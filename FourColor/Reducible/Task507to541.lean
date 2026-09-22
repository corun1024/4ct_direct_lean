import FourColor.Reducible.Job507to510
import FourColor.Reducible.Job511to516
import FourColor.Reducible.Job517to530
import FourColor.Reducible.Job531to534
import FourColor.Reducible.Job535to541

/-!
Reducibility of configurations 507 to 541: the reference's `task507to541.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 507 to 541 are reducible. -/
theorem red506to541 : ReducibleInRange 506 541 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red506to510
          red510to516)
        red516to530)
      red530to534)
    red534to541)

end FourColor
