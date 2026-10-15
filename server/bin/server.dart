// Saguki sync server: device login + last-write-wins row sync over Postgres.
//
// Rows are stored opaquely as JSONB keyed by (table, id), so app schema changes
// need no server migration. Clients do all scheduling and stats themselves.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const tables = {'decks', 'notes', 'cards', 'review_logs'};

late final Pool db;
late final String password;

Future<void> main() async {
  password = Platform.environment['SAGUKI_PASSWORD'] ?? '';
  if (password.length < 12) {
    stderr.writeln('SAGUKI_PASSWORD must be set (12+ chars)');
    exit(1);
  }
  db = Pool.withUrl(Platform.environment['DATABASE_URL']!);
  await migrate();

  final app = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..post('/login', login)
    ..post('/sync', sync);
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(app.call);
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  await io.serve(handler, InternetAddress.anyIPv4, port);
  print('saguki server on :$port');
}

Future<void> migrate() async {
  await db.execute('CREATE SEQUENCE IF NOT EXISTS sync_seq');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS sync_rows (
      tbl text NOT NULL,
      id text NOT NULL,
      modified_at bigint NOT NULL,
      deleted boolean NOT NULL DEFAULT false,
      data jsonb NOT NULL,
      version bigint NOT NULL DEFAULT nextval('sync_seq'),
      PRIMARY KEY (tbl, id)
    )''');
  await db.execute('CREATE INDEX IF NOT EXISTS sync_rows_version ON sync_rows (version)');
  await db.execute('''
    CREATE TABLE IF NOT EXISTS devices (
      id serial PRIMARY KEY,
      name text NOT NULL,
      token_hash text NOT NULL UNIQUE,
      created_at timestamptz NOT NULL DEFAULT now(),
      last_seen timestamptz NOT NULL DEFAULT now()
    )''');
}

Response json(Object body, [int status = 200]) =>
    Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json'});

String sha(String s) => sha256.convert(utf8.encode(s)).toString();

bool constantTimeEquals(String a, String b) {
  final x = utf8.encode(a), y = utf8.encode(b);
  var diff = x.length ^ y.length;
  for (var i = 0; i < min(x.length, y.length); i++) {
    diff |= x[i] ^ y[i];
  }
  return diff == 0;
}

Future<Map<String, dynamic>?> body(Request req) async {
  try {
    final v = jsonDecode(await req.readAsString());
    return v is Map<String, dynamic> ? v : null;
  } on FormatException {
    return null;
  }
}

/// POST /login {password, device} → {token}
Future<Response> login(Request req) async {
  final b = await body(req);
  if (b == null || b['password'] is! String || b['device'] is! String) return json({'error': 'bad request'}, 400);
  if (!constantTimeEquals(b['password'], password)) {
    // ponytail: fixed delay instead of per-IP lockout; fine for one user with a long password.
    await Future.delayed(const Duration(seconds: 1));
    return json({'error': 'wrong password'}, 401);
  }
  final rnd = Random.secure();
  final token = base64Url.encode(List.generate(32, (_) => rnd.nextInt(256)));
  final name = (b['device'] as String).trim();
  await db.execute(Sql.named('INSERT INTO devices (name, token_hash) VALUES (@n, @h)'),
      parameters: {'n': name.substring(0, min(name.length, 80)), 'h': sha(token)});
  return json({'token': token});
}

Future<bool> authed(Request req) async {
  final h = req.headers['authorization'] ?? '';
  if (!h.startsWith('Bearer ')) return false;
  final r = await db.execute(
      Sql.named('UPDATE devices SET last_seen = now() WHERE token_hash = @h RETURNING id'),
      parameters: {'h': sha(h.substring(7))});
  return r.isNotEmpty;
}

/// POST /sync {cursor, changes: [{t, id, m, d, data}]} → {cursor, changes}
/// Push is applied first (newer modified_at wins), then everything after the
/// client's cursor is returned, including its own just-pushed rows.
Future<Response> sync(Request req) async {
  if (!await authed(req)) return json({'error': 'unauthorized'}, 401);
  final b = await body(req);
  final cursor = b?['cursor'], changes = b?['changes'];
  if (cursor is! int || changes is! List) return json({'error': 'bad request'}, 400);
  for (final c in changes) {
    if (c is! Map ||
        !tables.contains(c['t']) ||
        c['id'] is! String ||
        c['m'] is! int ||
        c['d'] is! bool ||
        c['data'] is! Map) {
      return json({'error': 'bad change'}, 400);
    }
  }

  await db.runTx((tx) async {
    // Serialize writers so versions become visible in order and pulls never skip a row.
    await tx.execute('SELECT pg_advisory_xact_lock(42)');
    for (final c in changes) {
      await tx.execute(
        Sql.named('''
          INSERT INTO sync_rows (tbl, id, modified_at, deleted, data) VALUES (@t, @id, @m, @d, @data:jsonb)
          ON CONFLICT (tbl, id) DO UPDATE
            SET modified_at = EXCLUDED.modified_at, deleted = EXCLUDED.deleted, data = EXCLUDED.data,
                version = nextval('sync_seq')
            WHERE sync_rows.modified_at < EXCLUDED.modified_at'''),
        parameters: {'t': c['t'], 'id': c['id'], 'm': c['m'], 'd': c['d'], 'data': c['data']},
      );
    }
  });

  // ponytail: no paging; a personal collection is a few MB of JSON. Page if it grows past ~50k rows.
  final rows = await db.execute(
    Sql.named('SELECT tbl, id, modified_at, deleted, data, version FROM sync_rows WHERE version > @c ORDER BY version'),
    parameters: {'c': cursor},
  );
  var next = cursor;
  final out = [
    for (final r in rows)
      () {
        final m = r.toColumnMap();
        next = max(next, m['version'] as int);
        return {'t': m['tbl'], 'id': m['id'], 'm': m['modified_at'], 'd': m['deleted'], 'data': m['data']};
      }(),
  ];
  return json({'cursor': next, 'changes': out});
}
