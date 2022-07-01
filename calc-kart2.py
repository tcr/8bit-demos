import cycle_map
from sys import stderr

PRINT_SCANLINES = False

l1 = 1
l17 = 17
l33 = 33

r428 = 428
# +48
r380 = 380
# +40
r340 = 340
# +20
r320 = 320
# +34
r286 = 286
# +30
r254 = 254
# +30
r226 = 226
# +12
r214 = 214
# +24
r190 = 190
# +30
r160 = 160
# +18
r142 = 142
# +14
r128 = 128
# +22
r106 = 106
# +22
r84 = 84
# +14
r72 = 72
# +18
r54 = 54

ALL_RATES = [r54, r72, r84, r106, r128, r142, r160, r190, r214, r226, r254, r286, r320, r340, r380, r428]
ALL_LENGTHS = [l1, l17, l33]

CPU_FRAME = 29780.5


class State:
    rate = 0
    cpu = 0
    frame_count = 1

    def total_frame_cycles(self):
        # add one cpu clock each other frame
        # return CPU_FRAME * self.frame_count
        # return (341/3)*46.5 * self.frame_count
        return (CPU_FRAME * self.frame_count)
    
    def offset(self):
        return self.total_frame_cycles() - self.cpu

    def frame(self):
        print(self.cpu, '    missing cycles:', self.offset(), file=stderr)
        print()
        print('; next frame')
        self.frame_count += 1

    def reset(self, p0):
        self.rate = p0
        self.cpu = 0

    def print_scanline(self):
        print('scanline {:.1f}'.format(self.cpu / (CPU_FRAME / 262)), file=stderr)

    def step(self, p1_2, len=1):
        for i in range(0, len):
            self.cpu += self.rate
            self.cpu += p1_2 * 7
            self.rate = p1_2
        
        print(f'        IRQ_CALL irq_set_rate, DMCFREQ_IRQ_RATE{p1_2}')

        if PRINT_SCANLINES:
            self.print_scanline()

    def two_step(self, p1, p2):
        self.cpu += self.rate
        self.cpu += p1
        self.cpu += p2 * 6
        self.rate = p2

        print(f'        IRQ_CALL irq_set_two_rates, DMCFREQ_IRQ_RATE{p1}, DMCFREQ_IRQ_RATE{p2}')

        if PRINT_SCANLINES:
            self.print_scanline()

    def copy(self):
        c = State()
        c.cpu = self.cpu
        c.rate = self.rate
        c.frame_count = self.frame_count
        return c
    
    def advance(self, count):
        count -= (self.rate - 54)

        by = cycle_map.cycle_map[count]
        for step in by:
            if isinstance(step, list):
                self.two_step(step[0], step[1])
            else:
                self.step(step)


# run game

state = State()

def run_kernel(state):
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)

    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)
    state.two_step(r72, r54)
    state.two_step(r84, r54)


start_offset = 8818

state.reset(r54)
state.advance(start_offset)
print()
run_kernel(state)
print()
state.step(r428)
offset = state.offset() - 0.5
state.advance(offset + 2)
state.frame()

for _ in range(0, 3):
    state.advance(start_offset)
    print()
    run_kernel(state)
    print()
    state.step(r428)
    state.advance(offset)
    state.frame()
