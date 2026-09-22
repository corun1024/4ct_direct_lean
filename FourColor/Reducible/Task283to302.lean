import FourColor.Reducible.Job283to286
import FourColor.Reducible.Job287to290
import FourColor.Reducible.Job291to294
import FourColor.Reducible.Job295to298
import FourColor.Reducible.Job299to302

/-!
Reducibility of configurations 283 to 302: the reference's `task283to302.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 283 to 302 are reducible. -/
theorem red282to302 : ReducibleInRange 282 302 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red282to286
          red286to290)
        red290to294)
      red294to298)
    red298to302)

end FourColor
