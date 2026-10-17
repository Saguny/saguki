"""Pre-generates Zero's voice (Microsoft's Xiaoyi via edge-tts) into assets/zero/voice/.

    pip install edge-tts
    python tool/zero_voice.py          # from app/; only (re)makes clips whose text changed

Each line in assets/zero/lines.js is split around its number placeholders, e.g.
"还有{due张}在等你" -> sleepy_0_0.mp3 ("还有") + zhang_42.mp3 + sleepy_0_1.mp3 ("在等你"),
and index.html plays the pieces back to back. The split and the "is there anything to say"
test must match voiceClips() in index.html.
"""
import asyncio, json, os, re, sys

import edge_tts

VOICE = 'zh-CN-XiaoyiNeural'
ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'zero')
OUT = os.path.join(ROOT, 'voice')
HOLE = re.compile(r'\{(?:due|today|days|hour)[张天点]\}')
SILENT = re.compile(r'[♡♪～~…！？!?。，、,.\s]')
NUMBERS = {'zhang': ('张', range(1000)), 'tian': ('天', range(100)), 'dian': ('点', range(24))}


def clips():
    src = open(os.path.join(ROOT, 'lines.js'), encoding='utf-8').read()
    lines = json.loads(src[src.index('\nconst LINES =') + 14:src.rindex(';')])
    want = {}
    for pool, entries in lines.items():
        for i, (zh, _) in enumerate(entries):
            for k, part in enumerate(HOLE.split(zh)):
                if SILENT.sub('', part):
                    want[f'{pool}_{i}_{k}.mp3'] = part.replace('♡', '').replace('♪', '').strip()
    for name, (unit, ns) in NUMBERS.items():
        for n in ns:
            want[f'{name}_{n}.mp3'] = f'{n}{unit}'
        want[f'{name}_many.mp3'] = f'好多{unit}'
    return want


async def main():
    os.makedirs(OUT, exist_ok=True)
    manifest_path = os.path.join(OUT, 'manifest.json')
    try:
        done = json.load(open(manifest_path, encoding='utf-8'))
    except FileNotFoundError:
        done = {}
    want = clips()
    todo = [f for f, text in want.items() if done.get(f) != text or not os.path.exists(os.path.join(OUT, f))]
    gate = asyncio.Semaphore(8)

    async def make(f):
        async with gate:
            for attempt in range(4):
                try:
                    await edge_tts.Communicate(want[f], VOICE).save(os.path.join(OUT, f))
                    done[f] = want[f]
                    return
                except Exception as e:  # the free endpoint throttles now and then
                    if attempt == 3:
                        print('failed', f, e, file=sys.stderr)
                    await asyncio.sleep(2 ** attempt)

    await asyncio.gather(*(make(f) for f in todo))
    for f in set(os.listdir(OUT)) - set(want) - {'manifest.json'}:
        os.remove(os.path.join(OUT, f))
        done.pop(f, None)
    json.dump({f: done[f] for f in sorted(done) if f in want}, open(manifest_path, 'w', encoding='utf-8'),
              ensure_ascii=False, indent=0)
    print(f'{len(todo)} made, {len(want)} clips total')


if __name__ == '__main__':
    asyncio.run(main())
