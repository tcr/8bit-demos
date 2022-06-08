from math import floor


rate = 0
cpu = 0
frame_count = 0

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

CPU_FRAME = 29780

def frame():
    global frame_count
    # add one cpu clock each other frame
    frame_count += 1
    print(cpu, '    missing cycles:', (CPU_FRAME * frame_count) + (floor(frame_count / 2)) - cpu)

def reset(p0):
    global rate, cpu
    rate = p0
    cpu = 0

def step(p1_2):
    global rate, cpu
    cpu += rate
    cpu += p1_2 * 7
    rate = p1_2
    

def two_step(p1, p2):
    global rate, cpu
    cpu += rate
    cpu += p1
    cpu += p2 * 6
    rate = p2



# run game

def run_kernel():
    for i in range(0, 5):
        two_step(r84, r54)
        two_step(r72, r54)
        two_step(r72, r54)
        two_step(r84, r54)
        two_step(r72, r54)
        two_step(r72, r54)
        two_step(r84, r54)
        two_step(r72, r54)

    two_step(r84, r54)
    two_step(r72, r54)
    two_step(r72, r54)
    two_step(r84, r54)
    two_step(r72, r54)
    # two_step(r72, r54)
    two_step(r84, r54)
    two_step(r72, r54)

    two_step(r84, r54)
    two_step(r72, r54)
    two_step(r72, r54)
    two_step(r84, r54)
    two_step(r72, r54)

reset(r54)

run_kernel()
step(r428)
step(r214)
step(r54)
two_step(r190, r54)
frame()

run_kernel()
step(r380)
step(r226)
step(r106)
two_step(r72, r54)
frame()

run_kernel()
step(r428)
step(r214)
step(r54)
two_step(r190, r54)
frame()

run_kernel()
step(r428)
step(r214)
step(r72)
two_step(r54, r54)
frame()
