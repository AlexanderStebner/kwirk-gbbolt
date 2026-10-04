# From power-on to the first stairs

What the code does between switching the Game Boy on and Kwirk the tomato climbing the
stairs of floor 1, in the order it happens.

## Power on

The CPU starts at `Boot`, which jumps straight to `Start`. That routine does the usual
Game Boy chores in a few lines:

- `DisableLCD` waits for VBlank and switches the screen off, so VRAM can be written freely.
- `CopyOAMDMARoutine` copies a 10-byte routine into HRAM (`hOAMDMA`). During a sprite DMA
  the CPU can only run code from HRAM, so every game carries this little routine.
- All 8 KB of work RAM are cleared, the palettes are set to `$9C` and the VBlank and serial
  interrupts are switched on.

Then comes `Restart`, the place the game returns to after every link game: it silences the
sound (`InitSound`), clears the sprites and the tile buffer, and loads the title graphics
(`LoadTitleTiles`). The font is stored at 1 bit per pixel, and `Copy1bpp` expands it into
real 2-bit tiles on the way into VRAM.

## There is no main loop

Many games are built around a main loop that runs one state handler per frame. Kwirk
has none: the whole game is one long thread of ordinary code, which calls `WaitVBlank`
whenever it wants the next frame.

Meanwhile the `VBlankHandler` does the per-frame work behind its back:

- the sprite DMA through `hOAMDMA`;
- one tick of the sound engine (`UpdateSound`);
- the play clock (`wClockSeconds`, `wClockMinutes`);
- one of ten link-cable handlers, chosen by a bit of `wLinkState` (see the `link/vblank` folder).

Sounds are requested with a one-byte instruction: `rst $30` lands in `QueueSound`, which
puts the id into a two-entry queue that the engine picks up on the next frame.

## The title screen

`TitleScreen` starts the title music (`QueueSound(5)`) and prints the screen as text:
`TitleLogoText`, `PushStartText` and the copyright lines. Even the big KWIRK logo is a
"string", where `$AA` means newline and `$BB` ends it (`PrintText`).

`TitleScreenLoop` runs every 10 frames and waits for START. While it waits it also offers
the link cable a game (`SerialOfferTitle`), in case a second Game Boy is connected.

Wait 17 seconds instead and `TitleDemoTimer` starts the demo. It isn't a recording of a
player: `DemoInput` feeds the game d-pad steps packed 2 bits each from `DemoInputs`,
through five rooms listed in `DemoLevels`. Watch it in [the demo replay](demo-replay).

## Menus

Every menu (game, skill, floor, display, course length) goes through one generic chooser,
`MenuChoose`. It knows rows, columns and a blinking cursor, and it can also take the
choice from a link partner.

The choices end up in a few bytes of RAM:

- `wGameMode`: GOING UP?, HEADING OUT? or VS MODE;
- `wSkill`;
- `wRoom`: for GOING UP? this is simply skill x 10 + floor (`SelectFloorMenu`);
- `wDiagonalView`: the diagonal or the bird's-eye view.

`StartPrompt` shows the last screen and hands over to `StartGame`.

## Building room 0

`StartGame` falls into `NewLevel`, which falls into `SetUpLevel`. Its first call is
`BuildRoom`, the heart of the level data:

- `RoomHeaders` gives the room's size: floor 1 is 16 x 3 squares, centred on the 20 x 18
  screen.
- `RoomBits` is a bit map with one bit per square. A 0 is floor.
- A 1 takes the next byte of the object stream in `RoomObjects`. `DecodeRoomObject` reads
  its high nibble: a wall or a character, a block of any size (`DrawBlock`), a hole or the
  stairs, or a turnstile (`DrawTurnstile`).
- Last, `ShapeWall` gives every wall square the right tile for the walls around it.

Everything is drawn into `wTileBuffer`: one byte per screen square, where the high nibble
says what is there (floor, block, hole, turnstile arm, character, wall). From now on the
game logic only looks at this buffer. `FindCharacters` scans it for the characters and the
stairs, and `ShowRoom` wipes it onto the screen. See all 150 rooms in
[the rooms table](rooms-going-up).

## One frame of play

`PlayRoom` starts the music and falls into `GameLoop`, which runs once per frame:

- `ReadJoypad`, then `MoveFromJoypad` turns the d-pad into `wMoveDir`.
- `TryStep` looks at the square ahead in `wTileBuffer`. A wall, a hole or another character
  means a bump (sound 9). A block asks `CanPushBlock`; a turnstile arm asks
  `TryTurnTurnstile`, which checks every square the arms would sweep through.
- A step that works takes 8 frames of 1 pixel (`StepFrame`). A pushed block or turnstile is
  lifted out of the buffer and slides along as sprites (`ObjectToSprites`), then it is
  drawn back into the background at its new place.
- A block pushed completely over holes fills them (`FillHoles`).
- Before every push or turn, GOING UP? saves the whole room (`SaveUndo`) into an 8-slot ring, which
  is what BACK in the pause window undoes (`Undo`).

## The stairs

When Kwirk steps onto the stairs (tile `$10`), `CheckStairs` takes him off the board. If a
floor has more than one character, `NextCharacter` hands control to the next one: all of
them have to get out.

With nobody left, `CheckRoomCleared` takes over: `FlashOrNextRoom` flashes the screen nine
times, then YOU DID IT shows the time and the steps you took (`PrintStepCount`). START leads
back to `StartPrompt`, for floor 2.

After floor 10, Kwirk walks home to his girlfriend (`GoHomeScene`). Watch it in
[the ending video](skill-cleared).
