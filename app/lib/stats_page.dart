import 'dart:math';

import 'package:flutter/material.dart';

import 'main.dart' show PageBody;
import 'profile.dart';
import 'stats.dart';
import 'theme.dart';

List<Color> get ramp => C.ramp;

String fmtN(int n) => n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+$)'), (_) => ',');

String fmtMs(int ms) {
  final m = (ms / 60000).round();
  return m < 60 ? '$m min' : '${m ~/ 60} h ${m % 60} min';
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
String _date(DateTime d) => '${_days[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';
String _key(DateTime d) => d.toIso8601String().substring(0, 10);
DateTime _today() => DateTime.parse(dayKey(DateTime.now()));
DateTime _plus(DateTime d, int days) => DateTime(d.year, d.month, d.day + days); // DST-safe

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  String? _lang;
  late Stream<Stats> _stream = watchStats(lang: _lang = langFilter);

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: prefs,
            builder: (context, _, _) {
              if (langFilter != _lang) _stream = watchStats(lang: _lang = langFilter);
              return _content();
            },
          ),
        ),
      );

  Widget _content() => StreamBuilder(
        stream: _stream,
        builder: (context, snap) {
          final s = snap.data;
          return PageBody(children: [
            Text('Stats', style: T.largeTitle),
            const SizedBox(height: 12),
            if (s != null) ...[LangPills(s.langs), ..._body(s)],
          ]);
        },
      );

  List<Widget> _body(Stats s) {
    final total = s.buttons.fold(0, (a, b) => a + b);
    final hour = s.bestHour;
    final today = _today();
    final last30 = [for (var i = 29; i >= 0; i--) s.daily[_key(_plus(today, -i))] ?? 0];
    return [
      Tiles([
        StatTile('Today', fmtN(s.today), s.today == 1 ? 'review · ${fmtMs(s.todayMs)}' : 'reviews · ${fmtMs(s.todayMs)}'),
        StatTile('Streak', '${s.currentStreak}', s.currentStreak == 1 ? 'day · best ${s.bestStreak}' : 'days · best ${s.bestStreak}'),
        StatTile('Learned', fmtN(s.learned), 'of ${fmtN(s.learned + s.states.fresh)} cards'),
        StatTile('Retention', s.retention30 == null ? '–' : '${(s.retention30! * 100).round()}%', 'last 30 days'),
      ]),
      const SizedBox(height: 16),
      Panel(
        title: 'Reviews',
        note: '${fmtN(s.totalReviews)} total · ${fmtMs(s.totalMs)} studied',
        child: Heatmap(s.daily),
      ),
      Panel(
        title: 'Last 30 days',
        note: 'Peak ${fmtN(last30.reduce(max))} a day',
        child: Bars(last30, tip: (i) => '${_date(_plus(today, i - 29))}: ${fmtN(last30[i])} reviews', ends: ('30 days ago', 'Today')),
      ),
      Panel(
        title: 'Due next 30 days',
        note: '${fmtN(s.forecast.fold(0, (a, b) => a + b))} reviews · ${fmtN(s.forecast.first)} today',
        child: Bars(s.forecast, tip: (i) => '${_date(_plus(today, i))}: ${fmtN(s.forecast[i])} due', ends: ('Today', 'In 30 days')),
      ),
      Panel(title: 'Cards', note: '${fmtN(s.learned + s.states.fresh)} total', child: CardStates(s)),
      if (total > 0)
        Panel(title: 'Answers', note: 'Reviews of seen cards, last 30 days', child: Answers(s.buttons)),
      if (hour != null)
        Panel(
          title: 'Best time',
          child: Text(
            'You remember best around ${hour.toString().padLeft(2, '0')}:00 '
            '(${(s.hours[hour]!.ok / s.hours[hour]!.n * 100).round()}% of ${fmtN(s.hours[hour]!.n)} reviews).',
            style: T.callout,
          ),
        ),
      if (s.hardest.isNotEmpty) ...[
        Group(header: 'Hardest cards', children: [
          for (final c in s.hardest)
            _Row(c.term, c.meaning, '${c.lapses}× forgot', lang: c.lang),
        ]),
        const SizedBox(height: 24),
      ],
      if (s.topDecks.isNotEmpty)
        Group(header: 'Most reviewed decks', children: [
          for (final d in s.topDecks) _Row(d.name, null, fmtN(d.reviews)),
        ]),
    ];
  }
}

class _Row extends StatelessWidget {
  const _Row(this.title, this.sub, this.trailing, {this.lang});
  final String title, trailing;
  final String? sub, lang;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ts(17, lang: lang), overflow: TextOverflow.ellipsis),
              if (sub != null && sub!.isNotEmpty) Text(sub!, style: T.footnote, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(width: 12),
          Text(trailing, style: T.subhead),
        ]),
      );
}

/// Headline number tile.
class StatTile {
  const StatTile(this.label, this.value, this.sub);
  final String label, value, sub;
}

/// 2 tiles per row on phones, 4 on wider screens.
class Tiles extends StatelessWidget {
  const Tiles(this.tiles, {super.key});
  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final cols = c.maxWidth >= 560 ? 4 : 2;
        final w = (c.maxWidth - 10 * (cols - 1)) / cols;
        return Wrap(spacing: 10, runSpacing: 10, children: [
          for (final t in tiles)
            Container(
              width: w,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: C.surface1, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.label, style: T.footnote),
                const SizedBox(height: 4),
                Text(t.value, style: ts(28, w: 700, height: 1.1)),
                const SizedBox(height: 2),
                Text(t.sub, style: T.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
        ]);
      });
}

/// Titled chart card.
class Panel extends StatelessWidget {
  const Panel({super.key, required this.title, this.note, required this.child});
  final String title;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: C.surface1, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: T.headline),
          if (note != null) Text(note!, style: T.footnote),
          const SizedBox(height: 14),
          child,
        ]),
      );
}

/// GitHub-style year grid: columns are weeks (Mon on top), newest on the right.
class Heatmap extends StatelessWidget {
  const Heatmap(this.daily, {super.key});
  final Map<String, int> daily;
  static const _cell = 12.0, _gap = 2.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final weeks = ((c.maxWidth + _gap) / (_cell + _gap)).floor().clamp(1, 53);
        final today = _today();
        final start = _plus(today, -((weeks - 1) * 7 + today.weekday - 1));
        final days = [for (var i = 0; i < weeks * 7; i++) _plus(start, i)];
        final top = days.map((d) => daily[_key(d)] ?? 0).fold(0, max);
        Widget cell(DateTime d) {
          if (d.isAfter(today)) return const SizedBox(width: _cell, height: _cell);
          final n = daily[_key(d)] ?? 0;
          return Tooltip(
            message: '${_date(d)}: ${n == 0 ? 'no' : fmtN(n)} review${n == 1 ? '' : 's'}',
            child: Container(
              width: _cell,
              height: _cell,
              decoration: BoxDecoration(
                color: ramp[n == 0 ? 0 : (n / top * 4).ceil().clamp(1, 4)],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (var w = 0; w < weeks; w++)
              Padding(
                padding: EdgeInsets.only(right: w < weeks - 1 ? _gap : 0),
                child: Column(children: [
                  for (var d = 0; d < 7; d++)
                    Padding(padding: EdgeInsets.only(bottom: d < 6 ? _gap : 0), child: cell(days[w * 7 + d])),
                ]),
              ),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Text('${_months[start.month - 1]} ${start.year}', style: T.caption),
            const Spacer(),
            Text('Less', style: T.caption),
            for (final r in ramp)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(color: r, borderRadius: BorderRadius.circular(2)),
              ),
            const SizedBox(width: 4),
            Text('More', style: T.caption),
          ]),
        ]);
      });
}

/// Single-series column chart: 2px gaps, 4px rounded tops on a baseline, tooltip per bar.
class Bars extends StatelessWidget {
  const Bars(this.values, {super.key, required this.tip, required this.ends, this.height = 96});
  final List<int> values;
  final String Function(int i) tip;
  final (String, String) ends;
  final double height;

  @override
  Widget build(BuildContext context) {
    final top = values.fold(0, max);
    return Column(children: [
      SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Tooltip(
                message: tip(i),
                // Full-height hit target; the bar sits at the bottom.
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  alignment: Alignment.bottomCenter,
                  child: values[i] == 0
                      ? null
                      : Container(
                          height: max(2, values[i] / top * height),
                          decoration: BoxDecoration(
                            color: C.accent,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                ),
              ),
            ),
        ]),
      ),
      const Divider(color: C.border, thickness: 1, height: 1),
      const SizedBox(height: 6),
      Row(children: [Text(ends.$1, style: T.caption), const Spacer(), Text(ends.$2, style: T.caption)]),
    ]);
  }
}

/// Card maturity as one stacked bar (ordinal, so the lavender ramp) with a labelled legend.
class CardStates extends StatelessWidget {
  const CardStates(this.s, {super.key});
  final Stats s;

  @override
  Widget build(BuildContext context) {
    final parts = [
      ('New', 'not studied yet', s.states.fresh, ramp[1]),
      ('Learning', 'in short steps', s.states.learning, ramp[2]),
      ('Young', 'interval under 21 days', s.states.young, ramp[3]),
      ('Mature', '21 days or more', s.states.mature, ramp[4]),
    ];
    final shown = parts.where((p) => p.$3 > 0).toList();
    return Column(children: [
      if (shown.isEmpty)
        Container(height: 12, decoration: BoxDecoration(color: C.surface2, borderRadius: BorderRadius.circular(4)))
      else
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Row(children: [
              for (var i = 0; i < shown.length; i++)
                Expanded(
                  flex: shown[i].$3,
                  child: Tooltip(
                    message: '${shown[i].$1}: ${fmtN(shown[i].$3)}',
                    child: Container(
                      margin: EdgeInsets.only(left: i > 0 ? 2 : 0),
                      color: shown[i].$4,
                    ),
                  ),
                ),
            ]),
          ),
        ),
      const SizedBox(height: 12),
      for (final p in parts)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: p.$4, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Text(p.$1, style: T.callout),
            const SizedBox(width: 8),
            Expanded(child: Text(p.$2, style: T.caption, overflow: TextOverflow.ellipsis)),
            Text(fmtN(p.$3), style: ts(15, w: 600)),
          ]),
        ),
    ]);
  }
}

/// Rating split. Each row is labelled, so identity never depends on color alone.
class Answers extends StatelessWidget {
  const Answers(this.counts, {super.key});
  final List<int> counts;
  static const _labels = [('Again', C.again), ('Hard', C.hard), ('Good', C.good), ('Easy', C.easy)];

  @override
  Widget build(BuildContext context) {
    final total = counts.fold(0, (a, b) => a + b);
    return Column(children: [
      for (var i = 0; i < 4; i++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(children: [
            SizedBox(width: 52, child: Text(_labels[i].$1, style: T.callout)),
            Expanded(
              child: Tooltip(
                message: '${_labels[i].$1}: ${fmtN(counts[i])}',
                child: LayoutBuilder(
                  builder: (context, c) => Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: max(counts[i] == 0 ? 0.0 : 2.0, counts[i] / total * c.maxWidth),
                      height: 10,
                      decoration: BoxDecoration(
                        color: _labels[i].$2,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 88,
              child: Text('${fmtN(counts[i])} · ${(counts[i] / total * 100).round()}%',
                  style: T.footnote, textAlign: TextAlign.right),
            ),
          ]),
        ),
    ]);
  }
}
