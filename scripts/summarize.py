#!/usr/bin/env python3
"""Summarise a scripts/verify.sh run and fail unless every declaration was accepted.
Prints Markdown; exit status 1 on any failure."""
import glob, json, os, re, subprocess, sys
out = sys.argv[1]
ok = True
print(f"# Verification summary ({out})\n")
# step 2
total_checked = total_failed = 0; secs = []; mems = []
for f in sorted(glob.glob(f"{out}/shards/*.log")):
    m = re.search(r'^checked (\d+) declarations, (\d+) failed, (\d+) added unchecked, in ([\d.]+)s', open(f).read(), re.M)
    t = open(f[:-4] + '.time').read().split()
    if not m: print(f"- shard {f}: no result line"); ok = False; continue
    total_checked += int(m.group(1)); total_failed += int(m.group(2)); secs.append(float(t[0])); mems.append(int(t[1]) // 1024)
    if int(m.group(2)): ok = False
    for l in open(f):
        if l.startswith('FAIL'): print(f"- {l.strip()[:200]}")
print(f"## The closure\n\n{len(secs)} shards: {total_checked} declarations checked, {total_failed} failed; "
      f"wall {max(secs):.0f} s, CPU {sum(secs)/3600:.2f} h, peak {max(mems)} MB per shard.\n")
# step 3
rows = []
for l in open(f"{out}/red/results.tsv"):
    n, r, s, mb, rc = l.strip().split('\t'); rows.append((n, int(r), float(s), int(mb), int(rc)))
names = set(x.strip() for x in open(f"{out}/red_names.txt") if x.strip())
seen = set(n for n, *_ in rows)
missing = names - seen; bad = [x for x in rows if x[4] != 0]
if missing: print(f"- MISSING reducibility results: {len(missing)}"); ok = False
if bad: ok = False
for x in bad: print(f"- FAIL {x[0]} rc={x[4]}")
aux = [x for x in rows if '_' in x[0][x[0].index('red_cf') + 9:]]
print(f"## The 633 reducibility checks\n\n{len(rows)} declarations ({len(aux)} carrying the computation), "
      f"{len(bad)} failed; CPU {sum(x[2] for x in rows)/3600:.2f} h, peak {max(x[3] for x in rows)} MB.\n")
print("| ring size | configurations | total CPU | slowest | peak memory |\n|---|---|---|---|---|")
for r in sorted(set(x[1] for x in aux)):
    xs = [x for x in aux if x[1] == r]
    print(f"| {r} | {len(xs)} | {sum(x[2] for x in xs):.0f} s | {max(x[2] for x in xs):.0f} s | {max(x[3] for x in xs)} MB |")
print("\nSlowest:\n")
for x in sorted(aux, key=lambda x: -x[2])[:8]: print(f"- {x[0]}: ring {x[1]}, {x[2]:.0f} s, {x[3]} MB")
# axioms declared in the export
nm = {0: ''}; axioms = []
for line in open(f"{out}/fourcolor.ndjson"):
    o = json.loads(line)
    if 'in' in o:
        s = o.get('str'); nm[o['in']] = (nm[s['pre']] + '.' + s['str']).lstrip('.') if s else nm[o['num']['pre']] + '.' + str(o['num']['i'])
    elif 'axiom' in o: axioms.append(nm[o['axiom']['name']])
allowed = {'propext', 'Classical.choice', 'Quot.sound'}
print(f"\n## Axioms\n\nThe export declares: {', '.join(sorted(axioms))}.")
if set(axioms) - allowed: print("- NON-STANDARD AXIOM"); ok = False
# the theorem's type
ll = os.environ.get('LAZYLEAN', os.path.expanduser('~/lazylean/build/lazylean'))
p = subprocess.run([ll, '--print', 'FourColor.fourColorTheorem', f"{out}/fourcolor.ndjson"], capture_output=True, text=True)
ty = [l for l in p.stdout.splitlines() + p.stderr.splitlines() if l.startswith('== FourColor.fourColorTheorem')]
print(f"\n## The theorem\n\n`{ty[0] if ty else 'NOT FOUND'}`")
if not ty or 'FourColor.FourColorTheorem' not in ty[0]: ok = False
print("\n**RESULT:", "every declaration accepted by lazylean**" if ok else "FAILED**")
sys.exit(0 if ok else 1)
