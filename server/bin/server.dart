// Saguki sync server: accounts, device login + last-write-wins row sync over Postgres.
//
// Rows are stored opaquely as JSONB keyed by (user, table, id), so app schema changes
// need no server migration. Clients do all scheduling and stats themselves.
//
// Accounts: user 1 is the owner, whose password is SAGUKI_PASSWORD. Everyone else is added
// with `server adduser <name>` (see deploy/README.md) and has a PBKDF2-hashed password.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

import 'dict.dart';

const tables = {'prefs', 'decks', 'notes', 'cards', 'review_logs'};

late final Pool db;
late final String password;

Future<void> main(List<String> args) async {
  password = Platform.environment['SAGUKI_PASSWORD'] ?? '';
  if (password.length < 12) {
    stderr.writeln('SAGUKI_PASSWORD must be set (12+ chars)');
    exit(1);
  }
  db = Pool.withUrl(Platform.environment['DATABASE_URL']!);
  await migrate();
  if (args.isNotEmpty) exit(await admin(args));
  await migrateDict(db);
  unawaited(loadDicts(db));

  final app = Router()
    ..get('/health', (Request _) => Response.ok('ok'))
    ..get('/download', (Request _) => download('saguki.apk', 'application/vnd.android.package-archive'))
    ..get('/download/windows', (Request _) => download('saguki-setup.exe', 'application/vnd.microsoft.portable-executable'))
    ..get('/version', (Request _) async => json({'android': await buildOf('saguki.apk'), 'windows': await buildOf('saguki-setup.exe')}))
    ..post('/login', login)
    ..post('/sync', sync)
    ..post('/avatar', avatar)
    ..get('/dict', dict);
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

  // Accounts (added after v1: existing rows and devices belong to the owner, user 1).
  await db.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id serial PRIMARY KEY,
      name text NOT NULL UNIQUE,
      pw_hash text NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    )''');
  await db.execute(
      Sql.named("INSERT INTO users (id, name, pw_hash) VALUES (1, @n, 'env') "
          'ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name'),
      parameters: {'n': ownerName});
  await db.execute("SELECT setval('users_id_seq', GREATEST((SELECT MAX(id) FROM users), 1))");
  await db.execute('ALTER TABLE devices ADD COLUMN IF NOT EXISTS user_id int REFERENCES users (id) ON DELETE CASCADE');
  await db.execute('UPDATE devices SET user_id = 1 WHERE user_id IS NULL');
  await db.execute('ALTER TABLE sync_rows ADD COLUMN IF NOT EXISTS user_id int');
  await db.execute('UPDATE sync_rows SET user_id = 1 WHERE user_id IS NULL');
  await db.execute('ALTER TABLE sync_rows ALTER COLUMN user_id SET NOT NULL');
  await db.execute(r'''
    DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM information_schema.key_column_usage
                     WHERE table_name = 'sync_rows' AND constraint_name = 'sync_rows_pkey' AND column_name = 'user_id') THEN
        ALTER TABLE sync_rows DROP CONSTRAINT sync_rows_pkey;
        ALTER TABLE sync_rows ADD PRIMARY KEY (user_id, tbl, id);
      END IF;
    END $$''');
  await db.execute('CREATE INDEX IF NOT EXISTS sync_rows_user_version ON sync_rows (user_id, version)');
}

String get ownerName => (env('SAGUKI_OWNER') ?? 'owner').toLowerCase();
final _validName = RegExp(r'^[a-z0-9_.-]{2,32}$');

/// PBKDF2-HMAC-SHA256, stored as `pbkdf2$rounds$salt$hash` (base64url).
String hashPassword(String pw, {List<int>? salt, int rounds = 100000}) {
  salt ??= List.generate(16, (_) => Random.secure().nextInt(256));
  final mac = Hmac(sha256, utf8.encode(pw));
  var u = mac.convert([...salt, 0, 0, 0, 1]).bytes;
  final out = List<int>.of(u);
  for (var i = 1; i < rounds; i++) {
    u = mac.convert(u).bytes;
    for (var j = 0; j < out.length; j++) {
      out[j] ^= u[j];
    }
  }
  return ['pbkdf2', rounds, base64Url.encode(salt), base64Url.encode(out)].join(r'$');
}

bool checkPassword(String pw, String stored) {
  final p = stored.split(r'$');
  if (p.length != 4 || p[0] != 'pbkdf2') return false;
  return constantTimeEquals(hashPassword(pw, salt: base64Url.decode(p[2]), rounds: int.parse(p[1])), stored);
}

String randomPassword() => base64Url.encode(List.generate(12, (_) => Random.secure().nextInt(256)));

/// `server adduser|passwd|deluser <name>` and `server users`, run inside the api container.
Future<int> admin(List<String> args) async {
  final cmd = args.first, name = args.length > 1 ? args[1].toLowerCase() : '';
  if (cmd == 'users') {
    final rows = await db.execute('SELECT u.name, u.id = 1, (SELECT COUNT(*) FROM devices d WHERE d.user_id = u.id), '
        "(SELECT COUNT(*) FROM sync_rows r WHERE r.user_id = u.id AND r.tbl = 'notes' AND NOT r.deleted) "
        'FROM users u ORDER BY u.id');
    for (final r in rows) {
      print('${r[0]}${r[1] == true ? ' (owner)' : ''}: ${r[2]} devices, ${r[3]} cards');
    }
    return 0;
  }
  if (!const {'adduser', 'passwd', 'deluser'}.contains(cmd) || !_validName.hasMatch(name)) {
    stderr.writeln('usage: server adduser|passwd|deluser <name>   (2-32 of a-z 0-9 _ . -)\n       server users');
    return 2;
  }
  if (name == ownerName) {
    stderr.writeln('$name is the owner: change SAGUKI_PASSWORD in .env instead');
    return 1;
  }
  final pw = randomPassword();
  final changed = switch (cmd) {
    'adduser' => await db.execute(
        Sql.named('INSERT INTO users (name, pw_hash) VALUES (@n, @h) ON CONFLICT (name) DO NOTHING'),
        parameters: {'n': name, 'h': hashPassword(pw)}),
    'passwd' => await db.execute(Sql.named('UPDATE users SET pw_hash = @h WHERE name = @n AND id <> 1'),
        parameters: {'n': name, 'h': hashPassword(pw)}),
    _ => await db.execute(Sql.named('DELETE FROM users WHERE name = @n AND id <> 1'), parameters: {'n': name}),
  };
  if (changed.affectedRows == 0) {
    stderr.writeln(cmd == 'adduser' ? '$name already exists' : 'no user $name');
    return 1;
  }
  if (cmd == 'passwd') {
    // A new password signs out their devices.
    await db.execute(Sql.named('DELETE FROM devices WHERE user_id = (SELECT id FROM users WHERE name = @n)'),
        parameters: {'n': name});
  }
  if (cmd == 'deluser') {
    await db.execute('DELETE FROM sync_rows r WHERE NOT EXISTS (SELECT 1 FROM users u WHERE u.id = r.user_id)');
    print('deleted $name and all their data');
  } else {
    print('$name  password: $pw');
  }
  return 0;
}

/// GET /download (Android) and /download/windows (installer): latest builds, uploaded by CI
/// to the mounted /apk folder.
Future<Response> download(String name, String type) async {
  final f = File('${env('APK_DIR') ?? '/apk'}/$name');
  if (!await f.exists()) return Response.notFound('No build uploaded yet');
  return Response.ok(f.openRead(), headers: {
    'content-type': type,
    'content-length': '${await f.length()}',
    'content-disposition': 'attachment; filename="$name"',
    'cache-control': 'no-store',
  });
}

/// CI writes `<name>.build` (the build number) next to each upload; the in-app updater compares it.
Future<int?> buildOf(String name) async {
  final f = File('${env('APK_DIR') ?? '/apk'}/$name.build');
  return await f.exists() ? int.tryParse((await f.readAsString()).trim()) : null;
}

/// GET /dict?lang=ja&q=勉強 → {entries: [{term, reading, senses}]}
Future<Response> dict(Request req) async {
  if (await authed(req) == null) return json({'error': 'unauthorized'}, 401);
  final q = req.url.queryParameters['q']?.trim() ?? '', lang = req.url.queryParameters['lang'] ?? '';
  if (q.isEmpty || q.length > 40 || !const {'ja', 'zh-Hant', 'zh-Hans'}.contains(lang)) {
    return json({'error': 'bad request'}, 400);
  }
  return json({'entries': await searchDict(db, lang, q)});
}

/// POST /avatar (raw PNG/JPEG, ≤1 MB) → {url}. Stored in R2, served by the CDN.
/// Content-addressed key, so the CDN can cache it forever.
Future<Response> avatar(Request req) async {
  if (await authed(req) == null) return json({'error': 'unauthorized'}, 401);
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

/// POST /login {user?, password, device} → {token, user}. No user (older apps) = the owner.
Future<Response> login(Request req) async {
  final b = await body(req);
  if (b == null || b['password'] is! String || b['device'] is! String || (b['user'] != null && b['user'] is! String)) {
    return json({'error': 'bad request'}, 400);
  }
  final pw = b['password'] as String, name = ((b['user'] as String?) ?? '').trim().toLowerCase();
  int? userId;
  if (name.isEmpty || name == ownerName) {
    if (constantTimeEquals(pw, password)) userId = 1;
  } else {
    final u = (await db.execute(Sql.named('SELECT id, pw_hash FROM users WHERE name = @n AND id <> 1'),
            parameters: {'n': name}))
        .firstOrNull;
    if (u != null && checkPassword(pw, u[1] as String)) userId = u[0] as int;
  }
  if (userId == null) {
    // ponytail: fixed delay instead of per-IP lockout; fine for a few users with random passwords.
    await Future.delayed(const Duration(seconds: 1));
    return json({'error': 'wrong username or password'}, 401);
  }
  final rnd = Random.secure();
  final token = base64Url.encode(List.generate(32, (_) => rnd.nextInt(256)));
  final device = (b['device'] as String).trim();
  await db.execute(Sql.named('INSERT INTO devices (name, token_hash, user_id) VALUES (@n, @h, @u)'),
      parameters: {'n': device.substring(0, min(device.length, 80)), 'h': sha(token), 'u': userId});
  return json({'token': token, 'user': userId == 1 ? ownerName : name});
}

/// The signed-in user's id, or null.
Future<int?> authed(Request req) async {
  final h = req.headers['authorization'] ?? '';
  if (!h.startsWith('Bearer ')) return null;
  final r = await db.execute(
      Sql.named('UPDATE devices SET last_seen = now() WHERE token_hash = @h RETURNING user_id'),
      parameters: {'h': sha(h.substring(7))});
  return r.isEmpty ? null : r.first[0] as int;
}

/// POST /sync {cursor, changes: [{t, id, m, d, data}]} → {cursor, changes}
/// Push is applied first (newer modified_at wins), then everything after the
/// client's cursor is returned, including its own just-pushed rows.
Future<Response> sync(Request req) async {
  final user = await authed(req);
  if (user == null) return json({'error': 'unauthorized'}, 401);
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
          INSERT INTO sync_rows (user_id, tbl, id, modified_at, deleted, data)
          VALUES (@u, @t, @id, @m, @d, @data:jsonb)
          ON CONFLICT (user_id, tbl, id) DO UPDATE
            SET modified_at = EXCLUDED.modified_at, deleted = EXCLUDED.deleted, data = EXCLUDED.data,
                version = nextval('sync_seq')
            WHERE sync_rows.modified_at < EXCLUDED.modified_at'''),
        parameters: {'u': user, 't': c['t'], 'id': c['id'], 'm': c['m'], 'd': c['d'], 'data': c['data']},
      );
    }
  });

  // ponytail: no paging; a personal collection is a few MB of JSON. Page if it grows past ~50k rows.
  final rows = await db.execute(
    Sql.named('SELECT tbl, id, modified_at, deleted, data, version FROM sync_rows WHERE user_id = @u AND version > @c ORDER BY version'),
    parameters: {'u': user, 'c': cursor},
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
