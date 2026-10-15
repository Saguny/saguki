import 'package:flutter_test/flutter_test.dart';
import 'package:saguki/pron.dart';

void main() {
  test('furigana aligns readings to kanji runs', () {
    expect(furigana('食べ物', 'たべもの'), [(base: '食', ruby: 'た'), (base: 'べ', ruby: null), (base: '物', ruby: 'もの')]);
    expect(furigana('勉強', 'べんきょう'), [(base: '勉強', ruby: 'べんきょう')]);
    expect(furigana('お茶', 'オチャ'), [(base: 'お', ruby: null), (base: '茶', ruby: 'チャ')]);
    expect(furigana('ひらがな', 'ひらがな'), [(base: 'ひらがな', ruby: null)]);
    expect(furigana('食べる', 'のむ'), [(base: '食べる', ruby: 'のむ')]); // mismatch: whole word
  });

  test('ruby segments', () {
    expect(rubySegments('食べ物', '食[た]べ 物[もの]', 'ja'),
        [(base: '食', ruby: 'た'), (base: 'べ', ruby: null), (base: '物', ruby: 'もの')]);
    expect(rubySegments('學生', 'ㄒㄩㄝˊ ˙ㄕㄥ', 'zh-Hant'), [(base: '學', ruby: 'ㄒㄩㄝˊ'), (base: '生', ruby: '˙ㄕㄥ')]);
    expect(rubySegments('hello', 'həˈloʊ', 'en'), [(base: 'hello', ruby: 'həˈloʊ')]);
    expect(rubySegments('學生', '', 'zh-Hant'), [(base: '學生', ruby: null)]);
  });

  test('zhuyin from numbered pinyin', () {
    expect(zhuyin('xue2 sheng5'), 'ㄒㄩㄝˊ ˙ㄕㄥ');
    expect(zhuyin('zhong1 wen2'), 'ㄓㄨㄥ ㄨㄣˊ');
    expect(zhuyin('ni3 hao3 wei4'), 'ㄋㄧˇ ㄏㄠˇ ㄨㄟˋ');
    expect(zhuyin('shi4 you3 yu2 yue4'), 'ㄕˋ ㄧㄡˇ ㄩˊ ㄩㄝˋ');
    expect(zhuyin('lu:4 qu4 jiong3 er2'), 'ㄌㄩˋ ㄑㄩˋ ㄐㄩㄥˇ ㄦˊ');
    expect(zhuyin('Wang2 , A1'), 'ㄨㄤˊ , ㄚ');
  });

  test('tone-marked pinyin', () {
    expect(pinyinMarks('xue2 sheng5'), 'xué sheng');
    expect(pinyinMarks('gou3 lu:4 Zhong1 liu2'), 'gǒu lǜ Zhōng liú');
  });
}
