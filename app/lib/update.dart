import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'sync.dart';
import 'theme.dart';

/// Build number CI stamps in (--dart-define=BUILD=N); 0 for local builds.
const appBuild = int.fromEnvironment('BUILD');

bool get canUpdate => Platform.isAndroid || Platform.isWindows;

/// In-app updates from the sync server: /version lists the newest CI build per platform,
/// /download (APK) and /download/windows (installer) serve it.
class Updater {
  /// The server's newest build when it beats this one, else null. Throws when it can't tell.
  static Future<int?> newer() async {
    if (Sync.server == null) await Sync.load(); // launch check can beat Sync.start()
    final url = Sync.server;
    if (url == null) throw const HttpException('Connect sync first: updates come from your server.');
    final r = await http.get(Uri.parse('$url/version')).timeout(const Duration(seconds: 10));
    if (r.statusCode != 200) throw HttpException('Server answered ${r.statusCode}');
    final latest = jsonDecode(r.body)[Platform.isAndroid ? 'android' : 'windows'];
    return latest is int && latest > appBuild ? latest : null;
  }

  /// On launch: quiet unless there's an update. Skipped for local builds.
  static Future<void> checkOnLaunch(BuildContext context) async {
    if (!canUpdate || appBuild == 0) return;
    try {
      final n = await newer();
      if (n != null && context.mounted) await prompt(context, n);
    } catch (_) {}
  }

  /// Profile button: always answers.
  static Future<void> checkNow(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final n = await newer();
      if (n != null && context.mounted) return await prompt(context, n);
      messenger.showSnackBar(const SnackBar(content: Text('You’re on the latest version')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e is HttpException ? e.message : 'Couldn’t reach the server')));
    }
  }

  static Future<void> prompt(BuildContext context, int build) =>
      showDialog(context: context, barrierDismissible: false, builder: (_) => _UpdateDialog(build));

  /// Downloads the new build, then hands it to the system installer (Android) or runs the
  /// installer silently and quits; setup reopens the app (Windows, see installer.iss).
  static Future<void> install(void Function(double) progress) async {
    final win = Platform.isWindows;
    final file = File('${(await getTemporaryDirectory()).path}/${win ? 'saguki-setup.exe' : 'saguki.apk'}');
    final client = http.Client();
    try {
      final res = await client.send(http.Request('GET', Uri.parse('${Sync.server}/download${win ? '/windows' : ''}')));
      if (res.statusCode != 200) throw HttpException('Download failed (${res.statusCode})');
      final total = res.contentLength ?? 0;
      var got = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in res.stream.timeout(const Duration(seconds: 30))) {
          sink.add(chunk);
          got += chunk.length;
          if (total > 0) progress(got / total);
        }
      } finally {
        await sink.close();
      }
      if (total > 0 && got != total) throw const HttpException('Download was cut off');
    } finally {
      client.close();
    }
    if (win) {
      await Process.start(file.path, ['/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/CLOSEAPPLICATIONS'],
          mode: ProcessStartMode.detached);
      exit(0);
    }
    await const MethodChannel('saguki/update').invokeMethod('install', file.path);
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog(this.build);
  final int build;

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  double? _progress; // null = not started
  String? _error;

  Future<void> _go() async {
    setState(() {
      _progress = 0;
      _error = null;
    });
    try {
      await Updater.install((p) {
        if (mounted) setState(() => _progress = p);
      });
      if (mounted) Navigator.pop(context); // Android: the system installer takes over
    } catch (e) {
      if (mounted) {
        setState(() {
          _progress = null;
          _error = e is HttpException ? e.message : 'Download failed: offline or server down';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = _progress != null;
    return AlertDialog(
      title: Text('Update available', style: T.headline),
      content: SizedBox(
        width: 380,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            appBuild == 0 ? 'Build ${widget.build} is ready.' : 'Build ${widget.build} is ready (you have $appBuild).',
            style: T.body,
          ),
          if (busy) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: _progress == 0 ? null : _progress,
                minHeight: 6,
                color: C.accent,
                backgroundColor: C.surface3,
              ),
            ),
            const SizedBox(height: 8),
            Text('Downloading… ${(_progress! * 100).round()}%', style: T.footnote),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: ts(15, color: C.again)),
          ],
        ]),
      ),
      actions: [
        if (!busy) TextButton(onPressed: () => Navigator.pop(context), child: const Text('Later')),
        TextButton(onPressed: busy ? null : _go, child: Text(_error == null ? 'Update' : 'Try again')),
      ],
    );
  }
}
