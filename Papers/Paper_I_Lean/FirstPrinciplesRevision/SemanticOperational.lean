import FirstPrinciplesRevision.SemanticRoles
import FirstPrinciplesRevision.OperationalContracts

/-! Reachable, phase-free contracts for the existing Paper I finite realization.
Phase fields occur only in the bridge to the historical transition definition. -/
namespace FirstPrinciplesRevision.Operational.SemanticModel
open AlgebraOfHumanAiCollaboration FirstPrinciplesRevision.Semantic

/-- Reachability excludes inconsistent raw field combinations. -/
def Coherent (s : State) : Prop :=
  match s.phase with
  | .initial => s.ready = false ∧ s.artifact = none ∧ s.payload = none ∧ s.assessment = none
  | .local => s.ready = true ∧ s.artifact ≠ none ∧ s.payload = none ∧ s.assessment = none
  | .augmented => s.ready = true ∧ s.artifact ≠ none ∧ s.payload ≠ none

theorem reachable_coherent (h : Reachable principal s) : Coherent s := by
  induction h with
  | initial w => simp [Coherent, initial]
  | @next s t r hs ht ih =>
    cases r <;> simp only [step] at ht
    · rcases ht with ⟨hp, rfl⟩
      simp [Coherent, hp] at ih
      simp [Coherent, initializeState, ih]
    · rcases ht with ⟨hp, _, rfl⟩
      simp [Coherent, hp] at ih
      simp [Coherent, produce, hp, ih]
    · rcases ht with ⟨hp, _, rfl⟩
      simp [Coherent, hp] at ih
      simpa [Coherent, diagnose, hp] using ih
    · rcases ht with ⟨hp, d, rfl⟩
      simp [Coherent, hp] at ih
      simp [Coherent, acquire, ih]
    · rcases ht with ⟨hp, _, _, _, rfl⟩
      simpa [Coherent, assess, hp] using ih
    · rcases ht with ⟨hp, _, _, rfl⟩
      simpa [Coherent, close, hp] using ih

/-- Preconditions expressed by task records, without phase labels. -/
def guard : Role → State → Prop
  | .I, s => s.ready = false
  | .P, s => s.ready = true ∧ s.payload = none
  | .Q, s => s.ready = true ∧ s.payload = none ∧ s.artifact ≠ none
  | .B, s => s.ready = true ∧ s.payload = none
  | .A, s => s.ready = true ∧ s.payload ≠ none ∧ s.artifact ≠ none ∧ s.outstanding = true
  | .C, s => s.ready = true ∧ s.outstanding = true ∧ s.assessment ≠ none ∧ s.authorized = true

/-- Actual guaranteed state effects, retaining the old implementation. -/
def effect (principal : Nat) : Role → State → State → Prop
  | .I, s, t => t = initializeState s
  | .P, s, t => t = produce s
  | .Q, s, t => t = diagnose s
  | .B, s, t => ∃ d, t = acquire s d
  | .A, s, t => t = assess s
  | .C, s, t => t = close principal s

theorem step_iff_guard_effect (hs : Reachable principal s) (r : Role) :
    step principal r s t ↔ guard r s ∧ effect principal r s t := by
  have hc := reachable_coherent hs
  cases hp : s.phase <;> cases r <;>
    simp_all [Coherent, step, guard, effect, valid, and_assoc, and_comm]

def contract (principal : Nat) (r : Role) : Contract State where
  pre s := Reachable principal s ∧ guard r s
  post := effect principal r
  realizes := by
    intro s _
    cases r
    · exact ⟨_, rfl⟩
    · exact ⟨_, rfl⟩
    · exact ⟨_, rfl⟩
    · exact ⟨_, false, rfl⟩
    · exact ⟨_, rfl⟩
    · exact ⟨_, rfl⟩

theorem contract_bridge (hs : Reachable principal s) :
    step principal r s t ↔ (contract principal r).pre s ∧ (contract principal r).post s t := by
  rw [step_iff_guard_effect hs]
  simp only [contract]
  exact ⟨fun h => ⟨⟨hs, h.1⟩, h.2⟩, fun h => ⟨h.1.2, h.2⟩⟩

theorem contract_preserves_reachability
    (hpre : (contract principal r).pre s) (hpost : (contract principal r).post s t) :
    Reachable principal t :=
  .next hpre.1 ((contract_bridge hpre.1).mpr ⟨hpre, hpost⟩)

theorem downstream_payload (r : Role) (hr : r = .A ∨ r = .C)
    (hs : (contract principal r).pre s) : s.payload ≠ none := by
  obtain rfl | rfl := hr
  · exact hs.2.2.1
  · have hc := reachable_coherent hs.1
    have hg := hs.2
    cases hp : s.phase <;> simp_all [Coherent, guard]

/-- Canonical query site has a produced artifact and no diagnostic answer yet. -/
def querySite (w : Case) : State := produce (initializeState (initial w))

theorem query_reachable (principal : Nat) (w : Case) : Reachable principal (querySite w) :=
  .next (.next (.initial w) (realizes_all principal w).1) (realizes_all principal w).2.1

def artifactInterface (principal : Nat) :
    ArtifactInterface (contract principal .P) (contract principal .Q) artifactTask standingTask where
  site := querySite
  output := fun w => produce (querySite w)
  readout := fun s => s.diagnosis.getD false
  querySite := fun w => ⟨query_reachable principal w, by
    simp [guard, querySite, produce, initializeState, initial]⟩
  productionOutcome := fun _ => rfl
  artifactOnly := ⟨fun _ => false, fun _ => rfl⟩
  evaluation := by
    intro w t ht
    change t = diagnose (querySite w) at ht
    subst t
    rfl

/-- Specified task family: artifact, evaluation, external value, assessment,
and permit/refuse verdict under the finite model's fixed authority policy. -/
def taskFamily (w : Case) : Bool × Bool × Bool × Bool × Bool :=
  (artifactTask w, standingTask w, externalTask w,
    artifactTask w && externalTask w, artifactTask w && externalTask w)

theorem family_local_deficit : ¬ FactorsThrough taskFamily localView := by
  intro h
  apply no_local_task_recovery
  exact (show FactorsThrough externalTask taskFamily from ⟨fun v => v.2.2.1, fun _ => rfl⟩).trans h

theorem family_augmented_sufficient : FactorsThrough taskFamily acquiredView := by
  exact ⟨fun v => (v.1.1, v.1.1 == v.1.2, v.2, v.1.1 && v.2, v.1.1 && v.2), fun _ => rfl⟩

/-- Regime-level available channels, not omniscience of an individual state.
Payload availability enables the acquired channel over full input cases. -/
def regimeView (s : State) (w : Case) : (Bool × Bool) ⊕ ((Bool × Bool) × Bool) :=
  if s.payload = none then Sum.inl (localView w) else Sum.inr (acquiredView w)

theorem payload_iff_family_sufficient (s : State) :
    s.payload ≠ none ↔ FactorsThrough taskFamily (regimeView s) := by
  constructor
  · intro h
    obtain ⟨decode, hd⟩ := family_augmented_sufficient
    refine ⟨fun v => match v with
      | .inl _ => (false, false, false, false, false)
      | .inr v => decode v, ?_⟩
    intro w
    simpa [regimeView, h] using hd w
  · intro h hn
    apply family_local_deficit
    obtain ⟨decode, hd⟩ := h
    exact ⟨fun v => decode (.inl v), fun w => by simpa [regimeView, hn] using hd w⟩


def model (principal : Nat) : SixRoleModel State Role Case Bool Bool where
  contracts := contract principal
  roleAt := id
  operative := fun s => s.ready = true
  sufficient := fun s => s.payload ≠ none
  initSite := initial (false, false, false)
  initAllowed := ⟨.initial _, rfl⟩
  initAbsent := by decide
  initializes := by intro s t _ ht; cases ht; rfl
  requiresOperative := by
    intro r hr s hs
    have hg := hs.2
    cases r <;> simp_all [guard]
  localSite := fun _ _ => querySite (false, false, false)
  localAllowed := by
    intro r hr
    refine ⟨query_reachable principal _, ?_⟩
    obtain rfl | rfl := hr <;> simp [guard, querySite, produce, initializeState, initial]
  localAbsent := by intro r hr; simp [querySite, produce, initializeState, initial]
  TaskCase := Case
  TaskAnswer := Bool × Bool × Bool × Bool × Bool
  LocalInfo := Bool × Bool
  AvailableInfo := (Bool × Bool) ⊕ ((Bool × Bool) × Bool)
  task := taskFamily
  localView := localView
  available := regimeView
  localDeficit := family_local_deficit
  sufficientMeans := payload_iff_family_sufficient
  localRestriction := by
    intro r hr s t hs ht
    have empty : t.payload = none := by
      obtain rfl | rfl := hr
      · change t = produce s at ht
        subst t
        exact hs.2.2
      · change t = diagnose s at ht
        subst t
        exact hs.2.2.1
    exact ⟨Sum.inl, fun w => by simp [regimeView, empty]⟩
  boundarySite := querySite (false, false, false)
  boundaryAllowed := ⟨query_reachable principal _, by
    simp [guard, querySite, produce, initializeState, initial]⟩
  boundaryAbsent := by simp [querySite, produce, initializeState, initial]
  repairs := by
    intro s t _ ht
    obtain ⟨d, rfl⟩ := ht
    simp [acquire]
  downstreamRequires := fun r hr _ hs => downstream_payload r hr hs
  artifact := artifactTask
  judgment := standingTask
  artifactInterface := artifactInterface principal
  judgmentDeficit := standingRepair.deficit
  obligation := State.outstanding
  closureSite := assess (augmentedState (false, false, false))
  closureAllowed := ⟨canonical_pending_reachable principal _, by
    simp [guard, assess, augmentedState, localState, acquire, diagnose, produce, initializeState, initial]⟩
  assessmentOutput := assess (assess (augmentedState (false, false, false)))
  assessmentAllowed := rfl
  assessmentOpen := rfl
  closes := by intro s t _ ht; cases ht; rfl

theorem semantic_lower_bound (principal : Nat) :
    HasAtLeastSixClasses (semanticSetoid (contract principal)) :=
  (model principal).semantic_six_classes

theorem semantic_exactly_six (principal : Nat) :
    HasExactlySixClasses (semanticSetoid (contract principal)) := by
  refine ⟨{ roleAt := id, noncollapse := ?_, complete := ?_ }⟩
  · intro a b h
    exact (model principal).pairwise_noncollapse h
  · intro r
    exact ⟨r, (semanticSetoid (contract principal)).refl r⟩

/-- The operational sufficient predicate really is task-family sufficiency. -/
theorem model_sufficiency (principal : Nat) (s : State) :
    (model principal).sufficient s ↔ FactorsThrough taskFamily (regimeView s) :=
  payload_iff_family_sufficient s
end FirstPrinciplesRevision.Operational.SemanticModel
