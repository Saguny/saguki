import 'package:flutter/material.dart';

import 'db.dart';
import 'deck.dart';
import 'lang.dart';
import 'sync.dart';
import 'theme.dart';
import 'transfer_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Sync.start();
  runApp(MaterialApp(
    title: 'Saguki',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const Home(),
  ));
}

/// Centers content at a readable width on desktop.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 32), children: children),
        ),
      );
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: StreamBuilder(
            stream: db.watchDecks(),
            builder: (context, snap) {
              final decks = snap.data ?? [];
              final due = decks.fold(0, (a, d) => a + d.due), fresh = decks.fold(0, (a, d) => a + d.fresh);
              return PageBody(children: [
                Row(children: [
                  Expanded(child: Text('Today', style: T.largeTitle)),
                  const _SyncButton(),
                  IconButton(
                    tooltip: 'New deck',
                    icon: const Icon(Icons.add, color: C.accent),
                    onPressed: () => editDeck(context),
                  ),
                  PopupMenuButton(
                    tooltip: 'More',
                    icon: const Icon(Icons.more_horiz, color: C.accent),
                    itemBuilder: (_) => [
                      PopupMenuItem(onTap: () => importFile(context), child: const Text('Import Anki or Saguki file…')),
                      PopupMenuItem(onTap: () => exportFile(context), child: const Text('Export everything (.saguki)')),
                    ],
                  ),
                ]),
                Text(decks.isEmpty ? 'No decks yet' : '$due due · $fresh new', style: T.subhead),
                const SizedBox(height: 28),
                if (snap.hasData && decks.isEmpty)
                  _Empty(onCreate: () => editDeck(context))
                else if (decks.isNotEmpty)
                  Group(header: 'Decks', children: [for (final d in decks) _DeckRow(d)]),
              ]);
            },
          ),
        ),
      );
}

class _DeckRow extends StatelessWidget {
  const _DeckRow(this.d);
  final DeckWithCounts d;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DeckPage(d.deck.id))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(d.deck.name, style: ts(17, w: 600, lang: d.deck.language)),
                const SizedBox(height: 2),
                Text(languages[d.deck.language] ?? d.deck.language, style: ts(13, color: C.text3, lang: d.deck.language)),
              ]),
            ),
            if (d.due > 0) Text('${d.due}', style: ts(15, w: 600, color: C.accent)),
            if (d.fresh > 0) ...[
              const SizedBox(width: 12),
              Text('${d.fresh} new', style: ts(15, color: C.text2)),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: C.text3, size: 20),
          ]),
        ),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(children: [
          Text('Create your first deck', style: T.title3),
          const SizedBox(height: 6),
          Text('One deck per language or topic works well.', style: T.subhead, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton(onPressed: onCreate, child: const Text('Create deck')),
          const SizedBox(height: 8),
          TextButton(onPressed: () => importFile(context), child: const Text('Import from Anki')),
        ]),
      );
}

String _ago(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'just now';
  if (d.inHours < 1) return '${d.inMinutes} min ago';
  if (d.inDays < 1) return '${d.inHours} h ago';
  return '${d.inDays} d ago';
}

class _SyncButton extends StatelessWidget {
  const _SyncButton();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: Sync.status,
        builder: (context, s, _) => IconButton(
          tooltip: switch (s.state) {
            SyncState.off => 'Sync off',
            SyncState.syncing => 'Syncing…',
            SyncState.error => s.message,
            SyncState.idle => 'Synced ${s.last == null ? '' : _ago(s.last!)}',
          },
          icon: Icon(
            switch (s.state) {
              SyncState.off => Icons.cloud_off_outlined,
              SyncState.syncing => Icons.cloud_sync_outlined,
              SyncState.error => Icons.cloud_off_outlined,
              SyncState.idle => Icons.cloud_done_outlined,
            },
            color: switch (s.state) { SyncState.error => C.again, SyncState.off => C.text3, _ => C.accent },
          ),
          onPressed: () => showDialog(context: context, builder: (_) => const _SyncDialog()),
        ),
      );
}

class _SyncDialog extends StatefulWidget {
  const _SyncDialog();

  @override
  State<_SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends State<_SyncDialog> {
  final _url = TextEditingController(text: Sync.server);
  final _pw = TextEditingController();
  String? _error;
  bool _busy = false;

  Future<void> _connect() async {
    if (_url.text.trim().isEmpty || _pw.text.isEmpty) return setState(() => _error = 'Enter the server and password');
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await Sync.connect(_url.text, _pw.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: Sync.status,
        builder: (context, s, _) => AlertDialog(
          title: Text('Sync', style: T.headline),
          content: SizedBox(
            width: 380,
            child: Sync.connected
                ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(Uri.tryParse(Sync.server ?? '')?.host ?? '', style: T.body),
                    const SizedBox(height: 4),
                    Text(
                      switch (s.state) {
                        SyncState.syncing => 'Syncing…',
                        SyncState.error => s.message ?? 'Sync failed',
                        _ => s.last == null ? 'Not synced yet' : 'Last synced ${_ago(s.last!)}',
                      },
                      style: ts(15, color: s.state == SyncState.error ? C.again : C.text2),
                    ),
                  ])
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    if (s.message != null)
                      Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(s.message!, style: T.footnote)),
                    TextField(
                      controller: _url,
                      decoration: const InputDecoration(labelText: 'Server', hintText: 'saguki.example.com'),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pw,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password', errorText: _error),
                      onSubmitted: (_) => _connect(),
                    ),
                  ]),
          ),
          actions: Sync.connected
              ? [
                  TextButton(
                    onPressed: () async {
                      await Sync.disconnect();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text('Disconnect', style: ts(17, color: C.again)),
                  ),
                  TextButton(onPressed: s.state == SyncState.syncing ? null : Sync.run, child: const Text('Sync now')),
                ]
              : [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  TextButton(onPressed: _busy ? null : _connect, child: Text(_busy ? 'Connecting…' : 'Connect')),
                ],
        ),
      );
}
