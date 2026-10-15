import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/db.dart';
import 'package:saguki/transfer.dart';
import 'package:sqlite3/sqlite3.dart' as sq;

/// Builds a minimal Anki package. [modern] = schema 18 tables + zstd anki21b, else legacy JSON in `col`.
List<int> fakeApkg({required bool modern}) {
  final path = '${Directory.systemTemp.createTempSync('apkg').path}/c.db';
  final a = sq.sqlite3.open(path);
  const crt = 1700000000; // collection creation (seconds)
  a.execute('CREATE TABLE col (crt INTEGER, models TEXT, decks TEXT)');
  if (modern) {
    a.execute("INSERT INTO col VALUES ($crt, '{}', '{}')");
    a.execute('CREATE TABLE fields (ntid INTEGER, ord INTEGER, name TEXT)');
    a.execute("INSERT INTO fields VALUES (1, 0, 'Expression'), (1, 1, 'Reading'), (1, 2, 'Meaning'), "
        "(1, 3, 'Sentence'), (1, 4, 'Sentence-English')");
    a.execute('CREATE TABLE decks (id INTEGER, name TEXT)');
    a.execute("INSERT INTO decks VALUES (10, 'Japanese\x1fCore')");
  } else {
    final models = jsonEncode({
      '1': {
        'flds': [
          {'name': 'Front', 'ord': 0},
          {'name': 'Back', 'ord': 1},
        ],
      },
    });
    final decks = jsonEncode({
      '10': {'name': 'Japanese::Core'},
    });
    a.execute('INSERT INTO col VALUES (?, ?, ?)', [crt, models, decks]);
  }
  a.execute('CREATE TABLE notes (id INTEGER, mid INTEGER, flds TEXT, tags TEXT)');
  a.execute('CREATE TABLE cards (id INTEGER, nid INTEGER, did INTEGER, ord INTEGER, type INTEGER, due INTEGER, '
      'ivl INTEGER, factor INTEGER, reps INTEGER, lapses INTEGER, data TEXT)');
  a.execute('CREATE TABLE revlog (id INTEGER, cid INTEGER, ease INTEGER, time INTEGER)');
  final f = modern
      ? ['勉強', 'べんきょう', 'study<br>learning', '毎日勉強します。', 'I study every day.']
      : ['学生', 'student'];
  a.execute('INSERT INTO notes VALUES (100, 1, ?, ?)', [f.join('\x1f'), ' jlpt5 ']);
  a.execute("INSERT INTO notes VALUES (101, 1, ?, '')", [(['新しい', 'あたらしい', 'new', '', ''].take(f.length)).join('\x1f')]);
  // Card 200: review card, due 400 days after crt, 30-day interval. Card 201: new. Card 202: reverse (skipped).
  a.execute("INSERT INTO cards VALUES (200, 100, 10, 0, 2, 400, 30, 2500, 5, 1, ?)",
      [modern ? '{"s":42.5,"d":6.1}' : '']);
  a.execute("INSERT INTO cards VALUES (201, 101, 10, 0, 0, 1, 0, 0, 0, 0, '')");
  a.execute("INSERT INTO cards VALUES (202, 100, 10, 1, 0, 1, 0, 0, 0, 0, '')");
  a.execute('INSERT INTO revlog VALUES (1700000100000, 200, 3, 4000), (1700500000000, 200, 1, 9000)');
  a.close();
  final db = File(path).readAsBytesSync();
  return ZipEncoder().encode(Archive()
    ..add(modern
        ? ArchiveFile.bytes('collection.anki21b', ZstdEncoder().encodeBytes(db))
        : ArchiveFile.bytes('collection.anki2', db)));
}

void main() {
  for (final modern in [false, true]) {
    test('parseAnki ${modern ? 'schema 18 + zstd' : 'legacy'}', () {
      final d = parseAnki(fakeApkg(modern: modern), tmpDir: Directory.systemTemp.path);
      expect(d.decks.single.name.value, 'Japanese › Core');
      expect(d.decks.single.language.value, 'ja');
      expect(d.notes, hasLength(2));
      expect(d.cards, hasLength(2)); // reverse card skipped
      final n = d.notes.firstWhere((n) => n.id.value == 'anki-n100');
      final review = d.cards.firstWhere((c) => c.id.value == 'anki-c200');
      expect(review.state.value, 2);
      expect(review.due.value, DateTime.fromMillisecondsSinceEpoch((1700000000 + 400 * 86400) * 1000));
      expect(d.logs.map((l) => l.wasNew.value), [true, false]);
      expect(d.cards.firstWhere((c) => c.id.value == 'anki-c201').reps.value, 0);
      if (modern) {
        expect((n.term.value, n.pronunciation.value, n.meaning.value), ('勉強', 'べんきょう', 'study\nlearning'));
        expect((n.example.value, n.exampleTranslation.value), ('毎日勉強します。', 'I study every day.'));
        expect((review.stability.value, review.difficulty.value), (42.5, 6.1)); // FSRS memory reused
      } else {
        expect((n.term.value, n.meaning.value, n.tags.value), ('学生', 'student', 'jlpt5'));
        expect(review.stability.value, 30); // from interval
      }
    });
  }

  test('.sgki and CSV round-trip', () async {
    db = AppDb(NativeDatabase.memory());
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('d1'), name: 'JP'));
    await db.saveNote(const NotesCompanion(deckId: Value('d1'), term: Value('勉強'), meaning: Value('study, learn')));
    final zip = await exportSaguki(deckId: 'd1');
    final csv = await exportCsv('d1');

    db = AppDb(NativeDatabase.memory());
    expect(await importSaguki(zip), '1 cards imported');
    final note = await db.select(db.notes).getSingle();
    expect((note.term, note.meaning), ('勉強', 'study, learn'));
    expect(await db.select(db.cards).get(), hasLength(1));
    expect(await importSaguki(zip), '0 cards imported'); // same data again: nothing newer

    final deck = await db.select(db.decks).getSingle();
    expect(await importCsv(csv, deck), '1 cards imported');
    expect(await importCsv('Word\tEnglish\n新しい\tnew\n', deck), '1 cards imported');
    final terms = (await db.select(db.notes).get()).map((n) => (n.term, n.meaning));
    expect(terms, containsAll([('勉強', 'study, learn'), ('新しい', 'new')]));
  });
}
