"""Shared helpers for Kwirk's asset plugins: run the whole game from Boot, frame by frame.

Kwirk's code is one long thread that calls WaitVBlank whenever it wants the next frame
(there is no state table to call once per frame). So the machine here steps the CPU and
treats every arrival at WaitVBlank as the end of a frame: it takes the screen, runs the
VBlank interrupt handler (which sets hVBlankDone, so WaitVBlank returns at once), and
goes on. WaitHBlank returns at once (there is no LCD timing to wait for). With
spin_loops (routine names), a frame also ends after 30000 steps inside one of them:
loops that wait for a flag the VBlank handler sets (LinkWait).
"""
from gamerun import GameRunner

FRAME_HZ = 4194304 / 70224


class Machine:
    def __init__(self, ctx, record_sound=False, spin_loops=()):
        self.ctx = ctx
        self.run = GameRunner(ctx.project, stack=0xDCFF)
        self.mem = self.run.mem
        self.cpu = self.run.cpu
        self.syms = ctx.syms
        self.mem[self.syms['WaitHBlank']] = 0xC9           # ret
        self.wait_vblank = self.syms['WaitVBlank']
        self.handler = self.syms['VBlankHandler']
        self.cpu.pc = self.syms['Boot']
        self.cpu.sp = 0xFFFE
        self.frames = 0
        self.spin = set()                                  # busy loops that wait for the VBlank handler
        for name in spin_loops:
            self.spin.update(range(self.syms[name], self.syms[name] + 16))
        self.hooks = {}                                    # pc -> function(machine), called before the step
        if record_sound:
            self.run.record_sound()
        self.buttons = 0                                   # held: A $01 B $02 Select $04 Start $08, d-pad high nibble
        plain = self.cpu.rd

        self.ly = 144
        self.scx_writes = []                               # (line, value) of this frame's rSCX writes

        def rd(a):                                         # the joypad register answers from self.buttons
            if a & 0xFFFF == 0xFF44:                       # rLY: one line further at each read, so
                self.ly = (self.ly + 1) % 154              # the game's line waits come true
                return self.ly
            if a & 0xFFFF == 0xFF00:
                sel = self.mem[0xFF00]
                v = 0x0F
                if not sel & 0x10:
                    v &= ~(self.buttons >> 4)
                if not sel & 0x20:
                    v &= ~self.buttons
                return 0xC0 | (sel & 0x30) | (v & 0x0F)
            return plain(a)
        self.cpu.rd = rd
        plain_wr = self.cpu.wr

        def wr(a, v):
            if a & 0xFFFF == 0xFF43:                       # rSCX: remember the line (split scrolling)
                self.scx_writes.append((0 if self.ly >= 144 else self.ly, v & 0xFF))
            plain_wr(a, v)
        self.cpu.wr = wr

    def addr(self, name):
        return self.run.addr(name)

    def get(self, name):
        return self.run.get(name)

    def set(self, name, value):
        self.run.set(name, value)

    def frame(self, max_steps=3000000):
        """Run until the game waits for the next frame, then do the VBlank interrupt."""
        cpu, mem = self.cpu, self.mem
        cpu.reads, cpu.writes = set(), set()
        self.scx_start, self.scx_writes, self.ly = self.mem[0xFF43], [], 144
        for i in range(max_steps):
            pc = cpu.pc
            if pc in self.hooks:
                self.hooks[pc](self)
            if pc == self.wait_vblank and i:
                break
            if i >= 30000 and pc in self.spin:             # a frame's worth of steps in such a loop:
                break                                      # the VBlank interrupt comes in the middle
            if mem[pc] == 0x76:                            # halt: until the VBlank interrupt, which
                cpu.pc += 1                                # the WaitVBlank right after it stands for
                continue
            cpu.step()
        else:
            raise RuntimeError('no frame after {} steps (pc=${:04X})'.format(max_steps, cpu.pc))
        self.vblank()
        self.frames += 1

    def vblank(self):
        cpu, mem = self.cpu, self.mem
        pc, sp = cpu.pc, cpu.sp
        if self.run.sound is not None:
            cpu.io_log = []
        cpu.writes = set()
        cpu.call(self.handler, max_steps=200000)
        if self.run.sound is not None:
            self.run._pending += cpu.io_log
            cpu.io_log = None
            self.run.end_frame()
        if 0xFF46 in cpu.writes:                           # the OAM DMA
            src = mem[0xFF46] << 8
            mem[0xFE00:0xFEA0] = mem[src:src + 0xA0]
        cpu.pc, cpu.sp = pc, sp

    def screen(self):
        """The frame just drawn (call before frame() moves on), with the rSCX changes
        the game made on its way down the screen."""
        if not self.scx_writes:
            return self.run.screen()
        line_scx, cur, w = [], self.scx_start, sorted(self.scx_writes, key=lambda x: x[0])
        for y in range(144):
            while w and w[0][0] <= y:
                cur = w.pop(0)[1]
            line_scx.append(cur)
        keep, rows, shots = self.mem[0xFF43], [None] * 144, {}
        for y, s in enumerate(line_scx):
            if s not in shots:
                self.mem[0xFF43] = s
                shots[s] = self.run.screen()
            rows[y] = shots[s][y]
        self.mem[0xFF43] = keep
        return rows
