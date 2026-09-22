#!/usr/bin/env python3
"""Check the 633 reducibility theorems with lazylean, one process per declaration, under a
memory budget: the ring-14 configurations need about 21 GB each and the ring-13 ones about
4.5 GB, so a fixed process count would either idle the machine or overrun it.

Usage: schedule_reducible.py EXPORT OUTDIR --names NAMES --rings RINGS [--jobs N] [--memory GB]
NAMES: one declaration name per line (every declaration whose name starts with
FourColor.red_cf: the theorem and the auxiliary lemma `decide +kernel` created for it).
RINGS: lines `cfNNN <ring size>` from scripts/RingSizes.lean.  Results: OUTDIR/results.tsv
(name, ring, seconds, MB, exit status) and OUTDIR/<name>.log."""
import argparse, os, re, subprocess, sys, time, heapq
ap = argparse.ArgumentParser()
ap.add_argument('export'); ap.add_argument('outdir')
ap.add_argument('--names', required=True); ap.add_argument('--rings', required=True)
ap.add_argument('--jobs', type=int, default=max(1, os.cpu_count() - 12))
ap.add_argument('--memory', type=float, default=180.0, help='GB the running checks may hold together')
ap.add_argument('--lazylean', default=os.path.expanduser('~/lazylean/build/lazylean'))
a = ap.parse_args()
os.makedirs(a.outdir, exist_ok=True)
rings = {}
for l in open(a.rings):
    m = re.match(r'cf(\d+)\s+(\d+)', l.strip())
    if m: rings[int(m.group(1))] = int(m.group(2))
# predicted peak memory (GB) and time (s) by ring size, from the ladder in the README
mem = {14: 24, 13: 6, 12: 2, 11: 1, 10: 0.5}
def pred_mem(r): return mem.get(r, 0.4)
jobs = []
for l in open(a.names):
    n = l.strip()
    if not n: continue
    m = re.search(r'red_cf(\d+)', n)
    cf = int(m.group(1)); r = rings[cf]
    aux = '_' in n[n.index('red_cf') + 9:]   # the auxiliary lemma carries the computation
    jobs.append((-(r if aux else 0), n, r, aux))
jobs.sort()   # heaviest first
resf = os.path.join(a.outdir, 'results.tsv')
already = set()
if os.path.exists(resf):
    for l in open(resf):
        f = l.split('\t')
        if len(f) >= 5 and f[4].strip() == '0': already.add(f[0])
jobs = [j for j in jobs if j[1] not in already]   # a restarted run keeps what it has
if already: print(f"{len(already)} already done", flush=True)
done = open(resf, 'a')
running = []   # (proc, name, ring, aux, t0, mem)
used = 0.0
def reap():
    global used
    for it in running[:]:
        p, n, r, aux, t0, m = it
        if p.poll() is not None:
            running.remove(it); used -= m
            s, kb = open(os.path.join(a.outdir, n + '.time')).read().split()[:2]
            done.write(f"{n}\t{r}\t{s}\t{int(kb)//1024}\t{p.returncode}\n"); done.flush()
            print(f"done {n} ring {r} {s} s {int(kb)//1024} MB rc={p.returncode}", flush=True)
while jobs or running:
    reap()
    while jobs and len(running) < a.jobs:
        _, n, r, aux = jobs[0]
        m = pred_mem(r) if aux else 0.2
        if used + m > a.memory and running: break
        jobs.pop(0)
        env = dict(os.environ, LL_ORIG='none', LL_MEMO='0')
        cmd = ['/usr/bin/time', '-f', '%e %M', '-o', os.path.join(a.outdir, n + '.time'),
               a.lazylean, '--only', n, '--max-rss', str(int(max(m, 1) * 1024 * 2)), a.export]
        p = subprocess.Popen(cmd, stdout=open(os.path.join(a.outdir, n + '.log'), 'w'), stderr=subprocess.STDOUT, env=env)
        running.append((p, n, r, aux, time.time(), m)); used += m
        print(f"start {n} ring {r} (running {len(running)}, budget {used:.1f} GB)", flush=True)
    time.sleep(2)
print("ALL DONE")
