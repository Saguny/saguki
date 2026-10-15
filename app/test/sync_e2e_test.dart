// Two simulated devices syncing through a real server.
// Run: SAGUKI_TEST_URL=http://127.0.0.1:8787 SAGUKI_TEST_PW=... flutter test test/sync_e2e_test.dart
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/db.dart';
import 'package:saguki/srs.dart';
import 'package:saguki/sync.dart';

void main() {
  final url = Platform.environment['SAGUKI_TEST_URL'], pw = Platform.environment['SAGUKI_TEST_PW'];

  test('edits, reviews and deletes round-trip between devices', () async {
    final deckId = 'deck-e2e-${nowMs()}';
    final a = AppDb(NativeDatabase.memory()), b = AppDb(NativeDatabase.memory());
    final dirA = Directory.systemTemp.createTempSync('sgA'), dirB = Directory.systemTemp.createTempSync('sgB');
    Future<void> on(AppDb d, Directory dir, {bool connect = false}) async {
      db = d;
      Sync.configDir = dir.path;
      if (connect) {
        expect(await Sync.connect(url!, '', pw!), isNull);
      } else {
        await Sync.load();
        await Sync.run();
      }
    }

    // Device A creates a deck and a card.
    await on(a, dirA, connect: true);
    await a.into(a.decks).insert(DecksCompanion.insert(id: Value(deckId), name: 'E2E 日本語'));
    await a.saveNote(NotesCompanion(deckId: Value(deckId), term: Value('勉強'), meaning: Value('study')));
    await Sync.run();

    // Device B pulls it.
    await on(b, dirB, connect: true);
    final noteB = await (b.select(b.notes)..where((n) => n.deckId.equals(deckId))).getSingle();
    expect(noteB.term, '勉強');

    // B edits and reviews the card; A gets both.
    await b.saveNote(NotesCompanion(id: Value(noteB.id), meaning: const Value('to study')));
    final deckB = await (b.select(b.decks)..where((d) => d.id.equals(deckId))).getSingle();
    final cardB = await (b.select(b.cards)..where((c) => c.noteId.equals(noteB.id))).getSingle();
    await answer(deckB, cardB, 3, 1200);
    await Sync.run();

    await on(a, dirA);
    final noteA = await (a.select(a.notes)..where((n) => n.id.equals(noteB.id))).getSingle();
    expect(noteA.meaning, 'to study');
    final cardA = await (a.select(a.cards)..where((c) => c.id.equals(cardB.id))).getSingle();
    expect(cardA.reps, 1);
    expect(await (a.select(a.reviewLogs)..where((l) => l.cardId.equals(cardB.id))).get(), hasLength(1));
    expect(await (a.select(a.notes)..where((n) => n.dirty.equals(true))).get(), isEmpty);

    // A deletes the deck; B sees the tombstone.
    await a.deleteDeck(deckId);
    await Sync.run();
    await on(b, dirB);
    expect((await (b.select(b.decks)..where((d) => d.id.equals(deckId))).getSingle()).deleted, isTrue);
    expect((await (b.select(b.notes)..where((n) => n.id.equals(noteB.id))).getSingle()).deleted, isTrue);
  }, skip: url == null || pw == null ? 'set SAGUKI_TEST_URL and SAGUKI_TEST_PW' : false);
}
