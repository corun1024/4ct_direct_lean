import FourColor.Reducible.Job001to106
import FourColor.Reducible.Job107to164
import FourColor.Reducible.Job165to189
import FourColor.Reducible.Job190to206
import FourColor.Reducible.Job207to214

/-!
Reducibility of configurations 1 to 214: the reference's `task001to214.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 1 to 214 are reducible. -/
theorem red000to214 : ReducibleInRange 0 214 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red000to106
          red106to164)
        red164to189)
      red189to206)
    red206to214)

end FourColor
