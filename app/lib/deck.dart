import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'db.dart';
import 'editor.dart';
import 'lang.dart';
import 'main.dart' show PageBody;
import 'review.dart';
import 'theme.dart';
import 'transfer_ui.dart';

class DeckPage extends StatefulWidget {
  const DeckPage(this.deckId, {super.key});
  final String deckId;

  @override
  State<DeckPage> createState() => _DeckPageState();
}

class _DeckPageState extends State<DeckPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: db.watchDecks().map((ds) => ds.where((d) => d.deck.id == widget.deckId).firstOrNull),
        builder: (context, snap) {
          final d = snap.data;
          if (d == null) return const Scaffold();
          final deck = d.deck, todo = d.due + d.fresh;
          return Scaffold(
            appBar: AppBar(actions: [
              IconButton(
                tooltip: 'New card',
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditor(deck: deck))),
              ),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz),
                itemBuilder: (_) => [
                  PopupMenuItem(onTap: () => editDeck(context, deck), child: const Text('Edit deck')),
                  PopupMenuItem(onTap: () => importCsvInto(context, deck), child: const Text('Import CSV/TSV…')),
                  PopupMenuItem(onTap: () => exportFile(context, deck: deck), child: const Text('Export deck (.saguki)')),
                  PopupMenuItem(onTap: () => exportFile(context, deck: deck, csv: true), child: const Text('Export deck (CSV)')),
                  PopupMenuItem(
                    onTap: () => _confirmDelete(context, deck),
                    child: Text('Delete deck', style: ts(16, color: C.again)),
                  ),
                ],
              ),
            ]),
            body: PageBody(children: [
              Text(deck.name, style: ts(34, w: 700, lang: deck.language)),
              const SizedBox(height: 4),
              Text(languages[deck.language] ?? deck.language, style: T.subhead),
              const SizedBox(height: 24),
              if (todo > 0)
                FilledButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewPage(deck))),
                  child: Text('Study  ·  ${d.due} due, ${d.fresh} new'),
                )
              else
                Text('You’re done for today.', style: T.subhead, textAlign: TextAlign.center),
              const SizedBox(height: 28),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search cards',
                  prefixIcon: Icon(Icons.search, color: C.text3, size: 20),
                  isDense: true,
                ),
                style: T.callout,
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                stream: db.watchNotes(deck.id, _query),
                builder: (context, snap) {
                  final notes = snap.data ?? [];
                  if (notes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Text(_query.isEmpty ? 'Add your first card with +' : 'No matches',
                          style: T.subhead, textAlign: TextAlign.center),
                    );
                  }
                  return Group(header: '${notes.length} cards', children: [
                    for (final n in notes)
                      InkWell(
                        onTap: () =>
                            Navigator.push(context, MaterialPageRoute(builder: (_) => NoteEditor(deck: deck, note: n))),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(children: [
                            Expanded(
                              child: Text(n.term,
                                  style: ts(17, lang: detectLang(n.term, fallback: deck.language)),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(n.meaning, style: T.subhead, overflow: TextOverflow.ellipsis),
                            ),
                          ]),
                        ),
                      ),
                  ]);
                },
              ),
            ]),
          );
        },
      );

  Future<void> _confirmDelete(BuildContext context, Deck deck) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete “${deck.name}”?', style: T.headline),
        content: Text('Its cards and scheduling go with it.', style: T.callout),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: Text('Delete', style: ts(17, color: C.again)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await db.deleteDeck(deck.id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

/// Create (deck == null) or edit a deck.
Future<void> editDeck(BuildContext context, [Deck? deck]) async {
  final name = TextEditingController(text: deck?.name);
  final perDay = TextEditingController(text: '${deck?.newPerDay ?? 20}');
  var lang = deck?.language ?? 'ja';
  final save = await showDialog<bool>(
    context: context,
    builder: (c) => StatefulBuilder(
      builder: (c, setLocal) => AlertDialog(
        title: Text(deck == null ? 'New deck' : 'Edit deck', style: T.headline),
        content: SizedBox(
          width: 360,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              initialValue: lang,
              decoration: const InputDecoration(labelText: 'Language'),
              dropdownColor: C.surface2,
              items: [
                for (final e in languages.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value, style: ts(16, lang: e.key))),
              ],
              onChanged: (v) => setLocal(() => lang = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: perDay,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'New cards per day'),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Save')),
        ],
      ),
    ),
  );
  if (save != true || name.text.trim().isEmpty) return;
  await db.saveDeck(DecksCompanion(
    id: deck == null ? const Value.absent() : Value(deck.id),
    name: Value(name.text.trim()),
    language: Value(lang),
    newPerDay: Value((int.tryParse(perDay.text) ?? 20).clamp(0, 9999)),
  ));
}
