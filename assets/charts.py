"""Charts of Kwirk's numbers, read from the ROM's tables."""

GROUP = 'charts'


def bonus_chart(ctx):
    times, points = ctx.addr('BonusTimes'), ctx.addr('BonusPoints')
    steps = [(ctx.rom[times + i], ctx.rom[points + i]) for i in range(15)]

    def value(b):                       # BCD hundreds, a high digit $F is a blank
        hi, lo = b >> 4, b & 0x0F
        return 100 * ((0 if hi == 0x0F else hi) * 10 + lo)

    pts, d = [], 0
    for t in range(0, 91):
        while d < 15 and steps[d][0] < t:
            d += 1
        pts.append([t, value(steps[d][1]) if d < 15 and t < 80 else 0])
    return {
        'name': 'chart-room-bonus', 'type': 'chart', 'kind': 'step', 'title': 'Room bonus',
        'subtitle': 'HEADING OUT?: points for a room, by the seconds it took',
        'x': 'seconds on the play clock', 'y': 'bonus points',
        'series': [{'name': 'bonus', 'points': pts}],
        'doc': ['In HEADING OUT? and VS MODE the BONUS box counts down while Kwirk works on a room '
                '(UpdateBonus, from wClockSecondsTotal): 2000 points for the first 5 seconds, then '
                '1800, 1600, 1400, 1200, 1000 and down to 100 in steps of 100, and nothing after '
                '79 seconds. The steps get longer as the bonus falls: 2 seconds each at first, '
                '10 seconds at the end (BonusTimes, BonusPoints). AddRoomPoints adds the bonus '
                'to the score when the room is cleared.'],
        'users': ['UpdateBonus', 'BonusTimes', 'BonusPoints', 'AddRoomPoints'],
    }


def build(ctx):
    return [bonus_chart(ctx)]
