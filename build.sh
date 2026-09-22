#!/usr/bin/env bash
# Build and verify the four colour theorem from a bare checkout.
#
#   1. Mathlib, from the central cache.
#   2. `lake build`: Lean elaborates every module with its kernel switched off (lakefile).
#   3. `scripts/verify.sh`: lean4export writes the theorem's dependency closure and lazylean
#      checks every declaration of it (the 633 reducibility checks one process each).
#   4. `scripts/check.sh`: no `sorry`, no `native_decide`, the theorem's axioms, the negative
#      controls, and the verification summary.
#
# Needs lazylean and lean4export built (LAZYLEAN and LEAN4EXPORT point at the binaries).
set -euo pipefail
cd "$(dirname "$0")"
echo "== Mathlib (from the cache)"; lake exe cache get
echo "== elaboration"; lake build FourColor FourColor.Audit
echo "== verification with lazylean"; scripts/verify.sh "${1:-verification/run}"
echo "== checks"; exec scripts/check.sh "${1:-verification/run}"
