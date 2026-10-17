import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'db.dart';
import 'lang.dart';
import 'profile.dart';
import 'pron.dart';
import 'srs.dart';
import 'theme.dart';

final _tts = FlutterTts();

Future<void> speak(String text, String lang) async {
  if (text.trim().isEmpty) return;
  try {
    final loc = ttsLocale(lang);
    await _tts.stop();
    await _tts.setLanguage(loc);
    // setLanguage alone can leave the default (e.g. Japanese) voice selected, which reads
    // Chinese with Japanese readings. Pick an exact-locale voice explicitly.
    final voices = await _tts.getVoices as List? ?? const [];
    String norm(Object? s) => '$s'.toLowerCase().replaceAll('_', '-');
    final v = voices.cast<Map>().where((v) => norm(v['locale']) == norm(loc)).firstOrNull;
    if (v != null) await _tts.setVoice({'name': '${v['name']}', 'locale': '${v['locale']}'});
    // Chinese is hard to follow at the Japanese-tuned default pace.
    await _tts.setSpeechRate(prefNum('ttsRate', 0.5) * (lang.startsWith('zh') ? 0.8 : 1));
    await _tts.speak(text);
  } catch (_) {} // no voice installed for this language: stay silent
}

const _ratings = [('Again', C.again), ('Hard', C.hard), ('Good', C.good), ('Easy', C.easy)];

/// Review screen, direction A "Quiet": content on the background, fixed control positions.
class ReviewPage extends StatefulWidget {
  const ReviewPage(this.deck, {super.key, this.practice = false});
  final Deck deck;

  /// Start in "Keep practicing" mode (the deck's done for today).
  final bool practice;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  Study? _cur;
  bool _revealed = false, _done = false;
  int _left = 0, _reviewed = 0;
  late int _extraNew = widget.practice ? 10 : 0; // "Keep practicing": more new cards, then review ahead
  late bool _ahead = widget.practice;
  List<Duration> _next = const [];
  ({Card before, String logId})? _last;
  final _watch = Stopwatch();
  int? _baseline; // your usual think time, for swipe auto-grading
  int _thinkMs = 0;
  double _dx = 0; // swipe offset
  bool _dragging = false, _busy = false;
  Timer? _wait; // ticks a countdown while the only card left is the one you just answered
  // Flip: a quick 3D turn that swaps faces at the midpoint. Enter: the next card pops in.
  late final _flip = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);
  late final _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 200), value: 1);

  Deck get deck => widget.deck;

  @override
  void initState() {
    super.initState();
    _load();
    thinkBaseline(deck.language).then((b) => _baseline = b);
  }

  @override
  void dispose() {
    _wait?.cancel();
    _flip.dispose();
    _enter.dispose();
    super.dispose();
  }

  /// What a right swipe (or →) records for the current card.
  int get _swipeGrade => _cur == null ? 3 : autoGrade(_cur!.card, _thinkMs, _baseline);

  Future<void> _load() async {
    final cur = await db.nextCard(deck, extraNew: _extraNew, ahead: _ahead),
        left = await db.remaining(deck, extraNew: _extraNew);
    if (!mounted) return;
    // nextCard learns ahead when nothing else is due, which would hand an Again card straight back.
    // Hold it until it's actually due instead (learning steps only, not days-away practice-ahead).
    _wait?.cancel();
    _wait = null;
    final early = cur != null && cur.card.id == _last?.before.id ? cur.card.due.difference(DateTime.now()) : Duration.zero;
    if (early > Duration.zero && early <= const Duration(minutes: 20)) {
      _wait = Timer.periodic(const Duration(seconds: 1), (t) {
        if (cur!.card.due.isAfter(DateTime.now())) return setState(() {});
        t.cancel();
        _load();
      });
    }
    setState(() {
      _cur = cur;
      _done = cur == null;
      _left = left;
      _revealed = false;
      _dx = 0;
      _dragging = false;
      _flip.value = 1;
    });
    if (cur != null) _enter.forward(from: 0);
    _watch
      ..reset()
      ..start();
  }

  void _reveal() {
    final c = _cur;
    if (c == null || _revealed || _wait != null) return;
    _thinkMs = _watch.elapsedMilliseconds;
    setState(() {
      _revealed = true;
      _next = preview(deck, c.card);
    });
    _flip.forward(from: 0);
    if (prefOn('autoPlay')) speak(c.note.term, _lang(c.note));
  }

  Future<void> _rate(int rating) async {
    final c = _cur;
    if (c == null || !_revealed || _busy) return;
    _busy = true;
    HapticFeedback.selectionClick();
    try {
      final logId = await answer(deck, c.card, rating, _watch.elapsedMilliseconds.clamp(0, 60000), thinkMs: _thinkMs);
      _last = (before: c.card, logId: logId);
      _reviewed++;
      await _load();
    } finally {
      _busy = false;
    }
  }

  Future<void> _undo() async {
    final l = _last;
    if (l == null) return;
    await undo(l.before, l.logId);
    _last = null;
    _reviewed--;
    await _load();
  }

  String _lang(Note n) => detectLang(n.term, fallback: deck.language);

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.space) {
      if (_revealed) {
        setState(() => _revealed = false); // flip back to the question
        _flip.forward(from: 0);
      } else {
        _reveal();
      }
    } else if (k == LogicalKeyboardKey.enter) {
      _revealed ? _rate(3) : _reveal();
    } else if (k == LogicalKeyboardKey.digit1 || k == LogicalKeyboardKey.numpad1) {
      _rate(1);
    } else if (k == LogicalKeyboardKey.digit2 || k == LogicalKeyboardKey.numpad2) {
      _rate(2);
    } else if (k == LogicalKeyboardKey.digit3 || k == LogicalKeyboardKey.numpad3) {
      _rate(3);
    } else if (k == LogicalKeyboardKey.digit4 || k == LogicalKeyboardKey.numpad4) {
      _rate(4);
    } else if (k == LogicalKeyboardKey.arrowLeft) {
      _rate(1);
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _rate(_swipeGrade);
    } else if (k == LogicalKeyboardKey.keyZ) {
      _undo();
    } else if (k == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final total = _reviewed + _left;
    return Scaffold(
      body: SafeArea(
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(children: [
                IconButton(
                  tooltip: 'Close (Esc)',
                  icon: const Icon(Icons.close, color: C.text3, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 1 : _reviewed / total,
                      minHeight: 3,
                      backgroundColor: C.surface2,
                      color: C.accent,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Undo (Z)',
                  icon: Icon(Icons.undo, color: _last == null ? C.border : C.text3, size: 22),
                  onPressed: _last == null ? null : _undo,
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(
                  child: Text('${languages[deck.language] ?? ''}  ·  ${deck.name}',
                      style: ts(12, color: C.text3, lang: deck.language), overflow: TextOverflow.ellipsis),
                ),
                if (!_done) Text(_left > 0 || !_ahead ? '$_left left' : 'Practicing ahead', style: T.caption),
              ]),
            ),
            Expanded(
              child: _done
                  ? _Finished(
                      reviewed: _reviewed,
                      more: _ahead
                          ? null
                          : () {
                              _extraNew += 10;
                              _ahead = true;
                              _load();
                            },
                    )
                  : _cur == null
                      ? const SizedBox()
                      : _wait != null
                          ? Center(child: Text('Back in ${_countdown(_cur!.card.due)}', style: T.subhead))
                          : LayoutBuilder(builder: (context, box) => _swipeable(box.maxWidth)),
            ),
            if (!_done && _wait == null) SizedBox(height: 76, child: _revealed ? _buttons() : _hint()),
          ]),
        ),
      ),
    );
  }

  Widget _animatedCard() => AnimatedBuilder(
        animation: Listenable.merge([_flip, _enter]),
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_flip.value);
          final face = _flip.value < 0.5 ? !_revealed : _revealed; // faces swap edge-on
          final pop = Curves.easeOutBack.transform(_enter.value);
          return Opacity(
            opacity: _enter.value,
            child: Transform.scale(
              scale: (0.94 + 0.06 * pop) * (1 + 0.06 * sin(pi * t)), // lifts slightly mid-turn
              child: Transform(
                alignment: Alignment.center,
                // Never past 90°, so the text is never mirrored.
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0015)
                  ..rotateY((t < 0.5 ? t : t - 1) * pi),
                child: _CardView(_cur!.note, _lang(_cur!.note), revealed: face),
              ),
            ),
          );
        },
      );

  static String _countdown(DateTime due) {
    final s = max(0, due.difference(DateTime.now()).inSeconds + 1);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  Widget _hint() => Center(
        child: Text(
            Platform.isAndroid || Platform.isIOS
                ? 'Tap to reveal\nthen swipe ← forgot · remembered →'
                : 'Space to flip\nthen ← forgot · remembered →',
            style: T.caption, textAlign: TextAlign.center),
      );

  /// Card that follows the finger once revealed: past a quarter of the width (or flung), left
  /// records Again and right records the auto grade, which the label shows before you let go.
  Widget _swipeable(double w) {
    final grade = _swipeGrade;
    final left = _dx < 0;
    final (name, color) = left ? _ratings[0] : _ratings[grade - 1];
    final interval = _next.length == 4 ? ' · ${fmtInterval(_next[left ? 0 : grade - 1])}' : '';
    final anim = _dragging ? Duration.zero : const Duration(milliseconds: 180);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _reveal,
      onHorizontalDragUpdate: !_revealed ? null : (d) => setState(() {
            _dragging = true;
            _dx += d.delta.dx;
          }),
      onHorizontalDragEnd: !_revealed
          ? null
          : (d) {
              final v = d.velocity.pixelsPerSecond.dx;
              // Read _dx here, not the build-time values: a quick flick can end before a rebuild.
              if (_dx.abs() > w * 0.25 || (v.abs() > 800 && v.sign == _dx.sign)) {
                _rate(_dx < 0 ? 1 : _swipeGrade);
              } else {
                setState(() {
                  _dragging = false;
                  _dx = 0;
                });
              }
            },
      child: Stack(children: [
        Positioned.fill(
          child: AnimatedSlide(
            offset: Offset(_dx / w, 0),
            duration: anim,
            curve: Curves.easeOut,
            child: AnimatedRotation(
              turns: _dx / w * 0.04,
              duration: anim,
              child: _animatedCard(),
            ),
          ),
        ),
        if (_dx != 0)
          Align(
            alignment: Alignment.topCenter,
            child: Opacity(
              opacity: (_dx.abs() / (w * 0.25)).clamp(0.0, 1.0),
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: C.surface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color),
                ),
                child: Text('$name$interval', style: ts(15, w: 600, color: color)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _buttons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          for (var i = 0; i < 4; i++)
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _rate(i + 1),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(_ratings[i].$1, style: ts(16, w: 600, color: _ratings[i].$2)),
                  const SizedBox(height: 2),
                  Text(_next.length == 4 ? fmtInterval(_next[i]) : '', style: T.caption),
                ]),
              ),
            ),
        ]),
      );
}

/// Word with its reading above each part: furigana, zhuyin or pinyin.
/// Hidden readings still take their space so nothing jumps on reveal.
class RubyText extends StatelessWidget {
  const RubyText(this.term, this.pron, this.lang, {super.key, required this.size, this.showRuby = true});
  final String term, pron, lang;
  final double size;
  final bool showRuby;

  @override
  Widget build(BuildContext context) {
    final rubyStyle = ts(max(12, size * 0.3), color: C.text2, lang: lang);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        for (final s in rubySegments(term, pron, lang))
          Column(mainAxisSize: MainAxisSize.min, children: [
            Visibility.maintain(
              visible: showRuby && s.ruby != null,
              child: Text(s.ruby ?? ' ', style: rubyStyle, textAlign: TextAlign.center),
            ),
            Text(s.base, style: ts(size, w: 600, lang: lang, height: 1.15), textAlign: TextAlign.center),
          ]),
      ],
    );
  }
}

class _CardView extends StatelessWidget {
  const _CardView(this.n, this.lang, {required this.revealed});
  final Note n;
  final String lang;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    // Outlined card; the border lights up in the accent colour once revealed.
    return Center(
        child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: C.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: revealed ? C.accent.withValues(alpha: 0.6) : C.border, width: 1.5),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            RubyText(n.term, n.pronunciation, lang, size: (wide ? 72 : 56) * prefNum('cardScale', 1), showRuby: revealed),
            if (revealed) ...[
              if (n.meaning.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(n.meaning, style: ts(22, color: C.accent), textAlign: TextAlign.center),
              ],
              if (n.explanation.isNotEmpty || n.example.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 22),
                  child: SizedBox(width: 160, child: Divider()),
                ),
              if (n.explanation.isNotEmpty)
                Text(n.explanation, style: ts(16, color: C.text2, height: 1.5), textAlign: TextAlign.center),
              if (n.example.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text.rich(_highlight(n.example, n.term), textAlign: TextAlign.center),
                if (n.exampleTranslation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(n.exampleTranslation, style: ts(14, color: C.text3), textAlign: TextAlign.center),
                ],
              ],
            ],
          ]),
        ),
      ),
    ));
  }

  /// Example sentence with the studied word in lavender.
  TextSpan _highlight(String ex, String term) {
    final base = ts(18, lang: lang, height: 1.5), hit = ts(18, w: 600, color: C.accent, lang: lang, height: 1.5);
    final parts = term.isEmpty ? [ex] : ex.split(term);
    return TextSpan(children: [
      for (var i = 0; i < parts.length; i++) ...[
        if (i > 0) TextSpan(text: term, style: hit),
        TextSpan(text: parts[i], style: base),
      ],
    ]);
  }
}

class _Finished extends StatelessWidget {
  const _Finished({required this.reviewed, this.more});
  final int reviewed;
  final VoidCallback? more; // null once there's nothing left to practice

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle_outline, color: C.accent, size: 40),
          const SizedBox(height: 12),
          Text('All done', style: T.title2),
          const SizedBox(height: 4),
          Text('$reviewed ${reviewed == 1 ? 'card' : 'cards'} reviewed', style: T.subhead),
          const SizedBox(height: 24),
          if (more != null) ...[
            FilledButton(onPressed: more, child: const Text('Keep practicing')),
            const SizedBox(height: 6),
            Text('10 more new cards, then cards due soonest', style: T.caption),
            const SizedBox(height: 12),
          ],
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to deck')),
        ]),
      );
}
