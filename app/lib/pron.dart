/// Pronunciation helpers (PLAN.md §3): furigana alignment, zhuyin and tone-marked pinyin.
library;

typedef Seg = ({String base, String? ruby});

final _han = RegExp(r'[㐀-䶿一-鿿々〆ヶ]');
final _kana = RegExp(r'[ぁ-ゖァ-ヺー]');

String _hira(String s) => String.fromCharCodes(s.runes.map((c) => c >= 0x30A1 && c <= 0x30F6 ? c - 0x60 : c));

/// Splits [term] into base/ruby pieces so readings sit over the right characters.
/// Understands Anki's `食[た]べ 物[もの]` syntax; falls back to the whole word.
List<Seg> rubySegments(String term, String pron, String lang) {
  pron = pron.trim();
  if (pron.isEmpty) return [(base: term, ruby: null)];
  if (pron.contains('[')) return _anki(pron);
  if (lang == 'ja') return furigana(term, pron);
  if (lang.startsWith('zh')) {
    final chars = term.runes.map(String.fromCharCode).toList();
    final syl = pron.split(RegExp(r'\s+'));
    if (chars.length == syl.length && chars.every(_han.hasMatch)) {
      return [for (var i = 0; i < chars.length; i++) (base: chars[i], ruby: syl[i])];
    }
  }
  return [(base: term, ruby: pron)];
}

List<Seg> _anki(String s) {
  final out = <Seg>[];
  var at = 0;
  for (final m in RegExp(r'\s*([^\s\[\]]+)\[([^\]]*)\]').allMatches(s)) {
    final plain = s.substring(at, m.start).trim();
    if (plain.isNotEmpty) out.add((base: plain, ruby: null));
    out.add((base: m[1]!, ruby: m[2]));
    at = m.end;
  }
  final rest = s.substring(at).trim();
  if (rest.isNotEmpty) out.add((base: rest, ruby: null));
  return out;
}

/// 食べ物 + たべもの → 食(た) べ 物(もの): kana in the term anchor the split.
List<Seg> furigana(String term, String reading) {
  reading = reading.replaceAll(RegExp(r'[\s.・]'), '');
  final runs = RegExp(r'[ぁ-ゖァ-ヺー]+|[^ぁ-ゖァ-ヺー]+').allMatches(term).map((m) => m[0]!).toList();
  if (!runs.any((r) => !_kana.hasMatch(r[0]))) return [(base: term, ruby: null)]; // kana only
  final pattern = runs.map((r) => _kana.hasMatch(r[0]) ? RegExp.escape(_hira(r)) : '(.+?)').join();
  final m = RegExp('^$pattern\$').firstMatch(_hira(reading));
  if (m == null) return [(base: term, ruby: reading)];
  // kata→hira keeps lengths, so offsets map back onto the original reading.
  var g = 0, at = 0;
  final out = <Seg>[];
  for (final r in runs) {
    final kana = _kana.hasMatch(r[0]);
    final len = kana ? r.length : m[++g]!.length;
    out.add((base: r, ruby: kana ? null : reading.substring(at, at + len)));
    at += len;
  }
  return out;
}

// ---------------------------------------------------------------- Chinese

const _initials = {
  'zh': 'ㄓ', 'ch': 'ㄔ', 'sh': 'ㄕ', 'b': 'ㄅ', 'p': 'ㄆ', 'm': 'ㄇ', 'f': 'ㄈ', 'd': 'ㄉ', 't': 'ㄊ', 'n': 'ㄋ', //
  'l': 'ㄌ', 'g': 'ㄍ', 'k': 'ㄎ', 'h': 'ㄏ', 'j': 'ㄐ', 'q': 'ㄑ', 'x': 'ㄒ', 'r': 'ㄖ', 'z': 'ㄗ', 'c': 'ㄘ', 's': 'ㄙ',
};
const _finals = {
  'a': 'ㄚ', 'o': 'ㄛ', 'e': 'ㄜ', 'ê': 'ㄝ', 'ai': 'ㄞ', 'ei': 'ㄟ', 'ao': 'ㄠ', 'ou': 'ㄡ', 'an': 'ㄢ', 'en': 'ㄣ', //
  'ang': 'ㄤ', 'eng': 'ㄥ', 'ong': 'ㄨㄥ', 'er': 'ㄦ', 'i': 'ㄧ', 'ia': 'ㄧㄚ', 'io': 'ㄧㄛ', 'ie': 'ㄧㄝ', 'iao': 'ㄧㄠ',
  'iu': 'ㄧㄡ', 'ian': 'ㄧㄢ', 'in': 'ㄧㄣ', 'iang': 'ㄧㄤ', 'ing': 'ㄧㄥ', 'iong': 'ㄩㄥ', 'u': 'ㄨ', 'ua': 'ㄨㄚ',
  'uo': 'ㄨㄛ', 'uai': 'ㄨㄞ', 'ui': 'ㄨㄟ', 'uan': 'ㄨㄢ', 'un': 'ㄨㄣ', 'uang': 'ㄨㄤ', 'ueng': 'ㄨㄥ', 'ü': 'ㄩ',
  'üe': 'ㄩㄝ', 'üan': 'ㄩㄢ', 'ün': 'ㄩㄣ', 'uen': 'ㄨㄣ', 'uei': 'ㄨㄟ', 'iou': 'ㄧㄡ', // last three: wen, wei, you
};

/// One numbered syllable (`xue2`, `lu:4`, `ma5`) → its parts, or null if it isn't one.
({String? initial, String fin, int tone})? _parse(String syl) {
  final m = RegExp(r'^([a-zü:v]+?)([1-5])?$').firstMatch(syl.toLowerCase().replaceAll('u:', 'ü').replaceAll('v', 'ü'));
  if (m == null) return null;
  var s = m[1]!;
  final tone = int.tryParse(m[2] ?? '') ?? 5;
  if (s == 'r' && tone == 5) s = 'er'; // erhua 儿
  String? ini;
  for (final i in _initials.keys) {
    if (s.startsWith(i) && s.length > i.length) {
      ini = i;
      s = s.substring(i.length);
      break;
    }
  }
  if (ini == null && s.startsWith('y')) {
    s = s.substring(1);
    s = s.startsWith('u') ? 'ü${s.substring(1)}' : s.startsWith('i') ? s : 'i$s';
  } else if (ini == null && s.startsWith('w')) {
    s = s.substring(1);
    s = s.startsWith('u') ? s : 'u$s';
  }
  if ('jqx'.contains(ini ?? '-') && s.startsWith('u')) s = 'ü${s.substring(1)}';
  if (s == 'i' && const {'zh', 'ch', 'sh', 'r', 'z', 'c', 's'}.contains(ini)) s = ''; // zhi, si: no vowel sign
  if (s.isNotEmpty && !_finals.containsKey(s)) return null;
  return (initial: ini, fin: s, tone: tone);
}

/// `xue2 sheng5` → `ㄒㄩㄝˊ ˙ㄕㄥ`. Tokens that aren't syllables pass through.
String zhuyin(String pinyin) => pinyin.trim().split(RegExp(r'\s+')).map((syl) {
      final p = _parse(syl);
      if (p == null) return syl;
      final body = '${_initials[p.initial] ?? ''}${_finals[p.fin] ?? ''}';
      return p.tone == 5 ? '˙$body' : body + const ['', 'ˊ', 'ˇ', 'ˋ'][p.tone - 1];
    }).join(' ');

/// `xue2 sheng5` → `xué sheng`.
String pinyinMarks(String pinyin) => pinyin.trim().split(RegExp(r'\s+')).map((syl) {
      final m = RegExp(r'^([A-Za-züÜ:v]+)([1-5])$').firstMatch(syl);
      if (m == null) return syl.replaceAll('u:', 'ü');
      final s = m[1]!.replaceAll('u:', 'ü').replaceAll('v', 'ü');
      final tone = int.parse(m[2]!);
      if (tone == 5) return s;
      final lower = s.toLowerCase();
      final at = lower.contains('a')
          ? lower.indexOf('a')
          : lower.contains('e')
              ? lower.indexOf('e')
              : lower.contains('ou')
                  ? lower.indexOf('o')
                  : lower.lastIndexOf(RegExp('[iouü]'));
      if (at < 0) return s;
      const marks = {'a': 'āáǎà', 'e': 'ēéěè', 'i': 'īíǐì', 'o': 'ōóǒò', 'u': 'ūúǔù', 'ü': 'ǖǘǚǜ'};
      final v = marks[lower[at]]![tone - 1];
      return s.replaceRange(at, at + 1, s[at] == lower[at] ? v : v.toUpperCase());
    }).join(' ');
