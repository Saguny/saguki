/// The Zero tab: a Live2D companion whose mood follows your studying.
///
/// She's a web page (assets/zero/index.html, pixi + Cubism, all bundled so she works offline)
/// in a WebView, served from the app's assets on 127.0.0.1 so WebGL can read the model textures.
/// The app pushes the study state in with `zeroState({...})` and pauses her with
/// `zeroActive(false)` while the tab is hidden.
library;

import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show TableUpdateQuery, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'db.dart';
import 'theme.dart';

typedef ZeroLogs = ({int total, int today, int missed, int again, int streak, List<Map<String, String>> words});

/// All reviews, today's (after the rollover hour) and how many of those were Again, whole days skipped
/// before today, the streak, and Mandarin words you studied lately (for her quizzes and callbacks).
Future<ZeroLogs> loadZeroLogs() async {
  final today = dayStart();
  final r = (await db.customSelect(
    'SELECT COUNT(*) AS n, SUM(reviewed_at >= ?1) AS t, SUM(reviewed_at >= ?1 AND rating = 1) AS a, '
    'MAX(CASE WHEN reviewed_at < ?1 THEN reviewed_at END) AS last '
    'FROM review_logs WHERE deleted = 0',
    variables: [Variable(today.millisecondsSinceEpoch ~/ 1000)],
  ).get())
      .first;
  final last = r.read<int?>('last');
  // Yesterday's last review → 0 missed. Hours/24 rounded so DST days still count as one.
  final gap = last == null
      ? 1
      : (today.difference(dayStart(DateTime.fromMillisecondsSinceEpoch(last * 1000))).inHours / 24).round();
  final days = (await db.customSelect(
    "SELECT DISTINCT date(reviewed_at - ${rolloverHour * 3600}, 'unixepoch', 'localtime') AS d "
    'FROM review_logs WHERE deleted = 0 ORDER BY d DESC LIMIT 800',
  ).get())
      .map((x) => x.read<String>('d'))
      .toSet();
  var streak = 0; // ending today, or yesterday if today isn't done yet
  for (var d = days.contains(_key(today)) ? today : today.subtract(const Duration(days: 1));
      days.contains(_key(d));
      d = d.subtract(const Duration(days: 1))) {
    streak++;
  }
  final words = await db.customSelect(
    'SELECT n.term AS t, n.meaning AS m FROM review_logs l JOIN cards c ON c.id = l.card_id '
    'JOIN notes n ON n.id = c.note_id JOIN decks k ON k.id = n.deck_id '
    "WHERE l.deleted = 0 AND n.deleted = 0 AND n.meaning != '' AND k.language LIKE 'zh%' "
    'GROUP BY n.id ORDER BY MAX(l.reviewed_at) DESC LIMIT 12',
  ).get();
  return (
    total: r.read<int>('n'),
    today: r.read<int?>('t') ?? 0,
    missed: gap > 1 ? gap - 1 : 0,
    again: r.read<int?>('a') ?? 0,
    streak: streak,
    words: [for (final w in words) {'t': w.read<String>('t'), 'm': w.read<String>('m')}],
  );
}

String _key(DateTime day) => day.toIso8601String().substring(0, 10); // a dayStart() → its 'YYYY-MM-DD'

Stream<ZeroLogs> watchZeroLogs() async* {
  yield await loadZeroLogs();
  await for (final _ in db.tableUpdates(TableUpdateQuery.onTable(db.reviewLogs))) {
    yield await loadZeroLogs();
  }
}

class CompanionPage extends StatefulWidget {
  const CompanionPage({super.key, required this.active});
  final bool active;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  static final _server = InAppLocalhostServer(port: 47811, documentRoot: 'assets/');
  final _subs = <StreamSubscription>[];
  InAppWebViewController? _web;
  bool _started = false, _served = false, _loaded = false;
  ZeroLogs? _logs;
  int _due = 0;

  @override
  void initState() {
    super.initState();
    if (widget.active) _start();
  }

  @override
  void didUpdateWidget(CompanionPage old) {
    super.didUpdateWidget(old);
    if (widget.active) _start(); // the WebView isn't built until you first open her tab
    if (widget.active != old.active && _loaded) _web?.evaluateJavascript(source: 'zeroActive(${widget.active})');
    _push(); // the accent may have changed
  }

  Future<void> _start() async {
    if (_started) return;
    _started = true;
    if (!_server.isRunning()) await _server.start();
    _subs
      ..add(db.watchDecks().listen((ds) {
        _due = ds.fold(0, (n, d) => n + d.due + d.fresh);
        _push();
      }))
      ..add(watchZeroLogs().listen((l) {
        _logs = l;
        _push();
      }));
    if (mounted) setState(() => _served = true);
  }

  void _push() {
    final l = _logs;
    if (!_loaded || l == null) return;
    final now = DateTime.now();
    final state = {
      'total': l.total, 'today': l.today, 'missed': l.missed, 'due': _due,
      'again': l.again, 'streak': l.streak, 'words': l.words,
      'hour': now.hour, 'day': dayStart(now).toIso8601String(),
      'accent': '#${(C.accent.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
    };
    _web?.evaluateJavascript(source: 'zeroState(${jsonEncode(state)})');
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: C.bg,
        child: !_served
            ? const SizedBox.expand()
            : SafeArea(
                bottom: false,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri('http://127.0.0.1:47811/zero/index.html?app')),
                  initialSettings: InAppWebViewSettings(
                    transparentBackground: true,
                    mediaPlaybackRequiresUserGesture: false, // she talks without a tap first
                    supportZoom: false,
                    disableContextMenu: true,
                    // Her files come from the app's own assets: never serve a stale lines.js after an update.
                    cacheEnabled: false,
                    cacheMode: CacheMode.LOAD_NO_CACHE,
                    // No disable*Scroll: on Android those swallow every touch move, so head rubs
                    // never reach the page. The page is overflow:hidden and doesn't scroll anyway.
                    overScrollMode: OverScrollMode.NEVER,
                  ),
                  onWebViewCreated: (c) => _web = c,
                  onLoadStop: (c, _) {
                    _loaded = true;
                    // Before the first push: if you left her tab mid-load, she mustn't greet you from the background.
                    c.evaluateJavascript(source: 'zeroActive(${widget.active})');
                    _push();
                  },
                ),
              ),
      );
}
