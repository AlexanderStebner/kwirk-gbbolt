"""Every room of Kwirk, drawn by the game itself: it enters each room the way StartGame
does and takes the screen once the room has scrolled in."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _game import Machine  # noqa: E402

GROUP = 'rooms'
SKILLS = ['LEVEL-1 EASY', 'LEVEL-2 AVERAGE', 'LEVEL-3 HARD']
SETTLE = 200                        # frames until the room has scrolled in and the characters stand


def enter(ctx, room, mode, view):
    """The screen of a room as the game shows it after entering it."""
    m = Machine(ctx)
    for _ in range(5):              # through Boot to the title screen
        m.frame()
    m.set('wGameMode', mode)
    m.set('wRoom', room)
    m.set('wDiagonalView', view)
    m.set('wSkill', room // 10 if mode == 0 else 0)
    m.set(0xCF3A, 0)                # no link state
    m.cpu.pc, m.cpu.sp = ctx.syms['StartGame'], 0xDCFF
    for _ in range(SETTLE):
        m.frame()
    return m.screen()


def crop(screen, x0, y0, w, h):
    """A tile rectangle of the screen as an image part."""
    rows = [bytes(screen[y][8 * x0: 8 * (x0 + w)]) for y in range(8 * y0, 8 * (y0 + h))]
    return {'width': 8 * w, 'height': 8 * h, 'pixels': rows}


def image(ctx, part):
    return {'width': part['width'], 'height': part['height'], 'pixels': ctx.pixels(part['pixels'])}


def going_up(ctx):
    headers = ctx.addr('RoomHeaders')
    rows = []
    for room in range(30):
        h = ctx.word(headers + 2 * room)
        w, ht = ctx.rom[h], ctx.rom[h + 1]
        x, y = (20 - w) // 2, (18 - ht) // 2
        views = [image(ctx, crop(enter(ctx, room, 0, v), x - 1, y - 1, w + 2, ht + 2)) for v in (1, 0)]
        rows.append([SKILLS[room // 10], 'FL-{}'.format(room % 10 + 1), room, '{} x {}'.format(w, ht),
                     {'image': views[0]}, {'image': views[1]}])
    return {
        'name': 'rooms-going-up', 'type': 'table', 'title': 'GOING UP? floors',
        'columns': ['skill', 'floor', 'room', 'size', 'diagonal view', "bird's-eye view"],
        'rows': rows,
        'doc': ['The 30 puzzle rooms of GOING UP?, 10 floors for each skill (room = skill x 10 + floor, '
                'SelectFloorMenu). Every picture is the game\'s own screen after StartGame has built the '
                'room (BuildRoom, which centres it on the 20 x 18 tile screen). RoomHeaders gives its width and '
                'height. RoomBits is a bit map with one bit per cell: 0 is floor, 1 takes the next byte of the '
                'object stream in RoomObjects. Its high nibble says what stands there: a wall or one of the '
                'characters (0), a block of a given width and height (1-8; the block is drawn whole from its top '
                'left cell), a hole or the stairs (A) or a turnstile, whose low nibble picks its arms (9, B-F). '
                'Last, ShapeWall gives every wall cell its tile from the walls around it. '
                'Some floors have more than one character: every one of them has to reach the stairs.',
                'The diagonal view draws the walls with a top face and the objects with shadows, the '
                'bird\'s-eye view flat (SelectDisplayMenu sets wDiagonalView).'],
        'users': ['BuildRoom', 'DecodeRoomObject', 'DrawBlock', 'DrawTurnstile', 'RoomHeaders', 'RoomBits', 'RoomObjects', 'SelectFloorMenu'],
    }


def heading_out(ctx):
    rows = []
    for room in range(30, 150):
        skill = 0 if room < 60 else 1 if room < 110 else 2
        shot = crop(enter(ctx, room, 1, 1), 0, 5, 20, 8)
        rows.append([SKILLS[skill], room, {'image': image(ctx, shot)}])
    return {
        'name': 'rooms-heading-out', 'type': 'table', 'title': 'HEADING OUT? rooms',
        'columns': ['skill', 'room', 'room as the game draws it'],
        'rows': rows,
        'doc': ['The 120 rooms HEADING OUT? and VS MODE deal from: rooms 30-59 for LEVEL-1, 60-109 for '
                'LEVEL-2 and 110-149 for LEVEL-3. BuildCourse draws a course of up to 99 of them at random '
                '(SkillRooms gives each skill its first room and count) and PickRoom adds the skill\'s '
                'first room. Each is 8 x 6 tiles between two corridors: the first byte of its RoomHeaders '
                'entry picks one of six corridor shapes for the way in and one for the way out (BuildRoom, '
                'the shapes in CorridorShapes, 4 x 4 cells each), and on some rooms MirrorRoom turns the room upside down ($C2FA). '
                'Kwirk starts at the far end of the right corridor and leaves by the left one. Shown without mirroring, in the diagonal view.'],
        'users': ['BuildRoom', 'CorridorShapes', 'MirrorRoom', 'BuildCourse', 'SkillRooms', 'PickRoom', 'RoomHeaders'],
    }


def build(ctx):
    return [going_up(ctx), heading_out(ctx)]
