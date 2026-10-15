// Dictionary autofill (PLAN.md §3): JMdict (ja) and CC-CEDICT (zh) loaded into Postgres.
// Both are CC BY-SA 4.0; the app credits them in Profile.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

const jmdictUrl = 'https://www.edrdg.org/pub/Nihongo/JMdict_e.gz';
const cedictUrl = 'https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.txt.gz';

Future<void> migrateDict(Pool db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS dict (
      id bigserial PRIMARY KEY,
      lang text NOT NULL,
      term text NOT NULL,
      reading text NOT NULL,
      senses text NOT NULL, -- newline separated
      rank int NOT NULL
    )''');
  await db.execute('CREATE INDEX IF NOT EXISTS dict_term ON dict (lang, term)');
  await db.execute('CREATE INDEX IF NOT EXISTS dict_reading ON dict (lang, reading)');
}

/// Best matches for [q]: exact term first, then reading; common words first.
Future<List<Map<String, Object>>> searchDict(Pool db, String lang, String q) async {
  final rows = await db.execute(
    Sql.named('SELECT term, reading, senses FROM dict WHERE lang = @l AND (term = @q OR reading = @q) '
        'ORDER BY (term = @q) DESC, rank, id LIMIT 6'),
    parameters: {'l': lang, 'q': q},
  );
  return [
    for (final r in rows) {'term': r[0] as String, 'reading': r[1] as String, 'senses': (r[2] as String).split('\n')},
  ];
}

/// Loads any dictionary that isn't in the database yet. Runs in the background after startup;
/// a failed download just retries on the next restart.
Future<void> loadDicts(Pool db) async {
  Future<bool> has(String lang) async =>
      (await db.execute(Sql.named('SELECT 1 FROM dict WHERE lang = @l LIMIT 1'), parameters: {'l': lang})).isNotEmpty;
  try {
    if (!await has('ja')) await _load(db, jmdictUrl, _jmdict);
    if (!await has('zh-Hant')) await _load(db, cedictUrl, _cedict);
  } catch (e) {
    stderr.writeln('dictionary load failed: $e');
  }
}

typedef _Row = (String lang, String term, String reading, String senses, int rank);

Future<void> _load(Pool db, String url, Stream<_Row> Function(Stream<String> lines) parse) async {
  final watch = Stopwatch()..start();
  final client = HttpClient();
  try {
    final res = await (await client.getUrl(Uri.parse(url))).close();
    if (res.statusCode != 200) throw HttpException('$url: ${res.statusCode}');
    final lines = res.transform(gzip.decoder).transform(utf8.decoder).transform(const LineSplitter());
    var n = 0;
    await db.runTx((tx) async {
      final batch = <_Row>[];
      Future<void> flush() async {
        if (batch.isEmpty) return;
        await tx.execute(
          Sql.named('INSERT INTO dict (lang, term, reading, senses, rank) '
              'SELECT * FROM unnest(@l, @t, @r, @s, @k)'),
          parameters: {
            'l': TypedValue(Type.textArray, [for (final r in batch) r.$1]),
            't': TypedValue(Type.textArray, [for (final r in batch) r.$2]),
            'r': TypedValue(Type.textArray, [for (final r in batch) r.$3]),
            's': TypedValue(Type.textArray, [for (final r in batch) r.$4]),
            'k': TypedValue(Type.integerArray, [for (final r in batch) r.$5]),
          },
        );
        n += batch.length;
        batch.clear();
      }

      await for (final row in parse(lines)) {
        batch.add(row);
        if (batch.length == 5000) await flush();
      }
      await flush();
    });
    print('loaded $n dictionary rows from $url in ${watch.elapsed.inSeconds}s');
  } finally {
    client.close();
  }
}

String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'")
    .replaceAll('&amp;', '&');

final _keb = RegExp(r'<keb>([^<]*)</keb>'), _reb = RegExp(r'<reb>([^<]*)</reb>');
final _gloss = RegExp(r'<gloss[^>]*>([^<]*)</gloss>');

/// JMdict XML, one `<entry>` at a time: a row per kanji spelling (or the kana if there is none).
Stream<_Row> _jmdict(Stream<String> lines) async* {
  final buf = StringBuffer();
  var inEntry = false;
  await for (final line in lines) {
    if (line == '<entry>') {
      inEntry = true;
      buf.clear();
    } else if (line == '</entry>' && inEntry) {
      inEntry = false;
      final e = buf.toString();
      final kebs = _keb.allMatches(e).map((m) => _unescape(m[1]!)).toList();
      final rebs = _reb.allMatches(e).map((m) => _unescape(m[1]!)).toList();
      if (rebs.isEmpty) continue;
      final senses = e
          .split('<sense>')
          .skip(1)
          .map((s) => _gloss.allMatches(s).take(4).map((m) => _unescape(m[1]!)).join(', '))
          .where((s) => s.isNotEmpty)
          .take(4)
          .join('\n');
      if (senses.isEmpty) continue;
      final rank = e.contains('_pri>') ? 0 : 1;
      for (final term in kebs.isEmpty ? [rebs.first] : kebs) {
        yield ('ja', term, rebs.first, senses, rank);
      }
    } else if (inEntry) {
      buf.writeln(line);
    }
  }
}

final _cedictLine = RegExp(r'^(\S+) (\S+) \[([^\]]*)\] /(.*)/$');

/// CC-CEDICT: `學生 学生 [xue2 sheng5] /student/schoolchild/` → a zh-Hant and a zh-Hans row.
Stream<_Row> _cedict(Stream<String> lines) async* {
  await for (final line in lines) {
    final m = _cedictLine.firstMatch(line);
    if (m == null) continue;
    final senses = m[4]!.split('/');
    // Surnames, variants and cross-references sink below the everyday reading; more senses ≈ more common.
    final minor = RegExp(r'^(surname |variant of|old variant|see |used in |abbr\. for )').hasMatch(senses.first) ||
        m[3]!.startsWith(RegExp('[A-Z]'));
    final rank = (minor ? 100 : 0) + 99 - senses.length.clamp(0, 99);
    final s = senses.take(4).join('\n');
    yield ('zh-Hant', m[1]!, m[3]!, s, rank);
    yield ('zh-Hans', m[2]!, m[3]!, s, rank);
  }
}
