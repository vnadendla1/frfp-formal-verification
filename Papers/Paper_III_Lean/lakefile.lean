import Lake
open Lake DSL
package frfpMerge where
require mathlib from git "https://github.com/leanprover-community/mathlib4.git" @ "v4.29.0"
lean_lib Frfp
lean_lib AlgebraOfHumanAiCollaboration
lean_lib ETSplit
@[default_target]
lean_lib FRFPMerge

-- Paper-side revision, isolated from the frozen main FRFP specification.
lean_lib FirstPrinciplesRevision

-- Paper III verification, independent of legacy main FRFP.
lean_lib PaperIII

-- Chapter 1 owns the first-principles application.
lean_lib FRFPChapter1
