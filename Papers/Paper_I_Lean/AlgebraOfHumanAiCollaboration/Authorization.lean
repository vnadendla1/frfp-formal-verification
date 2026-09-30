import AlgebraOfHumanAiCollaboration.ApplicationWitnesses

/-!
# Validation, authorization judgment, and execution permission

The judgment function does not certify its own authority. Only a valid,
settling judgment closes the selected obligation. Execution permission is a
separate predicate, not an assertion that an action occurs or succeeds.
All validity and obligation-effect laws are specification inputs.
-/
namespace AlgebraOfHumanAiCollaboration

inductive AuthorizationDecision (Restriction : Type u) where
  | permit
  | restrict (conditions : Restriction)
  | refuse
  | defer
deriving DecidableEq, Repr

namespace AuthorizationDecision

def settles : AuthorizationDecision Restriction → Bool
  | .defer => false
  | _ => true

/-- Restricted permission still requires the action-specific conditions below. -/
def grantsPermission : AuthorizationDecision Restriction → Bool
  | .permit | .restrict _ => true
  | .refuse | .defer => false

theorem refusal_settles : (refuse : AuthorizationDecision Restriction).settles = true := rfl

theorem refusal_not_permission :
    (refuse : AuthorizationDecision Restriction).grantsPermission = false := rfl

end AuthorizationDecision

structure AuthorizationModel (State Assessment Context Authority Restriction : Type u) where
  assessment : State → Assessment
  context : State → Context
  authority : State → Authority
  judge : Assessment → Context → Authority → AuthorizationDecision Restriction
  valid : State → AuthorizationDecision Restriction → Bool
  conditionsMet : State → Restriction → Bool
  outstanding : State → Bool
  validate : State → State
  validationLeavesOpen : ∀ s, outstanding s = true → outstanding (validate s) = true
  applyDecision : State → AuthorizationDecision Restriction → State
  decisionEffect : ∀ s d, outstanding (applyDecision s d) =
    if valid s d && d.settles then false else outstanding s

namespace AuthorizationModel

def decision (m : AuthorizationModel S V K U C) (s : S) : AuthorizationDecision C :=
  m.judge (m.assessment s) (m.context s) (m.authority s)

def authorize (m : AuthorizationModel S V K U C) (s : S) : S :=
  m.applyDecision s (m.decision s)

/-- Authorization for this action, not execution itself or a success guarantee. -/
def permitsExecution (m : AuthorizationModel S V K U C) (s : S) : Bool :=
  m.valid s (m.decision s) && match m.decision s with
    | .permit => true
    | .restrict conditions => m.conditionsMet s conditions
    | .refuse | .defer => false

theorem valid_settlement_closes (m : AuthorizationModel S V K U C)
    (hvalid : m.valid s (m.decision s) = true)
    (hsettles : (m.decision s).settles = true) :
    m.outstanding (m.authorize s) = false := by
  unfold authorize
  rw [m.decisionEffect, hvalid, hsettles]
  rfl

theorem invalid_judgment_preserves (m : AuthorizationModel S V K U C)
    (h : m.valid s (m.decision s) = false) :
    m.outstanding (m.authorize s) = m.outstanding s := by
  unfold authorize
  rw [m.decisionEffect, h]
  rfl

theorem deferral_preserves (m : AuthorizationModel S V K U C)
    (h : m.decision s = .defer) :
    m.outstanding (m.authorize s) = m.outstanding s := by
  unfold authorize
  rw [m.decisionEffect, h]
  simp [AuthorizationDecision.settles]

theorem refusal_does_not_permit (m : AuthorizationModel S V K U C)
    (h : m.decision s = .refuse) : m.permitsExecution s = false := by
  unfold permitsExecution
  rw [h]
  simp

theorem unmet_restriction_does_not_permit (m : AuthorizationModel S V K U C)
    (h : m.decision s = .restrict conditions)
    (hunmet : m.conditionsMet s conditions = false) :
    m.permitsExecution s = false := by
  simp [permitsExecution, h, hunmet]

theorem invalid_judgment_does_not_permit (m : AuthorizationModel S V K U C)
    (h : m.valid s (m.decision s) = false) : m.permitsExecution s = false := by
  unfold permitsExecution
  rw [h]
  rfl

end AuthorizationModel

/--
An application realizes validation and valid settlement at a reachable witness
state. Reachability, authority validity, role semantics, and preservation are
explicit inputs; naming a decision does not discharge them.
-/
structure GovernanceRoleWitness (semanticEquiv : Setoid R)
    (artifact : W → Y) (standing : W → J)
    (model : AuthorizationModel S V K U C)
    extends ObservableRoleData semanticEquiv artifact standing model.outstanding where
  reachable : S → Prop
  pending : S
  pendingReachable : reachable pending
  initiallyOpen : model.outstanding pending = true
  assessmentRealizes : run (roleAt .A) pending = model.validate pending
  closureRealizes : run (roleAt .C) pending = model.authorize pending
  validJudgment : model.valid pending (model.decision pending) = true
  settlesJudgment : (model.decision pending).settles = true

namespace GovernanceRoleWitness

def toObservableRoleWitness
    (w : GovernanceRoleWitness semanticEquiv artifact standing model) :
    ObservableRoleWitness semanticEquiv artifact standing model.outstanding where
  toObservableRoleData := w.toObservableRoleData
  pending := w.pending
  initiallyOpen := w.initiallyOpen
  assessmentOpen := by
    rw [w.assessmentRealizes]
    exact model.validationLeavesOpen w.pending w.initiallyOpen
  closureClosed := by
    rw [w.closureRealizes]
    exact model.valid_settlement_closes w.validJudgment w.settlesJudgment

def toEffectiveLowerBoundWitness
    (w : GovernanceRoleWitness semanticEquiv artifact standing model) :
    EffectiveLowerBoundWitness semanticEquiv :=
  w.toObservableRoleWitness.toEffectiveLowerBoundWitness

theorem six_classes
    (w : GovernanceRoleWitness semanticEquiv artifact standing model) :
    HasAtLeastSixClasses semanticEquiv :=
  w.toEffectiveLowerBoundWitness.hasAtLeastSixClasses

end GovernanceRoleWitness
end AlgebraOfHumanAiCollaboration
