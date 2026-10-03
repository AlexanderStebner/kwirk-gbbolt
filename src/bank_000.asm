; Disassembly of "kwirk.gb"
; This file was created with:
; mgbdis v3.0 - Game Boy ROM disassembler by Matt Currie and contributors.
; https://github.com/mattcurrie/mgbdis

SECTION "ROM Bank $000", ROM0[$0]

;@ def RST_00()
;@ path: system/vectors
;@ Restart vector $00: a jump-table dispatcher (`rst $00` followed by a table of
;@ addresses). Kwirk never uses it.
;@ test: skip jumps through the caller's table
;@ sig: 8ec6e304
RST_00::
;> goto(JumpTable)
	jp JumpTable


	db $ff, $ff, $ff, $ff, $ff

RST_08::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

RST_28::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ def QueueSound(id: b)
;@ path: sound/queue
;@ `rst $30`: queues a sound id for the sound engine. The queue holds two
;@ ids; a third one is dropped.
;@ test: wSoundQueueCount = rand(0, 3)
;@ sig: eb03fb68
QueueSound::
;> count = u8(wSoundQueueCount + 1)
	ld hl, wSoundQueueCount
	ld a, [hl]
	inc a
;> if count >= 3: return                       # full
	cp $03
	ret nc

QueueSoundStore:
;> wSoundQueueCount = count
	ld [hl], a
;> mem[addr(wSoundQueueCount) + count] = id    # wSoundQueue[count - 1]
	add l
	ld l, a
	ld [hl], b
;> return
	ret


	db $ff, $ff, $ff

;@ def VBlankInterrupt()
;@ path: system/vectors
;@ Interrupt vector $40.
;@ test: skip interrupt vector
;@ sig: 2909b9ab
VBlankInterrupt::
;> goto(VBlankHandler)
	jp VBlankHandler


	db $ff, $ff, $ff, $ff, $ff

;@ def LCDCInterrupt()
;@ path: system/vectors
;@ Interrupt vector $48. Never enabled: a bare `reti`.
;@ test: skip interrupt vector
;@ sig: 1e5db4cd
LCDCInterrupt::
;> return   # reti
	reti


	db $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ def TimerOverflowInterrupt()
;@ path: system/vectors
;@ Interrupt vector $50. Never enabled: a bare `reti`.
;@ test: skip interrupt vector
;@ sig: 1e5db4cd
TimerOverflowInterrupt::
;> return   # reti
	reti


	db $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ def SerialTransferCompleteInterrupt()
;@ path: system/vectors
;@ Interrupt vector $58: the link cable's byte has been sent and received.
;@ test: skip interrupt vector
;@ sig: 74d274d1
SerialTransferCompleteInterrupt::
;> goto(SerialInterrupt)
	jp SerialInterrupt


	db $ff, $ff, $ff, $ff, $ff, $d9, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff

;@ def Boot()
;@ path: system/boot
;@ The entry point at $0100.
;@ test: skip never returns
;@ sig: 7f119ac7
Boot::
;> return Start()
	nop
	jp Start


HeaderLogo::
	db $ce, $ed, $66, $66, $cc, $0d, $00, $0b, $03, $73, $00, $83, $00, $0c, $00, $0d
	db $00, $08, $11, $1f, $88, $89, $00, $0e, $dc, $cc, $6e, $e6, $dd, $dd, $d9, $99
	db $bb, $bb, $67, $63, $6e, $0e, $ec, $cc, $dd, $dc, $99, $9f, $bb, $b9, $33, $3e

HeaderTitle::
	db "KWIRK", $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

HeaderNewLicenseeCode::
	db $00, $00

HeaderSGBFlag::
	db $00

HeaderCartridgeType::
	db $00

HeaderROMSize::
	db $00

HeaderRAMSize::
	db $00

HeaderDestinationCode::
	db $01

HeaderOldLicenseeCode::
	db $51

HeaderMaskROMVersion::
	db $00

HeaderComplementCheck::
	db $0d

HeaderGlobalChecksum::
	db $6d, $0a

;@ def Start()
;@ path: system/boot
;@ Power-on: LCD off, OAM DMA routine into HRAM, a blank screen, all of WRAM
;@ cleared, the palettes, VBlank and serial interrupts on, then Restart.
;@ writes: $FF93, wCourseLengthSave, wLinkActive, wPartnerLengthSave
;@ test: skip never returns
;@ sig: cab77414
Start::
;> DisableLCD()
	call DisableLCD
;> reset_stack(0xDCFF)
	ld sp, $dcff
;> CopyOAMDMARoutine()
	call CopyOAMDMARoutine
;> FillBGMap0(0xFF)
	ld a, $ff
	call FillBGMap0
;> fill(WORK_RAM0, 0, 0x2000)                 # all of WRAM
	ld bc, $2000
	ld hl, wShadowOAM

jr_000_0164:
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, jr_000_0164

;> rBGP = 0x9C
	ld a, $9c
	ldh [rBGP], a
;> rOBP0 = 0x9C
	ldh [rOBP0], a
;> rOBP1 = 0x9C
	ld a, $9c
	ldh [rOBP1], a
;> rIE = 0x09                                  # VBlank and serial
	ld a, $09
	ldh [rIE], a
;> mem[0xFF93] = 0x09
	ldh [$ff93], a
;> wLinkActive = 1
	ld a, $01
	ld [wLinkActive], a
;> rLCDC = 0x83
	ld a, $83
	ldh [rLCDC], a
;> wCourseLengthSave = 0x0A
	ld a, $0a
	ld [wCourseLengthSave], a
;> wPartnerLengthSave = 0x0A
	ld [wPartnerLengthSave], a
;> enable_interrupts()
	ei
;> return Restart()                            # falls through

;@ def Restart()
;@ path: system/boot
;@ Back to the title screen (also after a link game): silences the sound,
;@ resets the link and game state, clears sprites and the tile buffer.
;@ writes: wCourseFinished, wGameMode, wHandshakeOut, wLinkActive, wLinkDone, wLinkHandshake, wLinkMaster, wLinkState, wOppWins, wSplitSCX, wTitleOfferOff, wUnusedCF3E, wYouWins
;@ test: skip never returns
;@ sig: c6e256c1
Restart::
;> wTitleOfferOff = 0
	xor a
	ld [wTitleOfferOff], a
;> wUnusedCF3E = 0
	ld [wUnusedCF3E], a
;> wLinkState = 0
	ld [wLinkState], a
;> InitSound()                                 # sound engine init
	call InitSound
;> reset_stack(0xDCFF)
	ld sp, $dcff
;> wSplitSCX = 0
	xor a
	ld [wSplitSCX], a
;> rSB = 0
	ldh [rSB], a
;> rSC = 0
	ldh [rSC], a
;> for a in (0xCF3C, 0xCF39, addr(wGameMode), 0xC378, 0xC379, 0xCF01, 0xCF02, 0xCF46):
;>     mem[a] = 0
	ld [wLinkMaster], a
	ld [wLinkDone], a
	ld [wGameMode], a
	ld [wYouWins], a
	ld [wOppWins], a
	ld [wCourseFinished], a
	ld [wHandshakeOut], a
	ld [wLinkHandshake], a
;> wLinkActive = 1
	ld a, $01
	ld [wLinkActive], a
;> ClearShadowOAM()
	call ClearShadowOAM
;> ClearTileBuffer()
	call ClearTileBuffer
;> LoadTitleTiles()
	call LoadTitleTiles
;> return TitleScreen()
	jp TitleScreen


;@ def OpenMainMenu()
;@ path: game/menu
;@ From the title screen to the main menu (with the link cable listening).
;@ test: skip never returns
;@ sig: f79f4ccd
OpenMainMenu::
;> SerialStop()
	call SerialStop
;> reset_stack(0xDCFF)
	ld sp, $dcff
;> LoadGameTiles()
	call LoadGameTiles
;> SerialListen()
	call SerialListen
;> return MainMenu()
	jp MainMenu


;@ def StartGame()
;@ path: game/level
;@ LCD on, then NewLevel.
;@ sig: fa61472b
StartGame::
;> rLCDC = 0x83
	ld a, $83
	ldh [rLCDC], a
;> return NewLevel()                           # falls through

;@ def NewLevel()
;@ path: game/level
;@ Clears sprites and the tile buffer, then SetUpLevel.
;@ sig: b3461d53
NewLevel::
;> ClearShadowOAM()
	call ClearShadowOAM
;> ClearTileBuffer()
	call ClearTileBuffer
;> return SetUpLevel()                         # falls through

;@ def SetUpLevel()
;@ path: game/level
;@ Builds the room, loads the tiles, draws the panel and runs the room.
;@ sig: 488f2391
SetUpLevel::
;> BuildRoom()
	call BuildRoom
;> FindCharacters()
	call FindCharacters
;> LoadGameTiles()
	call LoadGameTiles
;> DrawLevelPanel()
	call DrawLevelPanel
;> ShowRoom()
	call ShowRoom
;> PlayRoom()
	call PlayRoom
;> return ClearTileBuffer()                    # falls through

;@ def ClearTileBuffer()
;@ path: room/screen
;@ Empties the screen's tile buffer and draws it, so the screen goes blank.
;@ sig: 78fb6fb9
ClearTileBuffer::
;> fill(addr(wTileBuffer), 0, 0x168)
	xor a
	ld bc, $0168
	ld hl, wTileBuffer
	call FillBytes
;> DrawBufferTiles(addr(wTileBuffer), 0x168)
	call DrawBufferTiles
;> return
	ret


;@ def LoadTitleTiles()
;@ path: gfx/tiles
;@ With the LCD off: the font, the title graphics and the game's tiles for
;@ the title screen; switches the LCD on again.
;@ sig: 0cfb2336
LoadTitleTiles::
;> DisableLCD()
	call DisableLCD
;> LoadFont()
	call LoadFont
;> CopyBytes(GameTiles + 0x700, 0x8D00, 0x10)  # two single tiles
	ld hl, $6700
	ld de, $8d00
	ld bc, $0010
	call CopyBytes
;> CopyBytes(GameTiles + 0xAF0, 0x8CF0, 0x10)
	ld hl, $6af0
	ld de, $8cf0
	ld bc, $0010
	call CopyBytes
;> CopyBytes(TitleTiles, vTiles1, 0x400)
	ld hl, TitleTiles
	ld de, $8800
	ld bc, $0400
	call CopyBytes
;> CopyBytes(GameTiles, 0x8400, 0x400)
	ld hl, GameTiles
	ld de, $8400
	ld bc, $0400
	call CopyBytes
;> return LoadMenuFontTiles()
	jr LoadMenuFontTiles

;@ def EnableLCDBG()
;@ path: system/lcd
;@ LCD on with the background and sprites (signed tile numbers, BG map 0).
;@ sig: 9cfc0d9e
EnableLCDBG::
;> rLCDC = 0x83
	ld a, $83
	ldh [rLCDC], a
;> return
	ret


;@ def LoadFont()
;@ path: gfx/tiles
;@ The 128 characters of the font (1 bit per pixel) into tile block 2, as colour 1.
;@ sig: 0591f8af
LoadFont::
;> Copy1bpp(Font, vTiles2, 0x400)
	ld hl, Font
	ld de, $9000
	ld bc, $0400
	call Copy1bpp
;> return
	ret


;@ def LoadGameTiles()
;@ path: gfx/tiles
;@ With the LCD off: the game's tiles for a level, the menu frame pieces of
;@ the font; switches the LCD on again.
;@ sig: cf4d3b7e
LoadGameTiles::
;> DisableLCD()
	call DisableLCD
;> CopyBytes(GameTiles, 0x8200, 0xC00)
	ld hl, GameTiles
	ld de, $8200
	ld bc, $0c00
	call CopyBytes
;> Copy1bpp(Font + 0x300, 0x8E00, 0x100)       # frame pieces, colour 1
	ld hl, $6f00
	ld de, $8e00
	ld bc, $0100
	call Copy1bpp
;> Copy1bppColour2(Font + 0x350, 0x8EA0, 0x58) # and some in colour 2
	ld hl, $6f50
	ld de, $8ea0
	ld bc, $0058
	call Copy1bppColour2
;> return LoadPieceTiles()
	jr LoadPieceTiles

;@ def LoadMenuTiles()
;@ path: gfx/tiles
;@ With the LCD off: title and game tiles from $8000, then the menu frame
;@ pieces of the font; switches the LCD on again.
;@ sig: 7f6bdb7a
LoadMenuTiles::
;> DisableLCD()
	call DisableLCD
;> CopyBytes(TitleTiles, vTiles0, 0x1000)
	ld hl, TitleTiles
	ld de, $8000
	ld bc, $1000
	call CopyBytes
;> return LoadMenuFontTiles()                # falls through

;@ def LoadMenuFontTiles()
;@ path: gfx/tiles
;@ The font's frame pieces as colour 1 at $8E00, then LoadPieceTiles.
;@ test: rLCDC = 0
;@ sig: 04d3ace1
LoadMenuFontTiles::
;> Copy1bpp(Font + 0x300, 0x8E00, 0x78)
	ld hl, $6f00
	ld de, $8e00
	ld bc, $0078
	call Copy1bpp
;> return LoadPieceTiles()                   # falls through

;@ def LoadPieceTiles()
;@ path: gfx/tiles
;@ The first 32 game tiles into $9600 (BG tiles $60-$7F), then the LCD on.
;@ test: rLCDC = 0
;@ sig: bb8a9a24
LoadPieceTiles::
;> CopyBytes(GameTiles, 0x9600, 0x200)
	ld hl, GameTiles
	ld de, $9600
	ld bc, $0200
	call CopyBytes
;> return EnableLCDBG()
	jp EnableLCDBG


;@ def Copy1bpp(src: hl, dest: de, count: bc)
;@ path: gfx/tiles
;@ Expands `count` bytes of 1-bit-per-pixel graphics into 2-bit tiles: each
;@ byte becomes a row in colour 1 (low bit plane set, high plane 0).
;@ test: count = rand(1, 0x80)
;@ test: src = rand(0x0000, 0x7F00)
;@ test: dest = rand_ram(2 * count)
;@ sig: 55f01411
Copy1bpp::
;> for i in range(count or 0x10000):
;>     mem[dest + 2 * i] = mem[src + i]
;>     mem[dest + 2 * i + 1] = 0
	ld a, [hli]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, Copy1bpp

;> return
	ret


;@ def Copy1bppColour2(src: hl, dest: de, count: bc)
;@ path: gfx/tiles
;@ Like Copy1bpp, but the pixels get colour 2 (the high bit plane).
;@ test: count = rand(1, 0x80)
;@ test: src = rand(0x0000, 0x7F00)
;@ test: dest = rand_ram(2 * count)
;@ sig: 815649e1
Copy1bppColour2::
;> for i in range(count or 0x10000):
;>     mem[dest + 2 * i] = 0
;>     mem[dest + 2 * i + 1] = mem[src + i]
	xor a
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, Copy1bppColour2

;> return
	ret


;@ def TitleScreen()
;@ path: title
;@ Draws the title screen (logo, PUSH START BUTTON, copyright lines), starts
;@ the title music and offers the link cable partner a game.
;@ writes: $986D, $988E, hJoyHeld, hJoyPressed, wClockSeconds, wCourseLength, wDemo, wLinkAnswerWait, wLinkState, wTitleBlink, wVsPartnerLength
;@ test: skip never returns
;@ sig: 3832987e
TitleScreen::
;> wDemo = 0
	xor a
	ld [wDemo], a
;> wClockSeconds = 0
	ld [wClockSeconds], a
;> wLinkAnswerWait = 0
	ld [wLinkAnswerWait], a
;> wCourseLength = 0x0A
	ld a, $0a
	ld [wCourseLength], a
;> wVsPartnerLength = 0x0A
	ld [wVsPartnerLength], a
;> QueueSound(5)                               # the title music
	ld b, $05
	rst $30
;> DisableLCD()
	call DisableLCD
;> FillBGMap0(0xCF)
	ld a, $cf
	call FillBGMap0
;> for row in range(18):                       # the screen's 18 x 20 tiles blank
	ld hl, $9800
	ld bc, $1412

;>     fill(vBGMap0 + 32 * row, 0xFF, 20)
jr_000_02df:
	ld a, $ff
	ld [hli], a
	dec b
	jr nz, jr_000_02df

	ld b, $14
	ld de, $000c
	add hl, de
	dec c
	jr nz, jr_000_02df

;> hJoyHeld = 0xFF
	ld a, $ff
	ldh [hJoyHeld], a
;> hJoyPressed = 0xFF
	ldh [hJoyPressed], a
;> EnableLCD()
	call EnableLCD
;> PrintText(0x9843, TitleLogoText)
	ld hl, $9843
	ld de, TitleLogoText
	call PrintText
;> WaitHBlank()
	call WaitHBlank
;> mem[0x986D] = 0xAA                          # two logo tiles that are PrintText's
	ld a, $aa
	ld [$986d], a
;> WaitHBlank()
	call WaitHBlank
;> mem[0x988E] = 0xBB                          # newline and end codes
	ld a, $bb
	ld [$988e], a
;> PrintText(0x9901, PushStartText)
	ld hl, $9901
	ld de, PushStartText
	call PrintText
;> PrintText(0x9A02, CopyrightAtlusText)
	ld hl, $9a02
	ld de, CopyrightAtlusText
	call PrintText
;> PrintText(0x9964, LicensedText)
	ld hl, $9964
	ld de, LicensedText
	call PrintText
;> PrintText(0x9984, TrademarkText)
	ld hl, $9984
	ld de, TrademarkText
	call PrintText
;> PrintText(0x99E2, CopyrightAcclaimText)
	ld hl, $99e2
	ld de, CopyrightAcclaimText
	call PrintText
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a
;> wLinkState = 1
	ld a, $01
	ld [wLinkState], a
;> SerialOfferTitle()
	call SerialOfferTitle
;> return TitleDemoTimer()                     # falls through

;@ def TitleDemoTimer()
;@ path: title
;@ After 17 seconds on the title screen the demo starts.
;@ reads: wClockSeconds
;@ test: skip never returns
;@ sig: 176873ec
TitleDemoTimer::
;> if wClockSeconds == 0x17: return StartDemo()
	ld a, [wClockSeconds]
	cp $17
	jp z, StartDemo
;> return TitleScreenLoop()                    # falls through

;@ def TitleScreenLoop()
;@ path: title
;@ One round of the title screen every 10 frames: START opens the main menu,
;@ a START from the link partner opens it in VS MODE.
;@ writes: wTitleBlink
;@ reads: hJoyPressed, wDemo, wPartnerStarted, wTitleBlink
;@ test: skip never returns
;@ sig: 144d36bc
TitleScreenLoop::
;> if wDemo: return TitleScreen()              # back from the demo
	ld a, [wDemo]
	and a
	jp nz, TitleScreen

;> if wPartnerStarted: return TitleLinkStart()     # the partner pressed START
	ld a, [wPartnerStarted]
	and a
	jr nz, TitleLinkStart

;> WaitFrames10()
	call WaitFrames10
;> wTitleBlink ^= 0xFF
	ld a, [wTitleBlink]
	cpl
	ld [wTitleBlink], a
;> ReadJoypad()
	call ReadJoypad
;> if not hJoyPressed & BTN_START: return TitleDemoTimer()
	ldh a, [hJoyPressed]
	bit 3, a
	jr z, TitleDemoTimer

;> return TitleStartPressed()
	jr TitleStartPressed

;@ def ClearScreen()
;@ path: gfx/tilemaps
;@ Fills BG map 0 with blank tiles (with the LCD off for it).
;@ sig: 1fd99a71
ClearScreen::
;> EnableLCD()
	call EnableLCD
;> DisableLCD()
	call DisableLCD
;> FillBGMap0(0xFF)
	ld a, $ff
	call FillBGMap0
;> EnableLCD()
	call EnableLCD
;> return
	ret


;@ def TitleLinkStart()
;@ path: title
;@ The link partner started: VS MODE.
;@ writes: wGameMode
;@ test: skip never returns
;@ sig: 8f39eb2b
TitleLinkStart::
;> wGameMode = 2
	ld a, $02
	ld [wGameMode], a
;> return TitleStartPressed()                  # falls through

;@ def TitleStartPressed()
;@ path: title
;@ Clears the screen and opens the main menu.
;@ test: skip never returns
;@ sig: 11a04306
TitleStartPressed::
;> ClearShadowOAM()
	call ClearShadowOAM
;> ClearScreen()
	call ClearScreen
;> return OpenMainMenu()
	jp OpenMainMenu


;@ def LinkStartVsGame()
;@ path: link/menu
;@ VS MODE: tells the link partner that the game starts (state 4).
;@ writes: wLinkState
;@ reads: wLinkMaster
;@ sig: 6014f824
LinkStartVsGame::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> if wLinkMaster:
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_03a6

;>     WaitFrames10()
	call WaitFrames10
;>     wLinkState = 4
	ld a, $04
	ld [wLinkState], a
;>     LinkWait()
	call LinkWait
;>     return
	ret


jr_000_03a6:
;> wLinkState = 4
	ld a, $04
	ld [wLinkState], a
;> LinkSendFollower(0xEE)
	ld a, $ee
	call LinkSendFollower
;> return
	ret


;@ def SerialOfferTitle()
;@ path: link/serial
;@ Puts $9F ("on the title screen") in the serial register for the partner
;@ to clock out, and waits for it.
;@ sig: be0703fd
SerialOfferTitle::
;> rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;> rSB = 0x9F
	ld a, $9f
	ldh [rSB], a
;> rSC = (rSC & ~0x01) | 0x80
	res 0, [hl]
	set 7, [hl]
;> return
	ret


;@ def LinkMenuSettle()
;@ path: link/menu
;@ Between two menus: 10 frames with the serial interrupt off, so the link
;@ code in the VBlank handler goes quiet.
;@ writes: wLinkState
;@ reads: wLinkMaster
;@ sig: abfa4e1a
LinkMenuSettle::
;> if not wLinkMaster: return
	ld a, [wLinkMaster]
	and a
	ret z

;> rIE = 0x01
	ld a, $01
	ldh [rIE], a
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> WaitFrames10()
	call WaitFrames10
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> return
	ret


;@ def MenuLinkStart()
;@ path: game/menu
;@ The link partner started a game from its main menu: VS MODE.
;@ writes: wGameMode
;@ test: skip never returns
;@ sig: f522df07
MenuLinkStart::
;> wGameMode = 2
	ld a, $02
	ld [wGameMode], a
;> return SelectSkillMenu()
	jp SelectSkillMenu


;@ def MenuRestart()
;@ path: game/menu
;@ Back to the main menu (B on the skill menu, or a failed link start).
;@ writes: wLinkMaster, wPartnerStarted, wSerialOut
;@ test: skip never returns
;@ sig: 7fc93f0e
MenuRestart::
;> Delay()
	call Delay
;> SerialOfferTitle2()
	call SerialOfferTitle2
;> wSerialOut = 0
	xor a
	ld [wSerialOut], a
;> wPartnerStarted = 0
	ld [wPartnerStarted], a
;> wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;> return MainMenuReset()
	jr MainMenuReset

;@ def SerialOfferTitle2()
;@ path: link/serial
;@ The same as SerialOfferTitle.
;@ sig: be0703fd
SerialOfferTitle2::
;> rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;> rSB = 0x9F
	ld a, $9f
	ldh [rSB], a
;> rSC = (rSC & ~0x01) | 0x80
	res 0, [hl]
	set 7, [hl]
;> return
	ret


;@ def MainMenu()
;@ path: game/menu
;@ Starts the menu music, then the main menu.
;@ writes: wCourseLength, wVsPartnerLength
;@ reads: wCourseLengthSave, wPartnerLengthSave
;@ test: skip never returns
;@ sig: 8224dc9c
MainMenu::
;> QueueSound(3)                               # the menu music
	ld b, $03
	rst $30
;> wCourseLength = wCourseLengthSave
	ld a, [wCourseLengthSave]
	ld [wCourseLength], a
;> wVsPartnerLength = wPartnerLengthSave
	ld a, [wPartnerLengthSave]
	ld [wVsPartnerLength], a
;> return MainMenuReset()                      # falls through

;@ def MainMenuReset()
;@ path: game/menu
;@ SELECT GAME: GOING UP?, HEADING OUT? or VS MODE. VS MODE first shakes
;@ hands with the link partner; without one it is back to this menu.
;@ writes: wContestGames, wGameMode, wLinkActive, wLinkAnswerWait, wLinkDone, wLinkMaster, wLinkState, wMenuLastColRows, wOppWins, wSerialOut, wYouWins
;@ reads: wLinkDone, wLinkRefused, wMenuChoice, wPartnerStarted
;@ test: skip never returns
;@ sig: fa31eac6
MainMenuReset::
;> fill(0xC2FD, 0xEE, 20)
	ld a, $ee
	ld b, $14
	ld hl, wRecentRooms

jr_000_0414:
	ld [hli], a
	dec b
	jr nz, jr_000_0414

;> for _ in forever():                         # SelectGameMenu
SelectGameMenu:
;>     SerialOfferTitle2()
	call SerialOfferTitle2
;>     ClearShadowOAM()
	call ClearShadowOAM
;>     wLinkState = 1
	ld a, $01
	ld [wLinkState], a
;>     wLinkActive = 1
	ld [wLinkActive], a
;>     for a in (0xCF48, addr(wContestGames), 0xC378, 0xC379, 0xCF39):
;>         mem[a] = 0
	xor a
	ld [wLinkAnswerWait], a
	ld [wContestGames], a
	ld [wYouWins], a
	ld [wOppWins], a
	ld [wLinkDone], a
;>     if wPartnerStarted: return SelectSkillMenu()   # the partner chose already
	ld a, [wPartnerStarted]
	and a
	jp nz, SelectSkillMenu

;>     Delay()
	call Delay
;>     MenuScreenText(0x9904, SelectGameText)
	ld de, SelectGameText
	ld hl, $9904
	call MenuScreenText
;>     wMenuLastColRows = 2
	ld hl, $9944
	ld de, $0040
	ld bc, $0002
	ld a, $02
	ld [wMenuLastColRows], a
;>     MenuChoose(0x9944, 0x0040, 0, 2, 0xAB)  # 3 rows, 2 apart
	ld a, $ab
	call MenuChoose
;>     wLinkState = 1
	ld a, $01
	ld [wLinkState], a
;>     if wMenuChoice == 0xF0: return MenuLinkStart()
	ld a, [wMenuChoice]
	cp $f0
	jp z, MenuLinkStart

;>     if wMenuChoice == 0xFF: continue
	cp $ff
	jr z, SelectGameMenu

;>     wGameMode = wMenuChoice
	ld [wGameMode], a
;>     if wGameMode == 2:                      # VS MODE: shake hands
	cp $02
	jr nz, jr_000_04ab

;>         rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;>         rSB = 0x9F
	ld a, $9f
	ldh [rSB], a
;>         rSC = (rSC & ~0x01) | 0x80
	res 0, [hl]
	set 7, [hl]
;>         disable_interrupts()
	di
;>         wSerialOut = 0x66
	ld a, $66
	ld [wSerialOut], a
;>         rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;>         enable_interrupts()
	ei
;>         SerialSend()
	call SerialSend
;>         if not wLinkDone: return MenuRestart()   # nobody there
	ld a, [wLinkDone]
	and a
	jp z, MenuRestart

;>         wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;>         wLinkAnswerWait = 1
	ld [wLinkAnswerWait], a
;>         LinkWait()
	call LinkWait
;>         if wLinkRefused: return MenuRestart()
	ld a, [wLinkRefused]
	and a
	jp nz, MenuRestart

;>         return SelectSkillMenu()
	jr jr_000_04bc

jr_000_04ab:
;>     wLinkActive = 0
	xor a
	ld [wLinkActive], a
;>     wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;>     rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;>     rSB = 0
	xor a
	ldh [rSB], a
;>     return SelectSkillMenu()                # falls through

;@ def SelectSkillMenu()
;@ path: game/menu
;@ SELECT SKILL: LEVEL-1 EASY, LEVEL-2 AVERAGE or LEVEL-3 HARD. Then the
;@ floor (GOING UP?) or the course.
;@ writes: wCourseRoom, wLinkState, wMenuLastColRows, wPartnerStarted, wSkill, wUnusedCF3E, wVsPartnerRoom
;@ reads: wGameMode, wMenuChoice
;@ test: skip never returns
;@ sig: d6a8a17b
SelectSkillMenu::
jr_000_04bc:
;> LinkMenuSettle()
	call LinkMenuSettle
;> ClearShadowOAM()
	call ClearShadowOAM
;> for a in (0xCF3A, 0xCF3E, 0xCF42, 0xC2BB, 0xC2BC):
;>     mem[a] = 0
	xor a
	ld [wLinkState], a
	ld [wUnusedCF3E], a
	ld [wPartnerStarted], a
	ld [wCourseRoom], a
	ld [wVsPartnerRoom], a
;> MenuScreenText(0x9902, SelectSkillText)
	ld de, SelectSkillText
	ld hl, $9902
	call MenuScreenText
;> wMenuLastColRows = 2
	ld hl, $9942
	ld de, $0040
	ld b, $00
	ld c, $02
	ld a, $02
	ld [wMenuLastColRows], a
;> MenuChoose(0x9942, 0x0040, 0, 2, 0xAB)
	ld a, $ab
	call MenuChoose
;> if wMenuChoice == 0xFF: return MenuRestart()
	ld a, [wMenuChoice]
	cp $ff
	jp z, MenuRestart

;> wSkill = wMenuChoice
	ld [wSkill], a
;> if wGameMode == 0: return SelectFloorMenu()
	ld a, [wGameMode]
	cp $00
	jp z, SelectFloorMenu

;> return SelectCourseMenu()
	jp SelectCourseMenu


;@ def SelectFloorMenu()
;@ path: game/menu
;@ GOING UP?: SELECT FLOOR, FL- 1 to FL-10 in two columns. The room is
;@ skill * 10 + floor.
;@ writes: wLinkMaster, wMenuLastColRows, wRoom
;@ reads: wMenuChoice, wSkill
;@ test: skip never returns
;@ sig: cdaa4bdb
SelectFloorMenu::
;> LinkMenuSettle()
	call LinkMenuSettle
;> wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;> Delay()
	call Delay
;> MenuScreenText(0x9903, SelectFloorText)
	ld de, SelectFloorText
	ld hl, $9903
	call MenuScreenText
;> wMenuLastColRows = 4
	ld hl, $9943
	ld de, $0720
	ld b, $01
	ld c, $04
	ld a, $04
	ld [wMenuLastColRows], a
;> MenuChoose(0x9943, 0x0720, 1, 4, 0xAB)      # 2 columns of 5
	ld a, $ab
	call MenuChoose
;> if wMenuChoice == 0xFF: return SelectSkillMenu()
	ld a, [wMenuChoice]
	cp $ff
	jr z, jr_000_04bc

;> wRoom = u8(MultiplyHLByA(10, wSkill) + wMenuChoice)
	push af
	ld a, [wSkill]
	ld hl, $000a
	call MultiplyHLByA
	pop af
	add l
	ld [wRoom], a
;> return SelectDisplayMenu()                  # falls through

;@ def SelectDisplayMenu()
;@ path: game/menu
;@ SELECT DISPLAY: DIAGONAL VIEW or BIRD'S-EYE VIEW.
;@ writes: wCourseLengthSave, wDiagonalView, wLinkState, wMenuLastColRows, wPartnerLengthSave
;@ reads: wCourseLength, wMenuChoice, wVsPartnerLength
;@ test: skip never returns
;@ sig: 3e2bcfd1
SelectDisplayMenu::
;> LinkMenuSettle()
	call LinkMenuSettle
;> wCourseLengthSave = wCourseLength
	ld a, [wCourseLength]
	ld [wCourseLengthSave], a
;> wPartnerLengthSave = wVsPartnerLength
	ld a, [wVsPartnerLength]
	ld [wPartnerLengthSave], a
;> Delay()
	call Delay
;> MenuScreenText(0x9902, SelectDisplayText)
	ld de, SelectDisplayText
	ld hl, $9902
	call MenuScreenText
;> wMenuLastColRows = 1
	ld hl, $9942
	ld de, $0040
	ld b, $00
	ld c, $01
	ld a, $01
	ld [wMenuLastColRows], a
;> MenuChoose(0x9942, 0x0040, 0, 1, 0xAB)
	ld a, $ab
	call MenuChoose
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> wDiagonalView = 0
	ld [wDiagonalView], a
;> if wMenuChoice == 0xFF: return DisplayMenuBack()
	ld a, [wMenuChoice]
	cp $ff
	jp z, DisplayMenuBack

;> if wMenuChoice != 0: return MenusDone()     # bird's-eye
	and a
	jp nz, MenusDone

;> wDiagonalView = 1
	inc a
	ld [wDiagonalView], a
;> return MenusDone()
	jp MenusDone


;@ def DisplayMenuBack()
;@ path: game/menu
;@ B on the display menu: back to the menu before it.
;@ reads: wGameMode
;@ test: skip never returns
;@ sig: e1803689
DisplayMenuBack::
;> if wGameMode == 0: return SelectFloorMenu()
	ld a, [wGameMode]
	and a
	jp z, SelectFloorMenu

;> if wGameMode == 1: return SelectCourseMenu()
	cp $01
	jr z, jr_000_059a

;> return SelectContestMenu()
	jp SelectContestMenu


;@ def SelectCourseMenu()
;@ path: game/menu
;@ HEADING OUT? and VS MODE: SELECT COURSE, the number of rooms.
;@ writes: wLinkState
;@ reads: wGameMode, wMenuChoice
;@ test: skip never returns
;@ sig: 2bc28d37
SelectCourseMenu::
jr_000_059a:
;> LinkMenuSettle()
	call LinkMenuSettle
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> CourseMenu()
	call CourseMenu
;> if wMenuChoice == 0xFF: return SelectSkillMenu()
	ld a, [wMenuChoice]
	cp $ff
	jp z, SelectSkillMenu

;> if wGameMode == 1: return SelectDisplayMenu()
	ld a, [wGameMode]
	cp $01
	jp z, SelectDisplayMenu
;> return SelectContestMenu()                  # falls through

;@ def SelectContestMenu()
;@ path: game/menu
;@ VS MODE: SELECT CONTEST, 1 GAME PLAYOFF or BEST OF 3 / 5 / 7 / 9.
;@ writes: wContestGames, wMenuLastColRows, wOppWins, wYouWins
;@ reads: wMenuChoice
;@ test: skip never returns
;@ sig: d4aa8b35
SelectContestMenu::
;> LinkMenuSettle()
	call LinkMenuSettle
;> Delay()
	call Delay
;> MenuScreenText(0x9903, SelectContestText)
	ld de, SelectContestText
	ld hl, $9903
	call MenuScreenText
;> wMenuLastColRows = 4
	ld hl, $9943
	ld de, $0020
	ld b, $00
	ld c, $04
	ld a, $04
	ld [wMenuLastColRows], a
;> MenuChoose(0x9943, 0x0020, 0, 4, 0xAB)
	ld a, $ab
	call MenuChoose
;> if wMenuChoice == 0xFF: return SelectCourseMenu()
	ld a, [wMenuChoice]
	cp $ff
	jp z, SelectCourseMenu

;> wContestGames = u8(wMenuChoice * 2 + 1)
	sla a
	inc a
	ld [wContestGames], a
;> wYouWins = 0
	xor a
	ld [wYouWins], a
;> wOppWins = 0
	ld [wOppWins], a
;> return SelectDisplayMenu()
	jp SelectDisplayMenu


;@ def MenusDone()
;@ path: game/menu
;@ The menus are done. HEADING OUT? with SELECT and LEFT held calls AllRoomsCourse.
;@ writes: wAllRooms, wLinkState
;@ reads: hJoyHeld, wGameMode
;@ test: skip never returns
;@ sig: d91b91af
MenusDone::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> wAllRooms = 0
	ld [wAllRooms], a
;> if wGameMode == 1 and (hJoyHeld & 0x24) == 0x24: AllRoomsCourse()
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_0606

	ldh a, [hJoyHeld]
	and $24
	cp $24
	call z, AllRoomsCourse
;> return StartPrompt()                        # falls through

;@ def StartPrompt()
;@ path: game/menu
;@ The last screen before the game (DrawStartScreen); B goes back to the display
;@ menu. Then the game is set up: for HEADING OUT? and VS MODE the course of
;@ rooms, then StartGame.
;@ writes: wCourseIndex, wCourseSeed, wInStartPrompt, wLinkMaster, wLinkState, wPartnerStarted
;@ reads: wAllRooms, wClockFrames, wGameMode, wLinkMaster, wMenuChoice
;@ test: skip never returns
;@ sig: 9f5eb798
StartPrompt::
jr_000_0606:
;> wPartnerStarted = 0
	xor a
	ld [wPartnerStarted], a
;> wInStartPrompt = 0xFF
	cpl
	ld [wInStartPrompt], a
;> if wLinkMaster: WaitFrames10()
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_0617

	call WaitFrames10

jr_000_0617:
;> LinkMenuSettle()
	call LinkMenuSettle
;> DrawStartScreen()
	call DrawStartScreen
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> if wMenuChoice == 0xFF: return SelectDisplayMenu()
	ld a, [wMenuChoice]
	cp $ff
	jp z, SelectDisplayMenu

;> if wMenuChoice: return EndMenu()
	and a
	jp nz, EndMenu

;> wInStartPrompt = 0
	xor a
	ld [wInStartPrompt], a
;> fill(0xC0EC, 0, 0x190)
	ld hl, $c0ec
	ld bc, $0190
	ld a, $00
	call FillBytes
;> if wGameMode != 0 and not wAllRooms:
	ld a, [wGameMode]
	and a
	jr z, jr_000_066e

	ld a, [wAllRooms]
	and a
	jr nz, jr_000_066e

;>     wCourseSeed = wClockFrames
	ld a, [wClockFrames]
	ld [wCourseSeed], a
;>     if wGameMode == 2: LinkStartVsGame()
	ld a, [wGameMode]
	cp $02
	call z, LinkStartVsGame
;>     if wGameMode == 1:
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_0660

;>         wLinkMaster = 1
	ld [wLinkMaster], a

jr_000_0660:
;>     ClearLevelList()
	call ClearLevelList
;>     wCourseIndex = 0xFF
	ld a, $ff
	ld [wCourseIndex], a
;>     BuildCourse()
	call BuildCourse
;>     PickRoom()
	call PickRoom

jr_000_066e:
;> WipeInRoom()
	call WipeInRoom
;> return StartGame()
	jp StartGame


;@ def PickRoom()
;@ path: game/level
;@ Picks the next room: in the demo the next of DemoLevels, otherwise the
;@ next room of the course. SkillRooms adds to it.
;@ writes: wDemoRun, wMirror, wRoom, wSkill
;@ reads: wDemo, wDemoRun, wRoom
;@ sig: a9a243eb
PickRoom::
;> if wDemo:
;>@d1     wRoom = mem[DemoLevels + wDemoRun]
;>@d2     wSkill = 0
;>@d3     wDemoRun += 1
;>@d4     wMirror = 0
	ld a, [wDemo]
	and a
	jr nz, jr_000_0689

;> else: NextCourseRoom()
	call NextCourseRoom

jr_000_067d:
;> wRoom = u8(wRoom + SkillRooms()[0])          # the skill's first room
	call SkillRooms
	ld b, a
	ld a, [wRoom]
	add b
	ld [wRoom], a
;> return
	ret


jr_000_0689:
;=@d1
	ld hl, DemoLevels
	ld a, [wDemoRun]
	call AddAToHL
	ld a, [hl]
	ld [wRoom], a
;=@d2
	xor a
	ld [wSkill], a
;=@d3
	ld a, [wDemoRun]
	inc a
	ld [wDemoRun], a
;=@d4
	xor a
	ld [wMirror], a
	jr jr_000_067d

;@ def DrawMenuScreen()
;@ path: game/menu
;@ The frame of the menu screens: a big box for the choices and a small
;@ one with Kwirk's picture.
;@ sig: 179bddef
DrawMenuScreen::
;> DisableLCD()
	call DisableLCD
;> FillBGMap0(0xCF)
	ld a, $cf
	call FillBGMap0
;> EnableLCD()
	call EnableLCD
;> DrawBox(0x98C0, 20, 11)
	ld hl, $98c0
	ld de, $140b
	call DrawBox
;> DrawBox(0x9807, 6, 7)
	ld hl, $9807
	ld de, $0607
	call DrawBox
;> PrintText(0x9828, MenuKwirkText)
	ld hl, $9828
	ld de, MenuKwirkText
	call PrintText
;> return
	ret


;@ def MenuScreenText(dest: hl, text: de)
;@ path: game/menu
;@ A new menu screen with the text at dest.
;@ sig: 0b6deb0b
MenuScreenText::
;> DrawMenuScreen()
	push hl
	push de
	call DrawMenuScreen
	pop de
	pop hl
;> PrintText(dest, text)
	call PrintText
;> return
	ret


;@ def Delay()
;@ path: lib/timing
;@ Busy-waits about 0.16 s (24576 rounds of a 28-cycle loop). Keeps every register.
;@ sig: 09fdffd9
Delay::
;> for _ in range(0x6000): pass
	push bc
	push af
	ld bc, $6000

jr_000_06de:
	dec bc
	ld a, b
	or c
	jr nz, jr_000_06de

	pop af
	pop bc
;> return
	ret


;@ def ClearLevelList()
;@ path: game/menu
;@ Fills the 30-byte list at $C311 with $FF.
;@ sig: ec431e5e
ClearLevelList::
;> fill(0xC311, 0xFF, 30)
	ld hl, wCourseRooms
	ld bc, $001e
	ld a, $ff
	call FillBytes
;> return
	ret


;@ def NextCourseRoom()
;@ path: game/level
;@ HEADING OUT? / VS MODE: the next room of the course.
;@ writes: wCourseIndex, wMirror, wRoom
;@ reads: wCourseIndex
;@ sig: 15669d90
NextCourseRoom::
;> wCourseIndex = u8(wCourseIndex + 1)
	ld a, [wCourseIndex]
	inc a
	ld [wCourseIndex], a
;> wRoom = mem[addr(wCourseRooms) + wCourseIndex]
	ld e, a
	ld d, $00
	ld hl, wCourseRooms
	add hl, de
	ld a, [hl]
	ld [wRoom], a
;> wMirror = 0
	xor a
	ld [wMirror], a
;> wMirror = Random() & 1
	call Random
	and $01
	ld [wMirror], a
;> return
	ret


;@ def SkillClearedText()
;@ path: game/results
;@ All 10 floors of a skill cleared: AWESOME and the next skill, or after
;@ the third EXCELLENT and back to the first.
;@ writes: wSkill
;@ reads: wSkill
;@ sig: 5fa8adfe
SkillClearedText::
;> DrawResultsScreen()
	call DrawResultsScreen
;> if wSkill != 2:
	ld hl, $9886
	ld a, [wSkill]
	cp $02
	jr z, jr_000_0734

;>     PrintText(0x9886, AwesomeText)
	ld de, AwesomeText
	call PrintText
;>     wSkill += 1
	ld a, [wSkill]
	inc a
	ld [wSkill], a
;>     PrintDigit(0x98CD, wSkill | 0xF0)
	or $f0
	ld hl, $98cd
	call PrintDigit
;>     return
	ret


jr_000_0734:
;> PrintText(0x9885, ExcellentText)
	ld hl, $9885
	ld de, ExcellentText
	call PrintText
;> wSkill = 0
	xor a
	ld [wSkill], a
;> return
	ret


;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ Main menu: GOING UP? (the puzzle floors), HEADING OUT? (a course of rooms against the clock) or VS MODE.
SelectGameText::
	db $12, $04, $0b, $04, $02, $13, $ff, $06, $00, $0c, $04, $aa, $aa, $ff, $06, $0e
	db $08, $0d, $06, $ff, $14, $0f, $21, $aa, $aa, $ff, $07, $04, $00, $03, $08, $0d
	db $06, $ff, $0e, $14, $13, $21, $aa, $aa, $ff, $15, $12, $ff, $0c, $0e, $03, $04
	db $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ The view of the rooms: diagonal or from above.
SelectDisplayText::
	db $ff, $12, $04, $0b, $04, $02, $13, $ff, $03, $08, $12, $0f, $0b, $00, $18
	db $aa, $aa, $ff, $03, $08, $00, $06, $0e, $0d, $00, $0b, $ff, $15, $08, $04, $16
	db $aa, $aa, $ff, $01, $08, $11, $03, $1e, $12, $1f, $04, $18, $04, $ff, $15, $08
	db $04, $16, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ GOING UP?: the skill level (each has its own 10 floors).
SelectSkillText::
	db $ff, $ff, $12, $04, $0b, $04, $02, $13, $ff, $12, $0a, $08, $0b
	db $0b, $aa, $aa, $ff, $0b, $04, $15, $04, $0b, $1d, $3d, $ff, $04, $00, $12, $18
	db $aa, $aa, $ff, $0b, $04, $15, $04, $0b, $1d, $3e, $ff, $00, $15, $04, $11, $00
	db $06, $04, $aa, $aa, $ff, $0b, $04, $15, $04, $0b, $1d, $3f, $ff, $07, $00, $11
	db $03, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ GOING UP?: the floor to start on.
SelectFloorText::
	db $ff, $12, $04, $0b, $04, $02, $13, $ff, $05, $0b, $0e, $0e, $11, $aa
	db $aa, $ff, $05, $0b, $1d, $ff, $3d, $ff, $ff, $05, $0b, $1d, $ff, $42, $aa, $ff
	db $05, $0b, $1d, $ff, $3e, $ff, $ff, $05, $0b, $1d, $ff, $43, $aa, $ff, $05, $0b
	db $1d, $ff, $3f, $ff, $ff, $05, $0b, $1d, $ff, $44, $aa, $ff, $05, $0b, $1d, $ff
	db $40, $ff, $ff, $05, $0b, $1d, $ff, $45, $aa, $ff, $05, $0b, $1d, $ff, $41, $ff
	db $ff, $05, $0b, $1d, $3d, $3c, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: how many games decide the contest.
SelectContestText::
	db $12, $04, $0b, $04, $02, $13, $ff, $02, $0e
	db $0d, $13, $04, $12, $13, $aa, $aa, $ff, $3d, $ff, $06, $00, $0c, $04, $ff, $0f
	db $0b, $00, $18, $0e, $05, $05, $aa, $ff, $01, $04, $12, $13, $ff, $0e, $05, $ff
	db $3f, $aa, $ff, $01, $04, $12, $13, $ff, $0e, $05, $ff, $41, $aa, $ff, $01, $04
	db $12, $13, $ff, $0e, $05, $ff, $43, $aa, $ff, $01, $04, $12, $13, $ff, $0e, $05
	db $ff, $45, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ GOING UP?: a floor cleared, with its time and steps.
YouDidItText::
	db $ff, $ff, $18, $0e, $14, $ff, $03, $08, $03, $ff, $08, $13, $20
	db $aa, $aa, $0b, $04, $15, $04, $0b, $ff, $1d, $ff, $ff, $05, $0b, $1d, $aa, $aa
	db $ff, $ff, $13, $08, $0c, $04, $ff, $ff, $ff, $e0, $aa, $aa, $ff, $ff, $12, $13
	db $04, $0f, $12, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ The menu after giving up a room.
PauseMenuText::
	db $11, $04, $13, $14, $11, $0d, $ff, $13, $0e, $ff, $06, $00
	db $0c, $04, $aa, $aa, $aa, $aa, $12, $04, $0b, $04, $02, $13, $ff, $12, $0a, $08
	db $0b, $0b, $aa, $aa, $12, $04, $0b, $04, $02, $13, $ff, $06, $00, $0c, $04, $bb
;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ A pause menu line.
SelectFloorText2::
	db $12, $04, $0b, $04, $02, $13, $ff, $05, $0b, $0e, $0e, $11, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT?: the course (number of rooms).
SelectCourseText::
	db $12, $04, $0b
	db $04, $02, $13, $ff, $02, $0e, $14, $11, $12, $04, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: the rooms of both players.
OppYouText::
	db $0e, $0f, $0f, $ff, $ff
	db $ff, $ff, $ff, $11, $0c, $12, $aa, $aa, $aa, $18, $0e, $14, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ A level of a skill cleared.
AwesomeText::
	db $00, $16, $04
	db $12, $0e, $0c, $04, $20, $aa, $aa, $0b, $04, $15, $04, $0b, $ff, $1d, $aa, $aa
	db $02, $0b, $04, $00, $11, $04, $03, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ All three levels cleared.
ExcellentText::
	db $aa, $aa, $04, $17, $02, $04, $0b, $0b
	db $04, $0d, $13, $20, $bb

;@ def BuildRoom()
;@ path: room/build
;@ Builds the current room (wRoom) in wTileBuffer. GOING UP?: the room's size
;@ comes first in its RoomHeaders entry and the room is centred on the screen;
;@ HEADING OUT?: every room is 8 x 6 at (6, 6) between two corridors. The
;@ screen starts as wall; the room's bit map (RoomBits, one bit per cell, each
;@ row starting a new byte) says which cells take the next object from the
;@ object stream (RoomObjects) and which are floor. HEADING OUT? then cuts the
;@ two corridors (the RoomHeaders byte: one shape in each nibble), puts Kwirk
;@ at the right end and mirrors the room when $C2FA says so. Finally every wall
;@ cell gets the tile that joins it to its wall neighbours.
;@ writes: wBoxLeft, wBoxMiddle, wBoxRight, wCellPtrHi, wMenuCursorTile, wMenuLastCol, wMenuLastRow, wRightCorridor, wRoomBitsByte, wRoomBitsHi, wRoomHeight, wRoomY
;@ reads: wBoxLeft, wBoxMiddle, wBoxRight, wGameMode, wMirror, wRightCorridor, wRoomBitsByte, wRoomBitsHi, wRoomHeight, wRoomY
;@ test: wGameMode = rng.choice([0, 1, 2]); wRoom = rand(0, 29) if wGameMode == 0 else rand(30, 149)
;@ test: mem[0xC2FA] = rng.choice([0, 1])
;@ sig: 1ee60df4
BuildRoom::
;> if wGameMode:                                # HEADING OUT?
	ld a, [wGameMode]
	and a
	jr z, jr_000_094c

;>     mem[0xCF07:0xCF0B] = [6, 6, 8, 6]          # x, y, width, height
	ld hl, wBoxLeft
	ld a, $06
	ld [hli], a
	ld [hli], a
	ld a, $08
	ld [hli], a
	ld a, $06
	ld [hl], a
	jr jr_000_096f

jr_000_094c:
;> else:                                        # GOING UP?
;>     header = ReadPointer(RoomTableEntry(RoomHeaders))
	ld bc, RoomHeaders
	call RoomTableEntry
	call ReadPointer
;>     wBoxMiddle = mem[header]                 # width
	ld a, [hli]
	ld [wBoxMiddle], a
	ld c, a
;>     wBoxLeft = u8(20 - wBoxMiddle) >> 1      # x: centred
	ld a, $14
	sub c
	srl a
	ld [wBoxLeft], a
;>     wRoomHeight = mem[u16(header + 1)]       # height
	ld a, [hl]
	ld [wRoomHeight], a
	ld c, a
;>     wRoomY = u8(18 - wRoomHeight) >> 1  # y
	ld a, $12
	sub c
	srl a
	ld [wRoomY], a

jr_000_096f:
;> start = u16(addr(wTileBuffer) + 5 * u8(4 * wRoomY) + wBoxLeft)
	ld h, $00
	ld b, $00
	ld a, [wRoomY]
	ld l, a
	sla l
	sla l
	ld c, l
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	ld a, [wBoxLeft]
	call AddAToHL
	ld b, h
	ld c, l
	ld hl, wTileBuffer
	add hl, bc
;> mem16[0xCF0F] = mem16[0xCF11] = start        # the cell and the row pointer
	ld a, l
	ld [wMenuCursorTile], a
	ld [wMenuLastCol], a
	ld a, h
	ld [wCellPtrHi], a
	ld [wMenuLastRow], a
;> mem16[0xCF0B] = ReadPointer(RoomTableEntry(RoomBits))     # the bit map
	ld bc, RoomBits
	call RoomTableEntry
	call ReadPointer
	ld a, l
	ld [wBoxRight], a
	ld a, h
	ld [wRoomBitsHi], a
;> mem16[0xCF0D] = ReadPointer(RoomTableEntry(RoomObjects))  # the object stream
	ld bc, RoomObjects
	call RoomTableEntry
	call ReadPointer
	ld a, l
	ld [wRightCorridor], a
	ld a, h
	ld [wRoomBitsByte], a
;> fill(addr(wTileBuffer), 0xF0, 0x168)         # all wall
	ld hl, wTileBuffer
	ld bc, $0168

jr_000_09c7:
	ld a, $f0
	ld [hli], a
	dec bc
	ld a, c
	and a
	jr nz, jr_000_09c7

	ld a, b
	and a
	jr nz, jr_000_09c7

;> bits = mem16[0xCF0B]
	ld a, [wBoxRight]
	ld l, a
	ld a, [wRoomBitsHi]
	ld h, a
;> for row in range(wRoomHeight or 256):
	ld a, [wRoomHeight]
	ld c, a

jr_000_09df:
;>     for col in range(wBoxMiddle or 256):
	ld a, [wBoxMiddle]
	ld b, a

jr_000_09e3:
;>         if col % 8 == 0:
;>             byte, bits = mem[bits], u16(bits + 1)
	ld d, $08
	ld a, [hli]

jr_000_09e6:
;>         BuildRoomCell(byte & (0x80 >> (col % 8)))
	sla a
	call BuildRoomCell
;>     NextRoomRow()
	dec b
	jr nz, jr_000_09f6

	call NextRoomRow
	dec c
	jr nz, jr_000_09df

	jr jr_000_09fb

jr_000_09f6:
	dec d
	jr nz, jr_000_09e6

	jr jr_000_09e3

jr_000_09fb:
;> if wGameMode:                                # HEADING OUT?: the corridors
	ld a, [wGameMode]
	and a
	jp z, Jump_000_0a92

;>     shapes = mem[ReadPointer(RoomTableEntry(RoomHeaders))]
	ld bc, RoomHeaders
	call RoomTableEntry
	call ReadPointer
	ld a, [hl]
	ld c, a
;>     if wMirror == 1:                     # mirrored: the corridors upside down too
	ld a, [wMirror]
	cp $01
	jr nz, jr_000_0a29

;>         left, right = u8(5 - (shapes >> 4)), u8(5 - (shapes & 0x0F))
;>         shapes = u8(((left << 4) | (left >> 4)) + right)
	ld a, c
	and $0f
	ld b, a
	ld a, $05
	sub b
	ld d, a
	ld a, c
	swap a
	and $0f
	ld b, a
	ld a, $05
	sub b
	swap a
	add d
	ld c, a

jr_000_0a29:
;>     wRightCorridor = shapes & 0x0F              # the right corridor's shape
	ld a, c
	push af
	and $0f
	ld [wRightCorridor], a
;>     shape = shapes >> 4                      # the left one first
	pop af
	and $f0
	swap a
	ld c, $02

jr_000_0a37:
;>     for side in range(2):
;>         dest = 0xC100 | mem[CorridorStarts + shape]
	push af
	ld hl, CorridorStarts
	call AddAToHL
	ld e, [hl]
	ld d, $c1
;>         p = u16(CorridorShapes + u8(2 * shape))
;>         bits = mem[p]
	ld hl, CorridorShapes
	pop af
	add a
	call AddAToHL
	ld b, [hl]
;>         wRoomBitsByte = mem[u16(p + 1)]
	inc hl
	ld a, [hl]
	ld [wRoomBitsByte], a
;>         for half in range(2):                # 2 bytes: 4 rows of 4 cells
	push bc
	ld c, $02

jr_000_0a52:
;>             for k in range(8):
	ld hl, $0408

jr_000_0a55:
;>                 if bits & (0x80 >> k): mem[dest] = 0
	sla b
	jr nc, jr_000_0a5b

	xor a
	ld [de], a

jr_000_0a5b:
;>                 dest = u16(dest + 1)
	inc de
	dec h
	jr nz, jr_000_0a65

;>                 if k % 4 == 3: dest = (dest & 0xFF00) | u8(dest + 16)
	ld a, $10
	add e
	ld e, a
	ld h, $04

jr_000_0a65:
	dec l
	jr nz, jr_000_0a55

;>             bits = wRoomBitsByte
	ld a, [wRoomBitsByte]
	ld b, a
	dec c
	jr nz, jr_000_0a52

;>         if side == 0: shape = u8(wRightCorridor + 6)
	pop bc
	dec c
	jr z, jr_000_0a7a

	ld a, [wRightCorridor]
	add $06
	jr jr_000_0a37

jr_000_0a7a:
;>     wTileBuffer[178] = 0xC0                       # Kwirk, at the right end of row 8
	ld a, $c0
	ld de, $c1b2
	ld [de], a
;>     wTileBuffer[179] = wTileBuffer[161] = wTileBuffer[160] = 0   # floor at both ends of row 8
	xor a
	inc de
	ld [de], a
	ld de, $c1a1
	ld [de], a
	dec de
	ld [de], a
;>     if wMirror: MirrorRoom()
	ld a, [wMirror]
	and a
	jr z, jr_000_0a92

	call MirrorRoom

Jump_000_0a92:
jr_000_0a92:
;> for p in range(addr(wTileBuffer), addr(wTileBuffer) + 0x168):
	ld hl, wTileBuffer
	ld bc, $0168

jr_000_0a98:
;>     if IsWall(mem[p]): ShapeWall(p)
	ld a, [hl]
	call IsWall
	call c, ShapeWall
	inc hl
	dec bc
	ld a, c
	and a
	jr nz, jr_000_0a98

	ld a, b
	and a
	jr nz, jr_000_0a98

;> return
	ret


;@ HEADING OUT?: where each corridor shape starts in wTileBuffer (low byte; 6 left, 6 right).
CorridorStarts::
	db $7a, $8e, $a2, $a2, $a2, $a2, $86, $9a, $ae, $ae, $ae, $ae


;@ HEADING OUT?: the corridor shapes, 4 x 4 cells each, one bit per cell (1 = floor), 2 bytes a shape.
CorridorShapes::
	db $74, $c0, $7c, $00, $f0, $00, $c7, $00, $c4, $70, $c4, $47, $e2, $30, $e3, $00
	db $f0, $00, $3e, $00, $32, $e0, $32, $2e

;@ def RoomTableEntry(table: bc) -> hl
;@ path: room/build
;@ The address of the current room's entry in one of the room tables
;@ (RoomHeaders, RoomBits, RoomObjects: a word per room).
;@ reads: wRoom
;@ sig: a5a566b2
RoomTableEntry::
;> return u16(table + 2 * wRoom)
	ld a, [wRoom]
	ld h, b
	ld l, c
	push af
	call AddAToHL
	pop af
	call AddAToHL
	ret


;@ def ReadPointer(ptr: hl) -> hl
;@ path: lib/memory
;@ The little-endian word at ptr.
;@ sig: 74c2921b
ReadPointer::
;> return mem16[ptr]
	ld a, [hli]
	ld b, a
	ld a, [hl]
	ld h, a
	ld l, b
	ret


;@ def BuildRoomCell(bit: carry)
;@ path: room/build
;@ One cell of the room's bit map: a 1 bit takes the next object from the object
;@ stream; a 0 bit makes the cell floor, unless an object drawn earlier (a block's
;@ other cells, a turnstile's arm) is there already. Keeps every register.
;@ test: p = rand_ram(400) + 40; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ test: s = rand_ram(2); mem[0xCF0D] = s & 0xFF; mem[0xCF0E] = s >> 8
;@ test: mem[p] = rng.choice([0xF0, 0xF0, rand(0, 255)])
;@ sig: 4d300304
BuildRoomCell::
;> if bit:
	push af
	push hl
	push bc
	push de
	jr nc, jr_000_0aed

;>     tile = ReadRoomObject()
	call ReadRoomObject
	jr jr_000_0afa

jr_000_0aed:
;> elif mem[mem16[0xCF0F]] == 0xF0:            # still wall: make it floor
	call RoomCellPtr
	ld a, [hl]
	cp $f0
	jr nz, jr_000_0af8

;>     tile = 0
	xor a
	jr jr_000_0afa

jr_000_0af8:
;> else:
;>     tile = 0xFF                             # keep what is there
	ld a, $ff

jr_000_0afa:
;> PutRoomTile(tile)
	call PutRoomTile
	pop de
	pop bc
	pop hl
	pop af
;> return
	ret


;@ def PutRoomTile(tile: a)
;@ path: room/build
;@ Writes a tile at the cell pointer ($CF0F) and moves it one cell on. $FF leaves
;@ the cell alone; a hole ($E0) under something already drawn turns that tile
;@ into its "in a hole" variant (+$10). Clears the block flag ($CF15).
;@ writes: wCellPtrHi, wMenuCursorTile, wObjInHole
;@ reads: wCellPtrHi, wMenuCursorTile
;@ test: tile = rng.choice([0xFF, 0xE0, 0xE0, rand(0, 255)])
;@ test: p = rand_ram(2); mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ test: mem[p] = rng.choice([0xF0, rand(0, 255)])
;@ sig: bc5d2f0c
PutRoomTile::
;> p = mem16[0xCF0F]                           # the cell pointer
	push af
	ld a, [wMenuCursorTile]
	ld l, a
	ld a, [wCellPtrHi]
	ld h, a
	pop af
;> if tile != 0xFF:
	cp $ff
	jr z, jr_000_0b20

;>     if tile == 0xE0 and mem[p] != 0xF0:
	cp $e0
	jr nz, jr_000_0b1f

	ld a, [hl]
	cp $f0
	jr z, jr_000_0b1d

;>         tile = u8(mem[p] + 0x10)
	add $10
	jr jr_000_0b1f

jr_000_0b1d:
	ld a, $e0

jr_000_0b1f:
;>     mem[p] = tile
	ld [hl], a

jr_000_0b20:
;> mem16[0xCF0F] = u16(p + 1)
	inc hl
	ld a, l
	ld [wMenuCursorTile], a
	ld a, h
	ld [wCellPtrHi], a
;> wObjInHole = 0
	xor a
	ld [wObjInHole], a
;> return
	ret


;@ def NextRoomRow()
;@ path: room/build
;@ Moves the row pointer ($CF11) down one screen row and the cell pointer
;@ ($CF0F) to its start. Keeps every register but bc and de.
;@ writes: wCellPtrHi, wMenuCursorTile, wMenuLastCol, wMenuLastRow
;@ reads: wMenuLastCol, wMenuLastRow
;@ sig: b76f4513
NextRoomRow::
;> row = u16(mem16[0xCF11] + 20)
	push af
	push hl
	ld a, [wMenuLastCol]
	ld l, a
	ld a, [wMenuLastRow]
	ld h, a
	call StepDown
;> mem16[0xCF0F] = row
	ld a, l
	ld [wMenuCursorTile], a
	ld [wMenuLastCol], a
;> mem16[0xCF11] = row
	ld a, h
	ld [wCellPtrHi], a
	ld [wMenuLastRow], a
;> return
	pop hl
	pop af
	ret


;@ def ReadRoomObject() -> a
;@ path: room/objects
;@ The next byte of the room's object stream ($CF0D), decoded into the tile of
;@ the current cell.
;@ writes: wRightCorridor, wRoomBitsByte
;@ reads: wRightCorridor, wRoomBitsByte
;@ test: p = rand_ram(400) + 40; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ test: s = rand_ram(2); mem[0xCF0D] = s & 0xFF; mem[0xCF0E] = s >> 8
;@ sig: cbc05af1
ReadRoomObject::
;> p = mem16[0xCF0D]
	ld a, [wRightCorridor]
	ld l, a
	ld a, [wRoomBitsByte]
	ld h, a
;> obj = mem[p]
	ld a, [hli]
	push af
;> mem16[0xCF0D] = u16(p + 1)
	ld a, l
	ld [wRightCorridor], a
	ld a, h
	ld [wRoomBitsByte], a
	pop af
;> return DecodeRoomObject(obj)
	call DecodeRoomObject
	ret


;@ def DecodeRoomObject(obj: a) -> a
;@ path: room/objects
;@ One object of a room, by its high nibble: 0 = wall or a character
;@ (ObjectTiles), 1-4 = a block (DrawBlock draws its other cells), 5-8 = the
;@ same blocks with the flag $CF15 set, A = a hole or the stairs (HoleTiles), anything else =
;@ a turnstile (DrawTurnstile). Returns the tile of the current cell.
;@ writes: wObjInHole
;@ test: p = rand_ram(400) + 40; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ sig: a7a954d0
DecodeRoomObject::
;> kind, n = obj >> 4, obj & 0x0F
	ld bc, $0004
	ld e, a

jr_000_0b67:
	srl a
	rr b
	dec c
	jr nz, jr_000_0b67

	and $0f
	swap b
;> if kind == 0:
	and a
	jr nz, jr_000_0b7a

;>     return ObjectTile(n)
	call ObjectTile
	jr jr_000_0ba3

jr_000_0b7a:
;> if kind == 0x0A:
	cp $0a
	jr nz, jr_000_0b83

;>     return HoleTile(n)
	call HoleTile
	jr jr_000_0ba3

jr_000_0b83:
;> if kind < 5:
	cp $05
	jr nc, jr_000_0b8d

;>     return DrawBlock(obj)
	ld a, e
	call DrawBlock
	jr jr_000_0ba3

jr_000_0b8d:
;> if kind < 9:
	cp $09
	jr nc, jr_000_0ba0

;>     wObjInHole = 1
	push af
	ld a, $01
	ld [wObjInHole], a
	pop af
;>     return DrawBlock(obj - 0x40)
	ld a, e
	sub $40
	call DrawBlock
	jr jr_000_0ba3

jr_000_0ba0:
;> return DrawTurnstile(n)
	call DrawTurnstile

jr_000_0ba3:
	ret


;@ def RoomCellPtr() -> hl
;@ path: room/build
;@ The cell pointer ($CF0F). Keeps a.
;@ reads: wCellPtrHi, wMenuCursorTile
;@ sig: cdfce434
RoomCellPtr::
;> return mem16[0xCF0F]
	push af
	ld a, [wMenuCursorTile]
	ld l, a
	ld a, [wCellPtrHi]
	ld h, a
	pop af
	ret


;@ def ObjectTile(n: b) -> a
;@ path: room/objects
;@ Objects $00-$04: wall ($F0) or one of the characters ($C0-$C3).
;@ sig: 1d270ba5
ObjectTile::
;> return mem[ObjectTiles + n]
	ld a, b
	ld hl, ObjectTiles
	call AddAToHL
	ld a, [hl]
	ret


;@ def HoleTile(n: b) -> a
;@ path: room/objects
;@ Objects $A0 and $A1: a hole ($E0) or the stairs ($10).
;@ sig: d880352b
HoleTile::
;> return mem[HoleTiles + n]
	ld a, b
	ld hl, HoleTiles
	call AddAToHL
	ld a, [hl]
	ret


;@ def StartBlock()
;@ path: room/objects
;@ A block starts at the current cell: the block pointer ($CF13) := the cell
;@ pointer. Keeps every register.
;@ writes: wBlockPtrHi, wMenuLastColRows
;@ reads: wCellPtrHi, wMenuCursorTile
;@ sig: 5da1d24c
StartBlock::
;> mem16[0xCF13] = mem16[0xCF0F]
	push af
	ld a, [wMenuCursorTile]
	ld [wMenuLastColRows], a
	ld a, [wCellPtrHi]
	ld [wBlockPtrHi], a
	pop af
;> return
	ret


;@ def DrawBlock(shape: a) -> a
;@ path: room/objects
;@ A block, 1-6 cells wide and up to 15 high, from the current cell right and
;@ down: $10 = 1 x 1, $11-$1E = one column 2-15 high, $1F/$2D/$36/$3C/$41 = one
;@ row 2-6 wide, $20-$2C = 2 wide, $2E-$35 = 3 wide, $37-$3B = 4 wide, $3D-$40 =
;@ 5 wide, $42-$44 = 6 wide (2 rows and more). Writes the other cells and
;@ returns the tile of the top-left one. Block tiles are $40 plus the sides that
;@ join another cell of the block: 1 right, 2 down, 4 left, 8 up.
;@ writes: wBlockPtrHi, wMenuLastColRows, wMenuRowStep
;@ reads: wBlockPtrHi, wMenuLastColRows, wMenuRowStep
;@ test: shape = rand(0x10, 0x4F); mem[0xCF15] = rng.choice([0, 1])
;@ test: p = rand_ram(330); mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ sig: 400026f9
DrawBlock::
;> if shape == 0x10:                            # 1 x 1
	cp $10
	jr nz, jr_000_0bdc

;>     return BlockAnchorTile(0x40)
	ld a, $40
	call BlockAnchorTile
	jp Jump_000_0cfd


jr_000_0bdc:
;> if shape < 0x1F:                             # one column
	cp $1f
	jr nc, jr_000_0bf9

;>     StartBlock()
	call StartBlock
;>     if u8(shape - 0x11): BlockDownN(0x4A, u8(shape - 0x11))
	sub $11
	jr z, jr_000_0bec

	ld b, $4a
	call BlockDownN

jr_000_0bec:
;>     BlockDown(0x48)
	ld b, $48
	call BlockDown
;>     return BlockAnchorTile(0x42)
	ld a, $42
	call BlockAnchorTile
	jp Jump_000_0cfd


jr_000_0bf9:
;> StartBlock()
	ld b, $45
	call StartBlock
;> if shape in (0x1F, 0x2D, 0x36, 0x3C, 0x41):    # one row
	cp $1f
	jr z, jr_000_0c2c

	cp $2d
	jr nz, jr_000_0c0d

;>     if shape != 0x1F: BlockRightN(0x45, (0x2D, 0x36, 0x3C, 0x41).index(shape) + 1)
	ld a, $01
	call BlockRightN
	jr jr_000_0c2c

jr_000_0c0d:
	cp $36
	jr nz, jr_000_0c18

	ld a, $02
	call BlockRightN
	jr jr_000_0c2c

jr_000_0c18:
	cp $3c
	jr nz, jr_000_0c23

	ld a, $03
	call BlockRightN
	jr jr_000_0c2c

jr_000_0c23:
	cp $41
	jr nz, jr_000_0c39

	ld a, $04
	call BlockRightN

jr_000_0c2c:
;>     BlockRight(0x44)
	ld b, $44
	call BlockRight
;>     return BlockAnchorTile(0x41)
	ld a, $41
	call BlockAnchorTile
	jp Jump_000_0cfd


jr_000_0c39:
;> StartBlock()
	call StartBlock
;> if shape < 0x2D:                             # 2 wide
	cp $2d
	jr nc, jr_000_0c6d

;>     rows = shape - 0x20                      # rows between the top and the bottom one
	sub $20
	ld c, a
	jr z, jr_000_0c4a

;>     if rows: BlockDownN(0x4B, rows)
	ld b, $4b
	call BlockDownN

jr_000_0c4a:
;>     BlockDown(0x49)
	ld b, $49
	call BlockDown
;>     StartBlock()
	call StartBlock
;>     BlockRight(0x46)
	ld b, $46
	call BlockRight
;>     if rows: BlockDownN(0x4E, rows)
	ld a, c
	and a
	jr z, jr_000_0c60

	ld b, $4e
	call BlockDownN

jr_000_0c60:
;>     BlockDown(0x4C)
	ld b, $4c
	call BlockDown
;>     return BlockAnchorTile(0x43)
	ld a, $43
	call BlockAnchorTile
	jp Jump_000_0cfd


jr_000_0c6d:
;> StartBlock()
	call StartBlock
;> if shape < 0x36: rows, middle = shape - 0x2E, 1    # 3-6 wide: middle columns
	cp $36
	jr nc, jr_000_0c7a

	sub $2e
	ld c, $01
	jr jr_000_0c96

jr_000_0c7a:
;> elif shape < 0x3C: rows, middle = shape - 0x37, 2
	cp $3c
	jr nc, jr_000_0c84

	sub $37
	ld c, $02
	jr jr_000_0c96

jr_000_0c84:
;> elif shape < 0x41: rows, middle = shape - 0x3D, 3
	cp $41
	jr nc, jr_000_0c8e

	sub $3d
	ld c, $03
	jr jr_000_0c96

jr_000_0c8e:
;> elif shape >= 0x45: return shape             # not a block
	cp $45
	jr nc, jr_000_0cfd

;> else: rows, middle = shape - 0x42, 4
	sub $42
	ld c, $04

jr_000_0c96:
;> wMenuRowStep = rows
	ld [wMenuRowStep], a
;> if rows: BlockDownN(0x4B, rows)              # the left column
	cp $00
	jr z, jr_000_0ca2

	ld b, $4b
	call BlockDownN

jr_000_0ca2:
;> BlockDown(0x49)
	ld b, $49
	call BlockDown
;> StartBlock()
	call StartBlock
;> for _ in range(middle):
	ld b, $47

jr_000_0cac:
;>     BlockRight(0x47)
	call BlockRight
;>     top = mem16[0xCF13]
	ld a, [wMenuLastColRows]
	ld e, a
	ld a, [wBlockPtrHi]
	ld d, a
;>     if wMenuRowStep: BlockDownN(0x4F, wMenuRowStep)
	ld a, [wMenuRowStep]
	and a
	jr z, jr_000_0cc2

	ld b, $4f
	call BlockDownN

jr_000_0cc2:
;>     BlockDown(0x4D)
	ld b, $4d
	call BlockDown
;>     mem16[0xCF13] = top                      # back up to the top of the column
	ld a, c
	dec a
	jr z, jr_000_0cd8

	ld c, a
	ld a, d
	ld [wBlockPtrHi], a
	ld a, e
	ld [wMenuLastColRows], a
	ld b, $47
	jr jr_000_0cac

jr_000_0cd8:
	ld a, d
	ld [wBlockPtrHi], a
	ld a, e
	ld [wMenuLastColRows], a
;> BlockRight(0x46)                             # the right column
	ld b, $46
	call BlockRight
;> if wMenuRowStep:
	ld a, [wMenuRowStep]
	and a
	jr z, jr_000_0cf3

;>     for _ in range(wMenuRowStep): BlockDown(0x4E)
jr_000_0ceb:
	ld b, $4e
	call BlockDown
	dec a
	jr nz, jr_000_0ceb

jr_000_0cf3:
;> BlockDown(0x4C)
	ld b, $4c
	call BlockDown
;> return BlockAnchorTile(0x43)
	ld a, $43
	call BlockAnchorTile

Jump_000_0cfd:
jr_000_0cfd:
	ret


;@ def BlockDown(tile: b)
;@ path: room/objects
;@ Moves the block pointer ($CF13) one row down and puts a tile there. Keeps
;@ every register.
;@ writes: wBlockPtrHi, wMenuLastColRows
;@ reads: wBlockPtrHi, wMenuLastColRows
;@ test: p = rand_ram(30); mem[0xCF13] = p & 0xFF; mem[0xCF14] = p >> 8
;@ sig: 8028ec4a
BlockDown::
;> p = u16(mem16[0xCF13] + 20)
	push af
	push hl
	ld a, [wMenuLastColRows]
	add $14
	ld l, a
;> mem16[0xCF13] = p
	ld [wMenuLastColRows], a
	ld a, [wBlockPtrHi]
	adc $00
	ld [wBlockPtrHi], a
	ld h, a
;> mem[p] = tile
	ld [hl], b
;> return
	pop hl
	pop af
	ret


;@ def BlockRight(tile: b)
;@ path: room/objects
;@ Moves the block pointer ($CF13) one cell right and puts a tile there. Keeps
;@ every register.
;@ writes: wBlockPtrHi, wMenuLastColRows
;@ reads: wBlockPtrHi, wMenuLastColRows
;@ test: p = rand_ram(30); mem[0xCF13] = p & 0xFF; mem[0xCF14] = p >> 8
;@ sig: 8ea03881
BlockRight::
;> p = u16(mem16[0xCF13] + 1)
	push af
	push hl
	ld a, [wMenuLastColRows]
	add $01
	ld l, a
;> mem16[0xCF13] = p
	ld [wMenuLastColRows], a
	ld a, [wBlockPtrHi]
	adc $00
	ld h, a
	ld [wBlockPtrHi], a
;> mem[p] = tile
	ld [hl], b
;> return
	pop hl
	pop af
	ret


;@ def BlockDownN(tile: b, n: a)
;@ path: room/objects
;@ BlockDown n times: a column of the same tile.
;@ test: n = rand(1, 12); p = rand_ram(260); mem[0xCF13] = p & 0xFF; mem[0xCF14] = p >> 8
;@ sig: ec29a1e2
BlockDownN::
;> for _ in range(n or 256):
;>     BlockDown(tile)
	call BlockDown
	dec a
	jr nz, BlockDownN

;> return
	ret


;@ def BlockRightN(tile: b, n: a)
;@ path: room/objects
;@ BlockRight n times: a row of the same tile.
;@ test: n = rand(1, 12); p = rand_ram(20); mem[0xCF13] = p & 0xFF; mem[0xCF14] = p >> 8
;@ sig: 2b5e11bd
BlockRightN::
;> for _ in range(n or 256):
;>     BlockRight(tile)
	call BlockRight
	dec a
	jr nz, BlockRightN

;> return
	ret


;@ def BlockAnchorTile(tile: a) -> a
;@ path: room/objects
;@ The tile of a block's top-left cell: +$10 when the object came from the
;@ second set ($5x-$8x, flag $CF15).
;@ reads: wObjInHole
;@ test: mem[0xCF15] = rng.choice([0, 1, rand(0, 255)])
;@ sig: b1f353b3
BlockAnchorTile::
;> return u8(tile + 0x10) if wObjInHole == 1 else tile
	push bc
	push af
	ld a, [wObjInHole]
	ld b, a
	pop af
	dec b
	jr nz, jr_000_0d48

	add $10

jr_000_0d48:
	pop bc
	ret


;@ def DrawTurnstile(kind: b) -> a
;@ path: room/objects
;@ A turnstile: draws its arms around the current cell (TurnstileArms says
;@ which) and returns the tile of its centre (TurnstileTiles). An arm on a hole
;@ already drawn (above, left) gets the "in a hole" tile; the arms below and to
;@ the right are drawn before their cells, which PutRoomTile then adjusts.
;@ test: p = rand_ram(30) + 20; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ sig: 0915a91a
DrawTurnstile::
;> arms = mem[TurnstileArms + kind]
	ld a, b
	ld hl, TurnstileArms
	call AddAToHL
	ld a, [hl]
;> if arms & 1: TurnstileArmRight()
	srl a
	call c, TurnstileArmRight
;> if arms & 2: TurnstileArmLeft()
	srl a
	call c, TurnstileArmLeft
;> if arms & 4: TurnstileArmDown()
	srl a
	call c, TurnstileArmDown
;> if arms & 8: TurnstileArmUp()
	srl a
	call c, TurnstileArmUp
;> return mem[TurnstileTiles + kind]
	ld a, b
	ld hl, TurnstileTiles
	call AddAToHL
	ld a, [hl]
	ret


;@ def TurnstileArmUp()
;@ path: room/objects
;@ The arm above the current cell: $80, or $90 over a hole. Keeps a.
;@ test: p = rand_ram(2) + 20; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8; mem[p - 20] = rng.choice([0xE0, rand(0, 255)])
;@ sig: cf44c38c
TurnstileArmUp::
;> p = u16(mem16[0xCF0F] - 20)
	push af
	call RoomCellPtr
	call StepUp
;> mem[p] = 0x90 if mem[p] == 0xE0 else 0x80
	cp $e0
	jr z, jr_000_0d7e

	ld a, $80
	jr jr_000_0d80

jr_000_0d7e:
	ld a, $90

jr_000_0d80:
	ld [hl], a
;> return
	pop af
	ret


;@ def TurnstileArmDown()
;@ path: room/objects
;@ The arm below the current cell: $82. Keeps a.
;@ test: p = rand_ram(22); mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ sig: 1dc199ed
TurnstileArmDown::
;> p = u16(mem16[0xCF0F] + 20)
	push af
	call RoomCellPtr
	call StepDown
;> mem[p] = 0x82
	ld a, $82
	ld [hl], a
;> return
	pop af
	ret


;@ def TurnstileArmRight()
;@ path: room/objects
;@ The arm right of the current cell: $81. Keeps a.
;@ test: p = rand_ram(2); mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8
;@ sig: ab04694d
TurnstileArmRight::
;> p = u16(mem16[0xCF0F] + 1)
	push af
	call RoomCellPtr
	call StepRight
;> mem[p] = 0x81
	ld a, $81
	ld [hl], a
;> return
	pop af
	ret


;@ def TurnstileArmLeft()
;@ path: room/objects
;@ The arm left of the current cell: $83, or $93 over a hole. Keeps a.
;@ test: p = rand_ram(2) + 1; mem[0xCF0F] = p & 0xFF; mem[0xCF10] = p >> 8; mem[p - 1] = rng.choice([0xE0, rand(0, 255)])
;@ sig: ecd96ac5
TurnstileArmLeft::
;> p = u16(mem16[0xCF0F] - 1)
	push af
	call RoomCellPtr
	call StepLeft
;> mem[p] = 0x93 if mem[p] == 0xE0 else 0x83
	cp $e0
	jr z, jr_000_0daa

	ld a, $83
	jr jr_000_0dac

jr_000_0daa:
	ld a, $93

jr_000_0dac:
	ld [hl], a
;> return
	pop af
	ret


;@ def ShapeWall(at: hl)
;@ path: room/walls
;@ Picks the tile of a wall cell from its four neighbours: which of them are
;@ wall too (WallTiles), so the walls join up.
;@ test: at = rand_ram(50) + 25
;@ test: for k in (-20, -1, 0, 1, 20): mem[at + k] = rng.choice([0xF0, 0, rand(0, 255)])
;@ sig: 1db1d393
ShapeWall::
;> above, below, left, right = (IsWall(mem[u16(at + k)]) for k in (-20, 20, -1, 1))
	push hl
	ld d, $00
	push hl
	call StepUp
	pop hl
	call IsWall
	rl d
	push hl
	call StepDown
	pop hl
	call IsWall
	rl d
	push hl
	call StepLeft
	pop hl
	call IsWall
	rl d
	call StepRight
	call IsWall
	rl d
;> mem[at] = mem[WallTiles + (above << 3 | below << 2 | left << 1 | right)]
	ld a, d
	ld hl, WallTiles
	call AddAToHL
	ld a, [hl]
	pop hl
	ld [hl], a
;> return
	ret


;@ def IsWall(tile: a) -> carry
;@ path: room/walls
;@ Tiles $F0-$FF are wall.
;@ sig: 6746a08e
IsWall::
;> return tile >= 0xF0
	cp $f0
	jr c, jr_000_0dea

	scf
	jr jr_000_0deb

jr_000_0dea:
	ccf

jr_000_0deb:
	ret


;@ def MirrorRoom()
;@ path: room/mirror
;@ HEADING OUT?: turns the 8 x 6 room (columns 6-13, rows 6-11) upside down,
;@ swapping rows and flipping every tile that points up or down (MirrorTile).
;@ writes: wBoxLeft
;@ reads: wBoxLeft
;@ sig: 72250542
MirrorRoom::
;> top, bottom, n = 0xC17E, 0xC1E2, 8            # wTileBuffer rows 6 and 11, column 6
	ld hl, $c17e
	ld de, $c1e2
	ld c, $18
	ld b, $08

jr_000_0df6:
;> for _ in range(24):
;>     wBoxLeft = MirrorTile(mem[top])             # scratch
	ld a, [hl]
	call MirrorTile
	ld [wBoxLeft], a
;>     mem[top] = MirrorTile(mem[bottom])
	ld a, [de]
	call MirrorTile
	ld [hl], a
;>     mem[bottom] = wBoxLeft
	ld a, [wBoxLeft]
	ld [de], a
;>     top, bottom, n = u16(top + 1), u16(bottom + 1), n - 1
	inc hl
	inc de
	dec b
;>     if n == 0:
;>         top, bottom, n = MirrorNextRow(top, bottom)
	call z, MirrorNextRow
	dec c
	jr nz, jr_000_0df6

;> return
	ret


;@ def MirrorTile(tile: a) -> a
;@ path: room/mirror
;@ The tile seen upside down: MirrorTilesTo for the 28 tiles in
;@ MirrorTilesFrom, any other tile stays. Keeps bc, de, hl.
;@ test: tile = rng.choice([0x42, 0x49, 0x92, 0xA9, rand(0, 255)])
;@ sig: 7d11f142
MirrorTile::
;> for i in range(28):
	push hl
	push bc
	push de
	ld e, a
	ld c, $1c
	ld d, $00
	ld hl, MirrorTilesFrom

jr_000_0e1b:
;>     if mem[MirrorTilesFrom + i] == tile:
	ld a, [hli]
	ld b, a
	ld a, e
	sub b
	jr nz, jr_000_0e26

;>         return MirrorTileLookup(i)
	call MirrorTileLookup
	jr jr_000_0e2c

jr_000_0e26:
	dec c
	jr z, jr_000_0e2c

	inc d
	jr jr_000_0e1b

jr_000_0e2c:
;> return tile
	ld a, e
	pop de
	pop bc
	pop hl
	ret


;@ def MirrorTileLookup(i: d) -> e
;@ path: room/mirror
;@ Entry i of MirrorTilesTo.
;@ sig: 9c08f5f3
MirrorTileLookup::
;> return mem[MirrorTilesTo + i]
	push hl
	ld hl, MirrorTilesTo
	ld a, d
	call AddAToHL
	ld a, [hl]
	ld e, a
	pop hl
	ret


;@ def MirrorNextRow(top: hl, bottom: de) -> (hl, de, b)
;@ path: room/mirror
;@ MirrorRoom: from the end of a top row to the start of the next row down,
;@ and from the end of a bottom row to the start of the row above (only the
;@ low byte of de changes); 8 cells again.
;@ sig: 9006d54c
MirrorNextRow::
;> return u16(top + 12), (bottom & 0xFF00) | u8(bottom - 0x1C), 8
	ld a, $0c
	call AddAToHL
	ld a, e
	sub $1c
	ld e, a
	ld b, $08
	ret


;@ The room tiles that change when a room is mirrored top to bottom ...
MirrorTilesFrom::
	db $42, $43, $46, $47, $48, $49, $4c, $4d, $52, $53, $56, $57, $58, $59, $5c, $5d
	db $a0, $a2, $a4, $a5, $a6, $a7, $a9, $ab, $80, $82, $90, $92


;@ ... and what each becomes (up and down swapped).
MirrorTilesTo::
	db $48, $49, $4c, $4d, $42, $43, $46, $47, $58, $59, $5c, $5d, $52, $53, $56, $57
	db $a2, $a0, $a5, $a4, $a7, $a6, $ab, $a9, $82, $80, $92, $90


;@ Room objects $00-$04: wall, then the characters (Kwirk first).
ObjectTiles::
	db $f0, $c0, $c1, $c2, $c3


;@ Room objects $A0 and $A1: a hole ($E0) and the stairs ($10).
HoleTiles::
	db $e0, $10


;@ Room objects $9x-$Fx: which arms the turnstile has (bit 0 right, 1 left, 2 down, 3 up), by the low nibble.
TurnstileArms::
	db $08, $01, $04, $02, $03, $0c, $09, $05, $06, $0a, $0d, $07, $0e, $0b, $0f


;@ ... and the tile of its centre.
TurnstileTiles::
	db $a0, $a1, $a2, $a3, $ae, $ad, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac


;@ The wall tile for each pattern of wall neighbours (bit 3 above, 2 below, 1 left, 0 right).
WallTiles::
	db $f0, $f1, $f4, $f5, $f2, $f3, $f6, $f7, $f8, $f9, $fc, $fd, $fa, $fb, $fe, $ff

;@ def PlayRoom()
;@ path: game/loop
;@ Plays the room SetUpLevel has built: resets the sound, shows the number
;@ of rooms in the course (HEADING OUT? and VS MODE, the partner's too),
;@ starts the music, gives the control to the first character and runs
;@ GameLoop until the room is cleared.
;@ writes: wBLatch, wClockFrames, wClockMinutes, wClockSeconds, wClockSecondsTotal, wCourseFinished, wLinkState, wTileBuffer
;@ reads: wCourseLength, wCourseRoom, wGameMode, wLinkMaster, wVsPartnerLength
;@ test: skip runs the whole room
;@ sig: 046b91a2
PlayRoom::
;> InitSound()
	call InitSound
;> DemoSerialListen()
	call DemoSerialListen
;> wBLatch = 0
	xor a
	ld [wBLatch], a
;> if wGameMode:
	ld a, [wGameMode]
	and a
	jr z, jr_000_0eea

;>     wTileBuffer[179] = 0xF0                          # wTileBuffer row 8, column 19: a wall at the corridor's far end
	ld a, $f0
	ld [wTileBuffer + 179], a
;>     n = ToBCDBlank(wCourseLength)
	ld a, [wCourseLength]
	call ToBCDBlank
;>     PrintBCD(n, 0x9A03)                         # the rooms of the course, in the bottom left box
	ld hl, $9a03
	call PrintBCD
;>     if wGameMode == 2:
	ld a, [wGameMode]
	cp $02
	jr nz, jr_000_0eea

;>         n = ToBCDBlank(wVsPartnerLength)
	ld a, [wVsPartnerLength]
	call ToBCDBlank
;>         PrintBCD(n, 0x9823)                     # VS MODE: the partner's, at the top
	ld hl, $9823
	call PrintBCD

jr_000_0eea:
;> if wGameMode == 2:
	ld a, [wGameMode]
	cp $02
	jr nz, jr_000_0f08

;>     if not wLinkMaster:
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_0f03

;>         rSB = wCourseRoom
	ld a, [wCourseRoom]
	ldh [rSB], a
;>         rSC = (rSC & 0xFE) | 0x80               # offer it on the partner's clock
	ld hl, $ff02
	res 0, [hl]
	set 7, [hl]

jr_000_0f03:
;>     wLinkState = 8
	ld a, $08
	ld [wLinkState], a

jr_000_0f08:
;> ResetGameState()
	call ResetGameState
;> DrawCharacters()
	call DrawCharacters
;> if not wGameMode:
	ld a, [wGameMode]
	and a
	jr nz, jr_000_0f19

;>     QueueSound(1)
	ld b, $01
	rst $30
	jr jr_000_0f38

;> else:
jr_000_0f19:
;>     QueueSound(2)
	ld b, $02
	rst $30
;>     wCourseFinished = 0
	xor a
	ld [wCourseFinished], a
;>     CloseEntryDoor()
	call CloseEntryDoor
;>     for _ in range(0x65):                       # 101 frames
	ld b, $65

jr_000_0f25:
;>         WaitVBlank()
	call WaitVBlank
	dec b
	jr nz, jr_000_0f25

;>     wClockFrames = wClockMinutes = wClockSeconds = wClockSecondsTotal = 0
	xor a
	ld [wClockFrames], a
	ld [wClockMinutes], a
	ld [wClockSeconds], a
	ld [wClockSecondsTotal], a

jr_000_0f38:
;> NextCharacter()
	call NextCharacter
;> return GameLoop()                               # falls through

;@ def GameLoop()
;@ path: game/loop
;@ One frame of play: the clock (and in HEADING OUT? Call_3162), the
;@ buttons, the d-pad move and the step it starts (pushing a turnstile or a
;@ block), the character's walk animation, and the checks for the stairs
;@ (GOING UP?) or the corridor's end (HEADING OUT?). Returns when the room
;@ is cleared; otherwise waits for the next frame and goes round again.
;@ writes: wAnimTimer, wSplitSCX
;@ reads: wAnimTimer, wCharExited, wDemo, wGameMode, wMoveDir, wRoomDone, wStepKind, wStepOK, wStepping
;@ test: skip runs until the room is cleared
;@ sig: 1adf3878
GameLoop::
;> wSplitSCX = 0
	xor a
	ld [wSplitSCX], a
;> if wGameMode:
	ld a, [wGameMode]
	and a
	jr z, jr_000_0f59

	cp $02
	jr nz, jr_000_0f49

jr_000_0f49:
;>     PrintClock(0x9A0E)                           # the clock, in the bottom right box
	ld hl, $9a0e
	call PrintClock
;>     if wGameMode == 1:
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_0f59

;>         UpdateBonus()
	call UpdateBonus

jr_000_0f59:
;> wAnimTimer = u8(wAnimTimer - 1)
	ld a, [wAnimTimer]
	dec a
	ld [wAnimTimer], a
;> stepping = wStepping
	ld a, [wStepping]
	and a
	jr nz, jr_000_0f9c

;> if not stepping:
;>     if not wDemo:
	ld a, [wDemo]
	and a
	jr nz, jr_000_0f7d

;>         ReadJoypad()
	call ReadJoypad
;>         if not wGameMode: GoingUpButtons()
	ld a, [wGameMode]
	and a
	jr nz, jr_000_0f7a

	call GoingUpButtons
	jr jr_000_0f7d

;>         else: HeadingOutButtons()
jr_000_0f7a:
	call HeadingOutButtons

jr_000_0f7d:
;>     ReadMove()
	call ReadMove
;>     if wMoveDir:
	ld a, [wMoveDir]
	and a
	jr z, jr_000_0fa6

;>         TryStep()
	call TryStep
;>         if wStepOK:
	ld a, [wStepOK]
	and a
	jr z, jr_000_0fa6

;>             if wStepKind != 3:
	ld a, [wStepKind]
	cp $03
	jr z, jr_000_0f9c

;>                 ObjectToSprites()
	call ObjectToSprites
;>                 MoveObject()
	call MoveObject

;>             stepping = True
;> if stepping:
jr_000_0f9c:
;>     if wStepKind: MovePushedObject()
	ld a, [wStepKind]
	and a
	call nz, MovePushedObject
;>     StepFrame()
	call StepFrame

jr_000_0fa6:
;> AnimateCharacter()
	call AnimateCharacter
;> if wStepping: return GameLoopNextFrame()
	ld a, [wStepping]
	and a
	jr nz, jr_000_0fcb

;> if wGameMode:
	ld a, [wGameMode]
	and a
	jr z, jr_000_0fba

;>     CheckCorridorExit()
	call CheckCorridorExit
	jr jr_000_0fc3

;> else:
jr_000_0fba:
;>     CheckStairs()
	call CheckStairs
;>     if not wCharExited: return GameLoopNextFrame()
	ld a, [wCharExited]
	and a
	jr z, jr_000_0fcb

jr_000_0fc3:
;> CheckRoomCleared()
	call CheckRoomCleared
;> if wRoomDone: return
	ld a, [wRoomDone]
	and a
	ret nz
;> return GameLoopNextFrame()                      # falls through

;@ def GameLoopNextFrame()
;@ path: game/loop
;@ Sleeps until the VBlank interrupt, then the next frame of GameLoop.
;@ test: skip waits for the VBlank interrupt
;@ sig: 2b10d1da
GameLoopNextFrame::
jr_000_0fcb:
;> WaitVBlank()                                    # after a halt
	halt
	call WaitVBlank
;> return GameLoop()
	jp GameLoop


;@ def WaitVBlank()
;@ path: lib/timing
;@ Waits for the VBlank handler to finish a frame (hVBlankDone).
;@ writes: hVBlankDone, wLinkDone
;@ reads: hVBlankDone
;@ sig: c55221d0
WaitVBlank::
;> enable_interrupts()
	ei
;> wait_vblank_flag()
	ldh a, [hVBlankDone]
	and a
	jr z, WaitVBlank

;> hVBlankDone = 0
	xor a
	ldh [hVBlankDone], a
;> wLinkDone = 0
	ld [wLinkDone], a
;> return
	ret


;@ def VBlankHandler()
;@ path: system/interrupts
;@ The VBlank interrupt: copies the shadow OAM to OAM, runs the sound
;@ engine, tells WaitVBlank, counts the play clock (it stops at 60:00), then
;@ hands over to a link handler: one for each bit of the link state at $CF3A
;@ (the demo sets bit 0, so its handler can watch the buttons).
;@ writes: hVBlankDone, wClockFrames, wClockMinutes, wClockSeconds, wClockSecondsTotal, wLinkState
;@ reads: wClockFrames, wClockMinutes, wClockSeconds, wClockSecondsTotal, wDemo, wLinkAnswerWait, wLinkHandshake, wLinkState, wTitleOfferOff
;@ test: skip runs the OAM DMA routine in HRAM
;@ sig: 2383df76
VBlankHandler::
;> disable_interrupts()
	di
	push af
	push bc
	push de
	push hl
;> CopyOAMDMARoutine()
	call CopyOAMDMARoutine
;> hOAMDMA()                                       # the DMA routine in HRAM
	call hOAMDMA
;> UpdateSound()                                     # the sound engine
	call UpdateSound
;> hVBlankDone = 1
	ld a, $01
	ldh [hVBlankDone], a
;> wClockFrames = u8(wClockFrames + 1)
	ld a, [wClockFrames]
	inc a
	ld [wClockFrames], a
;> if wClockFrames == 60:
	cp $3c
	jr nz, jr_000_1023

;>     wClockFrames = 0
	xor a
	ld [wClockFrames], a
;>     if wClockSecondsTotal != 0xFF: wClockSecondsTotal += 1
	ld a, [wClockSecondsTotal]
	inc a
	jr z, jr_000_1009

	ld [wClockSecondsTotal], a

jr_000_1009:
;>     wClockSeconds = to_bcd(bcd_to_int(wClockSeconds) + 1)
	ld a, [wClockSeconds]
	add $01
	daa
	ld [wClockSeconds], a
;>     if wClockSeconds == 0x60:
	cp $60
	jr nz, jr_000_1023

;>         wClockSeconds = 0
	xor a
	ld [wClockSeconds], a
;>         wClockMinutes = to_bcd(bcd_to_int(wClockMinutes) + 1)
	ld a, [wClockMinutes]
	add $01
	daa
	ld [wClockMinutes], a

jr_000_1023:
;> if wClockMinutes >= 0x60:
	ld a, [wClockMinutes]
	cp $60
	jr c, jr_000_1033

;>     wClockMinutes = 0x60
	ld a, $60
	ld [wClockMinutes], a
;>     wClockSeconds = 0
	xor a
	ld [wClockSeconds], a

jr_000_1033:
;> if wLinkHandshake: return LinkFrameHandshake()
	ld a, [wLinkHandshake]
	and a
	jp nz, LinkFrameHandshake

;> if wLinkAnswerWait: return LinkFrameAnswer()
	ld a, [wLinkAnswerWait]
	and a
	jp nz, LinkFrameAnswer

;> if wDemo:
	ld a, [wDemo]
	and a
	jr z, jr_000_1053

;>     wLinkState = wDemo
	ld [wLinkState], a
;>     if not wTitleOfferOff: SerialOfferTitle()
	ld a, [wTitleOfferOff]
	and a
	jr nz, jr_000_1053

	call SerialOfferTitle

jr_000_1053:
;> state = wLinkState
	ld a, [wLinkState]
;> if state & 0x01: return LinkFrameDemo()
	bit 0, a
	jp nz, LinkFrameDemo

;> if state & 0x02: return LinkFrameButtons()
	bit 1, a
	jp nz, LinkFrameButtons

;> if state & 0x04: return LinkFrameSeed()
	bit 2, a
	jp nz, LinkFrameSeed

;> if state & 0x08: return LinkFrameProgress()
	bit 3, a
	jp nz, LinkFrameProgress

;> if state & 0x10: return LinkFrameSeedPick()
	bit 4, a
	jp nz, LinkFrameSeedPick

;> if state & 0x20: return LinkFrameStart()
	bit 5, a
	jp nz, LinkFrameStart

;> if state & 0x40: return LinkFrameContinue()
	bit 6, a
	jp nz, LinkFrameContinue

;> if state & 0x80: return LinkFrameRooms()
	bit 7, a
	jp nz, LinkFrameRooms
;> return VBlankFrameDone()                        # falls through

;@ def VBlankFrameDone()
;@ path: system/interrupts
;@ The end of the VBlank handler when no link handler took over: marks the
;@ frame done at $CF39 and returns from the interrupt.
;@ writes: wLinkDone
;@ test: skip pops the registers the VBlank handler saved
;@ sig: c1a59172
VBlankFrameDone::
;> wLinkDone = 1
	ld a, $01
	ld [wLinkDone], a
;> return VBlankReturn()                           # falls through

;@ def VBlankReturn()
;@ path: system/interrupts
;@ Restores the registers the VBlank handler saved and returns from the
;@ interrupt (the link handlers end here too).
;@ test: skip pops the registers the VBlank handler saved
;@ sig: aafffdef
VBlankReturn::
;> enable_interrupts()
	pop hl
	pop de
	pop bc
	pop af
	ei
;> return                                          # registers restored, reti
	reti


;@ def GoingUpButtons()
;@ path: game/input
;@ GOING UP?: A opens the pause window; Select (with more than one character
;@ left and none of them stepping) gives the control to the next character.
;@ writes: wStepKind
;@ reads: hJoyHeld, wCharsLeft, wStepping
;@ sig: f592a36c
GoingUpButtons::
;> if hJoyHeld & BTN_A: PauseWindow()
	ldh a, [hJoyHeld]
	bit 0, a
	call nz, PauseWindow
;> if wCharsLeft == 1: return
	ld a, [wCharsLeft]
	cp $01
	ret z

;> if hJoyHeld & BTN_SELECT and not wStepping:
	ldh a, [hJoyHeld]
	bit 2, a
	jr z, jr_000_10a8

	ld a, [wStepping]
	and a
	jr nz, jr_000_10a8

;>     QueueSound(0x0E)
	ld b, $0e
	rst $30
;>     NextCharacter()
	call NextCharacter

jr_000_10a8:
;> wStepKind = 3
	ld a, $03
	ld [wStepKind], a
;> return
	ret


;@ def HeadingOutButtons()
;@ path: game/input
;@ HEADING OUT? and VS MODE: A gives the room up and builds it again from the
;@ start (not in the demo).
;@ writes: wGiveUp, wTileBuffer
;@ reads: hJoyHeld, wDemo
;@ sig: 6c59535b
HeadingOutButtons::
;> if wDemo: return
	ld a, [wDemo]
	and a
	ret nz

;> if not (hJoyHeld & BTN_A): return
	ldh a, [hJoyHeld]
	bit 0, a
	ret z

;> QueueSound(0x13)
	ld b, $13
	rst $30
;> wGiveUp = 0x80
	ld a, $80
	ld [wGiveUp], a
;> BuildRoom()
	call BuildRoom
;> FindCharacters()
	call FindCharacters
;> wTileBuffer[179] = 0xF0                              # the wall at the corridor's far end again
	ld a, $f0
	ld [wTileBuffer + 179], a
;> DrawBufferTiles(0xC178, 0x78)                         # wTileBuffer rows 6-11
	ld hl, $c178
	ld bc, $0078
	call DrawBufferTiles
;> DrawBufferTiles(0xC178, 0x78)
	ld hl, $c178
	ld bc, $0078
	call DrawBufferTiles
;> DrawCharacters()
	call DrawCharacters
;> NextCharacter()
	call NextCharacter
;> return
	ret


;@ def ReadMoveHook()
;@ path: game/input
;@ Does nothing: an empty hook ReadMove calls after reading the joypad.
;@ sig: 30ba9599
ReadMoveHook::
;> return
	ret


;@ def ReadMove()
;@ path: game/input
;@ The move of this frame: in the demo from DemoInput, otherwise from the
;@ joypad (after waiting for the next frame).
;@ reads: wDemo
;@ sig: eae0b3e8
ReadMove::
;> if wDemo: return DemoInput()
	ld a, [wDemo]
	and a
	jp nz, DemoInput

;> WaitVBlank()
	call WaitVBlank
;> ReadJoypad()
	call ReadJoypad
;> ReadMoveHook()
	push bc
	call ReadMoveHook
	pop bc
;> return MoveFromJoypad()                         # falls through

;@ def MoveFromJoypad(idle: b = 0)
;@ path: game/input
;@ Turns the d-pad in hJoyHeld into wMoveDir (Down before Up before Left
;@ before Right) and the pixel steps wMoveDX / wMoveDY. A new direction
;@ also turns the character's sprite (and in the diagonal view its shadow)
;@ to face it. With no d-pad button held the direction becomes `idle`, the
;@ 0 ReadJoypad leaves in b.
;@ writes: wBLatch, wCharAttr, wMoveDX, wMoveDY, wMoveDir
;@ reads: hJoyHeld, wCharAttr, wCharacter, wDiagonalView, wMoveDir
;@ sig: 095c1efa
MoveFromJoypad::
;> if not hJoyHeld & 0xF0: wBLatch = 0
	ldh a, [hJoyHeld]
	and $f0
	jr nz, jr_000_1101

	xor a
	ld [wBLatch], a

jr_000_1101:
;> direction = idle
;> if hJoyHeld & BTN_DOWN:
	bit 7, a
	jr z, jr_000_110e

;>     direction = 3
	ld b, $03
;>     wMoveDY = 1
	ld a, $01
	ld [wMoveDY], a
	jr jr_000_1149

jr_000_110e:
;> elif hJoyHeld & BTN_UP:
	ldh a, [hJoyHeld]
	bit 6, a
	jr z, jr_000_111d

;>     direction = 1
	ld b, $01
;>     wMoveDY = 0xFF
	ld a, $ff
	ld [wMoveDY], a
	jr jr_000_1149

jr_000_111d:
;> elif hJoyHeld & BTN_LEFT:
	ldh a, [hJoyHeld]
	bit 5, a
	jr z, jr_000_1134

;>     direction = 4
	ld b, $04
;>     wMoveDX = 0xFF
	ld a, $ff
	ld [wMoveDX], a
;>     wCharAttr &= 0xDF                           # facing left
	ld a, [wCharAttr]
	and $df
	ld [wCharAttr], a
	jr jr_000_1149

jr_000_1134:
;> elif hJoyHeld & BTN_RIGHT:
	ldh a, [hJoyHeld]
	bit 4, a
	jr z, jr_000_1149

;>     direction = 2
	ld b, $02
;>     wMoveDX = 1
	ld a, $01
	ld [wMoveDX], a
;>     wCharAttr |= 0x20                           # facing right (X flip)
	ld a, [wCharAttr]
	or $20
	ld [wCharAttr], a

jr_000_1149:
;> if wMoveDir == direction: return
	ld a, [wMoveDir]
	cp b
	ret z

;> wMoveDir = direction
	ld a, b
	ld [wMoveDir], a
;> tiles = AddAToHL(0x3F28, u8(4 * wCharacter))    # the characters' tiles, one per direction
	ld hl, $3f28
	ld a, [wCharacter]
	add a
	add a
	call AddAToHL
;> if not wDiagonalView: return
	ld a, [wDiagonalView]
	and a
	jr nz, jr_000_1164

	ret


jr_000_1164:
;> if not direction: return
	ld a, [wMoveDir]
	and a
	jr z, jr_000_11aa

;> tiles = AddAToHL(tiles, direction - 1)
	dec a
	call AddAToHL
;> if wDiagonalView:
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_119e

;>     sprite = wShadowOAM + u8(4 * wCharacter)
	push hl
	ld b, $00
	call CurCharSprite
;>     shadow = sprite + 0x88                      # the character's shadow, 34 sprites further on
	ld hl, $0088
	add hl, de
;>     mem[shadow] = u8(mem[sprite] + 8)
	ld a, [de]
	add $08
	ld [hli], a
;>     mem[shadow + 1] = mem[sprite + 1]
	inc de
	ld a, [de]
	ld [hli], a
;>     mem[shadow + 2] = 0x7D if direction in (1, 3) else 0x7F
	ld a, [wMoveDir]
	cp $01
	jr z, jr_000_1194

	cp $03
	jr z, jr_000_1194

	ld a, $7f
	jr jr_000_1196

jr_000_1194:
	ld a, $7d

jr_000_1196:
	ld [hli], a
;>     mem[shadow + 3] = wCharAttr | 0x80
	ld a, [wCharAttr]
	or $80
	ld [hl], a
	pop hl

jr_000_119e:
;> sprite = wShadowOAM + u8(4 * wCharacter + 2)
	ld b, $02
	call CurCharSprite
;> mem[sprite] = mem[tiles]
	ld a, [hl]
	ld [de], a
;> mem[sprite + 1] = wCharAttr
	inc de
	ld a, [wCharAttr]
	ld [de], a

jr_000_11aa:
;> return
	ret


;@ def TryStep()
;@ path: game/move
;@ Tries the move in wMoveDir. The kind of the square ahead (wTileAhead)
;@ stops it when it is a wall or another character ($F0, $E0, $A0, $C0, $90,
;@ $50); a block ($40, CanPushBlock) or a turnstile ($80, TryTurnTurnstile)
;@ say in wStepKind whether they move along. A step that can be made starts
;@ with its sound (in GOING UP? after an undo record); with B held only one
;@ step goes for each press of the d-pad. A blocked move bumps (sound 9).
;@ writes: wBLatch, wMoveDX, wMoveDY, wStepKind, wStepOK, wStepTiles, wStepping, wTileAhead, wUndoOn
;@ reads: hJoyHeld, wBLatch, wDemo, wGameMode, wMoveDir, wStepKind
;@ sig: 9f6d6794
TryStep::
;> square = CurCharTilePtr()
	call CurCharTilePtr
;> step = {1: -20, 2: 1, 3: 20, 4: -1}.get(wMoveDir)
	ld a, [wMoveDir]
	dec a
	jr z, jr_000_11be

	dec a
	jr z, jr_000_11ca

	dec a
	jr z, jr_000_11c4

	dec a
	jr z, jr_000_11cd

;> if step is None: return
	ret


jr_000_11be:
;> square = u16(square + step)
	ld de, $ffec
	add hl, de
	jr jr_000_11ce

jr_000_11c4:
	ld de, $0014
	add hl, de
	jr jr_000_11ce

jr_000_11ca:
	inc hl
	jr jr_000_11ce

jr_000_11cd:
	dec hl

jr_000_11ce:
;> kind = mem[square] & 0xF0
	ld a, [hl]
	and $f0
;> wTileAhead = kind
	ld [wTileAhead], a
;> bump = True
;> if kind not in (0xF0, 0xE0, 0xA0, 0xC0, 0x90, 0x50):
	cp $f0
	jr z, jr_000_1247

	cp $e0
	jr z, jr_000_1247

	cp $a0
	jr z, jr_000_1247

	cp $c0
	jr z, jr_000_1247

	cp $90
	jr z, jr_000_1247

	cp $50
	jr z, jr_000_1247

;>     if kind == 0x40: CanPushBlock()
	cp $40
	call z, CanPushBlock
;>     elif kind == 0x80: TryTurnTurnstile()
	cp $80
	call z, TryTurnTurnstile
;>     if wStepKind:
	ld a, [wStepKind]
	and a
	jp z, Jump_000_1247

;>         if wStepKind != 3 and not wGameMode:
	cp $03
	jr z, jr_000_120f

	ld a, [wGameMode]
	and a
	jr nz, jr_000_120f

;>             SaveUndo()
	call SaveUndo
;>             wUndoOn = 1
	ld a, $01
	ld [wUndoOn], a

jr_000_120f:
;>         if hJoyHeld & BTN_B and wBLatch:
	ldh a, [hJoyHeld]
	bit 1, a
	jr z, jr_000_1222

	ld a, [wBLatch]
	and a
	jr z, jr_000_121d

;>             bump = False                        # B: one step for each press of the d-pad
	jr jr_000_1250

;>         else:
jr_000_121d:
;>             if hJoyHeld & BTN_B: wBLatch = 1
	ld a, $01
	ld [wBLatch], a

jr_000_1222:
;>             if not wDemo:
	ld a, [wDemo]
	and a
	jr nz, jr_000_123e

;>                 QueueSound({1: 0x0A, 2: 0x0C}.get(wStepKind, 0x08))   # a block, a turnstile, a step
	ld a, [wStepKind]
	cp $01
	jr nz, jr_000_1233

	ld b, $0a
	jr jr_000_123d

jr_000_1233:
	cp $02
	jr nz, jr_000_123b

	ld b, $0c
	jr jr_000_123d

jr_000_123b:
	ld b, $08

jr_000_123d:
	rst $30

jr_000_123e:
;>             wStepping = wStepOK = 1
	ld a, $01
	ld [wStepping], a
	ld [wStepOK], a
;>             return
	ret


Jump_000_1247:
jr_000_1247:
;> if bump and not wDemo:
	ld a, [wDemo]
	and a
	jr nz, jr_000_1250

;>     QueueSound(9)                               # the bump
	ld b, $09
	rst $30

jr_000_1250:
;> wStepping = wStepOK = wMoveDX = wMoveDY = 0
	xor a
	ld [wStepping], a
	ld [wStepOK], a
	ld [wMoveDX], a
	ld [wMoveDY], a
;> wStepKind = 3
	ld a, $03
	ld [wStepKind], a
;> wStepTiles = 1
	ld a, $01
	ld [wStepTiles], a
;> return
	ret


;@ def MovePushedObject()
;@ path: game/move
;@ One frame of what the step pushes: the block's sprites move along
;@ (StepObjectSprites), or the turnstile turns (TurnstileStep).
;@ reads: wStepKind
;@ sig: 63b07eba
MovePushedObject::
;> if wStepKind == 1:
	ld a, [wStepKind]
	dec a
;>     if StepObjectSprites() == 1: TurnstileStep()   # (a is 0 when the sprites end)
	call z, StepObjectSprites
;> elif wStepKind == 2:
	dec a
;>     TurnstileStep()
	call z, TurnstileStep
;> return
	ret


;@ def StepFrame()
;@ path: game/move
;@ One frame of a step: moves the character's sprite (and its shadow) by
;@ wMoveDX / wMoveDY pixels, twice that at double pace. After 8 frames the
;@ character is on the next square: wCharTilePtrs moves on, a pushed block
;@ or turnstile is drawn in its new place, holes are filled, and the step
;@ count goes up.
;@ writes: wMoveDX, wMoveDY, wStepCount, wStepFrames, wStepKind, wStepTiles, wStepping
;@ reads: wCharAttr, wCharacter, wDiagonalView, wMoveDX, wMoveDY, wStepCount, wStepFrames, wStepKind, wStepOK, wStepTiles
;@ test: wStepFrames = rand(2, 0xFF)
;@ sig: 0bc98e71
StepFrame::
;> if wStepOK: wStepping = 1
	ld a, [wStepOK]
	and a
	jr z, jr_000_127f

	ld a, $01
	ld [wStepping], a

jr_000_127f:
;> coords = AddAToHL(wCharCoords, u8(2 * wCharacter))
	ld hl, wCharCoords
	ld a, [wCharacter]
	sla a
	call AddAToHL
;> if wStepTiles != 1:                             # double pace: 2 pixels a frame
	ld a, [wStepTiles]
	cp $01
	jr z, jr_000_12a1

;>     wMoveDX = u8(wMoveDX << 1)
	ld a, [wMoveDX]
	sla a
	ld [wMoveDX], a
;>     wMoveDY = u8(wMoveDY << 1)
	ld a, [wMoveDY]
	sla a
	ld [wMoveDY], a

jr_000_12a1:
;> x = mem[coords] = u8(wMoveDX + mem[coords])
	ld a, [wMoveDX]
	add [hl]
	ld [hl], a
	ld b, a
;> y = mem[coords + 1] = u8(wMoveDY + mem[coords + 1])
	inc hl
	ld a, [wMoveDY]
	add [hl]
	ld [hl], a
	ld c, a
;> tile = mem[CurCharSprite(2)]
	push bc
	ld b, $02
	call CurCharSprite
	pop bc
	ld a, [de]
	ld d, a
;> SetSprite(wCharacter, y, x, tile, wCharAttr)
	ld a, [wCharAttr]
	ld e, a
	ld a, [wCharacter]
	call SetSprite
;> if wDiagonalView:                               # the shadow follows, 8 pixels lower
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_12d7

;>     sprite = CurCharSprite(0)
	ld b, $00
	call CurCharSprite
;>     mem[sprite + 0x88] = u8(mem[sprite] + 8)
	ld hl, $0088
	add hl, de
	ld a, [de]
	add $08
	ld [hli], a
;>     mem[sprite + 0x89] = mem[sprite + 1]
	inc de
	ld a, [de]
	ld [hli], a

jr_000_12d7:
;> if wStepTiles != 1:
	ld a, [wStepTiles]
	cp $01
	jr z, jr_000_12ee

;>     wMoveDX = (wMoveDX >> 1) | (wMoveDX & 0x80)
	ld a, [wMoveDX]
	sra a
	ld [wMoveDX], a
;>     wMoveDY = (wMoveDY >> 1) | (wMoveDY & 0x80)
	ld a, [wMoveDY]
	sra a
	ld [wMoveDY], a

jr_000_12ee:
;> wStepFrames = u8(wStepFrames - 1)
	ld a, [wStepFrames]
	dec a
	ld [wStepFrames], a
;> if wStepFrames: return
	jr nz, jr_000_1347

;> StepTilePtr()                                   # the step is done: on the next square
	call StepTilePtr
;> wStepFrames = 8
	ld a, $08
	ld [wStepFrames], a
;> if wStepTiles == 2: StepTilePtr()
	ld a, [wStepTiles]
	cp $02
	jr nz, jr_000_1309

	call StepTilePtr

jr_000_1309:
;> kind = wStepKind
	ld a, [wStepKind]
;> if kind == 1: kind = RedrawMovedObject()
	cp $01
	call z, RedrawMovedObject
;> if kind == 2: RedrawMovedObject()
	cp $02
	call z, RedrawMovedObject
;> FillHoles()
	call FillHoles
;> ClearObjectSprites()
	call ClearObjectSprites
;> wMoveDX = wMoveDY = wStepping = 0
	xor a
	ld [wMoveDX], a
	ld [wMoveDY], a
	ld [wStepping], a
;> wStepKind = 3
	ld a, $03
	ld [wStepKind], a
;> wStepFrames = 8
	ld a, $08
	ld [wStepFrames], a
;> wStepTiles = 1
	ld a, $01
	ld [wStepTiles], a
;> bcd_write(addr(wStepCount), 2, (bcd_read(addr(wStepCount), 2) + 1) % 10000)
	ld a, [wStepCount]
	add $01
	daa
	ld [wStepCount], a
	ld a, [wStepCount + 1]
	adc $00
	daa
	ld [wStepCount + 1], a

jr_000_1347:
;> return
	ret


;@ def StepTilePtr()
;@ path: game/move
;@ Moves the character's address in wTileBuffer one square in the direction
;@ of wMoveDX / wMoveDY.
;@ reads: wCharacter, wMoveDX, wMoveDY
;@ sig: d0c30cbf
StepTilePtr::
;> ptr = wCharTilePtrs + u8(2 * wCharacter)
	ld hl, wCharTilePtrs
	ld a, [wCharacter]
	sla a
	ld e, a
	ld d, $00
	add hl, de
;> square = mem16[ptr]
	ld e, l
	ld d, h
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	dec de
	push de
;> if wMoveDX: square = u16(square + (1 if wMoveDX == 1 else -1))
	ld a, [wMoveDX]
	and a
	jr z, jr_000_1371

	cp $01
	jr nz, jr_000_136d

	ld e, a
	ld d, $00
	add hl, de
	jr jr_000_1371

jr_000_136d:
	ld de, $ffff
	add hl, de

jr_000_1371:
;> if wMoveDY: square = u16(square + (20 if wMoveDY == 1 else -20))
	ld a, [wMoveDY]
	and a
	jr z, jr_000_1385

	cp $01
	jr nz, jr_000_1381

	ld de, $0014
	add hl, de
	jr jr_000_1385

jr_000_1381:
	ld de, $ffec
	add hl, de

jr_000_1385:
;> mem16[ptr] = square
	pop de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
;> return
	ret


;@ def AnimateCharacter()
;@ path: game/move
;@ Every 8 frames (wAnimTimer): the character under control blinks (OBP1
;@ swaps between $AC and OBP0's colours) and bobs one pixel up or down; in
;@ the diagonal view its shadow bobs along and turns its tile.
;@ writes: wAnimTimer
;@ reads: wAnimTimer, wDiagonalView
;@ sig: 7b4795ad
AnimateCharacter::
;> sprite = CurCharSprite(2)
	ld b, $02
	call CurCharSprite
;> if wAnimTimer != 4: return
	ld a, [wAnimTimer]
	cp $04
	ret nz

;> rOBP1 = 0xAC if rOBP1 == 0x9C else rOBP0
	ldh a, [rOBP1]
	cp $9c
	jr nz, jr_000_13a1

	ld a, $ac
	jr jr_000_13a3

jr_000_13a1:
	ldh a, [rOBP0]

jr_000_13a3:
	ldh [rOBP1], a
;> wAnimTimer = 8
	ld a, $08
	ld [wAnimTimer], a
;> if wDiagonalView:
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_13f1

;>     shadow = sprite + 0x88                      # the shadow's tile
	ld hl, $0088
	add hl, de
;>     if mem[shadow] == 0x7D:
	ld a, [hl]
	cp $7d
	jr nz, jr_000_13cb

;>         mem[shadow + 1] ^= 0x20                 # flip it
	inc hl
	ld a, [hl]
	bit 5, a
	jr nz, jr_000_13c5

	set 5, a
	ld [hl], a
	dec hl
	jr jr_000_13db

jr_000_13c5:
	res 5, a
	ld [hl], a
	dec hl
	jr jr_000_13db

;>     else: mem[shadow] = {0x7F: 0x7E, 0x7E: 0x7F}.get(mem[shadow], mem[shadow])
jr_000_13cb:
	ld a, [hl]
	cp $7f
	jr nz, jr_000_13d4

	ld a, $7e
	jr jr_000_13da

jr_000_13d4:
	cp $7e
	jr nz, jr_000_13da

	ld a, $7f

jr_000_13da:
	ld [hl], a

jr_000_13db:
;>     d = 1 if mem[sprite - 2] & 1 else -1        # odd y: down, even y: up
	ld de, $fffe
	add hl, de
	push hl
	ld de, $ff78
	add hl, de
	ld a, [hl]
	and $01
	jr nz, jr_000_13ed

;>     mem[sprite - 2] = u8(mem[sprite - 2] + d)
;>     mem[sprite + 0x86] = u8(mem[sprite + 0x86] + d)
	dec [hl]
	pop hl
	dec [hl]
	ret


jr_000_13ed:
	inc [hl]
	pop hl
	inc [hl]
	ret


;> else:
jr_000_13f1:
;>     mem[sprite - 2] = u8(mem[sprite - 2] + (1 if mem[sprite - 2] & 1 else -1))
	ld h, d
	ld l, e
	ld de, $fffe
	add hl, de
	ld a, [hl]
	and $01
	jr nz, jr_000_13fe

	dec [hl]
	ret


jr_000_13fe:
	inc [hl]
	ret


;@ def NextCharacter()
;@ path: game/move
;@ Gives the control to the next character still in the room: the current
;@ one becomes an obstacle in wTileBuffer ($C0 + its number, unless it is
;@ on the stairs), the next one with a sprite hops (10 times 3 pixels, 3
;@ frames each) and its square is cleared.
;@ writes: wCharacter
;@ reads: wCharacter
;@ sig: 7f8f9b47
NextCharacter::
;> for _ in forever():
;>     square = CurCharTilePtr()
	call CurCharTilePtr
;>     if mem[square] & 0xF0 != 0x10:
	ld a, [hl]
	and $f0
	cp $10
	jr z, jr_000_1410

;>         mem[square] = 0xC0 | wCharacter
	ld a, [wCharacter]
	or $c0
	ld [hl], a

jr_000_1410:
;>     wCharacter = 0 if wCharacter + 1 == 4 else u8(wCharacter + 1)
	ld a, [wCharacter]
	inc a
	cp $04
	jr nz, jr_000_1419

	xor a

jr_000_1419:
	ld [wCharacter], a
;>     if mem[CurCharCoordsPtr()]: break           # x = 0: no character
	call CurCharCoordsPtr
	ld a, [hl]
	and a
	jr z, NextCharacter

;> sprite = CurCharSprite(0)
	ld b, $00
	call CurCharSprite
;> d = 0xFD
;> for _ in range(10):                             # the hop
	ld b, $fd
	ld c, $0a

jr_000_142c:
;>     mem[sprite] = u8(mem[sprite] + d)
	ld a, [de]
	add b
	ld [de], a
;>     d = u8(-d)
	ld a, b
	cpl
	inc a
	ld b, a
;>     for _ in range(3): WaitVBlank()
	call WaitVBlank
	call WaitVBlank
	call WaitVBlank
	dec c
	jr nz, jr_000_142c

;> mem[CurCharTilePtr()] = 0
	call CurCharTilePtr
	xor a
	ld [hl], a
;> return
	ret


;@ def DrawCharacters()
;@ path: game/character
;@ Puts the four characters into the shadow OAM (sprites 0-3) from their
;@ positions in wCharCoords (a character that has left has 0, 0). The tile comes from the table at $3F38 (bird's-eye view) or $3F28
;@ (diagonal view), and in the diagonal view each character also gets a
;@ shadow sprite ($7D, behind the background) 8 pixels lower, sprites 34-37.
;@ writes: wDrawCharIndex, wMoveDir
;@ reads: wDiagonalView, wDrawCharIndex
;@ sig: 59db1651
DrawCharacters::
;> for i in range(4):
	ld hl, wCharCoords
	ld b, $00

jr_000_144a:
;>     wDrawCharIndex = i
	push bc
	ld a, b
	ld [wDrawCharIndex], a
	push af
	push hl
;>     if not wDiagonalView:
	ld a, [wDiagonalView]
	and a
	jr nz, jr_000_1461

;>         tile = mem[0x3F38 + 2 * i]
	ld hl, $3f38
	ld a, b
	add a
	ld de, $0000
	jr jr_000_146a

jr_000_1461:
;>     else:
;>         tile = mem[0x3F28 + 4 * i + 2]
	ld hl, $3f28
	ld a, b
	add a
	add a
	ld de, $0002

jr_000_146a:
;>     x, y = wCharCoords[2 * i], wCharCoords[2 * i + 1]
	call AddAToHL
	add hl, de
	ld a, [hl]
	ld d, a
	pop hl
	ld a, [hli]
	ld b, a
	ld a, [hli]
	ld c, a
	ld e, $00
;>     SetSprite(i, y, x, tile, 0)
	pop af
	call SetSprite
;>     if wDiagonalView:
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_1490

;>         SetSprite(34 + i, u8(y + 8), x, 0x7D, 0x80)   # behind the background
	ld de, $7d80
	ld a, c
	add $08
	ld c, a
	ld a, [wDrawCharIndex]
	add $22
	call SetSprite

jr_000_1490:
	pop bc
	inc b
	ld a, b
	cp $04
	jr nz, jr_000_144a

;> WaitVBlank()
	call WaitVBlank
;> wMoveDir = 0
	xor a
	ld [wMoveDir], a
;> return
	ret


;@ def PauseWindow()
;@ path: game/pause
;@ SELECT during a room: the window slides in from the right with the skill
;@ and the floor, the characters disappear, and MenuChoose offers REDO, END
;@ and (when wUndoOn is set) BACK, which takes a move back (Undo). REDO
;@ builds the room again (PauseRedo), END opens EndMenu, B closes the window.
;@ writes: $9C45, wMenuLastColRows, wPauseTile38, wPauseTile39, wShadowOAM
;@ reads: wMenuChoice, wRoom, wShadowOAM, wSkill, wUndoOn
;@ sig: ff3e09d5
PauseWindow::
;> QueueSound(0x0F)
	ld b, $0f
	rst $30
;> for a in (0xC002, 0xC006, 0xC00A, 0xC00E, 0xC088, 0xC08C, 0xC090, 0xC094):
;>     mem[a] = 0xFF                           # the characters' and shadows' tiles
	ld a, $ff
	ld [wShadowOAM + 2], a
	ld [wShadowOAM + 6], a
	ld [wShadowOAM + 10], a
	ld [wShadowOAM + 14], a
	ld [wShadowOAM + 136], a
	ld [wShadowOAM + 140], a
	ld [wShadowOAM + 144], a
	ld [wShadowOAM + 148], a
;> wPauseTile39 = wShadowOAM[0x9E]                   # sprites 38 and 39: kept for later
	ld a, [wShadowOAM + 158]
	ld [wPauseTile39], a
;> wPauseTile38 = wShadowOAM[0x9A]
	ld a, [wShadowOAM + 154]
	ld [wPauseTile38], a
;> wShadowOAM[0x9A] = wShadowOAM[0x9E] = 0xFF
	ld a, $ff
	ld [wShadowOAM + 154], a
	ld [wShadowOAM + 158], a
;> rWX = 0xA5
	ld a, $a5
	ldh [rWX], a
;> rWY = 0x10
	ld a, $10
	ldh [rWY], a
;> rLCDC = 0xE3                                # the window on
	ld a, $e3
	ldh [rLCDC], a
;> PrintBCD(ToBCDBlank(wSkill + 1), 0x9C45)    # LVL- skill
	ld a, [wSkill]
	inc a
	call ToBCDBlank
	ld hl, $9c45
	call PrintBCD
;> PrintBCD(FloorDigits(wRoom), 0x9C85)       # FL- floor
	ld a, [wRoom]
	call FloorDigits
	ld hl, $9c85
	call PrintBCD
;> WaitHBlank()
	call WaitHBlank
;> mem[0x9C45] = 0x1D                          # '-' over the blank tens digit
	ld a, $1d
	ld [$9c45], a

;> for _ in forever():                         # slide in, 2 pixels a frame
jr_000_14fd:
;>     WaitVBlank()
	call WaitVBlank
;>     rWX = u8(rWX - 2)
	ldh a, [rWX]
	sub $02
	ldh [rWX], a
;>     if rWX == 0x5F: break
	cp $5f
	jr nz, jr_000_14fd

;> rows = u8(wUndoOn + 1)
	ld hl, $9d21
	ld de, $0040
	ld bc, $0001
	ld a, [wUndoOn]
	add c
;> wMenuLastColRows = rows
	ld c, a
	ld [wMenuLastColRows], a
;> MenuChoose(0x9D21, 0x0040, 0, rows, 0xAB)
	ld a, $ab
	call MenuChoose
;> choice = wMenuChoice
	ld a, [wMenuChoice]
;> if choice != 0xFF:
	cp $ff
	jr z, jr_000_1532

;>     if choice == 0: return PauseRedo()
	and a
	jp z, PauseRedo

;>     if choice == 1: return EndMenu()
	dec a
	jr z, jr_000_1567

;>     if choice == 2: Undo()
	dec a
	call z, Undo
;> return ClosePauseWindow()   # falls through

;@ def ClosePauseWindow()
;@ path: game/pause
;@ The window slides back out to the right and the characters come back.
;@ writes: wShadowOAM
;@ reads: wPauseTile38, wPauseTile39
;@ sig: b7f1f44e
ClosePauseWindow::
;> for _ in forever():                         # slide out, 4 pixels a frame
jr_000_1532:
;>     WaitVBlank()
	call WaitVBlank
;>     rWX = u8(rWX + 4)
	ldh a, [rWX]
	add $04
	ldh [rWX], a
;>     if rWX == 0xA7: break
	cp $a7
	jr nz, jr_000_1532

;> rLCDC = 0xC3                                # the window off
	ld a, $c3
	ldh [rLCDC], a
;> DrawCharacters()
	call DrawCharacters
;> wShadowOAM[0x9E] = wPauseTile39
	ld a, [wPauseTile39]
	ld [wShadowOAM + 158], a
;> wShadowOAM[0x9A] = wPauseTile38
	ld a, [wPauseTile38]
	ld [wShadowOAM + 154], a
;> return
	ret


;@ def PauseRedo()
;@ path: game/pause
;@ REDO: the window off and the room built again from the start.
;@ test: skip never returns
;@ sig: b45d8f2d
PauseRedo::
;> rLCDC = 0xC3
	ld a, $c3
	ldh [rLCDC], a
;> return SetUpLevel()
	jp SetUpLevel


;@ def FloorDigits(room: a) -> a
;@ path: game/pause
;@ The floor of a GOING UP? room (room % 10 + 1) as two digits for PrintBCD.
;@ sig: 7d05fb9f
FloorDigits::
;> q, r = DivideHLByA(room, 10)
	ld l, a
	ld h, $00
	ld a, $0a
	call DivideHLByA
;> return ToBCDBlank(r + 1)
	inc a
	call ToBCDBlank
	ret


;@ def EndMenu()
;@ path: game/pause
;@ END in the pause window: the clock stops and a menu offers going back to
;@ the room (also B), choosing another floor (another course in HEADING
;@ OUT?), another skill, or the main menu.
;@ writes: wClockMinutes, wClockSeconds, wInStartPrompt, wMenuLastColRows, wOppWins, wSavedMinutes, wSavedSeconds, wYouWins
;@ reads: wClockMinutes, wClockSeconds, wGameMode, wInStartPrompt, wMenuChoice, wSavedMinutes, wSavedSeconds
;@ sig: 510233ed
EndMenu::
jr_000_1567:
;> wSavedSeconds = wClockSeconds                 # the clock as it was
	ld a, [wClockSeconds]
	ld [wSavedSeconds], a
;> wSavedMinutes = wClockMinutes
	ld a, [wClockMinutes]
	ld [wSavedMinutes], a
;> rLCDC = 0xC3
	ld a, $c3
	ldh [rLCDC], a
;> QueueSound(3)
	ld b, $03
	rst $30
;> MenuScreenText(0x9903, PauseMenuText)
	ld hl, $9903
	ld de, PauseMenuText
	call MenuScreenText
;> text = SelectFloorText2 if wGameMode == 0 else SelectCourseText
	ld de, SelectFloorText2
	ld a, [wGameMode]
	and a
	jr z, jr_000_158f

	ld de, SelectCourseText

;> PrintText(0x9943, text)
jr_000_158f:
	ld hl, $9943
	call PrintText
;> wMenuLastColRows = 3
	ld hl, $9902
	ld de, $0040
	ld bc, $0003
	ld a, $03
	ld [wMenuLastColRows], a
;> MenuChoose(0x9902, 0x0040, 0, 3, 0xAB)
	ld a, $ab
	call MenuChoose
;> choice = wMenuChoice
	ld a, [wMenuChoice]
;> if choice != 0xFF and choice != 0:
	cp $ff
	jr nz, jr_000_15b1

	jr jr_000_15c6

jr_000_15b1:
	and a
	jr z, jr_000_15c6

;>     wYouWins = 0
	push af
	xor a
	ld [wYouWins], a
;>     wOppWins = 0
	ld [wOppWins], a
	pop af
;>     if choice == 1:
;>@fl         return SelectFloorMenu() if wGameMode == 0 else SelectCourseMenu()
	dec a
	jr z, jr_000_15eb

;>     if choice == 2:
;>@sk         return SelectSkillMenu()
	dec a
	jr z, jr_000_15e8

;>     return MainMenu()
	jp MainMenu


;> if wInStartPrompt: return MenusDone()
jr_000_15c6:
	ld a, [wInStartPrompt]
	and a
	jr z, jr_000_15cf

	jp MenusDone


;> wClockSeconds = wSavedSeconds
jr_000_15cf:
	ld a, [wSavedSeconds]
	ld [wClockSeconds], a
;> wClockMinutes = wSavedMinutes
	ld a, [wSavedMinutes]
	ld [wClockMinutes], a
;> wInStartPrompt = 0
	xor a
	ld [wInStartPrompt], a
;> WipeInRoom()
	call WipeInRoom
;> QueueSound(1)
	ld b, $01
	rst $30
;> return ClosePauseWindow()
	jp ClosePauseWindow


;=@sk
jr_000_15e8:
	jp SelectSkillMenu


;=@fl
jr_000_15eb:
	ld a, [wGameMode]
	and a
	jr nz, jr_000_15f4

	jp SelectFloorMenu


jr_000_15f4:
	jp SelectCourseMenu


;@ def ResetGameState()
;@ path: game/level
;@ Clears the state of a game before it starts: clock, steps, score, undo
;@ ring, progress bar and the step state; wCourseRoom starts at 1.
;@ writes: wAnimTimer, wBarLeft, wBarPtr, wBarTotal, wCharAttr, wCharExited, wClockFrames, wClockMinutes, wClockSeconds, wClockSecondsTotal, wCourseRoom, wGiveUp, wMoveDX, wMoveDY, wRoomDone, wScore, wStepCount, wStepFrames, wStepKind, wStepOK, wStepTiles, wStepping, wTileAhead, wUndoCount, wUndoOn, wUndoSlot, wVsLost, wVsPartnerRoom
;@ sig: dbe425de
ResetGameState::
;> wStepKind = 3
	ld a, $03
	ld [wStepKind], a
;> wVsLost = wGiveUp = 0
;> wUndoSlot = wUndoCount = wBarTotal = wBarLeft = wBarPtr = 0
	xor a
	ld [wVsLost], a
	ld [wGiveUp], a
	ld [wUndoSlot], a
	ld [wUndoCount], a
	ld [wBarTotal], a
	ld [wBarLeft], a
	ld [wBarPtr], a
	ld [wBarPtr + 1], a
;> wClockFrames = wClockSeconds = wClockMinutes = wClockSecondsTotal = 0
	ld [wClockFrames], a
	ld [wClockSeconds], a
	ld [wClockMinutes], a
	ld [wClockSecondsTotal], a
;> wStepCount = wScore = 0
;> wUndoOn = wTileAhead = wStepping = wStepOK = wCharExited = wRoomDone = 0
;> wMoveDX = wMoveDY = wCharAttr = 0
	ld [wStepCount], a
	ld [wStepCount + 1], a
	ld [wScore], a
	ld [wScore + 1], a
	ld [wUndoOn], a
	ld [wTileAhead], a
	ld [wStepping], a
	ld [wStepOK], a
	ld [wCharExited], a
	ld [wRoomDone], a
	ld [wMoveDX], a
	ld [wMoveDY], a
	ld [wCharAttr], a
;> wStepTiles = wCourseRoom = wVsPartnerRoom = 1
	ld a, $01
	ld [wStepTiles], a
	ld [wCourseRoom], a
	ld [wVsPartnerRoom], a
;> wAnimTimer = wStepFrames = 8
	ld a, $08
	ld [wAnimTimer], a
	ld [wStepFrames], a
;> return
	ret


;@ def CheckStairs()
;@ path: game/character
;@ When the current character has stepped onto the stairs (wTileAhead = $10) it
;@ leaves the room: its sprites go, its position is cleared, and with
;@ characters left (wCharsLeft) NextCharacter hands over to the next one.
;@ writes: wCharExited, wCharsLeft, wTileAhead
;@ reads: wCharsLeft, wTileAhead
;@ test: wTileAhead = 0x10 if rand(0, 3) else rand(0, 255)
;@ test: wCharsLeft = rand(1, 2)
;@ test: wCharacter = rand(0, 3)
;@ sig: ebd009bd
CheckStairs::
;> if wTileAhead != 0x10: return
	ld a, [wTileAhead]
	cp $10
	ret nz

;> QueueSound(0x12)
	ld b, $12
	rst $30
;> wCharExited = 1
	ld a, $01
	ld [wCharExited], a
;> sprite = CurCharSprite(0)                  # the current character's sprite
	ld b, $00
	call CurCharSprite
;> mem[sprite] = mem[sprite + 1] = 0
	xor a
	ld [de], a
	inc de
	ld [de], a
;> mem[sprite + 0x89] = 0                      # its shadow's x
	ld hl, $0088
	add hl, de
	ld [hl], a
;> pos = CurCharCoordsPtr()
	call CurCharCoordsPtr
;> mem[pos] = mem[pos + 1] = 0
	xor a
	ld [hli], a
	ld [hli], a
;> wCharsLeft = u8(wCharsLeft - 1)
	ld a, [wCharsLeft]
	dec a
	ld [wCharsLeft], a
;> if wCharsLeft: NextCharacter()                 # on with the next character
	jr z, jr_000_168a

	call NextCharacter

jr_000_168a:
;> wTileAhead = 0
	xor a
	ld [wTileAhead], a
;> return
	ret


;@ def CheckCorridorExit()
;@ path: game/character
;@ HEADING OUT?: a character at x = 8 (the screen's left edge) has walked out
;@ through the left corridor, which ends the room (wCharsLeft = 0).
;@ writes: wCharsLeft
;@ test: wCharacter = rand(0, 3)
;@ test: mem[0xC2DC + 2 * wCharacter] = rand(7, 9)
;@ sig: f0128fac
CheckCorridorExit::
;> if mem[CurCharCoordsPtr()] != 8: return     # the current character's x
	call CurCharCoordsPtr
	ld a, [hl]
	cp $08
	ret nz

;> wCharsLeft = 0
	xor a
	ld [wCharsLeft], a
;> return
	ret


;@ def CheckRoomCleared()
;@ path: game/clear
;@ Called by the game loop: once no character is left in the room
;@ (wCharsLeft = 0) the room is cleared. HEADING OUT? and VS MODE go on to
;@ the next room of the course (or CourseDone after the last one). GOING UP?
;@ flashes the screen and shows YOU DID IT with the skill, the floor, the
;@ time and the steps until A or START, then the next floor's START prompt;
;@ after the tenth floor SkillClearedText and GoHomeScene come first, and
;@ after the 30th room the game starts over from the title.
;@ writes: wCharExited, wClockMinutes, wClockSeconds, wContinue, wCourseRoom, wLinkState, wObjInHole, wRoom, wRoomDone, wSinkFrame, wSinkTile, wTitleBlink
;@ reads: wCharsLeft, wClockMinutes, wClockSeconds, wContinue, wCourseLength, wCourseRoom, wGameMode, wObjInHole, wRoom, wSinkFrame, wSinkTile, wSkill, wTitleBlink
;@ test: wCharsLeft = rand(0, 1)
;@ sig: 360f6313
CheckRoomCleared::
;> if wCharsLeft:
;>@b1     wCharExited = wRoomDone = 0
;>@b2     return
	ld a, [wCharsLeft]
	and a
	jp nz, Jump_000_178a

;> wSinkFrame = wClockSeconds                 # the clock when the room was cleared
	ld a, [wClockSeconds]
	ld [wSinkFrame], a
;> wSinkTile = wClockMinutes
	ld a, [wClockMinutes]
	ld [wSinkTile], a
;> wRoomDone = 1
	ld a, $01
	ld [wRoomDone], a
;> if wGameMode != 0:
	ld a, [wGameMode]
	and a
	jr z, jr_000_16d3

;>     wCourseRoom = u8(wCourseRoom + 1)
	ld a, [wCourseRoom]
	inc a
	ld [wCourseRoom], a
;>     if wCourseRoom == u8(wCourseLength + 1):
	ld a, [wCourseRoom]
	ld b, a
	ld a, [wCourseLength]
	add $01
	cp b
	jr nz, jr_000_16d3

;>         wLinkState = 0
	xor a
	ld [wLinkState], a
;>         return CourseDone()
	jp CourseDone


jr_000_16d3:
;> FlashOrNextRoom()                           # HEADING OUT? does not come back from it
	call FlashOrNextRoom
;> room = u8(wRoom + 1)
	ld a, [wRoom]
	inc a
	cp $1e
	jr nz, jr_000_16df

	xor a

jr_000_16df:
;> wRoom = 0 if room == 30 else room
	ld [wRoom], a
;> pop_return_address()                        # never back to the game loop
	pop hl
;> QueueSound(3)
	ld b, $03
	rst $30
;> DrawResultsScreen()
	call DrawResultsScreen
;> PrintText(0x9863, YouDidItText)
	ld de, YouDidItText
	ld hl, $9863
	call PrintText
;> PrintDigit(0xF0 | u8(wSkill + 1), 0x98AA)   # the skill
	ld a, [wSkill]
	inc a
	or $f0
	ld hl, $98aa
	call PrintDigit
;> q, r = DivideHLByA(wRoom, 10)
	ld a, [wRoom]
	ld h, $00
	ld l, a
	ld a, $0a
	call DivideHLByA
;> floor = ToBCDBlank(r if r else 10)          # the floor just cleared
	and a
	jr nz, jr_000_170e

	ld a, $0a

jr_000_170e:
	call ToBCDBlank
;> wObjInHole = floor
	ld [wObjInHole], a
;> PrintBCD(floor, 0x98AF)
	ld hl, $98af
	call PrintBCD
;> wClockSeconds = wSinkFrame
	ld a, [wSinkFrame]
	ld [wClockSeconds], a
;> wClockMinutes = wSinkTile
	ld a, [wSinkTile]
	ld [wClockMinutes], a
;> PrintClock(0x98EA)
	ld hl, $98ea
	call PrintClock
;> PrintStepCount(0x992B)
	ld hl, $992b
	call PrintStepCount
;> wLinkState = 0x40                           # the VBlank handler watches for A / START
	ld a, $40
	ld [wLinkState], a
;> wContinue = wTitleBlink = 0
	xor a
	ld [wContinue], a
	ld [wTitleBlink], a

;> for _ in forever():
jr_000_173e:
;>     ShowSprites(0x3A33, 0, 0x18, wTitleBlink)
	ld hl, GirlfriendSprites
	ld bc, $0018
	ld a, [wTitleBlink]
	call ShowSprites
;>     WaitFrames10()
	call WaitFrames10
;>     wTitleBlink = (wTitleBlink ^ 0xFF) & 1
	ld a, [wTitleBlink]
	cpl
	and $01
	ld [wTitleBlink], a
;>     if wContinue: break
	ld a, [wContinue]
	and a
	jr z, jr_000_173e

;> ClearTileBuffer()
	call ClearTileBuffer
;> if wObjInHole == 0x10:                     # floor 10: the skill is cleared
	ld a, [wObjInHole]
	cp $10
	jr nz, jr_000_1773

;>     wContinue = 0
	xor a
	ld [wContinue], a
;>     ClearShadowOAM()
	call ClearShadowOAM
;>     SkillClearedText()
	call SkillClearedText
;>     GoHomeScene()
	call GoHomeScene

jr_000_1773:
;> wContinue = 0
	xor a
	ld [wContinue], a
;> if wRoom:
	ld a, [wRoom]
	and a
	jr z, jr_000_1786

;>     ClearShadowOAM()
	call ClearShadowOAM
;>     LoadGameTiles()
	call LoadGameTiles
;>     return StartPrompt()
	jp StartPrompt


jr_000_1786:
;> disable_interrupts()                        # all 30 floors done: from the top
	di
;> return Start()
	jp Start


Jump_000_178a:
;=@b1
	xor a
	ld [wCharExited], a
	ld [wRoomDone], a
;=@b2
	ret


;@ def FlashOrNextRoom()
;@ path: game/clear
;@ After a cleared room. HEADING OUT? and VS MODE: the next room of the
;@ course is built and scrolled in, and play goes on in the game loop (the
;@ caller's return address is dropped). GOING UP?: the screen flashes nine
;@ times and sprites 38 and 39 go.
;@ writes: wClockSecondsTotal, wShadowOAM
;@ reads: wGameMode
;@ test: wGameMode = rand(0, 1)
;@ sig: 2672dce2
FlashOrNextRoom::
;> if wGameMode != 0:
	ld a, [wGameMode]
	and a
	jr z, jr_000_17b3

;>     PickRoom()
	call PickRoom
;>     BuildRoom()
	call BuildRoom
;>     ScrollToNextRoom()
	call ScrollToNextRoom
;>     FindCharacters()
	call FindCharacters
;>     pop_return_address()
	pop hl
;>     DrawCharacters()
	call DrawCharacters
;>     NextCharacter()
	call NextCharacter
;>     wClockSecondsTotal = 0
	xor a
	ld [wClockSecondsTotal], a
;>     return GameLoopNextFrame()
	jp GameLoopNextFrame


	db $c9

jr_000_17b3:
;> QueueSound(4)
	ld b, $04
	rst $30
;> bgp = rBGP
	ldh a, [rBGP]
	ld b, a
;> for _ in range(9):
	ld c, $09

jr_000_17bb:
;>     rBGP = 0
	xor a
	ldh [rBGP], a
;>     FlashDelay()
	call FlashDelay
;>     rBGP = bgp
	ld a, b
	ldh [rBGP], a
;>     FlashDelay()
	call FlashDelay
	dec c
	jr nz, jr_000_17bb

;> wShadowOAM[0x9E] = wShadowOAM[0x9A] = 0xFF
	ld a, $ff
	ld [wShadowOAM + 158], a
	ld [wShadowOAM + 154], a
;> return
	ret


;@ def FlashDelay()
;@ path: game/clear
;@ Waits 10 frames (one step of the floor-cleared flashing). Keeps bc.
;@ sig: 8b1e754d
FlashDelay::
;> for _ in range(10):
	ld d, $0a

jr_000_17d5:
;>     WaitVBlank()
	call WaitVBlank
	dec d
	jr nz, jr_000_17d5

;> return
	ret


;@ def ResultsScreen()
;@ path: game/results
;@ The results of a HEADING OUT? course (skill, rooms, score, the ranking
;@ with WAY TO GO!! or TRY AGAIN!!) or of a VS MODE game (skill, rooms, who
;@ won). The demo shows LEVEL-1, 5 rooms and 7600 points, and the ranking
;@ from the ROM instead of the player's.
;@ writes: wBoxRight, wCourseLength, wScore, wSkill
;@ reads: wDemo, wGameMode, wObjSpriteX, wRankClimb, wVsLost
;@ sig: a1d80f82
ResultsScreen::
;> if wGameMode == 1:
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_184c

;>     DrawResultsScreen()
	call DrawResultsScreen
;>     PrintText(0x98A5, CourseLevelText)
	ld de, CourseLevelText
	ld hl, $98a5
	call PrintText
;>     PrintSkillDigit(0x98AD)
	ld hl, $98ad
	call PrintSkillDigit
;>     if wDemo: wSkill = 0
	ld a, [wDemo]
	and a
	jr z, jr_000_17ff

	xor a
	ld [wSkill], a

jr_000_17ff:
;>     if wDemo: wCourseLength = 5
	ld a, [wDemo]
	and a
	jr z, jr_000_180a

	ld a, $05
	ld [wCourseLength], a

jr_000_180a:
;>     PrintCourseLength(0x98E7, CourseLevelText + 18)
	ld hl, $98e7
	call PrintCourseLength
;>     if wDemo: mem[0xC2F1] = 0x76             # wScore: 7600 points
	ld a, [wDemo]
	and a
	jr z, jr_000_181b

	ld a, $76
	ld [wScore], a

jr_000_181b:
;>     PrintScore(0x9926)
	ld hl, $9926
	call PrintScore
;>     PrintText(0x9982, ResultIconsText)
	ld hl, $9982
	ld de, ResultIconsText
	call PrintText
;>     RankCourse()
	call RankCourse
;>     rank = wRankClimb
	ld a, [wRankClimb]
;>     text = TryAgainText if rank == 0 else WayToGoText2 if rank == 4 else WayToGoText
	and a
	jr z, jr_000_1841

	cp $04
	jr nz, jr_000_183c

	ld de, WayToGoText2
	jr jr_000_1844

jr_000_183c:
	ld de, WayToGoText
	jr jr_000_1844

jr_000_1841:
	ld de, TryAgainText

jr_000_1844:
;>     PrintText(0x9865, text)
	ld hl, $9865
	call PrintText
;>     return
	jr jr_000_18a2

jr_000_184c:
;> DrawResultsScreen()
	ld hl, $9866
	call DrawResultsScreen
;> PrintText(0x98E5, VsOffYouText)
	ld de, VsOffYouText
	ld hl, $98e5
	call PrintText
;> PrintText(0x98A3, VsLevelText)
	ld de, VsLevelText
	ld hl, $98a3
	call PrintText
;> PrintSkillDigit(0x98AA)
	ld hl, $98aa
	call PrintSkillDigit
;> PrintCourseLength(0x98AC, VsLevelText + 14)   # de: the text's end, so the partner's count is lost in ROM
	ld hl, $98ac
	scf
	call PrintCourseLength
;> if wVsLost == 0:
	ld a, [wVsLost]
	and a
	jr nz, jr_000_1885

;>     text = VsWinText2 if wObjSpriteX else VsWinText
	ld de, VsWinText
	ld a, [wObjSpriteX]
	and a
	jr z, jr_000_1891

	ld de, VsWinText2
	jr jr_000_1891

;> else:
;>     text = VsLoseText2 if wObjSpriteX else VsLoseText
jr_000_1885:
	ld de, VsLoseText
	ld a, [wObjSpriteX]
	and a
	jr z, jr_000_1891

	ld de, VsLoseText2

jr_000_1891:
;> PrintText(0x9866, text)
	ld hl, $9866
	call PrintText
;> wBoxRight = 0xCA
	ld hl, $98ed
	ld a, $ca
	ld [wBoxRight], a
;> DrawWinMarks(0x98ED)
	call DrawWinMarks

jr_000_18a2:
;> return
	ret


;@ def RankCourse()
;@ path: game/results
;@ HEADING OUT? results: sorts the course just played (score and rooms) into
;@ the ranking of four, from the bottom up, and prints the ranking.
;@ wRankClimb tells how many places it climbed (0 = not in the ranking).
;@ A score of 0 is not ranked. The demo prints DemoRanking instead and
;@ leaves the player's ranking as it was.
;@ writes: wRankClimb, wRankNew
;@ reads: wCourseLength, wDemo, wRankClimb, wScore
;@ test: wDemo = rand(0, 1) * rand(0, 255)
;@ sig: 542c82cf
RankCourse::
;> if wDemo:
	ld a, [wDemo]
	and a
	jr z, jr_000_18e2

;>     copy(wRankingSaved, wRanking, 12)
	ld hl, wRanking
	ld de, wRankingSaved
	ld b, $0c

jr_000_18b1:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_18b1

;>     for i in range(4):
	ld hl, DemoRanking
	ld de, wRanking
	ld b, $04

;>         wRanking[3 * i:3 * i + 3] = [mem[DemoRanking + 2 * i], mem[DemoRanking + 2 * i + 1], 10]
jr_000_18bf:
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, $0a
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_18bf

;>     PrintRanking()
	ld hl, wRanking
	call PrintRanking
;>     copy(wRanking, wRankingSaved, 12)
	ld de, wRanking
	ld hl, wRankingSaved
	ld b, $0c

jr_000_18da:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_18da

;>     return
	jr jr_000_1936

jr_000_18e2:
;> wRankClimb = 0
	xor a
	ld [wRankClimb], a
;> wRankNew[0] = hi(wScore)
	ld a, [wScore + 1]
	ld b, a
	ld [wRankNew], a
;> wRankNew[1] = lo(wScore)
	ld a, [wScore]
	ld [wRankNew + 1], a
;> if wScore:
	or b
	jr z, jr_000_1930

;>     wRankNew[2] = wCourseLength
	ld a, [wCourseLength]
	ld [wRankNew + 2], a
;>     new, at = 12, 9                         # wRankNew and the last entry
	ld b, $04
	ld hl, $cee8
	ld de, wRankNew

;>     for _ in range(4):
jr_000_1904:
	push bc
;>         if wRanking[new] > wRanking[at] or (wRanking[new] == wRanking[at] and wRanking[new + 1] >= wRanking[at + 1]):
;>             RankSwap(wRanking + at, wRanking + new)
	ld a, [hl]
	ld b, a
	ld a, [de]
	sub b
	jr c, jr_000_191e

	jr z, jr_000_1912

	call RankSwap
	jr jr_000_191e

jr_000_1912:
	inc de
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [de]
	dec de
	sub b
	jr c, jr_000_191e

	call RankSwap

jr_000_191e:
;>         if wRankClimb == 0: break
	pop bc
	ld a, [wRankClimb]
	and a
	jr z, jr_000_1930

;>         new, at = at, at - 3
	dec b
	jr z, jr_000_1930

	dec de
	dec de
	dec de
	dec hl
	dec hl
	dec hl
	jr jr_000_1904

jr_000_1930:
;> PrintRanking()
	ld hl, wRanking
	call PrintRanking

jr_000_1936:
;> return
	ret

;@ The ranking the demo's results show (score high and low byte): 20000,
;@ 18000, 15000 and 10000 points, each with 10 rooms.
DemoRanking::
	db $02, $00, $01, $80, $01, $50, $01, $00

;@ def RankSwap(entry: hl, other: de)
;@ path: game/results
;@ Swaps two 3-byte ranking entries and counts the climb in wRankClimb.
;@ Keeps all registers.
;@ writes: wRankClimb
;@ reads: wRankClimb
;@ test: entry = rand_ram(3)
;@ test: other = rand_ram(3)
;@ sig: 33610cd8
RankSwap::
;> wRankClimb = u8(wRankClimb + 1)
	push bc
	push de
	push hl
	ld a, [wRankClimb]
	inc a
	ld [wRankClimb], a
;> copy(wRankSwap, other, 3)
	push hl
	push de
	ld h, d
	ld l, e
	ld c, $03
	ld de, wRankSwap

jr_000_1952:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, jr_000_1952

;> copy(other, entry, 3)
	ld b, $03
	pop de
	pop hl
	push hl
	push de

jr_000_195e:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_195e

;> copy(entry, wRankSwap, 3)
	pop de
	pop hl
	ld de, wRankSwap
	ld b, $03

jr_000_196b:
	ld a, [de]
	ld [hli], a
	inc de
	dec b
	jr nz, jr_000_196b

;> return
	pop hl
	pop de
	pop bc
	ret


;@ def PrintRanking()
;@ path: game/results
;@ Prints the four ranking entries one under the other from $9984: the score
;@ and, when the entry has them, the rooms with RMS.
;@ sig: 477e77c7
PrintRanking::
;> for i in range(4):
	ld de, $9984
	ld hl, wRanking
	ld b, $04

jr_000_197d:
;>     dest = 0x9984 + 0x20 * i
	push bc
;>     PrintEntryScore(dest, wRanking[3 * i], wRanking[3 * i + 1])
	ld a, [hli]
	ld b, a
	ld a, [hli]
	push hl
	ld c, a
	ld h, d
	ld l, e
	call PrintEntryScore
;>     rooms = wRanking[3 * i + 2]
	pop hl
	ld a, [hli]
	and a
;>     if rooms:
	push hl
	push af
	ld a, e
	add $08
	ld l, a
	ld h, d
	pop af
	and a
	jr z, jr_000_19a6

;>         PrintRoomCounts(dest + 8, rooms, dest)
	call PrintRoomCounts
;>         PrintText(dest + 11, RmsText2)
	ld a, e
	add $0b
	ld l, a
	ld h, d
	push de
	ld de, RmsText2
	call PrintText
	pop de

jr_000_19a6:
	pop hl
	ld a, e
	add $20
	ld e, a
	pop bc
	dec b
	jr nz, jr_000_197d

;> return
	ret


;@ def PrintEntryScore(dest: hl, high: b, low: c)
;@ path: game/results
;@ Prints a ranking entry's score through wScore (which it overwrites).
;@ writes: wScore
;@ sig: 65ee1997
PrintEntryScore::
;> wScore = (high << 8) | low
	ld a, b
	ld [wScore + 1], a
	ld a, c
	ld [wScore], a
;> PrintScore(dest)
	call PrintScore
;> return
	ret


;@ def DrawWinMarks(dest: hl)
;@ path: game/results
;@ VS MODE results: a row of marks for the partner (at dest, going left)
;@ and one for this Game Boy (a row lower), as many as wins the contest
;@ needs (wContestGames / 2 + 1); the games won are drawn with the tile in
;@ wBoxRight over them.
;@ writes: wBoxLeft
;@ reads: wBoxLeft, wBoxRight, wContestGames, wOppWins, wYouWins
;@ sig: 2798c9fe
DrawWinMarks::
;> need = u8(DivideHLByA(wContestGames, 2)[0] + 1)
	ld d, h
	ld e, l
	push hl
	ld a, [wContestGames]
	ld l, a
	ld h, $00
	ld a, $02
	call DivideHLByA
	inc l
	ld b, l
;> wBoxLeft = need
	ld a, l
	ld [wBoxLeft], a
;> DrawMarkRow(dest, need)
	pop hl
	ld c, $02
	call DrawMarkRow
;> DrawMarkRow(u16(dest + 0x40), wBoxLeft)
	ld h, d
	ld l, e
	ld a, $40
	call AddAToHL
	ld a, [wBoxLeft]
	ld b, a
	dec c
	call nz, DrawMarkRow
;> wins = wOppWins
	ld a, [wOppWins]
;> for row in range(2):
	ld h, d
	ld l, e
	ld c, $02

jr_000_19ec:
;>     if wins:
	and a
	jr z, jr_000_19fa

;>         p = u16(dest + 0x40 * row)
;>         for _ in range(wins):
	ld b, a

jr_000_19f0:
;>             WaitHBlank()
	call WaitHBlank
;>             mem[p] = wBoxRight
;>             p = u16(p - 1)
	ld a, [wBoxRight]
	ld [hld], a
	dec b
	jr nz, jr_000_19f0

jr_000_19fa:
;>     wins = wYouWins
	ld h, d
	ld l, e
	ld a, $40
	call AddAToHL
	ld a, [wYouWins]
	dec c
	jr nz, jr_000_19ec

;> return
	ret


;@ def DrawMarkRow(dest: hl, n: b) -> hl
;@ path: game/results
;@ Draws n empty marks (tile $46) from dest to the left, each in an HBlank.
;@ test: n = rand(1, 10)
;@ sig: 2a753b1d
DrawMarkRow::
;> for _ in range(n):
;>     WaitHBlank()
	call WaitHBlank
;>     mem[dest] = 0x46
;>     dest = u16(dest - 1)
	ld a, $46
	ld [hld], a
	dec b
	jr nz, DrawMarkRow

;> return dest
	ret


;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? results: "WAY TO GO!!" (a good rank).
WayToGoText::
	db $16, $00, $18, $ff, $13, $0e, $ff, $06, $0e, $20, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? results: "WAY TO GO!!" (the best rank).
WayToGoText2::
	db $16, $00, $18, $ff, $13, $0e, $ff, $06, $0e, $20, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? results: "TRY AGAIN!!" (no rank).
TryAgainText::
	db $13, $11, $18, $ff, $00, $06, $00, $08, $0d, $20, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? results: " LEVEL -" and, two rows down, "RMS".
CourseLevelText::
	db $ff, $0b, $04, $15, $04, $0b, $ff, $1d, $aa, $aa, $ff, $ff, $ff, $ff, $ff, $11, $0c, $12, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? results: the places 1 to 4 of the ranking, one under the other.
ResultIconsText::
	db $3d, $aa, $3e, $aa, $3f, $aa, $40, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ "RMS" (rooms).
RmsText2::
	db $11, $0c, $12, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE results: "LEVEL -    RMS".
VsLevelText::
	db $0b, $04, $15, $04, $0b, $ff, $1d, $ff, $ff, $ff, $ff, $11, $0c, $12, $bb

;@ def FindCharacters()
;@ path: game/room
;@ Scans wTileBuffer for the characters (tiles $C0-$C3, one per slot) and the
;@ stairs (tile $10): each character's square goes to wCharTilePtrs and its
;@ sprite position to wCharCoords, the stairs' position to wStairsX/Y, and
;@ wCharsLeft counts the characters.
;@ writes: hBGMapAddrHi, hBGMapAddrLo, wCharacter, wCharsLeft, wStairsX, wStairsY
;@ reads: hCoordX, hCoordY
;@ sig: 5dd7d4b4
FindCharacters::
;> fill(wCharTilePtrs, 0, 16)                  # and wCharCoords
	xor a
	ld b, $10
	ld hl, wCharTilePtrs

jr_000_1a6a:
	ld [hli], a
	dec b
	jr nz, jr_000_1a6a

;> wCharacter = 0
;> wCharsLeft = 0
	ld [wCharacter], a
	ld [wCharsLeft], a
;>@next for p in range(wTileBuffer, wTileBuffer + 360):
;=@next
	ld hl, wTileBuffer
	ld bc, $0168

Jump_000_1a7a:
;>     tile = mem[p]
	ld a, [hl]
	push bc
;>@chk     if 0xC0 <= tile <= 0xC3:              # a character: slot tile - $C0
;>@count         CountCharacter()
;=@chk
	ld de, wCharTilePtrs
	ld bc, wCharCoords
	cp $c0
	jr nz, jr_000_1a8b

;=@count
	call CountCharacter
	jr jr_000_1ab0

;=@chk
jr_000_1a8b:
	inc de
	inc de
	inc bc
	inc bc
	cp $c1
	jr nz, jr_000_1a98

;=@count
	call CountCharacter
	jr jr_000_1ab0

;=@chk
jr_000_1a98:
	inc de
	inc de
	inc bc
	inc bc
	cp $c2
	jr nz, jr_000_1aa5

;=@count
	call CountCharacter
	jr jr_000_1ab0

;=@chk
jr_000_1aa5:
	inc de
	inc de
	inc bc
	inc bc
	cp $c3
	jr nz, jr_000_1ac5

;=@count
	call CountCharacter

;>         k = tile - 0xC0
;>         mem16[wCharTilePtrs + 2 * k] = p
;>         hBGMapAddrLo = lo(p)
;>         hBGMapAddrHi = hi(p)
jr_000_1ab0:
	ld a, l
	ld [de], a
	ldh [hBGMapAddrLo], a
	ld a, h
	inc de
	ld [de], a
	ldh [hBGMapAddrHi], a
;>         TileCoords()
	call TileCoords
;>         wCharCoords[2 * k] = hCoordX
;>         wCharCoords[2 * k + 1] = hCoordY
	ldh a, [hCoordX]
	ld [bc], a
	ldh a, [hCoordY]
	inc bc
	ld [bc], a
	jr jr_000_1adc

;>     elif tile == 0x10:                       # the stairs
jr_000_1ac5:
	cp $10
	jr nz, jr_000_1adc

;>         hBGMapAddrLo = lo(p)
;>         hBGMapAddrHi = hi(p)
	ld a, l
	ldh [hBGMapAddrLo], a
	ld a, h
	ldh [hBGMapAddrHi], a
;>         TileCoords()
	call TileCoords
;>         wStairsX = hCoordX
;>         wStairsY = hCoordY
	ldh a, [hCoordX]
	ld [wStairsX], a
	ldh a, [hCoordY]
	ld [wStairsY], a

;=@next
jr_000_1adc:
	pop bc
	inc hl
	dec bc
	ld a, c
	and a
	jp nz, Jump_000_1a7a

	ld a, b
	and a
	jp nz, Jump_000_1a7a

;> return
	ret


;@ def CountCharacter()
;@ path: game/room
;@ FindCharacters found a character: one more in wCharsLeft. Also sets
;@ wCharacter to 3, the last slot, so NextCharacter starts over at the first.
;@ writes: wCharacter, wCharsLeft
;@ reads: wCharsLeft
;@ sig: b4abfb3c
CountCharacter::
;> wCharacter = 3
	ld a, $03
	ld [wCharacter], a
;> wCharsLeft += 1
	ld a, [wCharsLeft]
	inc a
	ld [wCharsLeft], a
;> return
	ret


;@ def TileCoords()
;@ path: gfx/tilemaps
;@ BufferAddrToCoords, keeping bc and hl.
;@ sig: da05c599
TileCoords::
;> BufferAddrToCoords()
	push bc
	push hl
	call BufferAddrToCoords
	pop hl
	pop bc
;> return
	ret


;@ def WipeInRoom()
;@ path: game/room
;@ Draws wTileBuffer onto the screen as a wipe: a diagonal sweeps across the
;@ screen two frames a step, even rows from the left and odd rows from the
;@ right, a pair of rows further down at each step. The scratch bytes it
;@ uses ($CF1B-$CF1E) serve other routines elsewhere.
;@ writes: wObjSprite, wSinkFrame, wSinkTile, wWipeRows
;@ reads: wObjSprite, wSinkFrame, wSinkTile, wWipeRows
;@ sig: 8ae20947
WipeInRoom::
;> mem16[0xCF1B] = 0xC0FF                      # the pair of rows the sweep starts in (- 1)
	ld hl, $c0ff
	ld a, l
	ld [wSinkFrame], a
	ld a, h
	ld [wSinkTile], a
;> wObjSprite = 1                              # here: the length of the diagonal
	ld a, $01
	ld c, a
	ld [wObjSprite], a
;> wWipeRows = 9                             # pairs of rows not finished
	ld a, $09
	ld b, a
	ld [wWipeRows], a

;> while True:
jr_000_1b16:
;>     base = mem16[0xCF1B]
;>     n = wObjSprite
;>     rows = wWipeRows
	ld a, [wSinkFrame]
	ld l, a
	ld a, [wSinkTile]
	ld h, a
	ld a, [wObjSprite]
	ld c, a
	ld a, [wWipeRows]
	ld b, a

;>     for k in range(min(n, rows)):           # one square in each pair of rows
jr_000_1b26:
;>         p = base + 40 * k + (n - k)         # even row: from the left
	push hl
	ld e, c
	ld d, $00
	add hl, de
	ld a, [hl]
;>         tile = BufferTileToBG(mem[p], p)
	call BufferTileToBG
	push af
;>         dest = BufferToBGMap(p)
	call BufferToBGMap
;>         wait_hblank()
	call WaitHBlank
;>         mem[dest] = tile
	pop af
	ld [de], a
	pop hl
;>         p = base + 40 * k + 41 - (n - k)    # the odd row below it: from the right
	ld de, $0029
	add hl, de
	ld a, c
	cpl
	inc a
	ld e, a
	ld d, $ff
	add hl, de
;>         tile = BufferTileToBG(mem[p], p)
	ld a, [hl]
	call BufferTileToBG
	push af
;>         dest = BufferToBGMap(p)
	call BufferToBGMap
;>         wait_hblank()
	call WaitHBlank
;>         mem[dest] = tile
	pop af
	ld [de], a
;>         # on to the next pair of rows, one square back
	ld e, c
	dec e
	ld d, $00
	add hl, de
	dec b
	jr z, jr_000_1b5c

	dec c
	jr nz, jr_000_1b26

jr_000_1b5c:
;>     WaitVBlank()
;>     WaitVBlank()
	call WaitVBlank
	call WaitVBlank
;>     n = wObjSprite + 1
;>     if n == 21:                             # the top pair of rows is done
	ld a, [wObjSprite]
	inc a
	cp $15
	jr nz, jr_000_1b88

;>         wWipeRows -= 1
;>         if wWipeRows == 0: return
	ld a, [wWipeRows]
	dec a
	ld [wWipeRows], a
	ret z

;>         mem16[0xCF1B] += 40
;>         n = 20
	ld a, [wSinkFrame]
	ld l, a
	ld a, [wSinkTile]
	ld h, a
	ld de, $0028
	add hl, de
	ld a, l
	ld [wSinkFrame], a
	ld a, h
	ld [wSinkTile], a
	ld a, $14

;>     wObjSprite = n
jr_000_1b88:
	ld [wObjSprite], a
	jr jr_000_1b16

;@ def DrawBufferTiles(src: hl, count: bc)
;@ path: gfx/tilemaps
;@ Draws `count` squares of wTileBuffer, from src on, into BG map 0: each
;@ becomes its BG tile (BufferTileToBG) and is written in an HBlank.
;@ sig: c5899e3a
DrawBufferTiles::
;> for p in range(src, src + (count or 0x10000)):
;>     tile = BufferTileToBG(mem[p], p)
	push bc
	ld a, [hl]
	call BufferTileToBG
	push af
;>     dest = BufferToBGMap(p)
	call BufferToBGMap
;>     wait_hblank()
	call WaitHBlank
;>     mem[dest] = tile
	pop af
	ld [de], a
;>     # next square
	inc hl
	pop bc
	dec bc
	ld a, b
	or c
	jr nz, DrawBufferTiles

;> return
	ret


;@ def BufferToBGMap(ptr: hl) -> de
;@ path: gfx/tilemaps
;@ The BG map 0 address that shows a square of wTileBuffer (20 tiles a row
;@ there, 32 in the BG map). Keeps hl and bc.
;@ test: ptr = rand(0xC100, 0xC267)
;@ sig: 48b479c9
BufferToBGMap::
;> offset = u16(ptr - 0xC100)                 # from wTileBuffer
	push hl
	push bc
	ld a, h
	sub $c1
	ld h, a
;> row, col = DivideHLByA(offset, 20)
	ld a, $14
	call DivideHLByA
;> return u16(0x9800 + row * 32 + col)
	ld b, $05

jr_000_1bb0:
	sla l
	rl h
	dec b
	jr nz, jr_000_1bb0

	ld e, a
	ld d, $00
	add hl, de
	ld de, $9800
	add hl, de
	ld d, h
	ld e, l
	pop bc
	pop hl
	ret


;@ def DrawLevelPanel()
;@ path: game/panel
;@ Draws the two frames of the panel beside the room in BG map 1 and its
;@ texts (level, floor, REDO / END).
;@ sig: cf941ad0
DrawLevelPanel::
;> DrawBox(0x9C00, 9, 7)
	ld hl, $9c00
	ld de, $0907
	call DrawBox
;> DrawBox(0x9CE0, 9, 9)
	ld hl, $9ce0
	ld de, $0909
	call DrawBox
;> PrintText(0x9C42, LevelPanelText)
	ld de, LevelPanelText
	ld hl, $9c42
	call PrintText
;> return
	ret


;@ def ShowRoom()
;@ path: game/room
;@ Wipes the new room onto the screen. In GOING UP? the stairs become two
;@ sprites; in the other modes the panels around the room get their boxes.
;@ reads: wDiagonalView, wGameMode, wStairsX, wStairsY
;@ sig: a28a00af
ShowRoom::
;> ClearShadowOAM()
	call ClearShadowOAM
;> WipeInRoom()
	call WipeInRoom
;> if wGameMode == 0:                          # GOING UP?: the stairs, sprites 38 and 39
	ld a, [wGameMode]
	and a
	jr nz, jr_000_1c21

;>     wShadowOAM[0x98] = wStairsY
	ld hl, $c098
	ld a, [wStairsY]
	ld [hli], a
;>     wShadowOAM[0x99] = wStairsX
	ld a, [wStairsX]
	ld [hli], a
	inc hl
	inc hl
;>     wShadowOAM[0x9C] = u8(wStairsY + 8)          # the lower half
	push af
	ld a, [wStairsY]
	add $08
	ld [hli], a
;>     wShadowOAM[0x9D] = wStairsX
	pop af
	ld [hli], a
;>     tiles = 0x3F01 + u8(wDiagonalView * 2)  # $DA, $FF bird's-eye; $D9, $DB diagonal
	ld hl, $c09a
	ld a, [wDiagonalView]
	ld de, $3f01
	sla a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
;>     wShadowOAM[0x9A] = mem[tiles]
	ld a, [de]
	ld [hli], a
;>     wShadowOAM[0x9B] = 0x10
	ld a, $10
	ld [hli], a
;>     wShadowOAM[0x9E] = mem[tiles + 1]
	inc de
	ld a, [de]
	inc hl
	inc hl
	ld [hli], a
;>     wShadowOAM[0x9F] = 0x90                      # flipped vertically
	ld a, $90
	ld [hl], a
;>     return
	ret


;> DrawBottomPanel()
jr_000_1c21:
	push af
	call DrawBottomPanel
	pop af
;> if wGameMode == 1:                          # HEADING OUT?
;>@m1a     PrintText(0x99C0, 0x410A)           # the bottom boxes without YOU
;>@m1b     PrintText(0x9801, 0x406B)           # SCORE and BONUS
;>@m1c     return
	dec a
	jr z, jr_000_1c37

;> elif wGameMode == 2:                        # VS MODE
;>@m2a     PrintText(0x9800, 0x40B7)           # RMS and OPP
;>@m2b     PrintText(0x980A, 0x40DE)           # two more bar boxes
;>@m2c     return
	dec a
	jr z, jr_000_1c4a

;> return
	ret


;@ def DrawBottomPanel()
;@ path: game/panel
;@ The boxes under the room: YOU with its bar, RMS and MIN 0:00 (a text in
;@ CopyrightAcclaimText, like the other panel boxes).
;@ sig: b2008413
DrawBottomPanel::
;> PrintText(0x99C0, 0x4026)
	ld hl, $99c0
	ld de, $4026
	call PrintText
;> return
	ret


;=@ShowRoom.m1a
jr_000_1c37:
	ld hl, $99c0
	ld de, $410a
	call PrintText
;=@ShowRoom.m1b
	ld hl, $9801
	ld de, $406b
	call PrintText
;=@ShowRoom.m1c
	ret


;=@ShowRoom.m2a
jr_000_1c4a:
	ld hl, $9800
	ld de, $40b7
	call PrintText
;=@ShowRoom.m2b
	ld hl, $980a
	ld de, $40de
	call PrintText
;=@ShowRoom.m2c
	ret


	db $e5, $d5, $c5, $f0, $8d, $d6, $10, $cb, $3f, $cb, $3f, $cb, $3f, $11, $00, $00
	db $5f, $21, $00, $c1, $0e, $02, $06, $02, $cb, $23, $cb, $12, $05, $20, $f9, $19
	db $0d, $20, $f3, $f0, $8e, $d6, $08, $cb, $3f, $cb, $3f, $cb, $3f, $11, $00, $00
	db $5f, $19, $7c, $e0, $8f, $7d, $e0, $90, $c1, $d1, $e1, $c9, $fa, $d1, $c2, $21
	db $d4, $c2, $cb, $27, $d5, $5f, $16, $00, $19, $d1, $c9

;@ def CurCharTilePtr() -> hl
;@ path: game/character
;@ The current character's square in wTileBuffer.
;@ reads: wCharacter
;@ test: wCharacter = rand(0, 3)
;@ sig: cd85cd52
CurCharTilePtr::
;> return mem16[wCharTilePtrs + 2 * wCharacter]
	ld a, [wCharacter]
	ld de, wCharTilePtrs
	sla a
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	ret


;@ def CurCharCoordsPtr() -> hl
;@ path: game/character
;@ The address of the current character's x, y in wCharCoords. Keeps de.
;@ reads: wCharacter
;@ test: wCharacter = rand(0, 3)
;@ sig: 0d9eb7e2
CurCharCoordsPtr::
;> return wCharCoords + 2 * wCharacter
	ld a, [wCharacter]
	ld hl, wCharCoords
	sla a
	push de
	ld e, a
	ld d, $00
	add hl, de
	pop de
	ret


;@ def CurCharSprite(offset: b) -> de
;@ path: game/character
;@ The address of byte `offset` of the current character's sprite in
;@ wShadowOAM (sprite n for character n).
;@ reads: wCharacter
;@ test: wCharacter = rand(0, 3)
;@ test: offset = rand(0, 3)
;@ sig: 6a4f5088
CurCharSprite::
;> return wShadowOAM + u8(4 * wCharacter + offset)
	ld a, [wCharacter]
	ld de, wShadowOAM
	sla a
	sla a
	add b
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ret


;@ def ScrollToNextRoom()
;@ path: game/course
;@ HEADING OUT? and VS MODE: the next room (already in wTileBuffer) scrolls
;@ in from the left. For 128 frames the band of rows 5-12 scrolls 2 pixels a
;@ frame (rSCX is changed at line $28 and put back at line $68), every 8
;@ pixels one more column of the new room is drawn, and the character
;@ walks along until it leaves at the right. Then the entrance closes.
;@ writes: wObjHeight, wObjPtr, wObjSpriteX, wObjWidth, wSplitSCX
;@ reads: wCourseLength, wCourseRoom, wDemo, wDiagonalView, wGameMode, wObjPtr, wObjSpriteX
;@ test: skip waits for LCD lines
;@ sig: 914fe4d2
ScrollToNextRoom::
;> QueueSound(0x12)
	ld b, $12
	rst $30
;> if wGameMode == 1:
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_1cea

;>     AddRoomPoints()
	call AddRoomPoints

jr_000_1cea:
;> PrintBCD(ToBCDBlank(u8(wCourseLength - wCourseRoom + 1)), 0x9A03)   # rooms left
	ld a, [wCourseRoom]
	ld b, a
	ld a, [wCourseLength]
	sub b
	inc a
	call ToBCDBlank
	ld hl, $9a03
	call PrintBCD
;> DrawOwnBar()
	call DrawOwnBar
;> wObjPtr = 0xC177                            # wTileBuffer row 5, column 19: the first column drawn
	ld hl, $c177
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
;> fill(wObjBGTiles, 0xD8, 12)                 # the corridor between the rooms: wall top
	ld hl, wObjBGTiles
	ld b, $0c

jr_000_1d0f:
	ld a, $d8
	ld [hli], a
	dec b
	jr nz, jr_000_1d0f

;> fill(0xC288, 0xFB if wDiagonalView else 0xFF, 12)   # and floor
	ld hl, $c288
	ld bc, $000c
	ld a, $ff
	push af
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_1d29

	pop af
	ld a, $fb
	jr jr_000_1d2a

jr_000_1d29:
	pop af

jr_000_1d2a:
	call FillBytes
;> wObjHeight = 2
	ld a, $02
	ld [wObjHeight], a
;> wObjWidth = 12
	ld a, $0c
	ld [wObjWidth], a
;> CopyRectToBGMap(0x98F4)                     # into the hidden BG map columns 20-31
	ld hl, $98f4
	call CopyRectToBGMap
;> WaitVBlank()
	call WaitVBlank
;> wObjSpriteX = 0                             # here: the band's scroll position
	ld c, $80
	xor a
	ld [wObjSpriteX], a

;> for _ in range(128):
Jump_000_1d46:
;>     if wDemo: SerialStop()
	ld a, [wDemo]
	and a
	call nz, SerialStop
;>     scx = rSCX
;>     disable_interrupts()
	ldh a, [rSCX]
	push af
	di

;>     wait_ly(0x28)                           # the top of the band
jr_000_1d51:
	ldh a, [rLY]
	cp $28
	jr z, jr_000_1d59

	jr jr_000_1d51

jr_000_1d59:
;>     wObjSpriteX = u8(wObjSpriteX - 2)
	ld a, [wObjSpriteX]
	sub $02
	ld [wObjSpriteX], a
;>     rSCX = wObjSpriteX
;>     wSplitSCX = wObjSpriteX
	ldh [rSCX], a
	ld [wSplitSCX], a
;>     enable_interrupts()
	ei
;>     if (wObjSpriteX & 7) == 0:              # a new column has come into view
	and $07
	jr nz, jr_000_1d8b

;>         wObjWidth = 1
;>         wObjHeight = 8
	push bc
	ld a, $01
	ld [wObjWidth], a
	ld a, $08
	ld [wObjHeight], a
;>         DrawObjectRect()
	call DrawObjectRect
;>         wObjPtr = u16(wObjPtr - 1)
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	dec hl
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
	pop bc

jr_000_1d8b:
;>     spr = CurCharSprite(1)                  # the character's x
	ld b, $01
	call CurCharSprite
	ld h, d
	ld l, e
;>     x = u8(mem[spr] + 2)
;>     if x != 0x9A:                           # until it is off the screen
	ld a, [hl]
	add $02
	cp $9a
	jr z, jr_000_1d9f

;>         mem[spr] = x
;>         mem[u16(spr + 0x88)] = x            # its second sprite, 34 slots on
	ld [hl], a
	ld de, $0088
	add hl, de
	ld [hl], a

jr_000_1d9f:
;>     disable_interrupts()
	di

;>     wait_ly(0x68)                           # the bottom of the band
jr_000_1da0:
	ldh a, [rLY]
	cp $68
	jr z, jr_000_1da8

	jr jr_000_1da0

jr_000_1da8:
;>     rSCX = scx
	pop af
	ldh [rSCX], a
;>     enable_interrupts()
	ei
;>     PrintClock(0x9A0E)
	ld hl, $9a0e
	call PrintClock
;>     WaitVBlank()
	call WaitVBlank
	dec c
	jp nz, Jump_000_1d46

;> wSplitSCX = 0
	xor a
	ld [wSplitSCX], a
;> DrawBufferTiles(0xC178, 120)                # rows 6-11 again, straight from wTileBuffer
	ld hl, $c178
	ld bc, $0078
	call DrawBufferTiles
;> PrintClock(0x9A0E)
	ld hl, $9a0e
	call PrintClock
;> DemoSerialListen()
	call DemoSerialListen
;> CloseEntryDoor()
	call CloseEntryDoor
;> PrintClock(0x9A0E)
	ld hl, $9a0e
	call PrintClock
;> return
	ret


;@ def CloseEntryDoor()
;@ path: game/course
;@ The door at the right end of the room's corridor closes behind the
;@ character: sprite 4 shows the frames from the end of CopyrightAcclaimText
;@ ($F4 $C0 $D0, or $F3 $8E $C0 $D0 in the diagonal view), 15 frames each,
;@ then the closed door goes into the BG map and wTileBuffer as wall.
;@ writes: $9913, wTileBuffer
;@ reads: wDiagonalView
;@ sig: 465067b2
CloseEntryDoor::
;> frames, tiles = (4, 0x4139) if wDiagonalView else (3, 0x4136)
	ld b, $03
	ld de, $0000
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_1de9

	ld b, $04
	ld de, $0003

jr_000_1de9:
	ld hl, $4136
	add hl, de
;> wShadowOAM[0x10] = 0x50                          # sprite 4: y (row 8)
	ld de, $c010
	ld a, $50
	ld [de], a
;> wShadowOAM[0x11] = 0xA0                          # x (column 19)
	inc de
	ld a, $a0
	ld [de], a
;> wShadowOAM[0x13] = 0                             # attributes
	inc de
	inc de
	xor a
	ld [de], a
	dec de

;> for i in range(frames):
jr_000_1dfc:
;>     wShadowOAM[0x12] = mem[tiles + i]
	ld a, [hli]
	ld [de], a
	ld c, $0f

;>     for _ in range(15):
;>         WaitVBlank()
jr_000_1e00:
	call WaitVBlank
	dec c
	jr nz, jr_000_1e00

	dec b
	jr nz, jr_000_1dfc

;> wTileBuffer[179] = 0xF0                          # wTileBuffer row 8, column 19: wall
	ld a, $f0
	ld [wTileBuffer + 179], a
;> for _ in range(2):
;>     wait_hblank()
;>     mem[0x9913] = 0xD0                      # the closed door
	call WaitHBlank
	ld a, $d0
	ld [$9913], a
	call WaitHBlank
	ld a, $d0
	ld [$9913], a
;> return
	ret


;@ def DrawProgressBar(row: a)
;@ path: game/panel
;@ Takes one off wBarLeft and draws the bar for it: wBarLeft / wBarTotal
;@ of 16 half tiles, centred on column 8 of the panel box, row `row` of the
;@ bars. Every tile is written twice, each in an HBlank.
;@ writes: wBarLeft, wBarLength, wBarPtr, wBarRow
;@ reads: wBarLeft, wBarLength, wBarRow, wBarTotal, wGameMode
;@ test: wBarTotal = rand(1, 99)
;@ test: wBarLeft = rand(1, wBarTotal + 1)
;@ sig: 8c901ab1
DrawProgressBar::
;> wBarRow = row
	ld [wBarRow], a
;> wBarLeft -= 1
	ld a, [wBarLeft]
	dec a
	ld [wBarLeft], a
;> if wBarLeft == 0: return
	and a
	ret z

;> if wBarLeft == wBarTotal:
	ld a, [wBarLeft]
	ld b, a
	ld a, [wBarTotal]
	cp b
	jr nz, jr_000_1e39

;>     n = 16                                    # full
	ld a, $10
	jr jr_000_1e73

;> else:                                        # 16 * left / total, rounded, in hundredths
;>     q, _ = DivideHLByA(1600, wBarTotal)
jr_000_1e39:
	ld hl, $0640
	ld a, [wBarTotal]
	call DivideHLByA
;>     whole, frac = DivideHLByA(q, 100)
	ld a, $64
	call DivideHLByA
;>     big = MultiplyHLByA(whole, wBarLeft)
	ld b, a
	ld a, [wBarLeft]
	call MultiplyHLByA
	push hl
;>     small, rest = DivideHLByA(MultiplyHLByA(frac, wBarLeft), 100)
	ld l, b
	ld h, $00
	ld a, [wBarLeft]
	call MultiplyHLByA
	ld a, $64
	call DivideHLByA
;>     rnd, _ = DivideHLByA(rest + 50, 100)
	push hl
	add $32
	ld l, a
	ld h, $00
	ld a, $64
	call DivideHLByA
;>     n = lo(big + lo(small + rnd))
	ld e, l
	ld d, $00
	pop hl
	add hl, de
	ld e, l
	ld d, $00
	pop hl
	add hl, de
	ld a, l

jr_000_1e73:
;> wBarLength = n
	ld [wBarLength], a
;> base = 0x99C1 if wGameMode == 1 else 0x982B
	ld hl, $982b
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_1e83

	ld hl, $99c1

jr_000_1e83:
;> ptr = u16(base + 8 + u8(wBarRow << 5))
	ld de, $0008
	add hl, de
	ld a, [wBarRow]
	sla a
	sla a
	sla a
	sla a
	sla a
	ld e, a
	add hl, de
;> if n == 0:
;>@none     rIE = 0x09; return
	ld a, [wBarLength]
	and a
	jp z, Jump_000_1f26

;> ptr = u16(ptr - (n + 1) // 2)
	cpl
	inc a
	sra a
	ld e, a
	ld d, $ff
	add hl, de
;> wBarPtr = ptr
	ld a, l
	ld [wBarPtr], a
	ld a, h
	ld [wBarPtr + 1], a
;> tile = 0xDD if n & 1 else 0x85               # odd: ends in a half tile
	ld a, [wBarLength]
	bit 0, a
	jr z, jr_000_1eb8

	ld a, $dd
	jr jr_000_1eba

jr_000_1eb8:
	ld a, $85

jr_000_1eba:
;> if n >= 15: tile -= 1
	push af
	ld a, [wBarLength]
	cp $0f
	jr c, jr_000_1ec6

	pop af
	dec a
	jr jr_000_1ec7

jr_000_1ec6:
	pop af

;> rIE = 0x01                                   # only VBlank, so no HBlank is missed
jr_000_1ec7:
	push af
	ld a, $01
	ldh [rIE], a
;> for _ in range(2):
;>     wait_hblank()
;>     mem[ptr] = tile
	call WaitHBlank
	pop af
	ld [hl], a
	push af
	call WaitHBlank
	pop af
	ld [hli], a
;> ptr = u16(ptr + 1)
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> half = (n - 1) >> 1
	ld a, [wBarLength]
	ld b, a
	dec b
	sra b
	jr z, jr_000_1efd

;> for _ in range(max(half - 1, 0)):
jr_000_1ee4:
	dec b
	jr z, jr_000_1efd

;>     rIE = 0x01
	ld a, $01
	ldh [rIE], a
;>     for _ in range(2):
;>         wait_hblank()
;>         mem[ptr] = 0x85                      # a whole tile
	call WaitHBlank
	ld a, $85
	ld [hl], a
	call WaitHBlank
	ld a, $85
	ld [hli], a
;>     ptr = u16(ptr + 1)
;>     rIE = 0x09
	ld a, $09
	ldh [rIE], a
	jr jr_000_1ee4

jr_000_1efd:
;> if n < 3:
	ld a, [wBarLength]
	cp $03
	jr nc, jr_000_1f12

;>     rIE = 0x01
	ld a, $01
	ldh [rIE], a
;>     ptr = u16(ptr - 1)
	dec hl
;>     wait_hblank()
	call WaitHBlank
;>     mem[ptr] += 1
	inc [hl]
;>     rIE = 0x09
;>     return
	ld a, $09
	ldh [rIE], a
	ret


;> rIE = 0x01
jr_000_1f12:
	ld a, $01
	ldh [rIE], a
;> for _ in range(2):
;>     wait_hblank()
;>     mem[ptr] = 0x86                          # the end
	call WaitHBlank
	ld a, $86
	ld [hl], a
	call WaitHBlank
	ld a, $86
	ld [hl], a
;> rIE = 0x09
;> return
	ld a, $09
	ldh [rIE], a

;=@none
Jump_000_1f26:
	ld a, $09
	ldh [rIE], a
	ret


;@ def DivideHLByA(n: hl, divisor: a) -> (hl, a)
;@ path: lib/math
;@ 16-bit by 8-bit division, bit by bit: the quotient in hl, the remainder
;@ in a. Only right for divisors up to 128 (the remainder has 8 bits, and
;@ a larger one would lose its top bit). Keeps bc and de.
;@ test: divisor = rand(1, 128)
;@ sig: 295f58db
DivideHLByA::
;> return n // divisor, n % divisor
	push bc
	push de
	ld c, $10
	ld b, a
	xor a
	ld d, a
	rl l
	rl h

jr_000_1f36:
	rl d
	ld a, b
	cp d
	jr z, jr_000_1f3e

	jr nc, jr_000_1f42

jr_000_1f3e:
	ld a, d
	sub b
	ld d, a
	scf

jr_000_1f42:
	rl l
	rl h
	dec c
	jr nz, jr_000_1f36

	ld a, d
	pop de
	pop bc
	ret


;@ def MultiplyHLByA(n: hl, factor: a) -> hl
;@ path: lib/math
;@ hl * a (16 bits kept), by shifting and adding. Keeps bc and de.
;@ sig: ef34c461
MultiplyHLByA::
;> return u16(n * factor)
	push de
	push bc
	ld e, l
	ld d, h
	ld hl, $0000

jr_000_1f54:
	scf
	ccf
	rra
	jr nc, jr_000_1f5a

	add hl, de

jr_000_1f5a:
	sla e
	rl d
	and a
	jr nz, jr_000_1f54

	pop bc
	pop de
	ret


;@ def ObjNextRow(ptr: hl) -> hl
;@ path: game/objects
;@ From the square after a row of the moving rectangle to the first square
;@ of its next row: ptr + 20 - wObjWidth. Keeps a and de.
;@ reads: wObjWidth
;@ sig: 22c186c5
ObjNextRow::
;> return u16(ptr + u8(20 - wObjWidth))
	push af
	push de
	ld a, [wObjWidth]
	ld e, a
	ld a, $14
	sub e
	ld e, a
	ld d, $00
	add hl, de
	pop de
	pop af
	ret


;@ def WaitHBlank()
;@ path: system/lcd
;@ Waits for the start of an HBlank: first until a line is being drawn,
;@ then until it is done, so there is a whole HBlank left for a VRAM write.
;@ test: skip polls the LCD
;@ sig: c80a5036
WaitHBlank::
;> wait_hblank()                               # (until mode 2 or 3, then until mode 0)
	ldh a, [rSTAT]
	bit 1, a
	jr z, WaitHBlank

jr_000_1f7a:
	ldh a, [rSTAT]
	and $03
	ret z

	jr jr_000_1f7a

;@ def ClearShadowOAM()
;@ path: gfx/sprites
;@ Clears the sprite table at $C000 (255 bytes; the DMA copies the first 160).
;@ sig: ed125c25
ClearShadowOAM::
;> fill(0xC000, 0, 0xFF)
	ld hl, wShadowOAM
	ld bc, $00ff
	ld a, $00
	call FillBytes
;> return
	ret


;@ def SaveUndo()
;@ path: game/undo
;@ Before a move: keeps wTileBuffer, the character and its square in the
;@ next slot of the 8-slot undo ring, and shows BACK in the panel.
;@ writes: wUndoCount, wUndoSlot
;@ reads: wCharacter, wUndoCount, wUndoSlot
;@ test: wUndoSlot = rand(0, 7)
;@ sig: 9e68e70d
SaveUndo::
;> n = u8(wUndoCount + 1)
;> wUndoCount = 8 if n == 9 else n             # at most 8 moves back
	ld a, [wUndoCount]
	inc a
	cp $09
	jr nz, jr_000_1f96

	dec a

jr_000_1f96:
	ld [wUndoCount], a
;> wUndoChar[wUndoSlot] = wCharacter
	ld a, [wUndoSlot]
	ld hl, wUndoChar
	call AddAToHL
	ld a, [wCharacter]
	ld [hl], a
;> mem16[wUndoCharPos + u8(2 * wUndoSlot)] = CurCharTilePtr()
	call CurCharTilePtr
	ld e, l
	ld d, h
	ld a, [wUndoSlot]
	sla a
	ld hl, wUndoCharPos
	call AddAToHL
	ld a, e
	ld [hli], a
	ld a, d
	ld [hl], a
;> copy(u16(wUndoBuffers + 360 * wUndoSlot), wTileBuffer, 360)
	ld hl, $0168
	ld a, [wUndoSlot]
	call MultiplyHLByA
	ld de, wUndoBuffers
	add hl, de
	ld e, l
	ld d, h
	ld hl, wTileBuffer
	ld bc, $0168
	call CopyBytes
;> wUndoSlot = 0 if wUndoSlot == 7 else u8(wUndoSlot + 1)
	ld a, [wUndoSlot]
	inc a
	cp $08
	jr nz, jr_000_1fdb

	xor a

jr_000_1fdb:
	ld [wUndoSlot], a
;> return PrintTextTail(0x9DA2, 0x4155)        # "BACK" (in LevelPanelText); falls through
	ld de, $4155
	ld hl, $9da2

;@ def PrintTextTail(dest: hl, text: de)
;@ path: gfx/text
;@ PrintText; the end of SaveUndo, also jumped to by Undo.
;@ sig: e8f2d046
PrintTextTail::
;> PrintText(dest, text)
;> return
	call PrintText
	ret


;@ def Undo()
;@ path: game/undo
;@ BACK: takes the last move back from the undo ring (wTileBuffer, the
;@ character and its square), redraws the room and selects that character
;@ again. When no move is left BACK disappears from the panel.
;@ writes: wCharacter, wUndoCount, wUndoOn, wUndoSlot
;@ reads: wUndoCount, wUndoOn, wUndoSlot
;@ test: wUndoSlot = rand(0, 7)
;@ sig: 57782c0e
Undo::
;> if not wUndoOn: return
	ld a, [wUndoOn]
	and a
	ret z

;> wUndoSlot = 7 if wUndoSlot == 0 else wUndoSlot - 1
	ld a, [wUndoSlot]
	dec a
	cp $ff
	jr nz, jr_000_1ff7

	ld a, $07

jr_000_1ff7:
	ld [wUndoSlot], a
;> copy(wTileBuffer, u16(wUndoBuffers + 360 * wUndoSlot), 360)
	ld hl, $0168
	call MultiplyHLByA
	ld de, wUndoBuffers
	add hl, de
	ld de, wTileBuffer
	ld bc, $0168
	call CopyBytes
;> pos = mem16[wUndoCharPos + u8(2 * wUndoSlot)]
	ld hl, wUndoCharPos
	ld a, [wUndoSlot]
	sla a
	call AddAToHL
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
;> char = wUndoChar[wUndoSlot]
	ld hl, wUndoChar
	ld a, [wUndoSlot]
	call AddAToHL
	ld a, [hl]
	push af
;> wCharacter = char
	ld [wCharacter], a
;> mem[pos] = char | 0xC0                       # the character back on its square
	or $c0
	ld [de], a
;> FindCharacters()
	call FindCharacters
;> DrawBufferTiles(wTileBuffer, 360)
	ld hl, wTileBuffer
	ld bc, $0168
	call DrawBufferTiles
;> wCharacter = 3 if char == 0 else char - 1
	pop af
	dec a
	cp $ff
	jr nz, jr_000_2041

	ld a, $03

jr_000_2041:
	ld [wCharacter], a
;> NextCharacter()                              # which comes back to char
	call NextCharacter
;> wUndoCount -= 1
;> if wUndoCount: return
	ld a, [wUndoCount]
	dec a
	ld [wUndoCount], a
	and a
	ret nz

;> wUndoOn = 0
	xor a
	ld [wUndoOn], a
;> return PrintTextTail(0x9D82, 0x415A)        # blanks over BACK
	ld de, $415a
	ld hl, $9d82
	jp PrintTextTail


;@ def PrintBCD(n: a, dest: hl) -> hl
;@ path: gfx/text
;@ Prints a BCD byte as two digit tiles (a digit $F prints as a blank).
;@ Keeps a.
;@ sig: 57d07b3a
PrintBCD::
;> dest = PrintDigit(n >> 4, dest)
	push af
	push af
	swap a
	call PrintDigit
;> dest = PrintDigit(n, dest)
	pop af
	call PrintDigit
;> return dest
	pop af
	ret


;@ def PrintDigit(n: a, dest: hl) -> hl
;@ path: gfx/text
;@ Prints the low nibble of n as a digit tile ($3C = 0) in an HBlank; $F
;@ prints as a blank.
;@ sig: e43266dc
PrintDigit::
;>@tile tile = 0xFF if (n & 0x0F) == 0x0F else (n & 0x0F) + 0x3C
;=@tile
	and $0f
	cp $0f
	jr z, jr_000_2079

	add $3c

jr_000_2072:
;> wait_hblank()
	push af
	call WaitHBlank
;> mem[dest] = tile
;> return u16(dest + 1)
	pop af
	ld [hli], a
	ret


;=@tile
jr_000_2079:
	ld a, $ff
	jr jr_000_2072

;@ def PrintClock(dest: hl) -> hl
;@ path: game/panel
;@ Prints the play clock as M:SS (minutes without a leading zero); the
;@ colon is already on the screen.
;@ reads: wClockMinutes, wClockSeconds
;@ sig: ee4768d0
PrintClock::
;> dest = PrintBCD(BlankLeadingZero(wClockMinutes), dest)
	ld a, [wClockMinutes]
	call BlankLeadingZero
	call PrintBCD
;> dest = PrintBCD(wClockSeconds, u16(dest + 1))   # past the colon
	inc hl
	ld a, [wClockSeconds]
	call PrintBCD
;> return dest
	ret


;@ def PrintStepCount(dest: hl) -> hl
;@ path: game/panel
;@ Prints wStepCount as four digits without leading zeros.
;@ reads: wStepCount
;@ sig: 91637da9
PrintStepCount::
;> high = BlankLeadingZero(wStepCount >> 8)
	push bc
	ld a, [wStepCount + 1]
	call BlankLeadingZero
;> if high == 0xF0:                             # 00: both blank
	cp $f0
	jr nz, jr_000_209b

;>     high = 0xFF
	ld a, $ff

jr_000_209b:
;> dest = PrintBCD(high, dest)
	ld b, a
	call PrintBCD
;> low = wStepCount & 0xFF
;> if high == 0xFF:
	ld a, [wStepCount]
	inc b
	jr nz, jr_000_20a8

;>     low = BlankLeadingZero(low)
	call BlankLeadingZero

jr_000_20a8:
;> return PrintBCD(low, dest)
	call PrintBCD
	pop bc
	ret


;@ def PrintScore(dest: hl)
;@ path: game/panel
;@ Prints wScore and two zeros after it (the score counts hundreds), without
;@ leading zeros; a score of 0 prints as a single 0. The code is the end of
;@ AddRoomPoints.
;@ writes: wNoLeadYet
;@ reads: wScore
;@ sig: eb9523ec
PrintScore::
;> score = wScore
;>@lead wNoLeadYet = 1
;>@d1 dest = PrintBCDNoLead(hi(score), dest)
;>@d2 dest = PrintBCDNoLead(lo(score), dest)
;>@d3 dest = PrintBCDNoLead(0, dest)          # the two zeros
;>@zero if wScore == 0:
;>@one     PrintBCD(0xF0, u16(dest - 2))       # " 0" over the "00"
;>@ret return
	ld a, [wScore + 1]
	jr jr_000_20ca

;@ def AddRoomPoints()
;@ path: game/panel
;@ HEADING OUT?: a room is cleared, so wRoomPoints go onto wScore (BCD),
;@ and the score box shows the new score.
;@ writes: wScore
;@ reads: wRoomPoints, wScore
;@ sig: 2e895a06
AddRoomPoints::
;> bcd_write(addr(wScore), 2, (bcd_read(addr(wScore), 2) + bcd_to_int(wRoomPoints)) % 10000)
	ld a, [wRoomPoints]
	ld b, a
	ld a, [wScore]
	add b
	daa
	ld [wScore], a
	ld a, [wScore + 1]
	adc $00
	daa
	ld [wScore + 1], a
;> return PrintScore(0x9843)
	ld hl, $9843

;=@PrintScore.lead
jr_000_20ca:
	push af
	ld a, $01
	ld [wNoLeadYet], a
	pop af
;=@PrintScore.d1
	call PrintBCDNoLead
;=@PrintScore.d2
	ld a, [wScore]
	call PrintBCDNoLead
;=@PrintScore.d3
	xor a
	call PrintBCDNoLead
;=@PrintScore.zero
	dec hl
	dec hl
	ld a, [wScore]
	ld b, a
	ld a, [wScore + 1]
	or b
	jr nz, jr_000_20ef

;=@PrintScore.one
	ld a, $f0
	call PrintBCD

;=@PrintScore.ret
jr_000_20ef:
	ret


;@ def PrintBCDNoLead(n: a, dest: hl) -> hl
;@ path: gfx/text
;@ PrintBCD for a digit of a longer number: while wNoLeadYet is set, zero
;@ digits print as blanks; the first other digit clears it.
;@ writes: wNoLeadYet
;@ reads: wNoLeadYet
;@ test: n = rand(0, 0xFE)
;@ sig: 37a76d47
PrintBCDNoLead::
;> if wNoLeadYet:                              # only zeros so far
	ld b, a
	ld a, [wNoLeadYet]
	and a
	jr z, jr_000_210d

;>     if n < 0x10:                            # a leading zero digit
	ld a, b
	and $f0
	jr nz, jr_000_2109

;>         n |= 0xF0                           # prints as a blank
	ld a, b
	or $f0
	ld b, a
;>         if n == 0xF0:                       # 00: both blank, still leading
	and $0f
	jr nz, jr_000_2109

;>             n = 0xFF
	ld a, $ff
	ld b, a
	jr jr_000_210d

;>     if n != 0xFF:
;>         wNoLeadYet = 0
jr_000_2109:
	xor a
	ld [wNoLeadYet], a

jr_000_210d:
;> return PrintBCD(n, dest)
	ld a, b
	call PrintBCD
	ret


;@ def ToBCDBlank(n: a) -> a
;@ path: gfx/text
;@ A number below 100 as a BCD byte for PrintBCD, the tens as a blank when
;@ they are 0. Keeps bc and hl.
;@ sig: b9dee800
ToBCDBlank::
;> v = swap(n // 10) | n % 10
	push bc
	push hl
	ld l, a
	ld h, $00
	ld a, $0a
	call DivideHLByA
	swap l
	or l

;> return v | 0xF0 if v < 0x10 else v
jr_000_211f:
	cp $10
	jr nc, jr_000_2125

	or $f0

jr_000_2125:
	pop hl
	pop bc
	ret


;@ def BlankLeadingZero(n: a) -> a
;@ path: gfx/text
;@ A BCD byte with its tens digit made a blank ($F) when it is 0, for
;@ PrintBCD. The code is the end of ToBCDBlank.
;@ sig: 6951e89c
BlankLeadingZero::
;> return n | 0xF0 if n < 0x10 else n
	push bc
	push hl
	jr jr_000_211f

;@ def CanPushBlock()
;@ path: game/objects
;@ The current character pushes against a block in direction wMoveDir:
;@ finds the block's rectangle (wObjPtr, wObjWidth, wObjHeight) and sets
;@ wStepKind to 1 if the squares it would move onto are all floor, else 0.
;@ writes: wObjHeight, wObjWidth, wStepKind
;@ reads: wMoveDir
;@ test: k = rand(0, 3)
;@ test: wCharacter = k
;@ test: p = rand(0xC300, 0xC700)
;@ test: mem[0xC2D4 + 2 * k] = p & 0xFF
;@ test: mem[0xC2D5 + 2 * k] = p >> 8
;@ test: wMoveDir = rand(0, 5)
;@ sig: f9e55f9d
CanPushBlock::
;> wObjWidth = 1
;> wObjHeight = 1
	ld a, $01
	ld [wObjWidth], a
	ld [wObjHeight], a
;> ptr = CurCharTilePtr()
	call CurCharTilePtr
;> result = 0                                  # (no direction: blocked)
;> if wMoveDir == 1:                           # up: the block's bottom row is above
	ld a, [wMoveDir]
	cp $01
	jr nz, jr_000_2158

;>     ptr, _ = StepUp(ptr)
	call StepUp
;>     ptr = ToObjTop(ptr)
	call ToObjTop
;>     SavePtr1(ptr)
	call SavePtr1
;>     ToObjRight(ptr)
	call ToObjRight
;>     ptr = ToObjLeft(LoadPtr1())
	call LoadPtr1
	call ToObjLeft
;>     SetObjPtr(ptr)
	call SetObjPtr
;>     result = RowAboveFree(ptr)
	call RowAboveFree
	jr jr_000_21b0

;> elif wMoveDir == 2:                         # right: its left column is to the right
jr_000_2158:
	cp $02
	jr nz, jr_000_2176

;>     ptr, _ = StepRight(ptr)
	call StepRight
;>     SavePtr1(ptr)
	call SavePtr1
;>     ToObjBottom(ptr)
	call ToObjBottom
;>     ptr = ToObjTop(LoadPtr1())
	call LoadPtr1
	call ToObjTop
;>     SetObjPtr(ptr)
	call SetObjPtr
;>     ptr = ToObjRight(ptr)
	call ToObjRight
;>     result = ColumnRightFree(ptr)
	call ColumnRightFree
	jr jr_000_21b0

;> elif wMoveDir == 3:                         # down: its top row is below
jr_000_2176:
	cp $03
	jr nz, jr_000_2194

;>     ptr, _ = StepDown(ptr)
	call StepDown
;>     SavePtr1(ptr)
	call SavePtr1
;>     SetObjPtr(ToObjLeft(ptr))
	call ToObjLeft
	call SetObjPtr
;>     ptr = ToObjRight(LoadPtr1())
	call LoadPtr1
	call ToObjRight
;>     ptr = ToObjBottom(ptr)
	call ToObjBottom
;>     result = RowBelowFree(ptr)
	call RowBelowFree
	jr jr_000_21b0

;> elif wMoveDir == 4:                         # left: its right column is to the left
jr_000_2194:
	cp $04
	jr nz, jr_000_21b0

;>     ptr, _ = StepLeft(ptr)
	call StepLeft
;>     ptr = ToObjLeft(ptr)
	call ToObjLeft
;>     SavePtr1(ptr)
	call SavePtr1
;>     ToObjBottom(ptr)
	call ToObjBottom
;>     ptr = ToObjTop(LoadPtr1())
	call LoadPtr1
	call ToObjTop
;>     SetObjPtr(ptr)
	call SetObjPtr
;>     result = ColumnLeftFree(ptr)
	call ColumnLeftFree

;> wStepKind = 1 if result == 1 else 0
jr_000_21b0:
	cp $01
	jr z, jr_000_21b6

	ld a, $00

jr_000_21b6:
	ld [wStepKind], a
;> return
	ret


;@ def StepUp(ptr: hl) -> (hl, a)
;@ path: game/objects
;@ The square above in wTileBuffer, and its tile.
;@ test: ptr = rand(0xC114, 0xCF00)
;@ sig: 5696a27b
StepUp::
;> ptr = u16(ptr - 20)
	ld a, l
	sub $14
	ld l, a
	ld a, h
	sbc $00
	ld h, a
;> return ptr, mem[ptr]
	ld a, [hl]
	ret


;@ def StepDown(ptr: hl) -> (hl, a)
;@ path: game/objects
;@ The square below in wTileBuffer, and its tile.
;@ test: ptr = rand(0xC100, 0xCF00)
;@ sig: 6c95ddc4
StepDown::
;> ptr = u16(ptr + 20)
	ld a, $14
	call AddAToHL
;> return ptr, mem[ptr]
	ld a, [hl]
	ret


;@ def StepLeft(ptr: hl) -> (hl, a)
;@ path: game/objects
;@ The square to the left in wTileBuffer, and its tile.
;@ test: ptr = rand(0xC100, 0xCF00)
;@ sig: 985d5e7f
StepLeft::
;> ptr = u16(ptr - 1)
	dec hl
;> return ptr, mem[ptr]
	ld a, [hl]
	ret


;@ def StepRight(ptr: hl) -> (hl, a)
;@ path: game/objects
;@ The square to the right in wTileBuffer, and its tile.
;@ test: ptr = rand(0xC100, 0xCF00)
;@ sig: 964e0fc7
StepRight::
;> ptr = u16(ptr + 1)
	inc hl
;> return ptr, mem[ptr]
	ld a, [hl]
	ret


;@ def ToObjTop(ptr: hl) -> hl
;@ path: game/objects
;@ Up to the top square of a block, counting its rows in wObjHeight. The low
;@ nibble of a block's buffer tile tells which neighbours belong to the same
;@ block: bit 3 the one above, bit 1 below, bit 2 left, bit 0 right.
;@ test: ptr = rand(0xC800, 0xCF00)
;@ sig: d424a7e0
ToObjTop::
;> while mem[ptr] & 0x08:                      # joined to the square above
	ld a, [hl]
	and $0f
	cp $08
	jr c, jr_000_21e0

;>     IncObjHeight()
	call IncObjHeight
;>     ptr, _ = StepUp(ptr)
	call StepUp
	jr ToObjTop

;> return ptr
jr_000_21e0:
	ret


;@ def ToObjBottom(ptr: hl) -> hl
;@ path: game/objects
;@ Down to the bottom square of a block, counting its rows in wObjHeight.
;@ test: ptr = rand(0xC100, 0xC800)
;@ sig: 9aeedbb2
ToObjBottom::
;> while mem[ptr] & 0x02:                      # joined below ($22D8: the low nibbles without bit 1)
	ld c, $08
	ld a, [hl]
	and $0f
	ld b, a
	ld de, $22d8

jr_000_21ea:
	ld a, [de]
	cp b
	jr z, jr_000_21fa

	inc de
	dec c
	jr nz, jr_000_21ea

;>     IncObjHeight()
	call IncObjHeight
;>     ptr, _ = StepDown(ptr)
	call StepDown
	jr ToObjBottom

;> return ptr
jr_000_21fa:
	ret


;@ def ToObjLeft(ptr: hl) -> hl
;@ path: game/objects
;@ Left to the first square of a block's row, counting its columns in
;@ wObjWidth.
;@ test: ptr = rand(0xC800, 0xCF00)
;@ sig: f73c074d
ToObjLeft::
;> while mem[ptr] & 0x04:                      # joined to the left ($22E0: the low nibbles without bit 2)
	ld c, $08
	ld a, [hl]
	and $0f
	ld b, a
	ld de, $22e0

jr_000_2204:
	ld a, [de]
	cp b
	jr z, jr_000_2214

	inc de
	dec c
	jr nz, jr_000_2204

;>     IncObjWidth()
	call IncObjWidth
;>     ptr, _ = StepLeft(ptr)
	call StepLeft
	jr ToObjLeft

;> return ptr
jr_000_2214:
	ret


;@ def ToObjRight(ptr: hl) -> hl
;@ path: game/objects
;@ Right to the last square of a block's row, counting its columns in
;@ wObjWidth.
;@ test: ptr = rand(0xC100, 0xC800)
;@ sig: 367d95b8
ToObjRight::
;> while mem[ptr] & 0x01:                      # joined to the right ($22E8: the even low nibbles)
	ld c, $08
	ld a, [hl]
	and $0f
	ld b, a
	ld de, $22e8

jr_000_221e:
	ld a, [de]
	cp b
	jr z, jr_000_222e

	inc de
	dec c
	jr nz, jr_000_221e

;>     IncObjWidth()
	call IncObjWidth
;>     ptr, _ = StepRight(ptr)
	call StepRight
	jr ToObjRight

;> return ptr
jr_000_222e:
	ret


;@ def SavePtr1(ptr: hl)
;@ path: lib/memory
;@ Keeps a pointer in the scratch word at $CF07.
;@ writes: wBoxLeft, wRoomY
;@ sig: f5c5d7d5
SavePtr1::
;> wBoxLeft = lo(ptr)
	ld a, l
	ld [wBoxLeft], a
;> wRoomY = hi(ptr)
	ld a, h
	ld [wRoomY], a
;> return
	ret


;@ def SavePtr2(ptr: hl)
;@ path: lib/memory
;@ Keeps a pointer in the scratch word at $CF09.
;@ writes: wBoxMiddle, wRoomHeight
;@ sig: a67e78e6
SavePtr2::
;> wBoxMiddle = lo(ptr)
	ld a, l
	ld [wBoxMiddle], a
;> wRoomHeight = hi(ptr)
	ld a, h
	ld [wRoomHeight], a
;> return
	ret


;@ def LoadPtr1() -> hl
;@ path: lib/memory
;@ The pointer kept by SavePtr1.
;@ reads: wBoxLeft, wRoomY
;@ sig: b9243044
LoadPtr1::
;> return wBoxLeft | wRoomY << 8
	ld a, [wBoxLeft]
	ld l, a
	ld a, [wRoomY]
	ld h, a
	ret


;@ def LoadPtr2() -> hl
;@ path: lib/memory
;@ The pointer kept by SavePtr2.
;@ reads: wBoxMiddle, wRoomHeight
;@ sig: 06a7eafd
LoadPtr2::
;> return wBoxMiddle | wRoomHeight << 8
	ld a, [wBoxMiddle]
	ld l, a
	ld a, [wRoomHeight]
	ld h, a
	ret


;@ def IncObjHeight()
;@ path: game/objects
;@ One row more in wObjHeight.
;@ writes: wObjHeight
;@ reads: wObjHeight
;@ sig: da3d6402
IncObjHeight::
;> wObjHeight += 1
	ld a, [wObjHeight]
	inc a
	ld [wObjHeight], a
;> return
	ret


;@ def IncObjWidth()
;@ path: game/objects
;@ One column more in wObjWidth.
;@ writes: wObjWidth
;@ reads: wObjWidth
;@ sig: 7d880581
IncObjWidth::
;> wObjWidth += 1
	ld a, [wObjWidth]
	inc a
	ld [wObjWidth], a
;> return
	ret


;@ def SetObjPtr(ptr: hl)
;@ path: game/objects
;@ The moving rectangle starts at ptr (its top left square).
;@ writes: wObjPtr
;@ sig: 8064bfc6
SetObjPtr::
;> wObjPtr = ptr
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
;> return
	ret


;@ def RowAboveFree(ptr: hl) -> a
;@ path: game/objects
;@ Whether the row above the block (from its top left square ptr, wObjWidth
;@ squares to the right) is all floor (kind $00 or $E0): 1 if so, otherwise
;@ the kind (high nibble) of the first square in the way.
;@ reads: wObjWidth
;@ test: ptr = rand(0xC200, 0xC800)
;@ sig: ca966be5
RowAboveFree::
;> n = wObjWidth
	ld a, [wObjWidth]
	ld b, a
;> ptr, tile = StepUp(ptr)
	call StepUp

;> while True:
;>     if tile & 0xF0 not in (0x00, 0xE0):     # in the way
;>         return tile & 0xF0
jr_000_2273:
	and $f0
	and a
	jr z, jr_000_227c

	cp $e0
	jr nz, jr_000_2286

jr_000_227c:
;>     n = u8(n - 1)
;>     if n == 0:
;>@all         return 1
	dec b
	jr z, jr_000_2284

;>     ptr, tile = StepRight(ptr)
	call StepRight
	jr jr_000_2273

;=@all
jr_000_2284:
	ld a, $01

jr_000_2286:
	ret


;@ def RowBelowFree(ptr: hl) -> a
;@ path: game/objects
;@ RowAboveFree for the row below the block, from its bottom right square
;@ ptr to the left.
;@ reads: wObjWidth
;@ test: ptr = rand(0xC200, 0xC800)
;@ sig: b83ac387
RowBelowFree::
;> n = wObjWidth
	ld a, [wObjWidth]
	ld b, a
;> ptr, tile = StepDown(ptr)
	call StepDown

;> while True:
;>     if tile & 0xF0 not in (0x00, 0xE0):     # in the way
;>         return tile & 0xF0
jr_000_228e:
	and $f0
	and a
	jr z, jr_000_2297

	cp $e0
	jr nz, jr_000_22a1

jr_000_2297:
;>     n = u8(n - 1)
;>     if n == 0:
;>@all         return 1
	dec b
	jr z, jr_000_229f

;>     ptr, tile = StepLeft(ptr)
	call StepLeft
	jr jr_000_228e

;=@all
jr_000_229f:
	ld a, $01

jr_000_22a1:
	ret


;@ def ColumnLeftFree(ptr: hl) -> a
;@ path: game/objects
;@ RowAboveFree for the column left of the block, from its top left square
;@ ptr down, wObjHeight squares.
;@ reads: wObjHeight
;@ test: ptr = rand(0xC200, 0xC800)
;@ sig: 75f50db9
ColumnLeftFree::
;> n = wObjHeight
	ld a, [wObjHeight]
	ld b, a
;> ptr, tile = StepLeft(ptr)
	call StepLeft

;> while True:
;>     if tile & 0xF0 not in (0x00, 0xE0):     # in the way
;>         return tile & 0xF0
jr_000_22a9:
	and $f0
	and a
	jr z, jr_000_22b2

	cp $e0
	jr nz, jr_000_22bc

jr_000_22b2:
;>     n = u8(n - 1)
;>     if n == 0:
;>@all         return 1
	dec b
	jr z, jr_000_22ba

;>     ptr, tile = StepDown(ptr)
	call StepDown
	jr jr_000_22a9

;=@all
jr_000_22ba:
	ld a, $01

jr_000_22bc:
	ret


;@ def ColumnRightFree(ptr: hl) -> a
;@ path: game/objects
;@ RowAboveFree for the column right of the block, from its top right
;@ square ptr down, wObjHeight squares.
;@ reads: wObjHeight
;@ test: ptr = rand(0xC200, 0xC800)
;@ sig: bc6e9f0e
ColumnRightFree::
;> n = wObjHeight
	ld a, [wObjHeight]
	ld b, a
;> ptr, tile = StepRight(ptr)
	call StepRight

;> while True:
;>     if tile & 0xF0 not in (0x00, 0xE0):     # in the way
;>         return tile & 0xF0
jr_000_22c4:
	and $f0
	and a
	jr z, jr_000_22cd

	cp $e0
	jr nz, jr_000_22d7

jr_000_22cd:
;>     n = u8(n - 1)
;>     if n == 0:
;>@all         return 1
	dec b
	jr z, jr_000_22d5

;>     ptr, tile = StepDown(ptr)
	call StepDown
	jr jr_000_22c4

;=@all
jr_000_22d5:
	ld a, $01

jr_000_22d7:
	ret


	db $00, $01, $04, $05, $08, $09, $0c, $0d, $00, $01, $02, $03, $08, $09, $0a, $0b
	db $00, $02, $04, $06, $08, $0a, $0c, $0e

;@ def TryTurnTurnstile()
;@ path: game/turnstile
;@ The character walks into a turnstile arm. Pushed end on, the arm does not
;@ give. Otherwise this finds the centre, makes the 3 x 3 square around it
;@ the moving rectangle and checks the squares the arms sweep through (table
;@ at $2479, by the turnstile's shape and the arm pushed) against what stands
;@ round the centre. If they are free, wStepKind = 2 and wMenuLastCol says
;@ which way it turns. Some shapes let the character through to the far side
;@ (wStepTiles = 2), unless that square is a hole.
;@ writes: wMenuLastCol, wObjHeight, wObjPtr, wObjWidth, wStepKind, wStepTiles
;@ reads: wMoveDir
;@ test: wMoveDir = rand(0, 5); wCharacter = rand(0, 3); pos = 0xC100 + rand(42, 310); mem[0xC2D4 + 2 * wCharacter] = pos & 0xFF; mem[0xC2D5 + 2 * wCharacter] = pos >> 8
;@ test: d = {1: -20, 2: 1, 3: 20, 4: -1}.get(wMoveDir, 0); mem[pos + d] = 0x80 + rand(0, 3)
;@ test: rand(0, 1) and [mem.__setitem__(pos + d + k, rand(0, 1) * 0xE0) for k in (-42, -41, -40, -22, -21, -19, -18, -2, 2, 18, 19, 21, 22, 40, 41, 42)]
;@ sig: b8015602
TryTurnTurnstile::
;> wObjWidth = 3
;> wObjHeight = 3
	ld a, $03
	ld [wObjWidth], a
	ld [wObjHeight], a
;> wStepKind = 0                                 # blocked, unless it turns
	xor a
	ld [wStepKind], a
;> wStepTiles = 1
	ld a, $01
	ld [wStepTiles], a
;> pos = CurCharTilePtr()
	call CurCharTilePtr
;> SavePtr1(pos)
	call SavePtr1
;> if wMoveDir == 1:                             # up
	ld a, [wMoveDir]
	cp $01
	jr nz, jr_000_232a

;>     arm, t = StepUp(pos)
	call StepUp
;>     if t == 0x82: return                      # pushed end on
	cp $82
	jp z, Jump_000_2468

;>     if t == 0x81:
	cp $81
	jr nz, jr_000_2322

;>         sweep = 4
;>         centre, shape = StepLeft(arm)
	ld e, $04
	call StepLeft
	ld d, a
	jr jr_000_2389

jr_000_2322:
;>     else:
;>         sweep = 6
;>         centre, shape = StepRight(arm)
	ld e, $06
	call StepRight
	ld d, a
	jr jr_000_2389

jr_000_232a:
;> elif wMoveDir == 2:                           # right
	cp $02
	jr nz, jr_000_234a

;>     arm, t = StepRight(pos)
	call StepRight
;>     if t == 0x83: return
	cp $83
	jp z, Jump_000_2468

;>     if t == 0x80:
	cp $80
	jr nz, jr_000_2342

;>         sweep = 0
;>         centre, shape = StepDown(arm)
	ld e, $00
	call StepDown
	ld d, a
	jr jr_000_2389

jr_000_2342:
;>     else:
;>         sweep = 6
;>         centre, shape = StepUp(arm)
	ld e, $06
	call StepUp
	ld d, a
	jr jr_000_2389

jr_000_234a:
;> elif wMoveDir == 3:                           # down
	cp $03
	jr nz, jr_000_236a

;>     arm, t = StepDown(pos)
	call StepDown
;>     if t == 0x80: return
	cp $80
	jp z, Jump_000_2468

;>     if t == 0x81:
	cp $81
	jr nz, jr_000_2362

;>         sweep = 2
;>         centre, shape = StepLeft(arm)
	ld e, $02
	call StepLeft
	ld d, a
	jr jr_000_2389

jr_000_2362:
;>     else:
;>         sweep = 0
;>         centre, shape = StepRight(arm)
	ld e, $00
	call StepRight
	ld d, a
	jr jr_000_2389

jr_000_236a:
;> else:
;>     if wMoveDir != 4: return
	cp $04
	jp nz, Jump_000_2468

;>     arm, t = StepLeft(pos)                    # left
	call StepLeft
;>     if t == 0x81: return
	cp $81
	jp z, Jump_000_2468

;>     if t == 0x80:
	cp $80
	jr nz, jr_000_2383

;>         sweep = 2
;>         centre, shape = StepDown(arm)
	ld e, $02
	call StepDown
	ld d, a
	jr jr_000_2389

jr_000_2383:
;>     else:
;>         sweep = 4
;>         centre, shape = StepUp(arm)
	ld e, $04
	call StepUp
	ld d, a

jr_000_2389:
;> corner = u16(centre - 21)                     # the top left of the 3 x 3 square
	call StepUp
	call StepLeft
;> wObjPtr = corner
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
;> around = 0                                    # bit k: the k-th square round the centre is taken
;> sq = corner
	ld bc, $0008

;> for k in range(8):                            # clockwise from the top left
jr_000_239a:
;>     t = mem[sq]
;>     around = around >> 1 | (0x80 if t != 0 and t != 0xE0 else 0)
	ld a, [hl]
	and a
	jr z, jr_000_23a2

	cp $e0
	jr nz, jr_000_23a6

jr_000_23a2:
	srl b
	jr jr_000_23a9

jr_000_23a6:
	scf
	rr b

jr_000_23a9:
;>     if k < 7: sq += (1, 1, 20, 20, -1, -1, -20)[k]
	ld a, c
	dec a
	ld c, a
	cp $06
	jr c, jr_000_23b5

	call StepRight
	jr jr_000_239a

jr_000_23b5:
	cp $04
	jr c, jr_000_23be

	call StepDown
	jr jr_000_239a

jr_000_23be:
	cp $02
	jr c, jr_000_23c7

	call StepLeft
	jr jr_000_239a

jr_000_23c7:
	and a
	jr z, jr_000_23cf

	call StepUp
	jr jr_000_239a

jr_000_23cf:
;> turn = u8(wMoveDir - mem[0x2472 + sweep])
	ld hl, $2472
	ld a, e
	call AddAToHL
	ld a, [hl]
	ld c, a
	ld a, [wMoveDir]
	sub c
;> if turn == 3: turn = 1
	cp $03
	jr nz, jr_000_23e2

	dec a
	dec a

jr_000_23e2:
	ld c, a
	ld a, d
	push af
;> wMenuLastCol = 0 if wMoveDir == mem[0x24EA + sweep] else 1   # (reused: the way it turns)
	ld hl, $24ea
	ld a, e
	call AddAToHL
	ld a, [hl]
	ld d, a
	ld a, [wMoveDir]
	sub d
	jr z, jr_000_23f6

	ld a, $01

jr_000_23f6:
	ld [wMenuLastCol], a
;> shape &= 0x0F
	pop af
	and $0f
	push af
;> if mem[0x24DB + shape] >> (wMoveDir - 1) & 1:
	ld hl, $24db
	call AddAToHL
	ld a, [hl]
	ld d, a
	ld a, [wMoveDir]

jr_000_2408:
	srl d
	dec a
	jr z, jr_000_240f

	jr jr_000_2408

jr_000_240f:
	jr nc, jr_000_2416

;>     wStepTiles = 2                            # through to the far side
	ld a, $02
	ld [wStepTiles], a

jr_000_2416:
	cp $02
	jr nz, jr_000_2451

;>     far = LoadPtr1()
	call LoadPtr1
;>     if wMoveDir == 1: far, t = StepUp(StepUp(far)[0])
	ld a, [wMoveDir]
	cp $01
	jr nz, jr_000_242c

	call StepUp
	call StepUp
	jr jr_000_244a

jr_000_242c:
;>     elif wMoveDir == 2: far, t = StepRight(StepRight(far)[0])
	cp $02
	jr nz, jr_000_2438

	call StepRight
	call StepRight
	jr jr_000_244a

jr_000_2438:
;>     elif wMoveDir == 3: far, t = StepDown(StepDown(far)[0])
	cp $03
	jr nz, jr_000_2444

	call StepDown
	call StepDown
	jr jr_000_244a

jr_000_2444:
;>     else: far, t = StepLeft(StepLeft(far)[0])
	call StepLeft
	call StepLeft

jr_000_244a:
;>     if t == 0xE0: return                      # a hole there
	cp $e0
	jr nz, jr_000_2451

	pop af
	jr jr_000_2468

jr_000_2451:
;> table = 0x2479 + shape
	pop af
	ld hl, $2479
	call AddAToHL
;> row = table + mem[table]
	ld a, [hl]
	call AddAToHL
;> if mem[AddCEToHL(row, turn, sweep)] & around: return   # something in the arms' way
	call AddCEToHL
	ld a, [hl]
	and b
	jr nz, jr_000_2468

;> wStepKind = 2
	ld a, $02
	ld [wStepKind], a

Jump_000_2468:
jr_000_2468:
	ret


;@ def AddCEToHL(ptr: hl, row: c, col: e) -> hl
;@ path: lib/math
;@ hl + (c + e), the sum kept to 8 bits: an index made of two parts, added on
;@ by AddAToHL, which it runs into.
;@ test: ptr = rand(0, 0xFFFF)
;@ sig: cb9502da
AddCEToHL::
;> return AddAToHL(ptr, u8(row + col))   # falls through
	ld a, c
	add e

;@ def AddAToHL(ptr: hl, n: a) -> hl
;@ path: lib/math
;@ hl + a.
;@ sig: 934ee143
AddAToHL::
;> return u16(ptr + n)
	add l
	ld l, a
	ld a, h
	adc $00
	ld h, a
	ret


	db $02, $00, $03, $00, $01, $00, $01, $0f, $0e, $0d, $0c, $13, $17, $1e, $25, $2b
	db $32, $39, $40, $4e, $45, $44, $0c, $60, $30, $81, $06, $c0, $03, $18, $34, $00
	db $30, $81, $85, $00, $00, $d0, $00, $06, $c0, $00, $16, $00, $58, $00, $00, $00
	db $43, $03, $18, $0c, $60, $00, $61, $00, $00, $0d, $d4, $00, $d0, $91, $85, $c4
	db $00, $95, $00, $56, $53, $00, $46, $43, $13, $16, $4c, $58, $00, $59, $00, $4d
	db $0d, $19, $34, $64, $31, $61, $65, $00, $35, $cc, $66, $33, $99, $66, $cc, $33
	db $99, $54, $54, $51, $51, $45, $45, $15, $15, $00, $00, $00, $00, $0c, $09, $03
	db $06, $0d, $0b, $07, $0e, $0f, $00, $00, $03, $00, $04, $00, $01, $00, $02

;@ def SetSprite(slot: a, y: c, x: b, tile: d, attr: e)
;@ path: game/objects
;@ Writes one sprite into wShadowOAM: slot `slot`, at (x, y) in OAM space,
;@ with a tile and its attributes. Keeps every register.
;@ test: slot = rand(0, 39)
;@ sig: 3f43486a
SetSprite::
;> at = wShadowOAM + 4 * slot
	push af
	push bc
	push de
	push hl
	push de
	ld de, $0000
	ld hl, wShadowOAM
	ld e, a
	sla e
	rl d
	sla e
	rl d
	add hl, de
	pop de
;> mem[at] = y
;> mem[at + 1] = x
;> mem[at + 2] = tile
;> mem[at + 3] = attr
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
	ld a, d
	ld [hli], a
	ld a, e
	ld [hli], a
	pop hl
	pop de
	pop bc
	pop af
	ret


;@ def MoveObject()
;@ path: game/objects
;@ Moves the block or turnstile of this step in wTileBuffer, once its sprites
;@ have slid there: lifts it out into wObjTiles (a block wholly, a turnstile's
;@ centre and arms), redraws the bare rectangle, then puts a block back one
;@ square further in wMoveDir, or a turnstile turned a quarter (the shape
;@ tables at $3F61 and $3F70, wMenuLastCol picks which). A square left over a
;@ hole stays a hole; anything put down over one is stored as its tile + $10.
;@ writes: wObjPtr
;@ reads: wMenuLastCol, wMoveDir, wObjHeight, wObjPtr, wObjWidth, wStepKind
;@ test: wStepKind = rand(1, 2); wMoveDir = rand(0, 4)
;@ test: wObjWidth = 3 if wStepKind == 2 else rand(1, 4); wObjHeight = 3 if wStepKind == 2 else rand(1, 3)
;@ test: wObjPtr = 0xC100 + rand(21, 240); wDiagonalView = rand(0, 1); wMenuLastCol = rand(0, 1)
;@ sig: 8ffe7b4a
MoveObject::
;> ptr = wObjPtr
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
;> tiles = wObjTiles
	ld de, wObjTiles
;> if wStepKind != 2:                            # a block: lift all of it
	ld a, [wStepKind]
	cp $02
	jp z, Jump_000_2542

;>     for y in range(wObjHeight):
	ld a, [wObjHeight]
	ld c, a

Jump_000_252b:
;>         for x in range(wObjWidth):
	ld a, [wObjWidth]
	ld b, a

Jump_000_252f:
;>             LiftTile(ptr + 20 * y + x, tiles + wObjWidth * y + x)
	call LiftTile
	inc de
	inc hl
	dec b
	jp nz, Jump_000_252f

	call ObjNextRow
	dec c
	jp nz, Jump_000_252b

	jp Jump_000_25de


;> else:                                         # a turnstile: keep a copy of its square
Jump_000_2542:
;>     for y in range(wObjHeight):
	ld a, [wObjHeight]
	ld c, a

Jump_000_2546:
;>         for x in range(wObjWidth):
	ld a, [wObjWidth]
	ld b, a

Jump_000_254a:
;>             mem[tiles + wObjWidth * y + x] = mem[ptr + 20 * y + x]
	ld a, [hl]
	ld [de], a
	inc de
	inc hl
	dec b
	jp nz, Jump_000_254a

	call ObjNextRow
	dec c
	jp nz, Jump_000_2546

;>     centre = ptr + 21
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	ld bc, $0015
	add hl, bc
;>     shape = mem[centre] & 0x0F
;>     mem[centre] = 0
	ld a, [hl]
	push af
	xor a
	ld [hl], a
	pop af
;>     arms = mem[0x3F7F + shape]                 # bit 7 up, 6 right, 5 down, 4 left
	and $0f
	ld de, $3f7f
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]
	ld b, a
;>     if arms & 0x80: LiftArmUp(centre)
	push hl
	sla b
	call c, LiftArmUp
	pop hl
;>     if arms & 0x40: LiftArmRight(centre)
	push hl
	sla b
	call c, LiftArmRight
	pop hl
;>     if arms & 0x20: LiftArmDown(centre)
	push hl
	sla b
	call c, LiftArmDown
	pop hl
;>     if arms & 0x10: LiftArmLeft(centre)
	push hl
	sla b
	call c, LiftArmLeft
	pop hl
	jp Jump_000_25bc
;>@redraw DrawObjectRect()                         # the rectangle without the object
;>@turn if wStepKind == 2:
;>@t1     centre = ptr + 21
;>@t2     table = 0x3F61 if wMenuLastCol else 0x3F70  # the shape turned one way or the other
;>@t3     shape = mem[table + (mem[tiles + 4] & 0x0F)]
;>@t4     mem[tiles + 4] = shape
;>@t5     arms = mem[0x3F7F + (shape & 0x0F)]
;>@t6     mem[centre] = shape
;>@t7     if arms & 0x80: PutArmUp(centre)
;>@t8     if arms & 0x40: PutArmRight(centre)
;>@t9     if arms & 0x20: PutArmDown(centre)
;>@t10     if arms & 0x10: PutArmLeft(centre)
;>@t11     return
;>@d0 step = {1: -20, 2: 1, 3: 20, 4: -1}.get(wMoveDir)
;>@d1 if step is None: return
;>@d2 ptr = u16(ptr + step)
;>@d3 wObjPtr = ptr
;>@d4 for y in range(wObjHeight):
;>@d5     for x in range(wObjWidth):
;>@d6         mem[ptr + 20 * y + x] = DropTile(ptr + 20 * y + x, tiles + wObjWidth * y + x)


;@ def LiftArmLeft(centre: hl)
;@ path: game/turnstile
;@ Lifts a turnstile's left arm into its place in wObjTiles.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 72d4ad30
LiftArmLeft::
;> LiftTile(centre - 1, wObjTiles + 3)
	dec hl
	ld de, wObjTiles + 3
	call LiftTile
	ret


;@ def LiftArmRight(centre: hl)
;@ path: game/turnstile
;@ Lifts a turnstile's right arm into its place in wObjTiles.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: ecf9178e
LiftArmRight::
;> LiftTile(centre + 1, wObjTiles + 5)
	inc hl
	ld de, wObjTiles + 5
	call LiftTile
	ret


;@ def LiftArmUp(centre: hl)
;@ path: game/turnstile
;@ Lifts a turnstile's upper arm into its place in wObjTiles.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 66298e17
LiftArmUp::
;> LiftTile(centre - 20, wObjTiles + 1)
	ld de, $ffec
	add hl, de
	ld de, wObjTiles + 1
	call LiftTile
	ret


;@ def LiftArmDown(centre: hl)
;@ path: game/turnstile
;@ Lifts a turnstile's lower arm into its place in wObjTiles.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 0b57e430
LiftArmDown::
;> LiftTile(centre + 20, wObjTiles + 7)
	ld de, $0014
	add hl, de
	ld de, wObjTiles + 7
	call LiftTile
	ret


;=@MoveObject.redraw
Jump_000_25bc:
	jp Jump_000_25de


;@ def LiftTile(src: hl, save: de)
;@ path: game/objects
;@ Takes one square of a moving object out of wTileBuffer into `save`. An
;@ object standing in a hole ($50 a block, $90 an arm) comes out as itself
;@ and leaves the hole ($E0); anything else leaves floor (0).
;@ test: src = 0xC100 + rand(0, 359); save = 0xC29A + rand(0, 29)
;@ sig: 9893a54a
LiftTile::
;> kind = mem[src] & 0xF0
	push bc
	ld a, [hl]
	and $f0
;> if kind == 0x50 or kind == 0x90:              # a block or an arm in a hole
;>@in     keep, leave = mem[src] - 0x10, 0xE0     # it comes out, the hole stays
;>@hole elif kind == 0xE0:
;>@h2     keep, leave = 0xE0, 0xE0
	cp $50
	jr z, jr_000_25d4

	cp $90
	jr z, jr_000_25d4

;=@hole
	cp $e0
	jr z, jr_000_25d7

;> else:
;>     keep, leave = mem[src], 0                 # floor is left behind
	ld a, [hl]
	ld b, $00
	jr jr_000_25d9

;=@in
jr_000_25d4:
	ld a, [hl]
	sub $10

;=@h2
jr_000_25d7:
	ld b, $e0

;> mem[save] = keep
;> mem[src] = leave
jr_000_25d9:
	ld [de], a
	ld a, b
	ld [hl], a
	pop bc
	ret


;=@MoveObject.redraw
Jump_000_25de:
	call DrawObjectRect
;=@MoveObject.turn
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	ld a, [wStepKind]
	cp $02
	jr z, jr_000_263d

;=@MoveObject.d0
	ld a, [wMoveDir]
	dec a
	jr z, jr_000_2600

	dec a
	jr z, jr_000_2605

	dec a
	jr z, jr_000_260a

	dec a
	jr z, jr_000_260f

;=@MoveObject.d1
	ret


;=@MoveObject.d0
jr_000_2600:
	ld de, $ffec
	jr jr_000_2612

jr_000_2605:
	ld de, $0001
	jr jr_000_2612

jr_000_260a:
	ld de, $0014
	jr jr_000_2612

jr_000_260f:
	ld de, $ffff

;=@MoveObject.d2
jr_000_2612:
	add hl, de
;=@MoveObject.d3
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
;=@MoveObject.d4
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	ld de, wObjTiles
	ld a, [wObjHeight]
	ld c, a

;=@MoveObject.d5
jr_000_262a:
	ld a, [wObjWidth]
	ld b, a

;=@MoveObject.d6
jr_000_262e:
	call DropTile
	ld [hli], a
	inc de
	dec b
	jr nz, jr_000_262e

	call ObjNextRow
	dec c
	jr nz, jr_000_262a

	ret


;=@MoveObject.t1
jr_000_263d:
	ld de, $0015
	add hl, de
	push hl
;=@MoveObject.t2
	ld de, wObjTiles + 4
	ld a, [wMenuLastCol]
	and a
	jr z, jr_000_2651

	ld a, [de]
	ld hl, $3f61
	jr jr_000_2654

jr_000_2651:
	ld hl, $3f70

;=@MoveObject.t3
jr_000_2654:
	ld a, [de]
	and $0f
	push de
	and $0f
	ld e, a
	ld d, $00
	add hl, de
	pop de
	ld a, [hl]
;=@MoveObject.t4
	ld [de], a
;=@MoveObject.t5
	and $0f
	ld hl, $3f7f
	ld e, a
	ld d, $00
	add hl, de
	ld a, [hl]
	ld b, a
;=@MoveObject.t6
	pop hl
	ld de, wObjTiles + 4
	ld a, [de]
	ld [hl], a
;=@MoveObject.t7
	push hl
	sla b
	call c, PutArmUp
	pop hl
;=@MoveObject.t8
	push hl
	sla b
	call c, PutArmRight
	pop hl
;=@MoveObject.t9
	push hl
	sla b
	call c, PutArmDown
	pop hl
;=@MoveObject.t10
	push hl
	sla b
	call c, PutArmLeft
	pop hl
;=@MoveObject.t11
	ret


;@ def PutArmUp(centre: hl)
;@ path: game/turnstile
;@ Puts a turnstile's upper arm ($80) above its centre; over a hole it is $90.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 69b1074c
PutArmUp::
;> at = centre - 20
	ld de, $ffec
	add hl, de
;> if mem[at] == 0xE0:
	ld a, [hl]
	cp $e0
	jr nz, jr_000_269c

;>     mem[at] = 0x90                            # the arm over a hole
	ld a, $90
	ld [hl], a
	ret


jr_000_269c:
;> else:
;>     mem[at] = 0x80
	ld a, $80
	ld [hl], a
	ret


;@ def PutArmDown(centre: hl)
;@ path: game/turnstile
;@ Puts a turnstile's lower arm ($82) below its centre; over a hole it is $92.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 1171ea23
PutArmDown::
;> at = centre + 20
	ld de, $0014
	add hl, de
;> if mem[at] == 0xE0:
	ld a, [hl]
	cp $e0
	jr nz, jr_000_26ad

;>     mem[at] = 0x92                            # the arm over a hole
	ld a, $92
	ld [hl], a
	ret


jr_000_26ad:
;> else:
;>     mem[at] = 0x82
	ld a, $82
	ld [hl], a
	ret


;@ def PutArmRight(centre: hl)
;@ path: game/turnstile
;@ Puts a turnstile's right arm ($81) beside its centre; over a hole it is $91.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: e18b7895
PutArmRight::
;> at = centre + 1
	inc hl
;> if mem[at] == 0xE0:
	ld a, [hl]
	cp $e0
	jr nz, jr_000_26bb

;>     mem[at] = 0x91                            # the arm over a hole
	ld a, $91
	ld [hl], a
	ret


jr_000_26bb:
;> else:
;>     mem[at] = 0x81
	ld a, $81
	ld [hl], a
	ret


;@ def PutArmLeft(centre: hl)
;@ path: game/turnstile
;@ Puts a turnstile's left arm ($83) beside its centre; over a hole it is $93.
;@ test: centre = 0xC100 + rand(21, 330)
;@ sig: 46c9a3e4
PutArmLeft::
;> at = centre - 1
	dec hl
;> if mem[at] == 0xE0:
	ld a, [hl]
	cp $e0
	jr nz, jr_000_26c9

;>     mem[at] = 0x93                            # the arm over a hole
	ld a, $93
	ld [hl], a
	ret


jr_000_26c9:
;> else:
;>     mem[at] = 0x83
	ld a, $83
	ld [hl], a
	ret


;@ def DropTile(dest: hl, saved: de) -> a
;@ path: game/objects
;@ The tile a moving object leaves on the square `dest`: its own tile from
;@ `saved`, or over a hole ($E0) the tile + $10 (an empty or hole square
;@ there just keeps the hole).
;@ test: dest = 0xC100 + rand(0, 359); saved = 0xC29A + rand(0, 29)
;@ sig: 2050d2ed
DropTile::
;> if mem[dest] == 0xE0:                          # onto a hole
	ld a, [hl]
	cp $e0
	jr nz, jr_000_26e0

;>     t = mem[saved]
	ld a, [de]
;>     if t != 0 and t != 0xE0:
	and a
	jr z, jr_000_26dd

	cp $e0
	jr z, jr_000_26dd

;>         return u8(t + 0x10)                     # it now stands in the hole
	add $10
	ret


jr_000_26dd:
;>     return 0xE0                               # nothing on it: still a hole
	ld a, $e0
	ret


jr_000_26e0:
;> return mem[saved]
	ld a, [de]
	ret


;@ def DrawObjectRect() -> a
;@ path: game/objects
;@ Redraws the moving rectangle (wObjPtr, wObjWidth x wObjHeight) in the BG
;@ map from wTileBuffer: every square through BufferTileToBG into
;@ wObjBGTiles, then into the BG map in HBlanks. In the diagonal view one row
;@ more, for the shadows the squares cast below.
;@ writes: wObjHeight
;@ reads: wDiagonalView, wObjHeight, wObjPtr, wObjWidth
;@ test: wObjWidth = rand(1, 4); wObjHeight = rand(1, 4); wObjPtr = 0xC100 + rand(21, 240)
;@ sig: 9bb823e9
DrawObjectRect::
;> if wDiagonalView: wObjHeight += 1            # one row more for the shadows
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_26ef

	ld a, [wObjHeight]
	inc a
	ld [wObjHeight], a

jr_000_26ef:
;> ptr = wObjPtr
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
;> for y in range(wObjHeight):
;>     for x in range(wObjWidth):
	ld de, wObjBGTiles
	ld a, [wObjHeight]
	ld c, a

jr_000_26fe:
	ld a, [wObjWidth]
	ld b, a

jr_000_2702:
;>         sq = ptr + 20 * y + x
;>         wObjBGTiles[wObjWidth * y + x] = BufferTileToBG(mem[sq], sq)
	ld a, [hl]
	call BufferTileToBG
	ld [de], a
	inc de
	inc hl
	dec b
	jr nz, jr_000_2702

	call ObjNextRow
	dec c
	jr nz, jr_000_26fe

;> CopyRectToBGMap(BufferAddrToBGMap(ptr))
	ld de, wObjBGTiles
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	call BufferAddrToBGMap
	call CopyRectToBGMap
;> if wDiagonalView: wObjHeight -= 1
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_2730

	ld a, [wObjHeight]
	dec a
	ld [wObjHeight], a

jr_000_2730:
;> return wObjHeight if wDiagonalView else 0   # what is left in a
	ret


;@ def BufferTileToBG(tile: a, at: hl) -> a
;@ path: game/room
;@ The BG tile that shows the buffer tile `tile` on the square `at`. The
;@ high nibble is the kind, the low one picks from the kind's tiles (table
;@ at $3EDF). The stairs ($10) and the characters ($C0, they are sprites)
;@ show the floor. In the diagonal view a floor square below anything else
;@ shows the shadow ($FB). A hole ($E0) gets its edges from what is around
;@ it: the wall face above, holes left and right (table at $3F54).
;@ writes: wBoxLeft, wBoxMiddle, wRoomHeight, wRoomY
;@ reads: wBoxLeft, wBoxMiddle, wDiagonalView, wRoomHeight, wRoomY
;@ test: at = 0xC100 + rand(21, 330); tile = rand(0, 255) if rand(0, 1) else 0xE0
;@ sig: c8c050a1
BufferTileToBG::
;> if tile & 0xF0 == 0x10: tile = 0
	push bc
	push de
	push hl
	push af
	and $f0
	cp $10
	jr nz, jr_000_273e

	pop af
	xor a
	push af

jr_000_273e:
;> mem16[0xCF09] = at                              # (kept in the box scratch bytes)
	ld a, l
	ld [wBoxMiddle], a
	ld a, h
	ld [wRoomHeight], a
;> if tile != 0xE0:
	pop af
	cp $e0
	jp z, Jump_000_27c4

;>     wBoxLeft = tile
	ld [wBoxLeft], a
;>     if tile & 0xF0 == 0xC0: wBoxLeft = 0
	and $f0
	cp $c0
	jr nz, jr_000_2759

	xor a
	ld [wBoxLeft], a

jr_000_2759:
;>     table = 0x3EDF + 2 * (wBoxLeft >> 4)       # the tiles of each kind
	ld a, [wBoxLeft]
	ld hl, $3edf
	swap a
	and $0f
	ld e, a
	ld d, $00
	sla e
	rl d
	add hl, de
;>     base = mem16[table]
;>     wRoomY = lo(base)
	ld a, [hli]
	ld [wRoomY], a
	ld a, [hl]
	ld h, a
	ld a, [wRoomY]
	ld l, a
;>     entry = base + (wBoxLeft & 0x0F)
	ld a, [wBoxLeft]
	and $0f
	ld e, a
	ld d, $00
	add hl, de
	push hl
;>     if wDiagonalView and mem[at] & 0xF0 in (0x00, 0x10, 0xC0):
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_27b7

	ld a, [wBoxMiddle]
	ld l, a
	ld a, [wRoomHeight]
	ld h, a
	ld a, [hl]
	and $f0
	cp $10
	jr z, jr_000_279c

	cp $c0
	jr z, jr_000_279c

	cp $00
	jr nz, jr_000_27b7

jr_000_279c:
;>         if mem[at - 20] & 0xF0 not in (0x00, 0x10, 0xC0):
;>@shadow             return 0xFB                  # in the shadow of what is above
	ld de, $ffec
	add hl, de
	ld a, [hl]
	and $f0
	cp $00
	jr z, jr_000_27b7

	cp $10
	jr z, jr_000_27b7

	cp $c0
	jr z, jr_000_27b7

	cp $e0
	jr z, jr_000_27bd

;=@shadow
	ld a, $fb
	jr jr_000_27bf

;>     return mem[entry]
;>@h0 above = mem[at - 20] & 0xF0
;>@h1 if above in (0xE0, 0x50, 0x90): return mem[0x3F60]   # below another hole: no edge
;>@h2 face = 1 if above in (0x00, 0x10, 0xC0) else 2       # floor or a wall above it
;>@h3 sides = (1 if mem[at + 1] & 0xF0 in (0xE0, 0x50, 0x90) else 0) | (2 if mem[at - 1] & 0xF0 in (0xE0, 0x50, 0x90) else 0)
;>@h4 if not wDiagonalView: face = 0
;>@h5 return mem[0x3F54 + sides + 4 * face]
jr_000_27b7:
	pop hl
	ld a, [hl]
	pop hl
	pop de
	pop bc
	ret


;=@shadow
jr_000_27bd:
	ld a, $fb

jr_000_27bf:
	pop hl

jr_000_27c0:
	pop hl
	pop de
	pop bc
	ret


;=@h0
Jump_000_27c4:
	ld de, $ffec
	add hl, de
	ld a, [hl]
	and $f0
;=@h1
	cp $e0
	jr z, jr_000_27d9

	cp $50
	jr z, jr_000_27d9

	cp $90
	jr z, jr_000_27d9

	jr jr_000_27de

jr_000_27d9:
	ld a, [$3f60]
	jr jr_000_27c0

;=@h2
jr_000_27de:
	ld c, $01
	and $f0
	cp $00
	jr z, jr_000_27f0

	cp $10
	jr z, jr_000_27f0

	cp $c0
	jr z, jr_000_27f0

	ld c, $02

;=@h3
jr_000_27f0:
	ld a, [wBoxMiddle]
	ld l, a
	ld a, [wRoomHeight]
	ld h, a
	ld b, $00
	inc hl
	ld a, [hl]
	and $f0
	cp $e0
	jr z, jr_000_280c

	cp $50
	jr z, jr_000_280c

	cp $90
	jr z, jr_000_280c

	jr jr_000_280e

jr_000_280c:
	set 0, b

jr_000_280e:
	dec hl
	dec hl
	ld a, [hl]
	and $f0
	cp $e0
	jr z, jr_000_2821

	cp $50
	jr z, jr_000_2821

	cp $90
	jr z, jr_000_2821

	jr jr_000_2823

jr_000_2821:
	set 1, b

;=@h4
jr_000_2823:
	ld a, [wDiagonalView]
	and a
	jr nz, jr_000_282b

	ld c, $00

;=@h5
jr_000_282b:
	ld hl, $3f54
	ld de, $0000
	ld e, b
	add hl, de
	sla c
	sla c
	ld e, c
	add hl, de
	ld a, [hl]
	jr jr_000_27c0

;@ def CopyRectToBGMap(dest: hl)
;@ path: game/objects
;@ Writes wObjBGTiles (wObjWidth x wObjHeight) into the BG map at `dest`,
;@ a tile per HBlank, with only the VBlank interrupt on while waiting.
;@ reads: wObjHeight, wObjWidth
;@ sig: 80de1ae1
CopyRectToBGMap::
;> for y in range(wObjHeight):
	ld de, wObjBGTiles
	ld a, [wObjHeight]
	ld c, a

jr_000_2843:
	ld a, [wObjWidth]
	ld b, a

jr_000_2847:
;>     for x in range(wObjWidth):
;>         t = wObjBGTiles[wObjWidth * y + x]
	ld a, [de]
	inc de
	push af
;>         rIE = 0x01
;>         WaitHBlank()
	ld a, $01
	ldh [rIE], a
	call WaitHBlank
;>         mem[dest + 32 * y + x] = t
	pop af
	ld [hli], a
;>         rIE = 0x09
	ld a, $09
	ldh [rIE], a
	dec b
	jr nz, jr_000_2847

	push de
	ld a, [wObjWidth]
	ld e, a
	ld a, $20
	sub e
	ld e, a
	ld d, $00
	add hl, de
	pop de
	dec c
	jr nz, jr_000_2843

	ret


;@ def BufferAddrToBGMap(at: hl) -> hl
;@ path: game/room
;@ The BG map address ($9800 on, 32 tiles a row) of a square of wTileBuffer
;@ (20 a row).
;@ test: at = 0xC100 + rand(0, 359)
;@ sig: bfcdaec8
BufferAddrToBGMap::
;> row, col = DivideHLByA(at - wTileBuffer, 20)
	ld de, wTileBuffer
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, $14
	call DivideHLByA
;> return 0x9800 + 32 * row + col
	ld b, $05

jr_000_287b:
	rl l
	rl h
	dec b
	jr nz, jr_000_287b

	ld de, $0000
	ld e, a
	add hl, de
	ld de, $9800
	add hl, de
	ret


;@ def RedrawMovedObject() -> a
;@ path: game/objects
;@ Draws the block or turnstile into the BG map at its new place, once its
;@ sprites have arrived there.
;@ test: wObjWidth = rand(1, 4); wObjHeight = rand(1, 4); wObjPtr = 0xC100 + rand(21, 240)
;@ sig: 2e631439
RedrawMovedObject::
;> return DrawObjectRect()
	call DrawObjectRect
	ret


;@ def ObjectToSprites()
;@ path: game/objects
;@ Puts the block or turnstile of this step on screen as sprites (OAM slots 4
;@ on), each square's BG tile at its place, so it can slide or turn smoothly
;@ over the bare BG. In the diagonal view one row more: the shadow below it
;@ (for a block all shadow tiles $FB, behind the BG). Then waits a frame.
;@ writes: hBGMapAddrHi, hBGMapAddrLo, hCoordX, hCoordY, wObjHeight, wObjSprite, wObjSpriteX
;@ reads: hCoordX, hCoordY, wDiagonalView, wObjHeight, wObjPtr, wObjSprite, wObjSpriteX, wObjWidth, wStepKind
;@ test: wStepKind = rand(0, 2); wObjWidth = rand(1, 4); wObjHeight = rand(1, 3); wObjPtr = 0xC100 + rand(21, 240)
;@ sig: 2deace59
ObjectToSprites::
;> if not wStepKind: return
	ld a, [wStepKind]
	and a
	ret z

;> if wDiagonalView: wObjHeight += 1            # one row more for the shadow
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_28a2

	ld a, [wObjHeight]
	inc a
	ld [wObjHeight], a

jr_000_28a2:
;> ptr = wObjPtr
;> hBGMapAddrLo = lo(ptr)
;> hBGMapAddrHi = hi(ptr)
;> BufferAddrToCoords()
	ld a, [wObjPtr]
	ld l, a
	ldh [hBGMapAddrLo], a
	ld a, [wObjPtr + 1]
	ld h, a
	ldh [hBGMapAddrHi], a
	call BufferAddrToCoords
;> wObjSpriteX = hCoordX
	ldh a, [hCoordX]
	ld [wObjSpriteX], a
;> wObjSprite = 4
	ld a, $04
	ld [wObjSprite], a
;> for y in range(wObjHeight):
;>     for x in range(wObjWidth):
;>         sq = ptr + 20 * y + x
	ld a, [wObjHeight]
	ld c, a

jr_000_28bf:
	ld a, [wObjWidth]
	ld b, a

jr_000_28c3:
;>         if y == wObjHeight - 1 and wDiagonalView:   # the shadow row
;>@sh1             if wStepKind == 1:
;>@sh2                 tile = 0xFB
;>@sh3             else:
;>@sh4                 tile = BufferTileToBG(0, sq)
;>@nrm         else:
;>@n1             attr = 0
;>@n2             tile = BufferTileToBG(mem[sq], sq)
	ld a, c
	cp $01
	jr z, jr_000_2915

;=@nrm
jr_000_28c8:
;=@n1
	xor a
	ld e, a
;=@n2
	ld a, [hl]
	call BufferTileToBG

jr_000_28ce:
;>         if tile == 0xFB: attr = 0x80             # a shadow: behind the BG
	ld d, a
	push bc
	push af
	ldh a, [hCoordX]
	ld b, a
	ldh a, [hCoordY]
	ld c, a
	pop af
	cp $fb
	jr nz, jr_000_28df

	ld a, $80
	ld e, a

jr_000_28df:
;>         SetSprite(wObjSprite, hCoordY, hCoordX, tile, attr)
	ld a, [wObjSprite]
	call SetSprite
;>         wObjSprite += 1
	inc a
	ld [wObjSprite], a
;>         hCoordX += 8
	ldh a, [hCoordX]
	add $08
	ldh [hCoordX], a
	pop bc
	inc hl
	dec b
	jr nz, jr_000_28c3

;>     hCoordX = wObjSpriteX
	ld a, [wObjSpriteX]
	ldh [hCoordX], a
;>     hCoordY += 8
	ldh a, [hCoordY]
	add $08
	ldh [hCoordY], a
	call ObjNextRow
	dec c
	jr nz, jr_000_28bf

;> WaitVBlank()
	call WaitVBlank
;> if wDiagonalView: wObjHeight -= 1
	ld a, [wDiagonalView]
	and a
	ret z

	ld a, [wObjHeight]
	dec a
	ld [wObjHeight], a
	ret


;=@sh1
jr_000_2915:
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_28c8

;=@sh1
	ld a, [wStepKind]
	cp $01
	jr z, jr_000_2928

;=@sh4
	xor a
	call BufferTileToBG
	jr jr_000_28ce

;=@sh2
jr_000_2928:
	ld a, $fb
	jr jr_000_28ce

;@ def StepObjectSprites()
;@ path: game/objects
;@ Moves the sprites of the moving rectangle (OAM slots 4 on, up to 30, up to
;@ the first one with y = 0) by wMoveDX, wMoveDY: one frame of the slide.
;@ reads: wMoveDX, wMoveDY
;@ sig: d5b96fec
StepObjectSprites::
;> for i in range(30):
	ld de, $c010
	ld a, [wMoveDX]
	ld b, a
	ld a, [wMoveDY]
	ld c, a
	ld l, $1f

jr_000_2939:
;>     y = wShadowOAM[16 + 4 * i]
;>     if y == 0: return
	ld a, [de]
	and a
	ret z

	dec l
	ret z

;>     wShadowOAM[16 + 4 * i] = u8(y + wMoveDY)
	add c
	ld [de], a
	inc de
;>     wShadowOAM[17 + 4 * i] = u8(wShadowOAM[17 + 4 * i] + wMoveDX)
	ld a, [de]
	add b
	ld [de], a
	inc de
	inc de
	inc de
	jr jr_000_2939

;@ def TurnstileStep()
;@ path: game/turnstile
;@ Per frame while a turnstile turns: on frame 7 of the step its sprites show
;@ it half way round (LoadTurnstileSprites), on frame 4 in its new place
;@ (ObjectToSprites).
;@ reads: wDiagonalView, wMenuLastCol, wObjPtr, wStepFrames
;@ test: wStepFrames = rand(1, 8); wObjPtr = 0xC100 + rand(21, 240); wStepKind = 2; wObjWidth = 3; wObjHeight = 3
;@ sig: 777a9883
TurnstileStep::
;> if wStepFrames != 7:
	ld a, [wStepFrames]
	cp $07
	jr z, jr_000_2957

;>     if wStepFrames == 4: ObjectToSprites()
;>     return
	cp $04
	ret nz

	call ObjectToSprites
	ret


jr_000_2957:
;> centre = wObjPtr + 21
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	ld de, $0015
	add hl, de
;> if not wMenuLastCol:
	ld a, [wMenuLastCol]
	and a
	jr nz, jr_000_296c

;>     shape = mem[centre]
	ld a, [hl]
	jr jr_000_2979

jr_000_296c:
;> else:
;>     shape = mem[0x3F70 + (mem[centre] & 0x0F)]
	ld a, [hl]
	ld de, $3f70
	and $0f
	add e
	ld e, a
	ld a, $00
	adc d
	ld d, a
	ld a, [de]

jr_000_2979:
;> LoadTurnstileSprites(shape)
	call LoadTurnstileSprites
;> n = 12 if wDiagonalView else 9
	ld b, $09
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_2986

	ld b, $0c

jr_000_2986:
;> for i in range(n):
	ld hl, $c012
	ld de, wObjBGTiles

jr_000_298c:
;>     wShadowOAM[18 + 4 * i] = wObjBGTiles[2 * i]
;>     wShadowOAM[19 + 4 * i] = wObjBGTiles[2 * i + 1]
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	inc de
	ld [hli], a
	inc hl
	inc hl
	dec b
	jr nz, jr_000_298c

;> WaitVBlank()
	call WaitVBlank
	ret


;@ def ClearObjectSprites()
;@ path: game/objects
;@ Hides the 30 sprites of the moving rectangle (OAM slots 4-33).
;@ sig: af893499
ClearObjectSprites::
;> for i in range(30):
	ld de, $c010
	ld b, $1e
	xor a

jr_000_29a1:
;>     wShadowOAM[16 + 4 * i] = 0
	ld [de], a
	inc de
	inc de
	inc de
	inc de
	dec b
	jr nz, jr_000_29a1

	ret


;@ def FillHoles()
;@ path: game/objects
;@ After a block has been pushed: if every square of it is over a hole ($50),
;@ it drops in. The squares become floor, a sound plays, and the block's
;@ sprites sink in one stage (two in the diagonal view) of 8 frames each.
;@ Then the floor and the edges around it are redrawn.
;@ writes: wObjHeight, wObjPtr, wObjWidth, wSinkFrame
;@ reads: wDiagonalView, wObjHeight, wObjPtr, wObjWidth, wStepKind
;@ test: wStepKind = rand(0, 1); wObjWidth = rand(1, 4); wObjHeight = rand(1, 3); wObjPtr = 0xC100 + rand(21, 240)
;@ test: sunk = rand(0, 1) and [mem.__setitem__(wObjPtr + 20 * y + x, 0x50 + rand(0, 15)) for y in range(wObjHeight) for x in range(wObjWidth)]
;@ sig: d79145d1
FillHoles::
;> if wStepKind != 1: return                     # only after pushing a block
	ld a, [wStepKind]
	cp $01
	ret nz

;> ptr = wObjPtr
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
;> for y in range(wObjHeight):
;>     for x in range(wObjWidth):
	ld a, [wObjHeight]
	ld c, a

jr_000_29bc:
	ld a, [wObjWidth]
	ld b, a

jr_000_29c0:
;>         if mem[ptr + 20 * y + x] & 0xF0 != 0x50: return   # not all of it over holes
	ld a, [hli]
	and $f0
	cp $50
	ret nz

	dec b
	jr nz, jr_000_29c0

	call ObjNextRow
	dec c
	jr nz, jr_000_29bc

;> QueueSound(0x0B)
	ld b, $0b
	rst $30
;> for y in range(wObjHeight):
;>     for x in range(wObjWidth):
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	ld a, [wObjHeight]
	ld c, a

jr_000_29de:
	ld a, [wObjWidth]
	ld b, a
	xor a

;>         mem[ptr + 20 * y + x] = 0             # the hole is filled: floor
jr_000_29e3:
	ld [hli], a
	dec b
	jr nz, jr_000_29e3

	call ObjNextRow
	dec c
	jr nz, jr_000_29de

;> DrawObjectRect()
	call DrawObjectRect
;> wObjHeight += 1
	ld hl, wObjHeight
	inc [hl]
;> wSinkFrame = wDiagonalView + 1
	ld a, [wDiagonalView]
	inc a
	ld e, a
	ld [wSinkFrame], a

;> while True:
jr_000_29fc:
;>     for _ in range(8): WaitVBlank()
	push de
	ld d, $08

jr_000_29ff:
	call WaitVBlank
	dec d
	jr nz, jr_000_29ff

;>     for y in range(wObjHeight):
;>         for x in range(wObjWidth):
	ld a, [wObjHeight]
	ld c, a
	ld de, $c012
	ld hl, wObjTiles

jr_000_2a0f:
	ld a, [wObjWidth]
	ld b, a

jr_000_2a13:
;>             i = wObjWidth * y + x
;>             tile, attr = SinkSpriteTile(wObjTiles[i], wObjWidth - x, wObjHeight - y)
;>             wShadowOAM[18 + 4 * i] = tile
;>             wShadowOAM[19 + 4 * i] = attr
	push bc
	ld a, [hli]
	call SinkSpriteTile
	ld [de], a
	inc de
	ld a, b
	ld [de], a
	inc de
	inc de
	inc de
	pop bc
	dec b
	jr nz, jr_000_2a13

	dec c
	jr nz, jr_000_2a0f

;>     wSinkFrame -= 1
;>     if wSinkFrame == 0: break
	pop de
	dec e
	ld a, e
	ld [wSinkFrame], a
	and a
	jr nz, jr_000_29fc

;> for _ in range(10): WaitVBlank()
	ld d, $0a

jr_000_2a31:
	call WaitVBlank
	dec d
	jr nz, jr_000_2a31

;> if wDiagonalView: wObjHeight -= 1
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_2a41

	ld hl, wObjHeight
	dec [hl]

jr_000_2a41:
;> wObjHeight += 1
	ld a, [wObjHeight]
	inc a
	ld [wObjHeight], a
;> wObjPtr -= 1
	ld a, [wObjPtr]
	ld l, a
	ld a, [wObjPtr + 1]
	ld h, a
	dec hl
	ld a, l
	ld [wObjPtr], a
	ld a, h
	ld [wObjPtr + 1], a
;> wObjWidth += 2
	ld a, [wObjWidth]
	inc a
	inc a
	ld [wObjWidth], a
;> DrawObjectRect()                              # the new floor and the edges around it
	call DrawObjectRect
	ret


;@ def SinkSpriteTile(tile: a, col: b, row: c) -> (a, b)
;@ path: game/objects
;@ The sprite (tile, attributes) of one square of a block sinking into its
;@ holes, for stage wSinkFrame: by the block's tile ($2AD5 bird's-eye, $2AF5
;@ diagonal), or for the shadow row below it (row 1 of the diagonal view) by
;@ the column: alone, the right end (col 1), the left end, or between
;@ ($2B35).
;@ writes: wSinkTile
;@ reads: wDiagonalView, wObjWidth, wSinkFrame, wSinkTile
;@ test: wSinkFrame = rand(1, 2); col = rand(1, 4); row = rand(1, 4); wObjWidth = rand(1, 4)
;@ sig: 4fd38da0
SinkSpriteTile::
;> wSinkTile = tile
	push hl
	push de
	ld [wSinkTile], a
;> table = 0x2AD5
	ld hl, $2ad5
;> if wDiagonalView:
	ld a, [wDiagonalView]
	and a
	jr z, jr_000_2a7b

;>     if row == 1:                              # the shadow row
;>@s1         pos = 0 if wObjWidth == 1 else 2 if col == 1 else 4 if col == wObjWidth else 6
;>@s2         at = 0x2B35 + pos + u8(8 * (wSinkFrame - 1))
;>@s3         return mem[at], mem[at + 1]
	ld a, c
	cp $01
	jr z, jr_000_2a9e

;>     table = 0x2AF5
	ld hl, $2af5

jr_000_2a7b:
;> at = AddAToHL(table, u8(32 * (wSinkFrame - 1))) + 2 * (wSinkTile & 0x0F)
	ld a, [wSinkFrame]
	dec a
	sla a
	sla a
	sla a
	sla a
	sla a
	call AddAToHL
	ld a, [wSinkTile]
	and $0f
	sla a
	ld e, a
	ld d, $00

jr_000_2a96:
;> return mem[at], mem[at + 1]
	add hl, de
	inc hl
	ld a, [hld]
	ld b, a
	ld a, [hl]
	pop de
	pop hl
	ret


;=@s1
jr_000_2a9e:
	ld a, [wObjWidth]
	cp $01
	jr nz, jr_000_2aaa

	ld de, $0000
	jr jr_000_2ac2

jr_000_2aaa:
	ld a, b
	cp $01
	jr nz, jr_000_2ab4

	ld de, $0002
	jr jr_000_2ac2

jr_000_2ab4:
	ld a, [wObjWidth]
	cp b
	jr nz, jr_000_2abf

	ld de, $0004
	jr jr_000_2ac2

jr_000_2abf:
	ld de, $0006

;=@s2
jr_000_2ac2:
	ld hl, $2b35
	add hl, de
	ld a, [wSinkFrame]
	dec a
	sla a
	sla a
	sla a
	ld e, a
	ld d, $00
;=@s3
	jr jr_000_2a96

	db $f4, $00, $eb, $20, $ea, $00, $ee, $40, $eb, $00, $ed, $00, $ee, $60, $ef, $40
	db $ea, $40, $ee, $00, $f0, $00, $ec, $20, $ee, $20, $ef, $00, $ec, $00, $ff, $00
	db $f3, $00, $f1, $00, $f3, $00, $f1, $00, $f1, $20, $f2, $00, $f1, $20, $f2, $00
	db $f0, $00, $ec, $20, $f0, $00, $ec, $20, $ec, $00, $ff, $00, $ec, $00, $ff, $00
	db $8e, $00, $8a, $00, $8e, $00, $8a, $00, $8a, $20, $8b, $00, $8a, $20, $8b, $00
	db $c9, $00, $cb, $00, $c9, $00, $cb, $00, $cc, $00, $bf, $00, $cc, $00, $bf, $00
	db $f3, $c0, $f1, $e0, $f1, $c0, $f2, $c0, $8f, $80, $8c, $a0, $8c, $80, $8d, $80

;@ def ReadJoypad()
;@ path: system/input
;@ Reads all eight buttons into hJoyHeld and works out which of them were
;@ pressed since the last call (hJoyPressed). The same routine as Tetris's,
;@ with more reads of the d-pad.
;@ writes: hJoyHeld, hJoyPressed
;@ reads: hJoyHeld
;@ test: skip reads the joypad
;@ sig: ec540327
ReadJoypad::
;> rP1 = 0x20                                  # select the d-pad
	ld a, $20
	ldh [rP1], a
;> pins = rP1                                  # read 6 times to let the lines settle
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;> dpad = (~pins & 0x0F) << 4
	cpl
	and $0f
	swap a
	ld b, a
;> rP1 = 0x10                                  # select A/B/Select/Start
	ld a, $10
	ldh [rP1], a
;> pins = rP1                                  # read 10 times
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
	ldh a, [rP1]
;> buttons = ~pins & 0x0F
	cpl
	and $0f
;> held = dpad | buttons
	or b
	ld c, a
;> hJoyPressed = held & ~hJoyHeld              # down now, but not last time
	ldh a, [hJoyHeld]
	xor c
	and c
	ldh [hJoyPressed], a
;> hJoyHeld = held
	ld a, c
	ldh [hJoyHeld], a
;> rP1 = 0x30                                  # deselect both groups
	ld a, $30
	ldh [rP1], a
;> return
	ret


;@ def CopyOAMDMARoutine()
;@ path: system/lcd
;@ Copies the 10-byte OAM DMA routine (OAMDMARoutine) to HRAM at hOAMDMA,
;@ where it has to run while the DMA blocks the rest of memory.
;@ sig: d2eb0543
CopyOAMDMARoutine::
;> copy(addr(hOAMDMA), OAMDMARoutine, 10)
	ld c, $80
	ld b, $0a
	ld hl, OAMDMARoutine

jr_000_2b8d:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, jr_000_2b8d

;> return
	ret


;@ path: system/lcd
;@ The OAM DMA routine as bytes: `ld a, HIGH(wShadowOAM)`, `ldh [rDMA], a`, then
;@ a 160 microsecond wait loop and `ret`. CopyOAMDMARoutine puts it into
;@ hOAMDMA, since only HRAM can be read while the DMA runs.
OAMDMARoutine::
	db $3e, $c0, $e0, $46, $3e, $28, $3d, $20, $fd, $c9

;@ path: lib/unused
;@ Unused library code, the same routine as Tetris's CoordsToBGMapAddr: the BG
;@ map address of the tile under the OAM coordinates hCoordY, hCoordX, into
;@ hBGMapAddrHi/Lo. Kwirk never calls it, so it is kept as bytes.
CoordsToBGMapAddr::
	db $f0, $8d, $d6, $10, $cb, $3f
	db $cb, $3f, $cb, $3f, $11, $00, $00, $5f, $21, $00, $98, $06, $20, $19, $05, $20
	db $fc, $f0, $8e, $d6, $08, $cb, $3f, $cb, $3f, $cb, $3f, $11, $00, $00, $5f, $19
	db $7c, $e0, $8f, $7d, $e0, $90, $c9

;@ def BufferAddrToCoords()
;@ path: gfx/tilemaps
;@ Converts an address in wTileBuffer (hBGMapAddrHi/Lo) into the OAM-space
;@ coordinates of that tile: hCoordX, hCoordY.
;@ writes: hCoordX, hCoordY
;@ reads: hBGMapAddrHi, hBGMapAddrLo
;@ test: hBGMapAddrHi = rand(0xC1, 0xC2)
;@ test: hBGMapAddrLo = rand(0, 255)
;@ sig: ec2ae622
BufferAddrToCoords::
;> offset = ((u8(hBGMapAddrHi - 0xC0) or 256) - 1) * 256 + hBGMapAddrLo   # from wTileBuffer
	ldh a, [hBGMapAddrLo]
	ld e, a
	ldh a, [hBGMapAddrHi]
	sub $c0
	ld d, a
	ld bc, $0000
	ld a, e

;> row = offset // 20                         # 20 tiles a row
;> col = offset % 20
jr_000_2bd7:
	cp $14
	jr c, jr_000_2be2

jr_000_2bdb:
	inc bc
	sub $14
	scf
	ccf
	jr jr_000_2bd7

jr_000_2be2:
	dec d
	jr nz, jr_000_2bdb

;> hCoordX = u8(col * 8 + 8)
	sla a
	sla a
	sla a
	add $08
	ldh [hCoordX], a
;> hCoordY = u8(row * 8 + 16)
	ld a, c
	sla a
	sla a
	sla a
	add $10
	ldh [hCoordY], a
;> return
	ret


;@ def JumpTable(index: a)
;@ path: system/vectors
;@ Jump-table dispatch behind `rst $00`: the `rst` is followed by a table of
;@ 16-bit addresses, and execution goes on at entry `index` of it instead of
;@ returning. The same as Tetris's; Kwirk never uses it.
;@ clobbers: a, de, hl
;@ test: skip rewrites the return address on the stack
;@ sig: a7c000c3
JumpTable::
;> offset = 2 * index
	add a
;> table = pop_return_address()       # the table starts right after `rst $00`
	pop hl
;> target = mem16[table + offset]
	ld e, a
	ld d, $00
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
;> goto(target)
	push de
	pop hl
	jp hl


;@ def DisableLCD()
;@ path: system/lcd
;@ Waits for VBlank and switches the LCD off. The VBlank interrupt is
;@ masked while waiting so the handler can't run in between.
;@ writes: hSavedIE
;@ reads: hSavedIE
;@ test: skip polls the LCD
;@ sig: 02289a40
DisableLCD::
;> hSavedIE = rIE
;> rIE = hSavedIE & ~1                         # no VBlank interrupt for now
	ldh a, [rIE]
	ldh [hSavedIE], a
	res 0, a
	ldh [rIE], a

;> wait_ly(0x91)                               # inside VBlank
jr_000_2c0f:
	ldh a, [rLY]
	cp $91
	jr c, jr_000_2c0f

;> rLCDC &= 0x7F                               # LCD off
	ldh a, [rLCDC]
	and $7f
	ldh [rLCDC], a
;> rIE = hSavedIE
	ldh a, [hSavedIE]
	ldh [rIE], a
;> return
	ret


;@ def EnableLCD()
;@ path: system/lcd
;@ Switches the LCD back on.
;@ sig: 0da9d541
EnableLCD::
;> rLCDC |= 0x80
	ldh a, [rLCDC]
	set 7, a
	ldh [rLCDC], a
;> return
	ret


;@ def FillBytes(dest: hl, count: bc, value: a)
;@ path: lib/memory
;@ Fills `count` bytes from dest with value (0 = 64 KiB). Keeps every register.
;@ test: count = rand(1, 0x100)
;@ test: dest = rand_ram(count)
;@ test: value = rand(0, 255)
;@ sig: 4dfdc421
FillBytes::
;> fill(dest, value, count or 0x10000)
	push af
	push bc
	push de
	push hl
	ld e, a

jr_000_2c2c:
	ld a, e
	ld [hli], a
	dec bc
	ld a, c
	or b
	jr nz, jr_000_2c2c

	pop hl
	pop de
	pop bc
	pop af
;> return
	ret


;@ def FillBGMap0(value: a)
;@ path: gfx/tilemaps
;@ Fills all of BG map 0 with one tile, from the end downwards.
;@ test: value = rand(0, 255)
;@ sig: c2827d93
FillBGMap0::
;> fill(vBGMap0, value, 0x400)
	ld hl, $9bff
	ld bc, $0400
	ld e, a

jr_000_2c3f:
	ld a, e
	ld [hld], a
	dec bc
	ld a, b
	or c
	jr nz, jr_000_2c3f

;> return
	ret


;@ def CopyBytes(src: hl, dest: de, count: bc)
;@ path: lib/memory
;@ Copies `count` bytes from src to dest, front to back (0 = 64 KiB).
;@ test: count = rand(1, 0x100)
;@ test: src = rand(0x0000, 0xDE00)
;@ test: dest = rand_ram(count)
;@ sig: 994589e5
CopyBytes::
;> for i in range(count or 0x10000):
;>     mem[dest + i] = mem[src + i]
	ld a, [hli]
	ld [de], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, CopyBytes

;> return
	ret


;@ path: lib/unused
;@ Unused library code, routines Tetris has too: the tail of a loop that takes
;@ addresses from a list at de and draws each until a 0, and the start of one
;@ that branches on the top two bits of a byte (the low six are a count).
;@ Never run in Kwirk, so kept as bytes.
UnusedLibraryCode::
	db $13, $67, $1a, $6f, $13, $1a, $13, $cd, $60, $2c, $1a, $fe, $00, $20, $f1, $c9
	db $f5, $e6, $3f, $47, $f1, $07, $07, $e6, $03, $28, $08, $3d, $28, $0c, $3d, $28
	db $10, $18, $1b

;@ path: lib/unused
;@ Unused library code, as in Tetris: CopyBytesB (copy b bytes from de to
;@ hl), the same with the other increment order, and two routines that copy
;@ b bytes down a BG map column (32 bytes a step), the second one byte b
;@ times. Never called in Kwirk.
CopyBytesB::
	db $1a, $22, $13, $05, $20, $fa, $c9, $1a, $13, $22, $05, $20, $fc
	db $c9, $1a, $77, $13, $78, $01, $20, $00, $09, $47, $05, $20, $f4, $c9, $1a, $77
	db $78, $01, $20, $00, $09, $47, $05, $20, $f5, $13, $c9

;@ def MenuChoose(origin: hl, steps: de, last_col: b, last_row: c, cursor: a)
;@ path: ui/menu
;@ Lets the player pick from a grid of choices with the d-pad: columns
;@ hi(steps) bytes apart in the BG map, rows lo(steps) apart, the last
;@ column only wMenuLastColRows + 1 rows long. A or START picks
;@ (wMenuChoice = column * rows + row), B gives $FF. In the link state of the
;@ title, a start by the partner gives $F0.
;@ writes: wLinkState, wMenuChoice, wMenuColStep, wMenuCursorTile, wMenuLastCol, wMenuLastRow, wMenuLinkTimer, wMenuRowStep
;@ reads: hJoyPressed, wLinkDone, wLinkMaster, wLinkState, wMenuLastCol, wMenuLastColRows, wMenuLastRow, wMenuLinkTimer
;@ sig: e92b0a80
MenuChoose::
;> wMenuCursorTile = cursor
	ld [wMenuCursorTile], a
;> wMenuLastCol = last_col
	ld a, b
	ld [wMenuLastCol], a
;> wMenuLastRow = last_row
	ld a, c
	ld [wMenuLastRow], a
;> wMenuRowStep = lo(steps)
	ld a, e
	ld [wMenuRowStep], a
;> wMenuColStep = hi(steps)
	ld a, d
	ld [wMenuColStep], a
;> wMenuLinkTimer = 60
	ld a, $3c
	ld [wMenuLinkTimer], a
;> wMenuChoice = 0
	xor a
	ld [wMenuChoice], a
;> col, row = 0, 0
	ld bc, $0000
;> SavePtr1(origin)
	call SavePtr1
;> MenuDrawCursor(col, row)
	call MenuDrawCursor

;> for _ in forever():
Jump_000_2cc0:
jr_000_2cc0:
;>     if wLinkState == 1:
	ld a, [wLinkState]
	cp $01
	jr nz, jr_000_2cee

;>         if wLinkDone:
	ld a, [wLinkDone]
	and a
	jr z, jr_000_2cd3

;>             wMenuChoice = 0xF0              # the partner started
	ld a, $f0
	ld [wMenuChoice], a
;>             return
	ret


jr_000_2cd3:
;>         wMenuLinkTimer = u8(wMenuLinkTimer - 1)
	ld a, [wMenuLinkTimer]
	dec a
	ld [wMenuLinkTimer], a
;>         if wMenuLinkTimer == 0:
	jr nz, jr_000_2ce4

;>             wMenuLinkTimer = 60
	ld a, $3c
	ld [wMenuLinkTimer], a
;>             SerialOfferTitle()
	call SerialOfferTitle

jr_000_2ce4:
;>         ReadJoypad()
	push bc
	call ReadJoypad
	pop bc
;>         WaitVBlank()
	call WaitVBlank
	jr jr_000_2d07

jr_000_2cee:
;>     else:
	push hl
	push de
	push bc
;>         wLinkState = 2
	ld a, $02
	ld [wLinkState], a
;>         if wLinkMaster: LinkWait()
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_2d01

	call LinkWait
	jr jr_000_2d04

jr_000_2d01:
;>         else: LinkSendEE()
	call LinkSendEE

jr_000_2d04:
	pop bc
	pop de
	pop hl

jr_000_2d07:
;>     pressed = hJoyPressed
	ldh a, [hJoyPressed]
;>     if not pressed: continue
	and a
	jr z, jr_000_2cc0

;>     if pressed & BTN_A:
	bit 0, a
	jr z, jr_000_2d19

Jump_000_2d10:
;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         QueueSound(0x10)
	ld b, $10
	rst $30
;>         return
	jp Jump_000_2df0


jr_000_2d19:
;>     if pressed & BTN_B:
	bit 1, a
	jr z, jr_000_2d2b

;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         wMenuChoice = 0xFF
	ld a, $ff
	ld [wMenuChoice], a
;>         QueueSound(0x11)
	ld b, $11
	rst $30
;>         return
	jp Jump_000_2df0


jr_000_2d2b:
;>     if pressed & BTN_START:                 # like A
	bit 3, a
	jr z, jr_000_2d32

;>         MenuEraseCursor(col, row); QueueSound(0x10); return
	jp Jump_000_2d10


jr_000_2d32:
;>     if pressed & BTN_RIGHT and wMenuLastCol:
	bit 4, a
	jr z, jr_000_2d64

	ld a, [wMenuLastCol]
	and a
	jp z, Jump_000_2d64

;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         col = 0 if col == wMenuLastCol else col + 1
	ld a, [wMenuLastCol]
	sub b
	jr nz, jr_000_2d4a

	ld b, $00
	jr jr_000_2d5b

jr_000_2d4a:
	inc b
;>         if col == wMenuLastCol and row > wMenuLastColRows:
	ld a, [wMenuLastCol]
	sub b
	jr nz, jr_000_2d5b

	ld a, [wMenuLastColRows]
	sub c
	jr nc, jr_000_2d5b

;>             row = wMenuLastColRows
	ld a, [wMenuLastColRows]
	ld c, a

jr_000_2d5b:
;>         MenuChoiceIndex(col, row)
	call MenuChoiceIndex
;>         MenuMoveCursor(col, row)
	call MenuMoveCursor
;>         continue
	jp Jump_000_2cc0


Jump_000_2d64:
jr_000_2d64:
;>     if hJoyPressed & BTN_LEFT and wMenuLastCol:
	ldh a, [hJoyPressed]
	bit 5, a
	jr z, jr_000_2d90

	ld a, [wMenuLastCol]
	and a
	jr z, jr_000_2d90

;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         if col == 0:
	ld a, b
	and a
	jr nz, jr_000_2d83

;>             col = wMenuLastCol
	ld a, [wMenuLastCol]
	ld b, a
;>             if row > wMenuLastColRows:      # that column is shorter
;>@lshort                col -= 1
	ld a, [wMenuLastColRows]
	sub c
	jr c, jr_000_2d86

	jr jr_000_2d87

jr_000_2d83:
;>         else: col -= 1
	dec b
	jr jr_000_2d87

jr_000_2d86:
;=@lshort
	dec b

jr_000_2d87:
;>         MenuChoiceIndex(col, row)
	call MenuChoiceIndex
;>         MenuMoveCursor(col, row)
	call MenuMoveCursor
;>         continue
	jp Jump_000_2cc0


jr_000_2d90:
;>     if hJoyPressed & BTN_UP and wMenuLastRow:
	ldh a, [hJoyPressed]
	bit 6, a
	jr z, jr_000_2dbf

	ld a, [wMenuLastRow]
	and a
	jr z, jr_000_2dbf

;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         if row == 0:
	ld a, c
	and a
	jr nz, jr_000_2db5

;>             row = wMenuLastRow if col != wMenuLastCol else wMenuLastColRows
	ld a, [wMenuLastCol]
	sub b
	jr z, jr_000_2daf

	ld a, [wMenuLastRow]
	ld c, a
	jr jr_000_2db6

jr_000_2daf:
	ld a, [wMenuLastColRows]
	ld c, a
	jr jr_000_2db6

jr_000_2db5:
;>         else: row -= 1
	dec c

jr_000_2db6:
;>         MenuChoiceIndex(col, row)
	call MenuChoiceIndex
;>         MenuMoveCursor(col, row)
	call MenuMoveCursor
;>         continue
	jp Jump_000_2cc0


jr_000_2dbf:
;>     if hJoyPressed & BTN_DOWN and wMenuLastRow:
	ldh a, [hJoyPressed]
	bit 7, a
	jp z, Jump_000_2cc0

	ld a, [wMenuLastRow]
	and a
	jp z, Jump_000_2cc0

;>         MenuEraseCursor(col, row)
	call MenuEraseCursor
;>         bottom = row == wMenuLastRow or (col == wMenuLastCol and row == wMenuLastColRows)
	ld a, [wMenuLastRow]
	sub c
	jr z, jr_000_2de5

	ld a, [wMenuLastCol]
	sub b
	jr nz, jr_000_2de2

	ld a, [wMenuLastColRows]
	sub c
	jr z, jr_000_2de5

jr_000_2de2:
;>         row = 0 if bottom else row + 1
	inc c
	jr jr_000_2de7

jr_000_2de5:
	ld c, $00

jr_000_2de7:
;>         MenuChoiceIndex(col, row)
	call MenuChoiceIndex
;>         MenuMoveCursor(col, row)
	call MenuMoveCursor
	jp Jump_000_2cc0


;> return
Jump_000_2df0:
	ret


;@ def MenuChoiceIndex(col: b, row: c)
;@ path: ui/menu
;@ wMenuChoice = col * (wMenuLastRow + 1) + row.
;@ writes: wMenuChoice
;@ reads: wMenuLastRow
;@ sig: c92fab41
MenuChoiceIndex::
;> wMenuChoice = u8(col * u8(wMenuLastRow + 1) + row)
	ld a, b
	push hl
	push af
	ld a, [wMenuLastRow]
	ld l, a
	pop af
	inc l
	ld h, $00
	call MultiplyHLByA
	ld a, c
	add l
	ld [wMenuChoice], a
;> return
	pop hl
	ret


;@ def MenuMoveCursor(col: b, row: c)
;@ path: ui/menu
;@ The cursor sound, then the cursor at its new place.
;@ sig: 34a73370
MenuMoveCursor::
;> QueueSound(0x0D)
	push bc
	push hl
	push de
	ld b, $0d
	rst $30
	pop de
	pop hl
	pop bc
;> return MenuDrawCursor(col, row)             # falls through

;@ def MenuDrawCursor(col: b, row: c)
;@ path: ui/menu
;@ Puts the cursor tile at column col, row row of the menu.
;@ reads: wMenuCursorTile
;@ sig: 66e9a404
MenuDrawCursor::
;> dest = MenuCursorAddr(col, row)
	call MenuCursorAddr
;> WaitHBlank()
	call WaitHBlank
;> mem[dest] = wMenuCursorTile
	ld a, [wMenuCursorTile]
	ld [hl], a
;> WaitVBlank()
	call WaitVBlank
;> return
	ret


;@ def MenuEraseCursor(col: b, row: c)
;@ path: ui/menu
;@ Blanks the cursor at column col, row row of the menu.
;@ sig: cea6c905
MenuEraseCursor::
;> dest = MenuCursorAddr(col, row)
	call MenuCursorAddr
;> WaitHBlank()
	call WaitHBlank
;> mem[dest] = 0xFF
	ld a, $ff
	ld [hl], a
;> WaitVBlank()
	call WaitVBlank
;> return
	ret


;@ def MenuCursorAddr(col: b, row: c) -> hl
;@ path: ui/menu
;@ The BG map address of a menu cell: the origin (pointer 1) plus row and
;@ column steps. Uses pointer 2. Keeps bc.
;@ reads: wMenuColStep, wMenuRowStep
;@ sig: f3d229b5
MenuCursorAddr::
;> down = MultiplyHLByA(row, wMenuRowStep)
	push bc
	ld a, [wMenuRowStep]
	ld h, $00
	ld l, c
	call MultiplyHLByA
;> SavePtr2(down)
	call SavePtr2
;> across = MultiplyHLByA(col, wMenuColStep)
	ld a, [wMenuColStep]
	ld h, $00
	ld l, b
	call MultiplyHLByA
	ld b, h
	ld c, l
;> return u16(LoadPtr2() + across + LoadPtr1())
	call LoadPtr2
	add hl, bc
	ld b, h
	ld c, l
	call LoadPtr1
	add hl, bc
	pop bc
	ret


;@ def LoadTurnstileSprites(shape: a)
;@ path: game/objects
;@ Fetches the sprites of a turnstile being turned: one of 16 shapes (an arm up,
;@ right, down, left: one bit each), 12 (tile, attribute) pairs for the diagonal
;@ view or the 9 of the bird's-eye view behind them, into wObjBGTiles.
;@ reads: wDiagonalView
;@ sig: 106933a8
LoadTurnstileSprites::
;> src = mem16[0x2E74 + 2 * (shape & 0x0F)]       # the table right after this routine
	and $0f
	ld hl, $2e74
	sla a
	call AddAToHL
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld h, a
	ld l, e
;> if not wDiagonalView: src += 0x18                # the bird's-eye half of the record
	ld a, [wDiagonalView]
	and a
	jr nz, jr_000_2e68

	ld a, $18
	call AddAToHL

jr_000_2e68:
;> copy(addr(wObjBGTiles), src, 0x18)
	ld bc, wObjBGTiles
	ld d, $18

jr_000_2e6d:
	ld a, [hli]
	ld [bc], a
	inc bc
	dec d
	jr nz, jr_000_2e6d

;> return
	ret


	db $92, $2e, $c2, $2e, $f2, $2e, $22, $2f, $52, $2f, $82, $2f, $b2, $2f, $e2, $2f
	db $12, $30, $42, $30, $72, $30, $a2, $30, $d2, $30, $02, $31, $32, $31, $ff, $00
	db $94, $20, $99, $20, $ff, $00, $a6, $20, $a0, $00, $ff, $00, $a3, $80, $a1, $80
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $94, $20, $91, $20, $ff, $00, $97, $00
	db $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $a5, $20, $94, $00, $ff, $00, $a0, $20, $9b, $20
	db $ff, $00, $a1, $a0, $9d, $a0, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $97, $40
	db $94, $00, $ff, $00, $94, $60, $91, $60, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $94, $20, $a5, $00, $ff, $00, $9b, $00, $a0, $00, $ff, $00
	db $9d, $80, $a1, $80, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $94, $20, $97, $60
	db $ff, $00, $91, $40, $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $94, $00, $ff, $00, $a0, $20, $a6, $00, $ff, $00, $a1, $a0, $a3, $80, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $91, $00, $94, $00, $ff, $00, $94, $60, $97, $20
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $94, $20, $99, $20, $ff, $00, $9f, $20, $9a, $00, $ff, $00, $a0, $20, $9b, $20
	db $ff, $00, $a1, $a0, $9d, $a0, $ff, $00, $94, $20, $91, $20, $ff, $00, $95, $20
	db $a8, $20, $ff, $00, $94, $60, $91, $60, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $94, $20, $a9, $00, $94, $00, $9b, $00, $9c, $00, $9b, $20
	db $9d, $80, $9e, $80, $9d, $a0, $ff, $00, $ff, $00, $ff, $00, $94, $20, $a9, $00
	db $94, $00, $91, $40, $92, $40, $91, $60, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $94, $00, $ff, $00, $9a, $20, $9f, $00, $ff, $00, $9b, $00, $a0, $00, $ff, $00
	db $9d, $80, $a1, $80, $ff, $00, $91, $00, $94, $00, $ff, $00, $a8, $00, $95, $00
	db $ff, $00, $91, $40, $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $92, $00, $99, $20, $a0, $20, $a2, $00, $a0, $00, $a1, $a0, $a3, $80, $a1, $80
	db $ff, $00, $ff, $00, $ff, $00, $91, $00, $92, $00, $91, $20, $94, $60, $a9, $40
	db $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $94, $20, $99, $20, $94, $20, $96, $00, $9a, $00, $9b, $00, $9c, $00, $9b, $20
	db $9d, $80, $9e, $80, $9d, $a0, $ff, $00, $94, $20, $91, $20, $94, $20, $96, $00
	db $a8, $20, $91, $40, $92, $40, $91, $60, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $94, $00, $ff, $00, $9a, $20, $96, $20, $94, $00, $9b, $00, $9c, $00, $9b, $20
	db $9d, $80, $9e, $80, $9d, $a0, $91, $00, $94, $00, $ff, $00, $a8, $00, $96, $20
	db $94, $00, $91, $40, $92, $40, $91, $60, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $92, $00, $99, $20, $9a, $20, $a4, $00, $a0, $00, $9b, $00, $a0, $00, $a1, $80
	db $9d, $80, $a1, $80, $ff, $00, $91, $00, $92, $00, $91, $20, $a8, $00, $96, $60
	db $94, $40, $91, $40, $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $92, $00, $99, $20, $a0, $20, $a4, $20, $9a, $00, $a1, $a0, $a0, $20, $9b, $20
	db $ff, $00, $a1, $a0, $9d, $a0, $91, $00, $92, $00, $91, $20, $94, $60, $96, $40
	db $a8, $20, $ff, $00, $94, $60, $91, $60, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $92, $00, $99, $20, $9a, $20, $93, $00, $9a, $00, $9b, $00, $9c, $00, $9b, $20
	db $9d, $80, $9e, $80, $9d, $a0, $91, $00, $92, $00, $91, $20, $a8, $00, $93, $00
	db $a8, $20, $91, $40, $92, $40, $91, $60, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $94, $20, $99, $20, $94, $20, $a7, $00, $a0, $00, $9b, $00, $a0, $00, $a1, $80
	db $9d, $80, $a1, $80, $ff, $00, $ff, $00, $94, $20, $91, $20, $94, $20, $98, $00
	db $94, $40, $91, $40, $94, $40, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $99, $00
	db $94, $00, $ff, $00, $a0, $20, $a7, $20, $94, $00, $a1, $a0, $a0, $20, $9b, $20
	db $ff, $00, $a1, $a0, $9d, $a0, $91, $00, $94, $00, $ff, $00, $94, $60, $98, $20
	db $94, $00, $ff, $00, $94, $60, $91, $60, $ff, $00, $ff, $00, $ff, $00

;@ def UpdateBonus()
;@ path: game/score
;@ HEADING OUT?: the room's bonus from the play clock, shown in the BONUS box and
;@ kept in wRoomPoints: 2000 for the first 5 seconds, then 1800, 1600 ... 100, and
;@ nothing after 79 seconds. The times and the values are BonusTimes and
;@ BonusPoints; a digit $F prints as a blank.
;@ writes: wRoomPoints
;@ reads: wClockSecondsTotal
;@ test: wClockSecondsTotal = rand(0, 100)
;@ sig: 42ccaa07
UpdateBonus::
;> if wClockSecondsTotal < 80:
	ld d, $00
	ld a, [wClockSecondsTotal]
	cp $50
	jr nc, jr_000_3184

;>     d = 0
;>     while mem[BonusTimes + d] < wClockSecondsTotal: d += 1     # 5, 7, 9, 12, 15 ... 79 seconds
	ld b, a
	ld hl, BonusTimes

jr_000_316f:
	ld a, [hli]
	ld c, a
	sub b
	jr nc, jr_000_3177

	inc d
	jr jr_000_316f

jr_000_3177:
;>     c, b = mem[BonusPoints + d], 0x00                          # $20, $18 ... $10, $F9 ... $F1
	ld a, d
	ld hl, BonusPoints
	call AddAToHL
	ld a, [hl]
	ld c, a
	ld b, $00
	jr jr_000_3188

jr_000_3184:
;> else:
;>     c, b = 0xFF, 0xF0                                     # "   0"
	ld c, $ff
	ld b, $f0

jr_000_3188:
;> points = c
	push bc
	ld a, c
	ld l, a
	ld h, $02

jr_000_318d:
;> if c >> 4 == 0x0F: points = BonusBlankNibble(2, points)
;> if c & 0x0F == 0x0F: points = BonusBlankNibble(1, points)
	ld b, $00
	ld d, $04

jr_000_3191:
	sla a
	rl b
	dec d
	jr nz, jr_000_3191

	ld e, a
	ld a, b
	cp $0f
	call z, BonusBlankNibble
	dec h
	jr z, jr_000_31a5

	ld a, e
	jr jr_000_318d

jr_000_31a5:
;> wRoomPoints = points
	ld c, l
	ld a, c
	ld [wRoomPoints], a
;> PrintBCD(b, PrintBCD(c, 0x984D))                          # the four digits in the BONUS box
	pop bc
	ld a, c
	ld hl, $984d
	call PrintBCD
	ld a, b
	call PrintBCD
;> return
	ret


;@ def BonusBlankNibble(which: h, digits: l) -> l
;@ path: game/score
;@ UpdateBonus: a blank digit ($F) counts as 0 (which = 2: the high digit, 1: the low one).
;@ sig: 152f2a2a
BonusBlankNibble::
;> return digits & (0x0F if which == 2 else 0xF0)
	push af
	ld a, h
	cp $02
	jr nz, jr_000_31c3

	ld a, l
	and $0f
	ld l, a
	jr jr_000_31c7

jr_000_31c3:
	ld a, l
	and $f0
	ld l, a

jr_000_31c7:
	pop af
	ret


;@ The play clock's seconds up to which each bonus holds (UpdateBonus; 15 steps, 5 to 79 s).
BonusTimes::
	db $05, $07, $09, $0c, $0f, $13, $17, $1c, $21, $27, $2d, $34, $3c, $45, $4f


;@ The bonus for each step (UpdateBonus), in hundreds, BCD; a high digit $F prints as a blank (2000, 1800 ... 1000, 900 ... 100).
BonusPoints::
	db $20, $18, $16, $14, $12, $10, $f9, $f8, $f7, $f6, $f5, $f4, $f3, $f2, $f1

;@ def BuildCourse()
;@ path: game/course
;@ HEADING OUT? and VS MODE: deals the 99 rooms of a course from the skill's rooms
;@ (wCourseSeed seeds Random, so both Game Boys of a VS game deal the same course).
;@ A room among the 20 before it is dealt again. Then the course's last rooms are
;@ remembered in wRecentRooms, so the next course starts with others.
;@ writes: wRandom
;@ reads: wCourseLength, wCourseSeed, wGameMode, wVsPartnerLength
;@ test: wSkill = rand(0, 2)
;@ test: wCourseLength = rand(1, 99)
;@ test: wVsPartnerLength = rand(1, 99)
;@ test: wGameMode = rand(1, 2)
;@ sig: cd1f557f
BuildCourse::
;> fill(addr(wRandom), wCourseSeed, 4)
	ld de, wCourseRooms
	ld a, [wCourseSeed]
	ld [wRandom], a
	ld [wRandom + 1], a
	ld [wRandom + 2], a
	ld [wRandom + 3], a
;> for i in range(99):
	ld c, $63

jr_000_31fb:
;>     room = 0xAB
;>     while room == 0xAB:
;>         count = mem[0x3EDA + 2 * wSkill]                  # Call_3EC9: the skill's number of rooms
;>         room = AvoidRecentRoom(addr(wCourseRooms) + i, u8(DivideHLByA(Random(), count)[1] + 30))
	call Random
	ld l, a
	ld h, $00
	call SkillRooms
	ld a, b
	call DivideHLByA
	add $1e
	call AvoidRecentRoom
	cp $ab
	jr z, jr_000_31fb

;>     wCourseRooms[i] = room
	ld [de], a
	inc de
	dec c
	jr nz, jr_000_31fb

;> n = wCourseLength
	ld a, [wCourseLength]
	ld b, a
;> if wGameMode != 1 and wVsPartnerLength >= n: n = wVsPartnerLength
	ld a, [wGameMode]
	cp $01
	jr z, jr_000_3229

	ld a, [wVsPartnerLength]
	ld c, a
	sub b
	jr c, jr_000_3229

	ld b, c

jr_000_3229:
;> copy(addr(wRecentRooms), addr(wRecentRooms) + n, 20)     # the last 20 rooms that get played
	ld a, b
	ld hl, wRecentRooms
	call AddAToHL
	ld b, $14
	ld de, wRecentRooms

jr_000_3235:
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, jr_000_3235

;> return
	ret


;@ def AvoidRecentRoom(end: de, room: a) -> a
;@ path: game/course
;@ BuildCourse: $AB (deal again) if the room is one of the 20 bytes before end, else the room.
;@ test: end = rand(0xC311, 0xC373)
;@ test: room = mem[end - rand(1, 25)] if rand(0, 1) else rand(30, 149)
;@ sig: 0455db6b
AvoidRecentRoom::
;> if room in [mem[end - 1 - k] for k in range(20)]: return 0xAB
	push de
	push bc
	ld b, $14
	ld c, a
	dec de

jr_000_3242:
	ld a, [de]
	cp c
	jr z, jr_000_324c

	dec de
	dec b
	jr nz, jr_000_3242

	jr jr_000_3250

jr_000_324c:
	ld a, $ab
	jr jr_000_3251

jr_000_3250:
;> return room
	ld a, c

jr_000_3251:
	pop bc
	pop de
	ret


;@ def Random() -> a
;@ path: lib/math
;@ The random number generator: four bytes of state, added up with carries
;@ (the bit shifted out of the last byte is the first carry).
;@ writes: wRandom
;@ reads: wRandom
;@ sig: 271ee255
Random::
;> carry = wRandom[3] & 1
	ld a, [wRandom + 3]
	rr a
	ld [wRandom + 3], a
;> t = wRandom[0] + 0x25 + carry
;> wRandom[0] = u8(t)
	ld a, [wRandom]
	adc $25
	ld [wRandom], a
	ld b, a
;> t1 = wRandom[1] + 0x33 + (t >> 8)
;> wRandom[1] = u8(t1)
	ld a, [wRandom + 1]
	adc $33
	ld [wRandom + 1], a
;> t = u8(t1) + u8(t) + (t1 >> 8)
	adc b
	ld b, a
;> t2 = wRandom[2] + 0x53 + (t >> 8)
;> wRandom[2] = u8(t2)
	ld a, [wRandom + 2]
	adc $53
	ld [wRandom + 2], a
;> t = u8(t2) + u8(t) + (t2 >> 8)
	adc b
	ld b, a
;> wRandom[3] = ((wRandom[3] & 0xFE) | (t >> 8)) ^ u8(t)
	ld a, [wRandom + 3]
	rl a
	xor b
	ld [wRandom + 3], a
;> return wRandom[3]
	ret


;@ def SerialSend()
;@ path: link/serial
;@ Sends wSerialOut to the link partner with this Game Boy's clock (if there is a partner).
;@ reads: wLinkActive, wLinkState, wSerialOut
;@ test: wLinkState = rand(0, 2)
;@ sig: 0aaeaded
SerialSend::
;> if not wLinkActive: return
	ld a, [wLinkActive]
	and a
	jr z, jr_000_329f

;> rSB = wSerialOut
	ld a, [wSerialOut]
	ldh [rSB], a
;> rSC |= 0x81                                               # internal clock, start
	ld hl, $ff02
	set 0, [hl]
	set 7, [hl]
;> if wLinkState == 1: Delay()
	ld a, [wLinkState]
	cp $01
	jr nz, jr_000_329f

	call Delay

jr_000_329f:
;> return
	ret


;@ def SerialDelay()
;@ path: link/serial
;@ A short pause (100 rounds of a loop) between two bytes. Keeps bc.
;@ sig: b41fdfae
SerialDelay::
;> return
	push bc
	ld bc, $0064

jr_000_32a4:
	dec bc
	ld a, b
	or c
	jr nz, jr_000_32a4

	pop bc
	ret


;@ def SerialInterrupt()
;@ path: link/serial
;@ The serial interrupt: a byte has arrived from the link partner (wSerialIn).
;@ What it means depends on the link step: one bit of wLinkState each (the VBlank
;@ handler does the sending side of the same steps). The follower answers on the
;@ master's clock: $9F on the title screen, the room it plays during a VS game,
;@ its course length on the rooms menu. During the end-of-game handshake
;@ (wLinkHandshake) the byte is only stored for VsHandshake.
;@ writes: hJoyHeld, hJoyPressed, wContinue, wCourseFinished, wCourseLengthSave, wCourseSeed, wDemo, wGiveUp, wHandshakeGot, wHandshakeIn, wHandshakeOut, wLinkActive, wLinkAnswerWait, wLinkDone, wLinkHandshake, wLinkMaster, wLinkRefused, wLinkState, wPartnerLengthSave, wPartnerRoomSeen, wPartnerStarted, wSerialIn, wVsPartnerLength, wVsPartnerRoom
;@ reads: wCourseLength, wCourseRoom, wDemo, wGiveUp, wLinkAnswerWait, wLinkHandshake, wLinkMaster, wLinkState, wSerialIn, wSerialOut, wVsPartnerLength, wVsPartnerRoom
;@ test: wLinkHandshake = 0 if rand(0, 7) else 1
;@ test: mem[0xCF48] = 0 if rand(0, 7) else 1
;@ test: wLinkState = (1 << rand(0, 7)) if rand(0, 7) else 0
;@ test: wDemo = 0
;@ test: mem[0xFF01] = rand(0, 255)
;@ test: if mem[0xCF3A] == 8 and rand(0, 1): mem[0xFF01] = (mem[0xC2BC] + 1 + rand(0, 1) * 0x80) & 0xFF
;@ test: if mem[0xFF01] in (0x66, 0x71): mem[0xFF01] = 0x70
;@ sig: dba62cf9
SerialInterrupt::
;>@ie rIE = 0x01
	push af
	push bc
	push de
	push hl
	ld a, $01
	ldh [rIE], a
;> wSerialIn = rSB
	ldh a, [rSB]
	ld [wSerialIn], a
;> if wLinkHandshake:
	ld a, [wLinkHandshake]
	and a
	jp nz, Jump_000_3460

;>@hs2     wHandshakeIn = wSerialIn; wHandshakeGot = 1                # VsHandshake waits for this
;>@an elif wLinkAnswerWait:                                             # the answer to MenuLinkStart's offer
;>@an1     wLinkRefused = 0; wLinkAnswerWait = 0
;>@an2     if wLinkMaster:
;>@an3         if wSerialIn != 0xFC: wLinkRefused = 1               # not the answer: no game
;>@an4     elif wSerialIn != 0x08: wPartnerStarted = 0
;>@an5     wLinkDone = 1
;=@an
	ld a, [wLinkAnswerWait]
	and a
	jp nz, Jump_000_3328

;> elif wSerialIn == 0x71 and wLinkState == 8:                      # the partner cleared its course first
	ld a, [wSerialIn]
	cp $71
	jr nz, jr_000_32ec

	ld a, [wLinkState]
	cp $08
	jr nz, jr_000_32ec

;>     wLinkHandshake = 1; wLinkState = 0; wCourseFinished = 0; wHandshakeOut = 0x72    # answer "you won"
	ld a, $01
	ld [wLinkHandshake], a
	xor a
	ld [wLinkState], a
	ld [wCourseFinished], a
	ld a, $72
	ld [wHandshakeOut], a
;>     rIE = 0x09
	ld a, $09
	ldh [rIE], a
;>     return VsHandshake()
	jp VsHandshake


jr_000_32ec:
;> else:
;>     if wDemo: wLinkState = wDemo
	ld a, [wDemo]
	and a
	jr z, jr_000_32f5

	ld [wLinkState], a

jr_000_32f5:
;>@b0     if wLinkState & 0x01:                                     # title screen and demo
;>@b0a         if wSerialIn == 0x9F: wLinkDone = 1
;>@b0b         elif wSerialIn == 0x66 and wSerialOut != 0x66:        # the partner starts a VS game
;>@b0c             if not wDemo: wCourseLengthSave = wCourseLength; wPartnerLengthSave = wVsPartnerLength
;>@b0d             wLinkState = 0; wLinkMaster = 0; wDemo = 0; wPartnerStarted = 1; rSCX = 0; rIE = 0x09
;>@b0e             enable_interrupts(); return EndDemo()
;>         else:
;>@b0f             if wSerialIn == 0xFF: wLinkActive = 0             # nobody at the other end
;>@b0g             rSB = 0x9F; rSC = (rSC & ~0x01) | 0x80            # answer $9F on the partner's clock
;>@b1     elif wLinkState & 0x02:                                   # menus: the master's buttons
;>@b1a         if not wLinkMaster: hJoyHeld = wSerialIn; hJoyPressed = wSerialIn
;>@b1b         wLinkDone = 1; wLinkState = 0
;>@b2     elif wLinkState & 0x04:                                   # the course seed
;>@b2a         if not wLinkMaster: wCourseSeed = wSerialIn
;>@b2b         wLinkDone = 1
;>@b3     elif wLinkState & 0x08:                                   # VS game: the partner's room
;>@b3a         if wSerialIn != 0xFF:
;>@b3b             if wSerialIn & 0x80: wSerialIn &= 0x7F; QueueSound(0x13)
;>@b3c             if wSerialIn and wSerialIn == u8(wVsPartnerRoom + 1):
;>@b3d                 wVsPartnerRoom = wSerialIn; QueueSound(0x12)
;>@b3e                 PrintBCD(ToBCDBlank(u8(wVsPartnerLength - wVsPartnerRoom + 1)), 0x9823)    # rooms left
;>@b3f                 DrawPartnerBar()
;>@b3g         if not wLinkMaster:
;>@b3h             rSB = wGiveUp | wCourseRoom; rSC = (rSC & ~0x01) | 0x80     # answer: our room
;>@b3i             wGiveUp = 0; wPartnerRoomSeen = 1
;>@b4     elif wLinkState & 0x10:                                   # the seed picked with A
;>@b4a         if wLinkMaster or wSerialIn < 0x76:
;>@b4b             if not wLinkMaster: wCourseSeed = wSerialIn
;>@b4c             wLinkDone = 1
;>@b5     elif wLinkState & 0x20:                                   # START
;>@b5a         if wSerialIn in (0x66, 0xEE): wLinkDone = 1
;>@b6     elif wLinkState & 0x40:                                   # after a VS game: go on
;>@b6a         if not wLinkMaster and wSerialIn & 0x09: wContinue = 1
;>@b6b         wLinkDone = 1
;>@b7     elif wLinkState & 0x80:                                   # the rooms menu of VS MODE
;>@b7a         if wSerialIn == 0xAA: hJoyPressed = BTN_A
;>@b7b         elif wSerialIn == 0xBB: hJoyPressed = BTN_B
;>@b7c         else: wVsPartnerLength = wSerialIn
;>@b7d         wLinkDone = 1
;>@b7e         if not wLinkMaster: rSB = wCourseLength; rSC = (rSC & ~0x01) | 0x80     # answer with ours
;>@x rIE = 0x09
;>@x2 return
;=@b0
	ld a, [wLinkState]
	bit 0, a
	jr nz, jr_000_3356

;=@b1
	bit 1, a
	jp nz, Jump_000_33b7

;=@b2
	bit 2, a
	jp nz, Jump_000_33d0

;=@b3
	bit 3, a
	jp nz, Jump_000_33e5

;=@b4
	bit 4, a
	jp nz, Jump_000_347f

;=@b5
	bit 5, a
	jp nz, Jump_000_3498

;=@b6
	bit 6, a
	jp nz, Jump_000_34ae

;=@b7
	bit 7, a
	jp nz, Jump_000_34ce

Jump_000_331f:
;=@x
	ld a, $09
	ldh [rIE], a
;=@x2
	pop hl
	pop de
	pop bc
	pop af
	reti


Jump_000_3328:
;=@an1
	xor a
	ld [wLinkRefused], a
	ld [wLinkAnswerWait], a
;=@an2
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_3349

;=@an3
	ld a, [wSerialIn]
	cp $fc
	jr z, jr_000_3341

	ld a, $01
	ld [wLinkRefused], a

jr_000_3341:
;=@an5
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


jr_000_3349:
;=@an4
	ld a, [wSerialIn]
	cp $08
	jr z, jr_000_3341

	xor a
	ld [wPartnerStarted], a
	jr jr_000_3341

jr_000_3356:
;=@b0a
	ld a, [wSerialIn]
	cp $9f
	jr z, jr_000_336c

;=@b0b
	cp $66
	jr z, jr_000_3384

;=@b0f
	cp $ff
	jr nz, jr_000_3374

	xor a
	ld [wLinkActive], a
	jp Jump_000_3374


jr_000_336c:
;=@b0a
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


Jump_000_3374:
jr_000_3374:
;=@b0g
	ld hl, $ff02
	res 7, [hl]
	ld a, $9f
	ldh [rSB], a
	res 0, [hl]
	set 7, [hl]
	jp Jump_000_331f


jr_000_3384:
;=@b0b
	ld a, [wSerialOut]
	cp $66
	jr z, jr_000_3374

;=@b0c
	ld a, [wDemo]
	and a
	jr nz, jr_000_339d

	ld a, [wCourseLength]
	ld [wCourseLengthSave], a
	ld a, [wVsPartnerLength]
	ld [wPartnerLengthSave], a

jr_000_339d:
;=@b0d
	xor a
	ld [wLinkState], a
	ld [wLinkMaster], a
	ld [wDemo], a
	ld a, $01
	ld [wPartnerStarted], a
	xor a
	ldh [rSCX], a
	ld a, $09
	ldh [rIE], a
;=@b0e
	ei
	jp EndDemo


Jump_000_33b7:
;=@b1a
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_33c4

	ld a, [wSerialIn]
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a

jr_000_33c4:
;=@b1b
	ld a, $01
	ld [wLinkDone], a
	xor a
	ld [wLinkState], a
	jp Jump_000_331f


Jump_000_33d0:
;=@b2a
	ld a, [wLinkMaster]
	and a
	jp nz, Jump_000_33dd

	ld a, [wSerialIn]
	ld [wCourseSeed], a

Jump_000_33dd:
;=@b2b
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


Jump_000_33e5:
;=@b3a
	ld a, [wSerialIn]
	cp $ff
	jr z, jr_000_342a

;=@b3b
	bit 7, a
	jr z, jr_000_33f8

	res 7, a
	ld [wSerialIn], a
	ld b, $13
	rst $30

jr_000_33f8:
;=@b3c
	ld a, [wVsPartnerRoom]
	ld b, a
	ld a, [wSerialIn]
	and a
	jp z, Jump_000_342a

	cp $ff
	jp z, Jump_000_342a

	cp b
	jr z, jr_000_342a

	inc b
	cp b
	jr nz, jr_000_342a

;=@b3d
	ld [wVsPartnerRoom], a
	ld b, $12
	rst $30
;=@b3e
	ld a, [wVsPartnerRoom]
	ld b, a
	ld a, [wVsPartnerLength]
	sub b
	inc a
	call ToBCDBlank
	ld hl, $9823
	call PrintBCD
;=@b3f
	call DrawPartnerBar

Jump_000_342a:
jr_000_342a:
;=@b3g
	ld a, [wLinkMaster]
	and a
	jp nz, Jump_000_331f

;=@b3h
	ld a, [wGiveUp]
	ld b, a
	ld a, [wCourseRoom]
	or b
	ldh [rSB], a
	ld hl, $ff02
	res 0, [hl]
	set 7, [hl]
;=@b3i
	xor a
	ld [wGiveUp], a
	ld a, $01
	ld [wPartnerRoomSeen], a
	jp Jump_000_331f


;@ def DrawPartnerBar()
;@ path: link/vs
;@ VS MODE: the partner's progress bar (rooms played of its course).
;@ writes: wBarLeft, wBarTotal
;@ reads: wVsPartnerLength, wVsPartnerRoom
;@ sig: addf33e8
DrawPartnerBar::
;> wBarLeft = wVsPartnerRoom
	ld a, [wVsPartnerRoom]
	ld [wBarLeft], a
;> wBarTotal = wVsPartnerLength
	ld a, [wVsPartnerLength]
	ld [wBarTotal], a
;> DrawProgressBar(0)
	ld a, $00
	call DrawProgressBar
;> return
	ret


Jump_000_3460:
;=@SerialInterrupt.hs2
	ld a, [wSerialIn]
	ld [wHandshakeIn], a
	ld a, $01
	ld [wHandshakeGot], a
	jp Jump_000_331f


Jump_000_346e:
;=@VsHandshake.both1
	ld a, [wCourseFinished]
	and a
	jp z, VsOpponentCleared

	ld a, [wLinkMaster]
	and a
	jp z, CourseCleared

;=@VsHandshake.both2
	jp VsOpponentCleared


Jump_000_347f:
;=@SerialInterrupt.b4a
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_3490

	ld a, [wSerialIn]
	cp $76
	jp nc, Jump_000_331f

;=@SerialInterrupt.b4b
	ld [wCourseSeed], a

jr_000_3490:
;=@SerialInterrupt.b4c
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


Jump_000_3498:
;=@SerialInterrupt.b5a
	ld a, [wSerialIn]
	cp $66
	jr z, jr_000_34a6

	cp $ee
	jr z, jr_000_34a6

	jp Jump_000_331f


jr_000_34a6:
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


Jump_000_34ae:
;=@SerialInterrupt.b6a
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_34c6

	ld a, [wSerialIn]
	bit 0, a
	jr z, jr_000_34c2

jr_000_34bb:
	ld a, $01
	ld [wContinue], a
	jr jr_000_34c6

jr_000_34c2:
	bit 3, a
	jr nz, jr_000_34bb

jr_000_34c6:
;=@SerialInterrupt.b6b
	ld a, $01
	ld [wLinkDone], a
	jp Jump_000_331f


Jump_000_34ce:
;=@SerialInterrupt.b7a
	ld a, [wSerialIn]
	cp $aa
	jr z, jr_000_34f9

;=@SerialInterrupt.b7b
	cp $bb
	jr z, jr_000_34ff

;=@SerialInterrupt.b7c
	ld [wVsPartnerLength], a

jr_000_34dc:
;=@SerialInterrupt.b7d
	ld a, $01
	ld [wLinkDone], a
;=@SerialInterrupt.b7e
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_34ea

	jp Jump_000_331f


jr_000_34ea:
	ld a, [wCourseLength]
	ldh [rSB], a
	ld hl, $ff02
	res 0, [hl]
	set 7, [hl]
	jp Jump_000_331f


jr_000_34f9:
;=@SerialInterrupt.b7a
	ld a, $01
	ldh [hJoyPressed], a
	jr jr_000_34dc

jr_000_34ff:
;=@SerialInterrupt.b7b
	ld a, $02
	ldh [hJoyPressed], a
	jr jr_000_34dc

;@ def LinkSendEE()
;@ path: link/serial
;@ Sends $EE on the partner's clock and waits for the link step to finish.
;@ test: skip waits for the serial interrupt
;@ sig: 47aec6fd
LinkSendEE::
;> return LinkSendFollower(0xEE)   # falls through
	ld a, $ee

;@ def LinkSendFollower(value: a)
;@ path: link/serial
;@ Puts a byte out for the partner to clock in (external clock), then waits
;@ for the link step to finish.
;@ test: skip waits for the serial interrupt
;@ sig: 2b72bf88
LinkSendFollower::
;> rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;> rSB = value
	ldh [rSB], a
;> rSC = (rSC & ~0x01) | 0x80                              # the partner's clock
	res 0, [hl]
	set 7, [hl]
;> return LinkWait()   # falls through

;@ def LinkWait()
;@ path: link/serial
;@ Waits until the link step is done (SerialInterrupt or the VBlank handler sets
;@ wLinkDone), then ends it.
;@ writes: wLinkDone, wLinkState
;@ reads: wLinkDone
;@ test: skip waits for the serial interrupt
;@ sig: 86e895f3
LinkWait::
;> wLinkDone = 0
	xor a
	ld [wLinkDone], a

jr_000_3516:
;> while not wLinkDone: pass
	ld a, [wLinkDone]
	and a
	jr z, jr_000_3516

;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> return
	ret


;@ def LinkFrameAnswer()
;@ path: link/vblank
;@ VBlank handler, while the partner's answer to the game offer is awaited: the
;@ master sends $08 once.
;@ writes: wLinkState, wSerialOut
;@ reads: wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: bd88d895
LinkFrameAnswer::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> wSerialOut = 0x08
	ld a, $08
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> return VBlankReturn()
	jp VBlankReturn


;@ def LinkFrameHandshake()
;@ path: link/vblank
;@ VBlank handler, end of a VS game: the master sends $71 (it was through first)
;@ or $72 (the partner was) every frame until VsHandshake has its answer.
;@ writes: wSerialOut
;@ reads: wCourseFinished, wHandshakeOut, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 599e5fd3
LinkFrameHandshake::
;> if not wLinkMaster: return VBlankFrameDone()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankFrameDone

;> wSerialOut = 0x71 if wCourseFinished else 0x72
	ld a, [wHandshakeOut]
	ld a, [wCourseFinished]
	and a
	jr z, jr_000_354b

	ld a, $71
	jr jr_000_354d

jr_000_354b:
	ld a, $72

jr_000_354d:
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> return VBlankFrameDone()
	jp VBlankFrameDone


;@ def LinkFrameDemo()
;@ path: link/vblank
;@ VBlank handler, link step 1 (title screen): during the demo A or START ends it
;@ and goes back to the title screen; the demo's own input is kept otherwise.
;@ writes: hJoyHeld, wDemo, wLinkState
;@ reads: hJoyHeld, hJoyPressed, wDemo
;@ test: skip ends in the VBlank handler's exit
;@ sig: 25a9541c
LinkFrameDemo::
;> if not wDemo: return VBlankReturn()
	ld a, [wDemo]
	and a
	jp z, VBlankReturn

;> held = hJoyHeld
	ldh a, [hJoyHeld]
	push af
;> ReadJoypad()
	call ReadJoypad
;> if not hJoyPressed & (BTN_A | BTN_START):
	ldh a, [hJoyPressed]
	and $09
	jr nz, jr_000_356f

;>     hJoyHeld = held
	pop af
	ldh [hJoyHeld], a
;>     return VBlankReturn()
	jp VBlankReturn


jr_000_356f:
;> rSCX = 0; wDemo = 0; wLinkState = 0
	pop af
	xor a
	ldh [rSCX], a
	ld [wDemo], a
	ld [wLinkState], a
;> enable_interrupts()
	ei
;> return Restart()
	jp Restart


;@ def LinkFrameSeedPick()
;@ path: link/vblank
;@ VBlank handler, link step $10: when the master presses A, the frame counter
;@ (doubled) becomes the course seed and goes to the partner.
;@ writes: wCourseSeed, wLinkMaster, wSerialOut
;@ reads: hJoyPressed, wClockFrames, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: dd7c19ff
LinkFrameSeedPick::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> ReadJoypad()
	call ReadJoypad
;> if hJoyPressed != BTN_A: return VBlankReturn()
	ldh a, [hJoyPressed]
	cp $01
	jp nz, VBlankReturn

;> wSerialOut = u8(wClockFrames << 1)
;> wCourseSeed = wSerialOut
	ld a, [wClockFrames]
	sla a
	ld [wSerialOut], a
	ld [wCourseSeed], a
;> SerialSend()
	call SerialSend
;> wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;> return VBlankFrameDone()
	xor a
	jp VBlankFrameDone


;@ def LinkFrameStart()
;@ path: link/vblank
;@ VBlank handler, link step $20: START on the master sends $66 (the game starts).
;@ writes: wLinkMaster, wSerialOut
;@ reads: hJoyPressed, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 2c6bc75d
LinkFrameStart::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> ReadJoypad()
	call ReadJoypad
;> if not hJoyPressed & BTN_START: return VBlankReturn()
	ldh a, [hJoyPressed]
	bit 3, a
	jp z, VBlankReturn

;> wSerialOut = 0x66
	ld a, $66
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> wLinkMaster = 1
	ld a, $01
	ld [wLinkMaster], a
;> return VBlankFrameDone()
	xor a
	jp VBlankFrameDone


;@ def LinkFrameButtons()
;@ path: link/vblank
;@ VBlank handler, link step 2 (menus): the master sends the buttons it pressed,
;@ so the follower's menus move along.
;@ writes: wSerialOut
;@ reads: hJoyPressed, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 242fdc78
LinkFrameButtons::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> ReadJoypad()
	call ReadJoypad
;> if not hJoyPressed: return VBlankReturn()
	ldh a, [hJoyPressed]
	and a
	jp z, VBlankReturn

;> wSerialOut = hJoyPressed
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> SerialDelay()
	call SerialDelay
;> return VBlankFrameDone()
	xor a
	jp VBlankFrameDone


;@ def LinkFrameProgress()
;@ path: link/vblank
;@ VBlank handler, link step 8 (VS game): the master sends the room it plays
;@ (bit 7: an event flag from $CF41); SerialInterrupt takes the partner's answer.
;@ writes: wGiveUp, wSerialOut
;@ reads: wCourseRoom, wGiveUp, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 9351271d
LinkFrameProgress::
;> if not wLinkMaster: return VBlankFrameDone()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankFrameDone

;> wSerialOut = wGiveUp | wCourseRoom
	ld a, [wGiveUp]
	ld b, a
	ld a, [wCourseRoom]
	or b
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> wGiveUp = 0
	xor a
	ld [wGiveUp], a
;> return VBlankFrameDone()
	jp VBlankFrameDone


;@ def LinkFrameSeed()
;@ path: link/vblank
;@ VBlank handler, link step 4: the master sends the course seed.
;@ writes: wSerialOut
;@ reads: wCourseSeed, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 9b2070e2
LinkFrameSeed::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> wSerialOut = wCourseSeed
	ld a, [wCourseSeed]
	ld [wSerialOut], a
;> SerialDelay()
	call SerialDelay
;> SerialSend()
	call SerialSend
;> return VBlankFrameDone()
	xor a
	jp VBlankFrameDone


;@ def LinkFrameContinue()
;@ path: link/vblank
;@ VBlank handler, link step $40 (after a VS game): A or START on the master goes
;@ on (wContinue) and is sent to the partner.
;@ writes: wContinue, wSerialOut
;@ reads: hJoyPressed, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 6795f6f8
LinkFrameContinue::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;> ReadJoypad()
	call ReadJoypad
;> if not hJoyPressed & (BTN_A | BTN_START): return VBlankReturn()
	ldh a, [hJoyPressed]
	and $09
	jp z, VBlankReturn

;> wContinue = hJoyPressed & (BTN_A | BTN_START)
	ld [wContinue], a
;> wSerialOut = hJoyPressed
	ldh a, [hJoyPressed]
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> return VBlankFrameDone()
	xor a
	jp VBlankFrameDone


;@ def LinkFrameRooms()
;@ path: link/vblank
;@ VBlank handler, link step $80 (the rooms menu of VS MODE): the master sends
;@ $AA for A or START, $BB for B, else its course length; the follower answers
;@ with its own.
;@ writes: wSerialOut
;@ reads: hJoyPressed, wCourseLength, wLinkMaster
;@ test: skip ends in the VBlank handler's exit
;@ sig: 04470bf0
LinkFrameRooms::
;> if not wLinkMaster: return VBlankReturn()
	ld a, [wLinkMaster]
	and a
	jp z, VBlankReturn

;>@aa if hJoyPressed & (BTN_A | BTN_START): out = 0xAA
	ldh a, [hJoyPressed]
	and $09
	jr nz, jr_000_3657

;>@bb elif hJoyPressed & BTN_B: out = 0xBB
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, jr_000_365b

;> else: out = wCourseLength
	ld a, [wCourseLength]

jr_000_364d:
;> wSerialOut = out
	ld [wSerialOut], a
;> SerialSend()
	call SerialSend
;> return VBlankReturn()
	xor a
	jp VBlankReturn


jr_000_3657:
;=@aa
	ld a, $aa
	jr jr_000_364d

jr_000_365b:
;=@bb
	ld a, $bb
	jr jr_000_364d

;@ def Wait3Seconds()
;@ path: lib/timing
;@ Ends the link step, then waits 180 frames.
;@ writes: wLinkState
;@ sig: dcb015a9
Wait3Seconds::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> for _ in range(18): WaitFrames10()
	ld b, $12

jr_000_3665:
	call WaitFrames10
	dec b
	jr nz, jr_000_3665

;> return
	ret


;@ def HoldSplitScroll()
;@ path: gfx/scroll
;@ Ends the link step, then for 180 frames scrolls the screen's middle band
;@ (lines 40-103) by wSplitSCX, with the rest of the screen unscrolled.
;@ writes: wLinkState
;@ reads: wSplitSCX
;@ sig: 3137c8e2
HoldSplitScroll::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> rSCX = 0
	ldh [rSCX], a
;> for _ in range(180):
	ld b, $b4

jr_000_3674:
;>     wait_ly(0x28)
	ldh a, [rLY]
	cp $28
	jr z, jr_000_367c

	jr jr_000_3674

jr_000_367c:
;>     rSCX = wSplitSCX
	ld a, [wSplitSCX]
	ldh [rSCX], a

jr_000_3681:
;>     wait_ly(0x68)
	ldh a, [rLY]
	cp $68
	jr z, jr_000_3689

	jr jr_000_3681

jr_000_3689:
;>     rSCX = 0
	xor a
	ldh [rSCX], a
;>     WaitVBlank()
	call WaitVBlank
	dec b
	jr nz, jr_000_3674

;> return
	ret


;@ def DrawOwnBar()
;@ path: game/course
;@ This Game Boy's progress bar (rooms played of the course).
;@ writes: wBarLeft, wBarTotal
;@ reads: wCourseLength, wCourseRoom
;@ sig: eebd804d
DrawOwnBar::
;> wBarLeft = wCourseRoom
	ld a, [wCourseRoom]
	ld [wBarLeft], a
;> wBarTotal = wCourseLength
	ld a, [wCourseLength]
	ld [wBarTotal], a
;> DrawProgressBar(1)
	ld a, $01
	call DrawProgressBar
;> return
	ret


;@ def CourseDone()
;@ path: game/course
;@ The last room of the course is cleared. In VS MODE this Game Boy tells the
;@ partner ($71: "I am through") and waits for the answer in VsHandshake first.
;@ writes: wCourseFinished, wHandshakeOut, wLinkHandshake
;@ reads: wGameMode
;@ test: skip never returns
;@ sig: 9506f222
CourseDone::
;> ClearShadowOAM()
	call ClearShadowOAM
;> if wGameMode == 1: return CourseCleared()
	ld a, [wGameMode]
	cp $01
	jr z, CourseCleared

;> wHandshakeOut = 0x71
	ld a, $71
	ld [wHandshakeOut], a
;> wCourseFinished = 1
	ld a, $01
	ld [wCourseFinished], a
;> wLinkHandshake = 1
	ld [wLinkHandshake], a
;> return VsHandshake()   # falls through

;@ def VsHandshake()
;@ path: link/vs
;@ The end of a VS game: sends $CF02 ($71 "I am through", $72 "you won") until
;@ the partner's byte arrives. $72 back: we won (CourseCleared); $71 back: both
;@ finished at once, and only the follower that sent $71 counts as the winner.
;@ writes: wHandshakeGot, wHandshakeIn
;@ reads: wCourseFinished, wHandshakeGot, wHandshakeIn, wHandshakeOut, wLinkMaster
;@ test: skip never returns
;@ sig: 6ccd6a87
VsHandshake::
;> enable_interrupts()
	ei
;> wHandshakeIn = 0; wHandshakeGot = 0
	xor a
	ld [wHandshakeIn], a
	ld [wHandshakeGot], a
;> if not wLinkMaster: rSC &= ~0x80; rSB = wHandshakeOut; rSC = (rSC & ~0x01) | 0x80
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_36d8

	ld hl, $ff02
	res 7, [hl]
	ld a, [wHandshakeOut]
	ldh [rSB], a
	res 0, [hl]
	set 7, [hl]

jr_000_36d8:
;> while not wHandshakeGot: pass                             # SerialInterrupt stores the answer
	ld a, [wHandshakeGot]
	and a
	jr z, jr_000_36d8

;>@c71 if wHandshakeIn == 0x71:
;>@both1     if wCourseFinished and not wLinkMaster: return CourseCleared()
;>@both2     return VsOpponentCleared()
;=@c71
	ld a, [wHandshakeIn]
	cp $71
	jp z, Jump_000_346e

;> if wHandshakeIn == 0x72: return CourseCleared()
	cp $72
	jr z, CourseCleared

;> return VsHandshake()
	jp VsHandshake


;@ def CourseCleared()
;@ path: game/course
;@ The course is cleared (in VS MODE: first): the bar, the room points, CLEARED!,
;@ the jingle and 3 seconds, then on to ContestCheck.
;@ writes: hJoyPressed, wCourseFinished, wHandshakeOut, wLinkHandshake, wLinkState, wOppClearedLast, wVsLost, wYouWins
;@ reads: wGameMode, wYouWins
;@ test: skip never returns
;@ sig: 4c335b5c
CourseCleared::
;> enable_interrupts()
	ei
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> wCourseFinished = 0; wHandshakeOut = 0; wLinkHandshake = 0; wLinkState = 0; wOppClearedLast = 0; wVsLost = 0
	xor a
	ld [wCourseFinished], a
	ld [wHandshakeOut], a
	ld [wLinkHandshake], a
	ld [wLinkState], a
	ld [wOppClearedLast], a
	ld [wVsLost], a
;> DrawOwnBar()
	call DrawOwnBar
;> if wGameMode == 1: AddRoomPoints()
	ld a, [wGameMode]
	cp $01
	jr nz, jr_000_3712

	call AddRoomPoints

jr_000_3712:
;> PrintText(0x9A01, ClearedText)
	ld hl, $9a01
	ld de, ClearedText
	call PrintText
;> QueueSound(4)
	ld b, $04
	rst $30
;> hJoyPressed = 0xFF
	ld a, $ff
	ldh [hJoyPressed], a
;> Wait3Seconds()
	call Wait3Seconds
;> wYouWins = u8(wYouWins + 1)
	ld a, [wYouWins]
	inc a
	ld [wYouWins], a
;> Delay()
	call Delay
;> return ContestCheck()
	jp ContestCheck


;@ def AfterCourse()
;@ path: game/course
;@ After a course or a VS game: the results screen, then HeadingOutDone, or in
;@ VS MODE GoHomeScene and ContestEnd.
;@ reads: wDemo, wGameMode
;@ test: skip never returns
;@ sig: 7e6cb978
AfterCourse::
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> if wDemo: SerialStop()
	ld a, [wDemo]
	and a
	call nz, SerialStop
;> DrawResultsScreen()
	call DrawResultsScreen
;> ResultsScreen()
	call ResultsScreen
;> DemoSerialListen()
	call DemoSerialListen
;> if wGameMode == 1: return HeadingOutDone()
	ld a, [wGameMode]
	cp $01
	jp z, HeadingOutDone

;> GoHomeScene()
	call GoHomeScene
;> return ContestEnd()
	jp ContestEnd


;@ def GoHomeScene()
;@ path: game/results
;@ The happy end, after a won contest or the last skill of GOING UP?: Kwirk
;@ walks along the lower box of the results screen to his house, then he and
;@ his girlfriend wave under a blinking heart until A or START (wContinue).
;@ Then the contest is over (ContestEnd).
;@ writes: wLinkState, wShadowOAM, wTitleBlink
;@ reads: wContinue, wLinkMaster, wShadowOAM, wTitleBlink
;@ test: skip never returns
;@ sig: a34fc0d5
GoHomeScene::
;> for i, v in enumerate((0x84, 0x88, 0x92, 0x00, 0x8C, 0x88, 0x9E, 0x00)):   # Kwirk, 2 tiles high
	ld hl, wShadowOAM
	ld a, $84
	ld [hli], a
	ld a, $88
	ld [hli], a
;>     mem[wShadowOAM + i] = v                     # (wLinkMaster picks tile $92 either way)
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_3767

	ld a, $92
	jr jr_000_3769

jr_000_3767:
	ld a, $92

jr_000_3769:
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $8c
	ld [hli], a
	ld a, $88
	ld [hli], a
	ld a, $9e
	ld [hli], a
	ld a, $00
	ld [hli], a
;> x, c = wShadowOAM[0x01], 4
	ld a, [wShadowOAM + 1]
	ld b, a
	ld c, $04
;> wLinkState = 0
	ld a, $00
	ld [wLinkState], a

jr_000_3784:
;> while True:                                     # a pixel every 2 frames
;>     WaitVBlank()
	call WaitVBlank
;>     WaitVBlank()
	call WaitVBlank
;>     wShadowOAM[0x01] = wShadowOAM[0x05] = x
	ld a, b
	ld [wShadowOAM + 1], a
	ld [wShadowOAM + 5], a
;>     c -= 1
;>     if c == 0:
	dec c
	jr nz, jr_000_37a6

;>         c = 4
	ld c, $04
;>         wShadowOAM[0x06] = 0x9F if wShadowOAM[0x06] == 0x9E else 0x9E   # the legs, every 4 pixels
	ld a, [wShadowOAM + 6]
	cp $9e
	jr z, jr_000_37a1

	ld a, $9e
	jr jr_000_37a3

jr_000_37a1:
	ld a, $9f

jr_000_37a3:
	ld [wShadowOAM + 6], a

jr_000_37a6:
;>     x -= 1
	dec b
;>     if x == 0x20: break                         # at the door
	ld a, $20
	cp b
	jr nz, jr_000_3784

;> ClearShadowOAM()
	call ClearShadowOAM
;> Delay()
	call Delay
;> Delay()
	call Delay
;> wLinkState = 0x40
	ld a, $40
	ld [wLinkState], a
;> SerialOfferEE()
	call SerialOfferEE
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a

Jump_000_37c1:
;> while True:
;>     ShowSprites(GirlfriendSprites, 0, 24, wTitleBlink)
	ld hl, GirlfriendSprites
	ld bc, $0018
	ld a, [wTitleBlink]
	call ShowSprites
;>     ShowSprites(KwirkCheerSprites, 1, 24, wTitleBlink)   # (both wLinkMaster branches pick it)
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_37ff

	ld hl, KwirkCheerSprites

jr_000_37d6:
	ld bc, $0118
	ld a, [wTitleBlink]
	call ShowSprites
;>     ShowSprites(HeartSprites, 3, 8, wTitleBlink)
	ld hl, HeartSprites
	ld bc, $0308
	ld a, [wTitleBlink]
	call ShowSprites
;>     WaitFrames10()
	call WaitFrames10
;>     wTitleBlink ^= 0xFF
	ld a, [wTitleBlink]
	cpl
	ld [wTitleBlink], a
;>     if wContinue: break
	ld a, [wContinue]
	and a
	jp z, Jump_000_37c1

;> return ContestEnd()
	jp ContestEnd


jr_000_37ff:
;> # (wLinkMaster 0: the same sprites)
	ld hl, KwirkCheerSprites
	jr jr_000_37d6

;@ def HeadingOutDone()
;@ path: game/results
;@ HEADING OUT? is over: the results stay until A or START (ContestEnd).
;@ The demo goes back to the title after 3 seconds instead.
;@ reads: hJoyPressed, wDemo
;@ test: skip never returns
;@ sig: 7b71468d
HeadingOutDone::
jr_000_3804:
;> while not wDemo:
	ld a, [wDemo]
	and a
	jr nz, jr_000_3816

;>     ReadJoypad()
	call ReadJoypad
;>     if hJoyPressed & 0x09: return ContestEnd()  # A or START
	ldh a, [hJoyPressed]
	and $09
	jp nz, ContestEnd

	jr jr_000_3804

jr_000_3816:
;> Wait3Seconds()
	call Wait3Seconds
;> return Restart()
	jp Restart


;@ def WaitFrames10()
;@ path: lib/timing
;@ Waits 10 frames. Keeps bc.
;@ sig: ef38730b
WaitFrames10::
;> for _ in range(10):
	push bc
	ld b, $0a

;>     WaitVBlank()
jr_000_381f:
	call WaitVBlank
	dec b
	jr nz, jr_000_381f

;> return
	pop bc
	ret


;@ def WaitFrames5()
;@ path: lib/timing
;@ Waits 5 frames, in WaitFrames10's loop. Keeps bc.
;@ sig: 62d8367e
WaitFrames5::
;> for _ in range(5): WaitVBlank()
	push bc
	ld b, $05
	jr jr_000_381f

;@ def SerialOfferEE()
;@ path: link/serial
;@ As the following Game Boy (wLinkMaster 0): puts $EE in rSB for the
;@ partner's next transfer.
;@ reads: wLinkMaster
;@ sig: 3697a598
SerialOfferEE::
;> if wLinkMaster: return
	ld a, [wLinkMaster]
	and a
	ret nz

;> rSC &= ~0x80
	ld hl, $ff02
	res 7, [hl]
;> rSB = 0xEE
	ld a, $ee
	ldh [rSB], a
;> rSC = (rSC & ~0x01) | 0x80
	res 0, [hl]
	set 7, [hl]
;> return
	ret


;@ def VsOpponentCleared()
;@ path: game/results
;@ VS MODE: the partner cleared its course first. It scores the game, its
;@ progress bar at the top fills up under CLEARED!, then ContestCheck.
;@ writes: hJoyPressed, wCourseFinished, wHandshakeOut, wLinkHandshake, wLinkState, wOppClearedLast, wOppWins, wUnusedCF3E, wVsLost, wVsPartnerRoom
;@ reads: wOppWins, wVsPartnerLength
;@ test: skip never returns
;@ sig: 71baa0eb
VsOpponentCleared::
;> enable_interrupts()
	ei
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> wCourseFinished = 0
	ld [wCourseFinished], a
;> wHandshakeOut = 0
	ld [wHandshakeOut], a
;> wLinkHandshake = 0
	ld [wLinkHandshake], a
;> WaitVBlank()
	call WaitVBlank
;> QueueSound(4)
	ld b, $04
	rst $30
;> hJoyPressed = 0xFF
	ld a, $ff
	ldh [hJoyPressed], a
;> wVsLost = 1
	ld a, $01
	ld [wVsLost], a
;> wOppClearedLast = 1
	ld [wOppClearedLast], a
;> wUnusedCF3E = 0
	xor a
	ld [wUnusedCF3E], a
;> wOppWins += 1
	ld a, [wOppWins]
	inc a
	ld [wOppWins], a
;> wVsPartnerRoom = u8(wVsPartnerLength + 1)
	ld a, [wVsPartnerLength]
	inc a
	ld [wVsPartnerRoom], a
;> DrawPartnerBar()
	call DrawPartnerBar
;> PrintText(0x9821, ClearedText)
	ld hl, $9821
	ld de, ClearedText
	call PrintText
;> wVsPartnerRoom = 0
	xor a
	ld [wVsPartnerRoom], a
;> HoldSplitScroll()
	call HoldSplitScroll
;> ClearShadowOAM()
	call ClearShadowOAM
;> return ContestCheck()
	jp ContestCheck


;@ def ContestLost()
;@ path: game/results
;@ The contest is lost: on the results screen Kwirk bobs up and down in
;@ front of his house, 26 times (22 on the following Game Boy), then sits
;@ dizzy (DizzyScene).
;@ reads: wLinkMaster
;@ test: skip never returns
;@ sig: 375583b5
ContestLost::
;> rIE = 0x09
	ld a, $09
	ldh [rIE], a
;> DrawResultsScreen()
	call DrawResultsScreen
;> ResultsScreen()
	call ResultsScreen
;> for i, v in enumerate((0x84, 0x68, 0x92, 0x00, 0x8C, 0x68, 0x9E, 0x00)):   # Kwirk at the house
	ld hl, wShadowOAM
	ld a, $84
	ld [hli], a
	ld a, $68
	ld [hli], a
;>     mem[wShadowOAM + i] = v                     # (wLinkMaster picks tile $92 either way)
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_38ab

	ld a, $92
	jr jr_000_38ad

jr_000_38ab:
	ld a, $92

jr_000_38ad:
	ld [hli], a
	ld a, $00
	ld [hli], a
	ld a, $8c
	ld [hli], a
	ld a, $68
	ld [hli], a
	ld a, $9e
	ld [hli], a
	ld a, $00
	ld [hli], a
;> for _ in range(u8(4 * wLinkMaster + 22) or 256):
	ld a, [wLinkMaster]
	ld b, $16
	sla a
	sla a
	add b
	ld b, a

jr_000_38c8:
;>     wShadowOAM[0x00] = u8(wShadowOAM[0x00] - 1)
;>     wShadowOAM[0x04] = u8(wShadowOAM[0x04] - 1)
	ld hl, wShadowOAM
	dec [hl]
	ld de, $0004
	add hl, de
	dec [hl]
;>     WaitFrames5()
	call WaitFrames5
;>     wShadowOAM[0x04] = u8(wShadowOAM[0x04] + 1)
;>     wShadowOAM[0x00] = u8(wShadowOAM[0x00] + 1)
	inc [hl]
	ld de, $fffc
	add hl, de
	inc [hl]
;>     WaitFrames5()
	call WaitFrames5
	dec b
	jr nz, jr_000_38c8
;> return DizzyScene()   # falls through

;@ def DizzyScene()
;@ path: game/results
;@ Kwirk sits dizzy under a blinking swirl until A or START. After a lost
;@ contest that is the end of it (ContestEnd); after a lost game
;@ (wOppClearedLast $FF) the next game follows.
;@ writes: wLinkState, wOppClearedLast, wTitleBlink
;@ reads: wContinue, wLinkMaster, wOppClearedLast, wTitleBlink
;@ test: skip never returns
;@ sig: f9d369eb
DizzyScene::
;> SerialOfferEE()
	call SerialOfferEE
;> ShowSprites(KwirkDizzySprites, 0, 24, 0)     # (both wLinkMaster branches pick it)
	ld hl, KwirkDizzySprites
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_38ef

	ld hl, KwirkDizzySprites

jr_000_38ef:
	ld bc, $0018
	xor a
	call ShowSprites
;> wLinkState = 0x40
	ld a, $40
	ld [wLinkState], a
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a

jr_000_38ff:
;> while True:
;>     ShowSprites(DizzySwirlSprites, 1, 8, wTitleBlink)
	ld hl, DizzySwirlSprites
	ld bc, $0108
	ld a, [wTitleBlink]
	call ShowSprites
;>     wTitleBlink ^= 0xFF
	ld a, [wTitleBlink]
	cpl
	ld [wTitleBlink], a
;>     WaitFrames10()
	call WaitFrames10
;>     if wContinue: break
	ld a, [wContinue]
	and a
	jr z, jr_000_38ff

;> if wOppClearedLast != 0xFF: return ContestEnd()
	ld a, [wOppClearedLast]
	cp $ff
	jp nz, ContestEnd

;> wOppClearedLast = 0
	xor a
	ld [wOppClearedLast], a
;> return ContestNextGame()
	jp ContestNextGame


;@ def ContestCheck()
;@ path: game/results
;@ After each game of a contest (and after HEADING OUT?): with a majority of
;@ the games (wContestGames / 2 + 1) the contest is won (AfterCourse) or lost
;@ (ContestLost). Otherwise the results: HEADING OUT? stays there
;@ (HeadingOutDone); in VS MODE the loser of the game sits dizzy
;@ (DizzyScene) and the winner cheers until A or START, then the next game.
;@ writes: wContinue, wLinkState, wObjSpriteX, wOppClearedLast, wTitleBlink, wUnusedCF3E
;@ reads: wContestGames, wContinue, wGameMode, wLinkMaster, wOppClearedLast, wOppWins, wTitleBlink, wYouWins
;@ test: skip never returns
;@ sig: 544b6cbe
ContestCheck::
;> wContinue = 0
	xor a
	ld [wContinue], a
;> wUnusedCF3E = 0
	ld [wUnusedCF3E], a
;> wObjSpriteX = 0xFF
	cpl
	ld [wObjSpriteX], a
;> need = u8(((wContestGames >> 1) | (wContestGames & 0x80)) + 1)
	ld a, [wContestGames]
	sra a
	inc a
	ld b, a
;> if wYouWins == need: return AfterCourse()
	ld a, [wYouWins]
	cp b
	jp z, AfterCourse

;> if wOppWins == need: return ContestLost()
	ld a, [wOppWins]
	cp b
	jp z, ContestLost

;> wObjSpriteX = 0
	xor a
	ld [wObjSpriteX], a
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> ResultsScreen()
	call ResultsScreen
;> if wGameMode == 1: return HeadingOutDone()
	ld a, [wGameMode]
	cp $01
	jp z, HeadingOutDone

;> if wLinkMaster: WaitFrames10()
	ld a, [wLinkMaster]
	and a
	jr z, jr_000_3966

	call WaitFrames10

jr_000_3966:
;> SerialOfferEE()
	call SerialOfferEE
;> if wOppClearedLast:
	ld a, [wOppClearedLast]
	and a
	jr z, jr_000_3977

;>     wOppClearedLast = 0xFF
	ld a, $ff
	ld [wOppClearedLast], a
;>     return DizzyScene()
	jp DizzyScene


jr_000_3977:
;> wLinkState = 0x40
	ld a, $40
	ld [wLinkState], a
;> wTitleBlink = 0
	xor a
	ld [wTitleBlink], a

jr_000_3980:
;> while True:
;>     ShowSprites(KwirkCheerSprites, 0, 24, wTitleBlink)   # (both wLinkMaster branches pick it)
	ld hl, KwirkCheerSprites
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_398c

	ld hl, KwirkCheerSprites

jr_000_398c:
	ld bc, $0018
	ld a, [wTitleBlink]
	call ShowSprites
;>     wTitleBlink ^= 0xFF
	ld a, [wTitleBlink]
	cpl
	ld [wTitleBlink], a
;>     WaitFrames10()
	call WaitFrames10
;>     if wContinue: break
	ld a, [wContinue]
	and a
	jr z, jr_000_3980
;> return ContestNextGame()   # falls through

;@ def ContestNextGame()
;@ path: game/results
;@ Back to the start screen for the next game of the contest (the scores
;@ stay), with the menu music.
;@ writes: wCourseRoom, wLinkState, wUnusedCF3E, wVsPartnerRoom
;@ test: skip never returns
;@ sig: 94ebac1c
ContestNextGame::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> wUnusedCF3E = 0
	xor a
	ld [wUnusedCF3E], a
;> wCourseRoom = 0
	xor a
	ld [wCourseRoom], a
;> wVsPartnerRoom = 0
	ld [wVsPartnerRoom], a
;> QueueSound(3)
	ld b, $03
	rst $30
;> ClearShadowOAM()
	call ClearShadowOAM
;> return MenusDone()
	jp MenusDone


;@ def ContestEnd()
;@ path: game/results
;@ The contest (or the game) is over: the course lengths chosen in the menus
;@ come back, the scores are cleared, the menu music starts, and it is back
;@ to the start screen.
;@ writes: wCourseLength, wCourseRoom, wOppWins, wUnusedCF3E, wVsPartnerLength, wVsPartnerRoom, wYouWins
;@ reads: wCourseLengthSave, wPartnerLengthSave
;@ test: skip never returns
;@ sig: f25c27d5
ContestEnd::
;> wCourseLength = wCourseLengthSave
	ld a, [wCourseLengthSave]
	ld [wCourseLength], a
;> wVsPartnerLength = wPartnerLengthSave
	ld a, [wPartnerLengthSave]
	ld [wVsPartnerLength], a
;> ClearShadowOAM()
	call ClearShadowOAM
;> wYouWins = 0
	xor a
	ld [wYouWins], a
;> wOppWins = 0
	ld [wOppWins], a
;> wUnusedCF3E = 0
	ld [wUnusedCF3E], a
;> wCourseRoom = 0
	ld [wCourseRoom], a
;> wVsPartnerRoom = 0
	ld [wVsPartnerRoom], a
;> QueueSound(3)
	ld b, $03
	rst $30
;> return MenusDone()
	jp MenusDone


; Unused code: waits 60 frames with wLinkState 0, then restores it
; (ld a, [wLinkState] / push af / xor a / ld [wLinkState], a / ld b, 60 /
; call WaitVBlank / dec b / jr nz / pop af / ld [wLinkState], a / ret).
	db $fa, $3a, $cf, $f5, $af, $ea, $3a, $cf, $06, $3c, $cd, $d2, $0f, $05, $20, $fa
	db $f1, $ea, $3a, $cf, $c9

;@ def DrawResultsScreen()
;@ path: game/results
;@ The results screen: two boxes and, but in HEADING OUT?, Kwirk's house in
;@ the lower one, where the scenes play.
;@ reads: wGameMode
;@ sig: a4a8b612
DrawResultsScreen::
;> LoadMenuTiles()
	call LoadMenuTiles
;> DisableLCD()
	call DisableLCD
;> FillBGMap0(0xEF)
	ld a, $ef
	call FillBGMap0
;> EnableLCD()
	call EnableLCD
;> DrawBox(0x9822, 16, 11)
	ld hl, $9822
	ld de, $100b
	call DrawBox
;> DrawBox(0x9961, 18, 6)
	ld hl, $9961
	ld de, $1206
	call DrawBox
;> if wGameMode == 1: return
	ld a, [wGameMode]
	cp $01
	ret z

;> PrintText(0x99A3, HouseText)
	ld hl, $99a3
	ld de, HouseText
	call PrintText
;> return
	ret


;@ asset: rows tiles=LoadMenuTiles newline=$AA end=$BB blank=$FF
;@ Kwirk's house (3 x 3 tiles) in the lower box of the results screen.
HouseText::
	db $ff, $90, $80, $aa, $81, $82, $83, $aa, $84, $85, $86, $bb

;@ OAM entries (y, x, tile, flags), two frames of 6: Kwirk's girlfriend
;@ waving, beside the house when a contest is won or a skill is cleared.
GirlfriendSprites::
	db $7a, $58, $66, $00
	db $7a, $60, $67, $00, $82, $58, $76, $00, $82, $60, $77, $00, $8a, $58, $8b, $00
	db $8a, $60, $8c, $00, $7a, $58, $68, $00, $7a, $60, $69, $00, $82, $58, $78, $00
	db $82, $60, $79, $00, $8a, $58, $8d, $00, $8a, $60, $8e, $00

;@ OAM entries, two frames of 6: Kwirk cheering.
KwirkCheerSprites::
	db $7b, $48, $60, $00
	db $7b, $50, $61, $00, $83, $48, $70, $00, $83, $50, $71, $00, $8b, $48, $64, $00
	db $8b, $50, $65, $00, $7b, $48, $62, $00, $7b, $50, $63, $00, $83, $48, $72, $00
	db $83, $50, $73, $00, $8b, $48, $74, $00, $8b, $50, $75, $00

;@ OAM entries, one frame of 6: Kwirk dizzy, when the contest is lost.
KwirkDizzySprites::
	db $7e, $68, $6c, $00
	db $7e, $70, $6d, $00, $86, $68, $7c, $00, $86, $70, $7d, $00, $8e, $68, $7a, $00
	db $8e, $70, $7b, $00

;@ OAM entries, two frames of 2: the swirl above dizzy Kwirk (the second
;@ frame is empty, so it blinks).
DizzySwirlSprites::
	db $74, $68, $89, $00, $74, $70, $8a, $00, $00, $00, $00, $00
	db $00, $00, $00, $00

;@ OAM entries, two frames of 2: a heart between Kwirk and his girlfriend
;@ (blinking).
HeartSprites::
	db $74, $50, $87, $00, $74, $58, $88, $00, $00, $00, $00, $00
	db $00, $00, $00, $00

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ "CLEARED!" over the course of the player who finished first.
ClearedText::
	db $02, $0b, $04, $00, $11, $04, $03, $20, $bb

;@ def PrintText(dest: hl, text: de)
;@ path: gfx/text
;@ Writes a string of tile numbers to the BG map, one tile per HBlank.
;@ $AA starts a new line (32 tiles below the line's start), $BB ends it.
;@ $46 and $47 (the marks above some letters) go one row up and one column
;@ left, without moving on. Keeps bc.
;@ writes: wBoxLeft
;@ reads: wBoxLeft
;@ test: text = 0x3FA7                        # TitleLogoText
;@ test: dest = 0x9843
;@ sig: ddc06080
PrintText::
;> line = dest
	push bc
	ld b, h
	ld c, l

;> for _ in forever():
jr_000_3ad7:
;>     c = mem[text]
	ld a, [de]
;>     if c == 0xAA:                           # new line
	cp $aa
	jr nz, jr_000_3ae5

;>         line = dest = line + 32
	ld hl, $0020
	add hl, bc
	ld c, l
	ld b, h
;>         text += 1
	inc de
;>         continue
	jr jr_000_3ad7

jr_000_3ae5:
;>     if c == 0xBB:                           # end
	cp $bb
;>         break
	jr z, jr_000_3b13

;>     if c == 0x46 or c == 0x47:              # a mark above the last letter
	cp $46
	jr nz, jr_000_3af2

	ld [wBoxLeft], a
	jr jr_000_3af9

jr_000_3af2:
	cp $47
	jr nz, jr_000_3b0b

;>         wBoxLeft = c
	ld [wBoxLeft], a

jr_000_3af9:
;>         above = dest - 33
	push hl
	push bc
	ld bc, $ffdf
	add hl, bc
	pop bc
;>         WaitHBlank()
	call WaitHBlank
;>         mem[above] = wBoxLeft
	ld a, [wBoxLeft]
	ld [hl], a
	pop hl
;>         text += 1
	inc de
;>         continue
	jr jr_000_3ad7

jr_000_3b0b:
;>     WaitHBlank()
	call WaitHBlank
;>     mem[dest] = c
	ld a, [de]
	ld [hli], a
;>     dest, text = dest + 1, text + 1
	inc de
	jr jr_000_3ad7

jr_000_3b13:
;> return
	pop bc
	ret


;@ def DrawBox(dest: hl, width: d, height: e)
;@ path: gfx/text
;@ Draws a frame of width x height tiles at dest (in the BG map) with the
;@ font's frame pieces: corners $74/$76/$79/$7B, edges $75/$77/$78/$7A,
;@ blank inside.
;@ writes: wBoxLeft, wBoxMiddle, wBoxRight
;@ sig: ff427589
DrawBox::
;> wBoxLeft = 0x74
	ld c, e
	ld a, $74
	ld [wBoxLeft], a
;> wBoxMiddle = 0x75
	inc a
	ld [wBoxMiddle], a
;> wBoxRight = 0x76
	inc a
	ld [wBoxRight], a
;> DrawBoxRow(dest, width)
	ld b, d
	push hl
	call DrawBoxRow
	pop hl
;> dest = u16(dest + 32)
	ld a, $20
	call AddAToHL
;> for _ in range(u8(height - 2) or 256):
	dec c
	dec c

jr_000_3b30:
;>     wBoxLeft = 0x77
	ld b, d
	ld a, $77
	ld [wBoxLeft], a
;>     wBoxMiddle = 0xFF
	ld a, $ff
	ld [wBoxMiddle], a
;>     wBoxRight = 0x78
	ld a, $78
	ld [wBoxRight], a
;>     DrawBoxRow(dest, width)
	push hl
	call DrawBoxRow
	pop hl
;>     dest = u16(dest + 32)
	ld a, $20
	call AddAToHL
	dec c
	jr nz, jr_000_3b30

;> wBoxLeft = 0x79
	ld b, d
	ld a, $79
	ld [wBoxLeft], a
;> wBoxMiddle = 0x7A
	inc a
	ld [wBoxMiddle], a
;> wBoxRight = 0x7B
	inc a
	ld [wBoxRight], a
;> DrawBoxRow(dest, width)
	call DrawBoxRow
;> return
	ret


;@ def DrawBoxRow(dest: hl, width: b) -> hl
;@ path: gfx/text
;@ One row of a box: wBoxLeft, width - 2 times wBoxMiddle, wBoxRight.
;@ reads: wBoxLeft, wBoxMiddle, wBoxRight
;@ sig: f6f5f7af
DrawBoxRow::
;> dest = PutTileHBlank(dest, wBoxLeft)
	ld a, [wBoxLeft]
	call PutTileHBlank
;> for _ in range(u8(width - 2) or 256):
	dec b
	dec b
	ld a, [wBoxMiddle]

;>     dest = PutTileHBlank(dest, wBoxMiddle)
jr_000_3b6a:
	call PutTileHBlank
	dec b
	jr nz, jr_000_3b6a

;> dest = PutTileHBlank(dest, wBoxRight)
	ld a, [wBoxRight]
	call PutTileHBlank
;> return dest
	ret


;@ def PutTileHBlank(dest: hl, tile: a) -> hl
;@ path: gfx/text
;@ Writes one tile in an HBlank, with only the VBlank interrupt enabled
;@ meanwhile (a serial interrupt could make it miss the HBlank).
;@ sig: 570dc290
PutTileHBlank::
;> rIE = 0x01
	push af
	ld a, $01
	ldh [rIE], a
;> WaitHBlank()
	call WaitHBlank
;> mem[dest] = tile
	pop af
	ld [hli], a
;> rIE = 0x09
	push af
	ld a, $09
	ldh [rIE], a
	pop af
;> return u16(dest + 1)
	ret


;@ def ShowSprites(frames: hl, slot: b, size: c, second: a)
;@ path: gfx/sprites
;@ Copies size bytes of OAM entries to the shadow OAM at slot * 24: the
;@ frame at frames, or with second set the one after it. The results scenes
;@ animate their characters with it, flipping second every 10 frames. Keeps de.
;@ test: size = rand(1, 48)
;@ test: frames = rand_ram(96, 0xC200)
;@ sig: 70f7752e
ShowSprites::
;> if second: frames = u16(frames + size)
	push de
	and a
	jr z, jr_000_3b90

	ld d, $00
	ld e, c
	add hl, de

jr_000_3b90:
;> copy(0xC000 + u8(24 * slot), frames, size)
	push hl
	ld hl, $0018
	ld a, b
	call MultiplyHLByA
	ld b, l
	pop hl
	ld d, $c0
	ld e, b

jr_000_3b9d:
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, jr_000_3b9d

;> return
	pop de
	ret


;@ def CourseMenu()
;@ path: game/menu
;@ SELECT COURSE: the length of the course in rooms, as two digits. LEFT or
;@ RIGHT picks the digit, UP or DOWN changes it, and the digit at the cursor
;@ blinks. In VS MODE each player picks a length of their own and the
;@ partner's shows beside OPP; the following Game Boy only steers its digits.
;@ A or START: wMenuChoice 0 (0 rooms count as 1), B: $FF.
;@ writes: hJoyPressed, wCourseLength, wCourseOnes, wCourseTens, wLinkState, wMenuChoice, wVsPartnerLength
;@ reads: hJoyPressed, wCourseLength, wCourseOnes, wCourseTens, wGameMode, wLinkMaster, wVsPartnerLength
;@ test: skip waits for A, B or START
;@ sig: 766218a5
CourseMenu::
;> hJoyPressed = 0
	xor a
	ldh [hJoyPressed], a
;> DrawMenuScreen()
	call DrawMenuScreen
;> if wGameMode != 1: PrintText(0x9943, OppYouText)
	ld a, [wGameMode]
	cp $01
	jr z, jr_000_3bbb

	ld hl, $9943
	ld de, OppYouText
	call PrintText

jr_000_3bbb:
;> DrawBox(0x9987, 8, 3)
	ld hl, $9987
	ld de, $0803
	call DrawBox
;> PrintText(0x99AB, RmsText)
	ld hl, $99ab
	ld de, RmsText
	call PrintText
;> PrintText(0x9903, SelectCourseText)
	ld hl, $9903
	ld de, SelectCourseText
	call PrintText
;> digit, blink = 0, 30                            # digit 0: tens, 1: ones
	ld b, $00
	ld c, $1e
;> q, r = DivideHLByA(wCourseLength, 10)
	ld a, [wCourseLength]
	ld l, a
	ld h, $00
	ld a, $0a
	call DivideHLByA
;> wCourseOnes = r
	ld [wCourseOnes], a
;> wCourseTens = lo(q)
	ld a, l
	ld [wCourseTens], a

Jump_000_3bec:
;> while True:
;>     ReadJoypad()
	push bc
	call ReadJoypad
;>     if not wLinkMaster: hJoyPressed &= 0xF0     # the following Game Boy: only the d-pad
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_3bfc

	ldh a, [hJoyPressed]
	and $f0
	ldh [hJoyPressed], a

jr_000_3bfc:
	pop bc
;>     pressed = hJoyPressed
;>     if not pressed & 0x0B and pressed & 0xF0:   # the d-pad alone
	ldh a, [hJoyPressed]
	and $0b
	jr nz, jr_000_3c1f

	ldh a, [hJoyPressed]
	and $f0
	jr z, jr_000_3c1f

;>         QueueSound(0x0D)
	push af
	push bc
	ld b, $0d
	rst $30
	pop bc
	pop af
;>         if pressed & 0xC0:                      # DOWN or UP: the digit at the cursor
;>             a = addr(wCourseTens) if digit == 0 else addr(wCourseOnes)
;>@dn             if pressed & 0x80: mem[a] = u8(mem[a] - 1)
;>@up             else: mem[a] = u8(mem[a] + 1)
;>@w1             if wCourseOnes == 0xFF: wCourseOnes = 9          # CourseDigitWrap
;>@w2             if wCourseOnes >= 10: wCourseOnes = 0
;>@w3             if wCourseTens == 0xFF: wCourseTens = 9
;>@w4             if wCourseTens >= 10: wCourseTens = 0
;>@w5             wCourseLength = u8(10 * wCourseTens + wCourseOnes)
	bit 7, a
	jp nz, Jump_000_3c91

	bit 6, a
	jp nz, Jump_000_3ca0

;>         elif pressed & 0x30:                    # LEFT or RIGHT: the other digit
;>@lr             digit ^= 1
	and $30
	jp nz, Jump_000_3cec

Jump_000_3c1f:
jr_000_3c1f:
;>     if not wLinkMaster:                         # it offers its length to the partner
	ld a, [wLinkMaster]
	and a
	jr nz, jr_000_3c31

;>         rSB = wCourseLength
	ld a, [wCourseLength]
	ldh [rSB], a
;>         rSC = (rSC & ~0x01) | 0x80
	ld hl, $ff02
	res 0, [hl]
	set 7, [hl]

jr_000_3c31:
;>     if wGameMode != 2:
	ld a, [wGameMode]
	cp $02
	jr z, jr_000_3c3d

;>         WaitVBlank()
	call WaitVBlank
	jr jr_000_3c59

jr_000_3c3d:
;>     else:
;>         wLinkState = 0x80
	ld a, $80
	ld [wLinkState], a
;>         LinkWait()
	call LinkWait
;>         q, r = DivideHLByA(wVsPartnerLength, 10)
	ld a, [wVsPartnerLength]
	ld l, a
	ld h, $00
	ld a, $0a
	call DivideHLByA
;>         PrintBCD(r | ((lo(q) << 4 | lo(q) >> 4) & 0xFF), 0x9948)   # the partner's length
	swap l
	or l
	ld hl, $9948
	call PrintBCD

jr_000_3c59:
;>     PrintBCD(wCourseOnes | ((wCourseTens << 4 | wCourseTens >> 4) & 0xFF), 0x99A8)
	ld a, [wCourseOnes]
	ld d, a
	ld a, [wCourseTens]
	swap a
	or d
	ld hl, $99a8
	call PrintBCD
;>     if blink < 10:
	ld a, c
	cp $0a
	jr nc, jr_000_3c7b

;>         WaitHBlank()
	ld hl, $99a8
	ld a, b
	call AddAToHL
	call WaitHBlank
;>         mem[u16(0x99A8 + digit)] = 0xFF        # the digit at the cursor blinks
	ld a, $ff
	ld [hl], a

jr_000_3c7b:
;>     blink -= 1
	dec c
	jr nz, jr_000_3c80

;>     if blink == 0: blink = 30
	ld c, $1e

jr_000_3c80:
;>     if hJoyPressed & 0x09:                      # A or START
;>@ok1         QueueSound(0x10)
;>@ok2         wCourseLength = AtLeastOne(wCourseLength)
;>@ok3         wVsPartnerLength = AtLeastOne(wVsPartnerLength)
;>@ok4         wMenuChoice = 0
;>@ok5         return
	ldh a, [hJoyPressed]
	and $09
	jp nz, Jump_000_3cf4

;>     if hJoyPressed & 0x02:                      # B
;>@b1         QueueSound(0x11)
;>@b2         wMenuChoice = 0xFF
;>@b3         return
	ldh a, [hJoyPressed]
	bit 1, a
	jp nz, Jump_000_3d0e

	jp Jump_000_3bec


Jump_000_3c91:
;=@dn
	ld hl, wCourseOnes
	ld a, b
	cpl
	and $01
	jr z, jr_000_3c9d

	ld hl, wCourseTens

jr_000_3c9d:
	dec [hl]
	jr jr_000_3cad

Jump_000_3ca0:
;=@up
	ld hl, wCourseOnes
	ld a, b
	cpl
	and $01
	jr z, jr_000_3cac

	ld hl, wCourseTens

jr_000_3cac:
	inc [hl]

jr_000_3cad:
;=@w1
	ld a, [wCourseOnes]
	cp $ff
	call z, CourseDigitWrap
;=@w2
	ld [wCourseOnes], a
	cp $0a
	jr c, jr_000_3cc0

	xor a
	ld [wCourseOnes], a

jr_000_3cc0:
;=@w3
	ld a, [wCourseTens]
	cp $ff
	call z, CourseDigitWrap
;=@w4
	ld [wCourseTens], a
	cp $0a
	jr c, jr_000_3cd3

	xor a
	ld [wCourseTens], a

jr_000_3cd3:
;=@w5
	push bc
	ld hl, $000a
	ld a, [wCourseTens]
	call MultiplyHLByA
	ld b, l
	ld a, [wCourseOnes]
	add b
	ld [wCourseLength], a
	pop bc
	jp Jump_000_3c1f


CourseDigitWrap:
;> # (CourseDigitWrap: a = 9, for the two calls above)
	ld a, $09
	ret


Jump_000_3cec:
;=@lr
	ld a, b
	cpl
	and $01
	ld b, a
	jp Jump_000_3c1f


Jump_000_3cf4:
;=@ok1
	ld b, $10
	rst $30
;=@ok2
	ld a, [wCourseLength]
	call AtLeastOne
	ld [wCourseLength], a
;=@ok3
	ld a, [wVsPartnerLength]
	call AtLeastOne
	ld [wVsPartnerLength], a
;=@ok4
	xor a

jr_000_3d0a:
	ld [wMenuChoice], a
;=@ok5
	ret


Jump_000_3d0e:
;=@b1
	ld b, $11
	rst $30
;=@b2
	ld a, $ff
;=@b3
	jr jr_000_3d0a

;@ def AtLeastOne(n: a) -> a
;@ path: lib/math
;@ n, but 1 instead of 0.
;@ sig: f11c6b0b
AtLeastOne::
;> return n if n else 1
	and a
	ret nz

	inc a
	ret


;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ "RMS" (rooms) of the course menu.
RmsText::
	db $11, $0c, $12, $bb

;@ def DrawStartScreen()
;@ path: game/menu
;@ The last screen before the game, with START or END: the contest for VS
;@ MODE, otherwise the game, skill and floor or course length.
;@ writes: wLinkState
;@ reads: wGameMode
;@ sig: 71e05cdc
DrawStartScreen::
;> wLinkState = 0
	xor a
	ld [wLinkState], a
;> LoadGameTiles()
	call LoadGameTiles
;> if wGameMode == 2:
	ld a, [wGameMode]
	cp $02
	jr nz, jr_000_3d30

;>     DrawVsStartScreen()
	call DrawVsStartScreen
	jr jr_000_3d33

jr_000_3d30:
;> else: DrawSoloStartScreen(wGameMode)
	call DrawSoloStartScreen

jr_000_3d33:
;> return
	ret


;@ def DrawVsStartScreen()
;@ path: game/menu
;@ VS MODE before a game of the contest: the skill, how many games
;@ (BEST OF), the wins so far (DrawWinMarks), both course lengths and the
;@ number of the game; then START or END.
;@ writes: wBoxRight
;@ reads: wContestGames, wOppWins, wYouWins
;@ sig: f79eb787
DrawVsStartScreen::
;> DisableLCD()
	call DisableLCD
;> FillBGMap0(0xCF)
	ld a, $cf
	call FillBGMap0
;> EnableLCD()
	call EnableLCD
;> DrawBox(0x9800, 20, 17)
	ld hl, $9800
	ld de, $1411
	call DrawBox
;> PrintText(0x9841, VsStartText)
	ld hl, $9841
	ld de, VsStartText
	call PrintText
;> PrintBCD(u8(wContestGames + 0xF0), 0x9891)         # BEST OF n
	ld a, [wContestGames]
	add $f0
	ld hl, $9891
	call PrintBCD
;> wBoxRight = 0xAA
	ld hl, $98d1
	ld a, $aa
	ld [wBoxRight], a
;> DrawWinMarks(0x98D1)
	call DrawWinMarks
;> PrintCourseLength(0x9906, 0x98C6)                  # YOU, then OPP
	ld hl, $9906
	ld de, $98c6
	call PrintCourseLength
;> PrintBCD(ToBCDBlank(u8(wYouWins + wOppWins + 1)), 0x994B)   # GAME n
	ld a, [wYouWins]
	ld b, a
	ld a, [wOppWins]
	add b
	inc a
	call ToBCDBlank
	ld hl, $994b
	call PrintBCD
;> PrintSkillDigit(0x9888)
	ld hl, $9888
	call PrintSkillDigit
;> StartEndMenu()
	call StartEndMenu
;> return
	ret


;@ def PrintSkillDigit(dest: hl) -> hl
;@ path: game/menu
;@ Prints the skill (wSkill + 1) as one digit.
;@ reads: wSkill
;@ sig: c04b36e0
PrintSkillDigit::
;> return PrintDigit(dest, u8(wSkill + 0xF1))
	ld a, [wSkill]
	add $f1
	call PrintDigit
	ret


;@ def StartEndMenu()
;@ path: game/menu
;@ START or END on the last screen before the game (wMenuChoice 0 or 1).
;@ writes: wMenuLastColRows
;@ sig: 05739c76
StartEndMenu::
;> PrintText(0x9987, StartEndText)
	ld hl, $9987
	ld de, StartEndText
	call PrintText
;> wMenuLastColRows = 1
	ld hl, $9986
	ld bc, $0001
	ld de, $0040
	ld a, $01
	ld [wMenuLastColRows], a
;> MenuChoose(0x9986, 0x0040, 0, 1, 0xAB)
	ld a, $ab
	call MenuChoose
;> return
	ret


;@ def DrawSoloStartScreen(mode: a)
;@ path: game/menu
;@ GOING UP? (skill and floor) or HEADING OUT? (skill and course length)
;@ before the game; then START or END.
;@ reads: wGameMode, wRoom
;@ sig: 551a009d
DrawSoloStartScreen::
;> MenuScreenText(0x9903, HeadingOutStartText if mode else GoingUpStartText)
	and a
	jr nz, jr_000_3dba

	ld de, GoingUpStartText
	jr jr_000_3dbd

jr_000_3dba:
	ld de, HeadingOutStartText

jr_000_3dbd:
	ld hl, $9903
	call MenuScreenText
;> if wGameMode == 0:
	ld a, [wGameMode]
	and a
	jr nz, jr_000_3de0

;>     floor = FloorDigits(wRoom)
	ld a, [wRoom]
	call FloorDigits
;>     PrintBCD(floor, 0x994F)
	ld hl, $994f
	push hl
	call PrintBCD
;>     WaitHBlank()
	pop hl
	dec hl
	call WaitHBlank
;>     mem[0x994E] = 0x1D                              # the dash of FL- again
	ld a, $1d
	ld [hl], a
	jr jr_000_3de6

jr_000_3de0:
;> else: PrintCourseLength(0x994C, 0)                 # (de: only VS MODE uses it)
	ld hl, $994c
	call PrintCourseLength

jr_000_3de6:
;> PrintSkillDigit(0x994A)
	ld hl, $994a
	call PrintSkillDigit
;> StartEndMenu()
	call StartEndMenu
;> return
	ret


;@ def PrintCourseLength(dest: hl, partner_dest: de)
;@ path: game/menu
;@ PrintRoomCounts with wCourseLength.
;@ reads: wCourseLength
;@ sig: 077f9979
PrintCourseLength::
;> n = wCourseLength
	ld a, [wCourseLength]
;> return PrintRoomCounts(dest, n, partner_dest)   # falls through

;@ def PrintRoomCounts(dest: hl, n: a, partner_dest: de)
;@ path: game/menu
;@ Prints n (rooms) at dest, and in VS MODE the partner's course length at
;@ partner_dest. It waits for an HBlank before each number for nothing:
;@ the tile before it (hl - 1) is never written.
;@ reads: wGameMode, wVsPartnerLength
;@ sig: 70256320
PrintRoomCounts::
;> WaitHBlank()
	push af
	push hl
	dec hl
	call WaitHBlank
	pop hl
	pop af
;> PrintBCD(dest, ToBCDBlank(n))
	call ToBCDBlank
	call PrintBCD
;> # (ret c: never taken, PrintBCD hands back the clear carry of ToBCDBlank)
	ret c

;> if wGameMode != 2: return
	ld a, [wGameMode]
	cp $02
	ret nz

;> v = ToBCDBlank(wVsPartnerLength)
	ld a, [wVsPartnerLength]
	call ToBCDBlank
;> WaitHBlank()
	ld h, d
	ld l, e
	push af
	push hl
	dec hl
	call WaitHBlank
	pop hl
	pop af
;> PrintBCD(partner_dest, v)
	call PrintBCD
;> return
	ret


;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE before a game: LEVEL, BEST OF, OPP and YOU rooms, GAME.
VsStartText::
	db $ff, $ff, $ff, $ff, $ff, $15, $12, $ff, $0c, $0e, $03, $04, $ff, $ff, $aa, $aa
	db $0b, $04, $15, $04, $0b, $ff, $1d, $ff, $ff, $01, $04, $12, $13, $ff, $0e, $05
	db $aa, $aa, $ff, $0e, $0f, $0f, $ff, $ff, $ff, $ff, $11, $0c, $12, $aa, $aa, $ff
	db $18, $0e, $14, $ff, $ff, $ff, $ff, $11, $0c, $12, $aa, $aa, $ff, $ff, $ff, $ff
	db $ff, $ff, $06, $00, $0c, $04, $ff, $ff, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ START / END below the last screen before the game.
StartEndText::
	db $12, $13, $00, $11, $13, $aa, $aa
	db $04, $0d, $03, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ GOING UP? before the game: LEVEL and FL (floor).
GoingUpStartText::
	db $ff, $ff, $ff, $06, $0e, $08, $0d, $06, $ff, $14, $0f, $21
	db $aa, $aa, $0b, $04, $15, $04, $0b, $ff, $1d, $ff, $ff, $05, $0b, $1d, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ HEADING OUT? before the game: LEVEL and the rooms of the course.
HeadingOutStartText::
	db $ff
	db $07, $04, $00, $03, $08, $0d, $06, $ff, $0e, $14, $13, $21, $aa, $aa, $0b, $04
	db $15, $04, $0b, $ff, $1d, $ff, $ff, $ff, $ff, $11, $0c, $12, $bb

;@ def AllRoomsCourse()
;@ path: game/course
;@ A hidden course: HEADING OUT? started with SELECT and LEFT held (MenusDone)
;@ plays every room of the skill in order instead of a random course.
;@ writes: wAllRooms, wCourseIndex, wCourseLength, wRoom
;@ sig: d54cc512
AllRoomsCourse::
;> wCourseIndex = 0
	xor a
	ld [wCourseIndex], a
;> wAllRooms = 0x28
	ld a, $28
	ld [wAllRooms], a
;> first, n = SkillRooms()
	call SkillRooms
;> wRoom = u8(first + 30)
	add $1e
	ld [wRoom], a
;> wCourseLength = n
	ld a, b
	ld [wCourseLength], a
;> for i in range(n or 256):
	ld hl, wCourseRooms
	ld a, $1e

jr_000_3ec3:
;>     mem[wCourseRooms + i] = u8(30 + i)
	ld [hli], a
	inc a
	dec b
	jr nz, jr_000_3ec3

;> return
	ret


;@ def SkillRooms() -> (a, b)
;@ path: game/course
;@ The HEADING OUT? rooms of the skill from SkillRoomRanges: a = the first
;@ (counted from room 30), b = how many. LEVEL-1 has rooms 30-59, LEVEL-2
;@ 60-109, LEVEL-3 110-149. Keeps hl.
;@ reads: wSkill
;@ sig: ce9b33aa
SkillRooms::
;> i = u8(2 * wSkill)
	push hl
	ld a, [wSkill]
	ld hl, SkillRoomRanges
	sla a
	call AddAToHL
;> return mem[SkillRoomRanges + i], mem[SkillRoomRanges + i + 1]
	ld a, [hli]
	ld b, [hl]
	pop hl
	ret


;@ The first room (counted from room 30) and the number of rooms of each
;@ skill for HEADING OUT?: (0, 30), (30, 50), (80, 40). Other tables follow.
SkillRoomRanges::
	db $00, $1e, $1e, $32, $50, $28, $ff, $3e, $01, $3f, $ff, $ff, $ff, $ff, $05, $3f
	db $05, $3f, $ff, $ff, $ff, $ff, $15, $3f, $15, $3f, $19, $3f, $ff, $ff, $28, $3f
	db $ff, $ff, $54, $3f, $44, $3f, $ff, $ec, $da, $ff, $d9, $db, $c0, $c1, $c3, $c5
	db $c2, $ca, $c6, $cd, $c4, $c7, $c9, $cb, $c8, $ce, $cc, $bf, $b0, $b4, $b1, $b5
	db $b2, $b9, $b3, $b8, $ae, $ac, $ad, $af, $b6, $bb, $b7, $bc, $ba, $bd, $be, $73
	db $72, $71, $72, $76, $75, $74, $75, $79, $78, $77, $78, $7c, $7b, $7a, $7b, $80
	db $80, $81, $81, $82, $82, $83, $83, $7d, $7d, $7e, $7f, $d0, $d1, $d3, $d2, $d7
	db $d8, $d5, $cf, $d0, $d6, $d3, $d4, $d7, $d8, $d5, $cf, $fd, $fd, $fd, $fd, $fc
	db $f8, $f7, $fe, $f5, $fa, $f9, $f6, $fd, $a1, $a2, $a3, $a0, $a5, $a6, $a7, $a4
	db $a9, $aa, $ab, $a8, $ac, $ae, $ad, $a3, $a0, $a1, $a2, $a7, $a4, $a5, $a6, $ab
	db $a8, $a9, $aa, $ac, $ae, $ad, $80, $40, $20, $10, $c0, $60, $30, $90, $e0, $70
	db $b0, $d0, $f0, $a0, $50

;@ asset: rows tiles=LoadMenuTiles newline=$AA end=$BB blank=$FF
;@ Kwirk's picture in the corner of the menu screens (5 rows of 4 tiles).
MenuKwirkText::
	db $60, $61, $62, $63, $aa, $64, $65, $66, $67, $aa, $68
	db $69, $6a, $6b, $aa, $6c, $6d, $6e, $6f, $aa, $70, $71, $72, $73, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ The KWIRK logo of the title screen, as rows of tiles.
TitleLogoText::
	db $90, $91
	db $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $28, $29, $aa, $a0, $a1
	db $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $ff, $ab, $ac, $aa, $b0, $b1, $b2, $b3
	db $b4, $b5, $b6, $b7, $b8, $b9, $ba, $ff, $bc, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ "PUSH START BUTTON" on the title screen.
PushStartText::
	db $0f, $14, $12, $07, $ff, $12
	db $13, $00, $11, $13, $ff, $01, $14, $13, $13, $0e, $0d, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ Title screen copyright line.
CopyrightAtlusText::
	db $80, $81, $82, $83
	db $22, $23, $24, $25, $26, $27, $37, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ "LICENSED BY NINTENDO" on the title screen.
LicensedText::
	db $84, $85, $86, $87, $88, $89, $8a, $8b
	db $8c, $8d, $8e, $8f, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ Title screen trademark lines.
TrademarkText::
	db $ff, $ff, $ff, $52, $53, $54, $55, $56, $57, $28, $29
	db $aa, $ff, $ff, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $bb

;@ asset: rows tiles=LoadTitleTiles newline=$AA end=$BB blank=$FF
;@ Title screen copyright line.
CopyrightAcclaimText::
	db $2a, $2b, $2c, $80, $81
	db $82, $83, $2e, $2f, $30, $31, $32, $33, $34, $35, $36, $37, $bb, $74, $75, $75
	db $75, $76, $aa, $77, $18, $0e, $14, $7c, $75, $75, $75, $75, $76, $74, $75, $75
	db $75, $75, $75, $75, $75, $75, $76, $aa, $77, $ff, $ff, $ff, $ff, $ff, $11, $0c
	db $12, $78, $77, $0c, $08, $0d, $ff, $3c, $e0, $3c, $3c, $78, $aa, $79, $7a, $7a
	db $7a, $7a, $7a, $7a, $7a, $7a, $7b, $79, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a
	db $7b, $bb, $74, $75, $75, $75, $75, $75, $75, $75, $75, $76, $74, $75, $75, $75
	db $75, $75, $75, $76, $aa, $77, $12, $02, $0e, $11, $04, $ff, $ff, $ff, $78, $77
	db $01, $0e, $0d, $14, $12, $ff, $78, $aa, $77, $ff, $ff, $ff, $ff, $ff, $ff, $3c
	db $ff, $78, $77, $ff, $3e, $3c, $3c, $3c, $ff, $78, $aa, $79, $7a, $7a, $7a, $7a
	db $7a, $7a, $7a, $7a, $7b, $79, $7a, $7a, $7a, $7a, $7a, $7a, $7b, $bb, $74, $75
	db $75, $75, $75, $75, $75, $75, $75, $76, $aa, $77, $ff, $ff, $ff, $ff, $ff, $11
	db $0c, $12, $78, $aa, $77, $0e, $0f, $0f, $7d, $7a, $7a, $7a, $7a, $7b, $aa, $79
	db $7a, $7a, $7a, $7b, $bb, $74, $75, $75, $75, $75, $75, $75, $75, $75, $76, $aa
	db $77, $87, $88, $88, $88, $88, $88, $88, $89, $78, $aa, $77, $87, $88, $88, $88
	db $88, $88, $88, $89, $78, $aa, $79, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7b
	db $bb, $74, $75, $75, $75, $75, $75, $75, $75, $75, $76, $aa, $77, $87, $88, $88
	db $88, $88, $88, $88, $89, $78, $aa, $77, $ff, $ff, $ff, $ff, $ff, $11, $0c, $12
	db $78, $aa, $79, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7b, $bb, $f4, $c0, $d0
	db $f3, $8e, $c0, $d0

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ The panel beside the room: level, floor and the REDO / END choices.
LevelPanelText::
	db $0b, $15, $0b, $1d, $aa, $aa, $05, $0b, $1d, $aa, $aa, $aa
	db $aa, $aa, $11, $04, $03, $0e, $aa, $aa, $04, $0d, $03, $bb, $01, $00, $02, $0a
	db $bb, $aa, $ff, $ff, $ff, $ff, $bb, $5b, $ff, $ff, $78, $aa, $77, $ff, $ff, $ff
	db $ff, $ff, $ff, $3c, $ff, $78, $77, $ff, $3e, $3c, $3c, $3c, $ff, $78, $aa, $79
	db $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7b, $79, $7a, $7a, $7a, $7a, $7a, $7a
	db $7b, $bb, $74, $75, $75, $75, $75, $75, $75, $75, $75, $76, $aa, $77, $18, $09
	db $27, $ff, $ff, $5f, $59, $50, $78, $aa, $77, $00, $01, $12, $7d, $7a, $7a, $7a
	db $7a, $7b, $aa, $79, $7a, $7a, $7a, $7b, $bb, $74, $75, $75, $75, $75, $75, $75
	db $75, $75, $76, $aa, $77, $87, $88, $88, $88, $88, $88, $88, $89, $78, $aa, $77
	db $87, $88, $88, $88, $88, $88, $88, $89, $78, $aa, $79, $7a, $7a, $7a, $7a, $7a
	db $7a, $7a, $7a, $7b, $bb, $74, $75, $75, $75, $75, $75, $75, $75, $75, $76, $aa
	db $77, $87, $88, $88, $88, $88, $88, $88, $89, $78, $aa, $77, $18, $09, $27, $ff
	db $ff, $5f, $59, $50, $78, $aa, $79, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7a, $7b
	db $bb, $f4, $c0, $d0, $f3, $8e, $c0, $d0, $5e, $e4, $57, $aa, $aa, $5f, $59, $50
	db $aa, $aa, $aa, $aa, $aa, $23, $27, $14, $04, $0b, $aa, $aa, $13, $27, $23, $21
	db $bb, $22, $13, $46, $0b, $bb, $ff, $ff, $ff, $aa, $ff, $ff, $ff, $bb, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff

; Room headers: 150 pointers, by room number. GOING UP? rooms (0-29) start with width and height; HEADING OUT? rooms (30-149) with the corridor shapes (two nibbles).
RoomHeaders::
	db $d4, $45, $d6, $45, $d8, $45, $da, $45, $dc
	db $45, $75, $5b, $de, $45, $e0, $45, $77, $5b, $79, $5b, $e2, $45, $e4, $45, $e6
	db $45, $e8, $45, $ea, $45, $ec, $45, $ee, $45, $f0, $45, $f2, $45, $04, $46, $06
	db $46, $f4, $45, $f6, $45, $f8, $45, $08, $46, $fa, $45, $fc, $45, $fe, $45, $00
	db $46, $02, $46, $16, $59, $22, $59, $98, $4f, $0f, $59, $10, $59, $17, $59, $18
	db $59, $1a, $59, $21, $59, $9d, $4f, $a0, $4f, $0c, $59, $1e, $59, $24, $59, $12
	db $59, $a1, $4f, $a4, $4f, $14, $59, $19, $59, $1b, $59, $20, $59, $99, $4f, $9e
	db $4f, $9f, $4f, $a2, $4f, $a9, $4f, $b3, $4f, $13, $59, $26, $59, $a8, $4f, $23
	db $59, $25, $59, $0e, $59, $15, $59, $1c, $59, $9a, $4f, $aa, $4f, $ae, $4f, $ca
	db $4f, $1d, $59, $b9, $4f, $a3, $4f, $ad, $4f, $b1, $4f, $b2, $4f, $11, $59, $1f
	db $59, $9c, $4f, $0d, $59, $a5, $4f, $b4, $4f, $bb, $4f, $a6, $4f, $a7, $4f, $b0
	db $4f, $b6, $4f, $b8, $4f, $c1, $4f, $ce, $4f, $b7, $4f, $bd, $4f, $ed, $4f, $b5
	db $4f, $c0, $4f, $e2, $4f, $c3, $4f, $d1, $4f, $c5, $4f, $c7, $4f, $cc, $4f, $cd
	db $4f, $cf, $4f, $d0, $4f, $d2, $4f, $f5, $4f, $ba, $4f, $bc, $4f, $bf, $4f, $c9
	db $4f, $c4, $4f, $e5, $4f, $e6, $4f, $af, $4f, $c2, $4f, $d7, $4f, $e3, $4f, $d4
	db $4f, $f7, $4f, $da, $4f, $be, $4f, $f1, $4f, $cb, $4f, $f2, $4f, $f3, $4f, $eb
	db $4f, $d6, $4f, $ec, $4f, $9b, $4f, $e4, $4f, $e7, $4f, $e9, $4f, $c8, $4f, $e8
	db $4f, $d5, $4f, $ea, $4f, $f6, $4f, $d3, $4f, $d9, $4f, $dc, $4f, $e1, $4f, $f4
	db $4f, $e0, $4f, $ef, $4f, $df, $4f, $ee, $4f, $f0, $4f, $dd, $4f, $de, $4f, $d8
	db $4f, $db, $4f

; Room bit maps: 150 pointers, by room number. A bit per tile, row after row: 1 = the next object from RoomObjects (walls too), 0 = floor.
RoomBits::
	db $0a, $46, $10, $46, $16, $46, $22, $46, $2c, $46, $7b, $5b, $36
	db $46, $44, $46, $85, $5b, $9a, $5b, $52, $46, $6c, $46, $8c, $46, $a2, $46, $be
	db $46, $d4, $46, $f5, $46, $13, $47, $3a, $47, $4a, $48, $77, $48, $5a, $47, $7b
	db $47, $8d, $47, $7f, $48, $a9, $47, $c7, $47, $f7, $47, $13, $48, $2f, $48, $63
	db $59, $ab, $59, $f8, $4f, $39, $59, $3f, $59, $69, $59, $6f, $59, $7b, $59, $a5
	db $59, $16, $50, $28, $50, $27, $59, $93, $59, $b7, $59, $4b, $59, $2e, $50, $40
	db $50, $57, $59, $75, $59, $81, $59, $9f, $59, $fe, $4f, $1c, $50, $22, $50, $34
	db $50, $5e, $50, $9a, $50, $51, $59, $c3, $59, $58, $50, $b1, $59, $bd, $59, $33
	db $59, $5d, $59, $87, $59, $04, $50, $64, $50, $7c, $50, $24, $51, $8d, $59, $be
	db $50, $3a, $50, $76, $50, $8e, $50, $94, $50, $45, $59, $99, $59, $10, $50, $2d
	db $59, $46, $50, $a0, $50, $ca, $50, $4c, $50, $52, $50, $88, $50, $ac, $50, $b8
	db $50, $ee, $50, $3c, $51, $b2, $50, $d6, $50, $f6, $51, $a6, $50, $e8, $50, $b4
	db $51, $fa, $50, $4e, $51, $06, $51, $12, $51, $30, $51, $36, $51, $42, $51, $48
	db $51, $54, $51, $26, $52, $c4, $50, $d0, $50, $e2, $50, $1e, $51, $00, $51, $c6
	db $51, $cc, $51, $82, $50, $f4, $50, $72, $51, $ba, $51, $60, $51, $32, $52, $84
	db $51, $dc, $50, $0e, $52, $2a, $51, $14, $52, $1a, $52, $ea, $51, $6c, $51, $f0
	db $51, $0a, $50, $c0, $51, $d2, $51, $de, $51, $18, $51, $d8, $51, $66, $51, $e4
	db $51, $2c, $52, $5a, $51, $7e, $51, $90, $51, $ae, $51, $20, $52, $a8, $51, $02
	db $52, $a2, $51, $fc, $51, $08, $52, $96, $51, $9c, $51, $78, $51, $8a, $51

; Room objects: 150 pointers to the object streams (turnstiles, blocks, holes, characters, stairs) BuildRoom reads for the 1 bits of RoomBits.
RoomObjects::
	db $a6
	db $48, $b0, $48, $b9, $48, $d9, $48, $01, $49, $a6, $5b, $1a, $49, $32, $49, $b8
	db $5b, $ca, $5b, $54, $49, $88, $49, $e4, $49, $0c, $4a, $55, $4a, $ab, $4a, $22
	db $4b, $55, $4b, $ad, $4b, $f5, $4e, $30, $4f, $31, $4c, $87, $4c, $a7, $4c, $3e
	db $4f, $07, $4d, $6c, $4d, $d8, $4d, $01, $4e, $7b, $4e, $5b, $5a, $24, $5b, $38
	db $52, $ef, $59, $0a, $5a, $78, $5a, $84, $5a, $98, $5a, $11, $5b, $9d, $52, $da
	db $52, $c9, $59, $d9, $5a, $4a, $5b, $2c, $5a, $f9, $52, $3c, $53, $3e, $5a, $88
	db $5a, $ad, $5a, $05, $5b, $52, $52, $b1, $52, $cc, $52, $14, $53, $a8, $53, $5b
	db $54, $3b, $5a, $68, $5b, $91, $53, $2f, $5b, $59, $5b, $e5, $59, $4b, $5a, $b5
	db $5a, $68, $52, $c0, $53, $07, $54, $a5, $55, $c2, $5a, $db, $54, $28, $53, $ee
	db $53, $39, $54, $50, $54, $1c, $5a, $e6, $5a, $91, $52, $de, $59, $5a, $53, $6f
	db $54, $ea, $54, $70, $53, $81, $53, $20, $54, $a4, $54, $c9, $54, $2c, $55, $00
	db $56, $b9, $54, $fa, $54, $69, $58, $8a, $54, $23, $55, $5f, $57, $42, $55, $41
	db $56, $5f, $55, $72, $55, $db, $55, $e8, $55, $19, $56, $35, $56, $51, $56, $e4
	db $58, $e1, $54, $f0, $54, $14, $55, $97, $55, $4c, $55, $ae, $57, $c2, $57, $0c
	db $54, $3a, $55, $b8, $56, $7d, $57, $7a, $56, $05, $59, $e8, $56, $08, $55, $a5
	db $58, $bf, $55, $b7, $58, $c8, $58, $2d, $58, $9a, $56, $39, $58, $83, $52, $97
	db $57, $d2, $57, $08, $58, $89, $55, $e5, $57, $8c, $56, $1b, $58, $f1, $58, $68
	db $56, $d9, $56, $07, $57, $51, $57, $d5, $58, $45, $57, $86, $58, $32, $57, $77
	db $58, $99, $58, $15, $57, $20, $57, $ca, $56, $fa, $56

; The rooms' headers, wall bit maps and object streams (rooms share and overlap their bytes).
RoomData::
	db $10, $03, $0e, $03, $0c
	db $06, $10, $05, $0e, $05, $0d, $07, $0f, $07, $09, $0d, $0f, $10, $0b, $0b, $0e
	db $0e, $10, $0b, $12, $0b, $0c, $0f, $12, $0d, $0d, $10, $12, $0b, $0f, $09, $0f
	db $0e, $0d, $0f, $12, $10, $10, $0e, $10, $0e, $12, $09, $12, $0f, $08, $08, $12
	db $0d, $10, $08, $45, $a2, $10, $08, $12, $20, $42, $08, $12, $20, $f0, $80, $f0
	db $20, $f2, $80, $18, $f0, $40, $f0, $10, $f0, $fe, $0f, $1f, $48, $47, $02, $1f
	db $08, $fe, $0f, $f0, $3c, $10, $20, $53, $08, $10, $20, $f0, $3c, $f0, $78, $05
	db $00, $00, $00, $49, $10, $00, $00, $05, $00, $f0, $78, $e1, $0e, $e0, $0e, $f6
	db $de, $00, $00, $41, $04, $00, $00, $e0, $0e, $e3, $80, $c1, $80, $d1, $80, $88
	db $80, $84, $80, $22, $00, $08, $00, $41, $00, $10, $00, $f7, $80, $c1, $80, $eb
	db $80, $e3, $80, $48, $20, $08, $7c, $eb, $1c, $08, $04, $4f, $cc, $00, $04, $62
	db $a4, $00, $80, $2e, $04, $0f, $34, $ff, $b4, $0e, $94, $0f, $44, $0f, $c4, $4f
	db $c4, $03, $c0, $2f, $00, $21, $00, $28, $80, $20, $80, $3d, $00, $9e, $a0, $3c
	db $00, $20, $80, $2c, $80, $21, $00, $2b, $00, $10, $3c, $54, $20, $11, $30, $f0
	db $20, $59, $fc, $1d, $80, $1c, $00, $1c, $78, $10, $30, $10, $30, $f8, $3c, $08
	db $c8, $4f, $c0, $07, $80, $f8, $e3, $1a, $08, $40, $aa, $1e, $08, $fe, $be, $f8
	db $86, $fa, $a0, $f8, $05, $1a, $e1, $50, $7f, $1c, $7f, $fe, $1f, $c0, $fc, $1f
	db $c0, $fd, $5f, $c0, $fc, $40, $c0, $0c, $e0, $00, $5e, $92, $80, $0d, $c0, $00
	db $fc, $40, $c0, $fc, $1f, $c0, $fc, $1f, $c0, $fe, $1f, $c0, $06, $a0, $14, $00
	db $0e, $00, $80, $d0, $24, $00, $04, $10, $0f, $b0, $4f, $80, $0f, $00, $04, $00
	db $2e, $00, $00, $d0, $84, $00, $14, $00, $26, $a0, $00, $40, $00, $1f, $7a, $00
	db $13, $ea, $00, $13, $ee, $00, $13, $e2, $00, $13, $e2, $00, $13, $ea, $00, $1b
	db $fe, $00, $11, $72, $00, $11, $12, $00, $13, $2a, $00, $51, $5a, $80, $11, $02
	db $00, $2f, $f8, $0f, $f8, $cd, $78, $98, $38, $f4, $58, $b2, $08, $a1, $48, $c4
	db $80, $e9, $10, $e4, $78, $e7, $b8, $ff, $38, $f7, $98, $e7, $d8, $ef, $d8, $ef
	db $98, $0f, $f0, $00, $01, $00, $00, $0f, $f0, $00, $ff, $e8, $40, $2f, $e2, $00
	db $af, $e0, $40, $2f, $e0, $00, $ff, $f0, $00, $0f, $e8, $40, $01, $00, $00, $0f
	db $e0, $00, $81, $22, $01, $00, $01, $98, $01, $e8, $10, $5a, $01, $90, $01, $84
	db $01, $40, $81, $46, $c8, $82, $b4, $52, $a8, $8a, $b3, $72, $b8, $8a, $d1, $86
	db $aa, $0a, $a5, $1a, $89, $3a, $80, $0a, $c8, $26, $fd, $4a, $d8, $4a, $e9, $66
	db $ff, $98, $c9, $78, $a0, $b8, $aa, $58, $93, $98, $d4, $58, $84, $20, $f1, $d0
	db $89, $40, $a0, $38, $87, $58, $34, $18, $05, $58, $ff, $58, $d1, $38, $00, $00
	db $00, $1f, $fe, $00, $1f, $3e, $00, $19, $1e, $00, $18, $4e, $00, $1a, $86, $00
	db $11, $52, $00, $13, $1a, $00, $18, $36, $00, $1c, $56, $00, $1e, $c6, $00, $1f
	db $3e, $00, $1f, $fe, $00, $1f, $fe, $00, $40, $00, $00, $00, $00, $00, $be, $68
	db $11, $48, $02, $08, $00, $08, $00, $08, $00, $08, $24, $98, $00, $08, $00, $08
	db $00, $08, $00, $08, $40, $08, $08, $2a, $d3, $c8, $f4, $1b, $e0, $45, $c4, $30
	db $d7, $72, $c3, $14, $d0, $42, $c5, $f8, $f0, $30, $ee, $ea, $cc, $fb, $d5, $c4
	db $e4, $13, $3f, $ff, $bf, $ff, $ff, $fa, $c0, $ff, $d2, $c0, $ff, $c4, $c0, $ff
	db $e2, $80, $ff, $a0, $80, $ff, $e0, $80, $ff, $d4, $c0, $ff, $c2, $c0, $ff, $fa
	db $c0, $80, $80, $40, $29, $4a, $00, $00, $00, $00, $4a, $a4, $80, $80, $00, $40
	db $90, $04, $40, $42, $a0, $80, $08, $08, $00, $81, $40, $40, $90, $04, $40, $80
	db $00, $40, $ff, $7f, $c0, $00, $00, $00, $00, $80, $00, $80, $00, $40, $00, $50
	db $00, $9c, $48, $00, $30, $3c, $c4, $01, $c0, $e1, $55, $c0, $c4, $01, $c0, $88
	db $40, $c0, $a1, $05, $c0, $85, $12, $c0, $8b, $4a, $40, $a5, $12, $c0, $89, $05
	db $c0, $80, $40, $c0, $c4, $01, $c0, $e1, $55, $c0, $c4, $01, $c0, $00, $00, $a1
	db $9a, $00, $00, $9c, $01, $00, $00, $00, $1f, $00, $a1, $1f, $01, $00, $1f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $20, $00
	db $00, $96, $00, $00, $00, $00, $a1, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $a0, $a0, $a0, $00, $00, $00, $00, $00, $a0, $a0, $a0, $a0
	db $21, $00, $a1, $a0, $a0, $a0, $01, $00, $a0, $a0, $a0, $a0, $00, $00, $00, $00
	db $00, $a0, $a0, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $a1, $a0, $95, $10, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $95, $93, $a1, $9e, $93, $01, $95
	db $93, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $13, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $13, $14, $11, $11, $14, $13, $00
	db $00, $00, $a1, $11, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $97, $00, $00, $00, $01, $00, $00, $99, $00
	db $98, $97, $00, $9b, $9b, $2d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $a1, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	db $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $9a, $00, $00
	db $00, $00, $00, $2d, $00, $00, $00, $00, $00, $a0, $00, $00, $00, $12, $11, $00
	db $00, $2d, $00, $00, $a0, $00, $a0, $a0, $00, $00, $a0, $a0, $a0, $00, $a0, $00
	db $00, $00, $00, $00, $00, $a0, $a0, $a0, $a0, $00, $a0, $00, $00, $a0, $a0, $a0
	db $13, $00, $00, $a0, $a0, $a0, $00, $00, $00, $a0, $a0, $a0, $a0, $00, $00, $a1
	db $00, $a0, $a0, $a0, $a0, $00, $00, $a0, $a0, $a0, $00, $00, $a0, $12, $a0, $00
	db $00, $00, $00, $10, $00, $00, $00, $00, $a0, $a0, $00, $12, $a1, $a0, $a0, $a0
	db $a0, $1f, $01, $00, $a0, $a0, $00, $00, $00, $00, $10, $12, $00, $00, $00, $00
	db $a0, $a0, $00, $00, $00, $a0, $a0, $a0, $1f, $00, $01, $00, $a0, $2e, $00, $20
	db $00, $00, $00, $a0, $00, $21, $a0, $a0, $a0, $a0, $a0, $00, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $12, $00, $a0
	db $a0, $00, $a0, $a0, $00, $00, $00, $00, $a0, $00, $00, $00, $00, $a0, $a0, $a0
	db $11, $2d, $a0, $00, $00, $00, $a0, $a0, $00, $a1, $a0, $a0, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $9b, $00, $01, $00, $98, $00, $9e, $00
	db $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $96, $00
	db $9a, $00, $00, $00, $00, $00, $9e, $00, $00, $00, $00, $00, $00, $00, $00, $a1
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $13, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $a0, $00, $00, $a0, $a0, $00, $00, $12, $a1, $00, $a0, $a0, $a0, $10
	db $2d, $11, $01, $a0, $a0, $13, $00, $00, $00, $00, $00, $00, $00, $00, $a0, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $98, $98, $9d, $00, $12
	db $00, $12, $00, $00, $00, $10, $9a, $00, $00, $a0, $00, $00, $00, $00, $00, $99
	db $a0, $1f, $01, $00, $a1, $a0, $a0, $00, $00, $00, $00, $00, $9a, $12, $00, $12
	db $10, $00, $10, $00, $00, $9b, $00, $a0, $00, $00, $99, $99, $36, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $a0, $a0, $a0, $00, $a0, $10, $00, $00
	db $a0, $a0, $00, $00, $a0, $12, $10, $00, $00, $a0, $a0, $a0, $a0, $a0, $00, $00
	db $a0, $a0, $a0, $a0, $a0, $00, $00, $a0, $a0, $a0, $a0, $a0, $10, $00, $00, $1f
	db $a0, $00, $a0, $a0, $a0, $00, $10, $00, $00, $00, $00, $11, $10, $00, $00, $00
	db $00, $00, $00, $00, $10, $00, $10, $10, $00, $a1, $00, $00, $10, $10, $11, $00
	db $01, $00, $00, $00, $a1, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $11, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $a0, $a0, $00, $00, $2d, $98, $00, $00, $1f, $a0
	db $21, $1f, $00, $00, $10, $1f, $1f, $00, $00, $00, $97, $10, $00, $00, $00, $10
	db $1f, $00, $00, $00, $00, $00, $11, $00, $00, $02, $00, $00, $00, $00, $00, $00
	db $10, $00, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $03, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $97, $98, $1f, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $2f, $a1
	db $1f, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $01, $1f, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $96, $99, $1f, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $2d, $00, $00, $00, $a0, $10, $00, $00, $a0, $00, $1f, $00, $a1, $00, $a0, $00
	db $01, $00, $a0, $00, $00, $a0, $11, $00, $a0, $00, $00, $2d, $10, $00, $00, $a0
	db $10, $92, $01, $00, $00, $91, $1f, $10, $99, $00, $00, $a0, $10, $98, $97, $00
	db $00, $a0, $a0, $a0, $a0, $a0, $92, $12, $00, $00, $a0, $a0, $a0, $a0, $10, $00
	db $00, $1f, $a0, $a0, $20, $93, $00, $00, $91, $00, $a0, $10, $00, $00, $11, $10
	db $a0, $a0, $00, $00, $00, $97, $97, $99, $a0, $a0, $00, $00, $11, $00, $00, $00
	db $00, $11, $12, $00, $00, $a0, $a0, $a0, $00, $00, $99, $10, $93, $00, $00, $a0
	db $00, $00, $1f, $10, $00, $a1, $a0, $a0, $00, $96, $a0, $10, $a0, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $10, $1f, $a0, $a0, $00
	db $00, $00, $90, $00, $10, $00, $00, $00, $93, $97, $00, $00, $00, $00, $00, $10
	db $00, $10, $2d, $00, $00, $00, $10, $a0, $1f, $a0, $00, $00, $00, $00, $a0, $00
	db $a0, $a0, $a0, $00, $a0, $a0, $00, $00, $2e, $00, $00, $00, $9d, $a0, $00, $00
	db $00, $00, $00, $00, $9b, $00, $00, $10, $00, $00, $00, $00, $a0, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a1, $a0, $a0
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $10, $01, $00, $00
	db $00, $00, $90, $10, $00, $00, $00, $00, $9c, $10, $00, $00, $00, $00, $93, $99
	db $00, $00, $00, $00, $10, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a0
	db $00, $10, $00, $00, $00, $00, $a0, $90, $10, $a0, $00, $00, $00, $00, $a0, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a1, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $1a, $97, $1a, $a0, $1a, $00, $00, $00
	db $00, $01, $02, $03, $04, $00, $00, $00, $00, $00, $10, $00, $96, $96, $00, $a1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a0, $10, $20, $00, $00, $10
	db $01, $00, $00, $10, $90, $20, $10, $00, $00, $1f, $a0, $a0, $00, $00, $98, $00
	db $00, $00, $9c, $10, $00, $97, $00, $00, $00, $00, $1f, $a0, $00, $00, $9b, $10
	db $11, $00, $00, $00, $00, $00, $a0, $00, $00, $10, $00, $00, $a0, $10, $a0, $a0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $a0, $00, $00, $00, $00, $a0, $00
	db $00, $00, $10, $a0, $a0, $a0, $00, $00, $20, $10, $00, $00, $00, $00, $00, $a0
	db $a0, $a0, $a0, $10, $a0, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $a1, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $00, $a0, $a0, $10, $10
	db $00, $00, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $00, $a0, $00, $11, $10, $00, $00
	db $a0, $a0, $a0, $00, $a0, $a0, $a0, $a0, $a0, $00, $1f, $00, $00, $a0, $a0, $a0
	db $a0, $00, $a0, $a0, $a0, $a0, $10, $2d, $12, $10, $a1, $a0, $00, $a0, $a0, $a0
	db $a0, $a0, $a0, $1f, $01, $a0, $a0, $a0, $a0, $00, $a0, $a0, $a0, $a0, $10, $2d
	db $10, $a0, $a0, $a0, $00, $a0, $a0, $a0, $a0, $a0, $00, $11, $1f, $00, $00, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $00, $a0, $00, $10, $00, $00, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $00, $a0, $a0, $10, $10, $00, $00, $00, $01, $00, $20
	db $20, $20, $20, $20, $20, $99, $11, $1f, $20, $1f, $11, $96, $00, $00, $00, $20
	db $20, $00, $97, $1f, $20, $1f, $98, $20, $20, $00, $20, $20, $00, $00, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $a1, $00, $00, $01, $1f, $00, $00, $00, $00, $2d, $2d, $00
	db $00, $00, $a1, $a0, $a0, $00, $00, $97, $00, $00, $00, $00, $00, $97, $97, $90
	db $90, $98, $00, $00, $00, $00, $00, $10, $00, $00, $00, $00, $20, $9a, $00, $00
	db $00, $20, $99, $96, $10, $00, $00, $00, $10, $10, $99, $10, $00, $00, $a1, $00
	db $10, $10, $9c, $91, $10, $01, $00, $20, $10, $10, $98, $10, $00, $00, $00, $20
	db $98, $97, $10, $00, $00, $00, $9a, $00, $00, $00, $00, $10, $00, $00, $00, $00
	db $00, $96, $96, $92, $92, $99, $00, $00, $00, $00, $00, $96, $00, $00, $00, $22
	db $55, $22, $22, $22, $00, $11, $50, $33, $22, $50, $00, $22, $22, $32, $22, $33
	db $33, $23, $40, $50, $33, $00, $22, $22, $22, $22, $22, $40, $22, $22, $50, $40
	db $50, $33, $50, $30, $00, $50, $43, $33, $22, $23, $22, $22, $00, $33, $22, $33
	db $23, $22, $50, $00, $52, $00, $00, $55, $50, $25, $55, $22, $22, $52, $33, $55
	db $25, $23, $22, $25, $22, $05, $20, $22, $22, $22, $05, $50, $22, $22, $02, $32
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $25, $22, $05, $00, $30, $e7
	db $81, $24, $81, $e7, $ff, $83, $ab, $83, $a3, $8b, $38, $c3, $eb, $00, $c3, $cb
	db $ff, $28, $c2, $f0, $c0, $22, $08, $00, $10, $44, $10, $00, $ff, $00, $a5, $81
	db $a5, $81, $ff, $00, $54, $00, $ff, $ff, $ff, $80, $81, $c9, $81, $a5, $01, $eb
	db $d7, $f3, $00, $e3, $ff, $c9, $ed, $00, $e3, $c9, $ff, $5a, $24, $5a, $5a, $24
	db $5a, $22, $88, $9c, $a2, $80, $ff, $ab, $ab, $28, $ab, $ab, $ff, $89, $b1, $20
	db $a1, $89, $ff, $91, $51, $90, $51, $91, $51, $88, $20, $48, $20, $88, $ff, $d3
	db $c3, $c3, $10, $d3, $c3, $c7, $c7, $d7, $20, $83, $93, $00, $92, $10, $10, $92
	db $00, $84, $a5, $89, $a5, $05, $ff, $00, $49, $11, $45, $d7, $01, $cb, $cb, $e3
	db $10, $cb, $c3, $10, $90, $00, $00, $42, $00, $81, $89, $24, $89, $81, $ff, $81
	db $ed, $20, $ed, $81, $ff, $c1, $c1, $34, $c1, $c1, $ff, $80, $a4, $82, $80, $a4
	db $80, $38, $12, $28, $12, $38, $ff, $3c, $18, $f7, $3c, $18, $ff, $e0, $ea, $e4
	db $e0, $e0, $ff, $24, $06, $3e, $26, $04, $ff, $fc, $d0, $00, $1f, $10, $80, $00
	db $a9, $01, $a9, $01, $ff, $00, $90, $04, $20, $08, $20, $00, $54, $02, $40, $15
	db $40, $00, $10, $44, $10, $44, $00, $02, $00, $92, $40, $49, $03, $00, $a1, $91
	db $a5, $81, $81, $01, $00, $b5, $00, $e7, $00, $01, $49, $c1, $84, $55, $81, $02
	db $92, $08, $10, $42, $10, $22, $44, $08, $04, $22, $7e, $00, $92, $40, $04, $28
	db $20, $08, $62, $04, $90, $04, $22, $40, $74, $02, $74, $40, $ff, $00, $24, $82
	db $10, $40, $12, $10, $42, $4c, $20, $52, $08, $a1, $d5, $00, $c9, $91, $ff, $44
	db $50, $05, $da, $45, $00, $81, $91, $54, $40, $91, $81, $ec, $52, $52, $5a, $56
	db $ef, $88, $98, $7c, $fc, $f8, $fe, $f0, $80, $c0, $03, $01, $07, $f8, $d4, $f2
	db $b0, $f0, $e0, $e2, $ef, $eb, $21, $69, $03, $fe, $fe, $e8, $d4, $e8, $c0, $00
	db $aa, $c0, $c0, $2a, $80, $00, $55, $11, $45, $11, $c7, $81, $bd, $81, $af, $af
	db $80, $8f, $40, $0a, $50, $df, $40, $00, $be, $42, $76, $5e, $00, $63, $4b, $20
	db $85, $10, $04, $f0, $fe, $f0, $f2, $fc, $f0, $6e, $44, $d5, $80, $3a, $10, $00
	db $76, $48, $54, $52, $88, $44, $c4, $90, $42, $12, $e2, $22, $28, $42, $28, $22
	db $ff, $08, $af, $80, $54, $10, $04, $02, $58, $26, $b8, $02, $22, $09, $48, $82
	db $80, $48, $09, $3f, $e3, $a0, $22, $48, $80, $c0, $d2, $d8, $c2, $d2, $c0, $10
	db $c0, $f4, $04, $92, $00, $00, $d8, $40, $d9, $0b, $01, $ad, $2b, $9a, $2b, $ad
	db $ff, $2f, $5f, $8f, $40, $ee, $e0, $8a, $b1, $b8, $ac, $96, $e4, $e3, $a2, $d4
	db $c2, $98, $30, $b1, $44, $08, $81, $34, $69, $69, $c2, $2c, $3c, $82, $49, $f3
	db $9c, $d8, $e5, $ff, $ff, $00, $7e, $ea, $4c, $7c, $00, $f2, $44, $2a, $44, $64
	db $70, $82, $90, $c4, $12, $44, $02, $ff, $ff, $ff, $ff, $ff, $ff, $20, $aa, $8a
	db $40, $55, $04, $50, $0d, $98, $3d, $21, $00, $00, $6a, $fc, $b6, $19, $10, $80
	db $82, $c8, $2a, $4a, $00, $55, $82, $54, $a8, $44, $aa, $30, $c7, $60, $d7, $28
	db $00, $22, $18, $e8, $02, $00, $f0, $20, $da, $c0, $e2, $02, $48, $56, $08, $40
	db $ea, $20, $08, $c2, $d0, $d0, $c4, $d7, $c0, $00, $0a, $a0, $00, $0a, $20, $00
	db $00, $00, $00, $00, $00, $00, $00, $9a, $9c, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $98, $97, $00
	db $00, $00, $00, $00, $00, $98, $00, $00, $00, $96, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $96, $92, $00, $00, $00, $00, $00, $00, $00, $00, $99
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $11, $1f, $a0, $a0, $12, $a0
	db $a0, $10, $2e, $a0, $a0, $2d, $10, $1f, $96, $94, $95, $97, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $9d, $9b, $00, $00, $00, $00, $9d, $9b, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $9a, $96, $96, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $97, $9c, $00, $00, $00, $00, $9b, $9e, $00
	db $00, $00, $00, $10, $10, $00, $00, $00, $00, $10, $10, $00, $00, $00, $00, $10
	db $20, $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $00, $00, $00, $10, $12, $1f, $00, $00, $00, $1f, $10, $00, $00
	db $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $10, $10, $10, $10
	db $10, $10, $00, $00, $10, $10, $00, $00, $10, $10, $10, $10, $10, $10, $10, $12
	db $12, $00, $10, $00, $10, $12, $10, $00, $10, $10, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $10, $10, $00, $00, $00, $10, $10, $00, $00, $10, $10, $00
	db $10, $10, $00, $00, $00, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $1f, $00, $00, $10, $2f, $00, $10, $00, $10, $00, $00, $1f, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $10, $1f, $00, $10, $1f, $00, $10, $1f, $10
	db $1f, $00, $10, $1f, $00, $10, $1f, $00, $00, $2d, $2d, $2d, $10, $2d, $00, $2d
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $11, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $9d, $00, $00, $11, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $9a, $00, $00, $00, $11
	db $00, $00, $00, $00, $00, $00, $00, $97, $9d, $98, $10, $10, $96, $9b, $99, $00
	db $10, $00, $99, $10, $00, $00, $9c, $00, $00, $98, $10, $00, $10, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $1f, $1f, $00, $10, $00, $96, $99, $00, $00, $00
	db $94, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00, $00, $11, $00, $00, $00
	db $00, $97, $00, $00, $1f, $00, $00, $11, $00, $00, $00, $00, $00, $00, $10, $91
	db $2f, $97, $98, $00, $00, $00, $99, $00, $9c, $10, $00, $98, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a0, $1f, $10, $a0, $00, $93
	db $00, $a0, $1f, $10, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $a0, $9a, $10, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $97, $98, $a0, $11, $a0, $00, $96
	db $99, $00, $a0, $a0, $a0, $a0, $10, $95, $95, $a0, $10, $a0, $a0, $a0, $00, $00
	db $00, $00, $00, $00, $00, $00, $11, $a0, $a0, $11, $a0, $a0, $10, $10, $a0, $1f
	db $a0, $10, $10, $11, $a0, $a0, $11, $a0, $a0, $00, $00, $00, $00, $00, $00, $00
	db $00, $a0, $a0, $a0, $a0, $a0, $a0, $12, $12, $a0, $a0, $a0, $10, $a0, $a0, $a0
	db $a0, $a0, $a0, $00, $00, $00, $00, $00, $00, $00, $00, $20, $10, $10, $10, $10
	db $00, $00, $a0, $10, $20, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $00, $00, $00, $00, $00, $a0
	db $97, $97, $97, $00, $00, $97, $97, $97, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $96, $95, $94, $9e, $94, $00, $9c, $98, $90, $97, $93, $9c, $98, $93
	db $90, $9d, $9e, $94, $97, $98, $90, $11, $97, $97, $11, $1f, $11, $98, $00, $00
	db $00, $00, $9e, $00, $00, $1f, $00, $00, $97, $97, $00, $00, $00, $00, $00, $10
	db $10, $9c, $1f, $9a, $10, $00, $00, $00, $00, $00, $00, $00, $1f, $96, $00, $00
	db $97, $00, $00, $99, $10, $9c, $1f, $00, $00, $00, $10, $97, $9e, $11, $12, $10
	db $9e, $9c, $10, $98, $10, $12, $1f, $9a, $1f, $99, $10, $00, $00, $00, $00, $00
	db $00, $10, $94, $94, $94, $2d, $96, $97, $1f, $2d, $12, $10, $10, $94, $11, $94
	db $94, $10, $10, $1f, $10, $10, $96, $96, $10, $10, $10, $97, $97, $1f, $00, $00
	db $00, $00, $00, $00, $00, $00, $9d, $99, $1f, $9a, $9a, $96, $10, $96, $10, $96
	db $95, $10, $95, $10, $94, $11, $10, $95, $10, $00, $2d, $00, $00, $10, $12, $10
	db $00, $00, $1f, $1f, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $10, $11, $00, $11, $10, $10, $11, $1f, $11, $10, $10, $10, $11, $10, $00, $00
	db $00, $1f, $00, $1f, $20, $11, $1f, $00, $1f, $00, $00, $00, $10, $10, $10, $10
	db $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10, $10
	db $10, $10, $10, $10, $10, $10, $00, $10, $00, $10, $a0, $10, $10, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $00, $20, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $10, $a0, $a0, $a0, $21, $a0, $a0, $10, $11, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $14, $a0, $a0, $a0, $12, $a0, $a0, $a0, $a0, $10, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $10, $a0, $a0, $a0, $a0, $10
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $10, $a0, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $00, $00, $00, $00, $00, $a0, $a0, $00, $00, $00, $00, $00, $a0, $a0
	db $10, $10, $a0, $a0, $10, $10, $a0, $a0, $10, $10, $a0, $a0, $10, $9a, $97, $91
	db $a0, $10, $a0, $10, $9a, $96, $91, $a0, $92, $10, $92, $00, $10, $00, $94, $94
	db $00, $9e, $00, $a0, $10, $10, $a0, $00, $00, $00, $00, $9c, $10, $00, $00, $00
	db $a0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $10, $9a, $10, $1f, $a0, $00, $a0, $00, $00, $00, $00, $00
	db $a0, $97, $a0, $a0, $11, $a0, $a0, $a0, $a0, $a0, $11, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $10, $10, $a0, $10, $97, $10, $a0, $94, $96, $95, $11, $96
	db $10, $a0, $a0, $a0, $00, $a0, $a0, $a0, $00, $10, $10, $11, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $11, $a0, $a0, $a0, $00, $10, $10, $a0, $a0, $a0, $00, $a0
	db $11, $11, $a0, $11, $a0, $a0, $a0, $11, $11, $11, $11, $a0, $11, $a0, $11, $11
	db $a0, $00, $00, $00, $00, $12, $1f, $10, $00, $00, $00, $1f, $2d, $10, $a0, $2d
	db $10, $10, $a0, $11, $11, $12, $9d, $20, $00, $97, $10, $a0, $10, $a0, $10, $10
	db $10, $10, $99, $9c, $9a, $10, $98, $10, $10, $00, $00, $00, $00, $00, $00, $00
	db $00, $10, $91, $96, $10, $a0, $a0, $a0, $a0, $96, $96, $96, $2d, $10, $11, $99
	db $00, $00, $2d, $10, $20, $97, $00, $10, $00, $10, $96, $10, $10, $00, $9b, $9b
	db $a0, $11, $a0, $9d, $9d, $10, $00, $a0, $00, $00, $00, $00, $00, $00, $00, $a0
	db $00, $00, $00, $a0, $2d, $11, $10, $9b, $00, $a0, $a0, $a0, $a0, $00, $96, $a0
	db $a0, $a0, $20, $a0, $a0, $a0, $a0, $a0, $9c, $00, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $9c, $2d, $10, $97, $92, $96, $00, $00, $11, $00, $00, $a0, $00, $11
	db $00, $00, $00, $10, $00, $00, $10, $10, $10, $10, $00, $10, $10, $10, $00, $10
	db $10, $10, $10, $10, $10, $10, $00, $10, $10, $10, $10, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $a0, $00, $00, $00, $00, $20, $a0, $00, $00, $00, $00, $a0
	db $a0, $00, $00, $00, $a0, $00, $00, $a0, $99, $10, $10, $00, $00, $00, $00, $10
	db $00, $00, $10, $10, $11, $00, $00, $a0, $91, $00, $10, $10, $a0, $00, $9b, $a0
	db $10, $a0, $10, $a0, $a0, $a0, $a0, $2d, $a0, $a0, $1f, $13, $1f, $a0, $a0, $11
	db $9e, $a0, $a0, $20, $1f, $a0, $10, $10, $a0, $a0, $10, $13, $10, $20, $1f, $1f
	db $96, $10, $a0, $11, $10, $90, $a0, $1f, $10, $a0, $a0, $a0, $a0, $11, $a0, $10
	db $10, $00, $00, $00, $00, $00, $00, $1f, $10, $10, $a0, $a0, $00, $00, $00, $a0
	db $00, $00, $00, $a0, $a0, $11, $00, $a0, $10, $10, $a0, $a0, $a0, $10, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $a0
	db $a0, $11, $a0, $10, $a0, $a0, $a0, $a0, $10, $12, $a0, $a0, $a0, $a0, $10, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $00, $a0, $1f, $9e, $1f, $10, $a0, $1f, $a0, $a0
	db $91, $a0, $a0, $a0, $a0, $98, $10, $91, $a0, $96, $91, $97, $10, $91, $91, $10
	db $a0, $a0, $10, $a0, $10, $a0, $10, $a0, $a0, $10, $a0, $10, $a0, $a0, $a0, $10
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $10, $10, $10, $a0, $10, $a0, $10, $a0, $10
	db $a0, $a0, $10, $a0, $a0, $a0, $10, $a0, $10, $a0, $10, $a0, $10, $a0, $a0, $a0
	db $10, $00, $9b, $00, $10, $a0, $00, $00, $00, $00, $00, $9d, $00, $10, $92, $1f
	db $00, $10, $00, $a0, $a0, $36, $00, $10, $00, $11, $a0, $97, $a0, $00, $1f, $00
	db $10, $a0, $a0, $a0, $a0, $a0, $a0, $00, $11, $a0, $a0, $10, $10, $a0, $10, $a0
	db $a0, $a0, $11, $a0, $9a, $9d, $1f, $a0, $10, $92, $00, $00, $a0, $a0, $a0, $a0
	db $a0, $12, $a0, $12, $a0, $a0, $a0, $10, $a0, $a0, $a0, $a0, $a0, $10, $11, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $1f, $11, $a0, $a0, $a0, $11, $a0, $97, $10, $2d
	db $98, $10, $a0, $a0, $00, $00, $9b, $94, $00, $00, $00, $00, $11, $a0, $a0, $11
	db $10, $94, $a0, $a0, $a0, $a0, $96, $94, $10, $96, $10, $92, $92, $a0, $92, $10
	db $a0, $00, $a0, $90, $90, $90, $10, $90, $a0, $a0, $a0, $00, $00, $10, $00, $00
	db $98, $00, $00, $1f, $00, $00, $97, $a0, $a0, $00, $00, $00, $96, $97, $96, $97
	db $98, $99, $99, $22, $32, $13, $11, $22, $50, $05, $50, $00, $50, $22, $55, $22
	db $51, $22, $22, $50, $11, $22, $22, $22, $00, $22, $22, $00, $22, $02, $40, $0e
	db $6e, $0e, $40, $ff, $02, $10, $84, $20, $88, $00, $20, $0a, $e0, $04, $50, $04
	db $00, $54, $00, $ff, $ff, $ff, $00, $ba, $00, $5e, $00, $ff, $80, $95, $c1, $89
	db $a1, $09, $01, $d7, $45, $01, $55, $00, $00, $22, $00, $00, $80, $00, $10, $81
	db $91, $81, $91, $81, $80, $a1, $d1, $89, $a5, $01, $55, $ab, $54, $ab, $55, $ff
	db $00, $42, $02, $02, $db, $18, $50, $00, $40, $00, $40, $00, $03, $10, $b1, $8b
	db $f8, $00, $81, $a9, $10, $a9, $81, $ff, $80, $88, $10, $80, $88, $80, $94, $80
	db $d1, $80, $c1, $08, $00, $18, $c0, $c7, $d7, $ff, $00, $a0, $08, $a0, $00, $ff
	db $c3, $d3, $18, $c3, $ff, $ff, $81, $91, $20, $81, $81, $81, $e0, $fe, $f8, $f0
	db $00, $00, $00, $00, $bc, $3c, $40, $40, $f0, $e2, $e8, $e0, $f0, $ff, $c0, $d4
	db $00, $01, $83, $c7, $c7, $81, $70, $05, $11, $01, $e1, $e9, $20, $01, $01, $01
	db $92, $00, $00, $00, $93, $91, $00, $00, $00, $00, $00, $00, $90, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $95, $00, $94, $94, $00, $95, $00, $97, $00, $00
	db $00, $96, $98, $00, $99, $00, $9c, $9c, $9c, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $97, $00, $00, $00, $98, $96, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $92, $00, $00, $00, $00, $00, $00, $94, $00, $00, $9e
	db $00, $00, $00, $00, $00, $00, $94, $00, $00, $00, $97, $98, $00, $00, $00, $9e
	db $00, $00, $39, $1f, $1f, $20, $00, $00, $00, $20, $00, $00, $00, $00, $20, $00
	db $00, $00, $00, $00, $12, $00, $00, $10, $1f, $00, $00, $12, $00, $00, $1f, $10
	db $00, $00, $10, $10, $10, $00, $10, $10, $10, $10, $00, $10, $10, $10, $10, $10
	db $10, $10, $00, $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $38
	db $10, $10, $10, $00, $00, $00, $00, $00, $00, $00, $00, $11, $40, $11, $11, $00
	db $00, $36, $00, $00, $36, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $99, $96, $00, $10, $00, $98, $97, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $9d, $2e, $00, $00, $9b, $00, $00, $92, $92, $00
	db $00, $96, $2f, $99, $00, $00, $91, $93, $00, $9c, $1f, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $96, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $96, $1f, $9e, $97, $1f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $10, $00, $00, $98, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $12
	db $00, $9c, $00, $00, $00, $00, $00, $00, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $2f, $a0, $a0, $a0, $a0, $a0, $00, $00, $00, $00
	db $00, $00, $00, $00, $10, $00, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $12, $a0, $a0
	db $a0, $1f, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $00, $00, $00, $00, $00, $00, $00
	db $00, $a0, $a0, $a0, $a0, $9e, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $a0, $00, $98, $a0, $96, $94, $00, $9e, $00, $00, $a0
	db $a0, $a0, $00, $a0, $a0, $a0, $20, $00, $9b, $00, $00, $00, $0d, $05, $11, $07
	db $0e, $06, $15, $40, $10, $50, $12, $40, $50, $50, $15, $40, $02, $a0, $00, $02
	db $20, $00, $00, $a0, $00, $12, $24, $00, $00, $a0, $00, $02, $20, $00, $02, $a0
	db $00, $00, $00, $05, $08, $02, $00, $00, $80, $45, $08, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $a0, $00, $10, $a1, $00, $00, $02, $00, $00, $00, $00, $00
	db $10, $00, $00, $00, $99, $10, $a1, $95, $10, $01, $98, $10, $00, $00, $00, $10
	db $00, $99, $96, $02, $98, $96, $a1, $98, $97, $01, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ asset: tiles bpp=2 length=$400
;@ The title screen's graphics: the KWIRK logo, the copyright line and the characters (64 tiles).
TitleTiles::
	db $3c, $00, $42, $00, $9d, $00, $a1, $00, $a1
	db $00, $9d, $00, $42, $00, $3c, $00, $00, $00, $09, $00, $1a, $00, $0a, $00, $09
	db $00, $08, $00, $09, $00, $00, $00, $00, $00, $8c, $00, $52, $00, $4c, $00, $d2
	db $00, $52, $00, $8c, $00, $00, $00, $00, $00, $60, $00, $90, $00, $90, $00, $70
	db $00, $10, $00, $60, $00, $00, $00, $00, $00, $00, $00, $00, $00, $42, $00, $42
	db $00, $42, $00, $42, $00, $7a, $00, $00, $00, $00, $00, $00, $00, $67, $00, $94
	db $00, $87, $00, $94, $00, $67, $00, $00, $00, $00, $00, $00, $00, $a4, $00, $35
	db $00, $ac, $00, $24, $00, $a5, $00, $00, $00, $00, $00, $00, $00, $ef, $00, $08
	db $00, $cf, $00, $28, $00, $cf, $00, $00, $00, $00, $00, $00, $00, $70, $00, $48
	db $00, $48, $00, $48, $00, $70, $00, $00, $00, $00, $00, $00, $00, $e4, $00, $92
	db $00, $e1, $00, $91, $00, $e1, $00, $00, $00, $00, $00, $00, $00, $44, $00, $86
	db $00, $05, $00, $04, $00, $04, $00, $00, $00, $00, $00, $00, $00, $a9, $00, $ad
	db $00, $ab, $00, $a9, $00, $a9, $00, $00, $00, $00, $00, $00, $00, $7d, $00, $11
	db $00, $11, $00, $11, $00, $11, $00, $00, $00, $00, $00, $00, $00, $e9, $00, $0d
	db $00, $eb, $00, $09, $00, $e9, $00, $00, $00, $00, $00, $00, $00, $71, $00, $4a
	db $00, $4a, $00, $4a, $00, $71, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40
	db $00, $40, $00, $40, $00, $80, $00, $00, $00, $01, $00, $03, $01, $03, $01, $03
	db $01, $03, $01, $03, $01, $03, $01, $f0, $00, $f8, $f0, $9c, $98, $0c, $78, $0d
	db $78, $0f, $79, $0e, $7a, $0c, $7d, $1e, $00, $3f, $1e, $63, $23, $c1, $5f, $81
	db $bf, $03, $7e, $06, $fc, $0c, $f8, $07, $00, $0f, $07, $9c, $0c, $98, $0b, $98
	db $0b, $18, $0b, $18, $0b, $0c, $05, $80, $00, $c0, $80, $e0, $c0, $60, $c0, $60
	db $c0, $63, $c0, $37, $e3, $37, $e3, $07, $00, $0f, $07, $1c, $0c, $18, $0b, $18
	db $0b, $18, $0b, $b0, $17, $b0, $17, $81, $00, $c3, $81, $e7, $c3, $66, $c2, $66
	db $c2, $66, $c2, $66, $c2, $c6, $82, $e0, $00, $f0, $e0, $39, $30, $19, $f0, $19
	db $f0, $19, $f0, $19, $f0, $19, $f0, $7f, $00, $ff, $7f, $c0, $c0, $80, $bf, $80
	db $bf, $87, $bf, $87, $bc, $86, $bc, $fe, $00, $ff, $fe, $03, $03, $01, $ff, $00
	db $ff, $c0, $ff, $e0, $2f, $30, $17, $03, $00, $07, $03, $8e, $06, $cc, $85, $cc
	db $85, $cc, $85, $cc, $85, $cc, $85, $c0, $00, $e0, $c0, $71, $60, $33, $e1, $36
	db $e2, $3c, $e5, $38, $eb, $10, $f7, $78, $00, $fc, $78, $8e, $8c, $06, $7c, $06
	db $fc, $0c, $f8, $18, $f0, $30, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $03, $01, $03, $01, $03, $01, $03, $01, $03
	db $01, $03, $01, $03, $01, $03, $01, $00, $7f, $00, $7f, $00, $7f, $00, $7f, $00
	db $7f, $00, $7f, $00, $7f, $0c, $7f, $18, $f0, $30, $e0, $60, $c0, $c0, $80, $60
	db $c0, $30, $e0, $18, $f0, $0c, $f8, $0c, $05, $0c, $05, $0c, $05, $0c, $05, $06
	db $02, $06, $02, $06, $02, $06, $02, $3c, $e4, $1c, $f5, $18, $fb, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $f0, $97, $e0, $af, $60, $ef, $00, $ff, $01
	db $ff, $01, $ff, $01, $ff, $01, $ff, $c6, $82, $c6, $82, $c6, $82, $c6, $82, $86
	db $02, $86, $02, $86, $02, $86, $02, $19, $f0, $19, $f0, $19, $f0, $19, $f0, $19
	db $f0, $19, $f0, $19, $f0, $19, $f0, $86, $bc, $87, $bc, $87, $bf, $80, $b8, $80
	db $bf, $80, $bf, $80, $bf, $80, $bf, $30, $17, $e0, $2f, $c1, $df, $03, $3f, $0f
	db $fe, $1e, $f0, $0c, $f8, $06, $fc, $cc, $85, $cc, $85, $cc, $85, $8c, $05, $0c
	db $05, $0c, $05, $0c, $05, $0c, $05, $00, $ff, $00, $ff, $01, $ff, $03, $fe, $01
	db $ff, $00, $ff, $00, $ff, $10, $f7, $60, $c0, $c0, $80, $80, $00, $00, $00, $80
	db $00, $c0, $80, $60, $c0, $30, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $03, $01, $03, $01, $03, $01, $03, $01, $03
	db $01, $03, $01, $01, $00, $00, $00, $0e, $7a, $0f, $79, $0d, $78, $0c, $78, $0c
	db $78, $9c, $b8, $f8, $f0, $f0, $00, $06, $fc, $03, $7e, $81, $bf, $c1, $5f, $61
	db $2f, $33, $17, $1f, $0e, $0e, $00, $06, $02, $03, $01, $83, $01, $83, $01, $83
	db $01, $83, $01, $01, $00, $00, $00, $00, $ff, $03, $7f, $07, $7c, $0c, $78, $0c
	db $78, $9c, $b8, $f8, $f0, $f0, $00, $01, $ff, $03, $fe, $83, $be, $c3, $5e, $c3
	db $5e, $e7, $66, $7e, $3c, $3c, $00, $86, $02, $06, $02, $06, $02, $06, $02, $06
	db $02, $07, $03, $03, $01, $01, $00, $19, $f0, $19, $f0, $19, $f0, $19, $f0, $19
	db $f0, $39, $70, $f0, $e0, $e0, $00, $83, $bf, $87, $bc, $86, $bc, $86, $bc, $86
	db $bc, $ce, $dc, $fc, $78, $78, $00, $03, $7e, $81, $bf, $c0, $5f, $60, $2f, $30
	db $17, $19, $09, $0f, $07, $07, $00, $0c, $05, $8c, $05, $cc, $85, $cc, $85, $cc
	db $85, $ce, $86, $87, $03, $03, $00, $38, $eb, $3c, $e5, $36, $e2, $33, $e1, $31
	db $e0, $70, $e0, $e0, $c0, $c0, $00, $18, $f0, $0c, $f8, $06, $fc, $06, $7c, $86
	db $bc, $ce, $5c, $7c, $38, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00

;@ asset: tiles bpp=2 length=$C00
;@ The game's graphics: Kwirk and friends, the blocks, turnstiles, holes and the walls (192 tiles).
GameTiles::
	db $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $01, $03, $02, $00, $00, $02, $02, $06, $06, $0f, $0f, $3e
	db $3e, $cc, $e5, $74, $81, $83, $01, $00, $00, $66, $66, $dc, $dc, $6c, $fc, $dc
	db $dc, $36, $b6, $27, $a9, $b9, $a6, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $80, $80, $c0, $40, $02, $00, $04, $00, $08, $00, $08, $00, $1f
	db $00, $20, $00, $43, $00, $5b, $00, $01, $00, $00, $00, $00, $00, $00, $00, $ff
	db $00, $00, $00, $ff, $00, $3f, $40, $e0, $1b, $00, $00, $00, $00, $00, $00, $ff
	db $00, $00, $00, $3f, $00, $33, $04, $40, $80, $20, $c0, $10, $60, $10, $20, $f8
	db $00, $04, $00, $e4, $00, $e8, $00, $2b, $00, $25, $00, $22, $00, $21, $00, $10
	db $00, $10, $00, $10, $00, $08, $04, $3e, $40, $9e, $20, $fd, $00, $02, $00, $fc
	db $00, $00, $00, $00, $00, $08, $00, $d3, $04, $a9, $02, $17, $00, $08, $00, $07
	db $00, $e0, $00, $00, $00, $00, $00, $ec, $00, $d4, $08, $a4, $18, $44, $38, $88
	db $70, $08, $30, $08, $30, $10, $20, $08, $04, $04, $02, $02, $01, $01, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $06, $00, $01, $00, $00, $80, $80, $70, $70
	db $0f, $4f, $30, $e8, $10, $18, $00, $08, $00, $f0, $00, $00, $01, $01, $0e, $0e
	db $f0, $f4, $08, $2e, $10, $71, $00, $10, $60, $20, $c0, $40, $80, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $01, $00, $02, $01, $0d, $00, $10, $01, $30
	db $00, $20, $00, $3f, $1f, $1f, $00, $24, $00, $64, $90, $d4, $20, $24, $c0, $1c
	db $68, $1c, $20, $f8, $e0, $f0, $00, $51, $00, $49, $06, $42, $05, $61, $20, $62
	db $21, $3c, $1a, $1f, $07, $0f, $00, $00, $00, $c0, $00, $70, $80, $88, $40, $04
	db $80, $04, $00, $fc, $f8, $f8, $00, $ff, $c0, $ff, $bf, $e0, $7f, $c0, $60, $c0
	db $6f, $c3, $6f, $c7, $6e, $c6, $6c, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $00
	db $ff, $ff, $ff, $ff, $00, $00, $00, $ff, $03, $ff, $fd, $07, $fe, $03, $06, $03
	db $f6, $c3, $f6, $e3, $76, $63, $36, $c6, $6c, $c6, $6c, $c6, $6c, $c6, $6c, $c6
	db $6c, $c6, $6c, $c6, $6c, $c6, $6c, $63, $36, $63, $36, $63, $36, $63, $36, $63
	db $36, $63, $36, $63, $36, $63, $36, $c6, $6c, $c7, $6e, $c3, $6f, $c0, $6f, $c0
	db $60, $e0, $7f, $ff, $bf, $ff, $c0, $00, $00, $ff, $00, $ff, $ff, $00, $ff, $00
	db $00, $00, $ff, $ff, $ff, $ff, $00, $63, $36, $e3, $76, $c3, $f6, $03, $f6, $03
	db $06, $07, $fe, $ff, $fd, $ff, $03, $63, $36, $63, $37, $60, $37, $60, $30, $60
	db $3f, $7f, $3f, $3f, $00, $00, $00, $00, $00, $3f, $00, $7f, $3f, $60, $3f, $60
	db $30, $60, $37, $63, $37, $63, $36, $c6, $6c, $c6, $ec, $06, $ec, $06, $0c, $06
	db $fc, $fe, $fc, $fc, $00, $00, $00, $00, $00, $fc, $00, $fe, $fc, $06, $fc, $06
	db $0c, $06, $ec, $c6, $ec, $c6, $6c, $00, $00, $00, $00, $02, $00, $05, $02, $0a
	db $05, $16, $09, $21, $00, $40, $00, $00, $00, $00, $00, $80, $00, $60, $80, $50
	db $a0, $68, $90, $84, $00, $02, $00, $00, $00, $02, $00, $05, $02, $0a, $05, $16
	db $09, $21, $00, $40, $00, $40, $00, $00, $00, $80, $00, $60, $80, $50, $a0, $68
	db $90, $84, $00, $02, $00, $02, $00, $7c, $07, $0f, $00, $1e, $04, $25, $04, $41
	db $00, $3e, $00, $00, $00, $00, $00, $3e, $e0, $f0, $00, $78, $20, $a4, $20, $82
	db $00, $7c, $00, $00, $00, $00, $00, $00, $00, $07, $00, $08, $07, $30, $0d, $40
	db $35, $40, $2f, $80, $7f, $83, $7c, $30, $00, $c8, $00, $88, $00, $8e, $00, $71
	db $00, $11, $e0, $53, $a0, $ad, $12, $00, $00, $07, $00, $08, $07, $30, $0d, $40
	db $35, $40, $2f, $80, $7f, $83, $7c, $30, $00, $c8, $00, $88, $00, $8e, $00, $71
	db $00, $11, $e0, $53, $a0, $ad, $12, $7c, $07, $0f, $00, $0e, $04, $15, $04, $21
	db $00, $1e, $00, $00, $00, $00, $00, $3e, $e0, $f0, $00, $70, $20, $a8, $20, $84
	db $00, $78, $00, $00, $00, $00, $00, $00, $00, $02, $00, $05, $02, $0a, $05, $16
	db $09, $11, $00, $20, $00, $2a, $00, $00, $00, $80, $00, $60, $80, $50, $a0, $68
	db $90, $88, $00, $04, $00, $54, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $40, $00, $7f, $00, $4e, $00, $ee, $00, $90
	db $00, $90, $00, $b3, $40, $88, $00, $02, $00, $fe, $00, $72, $00, $76, $00, $09
	db $00, $09, $00, $cd, $02, $11, $00, $7f, $00, $6e, $00, $9e, $00, $90, $00, $b3
	db $00, $5a, $20, $29, $00, $1c, $00, $fe, $00, $76, $00, $79, $00, $09, $00, $cd
	db $00, $5a, $04, $94, $00, $38, $00, $0f, $04, $0e, $04, $1e, $04, $25, $04, $41
	db $00, $3e, $00, $00, $00, $00, $00, $f0, $20, $70, $20, $78, $20, $a4, $20, $82
	db $00, $7c, $00, $00, $00, $00, $00, $9c, $60, $a0, $40, $4c, $00, $52, $00, $40
	db $00, $22, $00, $21, $00, $50, $20, $19, $06, $05, $02, $32, $00, $4a, $00, $05
	db $00, $49, $00, $8a, $04, $14, $08, $9c, $60, $a0, $40, $4c, $00, $52, $00, $40
	db $00, $23, $00, $22, $00, $51, $20, $19, $06, $05, $02, $32, $00, $4e, $00, $0a
	db $00, $d2, $00, $4a, $04, $8c, $00, $42, $0c, $81, $06, $7e, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $42, $30, $81, $60, $7e, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $24, $00, $2a, $00, $40, $00, $91, $00, $aa
	db $11, $44, $2a, $20, $00, $3c, $03, $24, $00, $54, $00, $02, $00, $11, $00, $a9
	db $10, $46, $a8, $04, $00, $3c, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $78, $00, $84
	db $78, $78, $00, $78, $30, $c8, $30, $03, $00, $0c, $00, $33, $00, $4f, $03, $3f
	db $0f, $1c, $0f, $17, $08, $14, $0b, $3e, $08, $ff, $3e, $f0, $ff, $c0, $ff, $00
	db $ff, $0f, $f0, $c9, $32, $49, $b4, $68, $10, $98, $00, $66, $80, $19, $e0, $06
	db $f8, $e4, $18, $24, $58, $24, $98, $14, $0a, $14, $0a, $14, $0a, $14, $0a, $14
	db $0a, $14, $0a, $14, $0a, $1f, $00, $4f, $30, $49, $32, $49, $34, $4f, $30, $40
	db $3f, $40, $3f, $40, $3f, $ff, $00, $e4, $18, $24, $58, $24, $98, $e4, $18, $04
	db $f8, $04, $f8, $04, $f8, $fc, $00, $00, $00, $03, $00, $05, $03, $07, $03, $07
	db $03, $03, $01, $01, $00, $00, $00, $00, $00, $60, $00, $d0, $60, $f0, $e0, $f0
	db $e0, $e0, $c0, $c0, $80, $80, $00, $03, $00, $04, $00, $09, $00, $0a, $00, $08
	db $00, $07, $00, $00, $00, $00, $00, $80, $00, $40, $00, $20, $00, $a0, $00, $a0
	db $00, $20, $00, $40, $00, $00, $00, $ac, $40, $95, $62, $55, $00, $25, $00, $09
	db $00, $11, $0e, $0f, $00, $00, $00, $38, $00, $a0, $40, $a0, $00, $a0, $00, $90
	db $00, $88, $70, $70, $00, $00, $00, $ac, $40, $95, $62, $55, $00, $25, $00, $09
	db $00, $11, $0e, $0f, $00, $00, $00, $38, $00, $a0, $40, $a0, $00, $a0, $00, $90
	db $00, $88, $70, $70, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $08, $00, $36, $00, $c9, $00, $18, $18, $3c, $00, $42, $3c, $81, $7e, $ff
	db $00, $e7, $18, $81, $7e, $5a, $24, $00, $00, $3c, $00, $46, $3c, $83, $7e, $ff
	db $02, $e3, $1e, $87, $7e, $86, $7c, $00, $00, $3c, $00, $42, $3c, $83, $7e, $83
	db $7e, $83, $7e, $83, $7e, $46, $3c, $06, $00, $0b, $06, $3b, $0e, $73, $3e, $e7
	db $5a, $a7, $5a, $c3, $7e, $7e, $3c, $06, $00, $0b, $06, $33, $0e, $43, $3e, $a3
	db $5e, $a7, $5e, $cf, $7e, $fe, $7c, $06, $00, $0b, $06, $33, $0e, $43, $3e, $83
	db $7e, $87, $7e, $cf, $7e, $7e, $3c, $00, $00, $5a, $00, $b7, $5a, $af, $7e, $b7
	db $5a, $af, $5a, $97, $7e, $cf, $7e, $00, $00, $5a, $00, $b7, $5a, $af, $7e, $b7
	db $5e, $af, $5e, $97, $7e, $ce, $7c, $00, $00, $5a, $00, $b7, $5a, $af, $7e, $b7
	db $7e, $af, $7e, $97, $7e, $4e, $3c, $54, $00, $7c, $00, $ae, $54, $86, $7c, $ae
	db $54, $ae, $54, $44, $38, $5c, $28, $54, $00, $7c, $00, $ae, $54, $86, $7c, $a6
	db $5c, $a6, $5c, $46, $3c, $4c, $38, $54, $00, $7c, $00, $ae, $54, $86, $7c, $8e
	db $7c, $8e, $7c, $4c, $38, $4c, $38, $26, $18, $79, $06, $96, $60, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $7c, $38, $7e, $00, $95, $62, $62, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $7c, $38, $3c, $00, $24, $18, $18, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $3c, $00, $56, $3c, $c3, $7e, $ff, $00, $e7
	db $18, $c3, $7e, $5a, $24, $3c, $00, $06, $00, $0b, $06, $3b, $0e, $73, $3e, $e7
	db $5a, $a7, $5a, $42, $3c, $3c, $00, $5a, $00, $b7, $5a, $af, $7e, $b7, $5a, $af
	db $5a, $97, $7e, $4e, $3c, $3c, $00, $54, $00, $fe, $54, $d6, $7c, $ae, $54, $ae
	db $54, $44, $38, $5c, $28, $38, $00, $00, $ff, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $00, $ff, $00, $ff, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $00, $ff, $00, $ff, $7f, $80, $40, $bf, $40, $bf, $40
	db $bf, $40, $bf, $7f, $80, $00, $ff, $00, $ff, $ff, $00, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $ff, $00, $00, $ff, $00, $ff, $fe, $01, $02, $fd, $02, $fd, $02
	db $fd, $02, $fd, $fe, $01, $00, $ff, $00, $00, $00, $00, $00, $00, $ff, $00, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $00, $00, $00, $00, $00, $00, $ff, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $80, $7f, $ff, $00, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $81
	db $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $ff, $00, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $36, $00, $49, $36, $41, $1e, $41
	db $1e, $22, $0c, $14, $08, $08, $00, $04, $00, $0a, $04, $15, $0e, $2e, $1f, $5f
	db $3f, $bf, $7f, $5f, $3f, $2f, $1f, $00, $00, $00, $00, $00, $00, $81, $00, $42
	db $81, $a5, $c3, $db, $e7, $e7, $ff, $ff, $ff, $e7, $ff, $db, $e7, $a5, $c3, $a5
	db $cb, $db, $e7, $e7, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $80, $00, $40
	db $80, $a0, $c0, $d0, $e0, $e8, $f0, $f4, $f8, $e2, $fc, $d9, $e6, $a5, $c2, $a5
	db $ca, $d9, $e6, $e2, $fc, $f4, $f8, $2f, $1f, $47, $3f, $9b, $67, $25, $c3, $a5
	db $cb, $db, $e7, $e7, $ff, $ff, $ff, $2f, $1f, $47, $3f, $9b, $67, $a5, $43, $a4
	db $4b, $99, $66, $42, $3c, $3c, $00, $2f, $1f, $47, $3f, $9b, $67, $25, $c3, $a4
	db $cb, $d9, $e6, $e2, $fc, $f4, $f8, $04, $00, $0a, $04, $15, $0e, $2e, $1f, $5f
	db $3f, $bf, $7f, $df, $3f, $ef, $1f, $ef, $f0, $df, $e0, $bf, $c0, $7e, $80, $7c
	db $80, $b8, $c0, $d0, $e0, $e8, $f0, $2f, $1f, $5f, $3f, $bf, $7f, $df, $3f, $ee
	db $1f, $f5, $0e, $fb, $04, $ff, $00, $e7, $ff, $db, $e7, $bd, $c3, $7e, $81, $ff
	db $00, $ff, $00, $ff, $00, $e7, $00, $7f, $00, $3f, $00, $1f, $00, $0e, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $c3, $00, $81, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $f4, $f8, $e2, $fc, $d9, $e6, $a5, $c2, $a5
	db $ca, $d9, $e6, $e3, $fc, $f7, $f8, $ef, $f0, $df, $e0, $bf, $c0, $7e, $80, $fc
	db $00, $f8, $00, $f0, $00, $e0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $e7, $ff, $db, $e7, $a5, $c3, $24
	db $cb, $99, $66, $c3, $3c, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $3c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $e7, $ff, $db, $e7, $a5, $c3, $a4
	db $cb, $d9, $e6, $e3, $fc, $f7, $f8, $3c, $00, $42, $3c, $99, $66, $25, $c2, $a5
	db $ca, $d9, $e6, $e3, $fc, $f7, $f8, $f4, $f8, $e2, $fc, $d9, $e6, $a5, $c2, $25
	db $ca, $99, $66, $c3, $3c, $ff, $00, $2f, $1f, $47, $3f, $9b, $67, $25, $c3, $a4
	db $cb, $d9, $e6, $e3, $fc, $f7, $f8, $17, $0f, $0b, $07, $05, $03, $02, $01, $02
	db $01, $05, $03, $0b, $07, $17, $0f, $3c, $00, $42, $3c, $99, $66, $24, $c3, $a5
	db $cb, $db, $e7, $e7, $ff, $ff, $ff, $3c, $00, $42, $00, $a5, $02, $81, $02, $a5
	db $02, $99, $26, $42, $3c, $3c, $00, $00, $00, $20, $00, $30, $00, $38, $10, $3c
	db $18, $38, $10, $30, $00, $20, $00, $ff, $00, $80, $7f, $9b, $67, $a5, $5b, $bd
	db $5b, $9b, $67, $a4, $7f, $bd, $7e, $ff, $00, $01, $fe, $d9, $e6, $a5, $da, $bd
	db $da, $d9, $e6, $25, $fe, $bd, $7e, $bd, $7e, $a4, $7f, $9b, $67, $a5, $5b, $bd
	db $5b, $9b, $67, $80, $7f, $ff, $00, $bd, $7e, $25, $fe, $d9, $e6, $a5, $da, $bd
	db $da, $d9, $e6, $01, $fe, $ff, $00, $ff, $00, $81, $7e, $bd, $7e, $bd, $7e, $bd
	db $7e, $bd, $7e, $bd, $7e, $bd, $7e, $bd, $7e, $bd, $7e, $bd, $7e, $bd, $7e, $bd
	db $7e, $bd, $7e, $81, $7e, $ff, $00, $bd, $7e, $a5, $7e, $99, $66, $a5, $5a, $bd
	db $5a, $99, $66, $81, $7e, $ff, $00, $ff, $00, $81, $7e, $99, $66, $a5, $5a, $bd
	db $5a, $99, $66, $a5, $7e, $bd, $7e, $ff, $00, $01, $fe, $fd, $fe, $fd, $fe, $fd
	db $fe, $fd, $fe, $01, $fe, $ff, $00, $ff, $00, $80, $7f, $bf, $7f, $bf, $7f, $bf
	db $7f, $bf, $7f, $80, $7f, $ff, $00, $bd, $7e, $a4, $7f, $9b, $67, $a5, $5b, $bd
	db $5b, $9b, $67, $a4, $7f, $bd, $7e, $bd, $7e, $25, $fe, $d9, $e6, $a5, $da, $bd
	db $da, $d9, $e6, $25, $fe, $bd, $7e, $ff, $00, $01, $fe, $d9, $e6, $a5, $da, $bd
	db $da, $d9, $e6, $01, $fe, $ff, $00, $ff, $00, $80, $7f, $9b, $67, $a5, $5b, $bd
	db $5b, $9b, $67, $80, $7f, $ff, $00, $bd, $7e, $24, $ff, $db, $e7, $a5, $db, $bd
	db $db, $db, $e7, $24, $ff, $bd, $7e, $ff, $00, $00, $ff, $db, $e7, $a5, $db, $bd
	db $db, $db, $e7, $24, $ff, $bd, $7e, $bd, $7e, $24, $ff, $db, $e7, $a5, $db, $bd
	db $db, $db, $e7, $00, $ff, $ff, $00, $bd, $7e, $a5, $7e, $99, $66, $a5, $5a, $bd
	db $5a, $99, $66, $a5, $7e, $bd, $7e, $ff, $00, $00, $ff, $db, $e7, $a5, $db, $bd
	db $db, $db, $e7, $00, $ff, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $81, $7e, $81, $7e, $81, $7e, $81
	db $7e, $81, $7e, $81, $7e, $ff, $00, $ff, $00, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $ff, $00, $ff, $00, $01, $fe, $01, $fe, $01, $fe, $01
	db $fe, $01, $fe, $01, $fe, $ff, $00, $ff, $00, $81, $7e, $81, $7e, $81, $7e, $81
	db $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81
	db $7e, $81, $7e, $81, $7e, $ff, $00, $ff, $00, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $ff, $00, $01, $fe, $01, $fe, $01, $fe, $01
	db $fe, $01, $fe, $01, $fe, $01, $fe, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $ff, $00, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01
	db $fe, $01, $fe, $01, $fe, $ff, $00, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81
	db $7e, $81, $7e, $81, $7e, $81, $7e, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $ff, $00, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80
	db $7f, $80, $7f, $80, $7f, $80, $7f, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01
	db $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $08, $f7, $08, $f7, $fb, $f7, $ff
	db $00, $80, $7f, $80, $7f, $bf, $7f, $ff, $00, $89, $76, $89, $76, $bb, $76, $ff
	db $00, $81, $7e, $bf, $7e, $ff, $00, $ff, $00, $88, $77, $88, $77, $bb, $77, $ff
	db $00, $80, $7f, $bf, $7f, $ff, $00, $ff, $00, $88, $77, $88, $77, $bb, $77, $ff
	db $00, $80, $7f, $80, $7f, $bf, $7f, $ff, $00, $89, $76, $89, $76, $bb, $76, $ff
	db $00, $81, $7e, $81, $7e, $bf, $7e, $ff, $00, $88, $77, $88, $77, $bb, $77, $ff
	db $00, $80, $7f, $80, $7f, $bf, $7f, $ff, $00, $11, $ee, $11, $ee, $f7, $ee, $ff
	db $00, $81, $7e, $81, $7e, $bf, $7e, $ff, $00, $88, $77, $88, $77, $bb, $77, $ff
	db $00, $80, $7f, $bf, $7f, $ff, $00, $ff, $00, $11, $ee, $11, $ee, $f7, $ee, $ff
	db $00, $81, $7e, $bf, $7e, $ff, $00, $ff, $00, $08, $f7, $08, $f7, $fb, $f7, $ff
	db $00, $80, $7f, $bf, $7f, $ff, $00, $00, $00, $00, $00, $e0, $00, $b8, $40, $ae
	db $50, $aa, $54, $aa, $54, $ea, $14, $e0, $00, $b8, $40, $ae, $50, $aa, $54, $ea
	db $14, $fa, $04, $fe, $00, $fe, $00, $fa, $04, $fe, $00, $fe, $00, $fe, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $7f, $80, $47, $b8, $47, $b8, $47
	db $b8, $47, $b8, $7f, $80, $00, $ff, $00, $ff, $ff, $00, $0f, $f0, $0f, $f0, $0f
	db $f0, $0f, $f0, $ff, $00, $00, $ff, $00, $ff, $fe, $01, $1e, $e1, $1e, $e1, $1e
	db $e1, $1e, $e1, $fe, $01, $00, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00

;@ asset: tiles bpp=1 length=$400
;@ The font, 1 bit per pixel (LoadFont expands it to 2): A-Z at $00, digits from $3C, the ATLUS and ACCLAIM lettering and the frame pieces of the menus.
Font::
	db $00, $18, $24, $42, $42, $7e, $42, $42, $00
	db $7c, $42, $42, $7c, $42, $42, $7c, $00, $3c, $42, $40, $40, $40, $42, $3c, $00
	db $78, $44, $42, $42, $42, $44, $78, $00, $7e, $40, $40, $7c, $40, $40, $7e, $00
	db $7e, $40, $40, $7c, $40, $40, $40, $00, $3c, $42, $40, $4e, $42, $42, $3c, $00
	db $42, $42, $42, $7e, $42, $42, $42, $00, $10, $10, $10, $10, $10, $10, $10, $00
	db $7e, $08, $08, $08, $08, $48, $30, $00, $42, $44, $48, $70, $48, $44, $46, $00
	db $40, $40, $40, $40, $40, $40, $7e, $00, $42, $66, $5a, $42, $42, $42, $42, $00
	db $62, $52, $52, $4a, $4a, $46, $46, $00, $3c, $42, $42, $42, $42, $42, $3c, $00
	db $7c, $42, $42, $7c, $40, $40, $40, $00, $3c, $42, $42, $52, $4a, $34, $02, $00
	db $7c, $42, $42, $7c, $48, $44, $42, $00, $3c, $42, $40, $3c, $02, $42, $3c, $00
	db $3e, $08, $08, $08, $08, $08, $08, $00, $42, $42, $42, $42, $42, $42, $3c, $00
	db $42, $42, $42, $42, $24, $24, $18, $00, $42, $42, $42, $42, $5a, $66, $42, $00
	db $42, $42, $24, $18, $24, $42, $42, $00, $44, $44, $28, $10, $10, $10, $10, $00
	db $7e, $02, $04, $18, $20, $40, $7e, $00, $7d, $11, $11, $11, $11, $11, $00, $00
	db $45, $6d, $55, $45, $45, $45, $00, $00, $f0, $00, $f0, $00, $00, $f0, $00, $00
	db $00, $14, $3e, $14, $3e, $14, $00, $04, $04, $08, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $7e, $00, $00, $00, $00, $10, $10, $10, $10, $10, $00, $10, $00
	db $38, $44, $44, $18, $10, $00, $10, $00, $0d, $0c, $14, $14, $24, $24, $44, $00
	db $f4, $44, $44, $44, $44, $44, $47, $00, $22, $22, $22, $22, $22, $22, $9a, $00
	db $70, $80, $80, $70, $08, $08, $f0, $00, $47, $41, $41, $41, $41, $41, $79, $00
	db $de, $11, $11, $11, $11, $11, $1e, $00, $00, $1f, $04, $04, $04, $04, $00, $00
	db $00, $44, $6c, $54, $54, $44, $00, $00, $7d, $11, $11, $11, $11, $11, $00, $00
	db $10, $b1, $50, $51, $11, $10, $00, $00, $c0, $20, $c0, $28, $30, $c8, $00, $3c
	db $42, $9d, $a1, $a1, $9d, $42, $3c, $06, $09, $09, $09, $0f, $09, $09, $00, $31
	db $4a, $4a, $42, $42, $4a, $31, $00, $90, $50, $50, $10, $10, $50, $9e, $00, $65
	db $95, $95, $95, $f5, $95, $95, $00, $10, $b0, $50, $10, $10, $10, $10, $00, $f4
	db $84, $86, $f7, $85, $84, $f4, $00, $be, $88, $88, $88, $88, $89, $89, $02, $12
	db $12, $13, $13, $12, $12, $12, $00, $4c, $52, $52, $d0, $d0, $52, $4c, $00, $00
	db $00, $00, $00, $00, $00, $00, $40, $00, $09, $1a, $0a, $09, $08, $09, $00, $00
	db $8c, $52, $52, $ce, $42, $8c, $00, $00, $60, $90, $90, $90, $90, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $3c, $42, $42, $42, $42, $42, $3c, $00
	db $10, $30, $10, $10, $10, $10, $38, $00, $3c, $42, $02, $0c, $30, $40, $7e, $00
	db $3c, $42, $02, $3c, $02, $42, $3c, $00, $0c, $14, $24, $44, $7e, $04, $04, $00
	db $7e, $40, $40, $7c, $02, $42, $3c, $00, $3c, $42, $40, $7c, $42, $42, $3c, $00
	db $7e, $42, $04, $08, $10, $10, $10, $00, $3c, $42, $42, $3c, $42, $42, $3c, $00
	db $3c, $42, $42, $3e, $02, $42, $3c, $00, $00, $00, $18, $18, $00, $00, $00, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $00
	db $00, $00, $00, $00, $00, $00, $00, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $00, $00, $00, $0b, $17, $27, $6d, $cd, $00
	db $00, $00, $86, $8d, $8d, $9b, $9b, $00, $00, $00, $d8, $98, $98, $18, $19, $00
	db $00, $00, $03, $03, $00, $db, $fb, $00, $00, $00, $00, $00, $00, $64, $6e, $00
	db $00, $00, $00, $00, $00, $20, $70, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $00, $00, $18, $00, $00, $00, $18, $00, $01
	db $03, $07, $0f, $1e, $3e, $7c, $ff, $99, $99, $3f, $3f, $61, $61, $00, $ff, $b6
	db $b6, $9b, $8d, $8d, $86, $00, $ff, $1b, $1b, $1b, $9b, $9b, $d9, $00, $ff, $fb
	db $9b, $1b, $9b, $fb, $db, $00, $ff, $7f, $73, $63, $63, $63, $63, $00, $ff, $f8
	db $98, $18, $18, $18, $18, $00, $f8, $81, $42, $24, $18, $18, $24, $42, $81, $81
	db $42, $24, $18, $18, $24, $42, $81, $ff, $81, $81, $81, $81, $81, $81, $81, $ff
	db $01, $01, $01, $01, $01, $01, $ff, $01, $01, $01, $01, $01, $01, $01, $01, $ff
	db $00, $00, $00, $00, $00, $00, $ff, $80, $80, $80, $80, $80, $80, $80, $ff, $00
	db $00, $00, $00, $00, $00, $00, $ff, $81, $81, $81, $81, $81, $81, $81, $81, $00
	db $00, $00, $00, $ff, $80, $80, $80, $00, $00, $00, $00, $ff, $00, $00, $00, $00
	db $00, $00, $00, $ff, $81, $81, $81, $ff, $81, $81, $81, $81, $81, $81, $ff, $ff
	db $ff, $ff, $ff, $ff, $81, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $00
	db $00, $00, $00, $ff, $01, $ff, $ff, $00, $00, $00, $00, $ff, $80, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $80, $ff, $ff, $ff
	db $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $81, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $ff, $00, $ff, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00

;@ def DemoSerialListen()
;@ path: link/serial
;@ SerialListen, but only while the demo plays.
;@ reads: wDemo
;@ sig: a30df9e3
DemoSerialListen::
;> if not wDemo: return
	ld a, [wDemo]
	and a
	ret z
;> return SerialListen()                        # falls through

;@ def SerialListen()
;@ path: link/serial
;@ Waits for a byte from the link partner (external clock, transfer on).
;@ writes: wTitleOfferOff
;@ sig: 54f1d150
SerialListen::
;> wTitleOfferOff = 0
	xor a
	ld [wTitleOfferOff], a
;> rSC = (rSC & ~0x01) | 0x80
	ld hl, $ff02
	res 0, [hl]
	set 7, [hl]
;> return
	ret


;@ def SerialStop()
;@ path: link/serial
;@ Stops listening: no transfer, internal clock.
;@ writes: wTitleOfferOff
;@ sig: 6e08bb91
SerialStop::
;> wTitleOfferOff = 1
	ld a, $01
	ld [wTitleOfferOff], a
;> rSC = (rSC & ~0x80) | 0x01
	ld hl, $ff02
	res 7, [hl]
	set 0, [hl]
;> return
	ret


;@ def StartDemo()
;@ path: title/demo
;@ Starts the next of the five demo rooms, played as HEADING OUT? by the
;@ inputs in DemoInputs.
;@ writes: wCourseLength, wDemo, wDemoRun, wDemoStep, wDiagonalView, wGameMode, wLinkMaster
;@ test: skip never returns
;@ sig: 617dcce8
StartDemo::
;> wDemo = 1
	ld a, $01
	ld [wDemo], a
;> wLinkMaster = 1
	ld [wLinkMaster], a
;> wDiagonalView = 1
	ld [wDiagonalView], a
;> wGameMode = 1
	ld [wGameMode], a
;> wDemoRun = 0
	xor a
	ld [wDemoRun], a
;> wDemoStep = 0
	ld [wDemoStep], a
	ld [wDemoStep + 1], a
;> wCourseLength = 5
	ld a, $05
	ld [wCourseLength], a
;> PickRoom()
	call PickRoom
;> SerialStop()
	call SerialStop
;> return NewLevel()
	jp NewLevel


	db $3e, $0a, $ea, $b9, $c2

;@ def EndDemo()
;@ path: title/demo
;@ The demo is over: back to the title screen.
;@ writes: wLinkAnswerWait, wLinkRefused, wUnusedCF3E
;@ test: skip never returns
;@ sig: da573614
EndDemo::
;> SerialListen()
	call SerialListen
;> wLinkAnswerWait = 1
	ld a, $01
	ld [wLinkAnswerWait], a
;> LinkSendFollower(0xFC)
	ld a, $fc
	call LinkSendFollower
;> wLinkRefused = 0
	xor a
	ld [wLinkRefused], a
;> wLinkAnswerWait = 0
	ld [wLinkAnswerWait], a
;> wUnusedCF3E = 0
	ld [wUnusedCF3E], a
;> ClearShadowOAM()
	call ClearShadowOAM
;> WaitVBlank()
	call WaitVBlank
;> return TitleScreenLoop()
	jp TitleScreenLoop


;@ def DemoInput()
;@ path: title/demo
;@ The demo's joypad: the next 2-bit step of DemoInputs as one d-pad
;@ direction in hJoyHeld, held for 3 frames.
;@ writes: hJoyHeld, wDemoStep
;@ reads: wDemoStep
;@ test: wDemoStep = rand(0, 0x3FF)
;@ sig: 546bbb3e
DemoInput::
;> index, pair = DivideHLByA(wDemoStep, 4)     # 4 steps a byte
	ld a, [wDemoStep]
	ld l, a
	ld a, [wDemoStep + 1]
	ld h, a
	ld a, $04
	call DivideHLByA
;> bits = mem[DemoInputs + lo(index)]
	push af
	ld a, l
	ld hl, DemoInputs
	call AddAToHL
	ld b, [hl]
	pop af

;> bits = u8(bits << 2 * pair)                 # the step in the top 2 bits
jr_000_7080:
	and a
	jr z, jr_000_708a

	sla b
	sla b
	dec a
	jr jr_000_7080

jr_000_708a:
;> hJoyHeld = {0x00: BTN_DOWN, 0x40: BTN_UP, 0x80: BTN_LEFT, 0xC0: BTN_RIGHT}[bits & 0xC0]
	ld a, b
	and $c0
	jr z, jr_000_709f

	cp $40
	jr z, jr_000_70a3

	cp $80
	jr z, jr_000_709b

	ld a, $10
	jr jr_000_70a5

jr_000_709b:
	ld a, $20
	jr jr_000_70a5

jr_000_709f:
	ld a, $80
	jr jr_000_70a5

jr_000_70a3:
	ld a, $40

jr_000_70a5:
	ldh [hJoyHeld], a
;> wDemoStep = u16(wDemoStep + 1)
	ld a, [wDemoStep]
	add $01
	ld [wDemoStep], a
	ld a, [wDemoStep + 1]
	adc $00
	ld [wDemoStep + 1], a
;> for _ in range(3): WaitVBlank()
	call WaitVBlank
	call WaitVBlank
	call WaitVBlank
;> return MoveFromJoypad()
	jp MoveFromJoypad


; The five rooms the demo plays, one per run (wDemoRun picks the next).
DemoLevels::
	db $20, $2e, $26, $34, $36

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: "YOU WIN." under the rooms of a game.
VsWinText::
	db $18, $0e, $14, $ff, $16, $08, $0d, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: "YOU LOSE." under the rooms of a game.
VsLoseText::
	db $18, $0e
	db $14, $ff, $0b, $0e, $12, $04, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: the OFF / YOU labels of the result screen.
VsOffYouText::
	db $0e, $0f, $0f, $aa, $aa, $18, $0e, $14
	db $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: "YOU LOSE." (the other side's copy).
VsLoseText2::
	db $18, $0e, $14, $ff, $0b, $0e, $12, $04, $20, $bb

;@ asset: rows tiles=LoadFont newline=$AA end=$BB blank=$FF
;@ VS MODE: "YOU WIN." (the other side's copy).
VsWinText2::
	db $18, $0e, $14, $ff, $16
	db $08, $0d, $20, $bb

; The demo's joypad: 2 bits a step from the top (00 Down, 01 Up, 10 Left, 11 Right), each held 3 frames.
DemoInputs::
	db $aa, $a2, $96, $8f, $5a, $8a, $aa, $aa, $aa, $83, $58, $08
	db $02, $0d, $62, $aa, $aa, $96, $a0, $a0, $2a, $09, $d7, $53, $5f, $d5, $aa, $82
	db $96, $a0, $aa, $96, $a2, $bd, $63, $5a, $8f, $d6, $35, $aa, $a3, $7f, $a8, $ff
	db $d6, $35, $a8, $3f, $58, $d6, $aa, $a2, $a2, $aa, $5a, $a2, $02, $a5, $7f, $02
	db $a5, $68, $00, $2a, $56, $a0, $68, $48, $60, $00, $68, $50, $61, $00, $70, $48
	db $70, $00, $70, $50, $71, $00, $78, $48, $64, $00, $78, $50, $65, $00, $68, $48
	db $62, $00, $68, $50, $63, $00, $70, $48, $72, $00, $70, $50, $73, $00, $78, $48
	db $74, $00, $78, $50, $75, $00, $68, $58, $66, $00, $68, $60, $67, $00, $70, $58
	db $76, $00, $70, $60, $77, $00, $78, $58, $6a, $00, $78, $60, $6b, $00, $68, $58
	db $68, $00, $68, $60, $69, $00, $70, $58, $78, $00, $70, $60, $79, $00, $78, $58
	db $74, $00, $78, $60, $75, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;@ def InitSound()
;@ path: sound/engine
;@ Sound on, all four voices silent (volume 0, restarted), both outputs at full
;@ volume, no voice routed to an output yet, and all 8 channels of the engine stopped.
;@ sig: 21676462
InitSound::
;> rNR52 = 0x80
;> rNR30 = 0x80
	ld a, $80
	ldh [rNR52], a
	ldh [rNR30], a
;> rNR12 = 0x08                                 # volume 0 (the DAC stays on)
;> rNR22 = 0x08
;> rNR32 = 0x08
;> rNR42 = 0x08
	swap a
	ldh [rNR12], a
	ldh [rNR22], a
	ldh [rNR32], a
	ldh [rNR42], a
;> rNR14 = 0x80                                 # restart
;> rNR24 = 0x80
;> rNR34 = 0x80
;> rNR44 = 0x80
	swap a
	ldh [rNR14], a
	ldh [rNR24], a
	ldh [rNR34], a
	ldh [rNR44], a
;> rNR50 = 0x77
	ld a, $77
	ldh [rNR50], a
;> rNR51 = 0
	xor a
	ldh [rNR51], a
;> for ch in range(8):
;>     mem[wSoundChannels + 16 * ch] = 0        # flags: not playing
	ld de, $0010
	ld hl, wSoundChannels
	ld b, $08

jr_000_71d8:
	ld [hl], a
	add hl, de
	dec b
	jr nz, jr_000_71d8

;> return
	ret


;@ def StartQueuedSound()
;@ path: sound/engine
;@ Starts the sound queued last (one per frame): every channel its header in
;@ Sounds names starts reading its stream from the top. A sound effect channel (4-7)
;@ marks the music channel of the same voice (channel - 4) as held by the effect.
;@ test: wSoundQueueCount = rand(0, 2)
;@ test: mem[0xDF81] = rand(0, 20); mem[0xDF82] = rand(0, 20)
;@ sig: 13f3f86a
StartQueuedSound::
;> count = wSoundQueueCount
;> if not count: return
	ld hl, wSoundQueueCount
	ld a, [hl]
	and a
	ret z

;> wSoundQueueCount = count - 1
	dec a
	ld [hl], a
;> sound = mem[0xDF00 | u8(0x80 + count)]       # wSoundQueue[count - 1]: the last one queued
	inc a
	add l
	ld l, a
	ld a, [hl]
;> header = mem16[Sounds + u8(2 * sound)]
	add a
	ld de, Sounds
	ld h, $00
	ld l, a
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
;> while mem[header] != 0xFF:
	ld h, $df
	ld b, $df

jr_000_71f9:
	ld a, [de]
	inc a
	ret z

;>     ch = mem[header]
;>     slot = 0xDF00 | u8(ch << 4 | ch >> 4)    # wSoundChannels + 16 * ch
	dec a
	swap a
	ld l, a
;>     if lo(slot) >= 0x40:
	cp $40
	jr c, jr_000_720b

;>         mem[slot - 0x40] |= 0x80             # the music channel of this voice: held by the effect
	sub $40
	ld c, a
	ld a, [bc]
	or $80
	ld [bc], a

jr_000_720b:
;>     mem[slot] = mem[slot] & 0x81 | 0x01      # playing (the held flag stays)
	set 0, [hl]
	ld a, $81
	and [hl]
	ld [hl], a
;>     mem[slot + 1] = 1                        # the first event comes next frame
	inc l
	ld [hl], $01
;>     mem[slot + 5] = 0                        # volume drop
;>     mem[slot + 6] = 0                        # pitch offset
;>     mem[slot + 7] = 0                        # transpose
	xor a
	set 2, l
	ld [hl], a
	inc l
	ld [hl], a
	inc l
	ld [hl], a
	inc l
;>     mem16[slot + 8] = mem16[header + 1]      # stream pointer (the byte before the stream)
	inc de
	ld a, [de]
	ld [hl], a
	inc l
	inc de
	ld a, [de]
	ld [hl], a
;>     header += 3
	inc de
	jr jr_000_71f9

;@ def UpdateSound()
;@ path: sound/engine
;@ The sound engine's frame (from the VBlank handler): every playing channel, 7 down to
;@ 0, counts down its note and envelope and reads its stream when the note is over;
;@ then StartQueuedSound.
;@ test: play('sfx', rand(1, 19), rand(0, 400))
;@ sig: 19583d4b
UpdateSound::
;> ch = 8
	ld b, $08
;> return SoundNextChannel(ch)                  # falls through

;@ def SoundNextChannel(ch: b)
;@ path: sound/engine
;@ The channel below ch next (h = the page of the channels).
;@ test: play('sfx', rand(1, 19), rand(0, 400))
;@ test: ch = rand(1, 8)
;@ sig: 946b5e9e
SoundNextChannel::
jr_000_7229:
;> return SoundChannelLoop(ch, 0xDF00)          # falls through
	ld h, $df

;@ def SoundChannelLoop(ch: b, chan: hl)
;@ writes: wSoundChannel
;@ path: sound/engine
;@ The channel loop of UpdateSound (h = $DF, the page of the channels): for every
;@ playing channel below ch the note timer counts down; while the note lasts the
;@ envelope timer does, and at its end the next step of the envelope sets the volume
;@ (minus the channel's volume drop) and restarts the note with it, unless an effect
;@ holds the voice. The first channel whose note is over reads its stream
;@ (ReadSoundEvent); after channel 0, StartQueuedSound.
;@ test: s = rand(0, 1); play('sfx', [1, 2, 3, 5][rand(0, 3)] if s else rand(8, 19), rand(1, 150) if s else rand(1, 3))
;@ test: ch = rand(1, 8); chan = 0xDF00
;@ sig: ec28d51e
SoundChannelLoop::
jr_000_722b:
;> while True:
;>     ch = u8(ch - 1)
;>     if ch & 0x80: return StartQueuedSound()
	dec b
	bit 7, b
	jp nz, StartQueuedSound

;>     slot = 0xDF00 | u8(ch << 4 | ch >> 4)    # wSoundChannels + 16 * ch
	ld l, b
	swap l
;>     if not mem[slot] & 0x01: continue        # not playing
	ld a, [hl]
	bit 0, a
	jr z, jr_000_7229

;>     mem[slot + 1] = u8(mem[slot + 1] - 1)
;>     if not mem[slot + 1]: break              # the note is over
	inc l
	dec [hl]
	jr z, jr_000_727c

;>     mem[slot + 2] = u8(mem[slot + 2] - 1)
;>     if mem[slot + 2]: continue
	inc l
	dec [hl]
	jr nz, jr_000_722b

;>     env = mem16[slot + 3]                    # the envelope step: (frames, volume)
	inc l
	ld e, [hl]
	inc l
	ld d, [hl]
;>     frames = mem[u16(env + 1)]
;>     env = u16(env + 2)
;>     volume = mem[env]
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
;>     volume = max(volume - mem[slot + 5], 0)  # minus the volume drop
	inc l
	sub [hl]
	jr nc, jr_000_724f

	xor a

jr_000_724f:
;>     mem16[slot + 3] = env
;>     mem[slot + 2] = frames
	dec l
	ld [hl], d
	dec l
	ld [hl], e
	dec l
	ld [hl], c
;>     mem[0xDF00 | u8(0x8F + wSoundChannel)] = volume   # wChannelVolume[wSoundChannel] (the channel read last)
	ld c, a
	ld de, wChannelVolume
	ld a, [wSoundChannel]
	add e
	ld e, a
	ld a, c
	ld [de], a
;>     if mem[slot] & 0x80: continue            # an effect holds the voice
	dec l
	dec l
	bit 7, [hl]
	jr nz, jr_000_722b

;>     regs = ChannelRegs + 2 * ch
;>     mem[0xFF00 | mem[regs]] = volume         # rNRx2
;>     mem[0xFF00 | mem[regs + 1]] = mem[slot + 13]   # rNRx4: restart the note
	push hl
	ld hl, ChannelRegs
	ld a, b
	add a
	add l
	ld l, a
	ld a, c
	ld c, [hl]
	ldh [c], a
	inc hl
	ld c, [hl]
	pop hl
	ld a, $0d
	or l
	ld l, a
	ld a, [hl]
	ldh [c], a
	jr jr_000_722b

jr_000_727c:
;> wSoundChannel = ch
	ld a, b
	ld [wSoundChannel], a
;> ptr = mem16[slot + 8]
	dec l
	set 3, l
	ld e, [hl]
	inc l
	ld d, [hl]
;> return ReadSoundEvent(slot + 9, ptr)        # falls through

;@ def ReadSoundEvent(chan: hl, ptr: de)
;@ path: sound/engine
;@ The next byte of the channel's stream (chan = the channel's byte 9).
;@ test: s = rand(0, 1); play('sfx', [1, 2, 3, 5][rand(0, 3)] if s else rand(8, 19), rand(1, 150) if s else rand(1, 3))
;@ test: c = ([k for k in range(8) if mem[0xDF00 + 16 * k] & 1] or [0])[0]
;@ test: wSoundChannel = c; chan = 0xDF09 + 16 * c; ptr = mem[0xDF08 + 16 * c] | mem[0xDF09 + 16 * c] << 8
;@ sig: 56bcae53
ReadSoundEvent::
;> return ReadSoundByte(chan, u16(ptr + 1))    # falls through
	inc de

;@ def ReadSoundByte(chan: hl, ptr: de)
;@ path: sound/engine
;@ reads: wSoundChannel
;@ One byte of a channel's stream (chan = the channel's byte 9, ptr = the byte):
;@ $00-$7F a note (number + the transpose; $54 is a rest), $80-$BF a note length
;@ from NoteLengths, $C0-$DF a pan setting, $E0-$FF a command (SoundCommands). A note
;@ ends the channel's turn: it sets the frequency, starts the envelope and, unless
;@ an effect holds the voice, plays it on the voice's registers (ChannelRegs).
;@ test: s = rand(0, 1); play('sfx', [1, 2, 3, 5][rand(0, 3)] if s else rand(8, 19), rand(1, 150) if s else rand(1, 3))
;@ test: c = ([k for k in range(8) if mem[0xDF00 + 16 * k] & 1] or [0])[0]
;@ test: wSoundChannel = c; chan = 0xDF09 + 16 * c; ptr = (mem[0xDF08 + 16 * c] | mem[0xDF09 + 16 * c] << 8) + 1
;@ sig: 31d5fd2c
ReadSoundByte::
;>@a byte = mem[ptr]
;> slot = chan - 9
;>@b if not byte & 0x80:                            # a note
;>@n     mem[slot + 1] = mem[slot + 10]             # the note timer: the note length
;>     mem16[slot + 8] = ptr
;>     if byte == 0x54:                           # a rest
;>@r         mem[slot] |= 0x02
;>         if mem[slot] & 0x80: return SoundChannelLoop(wSoundChannel, slot)
;>@r2         mask = mem[0xDF00 | u8(0x87 + wSoundChannel)]   # wChannelPan
;>         off = ~mask & 0xFF
;>         rNR51 = rNR51 & off & u8(off << 4 | off >> 4)   # the voice off both outputs
;>         return SoundNextChannel(wSoundChannel)
;>@v     if (wSoundChannel & 0x03) == 0x03: return PlayNoiseNote(slot + 8, byte)
;>@f     note = u8(byte + mem[slot + 7])            # plus the transpose
;>     freq = u16(mem16[NoteFreqs + u8(2 * note)] + mem[slot + 6])   # plus the pitch offset
;>@t     if (wSoundChannel & 0x03) != 0x02 or not rNR52 & 0x04:
;>         freq |= 0x8000                         # restart (not on the wave voice while it still plays)
;>@e     mem16[slot + 12] = freq
;>     env = mem16[slot + 14]                     # the envelope from its first step
;>     frames = mem[env]
;>     env = u16(env + 1)
;>     volume = max(mem[env] - mem[slot + 5], 0)  # minus the volume drop
;>     mem16[slot + 3] = env
;>     mem[slot + 2] = frames
;>@w     mem[0xDF00 | u8(0x8F + wSoundChannel)] = volume   # wChannelVolume
;>@h     if not mem[slot] & 0x80:                   # no effect holds the voice
;>@o         regs = 0x7F00 | u8(0xE0 + u8(2 * wSoundChannel))   # ChannelRegs + 2 * channel
;>         reg = mem[regs]
;>         mem[0xFF00 | reg] = volume             # rNRx2
;>         mem[0xFF00 | u8(reg - 1)] = mem[slot + 11]   # rNRx1: the duty
;>@pan         reg = mem[u16(regs + 1)]
;>         mask = mem[0xDF00 | u8(0x87 + wSoundChannel)]
;>         off = ~mask & 0xFF
;>         rNR51 = rNR51 & off & u8(off << 4 | off >> 4) | mask
;>@fr         mem[0xFF00 | u8(reg - 1)] = lo(freq)   # rNRx3
;>         mem[0xFF00 | reg] = hi(freq)           # rNRx4
;>@x     return SoundNextChannel(wSoundChannel)
;>@c if byte & 0x40 and byte & 0x20:                # $E0-$FF: a command
;>     return SoundCommands[byte & 0x0F](chan, ptr)
;>@l if not byte & 0x40:                            # $80-$BF: the note length
;>     mem[chan + 1] = mem[NoteLengths + (byte & 0x7F)]
;>     return ReadSoundEvent(chan, ptr)
;>@p mask = mem[0x7F00 | u8(0xF0 + (wSoundChannel & 0x03) + (byte & 0x1F))]   # $C0-$DF: PanMasks
;> mem[0xDF00 | u8(0x87 + wSoundChannel)] = mask  # wChannelPan
;> return ReadSoundEvent(chan, ptr)
;=@a
	ld a, [de]
;=@b
	bit 7, a
	jr z, jr_000_72f3

;=@c
	bit 6, a
	jr z, jr_000_72a4

	bit 5, a
	jr z, jr_000_72b5

	push hl
	ld hl, SoundCommands
	and $0f
	add a
	ld c, a
	ld b, $00
	add hl, bc
	ld b, [hl]
	inc hl
	ld h, [hl]
	ld l, b
	jp hl


;=@l
jr_000_72a4:
	push hl
	res 7, a
	ld c, a
	ld b, $00
	ld hl, NoteLengths
	add hl, bc
	ld a, [hl]
	pop hl
	inc l
	ld [hl], a
	dec l
	jr ReadSoundEvent

;=@p
jr_000_72b5:
	and $1f
	ld b, a
	ld a, [wSoundChannel]
	and $03
	add b
	push hl
	ld hl, PanMasks
	add l
	ld l, a
	ld a, [hl]
	ld hl, wChannelPan
	ld b, a
	ld a, [wSoundChannel]
	add l
	ld l, a
	ld [hl], b
	pop hl
	jr ReadSoundEvent

;=@r
jr_000_72d2:
	ld a, [wSoundChannel]
	ld b, a
	res 3, l
	set 1, [hl]
	bit 7, [hl]
	jp nz, SoundChannelLoop

;=@r2
	ld a, b
	ld hl, wChannelPan
	add l
	ld l, a
	ld a, [hl]
	cpl
	ld c, a
	ldh a, [rNR51]
	and c
	swap c
	and c
	ldh [rNR51], a
	jp SoundNextChannel


;=@n
jr_000_72f3:
	inc l
	ld c, [hl]
	res 3, l
	dec l
	ld [hl], c
	set 3, l
	ld [hl], d
	dec l
	ld [hl], e
	cp $54
	jr z, jr_000_72d2

;=@v
	ld c, a
	ld a, [wSoundChannel]
	and $03
	cp $03
	jp z, PlayNoiseNote

;=@f
	ld a, c
	dec l
	add [hl]
	ld c, l
	ld b, h
	add a
	ld e, a
	ld d, $00
	ld hl, NoteFreqs
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	dec c
	ld a, [bc]
	ld l, a
	ld h, $00
	add hl, de
;=@t
	ld a, [wSoundChannel]
	and $03
	cp $02
	jr z, jr_000_7332

jr_000_732c:
	ld a, $80
	or h
	ld h, a
	jr jr_000_7338

jr_000_7332:
	ldh a, [rNR52]
	bit 2, a
	jr z, jr_000_732c

;=@e
jr_000_7338:
	set 3, c
	dec c
	ld a, h
	ld [bc], a
	dec c
	ld a, l
	ld [bc], a
	push hl
	inc c
	ld l, c
	ld h, b
	inc c
	res 3, l
	ld a, [bc]
	ld e, a
	inc c
	ld a, [bc]
	ld d, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	sub [hl]
	jr nc, jr_000_7354

	xor a

jr_000_7354:
	dec l
	ld [hl], d
	dec l
	ld [hl], e
	dec l
	ld [hl], c
;=@w
	ld c, a
	ld de, wChannelVolume
	ld a, [wSoundChannel]
	add e
	ld e, a
	ld a, c
	ld [de], a
;=@h
	dec l
	dec l
	bit 7, [hl]
	jr nz, jr_000_73a1

;=@o
	push hl
	ld hl, ChannelRegs
	ld c, a
	ld a, [wSoundChannel]
	add a
	add l
	ld l, a
	ld a, c
	ld c, [hl]
	ldh [c], a
	dec c
	pop de
	ld a, $0b
	or e
	ld e, a
	ld a, [de]
	ldh [c], a
;=@pan
	inc hl
	ld c, [hl]
	ld hl, wChannelPan
	ld a, [wSoundChannel]
	add l
	ld l, a
	ld a, [hl]
	ld b, a
	cpl
	ld e, a
	ldh a, [rNR51]
	and e
	swap e
	and e
	or b
	ldh [rNR51], a
;=@fr
	pop hl
	dec c
	ld a, l
	ldh [c], a
	inc c
	ld a, h
	ldh [c], a
	jr jr_000_73a2

;=@h
jr_000_73a1:
	pop hl

;=@x
jr_000_73a2:
	ld a, [wSoundChannel]
	ld b, a
	jp SoundNextChannel


;@ def PlayNoiseNote(chan: hl, note: c)
;@ reads: wSoundChannel
;@ path: sound/engine
;@ A note on the noise voice (chan = the channel's byte 8): the note byte is the
;@ rNR43 setting itself. Starts the envelope and, unless an effect holds the voice,
;@ plays it. A volume drop bigger than the volume gives $08 (silent, the DAC on).
;@ test: play('sfx', 1, rand(1, 600))
;@ test: wSoundChannel = 3; chan = 0xDF38; note = rand(0, 255)
;@ sig: b0216ec1
PlayNoiseNote::
;> slot = chan - 8
;> mem[slot + 12] = note                         # the rNR43 setting
;> mem[slot + 13] = 0x80
	set 2, l
	ld [hl], c
	inc l
	ld [hl], $80
;> env = mem16[slot + 14]
	inc l
	ld e, [hl]
	inc l
	ld d, [hl]
;> mem[slot + 2] = mem[env]                      # the first step's frames
	ld a, $0d
	xor l
	ld l, a
	ld a, [de]
	ld [hl], a
;> env = u16(env + 1)
;> mem16[slot + 3] = env
	inc de
	inc l
	ld [hl], e
	inc l
	ld [hl], d
;> volume = mem[env] - mem[slot + 5] if mem[env] >= mem[slot + 5] else 0x08
	ld a, [de]
	inc l
	sub [hl]
	jr nc, jr_000_73c5

	ld a, $08

jr_000_73c5:
;> mem[0xDF00 | u8(0x8F + wSoundChannel)] = volume   # wChannelVolume
	ld b, a
	ld de, wChannelVolume
	ld a, [wSoundChannel]
	add e
	ld e, a
	ld a, b
	ld [de], a
;> if mem[slot] & 0x80: return SoundNextChannel(wSoundChannel)   # an effect holds the voice
	dec l
	res 2, l
	bit 7, [hl]
	jr nz, jr_000_73a2

;> rNR42 = volume
	ldh [rNR42], a
;> mask = mem[0xDF00 | u8(0x87 + wSoundChannel)]   # wChannelPan
;> off = ~mask & 0xFF
;> rNR51 = rNR51 & off & u8(off << 4 | off >> 4) | mask
	ld hl, wChannelPan
	ld a, [wSoundChannel]
	add l
	ld l, a
	ld a, [hl]
	ld b, a
	cpl
	ld e, a
	ldh a, [rNR51]
	and e
	swap e
	and e
	or b
	ldh [rNR51], a
;> rNR43 = note
	ld a, c
	ldh [rNR43], a
;> rNR44 = 0x80
	ld a, $80
	ldh [rNR44], a
;> return SoundNextChannel(wSoundChannel)
	jr jr_000_73a2

SoundCommands::
	dw SndCmdEnvelope, SndCmdDuty, SndCmdVolume, SndCmdTranspose, SndCmdRepeat, SndCmdRepeatEnd, SndCmdCall, SndCmdReturn
	dw SndCmdJump, SndCmdPitch, SndCmdSweep, SndCmdSweepOff, SndCmdWave, SndCmdEnd, SndCmdNop, SndCmdEnd

;@ def SndCmdNop(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $FE: nothing.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 0fbcfe85
SndCmdNop::
;> return ReadSoundEvent(chan, ptr)
	pop hl
	jp ReadSoundEvent

;@ def SndCmdEnvelope(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F0 n: the channel's notes use envelope n of Envelopes from now on.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: a1d4af90
SndCmdEnvelope::
;> ptr = u16(ptr + 1)
;> slot = chan - 9
;> mem16[slot + 14] = mem16[Envelopes + u8(2 * mem[ptr])]
	inc de
	ld a, [de]
	add a
	ld hl, Envelopes
	ld c, a
	ld b, $00
	add hl, bc
	ld c, l
	ld b, h
	pop hl
	set 2, l
	inc l
	ld a, [bc]
	ld [hl], a
	inc bc
	inc l
	ld a, [bc]
	ld [hl], a
	res 1, l
	res 2, l
;> return ReadSoundEvent(chan, ptr)
	jp ReadSoundEvent

;@ def SndCmdDuty(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F1 n: the duty (rNRx1) for the channel's notes.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 1cbebf14
SndCmdDuty::
;> ptr = u16(ptr + 1)
;> mem[chan + 2] = mem[ptr]                      # byte 11
	inc de
	ld a, [de]
	pop hl
	set 1, l
	ld [hl], a
	res 1, l
;> return ReadSoundEvent(chan, ptr)
	jp ReadSoundEvent

;@ def SndCmdVolume(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F2 n: the volume drop, taken off every envelope step.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 49d18664
SndCmdVolume::
;> ptr = u16(ptr + 1)
;> mem[chan - 4] = mem[ptr]                      # byte 5
	inc de
	pop hl
	ld a, $0c
	xor l
	ld l, a
	ld a, [de]
	ld [hl], a
	ld a, $0c
	xor l
	ld l, a
;> return ReadSoundEvent(chan, ptr)
	jp ReadSoundEvent

;@ def SndCmdTranspose(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F3 n: the transpose, added to every note number ($F4 = an octave down).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: ee194ca4
SndCmdTranspose::
;> ptr = u16(ptr + 1)
;> mem[chan - 2] = mem[ptr]                      # byte 7
	inc de
	pop hl
	dec l
	dec l
	ld a, [de]
	ld [hl], a
	inc l
	inc l
;> return ReadSoundEvent(chan, ptr)
	jp ReadSoundEvent

;@ def SndCmdRepeat(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ path: sound/engine/commands
;@ Stream command $F4 n: the part up to the next $F5 plays n times (one level per
;@ channel, in wSoundRepeat).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 21a40220
SndCmdRepeat::
;> ptr = u16(ptr + 1)
;> rep = u8(0xA7 + u8(3 * wSoundChannel))        # wSoundRepeat + 3 * channel
	inc de
	ld a, [wSoundChannel]
	ld c, a
	add a
	add c
	ld hl, wSoundRepeat
	add l
	ld l, a
;> mem[0xDF00 | rep] = mem[ptr]                  # the count
;> mem[0xDF00 | u8(rep + 1)] = lo(ptr)           # where to go back to
;> mem[0xDF00 | u8(rep + 2)] = hi(ptr)
	ld a, [de]
	ld [hl], a
	inc l
	ld [hl], e
	inc l
	ld [hl], d
;> return ReadSoundEvent(chan, ptr)
	pop hl
	jp ReadSoundEvent

;@ def SndCmdRepeatEnd(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ path: sound/engine/commands
;@ Stream command $F5: back to the $F4 until its count runs out.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: f1224621
SndCmdRepeatEnd::
;> rep = u8(0xA7 + u8(3 * wSoundChannel))        # wSoundRepeat + 3 * channel
	ld a, [wSoundChannel]
	ld c, a
	add a
	add c
	ld hl, wSoundRepeat
	add l
	ld l, a
;> mem[0xDF00 | rep] = u8(mem[0xDF00 | rep] - 1)
;> if mem[0xDF00 | rep]:
	dec [hl]
	jr z, jr_000_7485
;>     ptr = mem[0xDF00 | u8(rep + 1)] | mem[0xDF00 | u8(rep + 2)] << 8
	inc l
	ld e, [hl]
	inc l
	ld d, [hl]

jr_000_7485:
;> return ReadSoundEvent(chan, ptr)
	pop hl
	jp ReadSoundEvent

;@ def SndCmdCall(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ path: sound/engine/commands
;@ Stream command $F6 addr: plays the stream at addr up to its $F7, then goes on
;@ after the command (one level per channel, in wSoundReturn).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 98ca0fcb
SndCmdCall::
;> ret = u8(0x97 + u8(2 * wSoundChannel))        # wSoundReturn + 2 * channel
	ld a, [wSoundChannel]
	add a
	ld hl, wSoundReturn
	add l
	ld l, a
;> target = mem[u16(ptr + 1)] | mem[u16(ptr + 2)] << 8
;> back = u16(ptr + 2)
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
;> mem[0xDF00 | ret] = lo(back)
;> mem[0xDF00 | u8(ret + 1)] = hi(back)
	ld [hl], e
	ld e, c
	inc l
	ld [hl], d
	ld d, a
;> return ReadSoundByte(chan, target)
	pop hl
	jp ReadSoundByte

;@ def SndCmdReturn(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ path: sound/engine/commands
;@ Stream command $F7: the end of a part played with $F6: back after the $F6.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 89189a56
SndCmdReturn::
;> ret = u8(0x97 + u8(2 * wSoundChannel))        # wSoundReturn + 2 * channel
	ld a, [wSoundChannel]
	add a
	ld hl, wSoundReturn
	add l
	ld l, a
;> ptr = mem[0xDF00 | ret] | mem[0xDF00 | u8(ret + 1)] << 8
	ld e, [hl]
	inc l
	ld d, [hl]
;> return ReadSoundEvent(chan, ptr)
	pop hl
	jp ReadSoundEvent

;@ def SndCmdJump(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F8 addr: the stream goes on at addr (the songs loop with it).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: caff61a5
SndCmdJump::
;> target = mem[u16(ptr + 1)] | mem[u16(ptr + 2)] << 8
	inc de
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld e, c
	ld d, a
;> return ReadSoundByte(chan, target)
	pop hl
	jp ReadSoundByte

;@ def SndCmdPitch(chan: hl, ptr: de)
;@ path: sound/engine/commands
;@ Stream command $F9 n: the pitch offset, added to the frequency of every note
;@ (the effects play a voice a little sharp with it).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 4ba83f19
SndCmdPitch::
;> ptr = u16(ptr + 1)
;> mem[chan - 3] = mem[ptr]                      # byte 6
	inc de
	pop hl
	dec l
	dec l
	dec l
	ld a, [de]
	ld [hl], a
	inc l
	inc l
	inc l
;> return ReadSoundEvent(chan, ptr)
	jp ReadSoundEvent

;@ def SndCmdSweep(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ writes: wMusicSweep
;@ path: sound/engine/commands
;@ Stream command $FA n: the square 1 sweep (rNR10). For the music (channel 0) it is
;@ kept in wMusicSweep and the channel's sweep flag is set, so it comes back after
;@ an effect; it only reaches rNR10 while no effect holds the voice.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 93e07c1d
SndCmdSweep::
;> ptr = u16(ptr + 1)
;> sweep = mem[ptr]
	pop hl
	inc de
	ld a, [de]
	ld c, a
;> if wSoundChannel:
	ld a, [wSoundChannel]
	and a
	jr z, jr_000_74d8
;>     rNR10 = sweep
;>     return ReadSoundEvent(chan, ptr)
	ld a, c
	ldh [rNR10], a
	jp ReadSoundEvent

jr_000_74d8:
;> wMusicSweep = sweep
	ld a, c
	ld [wMusicSweep], a
;> slot = chan - 9
;> mem[slot] |= 0x04
;> if not mem[slot] & 0x80:
	dec l
	res 3, l
	set 2, [hl]
	bit 7, [hl]
	jp nz, jr_000_74e8
;>     rNR10 = sweep
	ldh [rNR10], a

jr_000_74e8:
;> return ReadSoundEvent(chan, ptr)
	set 3, l
	inc l
	jp ReadSoundEvent

;@ def SndCmdSweepOff(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ writes: wMusicSweep
;@ path: sound/engine/commands
;@ Stream command $FB: no sweep (for the music: the sweep flag goes off too).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 8b0e7e32
SndCmdSweepOff::
	pop hl
;> if wSoundChannel:
	ld a, [wSoundChannel]
	and a
	jr z, jr_000_74fb
;>     rNR10 = 0
;>     return ReadSoundEvent(chan, ptr)
	xor a
	ldh [rNR10], a
	jp ReadSoundEvent

jr_000_74fb:
;> wMusicSweep = 0
	xor a
	ld [wMusicSweep], a
;> slot = chan - 9
;> held = mem[slot] & 0x80
;> mem[slot] &= ~0x04
;> if not held:
	dec l
	res 3, l
	bit 7, [hl]
	res 2, [hl]
	jp nz, jr_000_750c
;>     rNR10 = 0
	xor a
	ldh [rNR10], a

jr_000_750c:
;> return ReadSoundEvent(chan, ptr)
	set 3, l
	inc l
	jp ReadSoundEvent

;@ def SndCmdWave(chan: hl, ptr: de)
;@ reads: wSoundChannel
;@ path: sound/engine/commands
;@ Stream command $FC addr: the wave voice's pattern. The music's wave channel loads
;@ it into wave RAM at once; on other channels it is only kept in wEffectWave (the
;@ wave effects play with the wave already there).
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 65d414aa
SndCmdWave::
;> wave = mem[u16(ptr + 1)] | mem[u16(ptr + 2)] << 8
;> if wSoundChannel != 2:
	ld a, [wSoundChannel]
	cp $02
	jr z, jr_000_7532
;>     wEffectWave = wave
	ld hl, wEffectWave
	inc de
	ld a, [de]
	ld [hli], a
	ld c, a
	inc de
	ld a, [de]
	ld [hl], a
	ld b, a
;>     pass                                      # (it looks at the held flag, but jumps on anyway)
	pop hl
	add sp, -2
	dec l
	res 3, l
	bit 7, [hl]
	jr jr_000_753b
	db $69, $60, $18, $06

jr_000_7532:
;> else:
;>     LoadWave(wave)
	inc de
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	ld h, a
	call LoadWave

jr_000_753b:
;> return ReadSoundEvent(chan, u16(ptr + 2))
	pop hl
	jp ReadSoundEvent

;@ def LoadWave(wave: hl) -> (hl, a)
;@ path: sound/engine
;@ Copies a 16-byte pattern into wave RAM (with the wave voice off meanwhile).
;@ reads: wSoundChannel
;@ test: wave = rand_ram(16)
;@ sig: 547b9c87
LoadWave::
;> rNR30 = 0
	xor a
	ldh [rNR30], a
;> copy(0xFF30, wave, 16)
	ld b, $10
	ld c, $30

jr_000_7546:
	ld a, [hli]
	ldh [c], a
	inc c
	dec b
	jr nz, jr_000_7546
;> rNR30 = 0x80
	ld a, $80
	ldh [rNR30], a
;> return u16(wave + 16), wSoundChannel
	ld a, [wSoundChannel]
	ret

;@ def SndCmdEnd(chan: hl, ptr: de)
;@ reads: wMusicSweep
;@ writes: wSoundChannel
;@ path: sound/engine/commands
;@ Stream commands $FD and $FF: the channel stops. A music channel silences its voice
;@ (unless an effect holds it). An effect lets go of the voice: the music channel
;@ under it, if it still plays, gets its sweep, wave, pan, volume and frequency back
;@ (and wSoundChannel is left on that music channel); if not, the voice goes silent.
;@ test: skip pops the channel pointer ReadSoundByte pushed
;@ sig: 785c3614
SndCmdEnd::
;> slot = u16(chan - 1) & 0xFFF7                 # byte 0
;> mem[slot] &= ~0x01
	pop hl
	dec hl
	res 3, l
	res 0, [hl]
;>@a ch = wSoundChannel
;> if ch < 4:
;>     if not mem[slot] & 0x80:
;>@s         regs = 0x7F00 | u8(0xE0 + u8(2 * ch))   # ChannelRegs + 2 * channel
;>         mem[0xFF00 | mem[regs]] = 0x08     # rNRx2: volume 0
;>         mem[0xFF00 | mem[u16(regs + 1)]] = 0x80   # rNRx4: restart (silent)
;>@n     return SoundNextChannel(wSoundChannel)
;>@m music = slot & 0xFFBF                       # the music channel of the voice
;> mem[music] &= ~0x80
;> if not mem[music] & 0x01:
;>@s2     regs = 0x7F00 | u8(0xE0 + u8(2 * ch))
;>     mem[0xFF00 | mem[regs]] = 0x08
;>     mem[0xFF00 | mem[u16(regs + 1)]] = 0x80
;>     return SoundNextChannel(wSoundChannel)
;>@w if ch == 4:
;>     rNR10 = wMusicSweep if mem[music] & 0x04 else 0
;=@a
	ld a, [wSoundChannel]
	cp $04
	jr nc, jr_000_757b
	bit 7, [hl]
	jr nz, jr_000_7574

;=@s
jr_000_7565:
	ld hl, ChannelRegs
	add a
	add l
	ld l, a
	ld c, [hl]
	ld a, $08
	ldh [c], a
	inc hl
	ld c, [hl]
	swap a
	ldh [c], a

;=@n
jr_000_7574:
	ld a, [wSoundChannel]
	ld b, a
	jp SoundNextChannel

;=@m
jr_000_757b:
	res 6, l
	res 7, [hl]
	bit 0, [hl]
	ld a, [wSoundChannel]
	jr z, jr_000_7565
;=@w
	cp $04
	jr nz, jr_000_7594
	xor a
	bit 2, [hl]
	jr z, jr_000_7592
	ld a, [wMusicSweep]

jr_000_7592:
	ldh [rNR10], a

jr_000_7594:
;> ch &= ~0x04
;> wSoundChannel = ch
;> volume = mem[0xDF00 | u8(0x8F + ch)]          # wChannelVolume
	ld a, [wSoundChannel]
	res 2, a
	ld [wSoundChannel], a
	ld de, wChannelVolume
	add e
	ld e, a
;> if ch == 2:
;>     LoadEffectWave()
	push hl
	ld a, [wSoundChannel]
	cp $02
	call z, LoadEffectWave
;> mask = mem[0xDF00 | u8(0x87 + ch)]            # wChannelPan
;> off = ~mask & 0xFF
;> rNR51 = rNR51 & off & u8(off << 4 | off >> 4) | mask
	ld hl, wChannelPan
	add l
	ld l, a
	ld a, [hl]
	ld b, a
	cpl
	ld c, a
	ldh a, [rNR51]
	and c
	swap c
	and c
	or b
	ldh [rNR51], a
;> regs = 0x7F00 | u8(0xE0 + u8(2 * ch))         # ChannelRegs + 2 * channel
;> reg = mem[u16(regs + 1)]
;> mem[0xFF00 | mem[regs]] = volume              # rNRx2
	ld hl, ChannelRegs
	ld a, [wSoundChannel]
	add a
	add l
	ld l, a
	ld c, [hl]
	ld a, [de]
	ldh [c], a
	inc hl
	ld c, [hl]
	dec c
;> mem[0xFF00 | u8(reg - 1)] = mem[music + 12]   # rNRx3
;> mem[0xFF00 | reg] = mem[music + 13]           # rNRx4
	pop hl
	set 2, l
	set 3, l
	ld a, [hl]
	ldh [c], a
	inc l
	inc c
	ld a, [hl]
	ldh [c], a
;> return SoundNextChannel(ch | 0x04)
	ld a, [wSoundChannel]
	set 2, a
	ld b, a
	jp SoundNextChannel

;@ def LoadEffectWave() -> (hl, a)
;@ path: sound/engine
;@ LoadWave with wEffectWave.
;@ test: wEffectWave = rand_ram(16)
;@ sig: 0d8bbe22
LoadEffectWave::
;> return LoadWave(wEffectWave)
	ld hl, wEffectWave
	ld a, [hli]
	ld h, [hl]
	ld l, a
	jp LoadWave
; Note frequencies (rNRx3/rNRx4 values), one per note number: note 0 is C2 (65 Hz).
NoteFreqs::
	dw $002c, $009d, $0107, $016b, $01c9, $0223, $0277, $02c7
	dw $0312, $0358, $039b, $03da, $0416, $044e, $0483, $04b5
	dw $04e5, $0511, $053b, $0563, $0589, $05ac, $05ce, $05ed
	dw $060b, $0627, $0642, $065b, $0672, $0689, $069e, $06b2
	dw $06c4, $06d6, $06e7, $06f7, $0706, $0714, $0721, $072d
	dw $0739, $0744, $074f, $0759, $0762, $076b, $0773, $077b
	dw $0783, $078a, $0790, $0797, $079d, $07a2, $07a7, $07ac
	dw $07b1, $07b6, $07ba, $07be, $07c1, $07c5, $07c8, $07cb
	dw $07ce, $07d1, $07d4, $07d6, $07d9, $07db, $07dd, $07df
	dw $07e1, $07e2, $07e4, $07e6, $07e7, $07e9, $07ea, $07eb
	dw $07ec, $07ed, $07ee, $07ef

; Per sound id (QueueSound): its header, a list of (channel, stream - 1), $FF.
Sounds::
	dw SoundNone, MusicGoingUp, MusicHeadingOut, MusicMenu
	dw MusicCleared, MusicTitle, SoundNone, SoundNone
	dw SfxStep, SfxBlocked, SfxPushBlock, SfxBlockInHole
	dw SfxTurnstile, SfxCursor, SfxSwitchChar, SfxPause
	dw SfxChoose, SfxCancel, SfxStairs, SfxGiveUp
	dw SoundNone

; Note lengths in frames for the length commands $80-$BF (index = command - $80):
; four tempos, each a row of 16 lengths and 4 unused bytes.
NoteLengths::
	db $00, $01, $02, $03, $04, $06, $08, $0c, $10, $18, $20, $30, $40, $60, $80, $c0
	db $00, $00, $00, $00, $05, $07, $0a, $0f, $14, $1e, $28, $3c, $50, $78, $a0, $f0
	db $00, $00, $00, $00, $06, $09, $0c, $12, $18, $24, $30, $48, $60, $90, $c0, $00
	db $00, $00, $00, $00, $07, $00, $0e, $15, $1c, $2a, $38, $54, $70, $a8, $e0, $00

; Envelopes for command $F0: (frames, rNRx2 volume byte) steps.
Envelopes::
	dw Envelope0, Envelope1, Envelope2, Envelope3, Envelope4, Envelope5, Envelope6, Envelope6

Envelope0::
	db $ff, $f0
Envelope1::
	db $ff, $20
Envelope2::
	db $ff, $f4
Envelope3::
	db $01, $f0, $ff, $08
Envelope4::
	db $ff, $f7
Envelope5::
	db $ff, $f2
Envelope6::
	db $ff, $08

; Wave RAM pattern for command $FC.
SquareWave::
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00
; Wave RAM pattern for command $FC.
TriangleWave::
	db $01, $23, $45, $67, $89, $ab, $cd, $ef, $fe, $dc, $ba, $98, $76, $54, $32, $10
; Wave RAM pattern for command $FC.
Wave2::
	db $02, $46, $8a, $ce, $ff, $ff, $ff, $ff, $fd, $b9, $75, $31, $00, $00, $00, $00


SoundNone::
	db $ff

MusicGoingUp::
	db 0
	dw MusicGoingUpSq1 - 1
	db 1
	dw MusicGoingUpSq2 - 1
	db 2
	dw MusicGoingUpWave - 1
	db 3
	dw MusicGoingUpNoise - 1
	db $ff
MusicGoingUpSq1::
	db $87, $54, $f0, $04, $f1, $80, $f2, $b0, $f9, $01
	db $f6
	dw MusicGoingUpSq1_Sub4
	db $c0, $8c, $30, $88, $54, $84, $54, $f0, $02, $f2, $a0, $f3, $f4
MusicGoingUpSq1_Loop::
	db $f4, $02
	db $f6
	dw MusicGoingUpSq1_Sub1
	db $88, $2a, $86, $2d, $88, $32, $86, $2a, $88, $2d, $86, $32, $88, $2a, $86, $2d
	db $f6
	dw MusicGoingUpSq1_Sub3
	db $88, $29, $86, $2c, $88, $32, $86, $29, $88, $2c, $86, $32, $88, $29, $86, $2c
	db $f6
	dw MusicGoingUpSq1_Sub2
	db $f6
	dw MusicGoingUpSq1_Sub1
	db $88, $28, $86, $2e, $88, $30, $86, $28, $88, $2e, $86, $30, $88, $28, $86, $2e
	db $88, $29, $86, $2d, $88, $30, $86, $29, $88, $2d, $86, $30, $88, $29, $86, $2d
	db $f5
	db $f6
	dw MusicGoingUpSq1_Sub2
	db $88, $29, $86, $2d, $88, $30, $86, $29, $88, $2d, $86, $30, $88, $29, $86, $2d
	db $f6
	dw MusicGoingUpSq1_Sub1
	db $f6
	dw MusicGoingUpSq1_Sub3
	db $f6
	dw MusicGoingUpSq1_Sub2
	db $88, $2b, $86, $2e, $88, $34, $86, $2b, $88, $2e, $86, $34, $88, $2b, $86, $2e
	db $88, $2d, $86, $30, $88, $35, $86, $2d, $88, $30, $86, $35, $88, $2d, $86, $30
	db $88, $35, $86, $34, $88, $33, $89, $32, $86, $31, $88, $30, $86, $2f
	db $f8
	dw MusicGoingUpSq1_Loop
MusicGoingUpSq1_Sub1::
	db $88, $29, $86, $2e, $88, $32, $86, $29, $88, $2e, $86, $32, $88, $29, $86, $2e
	db $f7
MusicGoingUpSq1_Sub2::
	db $88, $2b, $86, $2e, $88, $33, $86, $2b, $88, $2e, $86, $33, $88, $2b, $86, $2e
	db $f7
MusicGoingUpSq1_Sub3::
	db $88, $2b, $86, $2e, $88, $32, $86, $2b, $88, $2e, $86, $32, $88, $2b, $86, $2e
	db $f7
MusicGoingUpSq1_Sub4::
	db $c4, $88, $33, $c0, $86, $2e, $c8, $88, $29, $c0, $86, $33, $c4, $88, $32, $c0
	db $86, $2e, $c8, $88, $29, $c0, $86, $32, $f7
MusicGoingUpSq2::
	db $f0, $04, $f1, $80, $f2, $80
	db $f6
	dw MusicGoingUpSq1_Sub4
	db $c0, $8d, $30, $f0, $02, $f1, $40, $f3, $f4
MusicGoingUpSq2_Loop::
	db $f6
	dw MusicGoingUpSq2_Sub
	db $89, $30, $2c, $88, $2b, $86, $27, $88, $2b, $89, $32, $86, $30, $88, $2e, $86
	db $2d, $88, $2e, $86, $2d, $88, $2e, $89, $29, $86, $2b, $89, $2d, $88, $2b, $86
	db $28, $88, $2b, $89, $32, $86, $30, $88, $2e, $86, $2d, $88, $30, $89, $29, $86
	db $29, $88, $29, $86, $2d, $89, $30
	db $f6
	dw MusicGoingUpSq2_Sub
	db $88, $30, $86, $32, $88, $33, $86, $35, $88, $33, $86, $32, $88, $33, $89, $2b
	db $86, $2e, $89, $33, $88, $32, $86, $31, $88, $32, $89, $29, $86, $2e, $89, $32
	db $30, $2e, $2d, $2b, $29, $88, $29, $89, $29, $86, $2d, $88, $30, $86, $32, $89
	db $33, $33, $88, $33, $86, $32, $88, $33, $8a, $35, $89, $33, $32, $30, $32, $32
	db $88, $32, $86, $30, $88, $32, $89, $2b, $2b, $86, $2b, $88, $2b, $86, $2e, $89
	db $32, $89, $33, $33, $88, $33, $86, $32, $88, $33, $8a, $34, $89, $34, $88, $34
	db $86, $30, $88, $34, $8a, $35, $89, $35, $35, $35, $88, $35, $86, $34, $88, $33
	db $89, $32, $86, $31, $88, $30, $86, $2f
	db $f8
	dw MusicGoingUpSq2_Loop
MusicGoingUpSq2_Sub::
	db $88, $32, $86, $33, $88, $32, $89, $29, $86, $2e, $89, $32, $88, $54, $89, $32
	db $86, $32, $88, $32, $86, $30, $88, $2e, $86, $2d, $89, $2e, $2e, $88, $2e, $86
	db $30, $88, $2e, $89, $2c, $2c, $86, $2e, $f7
MusicGoingUpWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $86, $1b, $54, $54, $1b, $54, $54, $1a, $54, $54, $1a, $54, $54, $18, $54
	db $11, $88, $54, $84, $11, $54, $86, $11, $54, $13, $89, $15
MusicGoingUpWave_Loop::
	db $f4, $02, $a8, $16, $54, $86, $16, $54, $11, $16, $54, $15, $54, $54, $15, $54
	db $54, $15, $89, $1a, $86, $15, $54, $54, $13, $54, $54, $13, $54, $54, $13, $54
	db $12, $13, $54, $14, $54, $54, $14, $54, $54, $89, $16, $86, $18, $89, $1a, $a6
	db $1b, $54, $1b, $54, $86, $1b, $54, $1d, $1b, $54, $a6, $1a, $54, $1a, $54, $a8
	db $16, $86, $18, $a8, $1a, $a6, $18, $54, $18, $54, $16, $54, $13, $54, $11, $54
	db $86, $11, $54, $a8, $11, $86, $13, $a8, $15, $f5, $86, $1b, $54, $54, $13, $54
	db $89, $1b, $86, $13, $16, $54, $1b, $1d, $54, $54, $15, $54, $89, $1d, $86, $1b
	db $1a, $54, $18, $16, $54, $54, $11, $54, $89, $16, $86, $11, $88, $16, $86, $15
	db $13, $54, $54, $12, $54, $89, $13, $86, $15, $16, $54, $1a, $86, $1b, $54, $54
	db $13, $54, $89, $1b, $86, $13, $16, $54, $1b, $1c, $54, $54, $15, $54, $89, $1c
	db $86, $16, $18, $54, $1c, $11, $54, $11, $15, $54, $15, $18, $54, $18, $1b, $54
	db $1b, $1d, $54, $1c, $1b, $54, $89, $1a, $86, $19, $18, $54, $17
	db $f8
	dw MusicGoingUpWave_Loop
MusicGoingUpNoise::
	db $8d, $54, $54, $c0
MusicGoingUpNoise_Loop::
	db $f4, $2e, $f0, $00, $f2, $c0, $88, $10, $86, $54, $f0, $03, $f2, $80, $88, $20
	db $86, $20, $f5, $89, $20, $20, $20, $20
	db $f8
	dw MusicGoingUpNoise_Loop

MusicHeadingOut::
	db 0
	dw MusicHeadingOutSq1 - 1
	db 1
	dw MusicHeadingOutSq2 - 1
	db 2
	dw MusicHeadingOutWave - 1
	db 3
	dw SoundNone - 1
	db $ff
MusicHeadingOutSq1::
	db $f0, $05, $f1, $80, $f2, $80, $c0, $a4, $1a, $a6, $1a, $a4, $1a, $a6, $1a, $54
	db $a4, $1d, $a6, $1d, $a4, $1d, $a6, $1d, $54, $a6, $1a, $1a, $1d, $1e, $1f, $54
	db $f2, $40, $c8, $81, $f4, $0c, $3c, $3b, $f5, $f2, $80, $c0
MusicHeadingOutSq1_Loop::
	db $f9, $01
	db $f6
	dw MusicHeadingOutSq1_Sub2
	db $29, $f9, $00, $a4, $1a, $a6, $1a, $a4, $1a, $a6, $1f, $1d, $a8, $1a, $54, $f9, $01
	db $f6
	dw MusicHeadingOutSq1_Sub2
	db $2f, $f9, $00, $21, $a4, $1c, $1c, $a6, $1d, $1c, $54, $1f, $1f, $54, $f2, $a0
	db $f9, $01, $a4
	db $f6
	dw MusicHeadingOutSq1_Sub1
	db $f4, $04, $28, $24, $1f, $24, $f5
	db $f6
	dw MusicHeadingOutSq1_Sub1
	db $f2, $80, $a4, $1a, $a6, $1a, $a4, $1a, $a6, $1f, $23, $26, $54, $54, $54
	db $f8
	dw MusicHeadingOutSq1_Loop
MusicHeadingOutSq1_Sub1::
	db $f4, $04, $29, $24, $21, $24, $f5, $f4, $04, $28, $24, $1f, $24, $f5, $f4, $04
	db $26, $23, $1f, $23, $f5, $f7
MusicHeadingOutSq2::
	db $f0, $05, $f1, $80, $f2, $80, $c0, $a4, $1f, $a6, $1f, $a4, $1f, $a6, $1f, $54
	db $a4, $21, $a6, $21, $a4, $21, $a6, $21, $54, $a6, $1f, $1f, $21, $22, $23, $54
	db $f2, $40, $c4, $81, $f4, $0c, $3b, $3c, $f5, $f2, $80, $c0
MusicHeadingOutSq2_Loop::
	db $f6
	dw MusicHeadingOutSq1_Sub2
	db $29, $a4, $1f, $a6, $1f, $a4, $1f, $a6, $23, $21, $a8, $1f, $54
	db $f6
	dw MusicHeadingOutSq1_Sub2
	db $2f, $24, $a4, $1f, $1f, $a6, $21, $1f, $54, $23, $24, $54, $f0, $04
	db $f6
	dw MusicHeadingOutSq2_Sub
	db $a6, $32, $31, $30, $2f, $a8, $2b, $a6, $2f, $35, $ac, $34
	db $f6
	dw MusicHeadingOutSq2_Sub
	db $a6, $32, $32, $32, $32, $32, $30, $2f, $2d, $a4, $1f, $a6, $1f, $a4, $1f, $a6
	db $23, $26, $2b, $54, $54, $54, $f0, $05
	db $f8
	dw MusicHeadingOutSq2_Loop
MusicHeadingOutSq1_Sub2::
	db $83, $f4, $04, $2b, $28, $f5, $a6, $34, $32, $30, $2f, $2d, $2b, $29, $28, $26
	db $24, $23, $21, $1f, $54, $83, $f4, $04, $29, $26, $f5, $a6, $32, $30, $2f, $2d
	db $2b, $f7
MusicHeadingOutSq2_Sub::
	db $a6, $2d, $2d, $30, $30, $a8, $35, $a6, $2d, $35, $ac, $34, $f7
MusicHeadingOutWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $83, $13, $54, $a4, $13, $54, $83, $13, $54, $a4, $13, $a7, $54, $83, $15
	db $54, $a4, $15, $54, $83, $15, $54, $a4, $15, $a7, $54, $a4, $1a, $54, $18, $54
	db $17, $54, $15, $54, $13, $a7, $54, $a8, $54
MusicHeadingOutWave_Loop::
	db $f6
	dw MusicHeadingOutWave_Sub1
	db $17, $54, $13, $54, $a4, $18, $54, $13, $54, $15, $54, $17, $54
	db $f6
	dw MusicHeadingOutWave_Sub1
	db $a4, $18, $54, $83, $13, $54, $13, $54, $a6, $15, $a4, $13, $54, $a4, $54, $54
	db $17, $54, $18, $54, $54, $54, $a6
	db $f6
	dw MusicHeadingOutWave_Sub2
	db $18, $54, $13, $54, $18, $54, $13, $54
	db $f6
	dw MusicHeadingOutWave_Sub2
	db $83, $13, $54, $a4, $13, $54, $83, $13, $54, $a4, $17, $54, $1a, $54, $1f, $54
	db $13, $54, $15, $54, $17, $54
	db $f8
	dw MusicHeadingOutWave_Loop
MusicHeadingOutWave_Sub1::
	db $a6, $18, $54, $13, $54, $18, $54, $19, $54, $1a, $54, $13, $54, $1a, $54, $13
	db $54, $1a, $54, $15, $54, $1a, $54, $15, $54, $f7
MusicHeadingOutWave_Sub2::
	db $15, $54, $11, $54, $15, $54, $17, $54, $18, $54, $13, $54, $18, $54, $13, $54
	db $17, $54, $13, $54, $17, $54, $13, $54, $f7

MusicMenu::
	db 0
	dw MusicMenuSq1 - 1
	db 1
	dw MusicMenuSq2 - 1
	db 2
	dw MusicMenuWave - 1
	db 3
	dw SoundNone - 1
	db $ff
MusicMenuSq1::
	db $99, $54, $f0, $02, $f1, $80, $f2, $b0, $f9, $01, $98
MusicMenuSq1_Loop::
	db $c0, $24, $c8, $28, $c0, $2b, $c4, $29, $c0, $28, $c8, $26, $c0, $28, $c4, $26
	db $c0, $24, $c8, $29, $c0, $28, $c4, $26, $c0, $24, $c8, $28, $c0, $2b, $c4, $96
	db $2d, $2b, $c0, $98, $29, $c8, $28, $c0, $26, $c4, $24, $c0, $23, $c8, $1f, $c0
	db $23, $c4, $26
	db $f8
	dw MusicMenuSq1_Loop
MusicMenuSq2::
	db $f2, $80, $c0, $f0, $02, $f1, $80, $98
MusicMenuSq2_Loop::
	db $24, $28, $2b, $29, $28, $26, $28, $26, $24, $29, $28, $26, $24, $28, $2b, $96
	db $2d, $2b, $98, $29, $28, $26, $24, $23, $1f, $23, $26
	db $f8
	dw MusicMenuSq2_Loop
MusicMenuWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $9b
MusicMenuWave_Loop::
	db $18, $1a, $1c, $1d, $18, $19, $1a, $13
	db $f8
	dw MusicMenuWave_Loop

MusicCleared::
	db 0
	dw MusicClearedSq1 - 1
	db 1
	dw MusicClearedSq2 - 1
	db 2
	dw MusicClearedWave - 1
	db 3
	dw SoundNone - 1
	db $ff
MusicClearedSq1::
	db $f9, $01, $c0
	db $f8
	dw MusicClearedSq1_Jump
MusicClearedSq2::
	db $c0
MusicClearedSq1_Jump::
	db $88, $54, $f0, $02, $f1, $80, $f2, $80, $f3, $fe, $86, $2b, $88, $2a, $86, $2b
	db $88, $2d, $86, $2c, $88, $2d, $86, $2f, $89, $30, $88, $2f, $89, $30, $ff
MusicClearedWave::
	db $f0, $01, $f3, $fe
	db $fc
	dw TriangleWave
	db $c0, $86, $1f, $54, $84, $1f, $54, $86, $1f, $54, $84, $1f, $54, $86, $1e, $54
	db $84, $1e, $54, $86, $1d, $54, $84, $1d, $54, $86, $18, $88, $54, $86, $13, $54
	db $18, $ff

MusicTitle::
	db 0
	dw MusicTitleSq1 - 1
	db 1
	dw MusicTitleSq2 - 1
	db 2
	dw MusicTitleWave - 1
	db 3
	dw SoundNone - 1
	db $ff
MusicTitleSq1::
	db $f2, $80
	db $f6
	dw MusicTitleSq1_Sub2
	db $c0, $aa, $2f
	db $f6
	dw MusicTitleSq1_Sub1
	db $c0, $a6, $30, $2f, $2e, $2d, $2c, $2b, $2a, $29
	db $f6
	dw MusicTitleSq1_Sub1
	db $f4, $02, $c0, $30, $c4, $2b, $c0, $28, $c8, $2b, $f5, $f0, $02, $c0, $8c, $30
	db $ff
MusicTitleSq1_Sub1::
	db $a4, $f0, $05, $f4, $02, $c0, $2b, $c8, $28, $c0, $24, $c4, $28, $f5, $c0, $f0, $00
	db $a7, $2b, $81, $2b, $2c, $2d, $2e, $2f, $30, $f0, $04, $a8, $30, $a4, $f0, $05
	db $f4, $02, $c0, $2d, $c8, $29, $c0, $24, $c4, $29, $f5, $c0, $f0, $00, $b7, $2d
	db $81, $2e, $2f, $30, $f0, $04, $a8, $30, $a4, $f0, $05, $f4, $02, $c0, $2f, $c8
	db $2b, $c0, $26, $c4, $2b, $f5, $c0, $2f, $c8, $29, $c0, $2b, $c4, $29, $c0, $2d
	db $c8, $29, $c0, $2f, $c4, $2b, $f7
MusicTitleSq1_Sub2::
	db $f0, $05, $f1, $80, $a4, $c0, $2b, $c4, $28, $c0, $2b, $c8, $28, $c0, $2c, $c4
	db $28, $c0, $2c, $c8, $28, $c0, $2d, $c4, $29, $c0, $2d, $c8, $29, $c0, $2e, $c4
	db $29, $c0, $2e, $c8, $29, $c0, $2f, $c4, $2b, $c0, $29, $c8, $26, $c0, $23, $c4
	db $26, $c0, $29, $c4, $2b, $f0, $04, $f7
MusicTitleSq2::
	db $a5, $54, $f2, $b0, $f9, $01
	db $f6
	dw MusicTitleSq1_Sub2
	db $c0, $a9, $2f, $83, $54, $f0, $02, $f2, $a0
	db $f6
	dw MusicTitleSq2_Sub
	db $c0, $a6, $30, $2f, $2e, $2d, $2c, $2b, $2a, $29
	db $f6
	dw MusicTitleSq2_Sub
	db $f4, $02, $c0, $30, $c4, $2b, $c0, $28, $c8, $2b, $f5, $c0, $8c, $30, $ff
MusicTitleSq2_Sub::
	db $a4, $f4, $04, $c0, $28, $c4, $24, $c0, $1f, $c8, $24, $f5, $f4, $04, $c0, $29
	db $c4, $24, $c0, $21, $c8, $24, $f5, $f4, $04, $c0, $2b, $c4, $26, $c0, $23, $c8
	db $26, $f5, $f7
MusicTitleWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $a4, $13, $54, $13, $54, $14, $54, $14, $54, $15, $54, $15, $54, $16, $54
	db $16, $54, $17, $54, $54, $54, $a8, $13, $a4, $54, $54, $13, $54, $15, $54, $17
	db $54, $a4
	db $f6
	dw MusicTitleWave_Sub
	db $13, $54, $14, $54, $15, $54, $16, $54, $17, $54, $18, $54, $19, $54, $1a, $54
	db $f6
	dw MusicTitleWave_Sub
	db $24, $54, $1f, $54, $21, $54, $23, $54, $24, $54, $54, $54, $18, $ff
MusicTitleWave_Sub::
	db $f4, $02, $18, $54, $1f, $54, $83, $18, $54, $18, $54, $a4, $1f, $54, $f5, $f4, $02
	db $18, $54, $1d, $54, $83, $18, $54, $18, $54, $a4, $1d, $54, $f5, $f4, $02, $1a
	db $54, $1f, $54, $83, $1a, $54, $1a, $54, $a4, $1f, $54, $f5, $f7

SfxStep::
	db 4
	dw SfxStepFxSq1 - 1
	db $ff
SfxStepFxSq1::
	db $f0, $00, $f1, $80, $f2, $00, $c0, $fa, $16, $82, $28, $fa, $1e, $54, $28, $ff

SfxBlocked::
	db 4
	dw SfxBlockedFxSq1 - 1
	db 6
	dw SfxBlockedFxWave - 1
	db $ff
SfxBlockedFxSq1::
	db $f0, $00, $f1, $80, $f2, $80, $c0, $82, $14, $12, $10, $0e, $ff
SfxBlockedFxWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $82, $20, $1e, $1c, $1a, $ff

SfxPushBlock::
	db 4
	dw SfxPushBlockFxSq1 - 1
	db 6
	dw SfxPushBlockFxWave - 1
	db $ff
SfxPushBlockFxSq1::
	db $f0, $00, $f1, $80, $f2, $80, $c0, $82, $14, $16, $18, $1a, $ff
SfxPushBlockFxWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $82, $14, $16, $18, $1a, $ff

SfxBlockInHole::
	db 6
	dw SfxBlockInHoleFxWave - 1
	db $ff
SfxBlockInHoleFxWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $81, $20, $24, $28, $2c, $30, $82, $20, $1c, $18, $14, $10, $ff

SfxTurnstile::
	db 4
	dw SfxTurnstileFxSq1 - 1
	db $ff
SfxTurnstileFxSq1::
	db $f0, $00, $f1, $80, $f2, $40, $c0, $82, $28, $26, $2c, $2a, $30, $2e, $ff

SfxSwitchChar::
	db 5
	dw SfxSwitchCharFxSq2 - 1
	db 4
	dw SfxSwitchCharFxSq1 - 1
	db $ff
SfxSwitchCharFxSq2::
	db $f2, $40, $c4
SfxSwitchCharFxSq1_Jump::
	db $f0, $02, $f1, $40, $84, $32, $2e, $29, $2e, $32, $86, $35, $ff
SfxSwitchCharFxSq1::
	db $f2, $40, $f9, $01, $c8
	db $f8
	dw SfxSwitchCharFxSq1_Jump

SfxCursor::
	db 4
	dw SfxCursorFxSq1 - 1
	db $ff
SfxCursorFxSq1::
	db $f0, $00, $f1, $80, $f2, $40, $c0, $82, $39, $ff

SfxPause::
	db 6
	dw SfxPauseFxWave - 1
	db $ff
SfxPauseFxWave::
	db $f0, $01
	db $fc
	dw TriangleWave
	db $c0, $81, $20, $24, $28, $2c, $24, $28, $2c, $30, $28, $2c, $30, $34, $ff

SfxChoose::
	db 4
	dw SfxChooseFxSq1 - 1
	db $ff
SfxChooseFxSq1::
	db $f0, $00, $f1, $80, $f2, $40, $c0, $82, $30, $54, $34, $f2, $c0, $30, $54, $34
	db $ff

SfxCancel::
	db 4
	dw SfxCancelFxSq1 - 1
	db $ff
SfxCancelFxSq1::
	db $f0, $00, $f1, $80, $f2, $40, $c0, $82, $30, $2d, $2a, $f2, $c0, $30, $2d, $2a
	db $ff

SfxStairs::
	db 4
	dw SfxStairsFxSq1 - 1
	db 5
	dw SfxStairsFxSq2 - 1
	db $ff
SfxStairsFxSq1::
	db $f9, $01, $c0
	db $f8
	dw SfxStairsFxSq1_Jump
SfxStairsFxSq2::
	db $c0
SfxStairsFxSq1_Jump::
	db $f0, $05, $f1, $80, $f2, $40, $84, $37, $34, $37, $87, $34, $ff

SfxGiveUp::
	db 4
	dw SfxGiveUpFxSq1 - 1
	db 5
	dw SfxGiveUpFxSq2 - 1
	db $ff
SfxGiveUpFxSq1::
	db $85, $54, $f2, $b0, $c0
	db $f8
	dw SfxGiveUpFxSq1_Jump
SfxGiveUpFxSq2::
	db $f2, $40, $c0
SfxGiveUpFxSq1_Jump::
	db $f0, $00, $f1, $80, $82, $30, $54, $2c, $54, $29, $54, $27, $54, $26, $ff

; Per channel 0-7: the low bytes of its rNRx2 and rNRx4 registers.
ChannelRegs::
	db $12, $14, $17, $19, $1c, $1e, $21, $23, $12, $14, $17, $19, $1c, $1e, $21, $23

; rNR51 bits for the pan commands: $C0 + voice both sides, $C4 + voice left, $C8 + voice right.
PanMasks::
	db $11, $22, $44, $88, $10, $20, $40, $80, $01, $02, $04, $08
	db $00, $00, $00, $00
