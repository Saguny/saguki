import 'package:drift/drift.dart' show Value;
import 'package:fsrs/fsrs.dart' as f;

import 'db.dart';

f.Scheduler _scheduler(Deck d) => f.Scheduler(desiredRetention: d.desiredRetention);

f.Card _toFsrs(Card c) => f.Card(
      cardId: 0,
      state: f.State.fromValue(c.state),
      step: c.step,
      stability: c.stability,
      difficulty: c.difficulty,
      due: c.due.toUtc(),
      lastReview: c.lastReview?.toUtc(),
    );

/// Next interval per rating 1..4, for the button labels.
List<Duration> preview(Deck deck, Card card) {
  final s = _scheduler(deck), fc = _toFsrs(card), now = DateTime.now().toUtc();
  return [
    for (final r in f.Rating.values) s.reviewCard(fc, r, reviewDateTime: now).card.due.difference(now),
  ];
}

String fmtInterval(Duration d) => switch (d) {
      _ when d.inMinutes < 1 => '<1m',
      _ when d.inMinutes < 60 => '${d.inMinutes}m',
      _ when d.inHours < 24 => '${d.inHours}h',
      _ when d.inDays < 30 => '${d.inDays}d',
      _ when d.inDays < 365 => '${(d.inDays / 30).toStringAsFixed(1)}mo',
      _ => '${(d.inDays / 365).toStringAsFixed(1)}y',
    };

/// Applies a rating, writes the card and an append-only log. Returns the log id (for undo).
Future<String> answer(Deck deck, Card card, int rating, int durationMs) async {
  final now = DateTime.now().toUtc();
  final next = _scheduler(deck).reviewCard(_toFsrs(card), f.Rating.fromValue(rating), reviewDateTime: now).card;
  return db.transaction(() async {
    await (db.update(db.cards)..where((c) => c.id.equals(card.id))).write(CardsCompanion(
      due: Value(next.due.toLocal()),
      state: Value(next.state.value),
      step: Value(next.step),
      stability: Value(next.stability),
      difficulty: Value(next.difficulty),
      reps: Value(card.reps + 1),
      lapses: Value(card.lapses + (rating == 1 && card.state == f.State.review.value ? 1 : 0)),
      lastReview: Value(now.toLocal()),
      modifiedAt: Value(nowMs()),
      dirty: const Value(true),
    ));
    final log = await db.into(db.reviewLogs).insertReturning(ReviewLogsCompanion.insert(
      cardId: card.id,
      rating: rating,
      reviewedAt: now.toLocal(),
      durationMs: durationMs,
      wasNew: card.reps == 0,
      modifiedAt: Value(nowMs()),
    ));
    return log.id;
  });
}

/// Restores the card row as it was and tombstones the log (it may already be synced).
Future<void> undo(Card before, String logId) => db.transaction(() async {
      await (db.update(db.reviewLogs)..where((l) => l.id.equals(logId))).write(ReviewLogsCompanion(
          deleted: const Value(true), dirty: const Value(true), modifiedAt: Value(nowMs())));
      await db.update(db.cards).replace(before.copyWith(modifiedAt: nowMs(), dirty: true));
    });
