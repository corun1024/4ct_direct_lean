import FourColor.Reducible.Job303to306
import FourColor.Reducible.Job307to310
import FourColor.Reducible.Job311to314
import FourColor.Reducible.Job315to318
import FourColor.Reducible.Job319to322

/-!
Reducibility of configurations 303 to 322: the reference's `task303to322.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 303 to 322 are reducible. -/
theorem red302to322 : ReducibleInRange 302 322 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red302to306
          red306to310)
        red310to314)
      red314to318)
    red318to322)

end FourColor
