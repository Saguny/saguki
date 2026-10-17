// Everything Zero says: [Chinese, English subtitle]. Numbers go in as {due张} / {today张} /
// {days天} / {hour点} / {did张} / {yday张} in Chinese and {due} / {today} / {days} / {hour} / {did} / {yday} in English.
// {word} is a word you studied (both languages; its clip is voice/w_<hash>.mp3), {mean} its meaning (English only).
// notify_* and reviewDone are read by the app (reminders, the review screen) and aren't voiced.
// Her voice (Xiaoyi) is pre-generated from this file by tool/zero_voice.py into voice/:
// re-run it after editing a line. Keep it plain JSON after "const LINES =" (the script parses it).
const LINES = {
  "sleepy": [
    ["呼……啊。还有{due张}在等你。", "zz… oh. {due} cards waiting."],
    ["哈啊～……早上了吗？", "*yawn* …morning?"],
    ["再睡五分钟嘛……", "five more minutes…"],
    ["我又梦到单词卡了。", "I dreamt about flashcards again."],
    ["你开始学的时候再叫我嘛。", "wake me up when you start."]
  ],
  "nothingDue": [["呼……今天没有卡要复习。继续睡啦。", "zz… nothing due. back to sleep."]],
  "bedtime": [
    ["都{hour点}了，快去睡觉。", "it's {hour}am. go to bed."],
    ["……卡片明天也还在的啦。", "…the cards will still be here tomorrow."],
    ["哈啊～睡觉也是学习的一部分哦。", "*yawn* sleep is studying too, you know."],
    ["你，床上，现在。", "you, bed, now."]
  ],
  "cheer": [
    ["还剩{due张}，你可以的！", "{due} left. you've got this."],
    ["做得很好，继续加油！", "you're doing great, keep going!"],
    ["一张一张来～", "one card at a time~"],
    ["已经做完{today张}了！", "{today} done already!"],
    ["现在可别停下哦♡", "don't stop now ♡"],
    ["我在看着你哦，不许偷懒。", "I'm watching. no slacking."]
  ],
  "almost": [
    ["只剩{due张}了！！", "only {due} left!!"],
    ["快完成啦！", "almost there!"],
    ["最后冲刺！", "finish strong!"],
    ["就差一点点～", "so close~"]
  ],
  "happy": [
    ["今天全部完成啦！♡", "all done today! ♡"],
    ["你做到了～", "you did it~"],
    ["明天老时间见？", "same time tomorrow?"],
    ["我为你骄傲。", "I'm proud of you."],
    ["{today张}，还不错嘛～", "{today} cards. not bad~"]
  ],
  "proud": [
    ["{today张}？！你到底是谁啊。", "{today} cards?! who ARE you."],
    ["好吧，这真的很厉害。", "okay, that's actually impressive."],
    ["我的学习搭档是最棒的♡", "my study partner is the best ♡"],
    ["你今天简直无人能挡。", "you're unstoppable today."]
  ],
  "reunion": [
    ["……你回来了。", "…you came back."],
    ["我还以为你把我忘了。", "I thought you forgot about me."],
    ["我们一起加油，好不好？", "let's do this together, okay?"],
    ["我还有一点点生气。……继续吧。", "I'm still a little mad. …keep going."]
  ],
  "lonely": [
    ["你昨天没来……", "you didn't come yesterday…"],
    ["我一直在等你哦。", "I waited, you know."],
    ["……我没生气，只是有点寂寞。", "…I'm not mad. just lonely."],
    ["{due张}卡片也很想你。", "{due} cards missed you too."]
  ],
  "teary": [
    ["两天了……", "two days…"],
    ["我是不是做错什么了？", "did I do something wrong?"],
    ["呜……卡片都堆起来了，现在有{due张}。", "*sniff* the cards piled up. {due} now."],
    ["我一直帮你留着位置……现在都凉了。", "I kept your spot warm. …it's cold now."]
  ],
  "angry": [
    ["{days天}了。哼。", "{days} days. hmph."],
    ["哦，你现在才来？", "oh, NOW you show up?"],
    ["别跟我说话。", "don't talk to me."],
    ["{due张}卡，全都怪你。", "{due} cards. all your fault."],
    ["我不理你了。……哼。", "I'm not speaking to you. …hmph."]
  ],
  "sulky": [
    ["……好吧，我原谅你了。", "…fine. I forgive you."],
    ["但是你要把卡都做完，全部！", "but you're doing your cards. ALL of them."],
    ["不许再让我等那么久了。", "don't make me wait like that again."],
    ["……笨蛋，我想你了。", "…I missed you, idiot."]
  ],
  "cold": [
    ["……", "…"],
    ["哦，是你啊。", "oh. it's you."],
    ["{days天}了。", "{days} days."],
    ["我早就不数了。……骗你的，{days天}。", "I stopped counting. …no I didn't. {days} days."],
    ["随便你吧。", "do whatever you want."]
  ],
  "pat": [
    ["诶嘿嘿", "ehehe"],
    ["嗯～♡", "♡"],
    ["唔嗯～", "mm~"],
    ["还要摸吗？", "more pats?"],
    ["嘿嘿，别闹啦～", "hehe, stop it~"]
  ],
  "patCheer": [
    ["做完卡再摸！", "pats after cards!"],
    ["诶嘿嘿……好啦，继续学习。", "ehehe… okay, back to work."],
    ["嘿嘿♡ 快去学习啦", "♡ now go study"]
  ],
  "patSad": [
    ["……你终于来了。", "…you're here now."],
    ["呜……嗯。", "*sniff* …okay."],
    ["不要再离开那么久了。", "don't leave that long again."],
    ["……再摸一下。", "…one more."]
  ],
  "patSulky": [
    ["……哼♡", "…hmph ♡"],
    ["……就一点点哦。", "…only a little."],
    ["我还在生气。……别停。", "I'm still mad. …don't stop."]
  ],
  "rub": [
    ["嗯～", "mm~"],
    ["诶嘿嘿……好舒服", "ehehe… that feels nice"],
    ["呼嗯～♡", "♡♡♡"],
    ["再往左一点……嘿嘿", "a little to the left… ehehe"],
    ["不要停嘛～", "don't stop~"],
    ["我好像会上瘾的……", "I could get used to this…"]
  ],
  "rubCat": [
    ["喵～……我、我才没有说！", "nya~ …I did NOT just say that."],
    ["呼噜噜……等一下。", "*purr* …wait."],
    ["喵……♡", "nya… ♡"]
  ],
  "rubSad": [
    ["……嗯，我现在没事了。", "…okay. I'm okay now."],
    ["呜……谢谢你。", "*sniff* …thank you."],
    ["再陪我一会儿好吗？", "stay a bit longer?"]
  ],
  "rubSulky": [
    ["……哼。……别停。", "…hmph. …don't stop."],
    ["……我还在生气。……一点点。", "…I'm still mad. …a little."],
    ["……这样太犯规了。", "…this is cheating."]
  ],
  "rubSleepy": [
    ["唔……这样我更醒不过来了……", "mm… that's not helping me wake up…"],
    ["呼……嘿嘿……", "zz… ehehe…"],
    ["……再摸五下……", "…five more rubs…"]
  ],
  "rubAngry": [
    ["哼。", "hmph."],
    ["……", "…"],
    ["……别以为这招对我有用。", "…don't think this works on me."],
    ["……好像有一点用。", "…it's working a little."]
  ],
  "rubStop": [
    ["……诶？怎么停了？", "…eh? why'd you stop?"],
    ["诶嘿嘿，谢谢♡", "ehehe. thanks ♡"],
    ["……等下再摸？", "…more later?"]
  ],
  "patCold": [
    ["别碰我。", "don't."],
    ["……", "…"],
    ["{days天}了，你还想摸我？", "{days} days, and you want to pat me?"],
    ["住手。", "stop."]
  ],
  "angryPat": [
    ["哼。", "hmph."],
    ["别碰我。", "don't touch me."],
    ["……你以为摸摸头就没事了？", "…you think a pat fixes this?"],
    ["……", "…"],
    ["……继续。", "…keep going."]
  ],
  "poke": [
    ["诶！？", "!?"],
    ["喂、喂！", "h-hey!"],
    ["眼睛往上看！", "eyes up here."],
    ["……变态。", "…pervert."],
    ["你干嘛？？", "excuse me??"]
  ],
  "pokeSad": [
    ["嗯……？", "…?"],
    ["摸头不是摸那里啦。", "that's not where pats go."]
  ],
  "pokeAngry": [
    ["你干什么？！", "excuse me?!"],
    ["想都别想。", "absolutely not."],
    ["你胆子不小啊。", "you've got some nerve."]
  ],
  "pokeCold": [
    ["不行。", "no."],
    ["……", "…"],
    ["别这样。", "don't."]
  ],
  "sing": [
    ["♪ 啦啦啦～", "♪ la la la~"],
    ["♪ 汉字、声调、单词卡～", "♪ hanzi, tones, flashcards~"],
    ["♪ 嗯哼哼～", "♪ hmm hmm hmm~"]
  ],
  "outfit": [
    ["好看吗？", "how do I look?"],
    ["新造型♡", "new look ♡"],
    ["嘿嘿", "hehe"],
    ["可爱吧？", "cute, right?"]
  ],
  "outfitAngry": [["给我换衣服也没用。", "dressing me up won't fix it."]],
  "wakeBed": [["！！……我才没睡着。倒是你该睡了。", "!! …I wasn't asleep. you should be, though."]],
  "wakeDue": [["！！我醒了！{due张}卡，开始吧！", "!! I'm up. {due} cards, let's go."]],
  "wakeNone": [["！！醒了醒了！", "!! I'm up, I'm up."]],
  "coldCrack": [["……你现在才对我这么好干嘛。", "…why are you being nice now."]],
  "coldHurt": [["……我真的一直在等你啊。", "…I really waited for you, you know."]],
  "forgiveRub": [["……好啦，你赢了。我原谅你。", "…fine. you win. I forgive you."]],
  "forgivePat": [["……好吧，我原谅你。但你要把卡做完。", "…fine. I forgive you. but you do your cards."]],
  "dizzy": [["停、停下……房间在转……", "s-stop, the room is spinning…"]],
  "ignore": [["好，够了。我不理你了。", "okay, that's it. I'm ignoring you."]],
  "unlock_phones": [["哇，是耳机！", "ooh, headphones!"]],
  "unlock_ears": [["哇，是猫耳！", "ooh, cat ears!"]],
  "unlock_coat": [["哇，外套可以脱了！", "ooh, no jacket!"]],
  "unlock_game": [["哇，游戏时间！", "ooh, game time!"]],
  "unlock_black": [["哇，黑头发！……像不像另一个人？", "ooh, black hair! …do I look like someone else?"]],
  "unlock_down": [["哇，可以把头发放下来了！", "ooh, hair down!"]],
  "unlock_short": [["哇，短发！", "ooh, short hair!"]],
  "unlock_bun": [["哇，小丸子头！", "ooh, a little bun!"]],
  "unlock_chibi": [["哇，Q版的我！", "ooh, chibi me!"]],
  "caught_game": [
    ["！！……我、我只是在帮你测试游戏机而已。", "!! …I was just testing the console for you."],
    ["啊！差一点就通关了……你好啊。", "ah! I almost beat it… hi."]
  ],
  "caught_sing": [
    ["！！你、你听到了？……忘掉它。", "!! y-you heard that? …forget it."],
    ["诶？！你什么时候来的……刚才那个不算！", "eh?! when did you get here… that didn't count!"]
  ],
  "caught_swab": [
    ["诶！？别看！……我在掏耳朵啦。", "eh!? don't look! …I'm cleaning my ears."],
    ["！！……你、你应该先敲门的。", "!! …y-you should knock first."]
  ],
  "caught_mope": [
    ["……啊，你来了。", "…oh. you're here."],
    ["！……我才没有在发呆。", "! …I wasn't spacing out."]
  ],
  "sessionBig": [
    ["{did张}？！趁我不在你一直在学吗？", "{did} cards?! you studied the whole time I was gone?"],
    ["我才离开一下，你就做了{did张}……你是怪物吗？", "I look away for a second and you do {did}… are you a monster?"]
  ],
  "sessionGood": [
    ["我不在的时候你做了{did张}，好棒～", "{did} cards while I wasn't looking. nice~"],
    ["{did张}！我都看到了哦。", "{did} cards! I saw that."]
  ],
  "sessionSmall": [
    ["才{did张}？热身而已吧～", "only {did}? that was just a warm-up~"],
    ["做了{did张}，好的开始！", "{did} down, good start!"]
  ],
  "sessionTired": [
    ["学了好久……要不要休息一下？", "that was a long one… want to take a break?"],
    ["你看起来好累。喝点水吧？", "you look tired. drink some water?"]
  ],
  "visitEarly": [
    ["今天来得好早！……我头发还没梳好呢。", "you're early today! …I haven't even done my hair."]
  ],
  "visitLate": [
    ["今天怎么这么晚才来？我都等困了。", "why so late today? I got sleepy waiting."]
  ],
  "attention": [
    ["喂～你还在吗？", "hey~ are you still there?"],
    ["……你在看我吗？", "…are you looking at me?"],
    ["我无聊了～陪我玩嘛。", "I'm bored~ play with me."],
    ["摸摸头也可以哦……我只是说说。", "head pats are allowed, you know… just saying."]
  ],
  "shake": [
    ["别、别晃了！我要晕了……", "s-stop shaking! I'm getting dizzy…"],
    ["哇啊啊！地震了吗？！", "waaah! is it an earthquake?!"]
  ],
  "temper_sweet": [
    ["今天心情特别好～因为你在嘛。", "I'm in a really good mood today~ because you're here."],
    ["你今天也很努力呢，我喜欢。", "you're working hard today too. I like that."],
    ["嘿嘿，今天想一直笑。", "ehehe, I just want to smile all day."]
  ],
  "temper_clingy": [
    ["今天不许离开我太久哦。", "don't leave me for too long today."],
    ["再待一会儿嘛……就一会儿。", "stay a bit longer… just a bit."],
    ["你在做什么？我也想知道。", "what are you doing? I want to know too."]
  ],
  "temper_bratty": [
    ["哼，今天我说了算。", "hmph. today I'm in charge."],
    ["才、才不是在等你呢。", "I-I wasn't waiting for you or anything."],
    ["快点学啦，笨蛋。", "hurry up and study, dummy."]
  ],
  "temper_spacey": [
    ["……嗯？我刚才在说什么来着？", "…hm? what was I saying?"],
    ["今天脑子里全是云……", "my head's full of clouds today…"],
    ["你有没有觉得……天花板很好看？", "don't you think… the ceiling looks nice?"]
  ],
  "patBratty": [
    ["哼，才不是因为喜欢你才让你摸的。", "hmph. it's not like I let you because I like you."],
    ["……摸、摸够了没？", "…a-are you done yet?"]
  ],
  "love1": [
    ["和你一起学习，好像还不错。", "studying with you is… actually not bad."],
    ["我开始习惯你每天来了。", "I'm getting used to you coming every day."]
  ],
  "love2": [
    ["你来了我就很开心。……真的。", "I'm happy when you come. …really."],
    ["我们是最好的学习搭档，对吧？", "we're the best study partners, right?"]
  ],
  "love3": [
    ["……我最喜欢你了。学习的时候！学习的时候啦！", "…I like you the most. when we study! I mean when we study!"],
    ["不管多久，我都会在这里等你。", "however long it takes, I'll be right here."]
  ],
  "loveUp": [
    ["……我好像越来越喜欢和你一起学习了。", "…I think I'm starting to really like studying with you."],
    ["你是我最重要的学习搭档哦♡", "you're my most important study partner ♡"],
    ["……一直在一起吧？我是说，学习！学习啦！", "…let's always be together? I mean studying! studying!"]
  ],
  "patsCount": [
    ["这是你第十次摸我的头了哦。", "that's the tenth head pat, you know."],
    ["第五十次！……你真的很喜欢摸头呢。", "fifty! …you really like head pats, huh."],
    ["一百次了！我都记着呢♡", "a hundred pats! I've been counting ♡"],
    ["五百次……我的头发都要被你摸平了。", "five hundred… you're going to flatten my hair."],
    ["一千次！你是摸头大师吧。", "a thousand! you're a head-pat master."]
  ],
  "rubsCount": [
    ["第十次揉头了……我好像有点上瘾。", "tenth head rub… I think I'm hooked."],
    ["五十次了，你的手好暖。", "fifty rubs. your hands are warm."],
    ["两百次……没有你我可怎么办啊。", "two hundred… what would I do without you."]
  ],
  "pokesCount": [
    ["你已经戳了我二十次了！变态！", "that's twenty pokes! pervert!"],
    ["一百次……我要报警了。", "a hundred… I'm calling the police."]
  ],
  "anniv": [
    ["我们认识一个星期了！", "we've known each other for a week!"],
    ["一个月了……时间过得好快。", "a whole month… time flies."],
    ["一百天！谢谢你每天都来。", "a hundred days! thank you for coming every day."],
    ["一整年了。……以后也请多多指教。", "a whole year. …please keep looking after me."]
  ],
  "cal_newYear": [
    ["新年快乐！今年也一起加油吧！", "happy new year! let's do our best this year too!"]
  ],
  "cal_valentine": [
    ["今、今天是情人节……这个巧克力不是给你的！……好吧，是给你的。", "t-today's valentine's… this chocolate isn't for you! …okay, it is."]
  ],
  "cal_birthday": [
    ["今天是我的生日哦！……你记得吗？", "today's my birthday! …did you remember?"]
  ],
  "cal_halloween": [
    ["不给糖就捣蛋！……卡片也算糖吗？", "trick or treat! …do cards count as candy?"]
  ],
  "cal_xmas": [
    ["圣诞快乐～你的礼物就是今天的卡片！", "merry christmas~ your present is today's cards!"]
  ],
  "cal_lunar": [
    ["新年快乐！恭喜发财，红包拿来～", "happy lunar new year! now hand over the red envelope~"]
  ],
  "cal_midautumn": [
    ["中秋节快乐！今晚的月亮一定很圆。", "happy mid-autumn! the moon must be so round tonight."]
  ],
  "record": [
    ["新纪录！今天已经{today张}了！", "new record! {today} cards today!"]
  ],
  "beatYday": [
    ["比昨天做得还多！你好厉害。", "more than yesterday! you're amazing."]
  ],
  "memYday": [
    ["昨天你做了{yday张}，今天也一起吧～", "you did {yday} yesterday. let's go again today~"],
    ["我还记得昨天的{yday张}哦。今天呢？", "I still remember yesterday's {yday}. and today?"]
  ],
  "rough": [
    ["今天好多卡都忘了呢……没关系，忘了再记就好。", "you forgot a lot today… that's okay, forgetting is part of remembering."],
    ["今天比较难哦。你还是坚持下来了，我都看到了。", "today was a hard one. you stuck with it anyway, I saw."],
    ["错了好多？那说明你在学新东西嘛。", "lots of misses? that means you're learning new stuff."]
  ],
  "streak": [
    ["连续七天了！一整个星期都没缺席哦。", "seven days in a row! a whole week without missing."],
    ["连续三十天……你真的每天都来了。", "thirty days straight… you really came every single day."],
    ["一百天连续！我要给你颁奖。", "a hundred days in a row! I'm giving you an award."],
    ["连续一整年……我说不出话了。谢谢你。", "a whole year in a row… I'm speechless. thank you."]
  ],
  "water": [
    ["你学习了，我就给小草浇水～", "you studied, so I watered the plant~"],
    ["浇水时间！它今天也长大了一点点。", "watering time! it grew a tiny bit today too."]
  ],
  "morning": [
    ["早安！今天也一起加油吧。", "good morning! let's do our best today too."],
    ["早……我还没完全醒。", "morning… I'm not fully awake yet."]
  ],
  "evening": [
    ["晚上好～今天过得怎么样？", "good evening~ how was your day?"],
    ["天黑了呢。学完就早点休息哦。", "it's dark out. rest early once you're done."]
  ],
  "promiseAsk": [["明天也会来吗？", "will you come tomorrow too?"]],
  "promiseYes": [["约好了哦！拉钩♡", "it's a promise! pinky swear ♡"]],
  "promiseNo": [["……哼。随便你。", "…hmph. suit yourself."]],
  "promiseKept": [
    ["你真的来了！说话算话，好棒♡", "you actually came! you kept your promise ♡"],
    ["我就知道你会遵守约定的。", "I knew you'd keep your promise."]
  ],
  "promiseBroke": [
    ["……你说好昨天会来的。", "…you promised you'd come yesterday."],
    ["拉过钩的……骗子。", "we pinky swore… liar."]
  ],
  "wordRecall": [
    ["今天学的「{word}」你还记得吗？", "do you still remember \"{word}\" from today?"],
    ["「{word}」……我也在偷偷练习哦。", "\"{word}\"… I've been practicing it too, secretly."],
    ["我刚才一直在念「{word}」，停不下来。", "I keep saying \"{word}\" in my head. can't stop."]
  ],
  "quizAsk": [
    ["考考你！「{word}」是什么意思？", "pop quiz! what does \"{word}\" mean?"],
    ["「{word}」……你还记得是什么意思吗？", "\"{word}\"… do you remember what it means?"]
  ],
  "quizRight": [
    ["答对了！好厉害♡", "correct! amazing ♡"],
    ["嘿嘿，就知道你会。", "ehehe, I knew you'd get it."]
  ],
  "quizWrong": [
    ["不对哦～是这个意思啦。", "nope~ it means \"{mean}\"."],
    ["差一点！下次一定记得。", "close! it's \"{mean}\". you'll get it next time."]
  ],
  "headFly": [["头、头都被你戳飞了！", "y-you poked my head clean off!"]],
  "reviewDone": [
    ["今天的份都做完啦！♡", "all done for today! ♡"],
    ["辛苦了～来摸摸头？", "good work~ head pat?"],
    ["做完了！我们去玩吧。", "done! let's go play."],
    ["你真的做到了，我好开心。", "you really did it. I'm so happy."]
  ],
  "notify_sweet": [
    ["还有{due张}在等你哦～我也在等你。", "{due} cards are waiting~ and so am I."],
    ["今天也想见你。一起学习吧？", "I want to see you today too. study with me?"]
  ],
  "notify_clingy": [
    ["你在哪里？快回来陪我……还有{due张}。", "where are you? come back to me… {due} cards left."],
    ["我好想你。就来一下下嘛。", "I miss you. just come for a little bit."]
  ],
  "notify_bratty": [
    ["喂，{due张}卡还没做。我可没在等你哦。", "hey, {due} cards aren't done. not that I'm waiting."],
    ["哼，你不会是忘了我吧？", "hmph. you didn't forget about me, did you?"]
  ],
  "notify_spacey": [
    ["……啊，对了，还有{due张}卡。", "…oh, right. {due} cards."],
    ["我刚才在发呆……然后想到了你。", "I was spacing out… and then I thought of you."]
  ],
  "notify_1": [
    ["今天也一起学习吧？", "study with me today?"],
    ["昨天没见到你……今天会来吧？", "didn't see you yesterday… you'll come today, right?"]
  ],
  "notify_2": [
    ["……你昨天没来。", "…you didn't come yesterday."],
    ["两天了。我有点担心你。", "two days. I'm a little worried."]
  ],
  "notify_3": [
    ["哼。卡片都堆起来了。", "hmph. the cards are piling up."],
    ["我不理你了。……除非你回来。", "I'm not talking to you. …unless you come back."]
  ],
  "notify_5": [
    ["……", "…"],
    ["我还在这里。", "I'm still here."]
  ]
};
