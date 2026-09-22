import FourColor.Reducible.Job215to218
import FourColor.Reducible.Job219to222
import FourColor.Reducible.Job223to226
import FourColor.Reducible.Job227to230
import FourColor.Reducible.Job231to234

/-!
Reducibility of configurations 215 to 234: the reference's `task215to234.v`,
chaining the job files with `cat_reducible_range` as its `CatReducible` tactic does.
-/

namespace FourColor

/-- Configurations 215 to 234 are reducible. -/
theorem red214to234 : ReducibleInRange 214 234 theConfigs :=
  (cat_reducible_range
    (cat_reducible_range
      (cat_reducible_range
        (cat_reducible_range
          red214to218
          red218to222)
        red222to226)
      red226to230)
    red230to234)

end FourColor
