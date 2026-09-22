# Verification summary (verification/run)

## The closure

16 shards: 136499 declarations checked, 0 failed; wall 128 s, CPU 0.51 h, peak 1015 MB per shard.

## The 633 reducibility checks

1266 declarations (633 carrying the computation), 0 failed; CPU 76.94 h, peak 34318 MB.

| ring size | configurations | total CPU | slowest | peak memory |
|---|---|---|---|---|
| 6 | 1 | 1 s | 1 s | 35 MB |
| 7 | 1 | 1 s | 1 s | 38 MB |
| 8 | 5 | 7 s | 2 s | 44 MB |
| 9 | 8 | 30 s | 4 s | 68 MB |
| 10 | 31 | 419 s | 18 s | 149 MB |
| 11 | 81 | 4543 s | 92 s | 602 MB |
| 12 | 175 | 40286 s | 351 s | 2170 MB |
| 13 | 194 | 77835 s | 851 s | 7426 MB |
| 14 | 137 | 153534 s | 1505 s | 34318 MB |

Slowest:

- FourColor.red_cf613._proof_1_1: ring 14, 1505 s, 31639 MB
- FourColor.red_cf281._proof_1_1: ring 14, 1494 s, 34318 MB
- FourColor.red_cf564._proof_1_1: ring 14, 1476 s, 30029 MB
- FourColor.red_cf219._proof_1_1: ring 14, 1475 s, 32060 MB
- FourColor.red_cf562._proof_1_1: ring 14, 1456 s, 31528 MB
- FourColor.red_cf543._proof_1_1: ring 14, 1345 s, 27009 MB
- FourColor.red_cf614._proof_1_1: ring 14, 1345 s, 26367 MB
- FourColor.red_cf288._proof_1_1: ring 14, 1325 s, 27531 MB

## Axioms

The export declares: Classical.choice, Quot.sound, propext.

## The theorem

`== FourColor.fourColorTheorem : FourColor.FourColorTheorem`

**RESULT: every declaration accepted by lazylean**
