# Kwirk (Game Boy) - gbbolt disassembly

**Open it: <https://gbbolt.lingora.org/kwirk/>**

A complete, matching disassembly of *Kwirk* for the Game Boy (Atlus / Acclaim, 1989),
with pseudo-code written next to every function and checked against the original code
in an emulator. It is read with [gbbolt](https://github.com/gbbolt/gbbolt):
code and pseudo-code side by side, linked line by line.

- **300 of 300 functions** have pseudo-code. 140 are verified by differential testing:
  the pseudo-code and the original code give identical results on 64 random machine
  states. The other 160 are checked: they wait for HBlank, VBlank or an LCD line, talk
  to the link cable or never return, so they can't run in isolation.
- **Every routine and RAM variable is named**, and every function sits in a virtual
  folder (`room/objects`, `game/move`, `game/turnstile`, `link/vblank`, `sound/engine`, ...).
- **All 150 rooms, drawn by the game itself**: the 30 floors of GOING UP? in the
  diagonal and the bird's-eye view, and the 120 rooms HEADING OUT? and VS MODE deal
  their courses from. The room format is fully decoded: a bit map of the cells plus a
  stream of objects (walls, characters, blocks of any size, holes, stairs, turnstiles).
- **Sound**: the sound engine is fully annotated. All 5 songs and 12 sound effects are
  rendered from it, with a piano roll and mute / solo per channel.
- **Played by its own code** (asset plugins in `assets/`): the title demo, clearing the
  last floor of a skill (Kwirk walks home to his girlfriend) and losing a VS MODE
  contest (Kwirk sits dizzy), as videos recorded by running the game frame by frame.
  There is also the title screen and a chart of the room bonus.

Some things the code shows:

- A HEADING OUT? course is up to 99 random rooms. A room that came up among the 20
  before it is dealt again, and the last 20 rooms are remembered for the next course.
- Holding SELECT+LEFT when HEADING OUT? starts plays every room of the skill in order.
- Some HEADING OUT? rooms are mirrored at random, but upside down, not left to right.
- In GOING UP? the pause window's BACK undoes moves: an 8-slot ring of whole room copies.
- The room bonus starts at 2000 points and runs out after 79 seconds. Its steps get
  longer as it falls.
- A bug: on the VS MODE results screen the partner's room count is written into ROM,
  so it never shows.

## Building

The disassembly rebuilds the original ROM byte for byte. You need
[RGBDS](https://rgbds.gbdev.io) 1.0.1, Python 3.9+ with numpy, and gbbolt next to this
folder:

```
git clone https://github.com/gbbolt/gbbolt
git clone https://github.com/gbbolt/kwirk-gbbolt
cd kwirk-gbbolt
python ../gbbolt/tools/audio.py             # render the music (needs ffmpeg)
python ../gbbolt/tools/gbbolt.py            # build, verify, write out/site/index.html
```

The build is checked against the SHA1 of the original ROM
(`6ef48e912a47c774048456aa870c7e810fd45685`, *Kwirk - He's A-maze-ing! (USA, Europe)*). No ROM is needed to
build it. If you put your own dump next to `game.json` as `kwirk.gb`, it is compared
byte by byte.

## Layout

```
game.json           what gbbolt needs to know about the game
src/game.asm        the main file
src/bank_000.asm    the disassembly with its annotations
src/ram.inc         RAM variables: names, types, descriptions
src/hardware.inc    hardware registers
src/folders.txt     the virtual folders
src/sound.json      how to drive the sound engine
assets/*.py         asset plugins: rooms, demo, endings, charts
```

## Legal

Kwirk and its code, graphics and music are the property of their respective owners
(Atlus; published by Acclaim). This repository contains no ROM. It is a research and
documentation project in the tradition of other community disassemblies; please buy
the game.

The annotations, names, pseudo-code, descriptions, plugins and configuration written for
this project are available under the MIT license (see [LICENSE](LICENSE)), as far as
they are separable from the game itself.
