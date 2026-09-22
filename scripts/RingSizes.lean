import FourColor.CfReducible
import FourColor.Configurations

/-! Prints `cfNNN <ring size>` for every configuration, for `scripts/schedule_reducible.py`:
the cost of a reducibility check grows about fourfold per ring size. -/

open FourColor in
#eval show IO Unit from do
  for i in List.range theConfigs.length do
    IO.println s!"cf{i + 1} {cprsize theConfigs[i]!.prog}"
