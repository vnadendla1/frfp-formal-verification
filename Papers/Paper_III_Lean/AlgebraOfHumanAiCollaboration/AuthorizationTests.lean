import AlgebraOfHumanAiCollaboration.AcquisitionRealization
import AlgebraOfHumanAiCollaboration.ApplicationWitnessTests

/-! Synthetic consistency and negative controls, not deployment certification. -/
namespace AlgebraOfHumanAiCollaboration.AuthorizationTests
open ApplicationWitnessTests

structure State where
  phase : AcquisitionPhase
  localView : Bool × Bool
  payload : Bool
  pending : Bool

def initial : State := ⟨.local, (false, false), false, true⟩

def model (choice : AuthorizationDecision Unit) (valid conditions : Bool) :
    AuthorizationModel State Unit Unit Unit Unit where
  assessment := fun _ => ()
  context := fun _ => ()
  authority := fun _ => ()
  judge := fun _ _ _ => choice
  valid := fun _ _ => valid
  conditionsMet := fun _ _ => conditions
  outstanding := State.pending
  validate := id
  validationLeavesOpen := fun _ h => h
  applyDecision := fun s d =>
    { s with pending := if valid && d.settles then false else s.pending }
  decisionEffect := fun _ _ => rfl

theorem valid_permission :
    ((model .permit true true).authorize initial).pending = false ∧
      (model .permit true true).permitsExecution initial = true := ⟨rfl, rfl⟩

theorem refusal_closes_without_permission :
    ((model .refuse true true).authorize initial).pending = false ∧
      (model .refuse true true).permitsExecution initial = false := ⟨rfl, rfl⟩

theorem deferral_stays_open :
    ((model .defer true true).authorize initial).pending = true := rfl

theorem invalid_permission_stays_open :
    ((model .permit false true).authorize initial).pending = true ∧
      (model .permit false true).permitsExecution initial = false := ⟨rfl, rfl⟩

/-- Settling a conditional decision does not establish its execution conditions. -/
theorem unmet_conditions_block_execution :
    ((model (.restrict ()) true false).authorize initial).pending = false ∧
      (model (.restrict ()) true false).permitsExecution initial = false := ⟨rfl, rfl⟩

theorem met_conditions_allow_permission :
    (model (.restrict ()) true true).permitsExecution initial = true := rfl

def governance : GovernanceRoleWitness observationalEquiv
    (fun w : World => w.1.1) (fun w : World => w.1.2) (model .refuse true true) where
  roleAt := roleAt
  roleRegion := TestRole.region
  positionRegion := roles.positionRegion
  preservesRegion := roles.preservesRegion
  indistinguishable := TestRole.kernel
  preservesKernel := roles.preservesKernel
  primaryKernel := roles.primaryKernel
  standingKernel := roles.standingKernel
  left := roles.left
  right := roles.right
  sameArtifact := roles.sameArtifact
  differentStanding := roles.differentStanding
  run := fun r s => { s with pending := r.effect s.pending }
  preservesObligation := fun {_ _} h s => congrArg (fun f => f s.pending) h.2.2
  reachable := fun _ => True
  pending := initial
  pendingReachable := trivial
  initiallyOpen := rfl
  assessmentRealizes := rfl
  closureRealizes := rfl
  validJudgment := rfl
  settlesJudgment := rfl

/-- Payload acquisition is a separately supplied effect for the same B role. -/
def acquisition : AcquisitionRealization governance.toObservableRoleWitness (Bool × Bool) Bool where
  start := fun l => { initial with localView := l }
  perform := fun _ s d => { s with phase := .augmented, payload := d }
  readout := fun s => (s.localView, s.payload)
  phase := State.phase
  startIsLocal := fun _ => rfl
  boundaryIsAugmented := fun _ _ => rfl
  boundaryReadout := fun _ _ => rfl

theorem operational_repair :
    FactorsThrough (fun w : World => w.2)
      (acquisition.acquiredView (fun w : World => w.1) (fun w : World => w.2)) :=
  acquisition.repairs_task dependency

theorem governed_boundary_and_lower_bound :
    UsesOutsideLocal
      (acquisition.acquiredView (fun w : World => w.1) (fun w : World => w.2))
      (fun w : World => w.1) ∧ HasAtLeastSixClasses observationalEquiv :=
  governed_acquisition_and_six_classes governance acquisition dependency

end AlgebraOfHumanAiCollaboration.AuthorizationTests
