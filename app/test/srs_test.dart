import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/db.dart';
import 'package:saguki/review.dart';
import 'package:saguki/srs.dart';

void main() {
  test('swipe right grades by recall time against your usual', () async {
    db = AppDb(NativeDatabase.memory());
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('d'), name: 'JP'));
    await db.saveNote(const NotesCompanion(deckId: Value('d'), term: Value('勉強')));
    final fresh = (await db.select(db.cards).get()).single;
    final review = fresh.copyWith(reps: 5, state: 2);

    expect(await thinkBaseline('ja'), null); // no history yet
    // Defaults (5 s usual): quick → Easy, slow → Hard, in between → Good.
    expect(autoGrade(review, 2000, null), 4);
    expect(autoGrade(review, 5000, null), 3);
    expect(autoGrade(review, 10000, null), 2);
    expect(autoGrade(review, 90000, null), 3); // walked away: no signal
    expect(autoGrade(fresh, 1000, null), 3); // never Easy on a new card

    // 25 recalled reviews at 2 s make 2 s the baseline, so 2.5 s is now ordinary.
    final now = DateTime.now();
    for (var i = 0; i < 25; i++) {
      await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
          cardId: fresh.id, rating: 3, reviewedAt: now, durationMs: 4000, wasNew: false, thinkMs: const Value(2000)));
    }
    final base = await thinkBaseline('ja');
    expect(base, 2000);
    expect(autoGrade(review, 2500, base), 3);
    expect(autoGrade(review, 1000, base), 4);
    expect(autoGrade(review, 4000, base), 2);
    expect(await thinkBaseline('zh-Hant'), null); // per language
  });

  testWidgets('swiping the revealed card left records Again, right the auto grade', (tester) async {
    db = AppDb(NativeDatabase.memory());
    await tester.runAsync(() async {
      await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('d'), name: 'JP'));
      await db.saveNote(const NotesCompanion(deckId: Value('d'), term: Value('一')));
      await db.saveNote(const NotesCompanion(deckId: Value('d'), term: Value('二')));
    });
    final deck = await tester.runAsync(() => db.select(db.decks).getSingle());
    await tester.pumpWidget(MaterialApp(home: ReviewPage(deck!)));

    Future<int?> swipe(double dx) async {
      for (var i = 0; i < 20 && find.byType(RubyText).evaluate().isEmpty; i++) {
        await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
      await tester.tap(find.byType(RubyText));
      await tester.pump();
      await tester.drag(find.byType(RubyText), Offset(dx, 0));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));
      await tester.pump();
      final logs = await tester.runAsync(() => db.select(db.reviewLogs).get());
      return logs!.isEmpty ? null : logs.last.rating;
    }

    expect(await swipe(-400), 1);
    expect(await swipe(400), 3); // new card, ordinary speed → Good
    await tester.runAsync(() => db.close());
  });
}
