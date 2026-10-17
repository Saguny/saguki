import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/companion.dart';
import 'package:saguki/db.dart';

void main() {
  test('Zero counts reviews and whole days skipped before today', () async {
    db = AppDb(NativeDatabase.memory());
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('ja'), name: 'JP', language: const Value('ja')));
    await db.saveNote(const NotesCompanion(deckId: Value('ja'), term: Value('勉強')));
    final card = (await db.select(db.cards).get()).first;
    var i = 0;
    Future<void> log(DateTime at) => db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
        id: Value('l${i++}'), cardId: card.id, rating: 3, reviewedAt: at, durationMs: 1000, wasNew: false));
    DateTime daysAgo(int d) => dayStart().subtract(Duration(days: d)).add(const Duration(hours: 6));

    expect(await loadZeroLogs(), (total: 0, today: 0, missed: 0)); // brand new: nothing to be mad about
    await log(daysAgo(4));
    expect(await loadZeroLogs(), (total: 1, today: 0, missed: 3));
    await log(DateTime.now());
    expect(await loadZeroLogs(), (total: 2, today: 1, missed: 3)); // still knows you were gone
    await log(daysAgo(1));
    expect(await loadZeroLogs(), (total: 3, today: 1, missed: 0));
    await db.close();
  });
}
