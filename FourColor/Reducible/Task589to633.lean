import FourColor.Reducible.Job589to610
import FourColor.Reducible.Job611to617
import FourColor.Reducible.Job618to622
import FourColor.Reducible.Job623to633

/-!
Reducibility of configurations 589 to 633: the reference's `task589to633.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 589 to 633 are reducible. -/
theorem red588to633 : ReducibleInRange 588 633 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        red588to610
        red610to617)
      red617to622)
    red622to633)

end FourColor
