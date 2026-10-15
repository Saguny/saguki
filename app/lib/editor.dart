import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'db.dart';
import 'lang.dart';
import 'main.dart' show PageBody;
import 'profile.dart';
import 'pron.dart';
import 'review.dart' show RubyText, speak;
import 'sync.dart';
import 'theme.dart';

typedef _Hit = ({String term, String reading, List<String> senses});

class NoteEditor extends StatefulWidget {
  const NoteEditor({super.key, required this.deck, this.note});
  final Deck deck;
  final Note? note;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final n = widget.note;
  late final term = TextEditingController(text: n?.term);
  late final pron = TextEditingController(text: n?.pronunciation);
  late final meaning = TextEditingController(text: n?.meaning);
  late final expl = TextEditingController(text: n?.explanation);
  late final example = TextEditingController(text: n?.example);
  late final exampleTr = TextEditingController(text: n?.exampleTranslation);
  String? _error;
  Timer? _debounce;
  List<_Hit> _hits = const [];
  String _looked = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _termChanged(String _) {
    setState(() => _error = null);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _lookup);
  }

  /// Dictionary autofill: fills empty pronunciation + English with the best match; other matches stay tappable.
  Future<void> _lookup() async {
    final q = term.text.trim(), lang = _lang;
    if (q == _looked) return;
    _looked = q;
    final hits = q.isEmpty || !lang.startsWith(RegExp('ja|zh')) ? <_Hit>[] : await Sync.lookup(q, lang);
    if (!mounted || term.text.trim() != q) return;
    setState(() => _hits = hits);
    if (hits.isNotEmpty && pron.text.isEmpty && meaning.text.isEmpty) _fill(hits.first);
  }

  String _reading(String r) => switch (_lang) {
        'ja' => r,
        'zh-Hant' when pref('zhPron', 'zhuyin') == 'zhuyin' => zhuyin(r),
        _ => pinyinMarks(r),
      };

  void _fill(_Hit h) => setState(() {
        pron.text = _reading(h.reading);
        meaning.text = h.senses.first.replaceFirst(RegExp(r'^\((bound form|literary|coll\.)\)\s*'), '');
      });

  String get _lang => detectLang(term.text, fallback: widget.deck.language);

  Future<void> _save({bool another = false}) async {
    if (term.text.trim().isEmpty) return setState(() => _error = 'Enter the word first');
    await db.saveNote(NotesCompanion(
      id: n == null ? const Value.absent() : Value(n!.id),
      deckId: Value(widget.deck.id),
      term: Value(term.text.trim()),
      pronunciation: Value(pron.text.trim()),
      meaning: Value(meaning.text.trim()),
      explanation: Value(expl.text.trim()),
      example: Value(example.text.trim()),
      exampleTranslation: Value(exampleTr.text.trim()),
    ));
    if (!mounted) return;
    if (another) {
      for (final c in [term, pron, meaning, expl, example, exampleTr]) {
        c.clear();
      }
      setState(() {});
    } else {
      Navigator.pop(context);
    }
  }

  Widget _field(TextEditingController c, String label,
          {String? lang, int lines = 1, bool autofocus = false, ValueChanged<String>? onChanged}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          autofocus: autofocus,
          onChanged: onChanged,
          minLines: lines,
          maxLines: lines == 1 ? 1 : 6,
          style: ts(17, lang: lang),
          decoration: InputDecoration(labelText: label),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(n == null ? 'New card' : 'Edit card'),
          actions: [
            if (n != null)
              IconButton(
                tooltip: 'Delete card',
                icon: const Icon(Icons.delete_outline, color: C.again),
                onPressed: () async {
                  await db.deleteNote(n!.id);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            TextButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
        body: PageBody(children: [
          TextField(
            controller: term,
            autofocus: n == null,
            style: ts(28, w: 600, lang: _lang),
            onChanged: _termChanged,
            decoration: InputDecoration(
              labelText: 'Word',
              errorText: _error,
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                _LangChip(_lang),
                IconButton(
                  tooltip: 'Play',
                  icon: Icon(Icons.volume_up_outlined, color: C.accent, size: 20),
                  onPressed: () => speak(term.text, _lang),
                ),
              ]),
            ),
          ),
          if (term.text.trim().isNotEmpty && pron.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(child: RubyText(term.text.trim(), pron.text, _lang, size: 40)),
            ),
          if (_hits.isNotEmpty) ...[
            const SizedBox(height: 16),
            Group(header: 'Dictionary', children: [
              for (final h in _hits.take(4))
                InkWell(
                  onTap: () => _fill(h),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${h.term}  ${_reading(h.reading)}', style: ts(16, lang: _lang)),
                      Text(h.senses.take(2).join('; '), style: T.footnote, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
            ]),
          ] else if (!Sync.connected && _lang.startsWith(RegExp('ja|zh')) && term.text.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text('Connect sync to autofill from the dictionary.', style: T.caption),
            ),
          const SizedBox(height: 16),
          _field(
            pron,
            _lang == 'zh-Hant' ? 'Pronunciation (${pref('zhPron', 'zhuyin')})' : 'Pronunciation',
            lang: _lang,
            onChanged: (_) => setState(() {}),
          ),
          _field(meaning, 'English'),
          _field(expl, 'Explanation', lines: 2),
          _field(example, 'Usage example', lang: _lang, lines: 2),
          _field(exampleTr, 'Example translation', lines: 2),
          if (n == null)
            OutlinedButton(
              onPressed: () => _save(another: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: C.accent,
                side: const BorderSide(color: C.border),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Save and add another'),
            ),
        ]),
      );
}

class _LangChip extends StatelessWidget {
  const _LangChip(this.lang);
  final String lang;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: C.accentContainer, borderRadius: BorderRadius.circular(8)),
        child: Text(languages[lang] ?? lang, style: ts(12, color: C.accent, lang: lang)),
      );
}
