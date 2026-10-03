import AlgebraOfHumanAiCollaboration.Factorization
import Mathlib.Data.Fintype.Card
import Mathlib.SetTheory.Cardinal.Finite

namespace PaperIII
open AlgebraOfHumanAiCollaboration

/-- The adequacy quotient is surjective; only the representation image must be finite. -/
theorem quotient_card_le_capacity {X Y Q : Type} [Fintype Q]
    (q : X → Q) (R : X → Y) [Fintype (Set.range R)]
    (onto : Function.Surjective q) (factor : FactorsThrough q R) :
    Fintype.card Q ≤ Fintype.card (Set.range R) := by
  obtain ⟨d, hd⟩ := factor
  apply Fintype.card_le_of_surjective (fun y : Set.range R => d y.val)
  intro a
  obtain ⟨x, hx⟩ := onto a
  exact ⟨⟨R x, x, rfl⟩, (hd x).symm.trans hx⟩

/-- Theorem 2 without a finiteness assumption on the adequacy quotient. -/
theorem capacity_nonexhaustibility {X Y Q : Type}
    (q : X → Q) (R : X → Y) [Fintype (Set.range R)] (N : Nat)
    (onto : Function.Surjective q)
    (bound : Fintype.card (Set.range R) ≤ N)
    (large : (N : Cardinal) < Cardinal.mk Q) : ¬ FactorsThrough q R := by
  rintro ⟨d, hd⟩
  have surj : Function.Surjective (fun y : Set.range R => d y.val) := by
    intro a
    obtain ⟨x, hx⟩ := onto a
    exact ⟨⟨R x, x, rfl⟩, (hd x).symm.trans hx⟩
  have le := Cardinal.mk_le_of_surjective surj
  have finite_bound : Cardinal.mk (Set.range R) ≤ (N : Cardinal) := by
    simpa using (show (Fintype.card (Set.range R) : Cardinal.{0}) ≤ (N : Cardinal.{0}) from Nat.cast_le.mpr bound)
  exact (not_lt_of_ge (le.trans finite_bound)) large

/-- Theorem 2, for a single feasible representation. -/
theorem finite_capacity_nonexhaustibility {X Y Q : Type} [Fintype Q]
    (q : X → Q) (R : X → Y) [Fintype (Set.range R)] (N : Nat)
    (onto : Function.Surjective q)
    (bound : Fintype.card (Set.range R) ≤ N) (large : N < Fintype.card Q) :
    ¬ FactorsThrough q R := by
  intro h
  exact (Nat.not_lt_of_ge ((quotient_card_le_capacity q R onto h).trans bound)) large

/-- Theorem 2 for an indexed feasible family with possibly different output types. -/
theorem feasible_family_nonexhaustibility {X Q I : Type} [Fintype Q]
    (Y : I → Type) (R : (i : I) → X → Y i)
    [∀ i, Fintype (Set.range (R i))] (q : X → Q) (feasible : I → Prop)
    (N : Nat) (onto : Function.Surjective q)
    (bound : ∀ i, feasible i → Fintype.card (Set.range (R i)) ≤ N)
    (large : N < Fintype.card Q) :
    ∀ i, feasible i → ¬ FactorsThrough q (R i) := by
  intro i hi
  exact finite_capacity_nonexhaustibility q (R i) N onto (bound i hi) large

/-- Exact capacity does not forbid a representation at the boundary. -/
theorem exact_capacity_control : FactorsThrough (id : Bool → Bool) id :=
  ⟨id, fun _ => rfl⟩
end PaperIII
