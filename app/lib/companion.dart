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

typedef ZeroLogs = ({int total, int today, int missed});

/// All reviews, today's (after the rollover hour), and whole days skipped before today.
Future<ZeroLogs> loadZeroLogs() async {
  final today = dayStart();
  final r = (await db.customSelect(
    'SELECT COUNT(*) AS n, SUM(reviewed_at >= ?1) AS t, MAX(CASE WHEN reviewed_at < ?1 THEN reviewed_at END) AS last '
    'FROM review_logs WHERE deleted = 0',
    variables: [Variable(today.millisecondsSinceEpoch ~/ 1000)],
  ).get())
      .first;
  final last = r.read<int?>('last');
  // Yesterday's last review → 0 missed. Hours/24 rounded so DST days still count as one.
  final gap = last == null
      ? 1
      : (today.difference(dayStart(DateTime.fromMillisecondsSinceEpoch(last * 1000))).inHours / 24).round();
  return (total: r.read<int>('n'), today: r.read<int?>('t') ?? 0, missed: gap > 1 ? gap - 1 : 0);
}

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
                    supportZoom: false,
                    disableContextMenu: true,
                    disableHorizontalScroll: true,
                    disableVerticalScroll: true,
                    overScrollMode: OverScrollMode.NEVER,
                  ),
                  onWebViewCreated: (c) => _web = c,
                  onLoadStop: (c, _) {
                    _loaded = true;
                    _push();
                    c.evaluateJavascript(source: 'zeroActive(${widget.active})');
                  },
                ),
              ),
      );
}
