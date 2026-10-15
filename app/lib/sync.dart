import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'db.dart';

/// Push order matters for foreign keys on the receiving side.
const _tables = ['decks', 'notes', 'cards', 'review_logs'];

enum SyncState { off, idle, syncing, error }

class SyncStatus {
  const SyncStatus(this.state, {this.last, this.message});
  final SyncState state;
  final DateTime? last;
  final String? message;
}

/// Offline-first sync with the VPS (PLAN.md §1). Rows are sent raw (SQLite column
/// names and values); the server stores them opaquely and resolves by newest modified_at.
class Sync {
  static final status = ValueNotifier(const SyncStatus(SyncState.off));
  static Map<String, dynamic> _cfg = {};
  static bool _running = false, _again = false;
  static Timer? _debounce, _periodic;
  static AppLifecycleListener? _life;

  static String? get server => _cfg['url'];
  static bool get connected => _cfg['token'] != null;

  // ponytail: token in a plain file in app-private storage; move to flutter_secure_storage if devices are shared.
  static String? configDir; // tests point this at a temp dir
  static Future<File> get _file async =>
      File('${configDir ?? (await getApplicationSupportDirectory()).path}/sync.json');

  static Future<void> _save() async => (await _file).writeAsString(jsonEncode(_cfg));

  static Future<void> load() async {
    try {
      final f = await _file;
      _cfg = await f.exists() ? jsonDecode(await f.readAsString()) : {};
    } catch (_) {
      _cfg = {};
    }
  }

  /// Load config and start the triggers: start, resume, 5 s after local edits, every 60 s.
  static Future<void> start() async {
    await load();
    _life ??= AppLifecycleListener(
      onResume: () {
        run();
        _periodic ??= Timer.periodic(const Duration(seconds: 60), (_) => run());
      },
      onPause: () {
        _periodic?.cancel();
        _periodic = null;
      },
    );
    _periodic ??= Timer.periodic(const Duration(seconds: 60), (_) => run());
    db.tableUpdates().listen((_) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 5), () async {
        // Our own pull writes also fire table updates; only push when something is dirty.
        final q = _tables.map((t) => 'SELECT 1 FROM $t WHERE dirty = 1').join(' UNION ALL ');
        if ((await db.customSelect('$q LIMIT 1').get()).isNotEmpty) run();
      });
    });
    status.value = SyncStatus(connected ? SyncState.idle : SyncState.off);
    run();
  }

  /// Returns an error message, or null on success.
  static Future<String?> connect(String url, String password) async {
    url = url.trim().replaceAll(RegExp(r'/+$'), '');
    if (!url.startsWith('https://') && !url.startsWith('http://')) url = 'https://$url';
    try {
      final r = await http
          .post(Uri.parse('$url/login'),
              headers: {'content-type': 'application/json'},
              body: jsonEncode({'password': password, 'device': '${Platform.operatingSystem} · ${Platform.localHostname}'}))
          .timeout(const Duration(seconds: 15));
      if (r.statusCode == 401) return 'Wrong password';
      if (r.statusCode != 200) return 'Server answered ${r.statusCode}';
      _cfg = {'url': url, 'token': jsonDecode(r.body)['token'], 'cursor': 0};
    } catch (e) {
      return 'Couldn’t reach $url';
    }
    await _save();
    // Fresh server: everything local must be pushed.
    for (final t in _tables) {
      await db.customStatement('UPDATE $t SET dirty = 1');
    }
    await run();
    return status.value.state == SyncState.error ? status.value.message : null;
  }

  static Future<void> disconnect() async {
    _cfg = {};
    await _save();
    status.value = const SyncStatus(SyncState.off);
  }

  static Future<void> run() async {
    if (!connected) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    status.value = SyncStatus(SyncState.syncing, last: status.value.last);
    try {
      do {
        _again = false;
        await _once();
      } while (_again);
      status.value = SyncStatus(SyncState.idle, last: DateTime.now());
    } on _Unauthorized {
      _cfg.remove('token');
      await _save();
      status.value = const SyncStatus(SyncState.off, message: 'This device was signed out. Connect again.');
    } catch (e) {
      status.value = SyncStatus(SyncState.error, last: status.value.last, message: 'Sync failed: offline or server down');
    } finally {
      _running = false;
    }
  }

  static Future<void> _once() async {
    final pushed = <({String t, String id, int m})>[];
    final changes = [];
    for (final t in _tables) {
      for (final row in await db.customSelect('SELECT * FROM $t WHERE dirty = 1').get()) {
        final data = Map<String, dynamic>.of(row.data)..remove('dirty');
        final m = data['modified_at'] as int;
        pushed.add((t: t, id: data['id'], m: m));
        changes.add({'t': t, 'id': data['id'], 'm': m, 'd': data['deleted'] == 1, 'data': data});
      }
    }

    final r = await http
        .post(Uri.parse('${_cfg['url']}/sync'),
            headers: {'content-type': 'application/json', 'authorization': 'Bearer ${_cfg['token']}'},
            body: jsonEncode({'cursor': _cfg['cursor'] ?? 0, 'changes': changes}))
        .timeout(const Duration(seconds: 60));
    if (r.statusCode == 401) throw _Unauthorized();
    if (r.statusCode != 200) throw HttpException('sync ${r.statusCode}');
    final res = jsonDecode(r.body) as Map<String, dynamic>;
    final incoming = (res['changes'] as List).cast<Map<String, dynamic>>()
      ..sort((a, b) => _tables.indexOf(a['t']).compareTo(_tables.indexOf(b['t'])));

    final cols = {for (final t in db.allTables) t.actualTableName: t.$columns.map((c) => c.name).toSet()};
    await db.transaction(() async {
      await db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final c in incoming) {
        final t = c['t'] as String, known = cols[t];
        if (known == null) continue;
        final local = await db.customSelect('SELECT modified_at, dirty FROM $t WHERE id = ?', variables: [Variable(c['id'])]).getSingleOrNull();
        // An unsynced local edit at least as new wins; it goes up on the next push.
        if (local != null && local.read<int>('dirty') == 1 && local.read<int>('modified_at') >= (c['m'] as int)) continue;
        final data = {
          for (final e in (c['data'] as Map<String, dynamic>).entries)
            if (known.contains(e.key) && e.key != 'dirty') e.key: e.value,
        }..['dirty'] = 0;
        final keys = data.keys.toList();
        try {
          await db.customStatement(
            'INSERT INTO $t (${keys.join(', ')}) VALUES (${List.filled(keys.length, '?').join(', ')}) '
            'ON CONFLICT(id) DO UPDATE SET ${keys.map((k) => '$k = excluded.$k').join(', ')}',
            [for (final k in keys) data[k]],
          );
        } catch (e) {
          debugPrint('sync: skipped malformed $t/${c['id']}: $e'); // one bad row must not block the rest
        }
      }
      // Clear dirty only if the row wasn't edited again while the request was in flight.
      for (final p in pushed) {
        await db.customStatement('UPDATE ${p.t} SET dirty = 0 WHERE id = ? AND modified_at = ?', [p.id, p.m]);
      }
    });
    db.markTablesUpdated(db.allTables);
    _cfg['cursor'] = res['cursor'];
    await _save();
  }
}

class _Unauthorized implements Exception {}
