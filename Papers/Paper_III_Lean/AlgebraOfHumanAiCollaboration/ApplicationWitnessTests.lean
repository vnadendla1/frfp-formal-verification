import AlgebraOfHumanAiCollaboration.ApplicationWitnesses

/-!
# Consistency tests and applicability controls

These are synthetic models, not six verified official protocols. The three bits
represent a local artifact, local context, and an unavailable task-relevant fact. The role carrier
allows arbitrary kernels and effects; it is not an enumeration of six roles.
-/

namespace AlgebraOfHumanAiCollaboration.ApplicationWitnessTests

abbrev World := (Bool × Bool) × Bool

def dependency : DependencyRepairWitness
    (fun w : World => w.2) (fun w : World => w.1) (fun w : World => w.2) where
  left := ((false, false), false)
  right := ((false, false), true)
  localCollision := rfl
  taskSeparation := by decide
  decode := Prod.snd
  recovers := fun _ => rfl

/-- Every channel obtainable from the specified local map preserves its collision. -/
theorem complete_local_collision (channel : World → V)
    (h : FactorsThrough channel (fun w : World => w.1)) :
    channel ((false, false), false) = channel ((false, false), true) :=
  factorsThrough_kernelIncluded h rfl

/-- The supplied additional bit repairs the specified task, not all possible tasks. -/
theorem repaired_task :
    BoundaryResolution (fun w : World => w.2)
      (fun w : World => w.1) (fun w : World => w.2) := dependency.repair

/-- If the task itself is available locally, the deficit hypothesis fails. -/
theorem local_oracle_control : FactorsThrough (fun w : World => w.2) id :=
  ⟨Prod.snd, fun _ => rfl⟩

/-- A constant response cannot repair this collision. -/
theorem uninformative_acquisition_control :
    ¬ BoundaryResolution (fun w : World => w.2)
      (fun w : World => w.1) (fun _ : World => false) := by
  intro h
  have heq := factorsThrough_kernelIncluded h
    (w₁ := ((false, false), false)) (w₂ := ((false, false), true)) rfl
  cases heq

structure TestRole where
  region : EffectiveRegion
  kernel : World → World → Prop
  effect : Bool → Bool

def observationalEquiv : Setoid TestRole where
  r a b := a.region = b.region ∧ a.kernel = b.kernel ∧ a.effect = b.effect
  iseqv := {
    refl := fun _ => ⟨rfl, rfl, rfl⟩
    symm := fun h => ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩
    trans := fun h k => ⟨h.1.trans k.1, h.2.1.trans k.2.1, h.2.2.trans k.2.2⟩
  }

def roleAt (p : RequiredEffectivePosition) : TestRole where
  region := p.region
  kernel := match p with
    | .P => fun u v => u.1.1 = v.1.1
    | .Q => fun u v => u.1.2 = v.1.2
    | _ => fun u v => u = v
  effect := match p with
    | .C => fun _ => false
    | _ => id

def roles : ObservableRoleWitness observationalEquiv
    (fun w : World => w.1.1) (fun w : World => w.1.2) (id : Bool → Bool) where
  roleAt := roleAt
  roleRegion := TestRole.region
  positionRegion := fun _ => rfl
  preservesRegion := fun {_ _} h => h.1
  indistinguishable := TestRole.kernel
  preservesKernel := by
    intro a b h u v
    exact Eq.to_iff (congrArg (fun k => k u v) h.2.1)
  primaryKernel := fun _ _ => Iff.rfl
  standingKernel := fun _ _ => Iff.rfl
  left := ((false, false), false)
  right := ((false, true), false)
  sameArtifact := rfl
  differentStanding := by decide
  run := TestRole.effect
  preservesObligation := fun {_ _} h s => congrArg (fun f => f s) h.2.2
  pending := true
  initiallyOpen := rfl
  assessmentOpen := rfl
  closureClosed := rfl

/-- The observational hypotheses are jointly satisfiable on an unrestricted carrier. -/
theorem constructed_six_classes : HasAtLeastSixClasses observationalEquiv :=
  roles.six_classes

/-- When both operations exhaust the obligation, the separating observation fails. -/
theorem exhausted_authorization_control :
    ¬ ∃ s : Bool, (fun _ : Bool => false) s = true := by
  intro ⟨_, h⟩
  cases h

end AlgebraOfHumanAiCollaboration.ApplicationWitnessTests
