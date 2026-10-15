import 'package:drift/drift.dart' show Value, Variable;
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
Future<String> answer(Deck deck, Card card, int rating, int durationMs, {int? thinkMs}) async {
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
      thinkMs: Value(thinkMs),
      modifiedAt: Value(nowMs()),
    ));
    return log.id;
  });
}

/// Right swipe ("remembered") → Hard (2), Good (3) or Easy (4) from how long recall took
/// compared with your usual time. [thinkMs] runs from the card appearing to the reveal;
/// [baselineMs] is your median for recalled review cards (null until there's enough history).
int autoGrade(Card card, int thinkMs, int? baselineMs) {
  if (thinkMs > 60000) return 3; // probably looked away: no signal, don't punish
  final r = thinkMs / (baselineMs ?? 5000).clamp(1500, 20000);
  if (r >= 1.8) return 2; // got there, but slowly
  // Easy only for review cards: on new or learning cards it would skip the short steps.
  if (r <= 0.6 && card.reps > 0 && card.state == f.State.review.value) return 4;
  return 3;
}

/// Median think time of recent recalled reviews in [lang] decks, or null with under 20 samples.
Future<int?> thinkBaseline(String lang) async {
  final rows = await db.customSelect(
    'SELECT l.think_ms AS t FROM review_logs l JOIN cards c ON c.id = l.card_id JOIN notes n ON n.id = c.note_id '
    'JOIN decks d ON d.id = n.deck_id WHERE d.language = ? AND l.deleted = 0 AND l.was_new = 0 AND l.rating > 1 '
    'AND l.think_ms IS NOT NULL AND l.think_ms < 60000 ORDER BY l.reviewed_at DESC LIMIT 200',
    variables: [Variable(lang)],
  ).get();
  if (rows.length < 20) return null;
  final t = rows.map((r) => r.read<int>('t')).toList()..sort();
  return t[t.length ~/ 2];
}

/// Restores the card row as it was and tombstones the log (it may already be synced).
Future<void> undo(Card before, String logId) => db.transaction(() async {
      await (db.update(db.reviewLogs)..where((l) => l.id.equals(logId))).write(ReviewLogsCompanion(
          deleted: const Value(true), dirty: const Value(true), modifiedAt: Value(nowMs())));
      await db.update(db.cards).replace(before.copyWith(modifiedAt: nowMs(), dirty: true));
    });
