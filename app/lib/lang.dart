/// Script-based language detection (PLAN.md §3). No ML.
library;

const languages = {'ja': '日本語', 'zh-Hant': '繁體中文', 'zh-Hans': '简体中文', 'ko': '한국어', 'en': 'English'};

final _kana = RegExp(r'[぀-ヿㇰ-ㇿ]');
final _hangul = RegExp(r'[가-힯ᄀ-ᇿ]');
final _han = RegExp(r'[㐀-䶿一-鿿]');

// ponytail: tiny hand-picked character lists; Han-only words outside them fall back
// to the deck language. Upgrade path: full shinjitai/traditional tables from Unihan.
const _jpOnly = '学国気図売読会広円変体関発験歩対転来戦鉄楽薬様声訳辺駅権応桜経続乗両県単払触帰弁仏伝価児悪圧医営塩画絵覚観顔旧挙区軽芸剣険検験効号黒済剤雑残歯辞実写釈収従処将焼称証条状譲寝図数専浅銭総装蔵属続帯滞択担団弾断遅昼庁聴鉄点当党盗読売髪晩変辺歩宝豊毎満訳薬与様来乱覧両緑礼齢労湾';
const _tradOnly = '學國氣圖賣讀會廣圓變體關發驗步對轉來戰鐵樂藥樣聲譯邊驛權應櫻經續乘兩縣單觸歸辯佛傳價兒惡壓醫營鹽畫繪覺觀顏舊舉區輕藝劍險檢效號黑濟劑雜殘齒辭實寫釋收從處將燒稱證條狀讓寢數專淺錢總裝藏屬帶滯擇擔團彈斷遲晝廳聽點當黨盜髮晚寶豐每滿與覽綠禮齡勞灣們這說嗎麼還給讓';

/// Detects the language of [s]. [fallback] is the deck language, used when the
/// text is ambiguous Han-only.
String detectLang(String s, {String fallback = 'ja'}) {
  if (_kana.hasMatch(s)) return 'ja';
  if (_hangul.hasMatch(s)) return 'ko';
  if (_han.hasMatch(s)) {
    if (fallback == 'zh-Hans') return fallback; // simplified overlaps JP shinjitai
    for (final ch in s.runes.map(String.fromCharCode)) {
      if (_jpOnly.contains(ch)) return 'ja';
      if (_tradOnly.contains(ch)) return 'zh-Hant';
    }
    return fallback == 'ja' || fallback == 'zh-Hant' ? fallback : 'ja';
  }
  return 'en';
}

/// BCP-47 → TTS voice.
String ttsLocale(String lang) =>
    const {'ja': 'ja-JP', 'zh-Hant': 'zh-TW', 'zh-Hans': 'zh-CN', 'ko': 'ko-KR'}[lang] ?? 'en-US';
