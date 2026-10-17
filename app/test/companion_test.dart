import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/companion.dart';
import 'package:saguki/db.dart';

void main() {
  test('Zero counts reviews, Agains, the streak and whole days skipped before today', () async {
    db = AppDb(NativeDatabase.memory());
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('zh'), name: 'TW', language: const Value('zh-Hant')));
    await db.saveNote(const NotesCompanion(deckId: Value('zh'), term: Value('謝謝'), meaning: Value('thank you')));
    final card = (await db.select(db.cards).get()).first;
    var i = 0;
    Future<void> log(DateTime at, [int rating = 3]) => db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
        id: Value('l${i++}'), cardId: card.id, rating: rating, reviewedAt: at, durationMs: 1000, wasNew: false));
    DateTime daysAgo(int d) => dayStart().subtract(Duration(days: d)).add(const Duration(hours: 6));
    Future<(int, int, int, int, int)> state() async {
      final z = await loadZeroLogs();
      return (z.total, z.today, z.missed, z.again, z.streak);
    }

    expect(await state(), (0, 0, 0, 0, 0)); // brand new: nothing to be mad about
    expect((await loadZeroLogs()).words, isEmpty);
    await log(daysAgo(4));
    expect(await state(), (1, 0, 3, 0, 0));
    await log(DateTime.now(), 1);
    expect(await state(), (2, 1, 3, 1, 1)); // still knows you were gone
    await log(daysAgo(1));
    expect(await state(), (3, 1, 0, 1, 2));
    expect((await loadZeroLogs()).words, [{'t': '謝謝', 'm': 'thank you'}]);
    await db.close();
  });
}
