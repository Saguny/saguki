/// Import/export (PLAN.md §4): .sgki (full fidelity), CSV/TSV, Anki .apkg/.colpkg import.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

import 'csv.dart';
import 'db.dart';
import 'lang.dart';

const _order = ['prefs', 'decks', 'notes', 'cards', 'review_logs'];
const csvHeader = ['term', 'pronunciation', 'meaning', 'explanation', 'example', 'example_translation', 'tags'];

// ---------------------------------------------------------------- .sgki

/// Zip with saguki.json holding raw rows. [deckId] limits it to one deck.
Future<List<int>> exportSaguki({String? deckId}) async {
  final where = {
    'prefs': deckId == null ? 'deleted = 0' : '?1 IS NULL', // profile only goes into full backups
    'decks': deckId == null ? 'deleted = 0' : 'deleted = 0 AND id = ?1',
    'notes': deckId == null ? 'deleted = 0' : 'deleted = 0 AND deck_id = ?1',
    'cards': deckId == null
        ? 'deleted = 0'
        : 'deleted = 0 AND note_id IN (SELECT id FROM notes WHERE deck_id = ?1)',
    'review_logs': deckId == null
        ? 'deleted = 0'
        : 'deleted = 0 AND card_id IN (SELECT c.id FROM cards c JOIN notes n ON n.id = c.note_id WHERE n.deck_id = ?1)',
  };
  final tables = {
    for (final t in _order)
      t: [
        for (final r in await db
            .customSelect('SELECT * FROM $t WHERE ${where[t]}', variables: [if (deckId != null) Variable(deckId)]).get())
          Map.of(r.data)..remove('dirty'),
      ],
  };
  final json = utf8.encode(jsonEncode({'format': 'saguki', 'version': 1, 'exported': nowMs(), 'tables': tables}));
  return ZipEncoder().encode(Archive()..add(ArchiveFile.bytes('saguki.json', json)));
}

Future<String> importSaguki(List<int> bytes) async {
  final f = ZipDecoder().decodeBytes(bytes).findFile('saguki.json');
  final j = f == null ? null : jsonDecode(utf8.decode(f.content));
  if (j is! Map || j['format'] != 'saguki') throw const FormatException('Not a Saguki export');
  var n = 0;
  await db.transaction(() async {
    await db.customStatement('PRAGMA defer_foreign_keys = ON');
    for (final t in _order) {
      for (final row in (j['tables'][t] as List? ?? []).cast<Map<String, dynamic>>()) {
        final local = await db.localVersion(t, row['id']);
        if (local != null && local.m >= (row['modified_at'] as int? ?? 0)) continue; // keep the newer copy
        if (await db.upsertRaw(t, row, dirty: true) && t == 'notes') n++;
      }
    }
  });
  return '$n cards imported';
}

// ---------------------------------------------------------------- CSV

Future<String> exportCsv(String deckId) async {
  final notes = await (db.select(db.notes)..where((n) => n.deckId.equals(deckId) & n.deleted.equals(false))).get();
  return toCsv([
    csvHeader,
    for (final n in notes)
      [n.term, n.pronunciation, n.meaning, n.explanation, n.example, n.exampleTranslation, n.tags],
  ]);
}

/// Header names (any case) understood on import, per field.
const _aliases = {
  'term': ['term', 'word', 'front', 'expression', 'vocab', 'kanji', 'hanzi'],
  'pronunciation': ['pronunciation', 'reading', 'kana', 'furigana', 'pinyin', 'zhuyin'],
  'meaning': ['meaning', 'english', 'back', 'definition', 'translation'],
  'explanation': ['explanation', 'notes', 'note', 'extra'],
  'example': ['example', 'sentence', 'usage'],
  'example_translation': ['example_translation', 'example translation', 'sentence translation', 'sentence meaning'],
  'tags': ['tags', 'tag'],
};

/// With a recognised header row, columns map by name; otherwise by the export order.
Future<String> importCsv(String text, Deck deck) async {
  final rows = parseCsv(text);
  if (rows.isEmpty) return 'File is empty';
  final head = rows.first.map((h) => h.trim().toLowerCase()).toList();
  final byName = {
    for (final e in _aliases.entries)
      if (head.indexWhere(e.value.contains) case final i when i >= 0) e.key: i,
  };
  final hasHeader = byName.containsKey('term');
  final col = hasHeader ? byName : {for (var i = 0; i < csvHeader.length; i++) csvHeader[i]: i};
  String get(List<String> r, String k) => (col[k] != null && col[k]! < r.length) ? r[col[k]!].trim() : '';
  var n = 0;
  await db.transaction(() async {
    for (final r in hasHeader ? rows.skip(1) : rows) {
      if (get(r, 'term').isEmpty) continue;
      await db.saveNote(NotesCompanion(
        deckId: Value(deck.id),
        term: Value(get(r, 'term')),
        pronunciation: Value(get(r, 'pronunciation')),
        meaning: Value(get(r, 'meaning')),
        explanation: Value(get(r, 'explanation')),
        example: Value(get(r, 'example')),
        exampleTranslation: Value(get(r, 'example_translation')),
        tags: Value(get(r, 'tags')),
      ));
      n++;
    }
  });
  return '$n cards imported';
}

// ---------------------------------------------------------------- Anki

typedef AnkiData = ({
  List<DecksCompanion> decks,
  List<NotesCompanion> notes,
  List<CardsCompanion> cards,
  List<ReviewLogsCompanion> logs,
});

/// Imports an Anki .apkg/.colpkg. IDs derive from Anki's, so re-importing updates instead of duplicating.
Future<String> importAnki(String path) async {
  final d = await Isolate.run(() => parseAnki(File(path).readAsBytesSync(), tmpDir: Directory.systemTemp.path));
  await db.batch((b) {
    b.insertAllOnConflictUpdate(db.decks, d.decks);
    b.insertAllOnConflictUpdate(db.notes, d.notes);
    b.insertAllOnConflictUpdate(db.cards, d.cards);
    b.insertAllOnConflictUpdate(db.reviewLogs, d.logs);
  });
  return '${d.decks.length} ${d.decks.length == 1 ? 'deck' : 'decks'}, ${d.notes.length} cards imported';
}

String _clean(String html) => html
    .replaceAll(RegExp(r'\[sound:[^\]]*\]'), '')
    .replaceAll(RegExp(r'<br\s*/?>|</div>|</p>', caseSensitive: false), '\n')
    .replaceAll(RegExp(r'<[^>]+>'), '')
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#39;', "'")
    .replaceAll('&amp;', '&')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();

/// Field name keywords, in priority order (example translation before example, etc.).
const _fieldKeys = [
  ('exampleTranslation', ['sentence meaning', 'sentence-english', 'sentence english', 'sentence translation', 'example translation', 'sentence_en']),
  ('pronunciation', ['reading', 'pronunciation', 'kana', 'furigana', 'pinyin', 'zhuyin', 'bopomofo', 'romaji']),
  ('term', ['expression', 'vocab', 'word', 'kanji', 'front', 'traditional', 'hanzi', 'term', '単語', '單字']),
  ('meaning', ['meaning', 'english', 'definition', 'translation', 'gloss', 'back']),
  ('example', ['sentence', 'example']),
  ('explanation', ['notes', 'explanation', 'extra', 'hint', 'comment']),
];

/// Maps our fields to Anki field indexes by name: exact match first, then substring.
Map<String, int> mapFields(List<String> names) {
  final lower = names.map((n) => n.toLowerCase().trim()).toList(), out = <String, int>{};
  int free(bool Function(String n) ok) {
    for (var j = 0; j < lower.length; j++) {
      if (!out.containsValue(j) && ok(lower[j])) return j;
    }
    return -1;
  }

  for (final (field, keys) in _fieldKeys) {
    final i = [free(keys.contains), free((n) => keys.any(n.contains))].firstWhere((i) => i >= 0, orElse: () => -1);
    if (i >= 0) out[field] = i;
  }
  // Unrecognised note types: first free field is the word, the next one the meaning.
  if (!out.containsKey('term')) out['term'] = max(free((_) => true), 0);
  if (!out.containsKey('meaning')) {
    final i = free((_) => true);
    if (i >= 0) out['meaning'] = i;
  }
  return out;
}

/// SM-2 ease factor (1300–3500‰) → FSRS difficulty (1–10).
double _difficultyFromEase(int factor) => (9 - (factor - 1300) * 7 / 2200).clamp(1, 10).toDouble();

/// Pure parse step, run in an isolate. [tmpDir] holds the extracted SQLite file briefly.
AnkiData parseAnki(List<int> bytes, {required String tmpDir}) {
  final zip = ZipDecoder().decodeBytes(bytes);
  final List<int> dbBytes;
  if (zip.findFile('collection.anki21b') case final f?) {
    dbBytes = ZstdDecoder().decodeBytes(f.content);
  } else if ((zip.findFile('collection.anki21') ?? zip.findFile('collection.anki2')) case final f?) {
    dbBytes = f.content;
  } else {
    throw const FormatException('Not an Anki package');
  }
  final tmp = File('$tmpDir/saguki-anki-${DateTime.now().microsecondsSinceEpoch}.db')..writeAsBytesSync(dbBytes);
  final a = sq.sqlite3.open(tmp.path, mode: sq.OpenMode.readOnly);
  try {
    final crt = a.select('SELECT crt FROM col').first['crt'] as int;

    // Note type field names and deck names: schema 18 has tables, older schemas JSON in `col`.
    final fields = <int, List<String>>{};
    final deckNames = <int, String>{};
    try {
      for (final r in a.select('SELECT ntid, name FROM fields ORDER BY ntid, ord')) {
        (fields[r['ntid'] as int] ??= []).add(r['name'] as String);
      }
      for (final r in a.select('SELECT id, name FROM decks')) {
        deckNames[r['id'] as int] = (r['name'] as String).replaceAll('\x1f', ' › ');
      }
    } on sq.SqliteException {
      final col = a.select('SELECT models, decks FROM col').first;
      (jsonDecode(col['models'] as String) as Map).forEach((id, m) {
        final f = (m['flds'] as List)..sort((x, y) => (x['ord'] as int).compareTo(y['ord'] as int));
        fields[int.parse(id)] = [for (final x in f) x['name'] as String];
      });
      (jsonDecode(col['decks'] as String) as Map).forEach((id, d) {
        deckNames[int.parse(id)] = (d['name'] as String).replaceAll('::', ' › ');
      });
    }

    final now = nowMs(), today = DateTime.now();
    final notes = <NotesCompanion>[], cards = <CardsCompanion>[], logs = <ReviewLogsCompanion>[];
    final noteDeck = <int, int>{}; // Anki note id -> Anki deck id (from its first card)
    final terms = <int, List<String>>{}; // Anki deck id -> sample terms for language detection

    final lastReview = {
      for (final r in a.select('SELECT cid, MAX(id) AS t FROM revlog GROUP BY cid')) r['cid'] as int: r['t'] as int,
    };
    // ponytail: only the first template (ord 0) is imported; reverse cards need P-later "reverse" support.
    for (final c in a.select('SELECT * FROM cards WHERE ord = 0')) {
      final nid = c['nid'] as int, did = c['did'] as int, type = c['type'] as int, ivl = c['ivl'] as int;
      noteDeck[nid] = did;
      Map? mem;
      try {
        final raw = c['data'] as String? ?? '';
        if (raw.startsWith('{')) mem = jsonDecode(raw) as Map;
      } catch (_) {}
      final s = (mem?['s'] as num?)?.toDouble(), d = (mem?['d'] as num?)?.toDouble();
      final last = lastReview[c['id']] == null ? null : DateTime.fromMillisecondsSinceEpoch(lastReview[c['id']]!);
      final isNew = type == 0;
      cards.add(CardsCompanion.insert(
        id: Value('anki-c${c['id']}'),
        noteId: 'anki-n$nid',
        due: Value(switch (type) {
          2 => DateTime.fromMillisecondsSinceEpoch((crt + (c['due'] as int) * 86400) * 1000),
          _ => today, // new and (re)learning cards are due now
        }),
        state: Value(switch (type) { 2 => 2, 3 => 3, _ => 1 }),
        step: Value(type == 2 ? null : 0),
        stability: Value(isNew ? null : s ?? (type == 1 ? null : max(ivl, 1).toDouble())),
        difficulty: Value(isNew ? null : d ?? (type == 1 ? null : _difficultyFromEase(c['factor'] as int))),
        reps: Value(isNew ? 0 : max(c['reps'] as int, 1)),
        lapses: Value(c['lapses'] as int),
        lastReview: Value(isNew ? null : last),
        modifiedAt: Value(now),
      ));
    }

    for (final n in a.select('SELECT id, mid, flds, tags FROM notes')) {
      final did = noteDeck[n['id']];
      if (did == null) continue;
      final vals = (n['flds'] as String).split('\x1f').map(_clean).toList();
      final map = mapFields(fields[n['mid']] ?? List.generate(vals.length, (i) => 'Field $i'));
      String v(String k) => map[k] != null && map[k]! < vals.length ? vals[map[k]!] : '';
      if (v('term').isEmpty) continue;
      (terms[did] ??= []).add(v('term'));
      notes.add(NotesCompanion.insert(
        id: Value('anki-n${n['id']}'),
        deckId: 'anki-d$did',
        term: v('term'),
        pronunciation: Value(v('pronunciation')),
        meaning: Value(v('meaning')),
        explanation: Value(v('explanation')),
        example: Value(v('example')),
        exampleTranslation: Value(v('exampleTranslation')),
        tags: Value((n['tags'] as String).trim()),
        modifiedAt: Value(now),
      ));
    }
    final keptNotes = {for (final n in notes) n.id.value};
    cards.removeWhere((c) => !keptNotes.contains(c.noteId.value));
    final keptCards = {for (final c in cards) c.id.value};

    final seen = <int>{};
    for (final r in a.select('SELECT id, cid, ease, time FROM revlog WHERE ease BETWEEN 1 AND 4 ORDER BY id')) {
      if (!keptCards.contains('anki-c${r['cid']}')) continue;
      logs.add(ReviewLogsCompanion.insert(
        id: Value('anki-r${r['id']}'),
        cardId: 'anki-c${r['cid']}',
        rating: r['ease'] as int,
        reviewedAt: DateTime.fromMillisecondsSinceEpoch(r['id'] as int),
        durationMs: (r['time'] as int).clamp(0, 60000),
        wasNew: seen.add(r['cid'] as int),
        modifiedAt: Value(now),
      ));
    }

    final decks = [
      for (final did in terms.keys)
        DecksCompanion.insert(
          id: Value('anki-d$did'),
          name: deckNames[did] ?? 'Anki deck',
          language: Value(_majorityLang(terms[did]!)),
          modifiedAt: Value(now),
        ),
    ];
    return (decks: decks, notes: notes, cards: cards, logs: logs);
  } finally {
    a.close();
    tmp.deleteSync();
  }
}

String _majorityLang(List<String> terms) {
  final counts = <String, int>{};
  for (final t in terms.take(200)) {
    final l = detectLang(t, fallback: 'ja');
    if (l != 'en') counts[l] = (counts[l] ?? 0) + 1;
  }
  return counts.isEmpty ? 'en' : counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
}
