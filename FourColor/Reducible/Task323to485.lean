import FourColor.Reducible.Job323to383
import FourColor.Reducible.Job384to398
import FourColor.Reducible.Job399to438
import FourColor.Reducible.Job439to465
import FourColor.Reducible.Job466to485

/-!
Reducibility of configurations 323 to 485: the reference's `task323to485.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 323 to 485 are reducible. -/
theorem red322to485 : ReducibleInRange 322 485 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red322to383
          red383to398)
        red398to438)
      red438to465)
    red465to485)

end FourColor
