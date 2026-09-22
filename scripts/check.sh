#!/usr/bin/env bash
# Fail if any module contains a `sorry` or depends on a non-standard axiom, or if the
# development has not been verified by lazylean.
set -uo pipefail
cd "$(dirname "$0")/.."

# `sorry` as code, not as documentation: a module docstring may legitimately
# say a development contains no `sorry`, and that must not trip the check.  A
# real `sorry` would also show up as `sorryAx` in the axiom check below, so this
# grep is the early warning rather than the guarantee.
if grep -rn --include='*.lean' -E '\bsorry\b' FourColor/ FourColor.lean scripts/*.lean | grep -v '`sorry`' ; then
  echo "FAIL: sorry found" >&2; exit 1
fi

# Constructs that would put something beyond the kernel into the trusted base,
# or that a mathlib reviewer would reject on sight.  `native_decide` trusts the
# compiler; `axiom` adds to the base directly; `unsafe`/`opaque`/`partial` and
# the code-generator attributes all mean a definition the kernel cannot see
# through.  None of these is acceptable in a proof meant to be believed.
# `[[:space:]]*` rather than ` *`, so a tab-indented `axiom` cannot slip past;
# `sorryAx` is listed separately because `\bsorry\b` does not match it; and
# `debug.skipKernelTC` is set once, in lakefile.toml, because lazylean is the kernel here; a
# module that set it itself would be hiding something, so it is named explicitly.
if grep -rn --include='*.lean' -E \
    '\bnative_decide\b|\bsorryAx\b|^[[:space:]]*(private |protected |noncomputable )*axiom |\bpartial def\b|\bunsafe\b|^[[:space:]]*opaque |@\[implemented_by|@\[extern|debug\.skipKernelTC' \
    FourColor/ FourColor.lean scripts/*.lean ; then
  echo "FAIL: native_decide, sorryAx, axiom, partial, unsafe, opaque, skipKernelTC or a code-generator attribute found" >&2
  exit 1
fi

# Scratch files must not ship: they are not reachable from the root module, so
# they never enter `lake build`, but a reader finding them would reasonably ask
# what they are doing in a finished development.
if ls FourColor/Research*.lean FourColor/*Probe*.lean >/dev/null 2>&1; then
  echo "FAIL: scratch modules still present:" >&2
  ls FourColor/Research*.lean FourColor/*Probe*.lean 2>/dev/null >&2
  exit 1
fi

# The build: Lean elaborates with its kernel off (lakefile.toml), so this is fast and proves
# nothing by itself; the proof is checked by lazylean in scripts/verify.sh, whose summary is
# demanded below.
lake build FourColor FourColor.Audit || { echo "FAIL: build" >&2; exit 1; }

# Anti-vacuity negative controls: FourColor/Audit.lean.  Each theorem there says some checker
# the proof relies on answers `false` somewhere; they are exported with the theorem and
# checked by lazylean like everything else, so here it is enough that the module elaborates
# (above) and that the verification run accepted them (below).
out=$(lake env lean scripts/Check.lean 2>&1); rc=$?
echo "$out"
if [ $rc -ne 0 ]; then
  echo "FAIL: axiom check exited $rc" >&2; exit 1
fi
if echo "$out" | grep -qE 'error|sorryAx|ofReduceBool'; then
  echo "FAIL: axiom check" >&2; exit 1
fi
# Check.lean reports THEOREM OUTSTANDING, not an error, when the theorem is
# absent -- so a build that dropped it would otherwise pass here in silence.
# Demand the positive statement rather than the absence of a negative one.
if ! echo "$out" | grep -q 'THEOREM PROVED: FourColor.fourColorTheorem'; then
  echo "FAIL: the theorem was not proved in this build" >&2; exit 1
fi

# Check.lean ran inside Lean, whose kernel is off: it establishes the axioms and the statement,
# not that the proofs are correct.  That is the verification run's job, and the audit theorems
# are checked there with the rest; its summary must say every declaration was accepted.
RUN=${1:-verification/run}
if ! grep -q 'RESULT: every declaration accepted by lazylean' "$RUN/SUMMARY.md" 2>/dev/null; then
  echo "FAIL: no clean lazylean verification in $RUN (run scripts/verify.sh)" >&2; exit 1
fi
grep -c 'audit_' "$RUN/red_names.txt" >/dev/null 2>&1 || true
echo "VERIFIED BY LAZYLEAN: $(grep -m1 'declarations checked' "$RUN/SUMMARY.md")"
