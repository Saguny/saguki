import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';

import 'db.dart';
import 'lang.dart';
import 'main.dart' show PageBody, SyncDialog;
import 'reminders.dart';
import 'stats.dart';
import 'stats_page.dart';
import 'sync.dart';
import 'theme.dart';
import 'transfer_ui.dart';

/// Synced profile + settings (the `prefs` table), mirrored here for synchronous reads.
final prefs = ValueNotifier<Map<String, String>>({});
StreamSubscription<Map<String, String>>? _prefsSub;

void listenPrefs() {
  _prefsSub?.cancel();
  _prefsSub = db.watchPrefs().listen((p) {
    // Globals read during build/queries; set before listeners rebuild.
    accentPick = accentSwatches[p['accent']];
    rolloverHour = int.tryParse(p['rollover'] ?? '') ?? 4;
    prefs.value = p;
  });
}

String pref(String key, [String fallback = '']) => prefs.value[key] ?? fallback;
double prefNum(String key, double fallback) => double.tryParse(prefs.value[key] ?? '') ?? fallback;
bool prefOn(String key, {bool fallback = true}) => (prefs.value[key] ?? '$fallback') == 'true';

/// Language picked in the pill bar (shared by Today and Stats), or null for all.
String? get langFilter => pref('langFilter').isEmpty ? null : pref('langFilter');

/// `All · 日本語 · 繁體中文` quick switch (PLAN.md §3). Hidden with fewer than two languages.
class LangPills extends StatelessWidget {
  const LangPills(this.langs, {super.key});
  final List<String> langs;

  @override
  Widget build(BuildContext context) {
    if (langs.length < 2) return const SizedBox.shrink();
    final cur = langs.contains(langFilter) ? langFilter : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(spacing: 8, runSpacing: 8, children: [
        for (final l in [null, ...langs])
          ChoiceChip(
            label: Text(l == null ? 'All' : languages[l] ?? l, style: ts(14, lang: l, color: cur == l ? C.accent : C.text2)),
            selected: cur == l,
            showCheckmark: false,
            selectedColor: C.accentContainer,
            backgroundColor: C.surface1,
            side: BorderSide.none,
            shape: const StadiumBorder(),
            onSelected: (_) => db.setPref('langFilter', l ?? ''),
          ),
      ]),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: prefs,
            builder: (context, _, _) {
              final name = pref('name', 'You');
              return PageBody(children: [
                Text('Profile', style: T.largeTitle),
                const SizedBox(height: 20),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => showDialog(context: context, builder: (_) => const _EditProfile()),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Avatar(size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(name, style: T.title2),
                          Text(pref('bio').isEmpty ? 'Tap to edit your profile' : pref('bio'), style: T.subhead),
                        ]),
                      ),
                      const Icon(Icons.chevron_right, color: C.text3),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                  stream: watchStats(),
                  builder: (context, snap) {
                    final s = snap.data;
                    return Tiles([
                      StatTile('Learned', s == null ? '–' : fmtN(s.learned), 'cards'),
                      StatTile('Streak', s == null ? '–' : '${s.currentStreak}', 'best ${s?.bestStreak ?? 0}'),
                      StatTile('Reviews', s == null ? '–' : fmtN(s.totalReviews), 'all time'),
                      StatTile('Studied', s == null ? '–' : fmtMs(s.totalMs), 'all time'),
                    ]);
                  },
                ),
                const SizedBox(height: 28),
                Group(header: 'Review', children: [
                  _Slider(
                    label: 'Card text size',
                    value: prefNum('cardScale', 1),
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    show: (v) => '${(v * 100).round()}%',
                    onChanged: (v) => db.setPref('cardScale', '$v'),
                  ),
                  SwitchListTile(
                    title: Text('Read the word aloud on reveal', style: T.body),
                    value: prefOn('autoPlay'),
                    activeTrackColor: C.accent,
                    onChanged: (v) => db.setPref('autoPlay', '$v'),
                  ),
                  ListTile(
                    title: Text('Chinese pronunciation', style: T.body),
                    trailing: SegmentedButton(
                      showSelectedIcon: false,
                      segments: const [
                        ButtonSegment(value: 'zhuyin', label: Text('ㄅㄆㄇ')),
                        ButtonSegment(value: 'pinyin', label: Text('Pīnyīn')),
                      ],
                      selected: {pref('zhPron', 'zhuyin')},
                      onSelectionChanged: (v) => db.setPref('zhPron', v.first),
                    ),
                  ),
                  _Slider(
                    label: 'Speech speed',
                    value: prefNum('ttsRate', 0.5),
                    min: 0.25,
                    max: 0.75,
                    divisions: 4,
                    show: (v) => const ['Slowest', 'Slow', 'Normal', 'Fast', 'Fastest'][((v - 0.25) / 0.125).round().clamp(0, 4)],
                    onChanged: (v) => db.setPref('ttsRate', '$v'),
                  ),
                ]),
                if (remindersSupported) ...[
                  const SizedBox(height: 24),
                  Group(header: 'Reminder', children: [
                    SwitchListTile(
                      title: Text('Daily reminder', style: T.body),
                      subtitle: Text('Only when cards are waiting', style: T.footnote),
                      value: pref('reminder').isNotEmpty,
                      activeTrackColor: C.accent,
                      onChanged: (on) async {
                        if (on && !await askNotificationPermission()) return;
                        final v = on ? '19:00' : '';
                        await db.setPref('reminder', v);
                        await scheduleReminders(v);
                      },
                    ),
                    if (pref('reminder').isNotEmpty)
                      ListTile(
                        title: Text('Time', style: T.body),
                        trailing: Text(pref('reminder'), style: T.subhead),
                        onTap: () async {
                          final [h, m] = pref('reminder').split(':').map(int.parse).toList();
                          final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: h, minute: m));
                          if (t == null) return;
                          final v = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                          await db.setPref('reminder', v);
                          await scheduleReminders(v);
                        },
                      ),
                  ]),
                ],
                const SizedBox(height: 24),
                Group(header: 'Appearance & schedule', children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text('Accent color', style: T.body)),
                        Text(pref('accent', 'Lavender'), style: T.subhead),
                      ]),
                      const SizedBox(height: 12),
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        for (final MapEntry(key: name, value: color) in accentSwatches.entries)
                          Tooltip(
                            message: name,
                            child: Semantics(
                              button: true,
                              selected: C.accent == color,
                              label: '$name accent',
                              child: GestureDetector(
                                onTap: () => db.setPref('accent', name),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: C.accent == color ? C.text : Colors.transparent, width: 2),
                                  ),
                                  child: C.accent == color ? Icon(Icons.check, size: 18, color: C.bg) : null,
                                ),
                              ),
                            ),
                          ),
                      ]),
                    ]),
                  ),
                  _Slider(
                    label: 'New day starts at',
                    value: prefNum('rollover', 4),
                    min: 0,
                    max: 8,
                    divisions: 8,
                    show: (v) => '${v.round().toString().padLeft(2, '0')}:00',
                    onChanged: (v) => db.setPref('rollover', '${v.round()}'),
                  ),
                ]),
                const SizedBox(height: 24),
                Group(header: 'Sync & data', children: [
                  ValueListenableBuilder(
                    valueListenable: Sync.status,
                    builder: (context, s, _) => ListTile(
                      title: Text('Sync', style: T.body),
                      trailing: Text(Sync.connected ? Uri.tryParse(Sync.server ?? '')?.host ?? 'On' : 'Off', style: T.subhead),
                      onTap: () => showDialog(context: context, builder: (_) => const SyncDialog()),
                    ),
                  ),
                  ListTile(title: Text('Import Anki or Saguki file…', style: T.body), onTap: () => importFile(context)),
                  ListTile(title: Text('Export everything (.sgki)', style: T.body), onTap: () => exportFile(context)),
                ]),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Your profile and settings sync to your other devices.', style: T.caption),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Dictionary autofill uses JMdict (© Electronic Dictionary Research and Development Group) '
                    'and CC-CEDICT (© MDBG), both under CC BY-SA 4.0.',
                    style: T.caption,
                  ),
                ),
              ]);
            },
          ),
        ),
      );
}

/// Photo, else emoji or initial on a lavender disc.
class Avatar extends StatelessWidget {
  const Avatar({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    final a = pref('avatar').isNotEmpty ? pref('avatar') : pref('name', '?').characters.first.toUpperCase();
    final fallback = Text(a, style: ts(size * 0.45, w: 600, color: C.accent));
    final url = pref('avatarUrl');
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: C.accentContainer, shape: BoxShape.circle),
      child: url.isEmpty
          ? fallback
          : Image.network(url, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
    );
  }
}

/// Center-crops to a [size] px square PNG. Re-encoding also strips EXIF (e.g. photo location).
Future<List<int>> squarePng(List<int> bytes, {int size = 256}) async {
  final img = (await (await ui.instantiateImageCodec(Uint8List.fromList(bytes))).getNextFrame()).image;
  final side = min(img.width, img.height).toDouble();
  final rec = ui.PictureRecorder();
  Canvas(rec).drawImageRect(
    img,
    Rect.fromLTWH((img.width - side) / 2, (img.height - side) / 2, side, side),
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final out = await rec.endRecording().toImage(size, size);
  return (await out.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
}

class _Slider extends StatelessWidget {
  const _Slider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.show,
    required this.onChanged,
  });
  final String label;
  final double value, min, max;
  final int divisions;
  final String Function(double) show;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: T.body)), Text(show(value), style: T.subhead)]),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: C.accent,
            inactiveColor: C.surface3,
            onChanged: onChanged,
          ),
        ]),
      );
}

class _EditProfile extends StatefulWidget {
  const _EditProfile();

  @override
  State<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<_EditProfile> {
  final _name = TextEditingController(text: pref('name')),
      _avatar = TextEditingController(text: pref('avatar')),
      _bio = TextEditingController(text: pref('bio'));
  bool _uploading = false;
  String? _error;

  Future<void> _photo() async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    final path = files.isEmpty ? null : files.first.path;
    if (path == null) return;
    setState(() {
      _uploading = true;
      _error = null;
    });
    try {
      await db.setPref('avatarUrl', await Sync.uploadAvatar(await squarePng(await File(path).readAsBytes())));
    } on HttpException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Couldn’t upload that picture';
    }
    if (mounted) setState(() => _uploading = false);
  }

  Future<void> _save() async {
    for (final (k, c) in [('name', _name), ('avatar', _avatar), ('bio', _bio)]) {
      if (c.text.trim() != pref(k)) await db.setPref(k, c.text.trim());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Edit profile', style: T.headline),
        content: SizedBox(
          width: 380,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ValueListenableBuilder(
              valueListenable: prefs,
              builder: (context, _, _) => Row(children: [
                const Avatar(size: 64),
                const SizedBox(width: 12),
                TextButton(onPressed: _uploading ? null : _photo, child: Text(_uploading ? 'Uploading…' : 'Choose photo')),
                if (pref('avatarUrl').isNotEmpty && !_uploading)
                  TextButton(
                    onPressed: () => db.setPref('avatarUrl', ''),
                    child: Text('Remove', style: ts(17, color: C.again)),
                  ),
              ]),
            ),
            if (_error != null)
              Align(alignment: Alignment.centerLeft, child: Text(_error!, style: ts(13, color: C.again))),
            const SizedBox(height: 16),
            TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(
              controller: _avatar,
              maxLength: 2,
              decoration: const InputDecoration(labelText: 'Emoji (if no photo)', hintText: '🐱', counterText: ''),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bio,
              maxLength: 80,
              decoration: const InputDecoration(labelText: 'Bio', hintText: 'Learning 日本語 and 繁體中文', counterText: ''),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      );
}
