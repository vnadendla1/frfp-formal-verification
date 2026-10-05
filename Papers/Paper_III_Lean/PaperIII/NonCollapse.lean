import PaperIII.ProblemAdequacy

/-! # Paper III, Section 7: epistemic, constitutive, and closure non-collapse. -/

namespace PaperIII

open AlgebraOfHumanAiCollaboration

/-- `source` universally determines `target` exactly when `target` factors through it. -/
abbrev UniversallyDetermines (source : W → J) (target : W → A) : Prop :=
  FactorsThrough target source

/-- Theorem 6: a diagnostic factoring through an inadequate representation cannot determine adequacy. -/
theorem epistemicNonCollapse
    (adequacy : W → A) (representation : W → E) (diagnostic : W → J)
    (adequacyMissing : ¬ FactorsThrough adequacy representation)
    (diagnosticAvailable : FactorsThrough diagnostic representation) :
    ¬ UniversallyDetermines diagnostic adequacy := by
  intro diagnosticDetermines
  exact adequacyMissing (diagnosticDetermines.trans diagnosticAvailable)

/-- Continuation-preserving equivalence observes equality of admissible successor sets. -/
def ContinuationEquivalent
    (next : Z → T → K) (z : Z) (left right : T) : Prop :=
  next z left = next z right

/-- Standing-sensitive continuation is the substantive governance premise that
assessment alone does not generate the continuation licensed by an authorized
governing assessment. -/
def StandingSensitiveContinuation
    (content : T → C) (next : Z → T → K) (validStanding : T → Prop)
    (z : Z) (assessment authorization : T) : Prop :=
  content assessment = content authorization →
    ¬ validStanding assessment → validStanding authorization →
      next z assessment ≠ next z authorization

/-- Theorem 7: equal assessment content does not collapse diagnostic and
authorized occurrences when standing-sensitive continuation holds. -/
theorem standingSensitiveContinuationNonCollapse
    (content : T → C) (next : Z → T → K) (validStanding : T → Prop)
    (z : Z) (assessment admission : T)
    (sameContent : content assessment = content admission)
    (assessmentLacksStanding : ¬ validStanding assessment)
    (admissionHasStanding : validStanding admission)
    (standingSensitive :
      StandingSensitiveContinuation content next validStanding z assessment admission) :
    ¬ ContinuationEquivalent next z assessment admission := by
  exact standingSensitive sameContent assessmentLacksStanding admissionHasStanding

namespace IndependenceModels

inductive Transition where
  | diagnostic
  | admission
  deriving DecidableEq

def sameContent (_ : Transition) : Unit := ()
def differentNext (_ : Unit) : Transition → Bool
  | .diagnostic => false
  | .admission => true
def sameNext (_ : Unit) (_ : Transition) : Bool := false

/-- First half of Proposition 8: perfect information can coexist with constitutive separation. -/
theorem epistemic_collapse_with_constitutive_noncollapse :
    FactorsThrough (fun b : Bool => b) (fun b : Bool => b) ∧
    sameContent .diagnostic = sameContent .admission ∧
    ¬ ContinuationEquivalent differentNext () .diagnostic .admission := by
  refine ⟨⟨id, ?_⟩, rfl, ?_⟩
  · intro b
    rfl
  · simp [ContinuationEquivalent, differentNext]

/-- Second half of Proposition 8: an epistemic gap can coexist with no standing distinction. -/
theorem epistemic_noncollapse_without_constitutive_noncollapse :
    (¬ FactorsThrough
      FiniteAdequacyModel.problemAdequacy
      FiniteAdequacyModel.explicitRepresentation) ∧
    ContinuationEquivalent sameNext () .diagnostic .admission := by
  exact ⟨FiniteAdequacyModel.finite_specification_adequacy_incompleteness, rfl⟩

/-- Proposition 8: the two non-collapse properties are logically independent by finite witnesses. -/
theorem independence_of_epistemic_and_constitutive_noncollapse :
    (FactorsThrough (fun b : Bool => b) (fun b : Bool => b) ∧
      ¬ ContinuationEquivalent differentNext () .diagnostic .admission) ∧
    ((¬ FactorsThrough
        FiniteAdequacyModel.problemAdequacy
        FiniteAdequacyModel.explicitRepresentation) ∧
      ContinuationEquivalent sameNext () .diagnostic .admission) := by
  exact ⟨⟨epistemic_collapse_with_constitutive_noncollapse.1,
    epistemic_collapse_with_constitutive_noncollapse.2.2⟩,
    epistemic_noncollapse_without_constitutive_noncollapse⟩

end IndependenceModels

/-- Equivalence of transition results with respect to a designated observable. -/
def ObservableEquivalent (observable : X → O) (left right : X) : Prop :=
  observable left = observable right

/-- Theorem 8: assessment and closure cannot be equivalent when obligation status differs. -/
theorem assessmentClosureNonCollapse
    (outstanding : X → Bool) (afterAssessment afterClosure : X)
    (assessmentOpen : outstanding afterAssessment = true)
    (closureClosed : outstanding afterClosure = false) :
    ¬ ObservableEquivalent outstanding afterAssessment afterClosure := by
  intro heq
  unfold ObservableEquivalent at heq
  rw [assessmentOpen, closureClosed] at heq
  contradiction

/-- Theorem 7 for any relation preserving continuation sets, not only equality-defined equivalence. -/
theorem standingSensitiveContinuationNonCollapse_under_relation
    (relation : T → T → Prop) (next : Z → T → K) (z : Z) (left right : T)
    (preserves : ∀ a b, relation a b → next z a = next z b)
    (different : next z left ≠ next z right) : ¬ relation left right :=
  fun h => different (preserves left right h)

/-- Theorem 8 for any relation preserving the outstanding-obligation observable. -/
theorem assessmentClosureNonCollapse_under_relation
    (relation : X → X → Prop) (outstanding : X → Bool) (left right : X)
    (preserves : ∀ a b, relation a b → outstanding a = outstanding b)
    (openAssessment : outstanding left = true) (closed : outstanding right = false) :
    ¬ relation left right := by
  intro h
  have eq := preserves left right h
  rw [openAssessment, closed] at eq
  cases eq
end PaperIII
