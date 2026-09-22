#!/usr/bin/env bash
# Check the whole development with lazylean.
#
#   scripts/verify.sh [outdir]      default outdir: verification/run
#
# Lean's kernel is switched off in the lakefile, so `lake build` only elaborates.  This script
# is where the proof is checked:
#
#   1. export the dependency closure of `FourColor.fourColorTheorem` and of the audit theorems
#      (fourcolor.ndjson), and the closure of the 633 reducibility theorems alone
#      (reducible.ndjson, a few megabytes);
#   2. lazylean checks fourcolor.ndjson in SHARDS shards, with the reducibility theorems
#      (every declaration named FourColor.red_cf*) listed as trusted, so that each is checked
#      exactly once, in step 3;
#   3. lazylean checks every reducibility declaration on its own from reducible.ndjson,
#      scheduled by ring size under a memory budget (scripts/schedule_reducible.py);
#   4. scripts/summarize.py demands 0 failures in both, lists the axioms the export declares,
#      and prints the theorem's type; the summary lands in outdir/SUMMARY.md.
#
# Environment: LAZYLEAN, LEAN4EXPORT (binaries), SHARDS (default 16), JOBS and MEMORY_GB for
# step 3, MAXRSS_MB per shard in step 2 (default 24000).
set -euo pipefail
cd "$(dirname "$0")/.."
OUT=${1:-verification/run}; mkdir -p "$OUT"
LL=${LAZYLEAN:-$HOME/lazylean/build/lazylean}
EXP=${LEAN4EXPORT:-$HOME/lean4export/.lake/build/bin/lean4export}
SHARDS=${SHARDS:-16}
export PATH="$HOME/.elan/bin:$PATH"
[ -x "$LL" ] || { echo "lazylean not found at $LL (LAZYLEAN=...)" >&2; exit 1; }
[ -x "$EXP" ] || { echo "lean4export not found at $EXP (LEAN4EXPORT=...)" >&2; exit 1; }

date; echo "== 1. export"
AUDIT=$(grep -oE '^theorem (audit_[A-Za-z0-9_]+|twoPoints_[A-Za-z0-9_]+)' FourColor/Audit.lean | sed 's/theorem /FourColor./' | tr '\n' ' ')
lake env "$EXP" FourColor.Audit -- FourColor.fourColorTheorem $AUDIT > "$OUT/fourcolor.ndjson"
RED=$(grep -ohE '^theorem red_cf[0-9]+' FourColor/Reducible/Job*.lean | sed 's/theorem /FourColor./' | tr '\n' ' ')
lake env "$EXP" FourColor.Reducible.All -- $RED > "$OUT/reducible.ndjson"
ls -la "$OUT"/*.ndjson
# every declaration whose name starts with FourColor.red_cf: the theorems and their `decide +kernel` lemmas
python3 - "$OUT" <<'PY'
import json, sys, re
out = sys.argv[1]
names = set()
for f in ('fourcolor.ndjson', 'reducible.ndjson'):
    nm = {0: ''}
    for line in open(f"{out}/{f}"):
        o = json.loads(line)
        if 'in' in o:
            s = o.get('str'); nm[o['in']] = (nm[s['pre']] + '.' + s['str']).lstrip('.') if s else nm[o['num']['pre']] + '.' + str(o['num']['i'])
            continue
        for k in ('thm', 'def', 'axiom', 'opaque'):
            if k in o:
                n = nm[o[k]['name']]
                if n.startswith('FourColor.red_cf'): names.add(n)
open(f"{out}/red_names.txt", 'w').write('\n'.join(sorted(names)) + '\n')
print(len(names), 'reducibility declarations')
PY
lake env lean scripts/RingSizes.lean > "$OUT/ring_sizes.tsv"
wc -l "$OUT/ring_sizes.tsv"

date; echo "== 2. the closure, $SHARDS shards, reducibility theorems trusted here"
mkdir -p "$OUT/shards"
seq 0 $((SHARDS-1)) | xargs -P "$SHARDS" -I{} sh -c "/usr/bin/time -f '%e %M' -o $OUT/shards/{}.time $LL -k --memo --max-rss ${MAXRSS_MB:-24000} --trust-file $OUT/red_names.txt --progress $OUT/shards/{}.progress --shard {}/$SHARDS $OUT/fourcolor.ndjson > $OUT/shards/{}.log 2>&1"
grep -h "^checked" "$OUT"/shards/*.log

date; echo "== 3. the 633 reducibility checks, one process each"
scripts/schedule_reducible.py "$OUT/reducible.ndjson" "$OUT/red" --names "$OUT/red_names.txt" --rings "$OUT/ring_sizes.tsv" \
  --lazylean "$LL" ${JOBS:+--jobs $JOBS} ${MEMORY_GB:+--memory $MEMORY_GB} > "$OUT/red_schedule.log" 2>&1
tail -1 "$OUT/red_schedule.log"

date; echo "== 4. summary"
LAZYLEAN="$LL" python3 scripts/summarize.py "$OUT" | tee "$OUT/SUMMARY.md"
