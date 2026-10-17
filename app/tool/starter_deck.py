"""Builds the bundled first-timer deck, assets/starter/taiwan-mandarin.sgki.

    python tool/starter_deck.py        # from app/

Taiwan readings (MOE dictionary): 星期 xīng qí, 垃圾 lè sè, 朋友 péng yǒu, fewer neutral tones.
Pinyin is numbered, one syllable per character, so readings sit over the right characters.
Fixed ids and modified_at = 1: importing twice (or on two synced devices) never duplicates,
and anything you've studied or edited is newer, so a re-import leaves it alone.
"""
import io, json, os, zipfile

# term, pinyin, meaning, example, example translation, explanation
WORDS = [
    ('你好', 'ni3 hao3', 'hello', '你好，我叫小明。', 'Hello, my name is Xiaoming.', ''),
    ('謝謝', 'xie4 xie5', 'thank you', '謝謝你的幫忙。', 'Thanks for your help.', ''),
    ('不客氣', 'bu4 ke4 qi4', "you're welcome", '「謝謝！」「不客氣。」', '"Thanks!" "You\'re welcome."', ''),
    ('對不起', 'dui4 bu4 qi3', 'sorry', '對不起，我來晚了。', "Sorry, I'm late.", ''),
    ('沒關係', 'mei2 guan1 xi5', "it's okay; never mind", '沒關係，下次再來。', "It's okay, come again next time.", ''),
    ('再見', 'zai4 jian4', 'goodbye', '老師再見！', 'Goodbye, teacher!', ''),
    ('早安', 'zao3 an1', 'good morning', '早安！你吃早餐了嗎？', 'Good morning! Have you had breakfast?', ''),
    ('請', 'qing3', 'please', '請坐。', 'Please sit.', ''),
    ('請問', 'qing3 wen4', 'excuse me (may I ask)', '請問，捷運站在哪裡？', 'Excuse me, where is the MRT station?', ''),
    ('是', 'shi4', 'to be', '我是學生。', 'I am a student.', ''),
    ('不', 'bu4', 'not', '我不喝咖啡。', "I don't drink coffee.", ''),
    ('對', 'dui4', 'correct; right', '對，你說得對。', "Yes, you're right.", ''),
    ('好', 'hao3', 'good; well', '今天天氣很好。', 'The weather is nice today.', ''),
    ('嗎', 'ma5', 'question particle', '你是台灣人嗎？', 'Are you Taiwanese?', 'Turns a statement into a yes/no question.'),
    ('的', 'de5', "possessive particle ('s)", '這是我的書。', 'This is my book.', ''),
    ('我', 'wo3', 'I; me', '我很好。', "I'm fine.", ''),
    ('你', 'ni3', 'you', '你叫什麼名字？', "What's your name?", ''),
    ('他', 'ta1', 'he; him', '他是我哥哥。', "He's my older brother.", ''),
    ('她', 'ta1', 'she; her', '她是我的老師。', "She's my teacher.", ''),
    ('我們', 'wo3 men5', 'we; us', '我們一起去吧。', "Let's go together.", ''),
    ('什麼', 'shen2 me5', 'what', '這是什麼？', 'What is this?', ''),
    ('誰', 'shei2', 'who', '他是誰？', 'Who is he?', 'Taiwan usually says shéi.'),
    ('哪裡', 'na3 li3', 'where', '你住在哪裡？', 'Where do you live?', ''),
    ('怎麼', 'zen3 me5', 'how', '這個怎麼說？', 'How do you say this?', ''),
    ('這', 'zhe4', 'this', '這是我的手機。', 'This is my phone.', ''),
    ('那', 'na4', 'that', '那是誰的？', 'Whose is that?', ''),
    ('一', 'yi1', 'one', '我有一個妹妹。', 'I have one younger sister.', ''),
    ('二', 'er4', 'two', '我的生日在二月。', 'My birthday is in February.', ''),
    ('三', 'san1', 'three', '我們有三個人。', 'There are three of us.', ''),
    ('十', 'shi2', 'ten', '這個十塊錢。', 'This is ten dollars.', ''),
    ('兩', 'liang3', 'two (of something)', '我要兩杯咖啡。', "I'd like two coffees.", 'Use 兩 before a measure word, 二 when counting.'),
    ('幾', 'ji3', 'how many', '你幾歲？', 'How old are you?', ''),
    ('個', 'ge4', 'general measure word', '我一個人住。', 'I live alone.', ''),
    ('人', 'ren2', 'person', '台灣人很友善。', 'Taiwanese people are friendly.', ''),
    ('朋友', 'peng2 you3', 'friend', '他是我的好朋友。', "He's my good friend.", ''),
    ('老師', 'lao3 shi1', 'teacher', '老師，早安！', 'Good morning, teacher!', ''),
    ('學生', 'xue2 sheng1', 'student', '她是大學生。', "She's a university student.", ''),
    ('媽媽', 'ma1 ma5', 'mom', '我媽媽很會做菜。', 'My mom is a great cook.', ''),
    ('爸爸', 'ba4 ba5', 'dad', '爸爸在上班。', 'Dad is at work.', ''),
    ('先生', 'xian1 sheng1', 'Mr.; husband', '王先生，你好。', 'Hello, Mr. Wang.', ''),
    ('小姐', 'xiao3 jie3', 'Miss; young lady', '小姐，請問一下。', 'Excuse me, miss.', ''),
    ('名字', 'ming2 zi4', 'name', '你的名字很好聽。', 'Your name sounds nice.', ''),
    ('叫', 'jiao4', 'to be called', '我叫大衛。', 'My name is David.', ''),
    ('有', 'you3', 'to have; there is', '你有時間嗎？', 'Do you have time?', ''),
    ('沒有', 'mei2 you3', "to not have; there isn't", '我沒有錢。', "I don't have money.", ''),
    ('在', 'zai4', 'at; in; to be at', '我在家。', "I'm at home.", ''),
    ('要', 'yao4', 'to want; will', '我要這個。', 'I want this one.', ''),
    ('想', 'xiang3', 'would like to; to think', '我想去台北。', "I'd like to go to Taipei.", ''),
    ('喜歡', 'xi3 huan1', 'to like', '我喜歡珍珠奶茶。', 'I like bubble tea.', ''),
    ('去', 'qu4', 'to go', '你要去哪裡？', 'Where are you going?', ''),
    ('來', 'lai2', 'to come', '你什麼時候來台灣？', 'When are you coming to Taiwan?', ''),
    ('吃', 'chi1', 'to eat', '我們去吃飯吧。', "Let's go eat.", ''),
    ('喝', 'he1', 'to drink', '你要喝什麼？', 'What would you like to drink?', ''),
    ('看', 'kan4', 'to look; to watch', '我在看電視。', "I'm watching TV.", ''),
    ('說', 'shuo1', 'to speak; to say', '你會說中文嗎？', 'Can you speak Chinese?', ''),
    ('會', 'hui4', 'can (know how to)', '我會騎機車。', 'I can ride a scooter.', ''),
    ('可以', 'ke3 yi3', 'can; may', '我可以坐這裡嗎？', 'Can I sit here?', ''),
    ('知道', 'zhi1 dao4', 'to know', '我不知道。', "I don't know.", ''),
    ('買', 'mai3', 'to buy', '我想買一杯茶。', 'I want to buy a cup of tea.', ''),
    ('學', 'xue2', 'to learn', '我在學中文。', "I'm learning Chinese.", ''),
    ('住', 'zhu4', 'to live (somewhere)', '我住在台中。', 'I live in Taichung.', ''),
    ('工作', 'gong1 zuo4', 'to work; job', '我在台北工作。', 'I work in Taipei.', ''),
    ('睡覺', 'shui4 jiao4', 'to sleep', '我要去睡覺了。', "I'm going to bed.", ''),
    ('等', 'deng3', 'to wait', '請等一下。', 'Please wait a moment.', ''),
    ('大', 'da4', 'big', '這個太大了。', 'This is too big.', ''),
    ('小', 'xiao3', 'small', '我的房間很小。', 'My room is small.', ''),
    ('多', 'duo1', 'many; much', '夜市人很多。', 'The night market is crowded.', ''),
    ('少', 'shao3', 'few; little', '今天人很少。', 'There are few people today.', ''),
    ('多少', 'duo1 shao3', 'how many; how much', '你要多少？', 'How many do you want?', ''),
    ('貴', 'gui4', 'expensive', '這個太貴了！', 'This is too expensive!', ''),
    ('便宜', 'pian2 yi2', 'cheap', '夜市的東西很便宜。', 'Things at the night market are cheap.', ''),
    ('好吃', 'hao3 chi1', 'tasty', '這個很好吃！', 'This is delicious!', ''),
    ('熱', 're4', 'hot', '台灣的夏天很熱。', 'Summers in Taiwan are hot.', ''),
    ('冷', 'leng3', 'cold', '今天有點冷。', "It's a bit cold today.", ''),
    ('忙', 'mang2', 'busy', '你最近忙嗎？', 'Have you been busy lately?', ''),
    ('很', 'hen3', 'very', '我很高興。', "I'm very happy.", 'Often just links a subject to an adjective, without much "very".'),
    ('太', 'tai4', 'too; extremely', '太好了！', 'Great!', ''),
    ('今天', 'jin1 tian1', 'today', '今天星期幾？', 'What day is it today?', ''),
    ('明天', 'ming2 tian1', 'tomorrow', '明天見！', 'See you tomorrow!', ''),
    ('昨天', 'zuo2 tian1', 'yesterday', '昨天下雨了。', 'It rained yesterday.', ''),
    ('現在', 'xian4 zai4', 'now', '現在幾點？', 'What time is it now?', ''),
    ('星期', 'xing1 qi2', 'week', '一個星期有七天。', 'A week has seven days.', 'Taiwan says xīng qí; mainland xīng qī.'),
    ('點', 'dian3', "o'clock", '我們三點見。', 'See you at three.', ''),
    ('時候', 'shi2 hou4', 'time; when', '你什麼時候有空？', 'When are you free?', ''),
    ('台灣', 'tai2 wan1', 'Taiwan', '我很喜歡台灣。', 'I really like Taiwan.', ''),
    ('台北', 'tai2 bei3', 'Taipei', '台北的捷運很方便。', "Taipei's MRT is convenient.", ''),
    ('中文', 'zhong1 wen2', 'Chinese (language)', '中文很難嗎？', 'Is Chinese hard?', ''),
    ('家', 'jia1', 'home; family', '我想回家。', 'I want to go home.', ''),
    ('學校', 'xue2 xiao4', 'school', '學校離我家很近。', 'School is close to my home.', ''),
    ('夜市', 'ye4 shi4', 'night market', '晚上去夜市吧！', "Let's go to the night market tonight!", ''),
    ('便利商店', 'bian4 li4 shang1 dian4', 'convenience store', '便利商店在對面。', 'The convenience store is across the street.', ''),
    ('捷運', 'jie2 yun4', 'MRT; metro', '我坐捷運上班。', 'I take the MRT to work.', ''),
    ('機車', 'ji1 che1', 'scooter', '台灣到處都是機車。', 'There are scooters everywhere in Taiwan.', 'Slang: also means annoying.'),
    ('計程車', 'ji4 cheng2 che1', 'taxi', '我們坐計程車吧。', "Let's take a taxi.", ''),
    ('廁所', 'ce4 suo3', 'restroom', '請問，廁所在哪裡？', 'Excuse me, where is the restroom?', ''),
    ('飯', 'fan4', 'rice; meal', '你吃飯了嗎？', 'Have you eaten?', 'Also a casual greeting.'),
    ('水', 'shui3', 'water', '請給我一杯水。', 'A glass of water, please.', ''),
    ('茶', 'cha2', 'tea', '台灣的茶很有名。', 'Taiwanese tea is famous.', ''),
    ('咖啡', 'ka1 fei1', 'coffee', '我每天早上喝咖啡。', 'I drink coffee every morning.', ''),
    ('珍珠奶茶', 'zhen1 zhu1 nai3 cha2', 'bubble tea', '一杯珍珠奶茶，半糖少冰。', 'One bubble tea, half sugar, less ice.', ''),
    ('早餐', 'zao3 can1', 'breakfast', '我的早餐是蛋餅。', 'My breakfast is an egg crepe.', ''),
    ('外帶', 'wai4 dai4', 'takeout; to go', '內用還是外帶？', 'For here or to go?', ''),
    ('菜單', 'cai4 dan1', 'menu', '可以給我菜單嗎？', 'Can I have the menu?', ''),
    ('錢', 'qian2', 'money', '這個多少錢？', 'How much is this?', ''),
    ('塊', 'kuai4', 'dollar (NT$, spoken)', '這杯茶五十塊。', 'This tea is fifty dollars.', ''),
    ('手機', 'shou3 ji1', 'mobile phone', '我的手機沒電了。', 'My phone is dead.', ''),
    ('垃圾', 'le4 se4', 'trash', '垃圾車來了！', 'The garbage truck is here!', 'Taiwan says lè sè; mainland lā jī.'),
]

DECK = 'starter-tw'
DUE = 1767225600  # 2026-01-01; new cards are picked by order, not due
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'starter', 'taiwan-mandarin.sgki')


def main():
    for term, pron, *_ in WORDS:
        assert len(term) == len(pron.split()), term  # one syllable per character
    assert len({w[0] for w in WORDS}) == len(WORDS), 'duplicate term'
    sync = {'modified_at': 1, 'deleted': 0}
    tables = {
        'prefs': [],
        'decks': [{'id': DECK, 'name': 'Taiwan Mandarin basics', 'language': 'zh-Hant', 'new_per_day': 10,
                   'description': 'Everyday words for your first weeks in Taiwan.', 'desired_retention': 0.9, **sync}],
        'notes': [], 'cards': [], 'review_logs': [],
    }
    for i, (term, pron, meaning, ex, ex_tr, expl) in enumerate(WORDS, 1):
        n = f'{DECK}-n{i:03}'
        assert term in ex, term  # the example highlights the word
        tables['notes'].append({'id': n, 'deck_id': DECK, 'term': term, 'pronunciation': pron, 'meaning': meaning,
                                'explanation': expl, 'example': ex, 'example_translation': ex_tr, 'tags': 'starter', **sync})
        tables['cards'].append({'id': f'{DECK}-c{i:03}', 'note_id': n, 'direction': 'fwd', 'due': DUE, 'state': 1,
                                'step': 0, 'stability': None, 'difficulty': None, 'reps': 0, 'lapses': 0,
                                'last_review': None, **sync})
    buf = io.BytesIO()
    with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as z:
        z.writestr('saguki.json', json.dumps({'format': 'saguki', 'version': 1, 'exported': 1, 'tables': tables},
                                             ensure_ascii=False))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, 'wb').write(buf.getvalue())
    print(f'{len(WORDS)} words -> {os.path.relpath(OUT)}')


if __name__ == '__main__':
    main()
