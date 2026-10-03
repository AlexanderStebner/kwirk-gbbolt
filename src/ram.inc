; Named RAM / IO addresses.
; Format: DEF name EQU $addr ;@ type description
;   type: u8 | u16 (little endian) | u8[N] | code[N] | const
; Lines without ";@" are plain constants.

DEF hCoordY EQU $FF8D ;@ u8 Y coordinate in OAM space (screen y + 16)
DEF hCoordX EQU $FF8E ;@ u8 X coordinate in OAM space (screen x + 8)
DEF vTiles0 EQU $8000 ;@ const Tile data block 0
DEF vTiles1 EQU $8800 ;@ const Tile data block 1
DEF vTiles2 EQU $9000 ;@ const Tile data block 2
DEF vBGMap0 EQU $9800 ;@ const BG tile map 0 (32x32 tiles)
DEF vBGMap1 EQU $9C00 ;@ const BG tile map 1 (32x32 tiles)
DEF WORK_RAM0 EQU $C000 ;@ const Work RAM, first 4 KB ($C000-$CFFF)
DEF WORK_RAM1 EQU $D000 ;@ const Work RAM, second 4 KB ($D000-$DFFF)
DEF OAM_START EQU $FE00 ;@ const Object attribute memory (40 sprites x 4 bytes)
DEF HRAM_START EQU $FF80 ;@ const High RAM ($FF80-$FFFE)
DEF WAVE_RAM EQU $FF30 ;@ const Wave pattern RAM of sound channel 3 (32 4-bit samples)
DEF BTN_A EQU $01 ;@ const hJoyHeld / hJoyPressed bit
DEF BTN_B EQU $02 ;@ const
DEF BTN_SELECT EQU $04 ;@ const
DEF BTN_START EQU $08 ;@ const
DEF BTN_RIGHT EQU $10 ;@ const
DEF BTN_LEFT EQU $20 ;@ const
DEF BTN_UP EQU $40 ;@ const
DEF BTN_DOWN EQU $80 ;@ const
DEF hBGMapAddrLo EQU $FF90 ;@ u8 Low byte of the address in hBGMapAddrHi
DEF hJoyHeld EQU $FF8B ;@ u8 Buttons held (d-pad in the high nibble: Right $10, Left $20, Up $40, Down $80; A $01, B $02, Select $04, Start $08)
DEF hJoyPressed EQU $FF8C ;@ u8 Buttons pressed since the last ReadJoypad
DEF hSavedIE EQU $FF92 ;@ u8 rIE saved while DisableLCD waits for VBlank
DEF hBGMapAddrHi EQU $FF8F ;@ u8 High byte of an address (BufferAddrToCoords: in wTileBuffer)
DEF wTileBuffer EQU $C100 ;@ u8[360] The screen's tiles, 20 x 18, row by row (what is in the BG map's visible part)
DEF hOAMDMA EQU $FF80 ;@ code[10] Copy of OAMDMARoutine in HRAM (CopyOAMDMARoutine puts it there)
DEF hVBlankDone EQU $FF91 ;@ u8 Set to 1 by the VBlank handler; WaitVBlank waits for it
DEF wClockFrames EQU $C2EC ;@ u8 Play clock: frames of the current second (0-59), counted by the VBlank handler
DEF wClockSeconds EQU $C2ED ;@ u8 Play clock: seconds (BCD, 0-59)
DEF wClockMinutes EQU $C2EE ;@ u8 Play clock: minutes (BCD, stops at 60)
DEF wClockSecondsTotal EQU $C2EF ;@ u8 Seconds counted by the play clock (stops at 255)
DEF wTitleBlink EQU $C381 ;@ u8 Flips every 10 frames on the title screen (not read)
DEF wDemo EQU $CF43 ;@ u8 Set while the demo plays
DEF wGameMode EQU $C2B8 ;@ u8 0 = GOING UP?, 1 = HEADING OUT?, 2 = VS MODE (also the demo plays as 1)
DEF wDemoStep EQU $CEDC ;@ u16 Demo: index of the next 2-bit input in DemoInputs
DEF wBoxLeft EQU $CF07 ;@ u8 DrawBox: tile of a row's left end (PrintText keeps a raised tile here too)
DEF wBoxMiddle EQU $CF09 ;@ u8 DrawBox: tile of a row's middle
DEF wBoxRight EQU $CF0B ;@ u8 DrawBox: tile of a row's right end
DEF wSoundQueueCount EQU $DF80 ;@ u8 Number of sound ids queued for the sound engine (at most 2)
DEF wSoundQueue EQU $DF81 ;@ u8[2] Sound ids queued by QueueSound
DEF wDemoRun EQU $CEDE ;@ u8 Demo: which of the DemoLevels plays next
DEF wSkill EQU $C2C0 ;@ u8 The skill level chosen (0-2)
DEF wRoom EQU $C2BF ;@ u8 The room (puzzle) to play next: for GOING UP? skill * 10 + floor
DEF wDiagonalView EQU $C2BE ;@ u8 1 = diagonal view, 0 = bird's-eye view
DEF wContestGames EQU $C2BD ;@ u8 VS MODE: games in the contest (1, 3, 5, 7 or 9)
DEF wMenuChoice EQU $CF19 ;@ u8 MenuChoose: the choice (column * rows + row), $FF = B, $F0 = the link partner started
DEF wMenuCursorTile EQU $CF0F ;@ u8 MenuChoose: the cursor's tile
DEF wMenuLastCol EQU $CF11 ;@ u8 MenuChoose: the last column (0 = one column)
DEF wMenuLastRow EQU $CF12 ;@ u8 MenuChoose: the last row
DEF wMenuLastColRows EQU $CF13 ;@ u8 MenuChoose: the last row of the last column
DEF wMenuRowStep EQU $CF17 ;@ u8 MenuChoose: BG map bytes from one row to the next
DEF wMenuColStep EQU $CF18 ;@ u8 MenuChoose: BG map bytes from one column to the next
DEF wMenuLinkTimer EQU $CF06 ;@ u8 MenuChoose: frames until the title byte is offered to the link partner again
DEF wCourseIndex EQU $C374 ;@ u8 HEADING OUT?: index of the current room in wCourseRooms
DEF wCourseRooms EQU $C311 ;@ u8[99] HEADING OUT?: the rooms of the course, drawn at random by BuildCourse
DEF wShadowOAM EQU $C000 ;@ u8[160] Shadow OAM: 40 sprites (y, x, tile, attributes), copied to OAM by the VBlank handler
DEF wCharacter EQU $C2D1 ;@ u8 The character being moved (0-3; some floors have several)
DEF wCharTilePtrs EQU $C2D4 ;@ u16[4] Each character's address in wTileBuffer
DEF wCharCoords EQU $C2DC ;@ u8[8] Each character's sprite position (x, y) in OAM space; x = 0: no character
DEF wMoveDir EQU $C2D2 ;@ u8 The d-pad direction of the move: 1 up, 2 right, 3 down, 4 left, 0 none
DEF wCharAttr EQU $C2D3 ;@ u8 OAM attributes of the moving character (bit 5: facing right)
DEF wMoveDX EQU $C2E8 ;@ u8 Pixels a frame the character moves right ($FF = left)
DEF wMoveDY EQU $C2E9 ;@ u8 Pixels a frame the character moves down ($FF = up)
DEF wStepFrames EQU $C2E7 ;@ u8 Frames left of the current step (8 a tile)
DEF wStepTiles EQU $C2CE ;@ u8 Tiles the current step covers (1, or 2 at double pace)
DEF wAnimTimer EQU $C2E6 ;@ u8 Frames to the next walk animation of the character (and blink of the palette)
DEF wStepCount EQU $C2EA ;@ u16 Steps taken in the room (4 BCD digits)
DEF wStepping EQU $CF34 ;@ u8 Set while a step is under way
DEF wStepOK EQU $CF31 ;@ u8 Set when the step just tried can be made
DEF wStepKind EQU $CF35 ;@ u8 What the step moves: 3 = only the character, 1 = a block, 2 = a turnstile, 0 = nothing (blocked)
DEF wTileAhead EQU $C2CF ;@ u8 Kind (high nibble) of the tile the character tried to step on ($10 = the stairs)
DEF wCharsLeft EQU $C2D0 ;@ u8 Characters still in the room; 0 = the room is cleared
DEF wCharExited EQU $CF32 ;@ u8 Set when a character has reached the stairs
DEF wRoomDone EQU $CF33 ;@ u8 Set when the room is cleared (PlayRoom returns)
DEF wBLatch EQU $CF47 ;@ u8 With B held: set after one step, cleared when the d-pad is let go
DEF wCourseLength EQU $C2B9 ;@ u8 HEADING OUT?: rooms in the course
DEF wCourseRoom EQU $C2BB ;@ u8 HEADING OUT?: number of the room being played (1 = the first)
DEF wObjPtr EQU $C2F6 ;@ u16 The block or turnstile being moved: the top left corner of its rectangle in wTileBuffer
DEF wObjWidth EQU $C2F8 ;@ u8 The moving rectangle's width in tiles
DEF wObjHeight EQU $C2F9 ;@ u8 The moving rectangle's height in tiles
DEF wObjTiles EQU $C29A ;@ u8[30] The moving rectangle's buffer tiles, lifted out of wTileBuffer while it moves
DEF wObjBGTiles EQU $C27C ;@ u8[30] The moving rectangle as BG tile numbers (one row more in the diagonal view)
DEF wSinkFrame EQU $CF1B ;@ u8 Fill-the-hole animation: frames left (counts down to 0)
DEF wSinkTile EQU $CF1C ;@ u8 Fill-the-hole animation: the buffer tile being drawn
DEF wObjSprite EQU $CF1D ;@ u8 The next OAM slot used for the moving rectangle's sprites
DEF wObjSpriteX EQU $CF1F ;@ u8 The moving rectangle's left edge in pixels (sprites start each row there)
DEF wStairsX EQU $C2E4 ;@ u8 The stairs' sprite position in OAM space: x
DEF wStairsY EQU $C2E5 ;@ u8 The stairs' sprite position in OAM space: y
DEF wRoomPoints EQU $C2F0 ;@ u8 HEADING OUT?: points a cleared room adds to wScore (BCD, hundreds)
DEF wScore EQU $C2F1 ;@ u16 HEADING OUT?: the score in hundreds (4 BCD digits; shown with two zeros after it)
DEF wBarTotal EQU $C37F ;@ u8 Progress bar: the full count (DrawProgressBar)
DEF wBarLeft EQU $C380 ;@ u8 Progress bar: the count left (DrawProgressBar takes one off first)
DEF wUndoChar EQU $C382 ;@ u8[8] Undo ring: the character that moved, per slot
DEF wUndoCharPos EQU $C38A ;@ u8[16] Undo ring: that character's square in wTileBuffer before the move (a word per slot)
DEF wUndoBuffers EQU $C39A ;@ u8[2880] Undo ring: 8 copies of wTileBuffer, one per slot
DEF wUndoSlot EQU $CEDA ;@ u8 Undo ring: the slot SaveUndo writes next (0-7)
DEF wUndoCount EQU $CEDB ;@ u8 Undo ring: moves that can be taken back (up to 8)
DEF wUndoOn EQU $CF37 ;@ u8 Set when BACK can take a move back
DEF wNoLeadYet EQU $CF38 ;@ u8 PrintBCDNoLead: set while only zeros have been printed (they print as blanks)
DEF wBarRow EQU $CF21 ;@ u8 DrawProgressBar: the bar's row (0 = the first bar)
DEF wBarLength EQU $CF22 ;@ u8 DrawProgressBar: the bar's length in half tiles (16 = full)
DEF wBarPtr EQU $C2FB ;@ u16 DrawProgressBar: the BG map address of the bar's first tile
DEF wSplitSCX EQU $CEFF ;@ u8 The SCX of the screen's middle band while a room scrolls in (0 otherwise)
DEF wRandom EQU $CF28 ;@ u8[4] Random's state (BuildCourse seeds all four bytes with wCourseSeed)
DEF wRecentRooms EQU $C2FD ;@ u8[20] The last 20 rooms of the previous course: BuildCourse does not deal them again
DEF wCourseSeed EQU $C377 ;@ u8 Seed of the course (wClockFrames when chosen; the link master sends it to the partner)
DEF wSerialOut EQU $C375 ;@ u8 The byte SerialSend sends to the link partner
DEF wSerialIn EQU $C376 ;@ u8 The byte SerialInterrupt received last
DEF wLinkState EQU $CF3A ;@ u8 Link step: one bit set picks what the VBlank handler and SerialInterrupt do (0 = nothing)
DEF wLinkMaster EQU $CF3C ;@ u8 1 = this Game Boy sends (internal clock) or plays alone; 0 = it follows the partner
DEF wLinkActive EQU $CF3D ;@ u8 1 = a link partner may be there (SerialSend only sends then)
DEF wLinkDone EQU $CF39 ;@ u8 Set when the link step of this frame is done (a byte arrived, or the VBlank handler sent one)
DEF wVsPartnerLength EQU $C2BA ;@ u8 VS MODE: rooms in the partner's course
DEF wVsPartnerRoom EQU $C2BC ;@ u8 VS MODE: the room the partner plays (sent over the link)
DEF wLinkHandshake EQU $CF46 ;@ u8 Set during the handshake at the end of a VS game (SerialInterrupt then only stores the byte)
DEF wYouWins EQU $C378 ;@ u8 VS MODE: games of the contest this Game Boy has won
DEF wOppWins EQU $C379 ;@ u8 VS MODE: games of the contest the partner has won
DEF wOppClearedLast EQU $C37A ;@ u8 VS MODE: 1 when the partner cleared the last game first ($FF while ContestCheck shows the dizzy scene for it)
DEF wCourseOnes EQU $C37B ;@ u8 CourseMenu: the ones digit of the course length being chosen
DEF wCourseTens EQU $C37C ;@ u8 CourseMenu: the tens digit of the course length being chosen
DEF wCourseLengthSave EQU $C37D ;@ u8 wCourseLength as chosen in the menus (restored for the next contest)
DEF wPartnerLengthSave EQU $C37E ;@ u8 wVsPartnerLength as chosen in the menus (restored for the next contest)
DEF wContinue EQU $CF40 ;@ u8 Set when A or START (here or on the partner's Game Boy) ends a results scene of link state $40
DEF wSoundChannels EQU $DF00 ;@ u8[128] The sound engine's 8 channels, 16 bytes each: 0-3 music (square 1, square 2, wave, noise), 4-7 the sound effects on the same 4 voices. Bytes: 0 flags (bit 0 plays, 1 rest, 2 sweep on, 7 an effect holds the voice), 1 note timer, 2 envelope step timer, 3-4 envelope pointer, 5 volume drop, 6 pitch offset, 7 transpose, 8-9 stream pointer, 10 note length, 11 duty, 12-13 frequency (bit 15 = retrigger), 14-15 envelope start
DEF wSoundChannel EQU $DF83 ;@ u8 The channel the sound engine reads the stream of (0-7)
DEF wMusicSweep EQU $DF84 ;@ u8 The music's square 1 sweep (rNR10), put back when a square 1 effect ends
DEF wEffectWave EQU $DF85 ;@ u16 The wave an effect channel picked (command $FC), loaded into wave RAM when that effect ends
DEF wChannelPan EQU $DF87 ;@ u8[8] Per channel: its rNR51 bits (left and/or right), from the pan commands $C0-$DF
DEF wChannelVolume EQU $DF8F ;@ u8[8] Per channel: the volume byte last written to its rNRx2 (envelope step minus the volume drop)
DEF wSoundReturn EQU $DF97 ;@ u8[16] Per channel: the stream address a $F6 call returns to (2 bytes each)
DEF wSoundRepeat EQU $DFA7 ;@ u8[24] Per channel: a $F4 repeat, 3 bytes each: the count left and the stream address to go back to
DEF wRanking EQU $CEDF ;@ u8[12] HEADING OUT? ranking: four entries (score high and low byte, BCD hundreds; rooms of the course), the best first
DEF wRankNew EQU $CEEB ;@ u8[3] HEADING OUT? ranking: the course just played as an entry, which RankCourse sorts in from below
DEF wRankSwap EQU $CEEE ;@ u8[3] RankSwap: one entry, kept while two are swapped
DEF wRankClimb EQU $CEF1 ;@ u8 Places the course just played climbed in the ranking (0 = not in it, 4 = the best)
DEF wRankingSaved EQU $CEF2 ;@ u8[12] The player's ranking, kept while the demo shows DemoRanking
DEF wLinkAnswerWait EQU $CF48 ;@ u8 1 while the main menu waits for the partner's answer to its start offer (the VBlank handler runs LinkFrameAnswer)
DEF wTitleOfferOff EQU $CF49 ;@ u8 1 = SerialStop: the VBlank handler no longer offers the title byte to a link partner
DEF wGiveUp EQU $CF41 ;@ u8 $80 when the player gave up the room with A (HEADING OUT?/VS); sent to the partner with the room number
DEF wPartnerStarted EQU $CF42 ;@ u8 1 when the link partner started the game (the title screen and main menu follow it)
DEF wInStartPrompt EQU $CF44 ;@ u8 $FF while the START prompt before a game is up (EndMenu then goes straight to MenusDone)
DEF wAllRooms EQU $CF45 ;@ u8 Set ($28) by AllRoomsCourse: the course is every room of the skill, no course menu
DEF wUnusedCF3E EQU $CF3E ;@ u8 Cleared in many places, never read
DEF wVsLost EQU $CF3F ;@ u8 1 when the link partner cleared the course first (ResultsScreen)
DEF wMirror EQU $C2FA ;@ u8 1 = this HEADING OUT? room is drawn upside down (MirrorRoom); NextCourseRoom picks it at random
DEF wPartnerRoomSeen EQU $CF00 ;@ u8 Set when the partner's room number arrives; never read
DEF wCourseFinished EQU $CF01 ;@ u8 1 = this Game Boy finished the VS course and waits for the partner's answer
DEF wHandshakeOut EQU $CF02 ;@ u8 The byte the follower sends in the end-of-game handshake: $71 finished, $72 you won
DEF wHandshakeIn EQU $CF03 ;@ u8 The partner's byte in the end-of-game handshake
DEF wHandshakeGot EQU $CF04 ;@ u8 1 once SerialInterrupt stored wHandshakeIn
DEF wLinkRefused EQU $CF05 ;@ u8 1 when the partner did not answer the main menu's start offer: back to the main menu
DEF wDrawCharIndex EQU $CF1A ;@ u8 DrawCharacters: the character being drawn
DEF wWipeRows EQU $CF1E ;@ u8 WipeInRoom: pairs of rows still to draw
DEF wPauseTile39 EQU $CF24 ;@ u8 PauseWindow: sprite 39's tile, put back when the window closes
DEF wPauseTile38 EQU $CF25 ;@ u8 PauseWindow: sprite 38's tile, put back when the window closes
DEF wSavedSeconds EQU $CF26 ;@ u8 EndMenu: the clock's seconds, put back on return to the room
DEF wSavedMinutes EQU $CF27 ;@ u8 EndMenu: the clock's minutes, put back on return to the room
DEF wRoomY EQU $CF08 ;@ u8 BuildRoom: the room's top row (also the high byte of SavePtr1's pointer)
DEF wRoomHeight EQU $CF0A ;@ u8 BuildRoom: the room's height (also the high byte of SavePtr2's pointer)
DEF wRoomBitsHi EQU $CF0C ;@ u8 BuildRoom: high byte of the RoomBits pointer (low byte in wBoxRight)
DEF wRightCorridor EQU $CF0D ;@ u8 BuildRoom: the right corridor's shape (HEADING OUT?)
DEF wRoomBitsByte EQU $CF0E ;@ u8 BuildRoom: the RoomBits byte being read
DEF wCellPtrHi EQU $CF10 ;@ u8 BuildRoom: high byte of the cell pointer (low byte in wMenuCursorTile)
DEF wBlockPtrHi EQU $CF14 ;@ u8 Room building: high byte of the block pointer (low byte in wMenuLastColRows)
DEF wObjInHole EQU $CF15 ;@ u8 1 while drawing an object that stands in a hole (+$10 tiles); CheckRoomCleared reuses it for the floor
