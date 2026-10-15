import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/db.dart';
import 'package:saguki/stats.dart';

void main() {
  test('day rollover hour', () {
    final late = DateTime(2026, 3, 10, 2, 30);
    expect(dayStart(late), DateTime(2026, 3, 9, 4));
    expect(dayKey(late), '2026-03-09');
    rolloverHour = 0;
    expect(dayStart(late), DateTime(2026, 3, 10));
    expect(dayKey(late), '2026-03-10');
    rolloverHour = 4;
  });

  test('stats from review history', () async {
    db = AppDb(NativeDatabase.memory());
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('ja'), name: 'JP', language: const Value('ja')));
    await db.into(db.decks).insert(DecksCompanion.insert(id: const Value('zh'), name: 'ZH', language: const Value('zh-Hant')));
    for (final (deck, term) in [('ja', '勉強'), ('zh', '學生')]) {
      await db.saveNote(NotesCompanion(deckId: Value(deck), term: Value(term)));
    }
    final cards = await db.select(db.cards).get();
    final jaCard = cards.firstWhere((c) => true);
    // A mature JP card with 3 lapses, and a ZH card still new.
    await db.update(db.cards).replace(jaCard.copyWith(reps: 9, state: 2, stability: const Value(30), lapses: 3,
        due: DateTime.now().add(const Duration(days: 2))));

    // Reviews today, yesterday and 2 days ago (a 3-day streak), plus one 10 days ago.
    final now = DateTime.now();
    var i = 0;
    for (final (daysAgo, rating, isNew) in [(0, 3, false), (0, 1, false), (1, 3, false), (2, 4, false), (10, 3, true)]) {
      await db.into(db.reviewLogs).insert(ReviewLogsCompanion.insert(
            id: Value('l${i++}'),
            cardId: jaCard.id,
            rating: rating,
            reviewedAt: now.subtract(Duration(days: daysAgo)),
            durationMs: 5000,
            wasNew: isNew,
          ));
    }

    final s = await loadStats();
    expect(s.today, 2);
    expect(s.todayMs, 10000);
    expect(s.totalReviews, 5);
    expect(s.currentStreak, 3);
    expect(s.bestStreak, 3);
    expect(s.retention7, 0.75); // 3 of 4 non-new reviews were not Again
    expect(s.states, (fresh: 1, learning: 0, young: 0, mature: 1));
    expect(s.forecast.reduce((a, b) => a + b), 1);
    expect(s.forecast[2], 1);
    expect(s.buttons, [1, 0, 2, 1]);
    expect(s.hardest.single.lapses, 3);
    expect(s.topDecks.single.name, 'JP');

    final zh = await loadStats(lang: 'zh-Hant');
    expect(zh.totalReviews, 0);
    expect(zh.states.fresh, 1);
    expect(s.langs, ['ja', 'zh-Hant']);

    // Reminder text: the JP card is due in 2 days; the ZH card is new (daily limit 20).
    expect(await db.workAt(DateTime.now()), (due: 0, fresh: 1));
    expect(await db.workAt(DateTime.now().add(const Duration(days: 3))), (due: 1, fresh: 1));

    await db.setPref('name', 'Sagu');
    await db.setPref('name', 'Saguny');
    expect(await db.watchPrefs().first, {'name': 'Saguny'});
  });
}
