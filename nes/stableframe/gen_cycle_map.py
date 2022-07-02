# python gen_cycle_map.py > cycle_map.py

from itertools import product, chain

R1 = [54, 72, 84, 106, 128, 160, 190, 214, 226, 254, 286, 320, 340, 380, 428]
R1rev = list(R1)
R1rev.reverse()

R1twostep = [[e, 54] for e in R1rev]


def nested_product(lst):
    lst_positions = [l for l in lst if isinstance(l, list)]
    for p in product(*lst_positions):
        it = iter(p)
        yield [e if not isinstance(e, list) else next(it) for e in lst]


def step(args):
    last = 54
    acc = 0
    for arg in args:
        if isinstance(arg, list):
            acc += last
            acc += arg[0]
            last = arg[1]
            acc += last * 6
        else:
            acc += last
            last = arg
            acc += last * 7
    return acc


fit = dict()


def fit_set(arg):
    global fit
    s = step(arg)
    if s in fit:
        if len(fit[s]) > len(arg):
            fit[s] = arg
    else:
        fit[s] = arg


for pr in nested_product([[54]]):
    fit_set(pr)
for pr in nested_product([R1rev, [54]]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, [54]]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, R1rev, [54]]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, R1rev, R1rev, [54]]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, R1rev, R1rev, R1rev, [54]]):
    fit_set(pr)
for pr in nested_product([R1twostep]):
    fit_set(pr)
for pr in nested_product([[54, 72], R1twostep]):
    fit_set(pr)
for pr in nested_product([R1rev, [54, 72], R1twostep]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, [54, 72], R1twostep]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, R1rev, [54, 72], R1twostep]):
    fit_set(pr)
for pr in nested_product([R1rev, R1rev, R1rev, R1rev, [54, 72], R1twostep]):
    fit_set(pr)

fit_keys = sorted(fit.keys())
print("cycle_map = dict([")
for key in fit_keys:
    print(f"    ({key}, {fit[key]}),")
print("])")

# print(json.dumps(fit))
