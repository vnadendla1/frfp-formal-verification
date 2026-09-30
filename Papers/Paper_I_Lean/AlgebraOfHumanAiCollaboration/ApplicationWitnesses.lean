import AlgebraOfHumanAiCollaboration.EffectiveMinimality
import AlgebraOfHumanAiCollaboration.DependencyBoundary

/-!
# Application witnesses from observable distinctions

This module derives non-collapse rather than accepting it as a field. It does
not derive the existence of an architecture, validate an official protocol, or
certify that a supplied local map covers all actually admissible dependencies.
Those remain application obligations. No FRFP correspondence is used.
-/

namespace AlgebraOfHumanAiCollaboration

/-- A concrete collision and an explicit decoder for repairing acquisition. -/
structure DependencyRepairWitness (task : W → T) (localMap : W → L)
    (additional : W → D) where
  left : W
  right : W
  localCollision : localMap left = localMap right
  taskSeparation : task left ≠ task right
  decode : L × D → T
  recovers : ∀ w, task w = decode (localMap w, additional w)

namespace DependencyRepairWitness

theorem deficit (w : DependencyRepairWitness task localMap additional) :
    ¬ FactorsThrough task localMap := by
  intro h
  exact w.taskSeparation (factorsThrough_kernelIncluded h w.localCollision)

theorem repair (w : DependencyRepairWitness task localMap additional) :
    BoundaryResolution task localMap additional :=
  ⟨w.decode, w.recovers⟩

theorem nonlocal (w : DependencyRepairWitness task localMap additional) :
    UsesOutsideLocal (augment localMap additional) localMap :=
  success_requires_outside_local w.deficit w.repair

theorem essential (w : DependencyRepairWitness task localMap additional)
    (hcut : BoundaryExclusive localMap (augment localMap additional) activated) :
    activated :=
  hcut w.nonlocal

end DependencyRepairWitness

/--
Lower-level observational inputs for an already realized architecture.

`indistinguishable` records the informational kernel of a role's required
output. Its interpretation must be justified from the application, not assigned
to make role names different. P realizes the artifact kernel; Q the standing
kernel. Equivalent roles preserve these kernels and obligation observations.
Region preservation and existence/placement of representatives remain explicit.
-/
structure ObservableRoleData (semanticEquiv : Setoid R)
    (artifact : W → Y) (standing : W → J) (outstanding : S → Bool) where
  roleAt : RequiredEffectivePosition → R
  roleRegion : R → EffectiveRegion
  positionRegion : ∀ p, roleRegion (roleAt p) = p.region
  preservesRegion : ∀ {a b}, semanticEquiv.r a b → roleRegion a = roleRegion b
  indistinguishable : R → W → W → Prop
  preservesKernel : ∀ {a b}, semanticEquiv.r a b →
    ∀ u v, (indistinguishable a u v ↔ indistinguishable b u v)
  primaryKernel : ∀ u v, indistinguishable (roleAt .P) u v ↔ artifact u = artifact v
  standingKernel : ∀ u v, indistinguishable (roleAt .Q) u v ↔ standing u = standing v
  left : W
  right : W
  sameArtifact : artifact left = artifact right
  differentStanding : standing left ≠ standing right
  run : R → S → S
  preservesObligation : ∀ {a b}, semanticEquiv.r a b →
    ∀ s, outstanding (run a s) = outstanding (run b s)

/-- Add an observed open/closed case to realized, observation-preserving roles. -/
structure ObservableRoleWitness (semanticEquiv : Setoid R)
    (artifact : W → Y) (standing : W → J) (outstanding : S → Bool)
    extends ObservableRoleData semanticEquiv artifact standing outstanding where
  pending : S
  initiallyOpen : outstanding pending = true
  assessmentOpen : outstanding (run (roleAt .A) pending) = true
  closureClosed : outstanding (run (roleAt .C) pending) = false

namespace ObservableRoleWitness

theorem primary_standing_distinct
    (w : ObservableRoleWitness semanticEquiv artifact standing outstanding) :
    ¬ semanticEquiv.r (w.roleAt .P) (w.roleAt .Q) := by
  intro h
  have hp := (w.primaryKernel w.left w.right).mpr w.sameArtifact
  have hq := (w.preservesKernel h w.left w.right).mp hp
  exact w.differentStanding ((w.standingKernel w.left w.right).mp hq)

theorem assessment_closure_distinct
    (w : ObservableRoleWitness semanticEquiv artifact standing outstanding) :
    ¬ semanticEquiv.r (w.roleAt .A) (w.roleAt .C) := by
  intro h
  have heq := w.preservesObligation h w.pending
  rw [w.assessmentOpen, w.closureClosed] at heq
  cases heq

/-- Build the previous theorem's input; same-region non-collapse is now derived. -/
def toEffectiveLowerBoundWitness
    (w : ObservableRoleWitness semanticEquiv artifact standing outstanding) :
    EffectiveLowerBoundWitness semanticEquiv where
  roleAt := w.roleAt
  roleRegion := w.roleRegion
  positionRegion := w.positionRegion
  equivalencePreservesRegion := fun {_ _} h => w.preservesRegion h
  sameRegionNoncollapse := by
    intro a b hregion heq
    cases a <;> cases b <;> simp [RequiredEffectivePosition.region] at hregion
    all_goals first
      | rfl
      | exact False.elim (w.primary_standing_distinct heq)
      | exact False.elim (w.primary_standing_distinct (semanticEquiv.iseqv.symm heq))
      | exact False.elim (w.assessment_closure_distinct heq)
      | exact False.elim (w.assessment_closure_distinct (semanticEquiv.iseqv.symm heq))

theorem six_classes
    (w : ObservableRoleWitness semanticEquiv artifact standing outstanding) :
    HasAtLeastSixClasses semanticEquiv :=
  w.toEffectiveLowerBoundWitness.hasAtLeastSixClasses

end ObservableRoleWitness

/--
Combined application result. The dependency and role witnesses must refer to
the same application in the interpretation. This type does not synthesize roles
from access rules, nor connect `activated` to execution of `roleAt B` by itself.
-/
theorem application_boundary_and_six_classes
    (dependency : DependencyRepairWitness task localMap additional)
    (roles : ObservableRoleWitness semanticEquiv artifact standing outstanding)
    (hcut : BoundaryExclusive localMap (augment localMap additional) activated) :
    activated ∧ HasAtLeastSixClasses semanticEquiv :=
  ⟨dependency.essential hcut, roles.six_classes⟩

end AlgebraOfHumanAiCollaboration
