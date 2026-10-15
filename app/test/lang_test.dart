import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/lang.dart';

void main() {
  test('detectLang', () {
    expect(detectLang('べんきょう'), 'ja');
    expect(detectLang('勉強する'), 'ja'); // kana wins
    expect(detectLang('學生', fallback: 'ja'), 'zh-Hant'); // traditional form
    expect(detectLang('学生', fallback: 'zh-Hant'), 'ja'); // shinjitai form
    expect(detectLang('我們'), 'zh-Hant');
    expect(detectLang('電話', fallback: 'zh-Hant'), 'zh-Hant'); // ambiguous → deck
    expect(detectLang('電話', fallback: 'ja'), 'ja');
    expect(detectLang('학생'), 'ko');
    expect(detectLang('study'), 'en');
    expect(detectLang('学生', fallback: 'zh-Hans'), 'zh-Hans');
  });
}
