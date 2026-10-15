/// Stats (PLAN.md §5): plain SQL over review_logs and cards, so it all works offline.
library;

import 'package:drift/drift.dart';

import 'db.dart';

/// Day key with the day rollover applied, as SQLite computes it: 'YYYY-MM-DD'.
String dayKey(DateTime t) => t.subtract(Duration(hours: rolloverHour)).toIso8601String().substring(0, 10);
String get _sqlDay => "date(l.reviewed_at - ${rolloverHour * 3600}, 'unixepoch', 'localtime')";

class Stats {
  Stats({
    required this.daily,
    required this.dailyMs,
    required this.retention7,
    required this.retention30,
    required this.states,
    required this.forecast,
    required this.buttons,
    required this.hours,
    required this.hardest,
    required this.topDecks,
    required this.langs,
  });

  final Map<String, int> daily, dailyMs; // day key -> reviews / ms studied
  final double? retention7, retention30; // share of non-new reviews not answered Again
  final ({int fresh, int learning, int young, int mature}) states;
  final List<int> forecast; // due cards for today + next 29 days
  final List<int> buttons; // Again, Hard, Good, Easy counts (30 days)
  final Map<int, ({int n, int ok})> hours; // hour of day -> reviews / recalled
  final List<({String term, String meaning, String lang, int lapses})> hardest;
  final List<({String name, int reviews})> topDecks;
  final List<String> langs; // languages that have decks, for the filter

  int get today => daily[dayKey(DateTime.now())] ?? 0;
  int get todayMs => dailyMs[dayKey(DateTime.now())] ?? 0;
  int get totalReviews => daily.values.fold(0, (a, b) => a + b);
  int get totalMs => dailyMs.values.fold(0, (a, b) => a + b);
  int get learned => states.learning + states.young + states.mature;

  /// Consecutive days with reviews, ending today (or yesterday, if today isn't done yet).
  int get currentStreak {
    var d = DateTime.now();
    if (!daily.containsKey(dayKey(d))) d = d.subtract(const Duration(days: 1));
    var n = 0;
    while (daily.containsKey(dayKey(d))) {
      n++;
      d = d.subtract(const Duration(days: 1));
    }
    return n;
  }

  int get bestStreak {
    final days = daily.keys.map(DateTime.parse).toList()..sort();
    var best = 0, run = 0;
    for (var i = 0; i < days.length; i++) {
      run = i > 0 && days[i].difference(days[i - 1]).inHours.round() <= 25 ? run + 1 : 1;
      if (run > best) best = run;
    }
    return best;
  }

  /// Hour with the best recall, among hours with enough reviews to mean something.
  int? get bestHour {
    final ok = hours.entries.where((e) => e.value.n >= 20).toList();
    if (ok.isEmpty) return null;
    return ok.reduce((a, b) => b.value.ok / b.value.n > a.value.ok / a.value.n ? b : a).key;
  }
}

/// [lang] limits everything to decks of that language; null = all.
Future<Stats> loadStats({String? lang}) async {
  final now = DateTime.now();
  final join = 'JOIN cards c ON c.id = l.card_id JOIN notes n ON n.id = c.note_id JOIN decks d ON d.id = n.deck_id';
  const langOk = '(?1 IS NULL OR d.language = ?1)';
  Future<List<QueryRow>> q(String sql, [List<Object?> more = const []]) =>
      db.customSelect(sql, variables: [Variable(lang), ...more.map(Variable.new)]).get();
  int secs(DateTime t) => t.millisecondsSinceEpoch ~/ 1000;

  final daily = <String, int>{}, dailyMs = <String, int>{};
  for (final r in await q('SELECT $_sqlDay AS day, COUNT(*) AS n, SUM(l.duration_ms) AS ms FROM review_logs l $join '
      'WHERE l.deleted = 0 AND $langOk GROUP BY day')) {
    daily[r.read<String>('day')] = r.read<int>('n');
    dailyMs[r.read<String>('day')] = r.read<int>('ms');
  }

  Future<double?> retention(int days) async {
    final r = (await q(
      'SELECT SUM(l.rating > 1) AS ok, COUNT(*) AS n FROM review_logs l $join '
      'WHERE l.deleted = 0 AND l.was_new = 0 AND $langOk AND l.reviewed_at >= ?2',
      [secs(now.subtract(Duration(days: days)))],
    ))
        .first;
    final n = r.read<int>('n');
    return n == 0 ? null : (r.read<int?>('ok') ?? 0) / n;
  }

  const live = 'c.deleted = 0 AND n.deleted = 0 AND d.deleted = 0';
  final cardJoin = 'FROM cards c JOIN notes n ON n.id = c.note_id JOIN decks d ON d.id = n.deck_id WHERE $live AND $langOk';
  final s = (await q('SELECT SUM(c.reps = 0) AS f, SUM(c.reps > 0 AND c.state != 2) AS l, '
          'SUM(c.state = 2 AND COALESCE(c.stability, 0) < 21) AS y, SUM(c.state = 2 AND c.stability >= 21) AS m $cardJoin'))
      .first;
  int z(String k) => s.read<int?>(k) ?? 0;

  final forecast = List.filled(30, 0);
  final today = DateTime.parse(dayKey(now));
  for (final r in await q(
    "SELECT date(MAX(c.due, ?2) - ${rolloverHour * 3600}, 'unixepoch', 'localtime') AS day, COUNT(*) AS n $cardJoin "
    'AND c.reps > 0 AND c.due < ?3 GROUP BY day',
    [secs(now), secs(today.add(Duration(days: 30, hours: rolloverHour)))],
  )) {
    final i = DateTime.parse(r.read<String>('day')).difference(today).inHours ~/ 24;
    if (i >= 0 && i < 30) forecast[i] += r.read<int>('n');
  }

  final buttons = List.filled(4, 0);
  for (final r in await q(
    'SELECT l.rating AS r, COUNT(*) AS n FROM review_logs l $join '
    'WHERE l.deleted = 0 AND l.was_new = 0 AND $langOk AND l.reviewed_at >= ?2 GROUP BY l.rating',
    [secs(now.subtract(const Duration(days: 30)))],
  )) {
    final i = r.read<int>('r') - 1;
    if (i >= 0 && i < 4) buttons[i] = r.read<int>('n');
  }

  final hours = {
    for (final r in await q("SELECT CAST(strftime('%H', l.reviewed_at, 'unixepoch', 'localtime') AS INTEGER) AS h, "
        'COUNT(*) AS n, SUM(l.rating > 1) AS ok FROM review_logs l $join '
        'WHERE l.deleted = 0 AND l.was_new = 0 AND $langOk GROUP BY h'))
      r.read<int>('h'): (n: r.read<int>('n'), ok: r.read<int?>('ok') ?? 0),
  };

  final hardest = [
    for (final r in await q('SELECT n.term, n.meaning, d.language, c.lapses $cardJoin AND c.lapses > 0 '
        'ORDER BY c.lapses DESC LIMIT 8'))
      (term: r.read<String>('term'), meaning: r.read<String>('meaning'), lang: r.read<String>('language'), lapses: r.read<int>('lapses')),
  ];

  final topDecks = [
    for (final r in await q('SELECT d.name, COUNT(*) AS n FROM review_logs l $join '
        'WHERE l.deleted = 0 AND d.deleted = 0 AND $langOk GROUP BY d.id ORDER BY n DESC LIMIT 5'))
      (name: r.read<String>('name'), reviews: r.read<int>('n')),
  ];

  return Stats(
    daily: daily,
    dailyMs: dailyMs,
    retention7: await retention(7),
    retention30: await retention(30),
    states: (fresh: z('f'), learning: z('l'), young: z('y'), mature: z('m')),
    forecast: forecast,
    buttons: buttons,
    hours: hours,
    hardest: hardest,
    topDecks: topDecks,
    langs: [
      for (final r in await db.customSelect('SELECT DISTINCT language FROM decks WHERE deleted = 0 ORDER BY language').get())
        r.read<String>('language'),
    ],
  );
}

/// Reloads whenever cards, reviews or settings change (local edits and sync pulls).
Stream<Stats> watchStats({String? lang}) async* {
  yield await loadStats(lang: lang);
  await for (final _ in db.tableUpdates(TableUpdateQuery.onAllTables([db.reviewLogs, db.cards, db.decks, db.prefs]))) {
    yield await loadStats(lang: lang);
  }
}
