import AlgebraOfHumanAiCollaboration.Factorization

/-!
# Paper III, Sections 3.2--3.5

The general factorization theorem is reused from the predecessor formalization.
The paper's finite countermodel is then checked directly.
-/

namespace PaperIII

open AlgebraOfHumanAiCollaboration

/-- Theorem 1: specification adequacy is equivalent to kernel inclusion. -/
theorem specificationAdequacyFactorization [Nonempty W]
    (adequacy : W → A) (representation : W → E) :
    FactorsThrough adequacy representation ↔
      KernelIncluded representation adequacy :=
  factorsThrough_iff_kernelIncluded adequacy representation

namespace FiniteAdequacyModel

abbrev ProblemState := Bool × Bool
abbrev EvaluationState := ProblemState × Bool

/-- The specification retains only the first problem coordinate. -/
def specification (p : ProblemState) : Bool := p.1

/-- The representation available to evaluation: specification plus output. -/
def explicitRepresentation (state : EvaluationState) : Bool × Bool :=
  (specification state.1, state.2)

/-- The specified task succeeds exactly when the output matches `x`. -/
def specifiedSuccess (state : EvaluationState) : Prop :=
  state.2 = state.1.1

/-- Originating-problem adequacy additionally requires the omitted bit `z`. -/
def problemAdequacy (state : EvaluationState) : Bool :=
  (state.2 == state.1.1) && state.1.2

def state₀ : EvaluationState := ((false, false), false)
def state₁ : EvaluationState := ((false, true), false)

theorem same_explicit_representation :
    explicitRepresentation state₀ = explicitRepresentation state₁ := rfl

theorem both_satisfy_specified_task :
    specifiedSuccess state₀ ∧ specifiedSuccess state₁ := by
  constructor <;> rfl

theorem adequacy_differs :
    problemAdequacy state₀ ≠ problemAdequacy state₁ := by
  decide

/-- Section 3.4: the paper's explicit finite nonfactorability witness. -/
theorem finite_specification_adequacy_incompleteness :
    ¬ FactorsThrough problemAdequacy explicitRepresentation := by
  intro hfactor
  have hkernel := factorsThrough_kernelIncluded hfactor
  exact adequacy_differs (hkernel same_explicit_representation)

/-- Corollary 1: perfect specified-task success need not imply adequacy. -/
theorem specifiedSuccess_does_not_imply_problemAdequacy :
    ∃ u v : EvaluationState,
      specifiedSuccess u ∧ specifiedSuccess v ∧
      explicitRepresentation u = explicitRepresentation v ∧
      problemAdequacy u ≠ problemAdequacy v := by
  exact ⟨state₀, state₁, both_satisfy_specified_task.1,
    both_satisfy_specified_task.2, same_explicit_representation, adequacy_differs⟩

end FiniteAdequacyModel
end PaperIII
