import FourColor.Reducible.Task001to214
import FourColor.Reducible.Task215to234
import FourColor.Reducible.Task235to282
import FourColor.Reducible.Task283to302
import FourColor.Reducible.Task303to322
import FourColor.Reducible.Task323to485
import FourColor.Reducible.Task486to506
import FourColor.Reducible.Task507to541
import FourColor.Reducible.Task542to588
import FourColor.Reducible.Task589to633

/-!
Every configuration is reducible: the reference's `reducibility.v`.
-/

namespace FourColor

/-- Configurations 1 to 633 are reducible. -/
theorem red000to633 : ReducibleInRange 0 633 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          (cat_reducible_range
            (cat_reducible_range
              (cat_reducible_range
                (cat_reducible_range
                  (cat_reducible_range
                    red000to214
                    red214to234)
                  red234to282)
                red282to302)
              red302to322)
            red322to485)
          red485to506)
        red506to541)
      red541to588)
    red588to633)

/-- Every one of the 633 configurations is reducible: the hypothesis `Complete.lean`
consumes. -/
theorem reducible_all : ReducibleInRange 0 633 theConfigs := red000to633

end FourColor
