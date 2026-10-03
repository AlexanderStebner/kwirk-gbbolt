"""The attract-mode demo, played by the game's own code from power-on."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import Machine, FRAME_HZ  # noqa: E402

GROUP = 'replays'
BUTTONS = [('Right', 0x10), ('Left', 0x20), ('Up', 0x40), ('Down', 0x80)]


def lanes(held):
    out = []
    for name, bit in BUTTONS:
        spans, start = [], None
        for f, b in enumerate(held + [0]):
            if b & bit and start is None:
                start = f
            elif not b & bit and start is not None:
                spans.append([start, f])
                start = None
        if spans:
            out.append({'name': name, 'spans': spans})
    return out


def build(ctx):
    m = Machine(ctx)
    title = None
    while not m.get('wDemo'):                   # the title screen: 17 seconds, then StartDemo
        m.frame()
        if m.frames == 300:
            title = m.screen()
    ctx.poster(title, 'title')                  # gen/demo_replay_title.png: the hub's thumbnail
    frames, held, rooms = [], [], []
    while m.get('wDemo'):
        m.frame()
        frames.append(m.screen())
        held.append(m.get('hJoyHeld'))
        if not rooms or rooms[-1] != m.get('wRoom'):
            rooms.append(m.get('wRoom'))
    for _ in range(60):                         # a second of the title screen it returns to
        m.frame()
        frames.append(m.screen())
        held.append(0)
    url = ctx.video(frames, 'demo')
    poster = ctx.poster(frames[600], 'demo')
    return [{
        'name': 'title-screen', 'type': 'image', 'title': 'Title screen',
        'width': 160, 'height': 144, 'pixels': ctx.pixels(title), 'scale': 2,
        'doc': ['The title screen as the game draws it, five seconds after power-on (TitleScreen): '
                'the KWIRK logo from TitleLogoText in the title tiles, PUSH START, and the copyright '
                'lines. After 17 seconds without a button TitleDemoTimer starts the demo.'],
        'users': ['TitleScreen', 'TitleLogoText', 'PushStartText', 'TitleDemoTimer'],
    }, {
        'name': 'demo-replay', 'type': 'video', 'title': 'Demo replay',
        'subtitle': '{} frames, {:.0f} s'.format(len(frames), len(frames) / FRAME_HZ),
        'file': url, 'poster': poster, 'width': 160, 'height': 144, 'fps': FRAME_HZ,
        'lanes': lanes(held),
        'doc': ['After 17 seconds on the title screen (TitleDemoTimer) StartDemo plays HEADING OUT? '
                'through five rooms of LEVEL-1: rooms {} from DemoLevels, one per run of the demo '
                '(wDemoRun). There is no recording of a player: DemoInput feeds the game a d-pad '
                'direction from DemoInputs, 2 bits a step (Down, Up, Left, Right), and holds it '
                'for 3 frames. A or START during the demo goes back to the title screen.'.format(
                    ', '.join(str(r) for r in rooms)),
                'Played here by the game\'s own code from power-on; the lanes under the video show '
                'the direction DemoInput holds in each frame.'],
        'users': ['StartDemo', 'DemoInput', 'DemoInputs', 'DemoLevels', 'EndDemo'],
    }]
