import FourColor.Reducible.Job235to238
import FourColor.Reducible.Job239to253
import FourColor.Reducible.Job254to270
import FourColor.Reducible.Job271to278
import FourColor.Reducible.Job279to282

/-!
Reducibility of configurations 235 to 282: the reference's `task235to282.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 235 to 282 are reducible. -/
theorem red234to282 : ReducibleInRange 234 282 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red234to238
          red238to253)
        red253to270)
      red270to278)
    red278to282)

end FourColor
