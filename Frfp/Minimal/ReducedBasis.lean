import Frfp.Core.Kernel

/-!
Reduced FRFP basis for new projects (kept separate from Core).

Goal: keep only irreducible assumptions, while deriving everything possible
from the existing Kernel definitions/theorems.

This module does NOT modify Core and can be imported independently.
-/

namespace Frfp.Minimal.ReducedBasis

open Frfp.Core.Kernel

/-!
Published-source buckets for non-FRFP mathematical assumptions used by
higher layers (probability, rewriting, category theory, floating-point).

These are included as metadata for project governance; this module itself
does not postulate any of them as axioms.
-/
inductive PublishedSource where
  | ieee754_2019
  | billingsley_1995
  | durrett_2019
  | baader_nipkow_1998
  | newman_1942
  | mac_lane_1971
  | rudin_1976
  | pnueli_1977
  | alpern_schneider_1985
  deriving Repr, DecidableEq

/--
Core assumptions that remain irreducible after kernel-level derivations.

Dropped from primitive status in this reduced basis because derivable from
Kernel: ETS, RB, AE.
-/
structure CoreIrreducible where
  /-- Human-Exclusive Grounding -/
  HEG : Prop
  /-- Human-Exclusive Closure -/
  HEC : Prop
  /-- Compositional Pipelines -/
  CP : Prop

/--
Interaction assumptions kept as policy premises in the reduced basis.

`MD` is not kept primitive here; it is derivable from kernel typing +
AI/human primitive partitions.
-/
structure InteractionIrreducible where
  /-- Intent Locking -/
  IL : Prop
  /-- Ambiguity Resolution -/
  AR : Prop
  /-- No Tacit Emulation/Reconstruction -/
  NTER : Prop
  /-- Correctness Stability Constraint -/
  CSC : Prop

/--
Combined reduced assumption profile for a standalone project.
-/
structure ReducedProfile where
  core : CoreIrreducible
  interaction : InteractionIrreducible
  references : List PublishedSource := []

/-- Primitive assumptions retained in the minimal FRFP+interaction basis. -/
def minimalPrimitiveNames : List String :=
  ["HEG", "HEC", "CP", "IL", "AR", "NTER", "CSC"]

/--
External assumption families and their canonical published-source anchors.
These are optional imports for projects that need advanced modules beyond
kernel+interaction.
-/
def sourceBackedFamilies : List (String × PublishedSource) :=
  [ ("Float arithmetic/order axioms", PublishedSource.ieee754_2019)
  , ("Probability/stopping-time axioms", PublishedSource.billingsley_1995)
  , ("Stochastic process tail bounds", PublishedSource.durrett_2019)
  , ("Term rewriting and normalization", PublishedSource.baader_nipkow_1998)
  , ("Termination + local confluence => confluence", PublishedSource.newman_1942)
  , ("Category/groupoid structural axioms", PublishedSource.mac_lane_1971)
  , ("Geometric limit-to-zero lemma", PublishedSource.rudin_1976)
  , ("Temporal safety/invariance over traces", PublishedSource.pnueli_1977)
  , ("Safety vs liveness decomposition", PublishedSource.alpern_schneider_1985)
  ]

/-!
Derivable FRFP/Core constraints (no new axioms required)
-/

/-- ETS derivable directly from kernel primitive typing. -/
theorem ETS_derivable (p : Primitive) :
    ¬(p.source = Object.T0 ∧ p.target = Object.E0) :=
  no_morphism_T0_to_E0 p

/-- RB uniqueness derivable directly from kernel primitive enumeration/typing. -/
theorem RB_derivable (p : Primitive) :
    (p.source = Object.E0 ∧ p.target = Object.T0) → p = Primitive.RB :=
  RB_unique_boundary p

/-- AE derivable from kernel AI-executable primitive partition. -/
theorem AE_derivable (p : Primitive) :
    is_AI_executable p = true →
    (p.source = Object.E0 ∨ p.source = Object.empty) ∧ p.target = Object.E0 :=
  AI_preserves_explicit p

/--
Mode discipline as a derived typing rule:
- AI-executable primitives always target explicit space E0.
- Human-only primitives always target tacit space T0.
-/
theorem MD_derivable :
    (∀ p : Primitive, is_AI_executable p = true → p.target = Object.E0) ∧
    (∀ p : Primitive, is_human_only p = true → p.target = Object.T0) := by
  constructor
  · intro p hAI
    exact (AE_derivable p hAI).2
  · intro p hHuman
    cases p <;> simp [is_human_only] at hHuman

/--
Smallest reduced FRFP + Interaction basis for new projects using Kernel:
primitive assumptions = {HEG, HEC, CP, IL, AR, NTER, CSC}.
Everything else in this file is derivable from `Frfp.Core.Kernel`.
-/
def minimalPrimitiveCount : Nat := 7

/-!
Decomposition of the seven primitive assumptions:
- `skeleton`: the mathematically structural part we can derive or anchor.
- `residue`: irreducible normative/policy commitment.

This lets new projects separate mathematical obligations from governance
premises without changing Core.
-/

inductive DecompositionStatus where
  | skeletonDerivable
  | skeletonSourceAnchored
  | policyOnly
  deriving Repr, DecidableEq

/-- HEG skeleton: grounding operators live in tacit codomain. -/
def HEG_skeleton : Prop :=
  Primitive.TE.target = Object.T0 ∧ Primitive.HFD.target = Object.T0

theorem HEG_skeleton_derivable : HEG_skeleton := by
  simp [HEG_skeleton, Primitive.target]

/-- HEC skeleton: final closure primitive is tacit-space endomorphism. -/
def HEC_skeleton : Prop :=
  Primitive.HFD.source = Object.T0 ∧ Primitive.HFD.target = Object.T0

theorem HEC_skeleton_derivable : HEC_skeleton := by
  simp [HEC_skeleton, Primitive.source, Primitive.target]

/--
CP skeleton: typed composition preserves boundary of a composed pipeline.
This is the minimal category-style structural law exposed by `pipeline_compose`.
-/
def CP_skeleton : Prop :=
  ∀ (π₁ π₂ : Pipeline) (h : π₁.target = π₂.source),
    (pipeline_compose π₁ π₂ h).source = π₁.source ∧
    (pipeline_compose π₁ π₂ h).target = π₂.target

theorem CP_skeleton_derivable : CP_skeleton := by
  intro π₁ π₂ h
  simp [pipeline_compose]

/-- NTER skeleton: tacit-to-explicit morphism construction is disallowed. -/
def NTER_skeleton : Prop :=
  ∀ (p : Primitive), p.source = Object.T0 → p.target ≠ Object.E0

theorem NTER_skeleton_derivable : NTER_skeleton := by
  intro p hSource hTarget
  exact (no_morphism_T0_to_E0 p) ⟨hSource, hTarget⟩

/-!
Trace-logic skeletons for interaction constraints.

These capture the mathematically structural part of IL/AR/CSC as safety-style
properties over finite traces. FRFP policy residue remains as additional
domain commitments about authority, ambiguity semantics, and correctness
semantics.
-/

structure StepRecord where
  isAI : Bool
  intentTag : Nat
  ambiguous : Bool
  clarified : Bool
  correctnessLocked : Bool
  deriving Repr, DecidableEq

abbrev ProtocolTrace := List StepRecord

/-- IL skeleton: AI-labelled steps are intent-invariant along a trace. -/
def IL_skeleton (t : ProtocolTrace) : Prop :=
  ∀ (i j : Fin t.length),
    (t.get i).isAI = true →
    (t.get j).isAI = true →
    (t.get i).intentTag = (t.get j).intentTag

/-- AR skeleton: no unresolved ambiguity at any step. -/
def AR_skeleton (t : ProtocolTrace) : Prop :=
  ∀ (i : Fin t.length),
    (t.get i).ambiguous = true →
    (t.get i).clarified = true

/-- CSC skeleton: once correctness is locked, it remains locked thereafter. -/
def CSC_skeleton (t : ProtocolTrace) : Prop :=
  ∀ (i j : Fin t.length),
    i.1 ≤ j.1 →
    (t.get i).correctnessLocked = true →
    (t.get j).correctnessLocked = true

/--
Residual FRFP policy commitments for protocol semantics.
These are intentionally left as assumptions in new projects.
-/
structure InteractionPolicyResidue where
  /-- Human authority defines intent initialization/revision rights. -/
  intentAuthority : Prop
  /-- "Material ambiguity" classifier for actionable commands. -/
  materialAmbiguitySemantics : Prop
  /-- Tacit correctness lock is human-issued and binding. -/
  correctnessAuthority : Prop

/--
Metadata view: status of source-backed/derivable skeletons for the seven.
`none` means no external published-source anchor is currently encoded for the
skeleton in this module (it may still be definitional FRFP structure).
-/
def sevenAssumptionDecomposition :
    List (String × DecompositionStatus × Option PublishedSource) :=
  [ ("HEG", DecompositionStatus.skeletonDerivable, none)
  , ("HEC", DecompositionStatus.skeletonDerivable, none)
  , ("CP", DecompositionStatus.skeletonSourceAnchored, some PublishedSource.mac_lane_1971)
  , ("IL", DecompositionStatus.skeletonSourceAnchored, some PublishedSource.pnueli_1977)
  , ("AR", DecompositionStatus.skeletonSourceAnchored, some PublishedSource.alpern_schneider_1985)
  , ("NTER", DecompositionStatus.skeletonDerivable, none)
  , ("CSC", DecompositionStatus.skeletonSourceAnchored, some PublishedSource.pnueli_1977)
  ]

/-- Count of assumptions that currently have an explicit derivable skeleton. -/
def derivableSkeletonCount : Nat := 4

/-- Count of assumptions currently left as pure policy residue. -/
def policyOnlyCount : Nat := 0

end Frfp.Minimal.ReducedBasis
