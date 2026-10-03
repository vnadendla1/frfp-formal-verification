import AlgebraOfHumanAiCollaboration.Factorization

namespace PaperIII
open AlgebraOfHumanAiCollaboration

/-- Heterogeneous criteria, so the newly admitted criterion may have a new codomain. -/
def RevisedSetoid {X I : Type} {V : I → Type} {B : Type}
    (F : (i : I) → X → V i) (D : X → B) : Setoid X where
  r x y := (∀ i, F i x = F i y) ∧ D x = D y
  iseqv := ⟨fun _ => ⟨fun _ => rfl, rfl⟩,
    fun h => ⟨fun i => (h.1 i).symm, h.2.symm⟩,
    fun h k => ⟨fun i => (h.1 i).trans (k.1 i), h.2.trans k.2⟩⟩

def revisedQuotient {X I : Type} {V : I → Type} {B : Type}
    (F : (i : I) → X → V i) (D : X → B) : X → Quotient (RevisedSetoid F D) :=
  Quotient.mk _

theorem candidate_factors_revisedQuotient {X I : Type} {V : I → Type} {B : Type}
    (F : (i : I) → X → V i) (D : X → B) :
    FactorsThrough D (revisedQuotient F D) := by
  exact ⟨Quotient.lift D (fun _ _ h => h.2), fun _ => rfl⟩

/-- Theorem 3: the actual revised quotient, not just a family-sufficiency predicate. -/
theorem admission_induced_insufficiency {X I Y B : Type} {V : I → Type}
    (F : (i : I) → X → V i) (D : X → B) (R : X → Y)
    (_current : ∀ i, FactorsThrough (F i) R)
    (missing : ¬ FactorsThrough D R) (ValidAdmit : (X → B) → Prop)
    (_admitted : ValidAdmit D) : ¬ FactorsThrough (revisedQuotient F D) R := by
  intro h
  exact missing ((candidate_factors_revisedQuotient F D).trans h)

/-- A sufficiently rich successor representation can restore all criteria. -/
theorem identity_restores_sufficiency {X I B : Type} {V : I → Type}
    (F : (i : I) → X → V i) (D : X → B) :
    (∀ i, FactorsThrough (F i) (id : X → X)) ∧ FactorsThrough D (id : X → X) :=
  ⟨fun i => ⟨F i, fun _ => rfl⟩, ⟨D, fun _ => rfl⟩⟩

def BaselineEquivalent {X Y Z I : Type} {V : I → Type}
    (F : (i : I) → X → V i) (R : X → Y) (S : X → Z) : Prop :=
  ∀ i, FactorsThrough (F i) R ↔ FactorsThrough (F i) S

/-- The distinguishing criterion must belong to the comparison family. -/
theorem baseline_revision {X Y Z I : Type} {V : I → Type}
    (F : (i : I) → X → V i) (R : X → Y) (S : X → Z) (i : I)
    (missing : ¬ FactorsThrough (F i) R) (restored : FactorsThrough (F i) S) :
    ¬ BaselineEquivalent F R S := fun h => missing ((h i).mpr restored)

/-- Propositions 1 and 2 are countermodels to universal implications. -/
theorem discovery_without_admission :
    ∃ (discover permitted : Bool → Prop) (d : Bool), discover d ∧ ¬ permitted d :=
  ⟨fun _ => True, fun _ => False, false, trivial, id⟩

theorem inadequacy_without_particular_revision :
    ∃ (A : Unit → Bool) (permitted : Bool → Prop), A () = false ∧ ∀ d, ¬ permitted d :=
  ⟨fun _ => false, fun _ => False, rfl, fun _ => id⟩
end PaperIII
