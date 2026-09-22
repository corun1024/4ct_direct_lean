import FourColor.Reducible.Job486to489
import FourColor.Reducible.Job490to494
import FourColor.Reducible.Job495to498
import FourColor.Reducible.Job499to502
import FourColor.Reducible.Job503to506

/-!
Reducibility of configurations 486 to 506: the reference's `task486to506.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 486 to 506 are reducible. -/
theorem red485to506 : ReducibleInRange 485 506 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red485to489
          red489to494)
        red494to498)
      red498to502)
    red502to506)

end FourColor
