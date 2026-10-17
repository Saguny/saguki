// Everything Zero says: [Chinese, English subtitle]. Numbers go in as {due张} / {today张} /
// {days天} / {hour点} in Chinese and {due} / {today} / {days} / {hour} in English.
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
    ["♪ 汉字、假名、单词卡～", "♪ kanji, kana, flashcards~"],
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
  "unlock_down": [["哇，可以把头发放下来了！", "ooh, hair down!"]],
  "unlock_short": [["哇，短发！", "ooh, short hair!"]],
  "unlock_bun": [["哇，小丸子头！", "ooh, a little bun!"]],
  "unlock_chibi": [["哇，Q版的我！", "ooh, chibi me!"]]
};
