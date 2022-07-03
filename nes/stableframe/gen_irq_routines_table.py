import cycle_map
from sys import stderr

r428 = 428
r380 = 380
r340 = 340
r320 = 320
r286 = 286
r254 = 254
r226 = 226
r214 = 214
r190 = 190
r160 = 160
r142 = 142
r128 = 128
r106 = 106
r84 = 84
r72 = 72
r54 = 54

ALL_RATES = [
    r54,
    r72,
    r84,
    r106,
    r128,
    r142,
    r160,
    r190,
    r214,
    r226,
    r254,
    r286,
    r320,
    r340,
    r380,
    r428,
]

CPU_CYCLES_PER_FRAME = 29780.5
CPU_CYCLES_PER_SCANLINE = 341/3


class State:
    rate = 0
    cpu = 0
    frame_count = 1

    def total_frame_cycles(self):
        return CPU_CYCLES_PER_FRAME * self.frame_count

    def remaining_in_frame(self):
        return self.total_frame_cycles() - self.cpu

    def frame(self):
        print(
            f"        ; cpu cycles = {self.cpu}    offset = {self.remaining_in_frame()}"
        )
        print()
        self.frame_count += 1

    def start(self, p0):
        self.rate = p0
        self.cpu = 0

        print("; python gen_irq_routines_table.py > src/irq_routines_table.asm")
        print()
        print("        align 256")
        print("irq_routines_table:")

    def print_scanline(self):
        print(
            "scanline {:.1f}".format(self.cpu / (CPU_CYCLES_PER_FRAME / 262)),
            file=stderr,
        )

    def clone(self):
        c = State()
        c.cpu = self.cpu
        c.rate = self.rate
        c.frame_count = self.frame_count
        return c

    # step functions

    def one_step(
        self,
        p1_2,
        routine="irq_routine_one_step",
        output_arg_one=True,
        additional_args=[],
    ):
        self.cpu += self.rate
        self.cpu += p1_2 * 7
        self.rate = p1_2

        args = []
        if output_arg_one:
            args.append(f"DMCFREQ_IRQ_RATE{p1_2}")
        args.extend(additional_args)

        print(f'        WORD {routine}')
        if len(args) > 0:
            print(f'            byt {", ".join(args)}')

    def two_step(
        self,
        p1,
        p2,
        routine="irq_routine_two_step",
        output_arg_one=True,
        output_arg_two=True,
        additional_args=[],
    ):
        self.cpu += self.rate
        self.cpu += p1
        self.cpu += p2 * 6
        self.rate = p2

        args = []
        if output_arg_one:
            args.append(f"DMCFREQ_IRQ_RATE{p1}")
        if output_arg_two:
            args.append(f"DMCFREQ_IRQ_RATE{p2}")
        args.extend(additional_args)

        print(f'        WORD {routine}')
        if len(args) > 0:
            print(f'            byt {", ".join(args)}')

    def advance_to(self, count, **kwargs):
        count -= self.cpu
        if count < 0:
            raise Exception("advance_to is counting backward")

        return self.advance_by(count, **kwargs)

    def advance_by(
        self,
        count,
        last_routine_one_step="irq_routine_one_step",
        last_routine_two_step="irq_routine_two_step",
        last_routine_additional_args=[],
    ):
        count -= self.rate - 54

        by = cycle_map.cycle_map[count]
        for step in by[:-1]:
            if isinstance(step, list):
                self.two_step(step[0], step[1])
            else:
                self.one_step(step)
        for step in by[-1:]:
            if isinstance(step, list):
                self.two_step(
                    step[0],
                    step[1],
                    routine=last_routine_two_step,
                    additional_args=last_routine_additional_args,
                )
            else:
                self.one_step(
                    step,
                    routine=last_routine_one_step,
                    additional_args=last_routine_additional_args,
                )


###########################
# Game-specific logic
###########################

# Generate the middle rows using a chain of two step routines, with 72 and 84 being P1 values
def output_rows(state):
    start_cpu = state.cpu

    # Odd frames are light, even frames are dark
    odd = True

    # Start by creating an IRQ >4 scanlines.
    freq = r84

    # Aligning with JUMP_CYCLE in code, we can reduce some jitter by using different values for
    # cycle_modifier to wait odd or even numbers of CPU cycles before running each interrupt.
    cycle_modifier = 4

    # This irregular sequence of frequencies keeps us averaging about 4 scanlines per row.
    for row in range(0, 32):
        # color off/even frames
        if odd:
            routine = "irq_routine_row_light"
        else:
            routine = "irq_routine_row_dark"
        odd = not odd

        routine += f' - {cycle_modifier}'

        # advance in two steps
        state.two_step(freq, r54, routine=routine, output_arg_two=False)

        # see which frequency to use next by seeing if we are over or under
        elapsed_cycles = (state.cpu - start_cpu)
        expected_cycles = (row + 1) * 4 * CPU_CYCLES_PER_SCANLINE
        if elapsed_cycles > expected_cycles:
            # overshot
            freq = r72
        else:
            # undershot
            freq = r84

        if elapsed_cycles - expected_cycles < -3:
            cycle_modifier = 8
        elif elapsed_cycles - expected_cycles < 0:
            cycle_modifier = 6
        elif elapsed_cycles - expected_cycles < 3:
            cycle_modifier = 4
        elif elapsed_cycles - expected_cycles < 6:
            cycle_modifier = 2
        else:
            cycle_modifier = 0

        print(row, freq, elapsed_cycles - expected_cycles, file=stderr)
        # print(row, freq, (state.cpu - start_cpu) / CPU_CYCLES_PER_SCANLINE, offset - (row + 1) * 4, file=stderr)


# Build the state generator.
state = State()

cycles_vblank = 1364  # ~12 scanlines
cycle_rows = 8696  # cycle to start rendering the middle rows

# 1. Start with a VBLANK routine, then advance up to offset_to_rows.
state.start(r54)
state.one_step(r428, routine="irq_routine_vblank_start")
state.advance_to(cycle_rows)
print()

# 2. Output the series of middle rows.
output_rows(state)
print()

# 3. One routine to branch to end-of-frame alignment.
state.one_step(r54, routine="irq_routine_align_start")
print()

# 4. Output four alignment sequences. The first one overshoots by 1.5 clock cycles, and each
# of the three successive frames undershoots by 0.5.
alignment_offset = state.remaining_in_frame() - 0.5

print("irq_routines_table_align_0:")
state2 = state.clone()
state2.advance_by(
    alignment_offset + 2,
    last_routine_one_step="irq_routine_one_step_align",
    last_routine_two_step="irq_routine_two_step_align",
    last_routine_additional_args=["lo(irq_routines_table_align_3)"],
)
state2.frame()

for frame in range(1, 4):
    print(f"irq_routines_table_align_{frame}:")
    state2 = state.clone()
    state2.advance_by(
        alignment_offset,
        last_routine_one_step="irq_routine_one_step_align",
        last_routine_two_step="irq_routine_two_step_align",
        last_routine_additional_args=[f"lo(irq_routines_table_align_{frame - 1})"],
    )
    state2.frame()
