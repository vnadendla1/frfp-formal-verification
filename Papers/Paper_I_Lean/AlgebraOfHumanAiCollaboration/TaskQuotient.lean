import AlgebraOfHumanAiCollaboration.Factorization

/-!
# Task-requirement quotients

An indexed family of task maps induces exactly the equivalence relation described
in Sections 3-4 of the requirements paper.
-/

namespace AlgebraOfHumanAiCollaboration

universe u v w

variable {I : Type u} {W : Type v} {A : I → Type w}

/-- Indistinguishability with respect to every observation in an indexed family. -/
def familySetoid (observe : (i : I) → W → A i) : Setoid W where
  r w₁ w₂ := ∀ i, observe i w₁ = observe i w₂
  iseqv := {
    refl := fun _ _ => rfl
    symm := fun h i => (h i).symm
    trans := fun h₁ h₂ i => (h₁ i).trans (h₂ i)
  }

/-- The quotient preserving exactly the distinctions made by the family. -/
abbrev FamilyQuotient (observe : (i : I) → W → A i) :=
  Quotient (familySetoid observe)

/-- Canonical map into the family-induced quotient. -/
def familyQuotientMap (observe : (i : I) → W → A i) :
    W → FamilyQuotient observe :=
  Quotient.mk (familySetoid observe)

/-- Each member of the family descends to the canonical quotient. -/
def familyComponentOnQuotient (observe : (i : I) → W → A i) (i : I) :
    FamilyQuotient observe → A i :=
  Quotient.lift (observe i) (fun _ _ h => h i)

theorem family_component_factors
    (observe : (i : I) → W → A i) (i : I) :
    FactorsThrough (observe i) (familyQuotientMap observe) := by
  refine ⟨familyComponentOnQuotient observe i, ?_⟩
  intro w
  rfl

/-- Equality in the quotient is precisely joint task equivalence. -/
theorem familyQuotientMap_eq_iff
    (observe : (i : I) → W → A i) (w₁ w₂ : W) :
    familyQuotientMap observe w₁ = familyQuotientMap observe w₂ ↔
      ∀ i, observe i w₁ = observe i w₂ := by
  constructor
  · intro h i
    exact congrArg (familyComponentOnQuotient observe i) h
  · intro h
    exact Quotient.sound h

/-- Paper-facing name for a task-requirement quotient. -/
abbrev TaskQuotient (tasks : (i : I) → W → A i) :=
  FamilyQuotient tasks

/-- Paper-facing name for the task quotient map `q_F`. -/
abbrev taskQuotientMap (tasks : (i : I) → W → A i) : W → TaskQuotient tasks :=
  familyQuotientMap tasks

/-- Paper-facing name for a dependency-regime quotient. -/
abbrev DependencyQuotient (dependencies : (i : I) → W → A i) :=
  FamilyQuotient dependencies

/-- Paper-facing name for a dependency quotient map such as `lambda_1`. -/
abbrev dependencyQuotientMap
    (dependencies : (i : I) → W → A i) : W → DependencyQuotient dependencies :=
  familyQuotientMap dependencies

end AlgebraOfHumanAiCollaboration
