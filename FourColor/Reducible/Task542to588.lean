import FourColor.Reducible.Job542to545
import FourColor.Reducible.Job546to549
import FourColor.Reducible.Job550to553
import FourColor.Reducible.Job554to562
import FourColor.Reducible.Job563to588

/-!
Reducibility of configurations 542 to 588: the reference's `task542to588.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 542 to 588 are reducible. -/
theorem red541to588 : ReducibleInRange 541 588 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red541to545
          red545to549)
        red549to553)
      red553to562)
    red562to588)

end FourColor
