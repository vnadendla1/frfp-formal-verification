import AlgebraOfHumanAiCollaboration.TaskQuotient

/-!
# Dependency mismatch and boundary necessity

This module formalizes the exact conditional core of Sections 7-9. A realization
is successful when the task map factors through its available dependency map.
It is local when its dependency map itself factors through the local-regime map.
-/

namespace AlgebraOfHumanAiCollaboration

/-- A dependency representation is successful exactly when it determines the task. -/
abbrev Successful (task : W → Q) (dependency : W → U) : Prop :=
  FactorsThrough task dependency

/-- The dependency can be obtained without leaving the local regime. -/
abbrev LocallyObtainable (dependency : W → U) (localMap : W → L) : Prop :=
  FactorsThrough dependency localMap

/-- The dependency contains information not recoverable from the local regime. -/
def UsesOutsideLocal (dependency : W → U) (localMap : W → L) : Prop :=
  ¬ LocallyObtainable dependency localMap

/--
If the task does not factor through the local regime, every successful dependency
representation must contain something unobtainable from that regime.
-/
theorem success_requires_outside_local
    (hdeficit : ¬ FactorsThrough task localMap)
    (hsuccess : Successful task dependency) :
    UsesOutsideLocal dependency localMap := by
  intro hlocal
  exact hdeficit (hsuccess.trans hlocal)

/-- Cross-locus augmentation repairs the deficit and is necessarily nonlocal. -/
theorem crossLocus_repair
    (hdeficit : ¬ FactorsThrough task localMap)
    (haugmented : FactorsThrough task augmented) :
    Successful task augmented ∧ UsesOutsideLocal augmented localMap := by
  exact ⟨haugmented, success_requires_outside_local hdeficit haugmented⟩

/-- A designated boundary is exclusive for a dependency when nonlocal use activates it. -/
def BoundaryExclusive
    (localMap : W → L) (dependency : W → U) (activatesBoundary : Prop) : Prop :=
  UsesOutsideLocal dependency localMap → activatesBoundary

/-- The boundary is essential for this realization when success entails activation. -/
def BoundaryEssentialFor
    (task : W → Q) (dependency : W → U) (activatesBoundary : Prop) : Prop :=
  Successful task dependency → activatesBoundary

/-- The paper's boundary-exclusivity implication. -/
theorem boundary_essential
    (hdeficit : ¬ FactorsThrough task localMap)
    (hexclusive : BoundaryExclusive localMap dependency activatesBoundary) :
    BoundaryEssentialFor task dependency activatesBoundary := by
  intro hsuccess
  exact hexclusive (success_requires_outside_local hdeficit hsuccess)

/-- Augment a local dependency map with a newly acquired dependency. -/
def augment (localMap : W → L) (additional : W → U) : W → L × U :=
  fun w => (localMap w, additional w)

/-- A boundary-resolution contract is factorization through the augmented pair. -/
abbrev BoundaryResolution
    (task : W → Q) (localMap : W → L) (additional : W → U) : Prop :=
  FactorsThrough task (augment localMap additional)

/-- The canonical relation pairing local and task states arising from one world. -/
def CanonicalBoundaryRelation
    (localMap : W → L) (task : W → Q) : L → Q → Prop :=
  fun l q => ∃ w, localMap w = l ∧ task w = q

/-- A binary relation is single-valued in its second argument. -/
def IsFunctional (relation : L → Q → Prop) : Prop :=
  ∀ ⦃l q₁ q₂⦄, relation l q₁ → relation l q₂ → q₁ = q₂

/--
The canonical boundary relation is functional exactly when the local regime
preserves every task distinction.
-/
theorem canonicalBoundary_functional_iff
    (localMap : W → L) (task : W → Q) :
    IsFunctional (CanonicalBoundaryRelation localMap task) ↔
      KernelIncluded localMap task := by
  constructor
  · intro hfunctional w₁ w₂ hlocal
    apply hfunctional
    · exact ⟨w₁, rfl, rfl⟩
    · exact ⟨w₂, hlocal.symm, rfl⟩
  · intro hkernel l q₁ q₂ h₁ h₂
    obtain ⟨w₁, hl₁, hq₁⟩ := h₁
    obtain ⟨w₂, hl₂, hq₂⟩ := h₂
    calc
      q₁ = task w₁ := hq₁.symm
      _ = task w₂ := hkernel (hl₁.trans hl₂.symm)
      _ = q₂ := hq₂

/-- Failure of factorization is witnessed by a task-relevant local collision. -/
theorem not_factorsThrough_iff_exists_collision [Nonempty W]
    (task : W → Q) (localMap : W → L) :
    ¬ FactorsThrough task localMap ↔
      ∃ w₁ w₂, localMap w₁ = localMap w₂ ∧ task w₁ ≠ task w₂ := by
  classical
  constructor
  · intro hnot
    apply Classical.byContradiction
    intro hcollision
    apply hnot
    apply (factorsThrough_iff_kernelIncluded task localMap).2
    intro w₁ w₂ hlocal
    apply Classical.byContradiction
    intro htask
    exact hcollision ⟨w₁, w₂, hlocal, htask⟩
  · intro hexists hfactor
    obtain ⟨w₁, w₂, hlocal, htask⟩ := hexists
    exact htask (factorsThrough_kernelIncluded hfactor hlocal)

end AlgebraOfHumanAiCollaboration
