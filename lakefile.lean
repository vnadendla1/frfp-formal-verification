import Lake
open Lake DSL

package frfp where
  -- Package configuration

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"

@[default_target]
lean_lib Frfp where
  -- Library configuration

lean_lib Example where
  -- Example library

lean_exe FRFPReport where
  root := `FRFPReport

lean_exe SepsisExample where
  root := `Example.Sepsis
