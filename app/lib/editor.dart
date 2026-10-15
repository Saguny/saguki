import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'db.dart';
import 'lang.dart';
import 'main.dart' show PageBody;
import 'review.dart' show speak;
import 'theme.dart';

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

  Widget _field(TextEditingController c, String label, {String? lang, int lines = 1, bool autofocus = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          autofocus: autofocus,
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
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: 'Word',
              errorText: _error,
              suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                _LangChip(_lang),
                IconButton(
                  tooltip: 'Play',
                  icon: const Icon(Icons.volume_up_outlined, color: C.accent, size: 20),
                  onPressed: () => speak(term.text, _lang),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          _field(pron, widget.deck.language == 'zh-Hant' ? 'Pronunciation (zhuyin)' : 'Pronunciation', lang: _lang),
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
