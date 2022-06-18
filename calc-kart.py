PRINT_SCANLINES = True

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
r256 = 256
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

ALL_RATES = [r54, r72, r84, r106, r128, r142, r160, r190, r214, r226, r256, r286, r320, r340, r380, r428]
ALL_LENGTHS = [l1, l17, l33]

CPU_FRAME = 29780.5


class State:
    rate = 0
    cpu = 0
    frame_count = 1

    def total_frame_cycles(self):
        # add one cpu clock each other frame
        return CPU_FRAME * self.frame_count
    
    def offset(self):
        return self.total_frame_cycles() - self.cpu

    def frame(self):
        print(self.cpu, '    missing cycles:', self.offset())
        print()
        self.frame_count += 1

    def reset(self, p0):
        self.rate = p0
        self.cpu = 0

    def print_scanline(self):
        print('scanline {:.1f}'.format(self.cpu / (CPU_FRAME / 262)))

    def step(self, p1_2, len=1):
        for i in range(0, len):
            self.cpu += self.rate
            self.cpu += p1_2 * 7
            self.rate = p1_2

        if PRINT_SCANLINES:
            self.print_scanline()

    def two_step(self, p1, p2):
        self.cpu += self.rate
        self.cpu += p1
        self.cpu += p2 * 6
        self.rate = p2

        if PRINT_SCANLINES:
            self.print_scanline()

    def copy(self):
        c = State()
        c.cpu = self.cpu
        c.rate = self.rate
        c.frame_count = self.frame_count
        return c


def solve_frame(origin, source, lower, upper, max_len, terminate_on):
    if len(origin) > (max_len - 1):
        return

    for r in ALL_RATES:
        o2 = origin[:]
        s2 = source.copy()
        s2.step(r)
        o2.append(r)
        if s2.offset() > upper:
            solve_frame(o2, s2, lower, upper, max_len, terminate_on)
        elif s2.offset() >= lower:
            if s2.rate in terminate_on:
                print(o2)
                s2.frame()

    if len(origin) > 0 and (origin[-1:][0] == r54 or origin[-1:][0] == r72):
        for r in ALL_RATES:
            for r2 in [r54, r72]:
                o2 = origin[:]
                s2 = source.copy()
                s2.two_step(r, r2)
                o2.append([r, r2])
                if s2.offset() > upper:
                    solve_frame(o2, s2, lower, upper, max_len, terminate_on)
                elif s2.offset() >= lower:
                    if s2.rate in terminate_on:
                        print(o2)
                        s2.frame()



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


# Start
state.reset(r54)

run_kernel(state)
print('end of road [=56]')
state.two_step(r428, r72)
print('top of map [=64]')
state.step(r54, l17)
state.two_step(r320, r380)
print('last 8 rows of map [=152]')
state.step(r72)
print('end of map [=160]')
state.step(r428)
state.step(r226)
state.step(r226)
print('start of sky [=222]')
state.step(r128)
state.step(r160)
state.step(r226)
state.step(r54)
print('end of frame [=262]')
state.frame()

run_kernel(state)
print('end of road [=56]')
state.two_step(r428, r72)
print('top of map [=64]')
state.step(r54, l17)
state.two_step(r320, r380)
print('last 8 rows of map [=152]')
state.step(r72)
print('end of map [=160]')
state.step(r428)
state.step(r226)
state.step(r226)
print('start of sky [=222]')
state.step(r128)
state.step(r286)
state.step(r54)
state.two_step(r428, r54)
print('end of frame [=262]')
state.frame()

run_kernel(state)
print('end of road [=56]')
state.two_step(r428, r72)
print('top of map [=64]')
state.step(r54, l17)
state.two_step(r320, r380)
print('last 8 rows of map [=152]')
state.step(r72)
print('end of map [=160]')
state.step(r428)
state.step(r226)
state.step(r226)
print('start of sky [=222]')
state.step(r128)
state.step(r286)
state.step(r54)
state.two_step(r428, r54)
print('end of frame [=262]')
state.frame()

run_kernel(state)
print('end of road [=56]')
state.two_step(r428, r72)
print('top of map [=64]')
state.step(r54, l17)
state.two_step(r320, r380)
print('last 8 rows of map [=152]')
state.step(r72)
print('end of map [=160]')
state.step(r428)
state.step(r226)
state.step(r226)
print('start of sky [=222]')
state.step(r128)
state.step(r286)
state.step(r54)
state.two_step(r428, r54)
print('end of frame [=262]')
state.frame()


# try to solve
# print()
# print()
# solve_frame([], state, -0.5, 1.5, 4, set([r54]))
