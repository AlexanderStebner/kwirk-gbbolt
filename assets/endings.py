"""The scenes after a game, played by the game's own code: clearing the tenth floor of a
skill (Kwirk walks home to his girlfriend) and losing a VS MODE contest (Kwirk sits dizzy)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import Machine, FRAME_HZ  # noqa: E402

GROUP = 'replays'


def start_room(ctx, room, mode):
    """A machine in the middle of a room, entered the way StartGame does it."""
    m = Machine(ctx, spin_loops=('LinkWait',))
    for _ in range(5):
        m.frame()
    m.set('wGameMode', mode)
    m.set('wRoom', room)
    m.set('wDiagonalView', 1)
    m.set('wSkill', room // 10 if mode == 0 else 0)
    m.set('wLinkState', 0)
    m.cpu.pc, m.cpu.sp = ctx.syms['StartGame'], 0xDCFF
    for _ in range(200):
        m.frame()
    m.set('wLinkMaster', 1)          # no partner: this Game Boy reads the buttons itself
    return m


def jump(m, name):
    """Leave the game loop for a routine that drops its return address."""
    m.cpu.sp -= 2
    m.mem[m.cpu.sp] = m.mem[m.cpu.sp + 1] = 0
    m.cpu.pc = m.ctx.syms[name]


def record(m, n, presses):
    frames = []
    for f in range(n):
        m.buttons = 0x08 if any(p <= f < p + 3 for p in presses) else 0     # START
        m.frame()
        frames.append(m.screen())
    return frames


def video(ctx, name, title, frames, poster, doc, users):
    return {
        'name': name, 'type': 'video', 'title': title,
        'subtitle': '{} frames, {:.0f} s'.format(len(frames), len(frames) / FRAME_HZ),
        'file': ctx.video(frames, name), 'poster': ctx.poster(frames[poster], name),
        'width': 160, 'height': 144, 'fps': FRAME_HZ, 'doc': doc, 'users': users,
    }


def floor_ten(ctx):
    m = start_room(ctx, 9, 0)                    # LEVEL-1, FL-10
    m.set('wCharsLeft', 0)
    jump(m, 'CheckRoomCleared')
    frames = record(m, 960, (150, 900))
    return video(ctx, 'skill-cleared', 'LEVEL-1 cleared', frames, 700, [
        'What happens after the tenth floor of a skill, from the moment the last character '
        'reaches the stairs: the room flashes nine times (FlashOrNextRoom), YOU DID IT shows the '
        'skill, the floor, the time and the steps until START (CheckRoomCleared), then '
        'SkillClearedText says AWESOME! and GoHomeScene walks Kwirk to his house, where his '
        'girlfriend comes out under a blinking heart. START leads to the next skill\'s first floor.',
        'Played by the game\'s own code, entering LEVEL-1 FL-10 and clearing it at once; START is '
        'pressed twice.'],
        ['CheckRoomCleared', 'FlashOrNextRoom', 'DrawResultsScreen', 'SkillClearedText', 'GoHomeScene',
         'GirlfriendSprites', 'KwirkCheerSprites', 'HeartSprites', 'HouseText'])


def contest_lost(ctx):
    m = start_room(ctx, 30, 2)                   # VS MODE, LEVEL-1
    for name, v in (('wContestGames', 3), ('wYouWins', 0), ('wOppWins', 2), ('wVsLost', 1),
                    ('wCourseLength', 10), ('wVsPartnerLength', 10), ('wOppClearedLast', 1)):
        m.set(name, v)
    jump(m, 'ContestLost')
    frames = record(m, 600, ())
    return video(ctx, 'contest-lost', 'VS MODE contest lost', frames, 560, [
        'The end of a lost VS MODE contest: on the results screen Kwirk bobs in front of his house '
        '(ContestLost), then DizzyScene sits him down dizzy under a blinking swirl until A or START. '
        'A contest is won by a majority of its games (ContestCheck).',
        'Played by the game\'s own code from ContestLost, with the scores of a lost best-of-3 '
        'set in RAM; there is no link partner.'],
        ['ContestLost', 'DizzyScene', 'ResultsScreen', 'KwirkDizzySprites', 'DizzySwirlSprites', 'ContestCheck'])


def build(ctx):
    return [floor_ten(ctx), contest_lost(ctx)]
