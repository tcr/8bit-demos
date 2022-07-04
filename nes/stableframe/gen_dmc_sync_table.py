# Generate the DMC sync lookup table for the initial sync handler.

import sys

RATES = [428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 84, 72, 54]

# Change the DMC rate up to this many times in the handler.
# This should match the number of times the code expects to update DMCFREQ.
max_steps = 4

if len(sys.argv) < 2:
    print("error: expected target cycles for dmc sync table. example:", file=sys.stderr)
    print(file=sys.stderr)
    print("    python gen_dmc_sync.py 922 > src/dmc_sync_table.asm", file=sys.stderr)
    print(file=sys.stderr)
    print("possible values:", file=sys.stderr)

    start_cycles = range(0, 54 * 8, 2)
    results = []
    for start in start_cycles:
        last_values = set()
        values = set([start])
        for _ in range(0, max_steps):
            last_values = values
            values = set()
            for l in last_values:
                for r in RATES:
                    values.add(l + r)
        results.append(values)

    first = results.pop()
    print(sorted(list(first.intersection(*results))), file=sys.stderr)
    sys.exit(1)

TARGET_CYCLES = int(sys.argv[1])

start_cycles = range(0, 54 * 8, 2)
results = dict()
for start in start_cycles:
    last_values = list()
    values = list([[start]])
    for _ in range(0, max_steps):
        last_values = values
        values = list()
        for l in last_values:
            for r in RATES:
                l2 = list(l)
                l2.append(r)
                values.append(l2)

    for l2 in values:
        if sum(l2) == TARGET_CYCLES:
            results[start] = ["".join([hex(RATES.index(x))[2:] for x in l2[1:]]), l2]
            break

print(f"; python gen_dmc_sync.py {TARGET_CYCLES} > src/dmc_sync.asm")
print()
print("    align 256")
print("dmc_sync_1_2:")
for k in results.keys():
    print(
        f"    byt ${results[k][0][0:2]}   ; index ${hex(int(k/2))[2:]} => {results[k][1]} = {sum(results[k][1])}"
    )
print()
print("    align 256")
print("dmc_sync_3_4:")
for k in results.keys():
    print(
        f"    byt ${results[k][0][2:4]}   ; index ${hex(int(k/2))[2:]} => {results[k][1]} = {sum(results[k][1])}"
    )
