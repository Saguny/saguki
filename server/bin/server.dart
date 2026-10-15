// Saguki sync server: device login + last-write-wins row sync over Postgres.
//
// Rows are stored opaquely as JSONB keyed by (table, id), so app schema changes
// need no server migration. Clients do all scheduling and stats themselves.
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

const tables = {'prefs', 'decks', 'notes', 'cards', 'review_logs'};

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
    ..get('/download', download)
    ..post('/login', login)
    ..post('/sync', sync)
    ..post('/avatar', avatar);
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

/// GET /download: latest Android build, uploaded by CI to the mounted /apk folder.
Future<Response> download(Request _) async {
  final f = File(Platform.environment['APK_PATH'] ?? '/apk/saguki.apk');
  if (!await f.exists()) return Response.notFound('No APK uploaded yet');
  return Response.ok(f.openRead(), headers: {
    'content-type': 'application/vnd.android.package-archive',
    'content-length': '${await f.length()}',
    'content-disposition': 'attachment; filename="saguki.apk"',
    'cache-control': 'no-store',
  });
}

/// POST /avatar (raw PNG/JPEG, ≤1 MB) → {url}. Stored in R2, served by the CDN.
/// Content-addressed key, so the CDN can cache it forever.
Future<Response> avatar(Request req) async {
  if (!await authed(req)) return json({'error': 'unauthorized'}, 401);
  final bucket = env('R2_BUCKET');
  final endpoint = env('R2_ENDPOINT') ?? (env('R2_ACCOUNT_ID') == null ? null : 'https://${env('R2_ACCOUNT_ID')}.r2.cloudflarestorage.com');
  final creds = await r2Creds();
  if (creds == null || [bucket, endpoint].any((v) => v == null || v.isEmpty)) {
    return json({'error': 'uploads are not configured on the server'}, 503);
  }
  const limit = 1 << 20;
  if ((req.contentLength ?? 0) > limit) return json({'error': 'image too large'}, 413);
  final bytes = BytesBuilder(copy: false);
  await for (final chunk in req.read()) {
    bytes.add(chunk);
    if (bytes.length > limit) return json({'error': 'image too large'}, 413);
  }
  final b = bytes.takeBytes();
  final type = b.length > 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47
      ? 'png'
      : b.length > 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF
          ? 'jpeg'
          : null;
  if (type == null) return json({'error': 'send a PNG or JPEG'}, 400);

  final prefix = env('R2_PREFIX') ?? 'pfps/';
  final key = '$prefix${sha256.convert(b)}.${type == 'png' ? 'png' : 'jpg'}';
  try {
    await s3Put(Uri.parse('$endpoint/$bucket/$key'), b, 'image/$type', creds.id, creds.secret);
  } catch (e) {
    stderr.writeln('avatar upload failed: $e');
    return json({'error': 'upload failed'}, 502);
  }
  final cdn = (env('R2_PUBLIC_URL') ?? 'https://cdn.off-by-one.digital').replaceAll(RegExp(r'/+$'), '');
  return json({'url': '$cdn/$key'});
}

({String id, String secret})? _creds;

/// S3 keys from R2_ACCESS_KEY_ID + R2_SECRET_ACCESS_KEY, or derived from a Cloudflare API token
/// (R2_TOKEN): key id = the token's id, secret = sha256(token). Null if neither is set.
Future<({String id, String secret})?> r2Creds() async {
  if (_creds != null) return _creds;
  final id = env('R2_ACCESS_KEY_ID') ?? '', secret = env('R2_SECRET_ACCESS_KEY') ?? '', token = env('R2_TOKEN') ?? '';
  if (id.isNotEmpty && secret.isNotEmpty) return _creds = (id: id, secret: secret);
  if (token.isEmpty) return null;
  final client = HttpClient();
  try {
    // User tokens (cfut_…) verify here; account tokens under the account.
    for (final path in ['user/tokens/verify', 'accounts/${env('R2_ACCOUNT_ID')}/tokens/verify']) {
      final r = await client.getUrl(Uri.parse('https://api.cloudflare.com/client/v4/$path'));
      r.headers.set('authorization', 'Bearer $token');
      final res = await r.close();
      final body = jsonDecode(await res.transform(utf8.decoder).join());
      if (res.statusCode == 200 && body['result']?['id'] is String) {
        return _creds = (id: body['result']['id'] as String, secret: sha(token));
      }
    }
    stderr.writeln('R2_TOKEN could not be verified with Cloudflare');
    return null;
  } catch (e) {
    stderr.writeln('R2_TOKEN check failed: $e');
    return null;
  } finally {
    client.close();
  }
}

/// S3 PutObject with AWS SigV4 (R2 uses region "auto"). Path must already be URL-safe.
Future<void> s3Put(Uri url, List<int> body, String type, String keyId, String secret) async {
  final now = DateTime.now().toUtc();
  final date = now.toIso8601String().replaceAll(RegExp(r'[-:]|\.\d+'), ''); // 20261015T075318Z
  final day = date.substring(0, 8);
  final payload = sha256.convert(body).toString();
  final host = url.hasPort ? '${url.host}:${url.port}' : url.host;
  final headers = {'content-type': type, 'host': host, 'x-amz-content-sha256': payload, 'x-amz-date': date};
  final signed = headers.keys.join(';');
  final canonical = ['PUT', url.path, '', for (final e in headers.entries) '${e.key}:${e.value}', '', signed, payload].join('\n');
  final scope = '$day/auto/s3/aws4_request';
  final toSign = ['AWS4-HMAC-SHA256', date, scope, sha256.convert(utf8.encode(canonical))].join('\n');
  List<int> k = utf8.encode('AWS4$secret');
  for (final part in [day, 'auto', 's3', 'aws4_request']) {
    k = Hmac(sha256, k).convert(utf8.encode(part)).bytes;
  }
  final sig = Hmac(sha256, k).convert(utf8.encode(toSign));

  final client = HttpClient();
  try {
    final r = await client.putUrl(url);
    headers.forEach((k, v) => k == 'host' ? null : r.headers.set(k, v));
    r.headers.set('authorization', 'AWS4-HMAC-SHA256 Credential=$keyId/$scope, SignedHeaders=$signed, Signature=$sig');
    r.contentLength = body.length;
    r.add(body);
    final res = await r.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) throw HttpException('R2 ${res.statusCode}: $text');
  } finally {
    client.close();
  }
}

/// Env var with empty treated as unset (compose passes `${X:-}` through as "").
String? env(String key) => switch (Platform.environment[key]) { null || '' => null, final v => v };

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
