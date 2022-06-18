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

# CPU_FRAME = 29780.5

def round_to_half(n):
    return round(n * 2) / 2

SCANLINE_CPU_COUNT = 341/3

def scanline_cpu_count_rounded(n):
    return round_to_half(SCANLINE_CPU_COUNT * n)

CPU_FRAME = scanline_cpu_count_rounded(222)


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
        return self.offset()

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
        for l in ALL_LENGTHS:
            if source.offset() < (r * l * 8):
                continue

            o2 = origin[:]
            s2 = source.copy()
            s2.step(r)
            o2.append(r)
            if s2.offset() > upper:
                solve_frame(o2, s2, lower, upper, max_len, terminate_on)
            elif s2.offset() >= lower:
                if s2.rate in terminate_on:
                    print(o2)
                    raise Exception(f"Count: {s2.frame()}")

    if len(origin) > 1 and (origin[-1:][0] == r54 or origin[-1:][0] == r72):
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
                        raise Exception(f"Count: {s2.frame()}")





# try to solve
print()
print()
for i in range(0, (428-54), 2):
    state = State()
    state.reset(r54)
    state.cpu = i

    state.step(r160, l17)

    print(state.offset())

    try:
        solve_frame([], state, 0, 4.5, 4, set([r54]))
    except Exception as e:
        print(e)
        continue

    raise Exception(f'could not solve for {i}')
