import 'package:flutter/material.dart' hide Card;
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'db.dart';
import 'lang.dart';
import 'profile.dart';
import 'srs.dart';
import 'theme.dart';

final _tts = FlutterTts();

Future<void> speak(String text, String lang) async {
  if (text.trim().isEmpty) return;
  try {
    await _tts.setLanguage(ttsLocale(lang));
    await _tts.setSpeechRate(prefNum('ttsRate', 0.5));
    await _tts.speak(text);
  } catch (_) {} // no voice installed for this language: stay silent
}

const _ratings = [('Again', C.again), ('Hard', C.hard), ('Good', C.good), ('Easy', C.easy)];

/// Review screen, direction A "Quiet": content on the background, fixed control positions.
class ReviewPage extends StatefulWidget {
  const ReviewPage(this.deck, {super.key});
  final Deck deck;

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Study? _cur;
  bool _revealed = false, _done = false;
  int _left = 0, _reviewed = 0;
  List<Duration> _next = const [];
  ({Card before, String logId})? _last;
  final _watch = Stopwatch();

  Deck get deck => widget.deck;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cur = await db.nextCard(deck), left = await db.remaining(deck);
    setState(() {
      _cur = cur;
      _done = cur == null;
      _left = left;
      _revealed = false;
    });
    _watch
      ..reset()
      ..start();
  }

  void _reveal() {
    final c = _cur;
    if (c == null || _revealed) return;
    setState(() {
      _revealed = true;
      _next = preview(deck, c.card);
    });
    if (prefOn('autoPlay')) speak(c.note.term, _lang(c.note));
  }

  Future<void> _rate(int rating) async {
    final c = _cur;
    if (c == null || !_revealed) return;
    HapticFeedback.selectionClick();
    final logId = await answer(deck, c.card, rating, _watch.elapsedMilliseconds.clamp(0, 60000));
    _last = (before: c.card, logId: logId);
    _reviewed++;
    await _load();
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
    if (k == LogicalKeyboardKey.space || k == LogicalKeyboardKey.enter) {
      _revealed ? _rate(3) : _reveal();
    } else if (k == LogicalKeyboardKey.digit1 || k == LogicalKeyboardKey.numpad1) {
      _rate(1);
    } else if (k == LogicalKeyboardKey.digit2 || k == LogicalKeyboardKey.numpad2) {
      _rate(2);
    } else if (k == LogicalKeyboardKey.digit3 || k == LogicalKeyboardKey.numpad3) {
      _rate(3);
    } else if (k == LogicalKeyboardKey.digit4 || k == LogicalKeyboardKey.numpad4) {
      _rate(4);
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
                if (!_done) Text('$_left left', style: T.caption),
              ]),
            ),
            Expanded(
              child: _done
                  ? _Finished(reviewed: _reviewed)
                  : _cur == null
                      ? const SizedBox()
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _reveal,
                          child: _CardView(_cur!.note, _lang(_cur!.note), revealed: _revealed),
                        ),
            ),
            if (!_done) SizedBox(height: 76, child: _revealed ? _buttons() : _hint()),
          ]),
        ),
      ),
    );
  }

  Widget _hint() => Center(child: Text('Tap or press Space to reveal', style: T.caption));

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

class _CardView extends StatelessWidget {
  const _CardView(this.n, this.lang, {required this.revealed});
  final Note n;
  final String lang;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 840;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Reserve the pronunciation line so the word never jumps on reveal.
            Visibility.maintain(
              visible: revealed && n.pronunciation.isNotEmpty,
              child: Text(n.pronunciation.isEmpty ? ' ' : n.pronunciation,
                  style: ts(wide ? 22 : 18, color: C.text2, lang: lang), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 4),
            Text(n.term, style: ts((wide ? 72 : 56) * prefNum('cardScale', 1), w: 600, lang: lang, height: 1.15), textAlign: TextAlign.center),
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
    );
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
  const _Finished({required this.reviewed});
  final int reviewed;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline, color: C.accent, size: 40),
          const SizedBox(height: 12),
          Text('All done', style: T.title2),
          const SizedBox(height: 4),
          Text('$reviewed ${reviewed == 1 ? 'card' : 'cards'} reviewed', style: T.subhead),
          const SizedBox(height: 24),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to deck')),
        ]),
      );
}
