import AlgebraOfHumanAiCollaboration.DependencyBoundary

/-!
# Semantic roles and conditional lower bounds

This module formalizes the conditional `>= 2` claims from Section 12 of the
requirements paper. It does not assert that either internal regime has exactly
two semantic role classes.
-/

namespace AlgebraOfHumanAiCollaboration

/-- A role system has at least two semantic classes when two roles are inequivalent. -/
def HasAtLeastTwoClasses (semanticEquiv : Setoid Role) : Prop :=
  ∃ left right : Role, ¬ semanticEquiv.r left right

/--
Independent pre-boundary witnesses for primary transformation and standing or
diagnostic assessment. The caller supplies the two neutral contract predicates
and the semantic equivalence relation; no executor identity or FRFP role enters.
-/
structure PreBoundaryWitness
    (semanticEquiv : Setoid Role)
    (PrimaryContract StandingContract : Role → Prop) where
  primary : Role
  standing : Role
  primaryRequired : PrimaryContract primary
  standingRequired : StandingContract standing
  nonReducible : ¬ semanticEquiv.r primary standing

/-- Independent, non-reducible contract witnesses imply at least two classes. -/
theorem preBoundary_hasAtLeastTwoClasses
    (witness : PreBoundaryWitness semanticEquiv PrimaryContract StandingContract) :
    HasAtLeastTwoClasses semanticEquiv := by
  exact ⟨witness.primary, witness.standing, witness.nonReducible⟩

/-- An operation leaves every initially outstanding obligation open. -/
def LeavesOutstandingOpen
    (outstanding : State → Prop) (operation : State → State) : Prop :=
  ∀ state, outstanding state → outstanding (operation state)

/-- An operation discharges every initially outstanding obligation. -/
def DischargesOutstanding
    (outstanding : State → Prop) (operation : State → State) : Prop :=
  ∀ state, outstanding state → ¬ outstanding (operation state)

/--
The semantic equivalence is sound for the observable that records whether an
obligation remains outstanding after an operation.
-/
def RespectsOutstandingObservable
    (semanticEquiv : Setoid (State → State))
    (outstanding : State → Prop) : Prop :=
  ∀ ⦃left right⦄, semanticEquiv.r left right →
    ∀ state, outstanding (left state) ↔ outstanding (right state)

/--
Post-boundary witnesses for a substantive open assessment and a separate closure
operation. Inhabitedness of the outstanding region is explicit rather than
hidden in the contract definitions.
-/
structure PostBoundaryWitness
    (semanticEquiv : Setoid (State → State))
    (outstanding : State → Prop) where
  assessment : State → State
  closure : State → State
  witnessState : State
  witnessOutstanding : outstanding witnessState
  assessmentLeavesOpen : LeavesOutstandingOpen outstanding assessment
  closureDischarges : DischargesOutstanding outstanding closure
  equivalenceSound : RespectsOutstandingObservable semanticEquiv outstanding

/-- Open assessment and closure witnesses are semantically inequivalent. -/
theorem postBoundary_roles_inequivalent
    (witness : PostBoundaryWitness semanticEquiv outstanding) :
    ¬ semanticEquiv.r witness.assessment witness.closure := by
  intro hequivalent
  have hassessment : outstanding (witness.assessment witness.witnessState) :=
    witness.assessmentLeavesOpen witness.witnessState witness.witnessOutstanding
  have hclosure : ¬ outstanding (witness.closure witness.witnessState) :=
    witness.closureDischarges witness.witnessState witness.witnessOutstanding
  have hobservable :=
    witness.equivalenceSound hequivalent witness.witnessState
  exact hclosure (hobservable.mp hassessment)

/-- Observable open-versus-closure witnesses imply at least two classes. -/
theorem postBoundary_hasAtLeastTwoClasses
    (witness : PostBoundaryWitness semanticEquiv outstanding) :
    HasAtLeastTwoClasses semanticEquiv := by
  exact ⟨witness.assessment, witness.closure,
    postBoundary_roles_inequivalent witness⟩

end AlgebraOfHumanAiCollaboration
