import FirstPrinciplesRevision.RelationalRoles
import AlgebraOfHumanAiCollaboration.FRFPSpecificationBridge
import AlgebraOfHumanAiCollaboration.AuthorizationSufficiency

/-!
A paper-side operational witness, not a replacement for main FRFP. Operations
are introduced neutrally; their behavioral contracts are then mapped to the
paper's FRFP roles. The finite task and authorization specification are explicit.
-/
namespace FirstPrinciplesRevision.Operational
open AlgebraOfHumanAiCollaboration
abbrev Role := RequiredEffectivePosition
abbrev Decision := AuthorizationDecision Unit

structure State where
  phase : Phase
  requested : Bool
  criterion : Bool
  ready : Bool := false
  artifact : Option Bool := none
  diagnosis : Option Bool := none
  payload : Option Bool := none
  assessment : Option Bool := none
  outstanding : Bool := true
  authorized : Bool := true
  decision : Option Decision := none
  closer : Option Nat := none
  deriving DecidableEq

def initializeState (s : State) : State :=
  { s with phase := .local, ready := true, artifact := some false }
def produce (s : State) : State := { s with artifact := some s.requested }
def diagnose (s : State) : State :=
  { s with diagnosis := some (s.artifact.getD false == s.criterion) }
def acquire (s : State) (external : Bool) : State :=
  { s with phase := .augmented, payload := some external }
def evaluate (s : State) : Bool := s.artifact.getD false && s.payload.getD false
def assess (s : State) : State := { s with assessment := some (evaluate s) }
def judgment (s : State) : Decision :=
  if s.assessment = some true then .permit else .refuse
/-- This finite authorization specification admits the recorded assessed verdict
only with independently present authority. Neither truth nor computation grants authority. -/
def valid (s : State) (d : Decision) : Prop :=
  s.authorized = true ∧ s.assessment ≠ none ∧ d = judgment s

def close (principal : Nat) (s : State) : State :=
  { s with outstanding := false, decision := some (judgment s), closer := some principal }

/-- Boundary acquisition receives an external argument; other transitions have
no external-payload argument. Guards specify each operation's admitted domain. -/
def step (principal : Nat) : Role → State → State → Prop
  | .I, s, t => s.phase = .initial ∧ t = initializeState s
  | .P, s, t => s.phase = .local ∧ s.ready = true ∧ t = produce s
  | .Q, s, t => s.phase = .local ∧ s.artifact ≠ none ∧ t = diagnose s
  | .B, s, t => s.phase = .local ∧ ∃ external, t = acquire s external
  | .A, s, t => s.phase = .augmented ∧ s.artifact ≠ none ∧
      s.payload ≠ none ∧ s.outstanding = true ∧ t = assess s
  | .C, s, t => s.phase = .augmented ∧ s.outstanding = true ∧
      valid s (judgment s) ∧ t = close principal s

/-- Three independently variable task coordinates: artifact, diagnostic context,
and the external dependency needed for the augmented task. -/
abbrev Case := Bool × Bool × Bool
def artifactTask (w : Case) := w.1
def contextTask (w : Case) := w.2.1
def standingTask (w : Case) := w.1 == w.2.1
def externalTask (w : Case) := w.2.2
def localView (w : Case) := (w.1, w.2.1)
def initial (w : Case) : State :=
  { phase := .initial, requested := w.1, criterion := w.2.1 }
def localState (w : Case) := diagnose (produce (initializeState (initial w)))
def augmentedState (w : Case) := acquire (localState w) (externalTask w)

/-- Every case has an actual realization, not just a vacuous universal contract. -/
theorem realizes_all (principal : Nat) (w : Case) :
    step principal .I (initial w) (initializeState (initial w)) ∧
    step principal .P (initializeState (initial w)) (produce (initializeState (initial w))) ∧
    step principal .Q (produce (initializeState (initial w))) (localState w) ∧
    step principal .B (localState w) (augmentedState w) ∧
    step principal .A (augmentedState w) (assess (augmentedState w)) ∧
    step principal .C (assess (augmentedState w)) (close principal (assess (augmentedState w))) := by
  simp [step, initial, initializeState, produce, diagnose, localState, augmentedState,
    acquire, assess, valid]

-- Contracts are predicates of behavior, not propositions set to True by role name.
def HasSignature (run : State → State → Prop) (sig : Signature) : Prop :=
  ∀ s t, run s t → (s.phase, t.phase) = sig

def Initialization (run : State → State → Prop) : Prop :=
  HasSignature run (.initial, .local) ∧
  ∀ s t, run s t → t.ready = true ∧ t.artifact ≠ none

def Transformation (run : State → State → Prop) : Prop :=
  ∀ s t, run s t → t.artifact = some s.requested

def Diagnostic (run : State → State → Prop) : Prop :=
  ∀ s t, run s t → s.artifact ≠ none ∧
    t.artifact = s.artifact ∧ t.criterion = s.criterion ∧
    t.diagnosis = some (s.artifact.getD false == s.criterion)

def Acquisition (run : State → State → Prop) : Prop :=
  HasSignature run (.local, .augmented) ∧
  (∀ s t, run s t → t.artifact = s.artifact ∧ t.criterion = s.criterion ∧
    ∃ d, t.payload = some d) ∧
  (∀ s d, s.phase = .local → run s (acquire s d))

def SubstantiveAssessment (run : State → State → Prop) : Prop :=
  HasSignature run (.augmented, .augmented) ∧
  ∀ s t, run s t → s.artifact ≠ none ∧ s.payload ≠ none ∧
    t.assessment = some (evaluate s)

def LeavesOpen (run : State → State → Prop) : Prop :=
  ∀ s t, run s t → s.outstanding = true ∧ t.outstanding = true

def ValidClosure (principal : Nat) (run : State → State → Prop) : Prop :=
  HasSignature run (.augmented, .augmented) ∧
  ∀ s t, run s t → s.outstanding = true ∧ t.outstanding = false ∧
    ∃ d, valid s d ∧ d.settles = true ∧ t.decision = some d ∧
      t.closer = some principal

theorem step_signature (principal : Nat) (r : Role) :
    HasSignature (step principal r) (requiredSignature r) := by
  intro s t h
  cases r <;> simp only [step] at h
  · rcases h with ⟨hp, rfl⟩; simp [initializeState, hp, requiredSignature]
  · rcases h with ⟨hp, _, rfl⟩; simp [produce, hp, requiredSignature]
  · rcases h with ⟨hp, _, rfl⟩; simp [diagnose, hp, requiredSignature]
  · rcases h with ⟨hp, d, rfl⟩; simp [acquire, hp, requiredSignature]
  · rcases h with ⟨hp, _, _, _, rfl⟩; simp [assess, hp, requiredSignature]
  · rcases h with ⟨hp, _, _, rfl⟩; simp [close, hp, requiredSignature]

theorem initialization_contract (principal : Nat) : Initialization (step principal .I) := by
  refine ⟨step_signature principal .I, ?_⟩
  intro s t h
  rcases h with ⟨_, rfl⟩
  simp [initializeState]

theorem transformation_contract (principal : Nat) : Transformation (step principal .P) := by
  intro s t h
  rcases h with ⟨_, _, rfl⟩
  rfl

theorem diagnostic_contract (principal : Nat) : Diagnostic (step principal .Q) := by
  intro s t h
  rcases h with ⟨_, ha, rfl⟩
  exact ⟨ha, rfl, rfl, rfl⟩

theorem acquisition_contract (principal : Nat) : Acquisition (step principal .B) := by
  refine ⟨step_signature principal .B, ?_, ?_⟩
  · intro s t h
    rcases h with ⟨_, d, rfl⟩
    exact ⟨rfl, rfl, d, rfl⟩
  · intro s d hs
    exact ⟨hs, d, rfl⟩

theorem assessment_contract (principal : Nat) :
    SubstantiveAssessment (step principal .A) ∧ LeavesOpen (step principal .A) := by
  constructor
  · refine ⟨step_signature principal .A, ?_⟩
    intro s t h
    rcases h with ⟨_, ha, hd, _, rfl⟩
    exact ⟨ha, hd, rfl⟩
  · intro s t h
    rcases h with ⟨_, _, _, ho, rfl⟩
    exact ⟨ho, ho⟩

theorem judgment_settles (s : State) : (judgment s).settles = true := by
  unfold judgment
  split <;> rfl

theorem closure_contract (principal : Nat) : ValidClosure principal (step principal .C) := by
  refine ⟨step_signature principal .C, ?_⟩
  intro s t h
  rcases h with ⟨_, ho, hv, rfl⟩
  exact ⟨ho, rfl, judgment s, hv, judgment_settles s, rfl, rfl⟩

/-- The missing external coordinate is not recoverable from the complete local
view of this finite model, but the acquired record supplies it. -/
def dependencyRepair : DependencyRepairWitness externalTask localView externalTask where
  left := (false, false, false)
  right := (false, false, true)
  localCollision := rfl
  taskSeparation := by decide
  decode := Prod.snd
  recovers := by intro w; rfl

def standingRepair : DependencyRepairWitness standingTask artifactTask contextTask where
  left := (false, false, false)
  right := (false, true, false)
  localCollision := rfl
  taskSeparation := by decide
  decode := fun pair => pair.1 == pair.2
  recovers := by intro w; rfl


def acquiredView (w : Case) : (Bool × Bool) × Bool :=
  (((augmentedState w).requested, (augmentedState w).criterion),
    (augmentedState w).payload.getD false)

theorem acquired_task_recovery : FactorsThrough externalTask acquiredView := by
  exact ⟨Prod.snd, fun _ => rfl⟩

theorem no_local_task_recovery : ¬ FactorsThrough externalTask localView :=
  dependencyRepair.deficit

theorem acquired_view_uses_nonlocal : UsesOutsideLocal acquiredView localView :=
  success_requires_outside_local no_local_task_recovery acquired_task_recovery

/-- The output kernels used in counting are realized readouts, not just names. -/
theorem required_readouts (w : Case) :
    (produce (initializeState (initial w))).artifact = some (artifactTask w) ∧
    (localState w).diagnosis = some (standingTask w) := by
  exact ⟨rfl, rfl⟩

/-- Task interpretation of diagnostic standing is context-relative. -/
theorem diagnostic_context_recovery :
    FactorsThrough standingTask (fun w => (artifactTask w, contextTask w)) :=
  standingRepair.repair

def profile (principal : Nat) (r : FRFPRole) : RoleSemanticProfile where
  establishesInitialRegime := Initialization (step principal r.position)
  primaryExplicitTransformation := Transformation (step principal r.position)
  diagnosticCriterionStanding := Diagnostic (step principal r.position) ∧
    ¬ FactorsThrough standingTask artifactTask ∧
    FactorsThrough standingTask (fun w => (artifactTask w, contextTask w))
  remainsPreBoundary := HasSignature (step principal r.position) (.local, .local)
  activatesAugmentedDependencyRegime := Acquisition (step principal r.position) ∧
    FactorsThrough externalTask acquiredView
  claimsLocalRecoveryOfMissingDependency := FactorsThrough externalTask localView
  substantiveAssessment := SubstantiveAssessment (step principal r.position)
  leavesTerminalObligationOpen := LeavesOpen (step principal r.position)
  dischargesTerminalObligation := ValidClosure principal (step principal r.position)

theorem operational_specification_bridge (principal : Nat) :
    FRFPSpecificationBridge (profile principal) where
  riEstablishesInitialRegime := initialization_contract principal
  ecPrimaryExplicitTransformation := transformation_contract principal
  ecRemainsPreBoundary := step_signature principal .P
  edDiagnosticCriterionStanding :=
    ⟨diagnostic_contract principal, standingRepair.deficit, diagnostic_context_recovery⟩
  edRemainsPreBoundary := step_signature principal .Q
  rbActivatesAugmentedDependencyRegime :=
    ⟨acquisition_contract principal, acquired_task_recovery⟩
  rbDoesNotClaimLocalRecovery := no_local_task_recovery
  teSubstantiveAssessment := (assessment_contract principal).1
  teLeavesTerminalObligationOpen := (assessment_contract principal).2
  hfdDischargesTerminalObligation := closure_contract principal

theorem operational_correspondence (principal : Nat) :
    FRFPCorrespondenceWitness (NeutralEffectiveContract (profile principal)) :=
  (operational_specification_bridge principal).toCorrespondenceWitness

def behavior (principal : Nat) : PhasedBehavior State Role where
  phase := State.phase
  step := step principal
  realized := by
    intro r
    have h := realizes_all principal (false, false, false)
    cases r
    · exact ⟨_, _, h.1⟩
    · exact ⟨_, _, h.2.1⟩
    · exact ⟨_, _, h.2.2.1⟩
    · exact ⟨_, _, h.2.2.2.1⟩
    · exact ⟨_, _, h.2.2.2.2.1⟩
    · exact ⟨_, _, h.2.2.2.2.2⟩
  homogeneous := by
    intro r s t u v h k
    exact (step_signature principal r s t h).trans (step_signature principal r u v k).symm

/-- Observe actual artifact/diagnostic outputs on the independently selected cases. -/
def outputKernel (r : Role) (u v : Case) : Prop :=
  if r = .Q then (localState u).diagnosis = (localState v).diagnosis
  else (produce (initializeState (initial u))).artifact =
    (produce (initializeState (initial v))).artifact

def operationalEquiv (principal : Nat) : Setoid Role where
  r a b := step principal a = step principal b ∧ outputKernel a = outputKernel b
  iseqv := ⟨fun _ => ⟨rfl, rfl⟩,
    fun h => ⟨h.1.symm, h.2.symm⟩,
    fun h k => ⟨h.1.trans k.1, h.2.trans k.2⟩⟩

theorem obligation_effect (principal : Nat) (r : Role) (s t : State)
    (h : step principal r s t) :
    t.outstanding = (if r = .C then false else s.outstanding) := by
  cases r <;> simp only [step] at h
  · rcases h with ⟨_, rfl⟩; rfl
  · rcases h with ⟨_, _, rfl⟩; rfl
  · rcases h with ⟨_, _, rfl⟩; rfl
  · rcases h with ⟨_, d, rfl⟩; rfl
  · rcases h with ⟨_, _, _, _, rfl⟩; rfl
  · rcases h with ⟨_, _, _, rfl⟩; rfl

def roleWitness (principal : Nat) : RelationalRoleWitness (operationalEquiv principal)
    artifactTask standingTask State.outstanding where
  behavior := behavior principal
  roleAt := id
  placed := step_signature principal
  preservesSignature := by
    intro a b h
    obtain ⟨s, t, hs⟩ := (behavior principal).realized a
    have ht : (behavior principal).step b s t := by
      change step principal b s t
      rw [← h.1]
      exact hs
    exact ((behavior principal).signature_of_step hs).trans
      ((behavior principal).signature_of_step ht).symm
  indistinguishable := outputKernel
  preservesKernel := by intro a b h u v; rw [h.2]
  primaryKernel := by
    intro u v
    change (some (artifactTask u) = some (artifactTask v)) ↔ _
    simp only [Option.some.injEq]
  standingKernel := by
    intro u v
    change (some (standingTask u) = some (standingTask v)) ↔ _
    simp only [Option.some.injEq]
  left := standingRepair.left
  right := standingRepair.right
  sameArtifact := standingRepair.localCollision
  differentStanding := standingRepair.taskSeparation
  pending := assess (augmentedState (false, false, false))
  assessmentOutput := assess (assess (augmentedState (false, false, false)))
  closureOutput := close principal (assess (augmentedState (false, false, false)))
  initiallyOpen := rfl
  assessmentRealizes := by
    simp [behavior, step, assess, augmentedState, localState, acquire, diagnose,
      produce, initializeState, initial]
  closureRealizes := (realizes_all principal (false, false, false)).2.2.2.2.2
  assessmentOpen := rfl
  closureClosed := rfl
  preservesObligation := by
    intro a b s t u h ht hu
    have ht' : step principal b s t := by rw [← h.1]; exact ht
    exact (obligation_effect principal b s t ht').trans
      (obligation_effect principal b s u hu).symm

/-- Non-collapse follows from signatures, readout kernels, and obligation effects.
Coverage uses the selected six-position model; no universal six-role upper bound. -/
theorem operational_exactly_six (principal : Nat) :
    HasExactlySixClasses (operationalEquiv principal) := by
  -- Use the explicit representative map from the derived lower-bound witness.
  let lower := (roleWitness principal).toEffectiveLowerBoundWitness
  refine ⟨{
    roleAt := id
    noncollapse := ?_
    complete := ?_
  }⟩
  · intro a b h
    exact lower.sameRegionNoncollapse (lower.required_roles_same_region h) h
  · intro r
    exact ⟨r, (operationalEquiv principal).refl r⟩

theorem operational_attainment (principal : Nat) :
    HasExactlySixClasses (operationalEquiv principal) ∧
    FRFPAttainsEffectiveLowerBound (NeutralEffectiveContract (profile principal)) := by
  exact ⟨operational_exactly_six principal,
    ((roleWitness principal).conditional_attainment (operational_correspondence principal)).2⟩

/-- Human identity is supplied as the accepted p = H premise, not derived. -/
theorem human_closure (principal human : Nat) (hPrincipal : principal = human)
    (h : step principal .C s t) : t.closer = some human := by
  rcases h with ⟨_, _, _, rfl⟩
  exact congrArg some hPrincipal


/-- All non-acquisition operations preserve the dependency payload. -/
theorem nonboundary_preserves_payload (principal : Nat) (r : Role)
    (hne : r ≠ .B) (h : step principal r s t) : t.payload = s.payload := by
  cases r <;> simp only [step] at h
  · rcases h with ⟨_, rfl⟩; rfl
  · rcases h with ⟨_, _, rfl⟩; rfl
  · rcases h with ⟨_, _, rfl⟩; rfl
  · exact (hne rfl).elim
  · rcases h with ⟨_, _, _, _, rfl⟩; rfl
  · rcases h with ⟨_, _, _, rfl⟩; rfl

inductive PathWithoutAcquisition (principal : Nat) : State → State → Prop where
  | refl (s) : PathWithoutAcquisition principal s s
  | next {s t u r} : PathWithoutAcquisition principal s t →
      r ≠ .B → step principal r t u → PathWithoutAcquisition principal s u

/-- A sequence of available non-boundary operations cannot manufacture the payload. -/
theorem path_without_acquisition_preserves_payload
    (h : PathWithoutAcquisition principal s t) : t.payload = s.payload := by
  induction h with
  | refl => rfl
  | next path hne hstep ih =>
    exact (nonboundary_preserves_payload _ _ hne hstep).trans ih

theorem acquisition_required_from_initial
    (h : PathWithoutAcquisition principal (initial w) t) : t.payload = none :=
  path_without_acquisition_preserves_payload h

inductive Reachable (principal : Nat) : State → Prop where
  | initial (w) : Reachable principal (initial w)
  | next {s t r} : Reachable principal s → step principal r s t → Reachable principal t

theorem canonical_pending_reachable (principal : Nat) (w : Case) :
    Reachable principal (assess (augmentedState w)) := by
  have h := realizes_all principal w
  exact .next (.next (.next (.next (.next (.initial w) h.1) h.2.1)
    h.2.2.1) h.2.2.2.1) h.2.2.2.2.1

theorem canonical_closure_reachable (principal : Nat) (w : Case) :
    Reachable principal (close principal (assess (augmentedState w))) :=
  .next (canonical_pending_reachable principal w) (realizes_all principal w).2.2.2.2.2

/-- The complete modeled local state contains exactly the chosen local-view
information: its other fields add no hidden external coordinate. -/
theorem local_state_factors : FactorsThrough localState localView := by
  exact ⟨fun pair => localState (pair.1, pair.2, false), fun _ => rfl⟩

theorem local_view_factors : FactorsThrough localView localState := by
  exact ⟨fun s => (s.requested, s.criterion), fun _ => rfl⟩

theorem no_local_state_task_recovery : ¬ FactorsThrough externalTask localState := by
  intro h
  exact no_local_task_recovery (h.trans local_state_factors)

end FirstPrinciplesRevision.Operational
