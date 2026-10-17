import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'db.g.dart';

const _uuid = Uuid();

/// Sync clock: epoch milliseconds (second precision made same-second edits tie).
int nowMs() => DateTime.now().millisecondsSinceEpoch;

/// Sync columns (PLAN.md §1): client UUIDv7, last-write-wins clock, soft delete, push flag.
mixin Synced on Table {
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  IntColumn get modifiedAt => integer().clientDefault(nowMs)();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

class Decks extends Table with Synced {
  TextColumn get name => text()();
  TextColumn get language => text().withDefault(const Constant('ja'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get newPerDay => integer().withDefault(const Constant(20))();
  RealColumn get desiredRetention => real().withDefault(const Constant(0.9))();
}

class Notes extends Table with Synced {
  TextColumn get deckId => text().references(Decks, #id)();
  TextColumn get term => text()();
  TextColumn get pronunciation => text().withDefault(const Constant(''))();
  TextColumn get meaning => text().withDefault(const Constant(''))();
  TextColumn get explanation => text().withDefault(const Constant(''))();
  TextColumn get example => text().withDefault(const Constant(''))();
  TextColumn get exampleTranslation => text().withDefault(const Constant(''))();
  TextColumn get tags => text().withDefault(const Constant(''))(); // space separated
}

/// Scheduling state, one per note+direction. `reps == 0` means new.
class Cards extends Table with Synced {
  TextColumn get noteId => text().references(Notes, #id)();
  TextColumn get direction => text().withDefault(const Constant('fwd'))();
  DateTimeColumn get due => dateTime().clientDefault(DateTime.now)();
  IntColumn get state => integer().withDefault(const Constant(1))(); // fsrs State.value
  IntColumn get step => integer().nullable().withDefault(const Constant(0))();
  RealColumn get stability => real().nullable()();
  RealColumn get difficulty => real().nullable()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  IntColumn get lapses => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastReview => dateTime().nullable()();
}

/// Append-only review history; source for stats. Only an undo ever changes a row (soft delete).
class ReviewLogs extends Table {
  TextColumn get id => text().clientDefault(() => _uuid.v7())();
  IntColumn get modifiedAt => integer().withDefault(const Constant(0))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get cardId => text().references(Cards, #id)();
  IntColumn get rating => integer()();
  DateTimeColumn get reviewedAt => dateTime()();
  IntColumn get durationMs => integer()();
  BoolColumn get wasNew => boolean()();
  IntColumn get thinkMs => integer().nullable()(); // shown → revealed; drives swipe auto-grading
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  @override
  Set<Column> get primaryKey => {id};
}

/// Profile and settings, one row per key (id = key) so each setting syncs on its own.
class Prefs extends Table with Synced {
  TextColumn get value => text()();
}

class DeckWithCounts {
  DeckWithCounts(this.deck, this.due, this.fresh);
  final Deck deck;
  final int due, fresh;
}

typedef Study = ({Card card, Note note});

/// Hour the study day starts (Profile; default 4 am, like Anki).
int rolloverHour = 4;

DateTime dayStart([DateTime? now]) {
  now ??= DateTime.now();
  final d = DateTime(now.year, now.month, now.day, rolloverHour);
  return now.isBefore(d) ? d.subtract(const Duration(days: 1)) : d;
}

@DriftDatabase(tables: [Decks, Notes, Cards, ReviewLogs, Prefs])
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? e]) : super(e ?? driftDatabase(name: 'saguki'));

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(reviewLogs, reviewLogs.modifiedAt);
            await m.addColumn(reviewLogs, reviewLogs.deleted);
          }
          if (from < 3) {
            for (final t in ['decks', 'notes', 'cards', 'review_logs']) {
              await customStatement('UPDATE $t SET modified_at = modified_at * 1000');
            }
          }
          if (from < 4) await m.createTable(prefs);
          if (from < 5) await m.addColumn(reviewLogs, reviewLogs.thinkMs);
        },
        beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
      );

  static const _live = 'c.deleted = 0 AND n.deleted = 0';

  late final _columns = {for (final t in allTables) t.actualTableName: t.$columns.map((c) => c.name).toSet()};

  /// Upsert a raw row keyed by SQLite column names (sync pulls, .sgki imports).
  /// Unknown tables/columns are dropped. Returns false if the row was malformed.
  Future<bool> upsertRaw(String table, Map<String, dynamic> row, {required bool dirty}) async {
    final known = _columns[table];
    if (known == null) return false;
    final data = {
      for (final e in row.entries)
        if (known.contains(e.key) && e.key != 'dirty') e.key: e.value,
    }..['dirty'] = dirty ? 1 : 0;
    final keys = data.keys.toList();
    try {
      await customStatement(
        'INSERT INTO $table (${keys.join(', ')}) VALUES (${List.filled(keys.length, '?').join(', ')}) '
        'ON CONFLICT(id) DO UPDATE SET ${keys.map((k) => '$k = excluded.$k').join(', ')}',
        [for (final k in keys) data[k]],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Local modified_at for a row, or null if absent.
  Future<({int m, bool dirty})?> localVersion(String table, String id) async {
    final r = await customSelect('SELECT modified_at, dirty FROM $table WHERE id = ?', variables: [Variable(id)])
        .getSingleOrNull();
    return r == null ? null : (m: r.read<int>('modified_at'), dirty: r.read<int>('dirty') == 1);
  }

  /// New cards still allowed today for [deck], plus [extra] granted by "Keep practicing".
  Future<int> newLeft(Deck deck, {int extra = 0}) async {
    final r = await customSelect(
      'SELECT COUNT(*) AS n FROM review_logs l JOIN cards c ON c.id = l.card_id JOIN notes n ON n.id = c.note_id '
      'WHERE n.deck_id = ? AND l.was_new = 1 AND l.deleted = 0 AND l.reviewed_at >= ?',
      variables: [Variable(deck.id), Variable(dayStart())],
    ).getSingle();
    return (deck.newPerDay + extra - r.read<int>('n')).clamp(0, 9999);
  }

  Stream<List<DeckWithCounts>> watchDecks() {
    return customSelect(
      'SELECT d.*, '
      // 'now' evaluated in SQL so counts stay fresh when the stream re-runs after a sync.
      '(SELECT COUNT(*) FROM cards c JOIN notes n ON n.id = c.note_id WHERE n.deck_id = d.id AND $_live AND c.reps > 0 '
      "  AND c.due <= CAST(strftime('%s', 'now') AS INTEGER)) AS due_n, "
      '(SELECT COUNT(*) FROM cards c JOIN notes n ON n.id = c.note_id WHERE n.deck_id = d.id AND $_live AND c.reps = 0) AS new_n, '
      '(SELECT COUNT(*) FROM review_logs l JOIN cards c ON c.id = l.card_id JOIN notes n ON n.id = c.note_id '
      '  WHERE n.deck_id = d.id AND l.was_new = 1 AND l.deleted = 0 AND l.reviewed_at >= ?) AS new_done '
      'FROM decks d WHERE d.deleted = 0 ORDER BY d.name COLLATE NOCASE',
      variables: [Variable(dayStart())],
      readsFrom: {decks, notes, cards, reviewLogs},
    ).watch().map((rows) => [
          for (final r in rows)
            if (decks.map(r.data) case final d)
              DeckWithCounts(d, r.read<int>('due_n'),
                  r.read<int>('new_n').clamp(0, (d.newPerDay - r.read<int>('new_done')).clamp(0, 9999))),
        ]);
  }

  /// Reviews due by [at] plus new cards the daily limits allow (for the reminder text).
  Future<({int due, int fresh})> workAt(DateTime at) async {
    final r = await customSelect(
      'SELECT (SELECT COUNT(*) FROM cards c JOIN notes n ON n.id = c.note_id JOIN decks d ON d.id = n.deck_id '
      '  WHERE $_live AND d.deleted = 0 AND c.reps > 0 AND c.due <= ?) AS due, '
      '(SELECT COALESCE(SUM(MIN(x.n, x.lim)), 0) FROM (SELECT COUNT(*) AS n, d.new_per_day AS lim FROM cards c '
      '  JOIN notes n ON n.id = c.note_id JOIN decks d ON d.id = n.deck_id '
      '  WHERE $_live AND d.deleted = 0 AND c.reps = 0 GROUP BY d.id) x) AS fresh',
      variables: [Variable(at)],
    ).getSingle();
    return (due: r.read<int>('due'), fresh: r.read<int>('fresh'));
  }

  Stream<List<Note>> watchNotes(String deckId, String query) {
    final q = select(notes)..where((n) => n.deckId.equals(deckId) & n.deleted.equals(false));
    if (query.isNotEmpty) {
      final like = '%$query%';
      q.where((n) => n.term.like(like) | n.meaning.like(like) | n.pronunciation.like(like));
    }
    q.orderBy([(n) => OrderingTerm.desc(n.modifiedAt)]);
    return q.watch();
  }

  Future<Study?> _first(String where, List<Variable> vars, {String order = 'c.due'}) async {
    final rows = await customSelect(
      'SELECT c.id AS cid, n.id AS nid FROM cards c JOIN notes n ON n.id = c.note_id '
      'WHERE n.deck_id = ? AND $_live AND $where ORDER BY $order LIMIT 1',
      variables: vars,
    ).get();
    if (rows.isEmpty) return null;
    final card = await (select(cards)..where((c) => c.id.equals(rows.first.read<String>('cid')))).getSingle();
    final note = await (select(notes)..where((n) => n.id.equals(rows.first.read<String>('nid')))).getSingle();
    return (card: card, note: note);
  }

  /// Anki order: due learning → due review → new (within daily limit + [extraNew]) → learning due
  /// within 20 min → with [ahead], whatever is due soonest ("Keep practicing").
  Future<Study?> nextCard(Deck deck, {int extraNew = 0, bool ahead = false}) async {
    final now = DateTime.now();
    final id = Variable(deck.id);
    return await _first('c.reps > 0 AND c.state != 2 AND c.due <= ?', [id, Variable(now)]) ??
        await _first('c.reps > 0 AND c.due <= ?', [id, Variable(now)]) ??
        (await newLeft(deck, extra: extraNew) > 0 ? await _first('c.reps = 0', [id], order: 'n.rowid') : null) ??
        await _first('c.reps > 0 AND c.state != 2 AND c.due <= ?', [id, Variable(now.add(const Duration(minutes: 20)))]) ??
        (ahead ? await _first('c.reps > 0', [id]) : null);
  }

  /// Something to study while [waiting] sits out its learning step: a new card past the daily limit,
  /// else the soonest-due other card (practice ahead).
  Future<Study?> filler(Deck deck, String waiting) async {
    final id = Variable(deck.id);
    return await _first('c.reps = 0', [id], order: 'n.rowid') ??
        await _first('c.reps > 0 AND c.id != ?', [id, Variable(waiting)]);
  }

  /// Cards left in this session (for the progress bar).
  Future<int> remaining(Deck deck, {int extraNew = 0}) async {
    final soon = DateTime.now().add(const Duration(minutes: 20));
    final r = await customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM cards c JOIN notes n ON n.id = c.note_id WHERE n.deck_id = ?1 AND $_live AND c.reps > 0 AND c.due <= ?2) AS due_n, '
      '(SELECT COUNT(*) FROM cards c JOIN notes n ON n.id = c.note_id WHERE n.deck_id = ?1 AND $_live AND c.reps = 0) AS new_n',
      variables: [Variable(deck.id), Variable(soon)],
    ).getSingle();
    return r.read<int>('due_n') + r.read<int>('new_n').clamp(0, await newLeft(deck, extra: extraNew));
  }

  Future<void> saveNote(NotesCompanion n) => transaction(() async {
        if (n.id.present) {
          await (update(notes)..where((x) => x.id.equals(n.id.value)))
              .write(n.copyWith(modifiedAt: Value(nowMs()), dirty: const Value(true)));
        } else {
          final note = await into(notes).insertReturning(n);
          await into(cards).insert(CardsCompanion.insert(noteId: note.id));
        }
      });

  Future<void> deleteNote(String id) => transaction(() async {
        final now = Value(nowMs());
        await (update(notes)..where((x) => x.id.equals(id)))
            .write(NotesCompanion(modifiedAt: now, deleted: const Value(true), dirty: const Value(true)));
        await (update(cards)..where((x) => x.noteId.equals(id)))
            .write(CardsCompanion(modifiedAt: now, deleted: const Value(true), dirty: const Value(true)));
      });

  Stream<Map<String, String>> watchPrefs() => (select(prefs)..where((p) => p.deleted.equals(false)))
      .watch()
      .map((rows) => {for (final p in rows) p.id: p.value});

  Future<void> setPref(String key, String value) => into(prefs).insertOnConflictUpdate(
      PrefsCompanion.insert(id: Value(key), value: value, modifiedAt: Value(nowMs()), dirty: const Value(true)));

  Future<void> saveDeck(DecksCompanion d) async {
    if (d.id.present) {
      await (update(decks)..where((x) => x.id.equals(d.id.value)))
          .write(d.copyWith(modifiedAt: Value(nowMs()), dirty: const Value(true)));
    } else {
      await into(decks).insert(d);
    }
  }

  Future<void> deleteDeck(String id) => transaction(() async {
        final now = Value(nowMs());
        await (update(decks)..where((x) => x.id.equals(id)))
            .write(DecksCompanion(modifiedAt: now, deleted: const Value(true), dirty: const Value(true)));
        for (final n in await (select(notes)..where((x) => x.deckId.equals(id))).get()) {
          await deleteNote(n.id);
        }
      });
}

/// Swappable so tests can run two in-memory "devices".
AppDb db = AppDb();
