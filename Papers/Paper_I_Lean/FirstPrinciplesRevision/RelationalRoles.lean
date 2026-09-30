import AlgebraOfHumanAiCollaboration.ApplicationWitnesses

/-!
Paper I §§4.3–4.5: regions derived from realized behavior, and relational
assessment/closure separation. No main FRFP imports or additional global axioms.
Task interpretation, behavioral realization, and preservation remain premises.
-/
namespace FirstPrinciplesRevision
open AlgebraOfHumanAiCollaboration

inductive Phase where
  | initial | local | augmented
  deriving DecidableEq, Repr

abbrev Signature := Phase × Phase

def requiredSignature : RequiredEffectivePosition → Signature
  | .I => (.initial, .local)
  | .P | .Q => (.local, .local)
  | .B => (.local, .augmented)
  | .A | .C => (.augmented, .augmented)

def regionOf : Signature → Option EffectiveRegion
  | (.initial, .local) => some .initialization
  | (.local, .local) => some .preBoundary
  | (.local, .augmented) => some .boundary
  | (.augmented, .augmented) => some .postBoundary
  | _ => none

theorem required_region (p : RequiredEffectivePosition) :
    regionOf (requiredSignature p) = some p.region := by
  cases p <;> rfl

/-- Nonempty homogeneous behavior determines a signature, rather than a role name. -/
structure PhasedBehavior (State Role : Type) where
  phase : State → Phase
  step : Role → State → State → Prop
  realized : ∀ r, ∃ s t, step r s t
  homogeneous : ∀ r s t u v, step r s t → step r u v →
    (phase s, phase t) = (phase u, phase v)

namespace PhasedBehavior
noncomputable def signature (b : PhasedBehavior S R) (r : R) : Signature :=
  let s := Classical.choose (b.realized r)
  let t := Classical.choose (Classical.choose_spec (b.realized r))
  (b.phase s, b.phase t)

theorem signature_of_step (b : PhasedBehavior S R) (h : b.step r s t) :
    b.signature r = (b.phase s, b.phase t) := by
  exact b.homogeneous r _ _ s t
    (Classical.choose_spec (Classical.choose_spec (b.realized r))) h

/-- Any signature fitting all realizations equals the derived signature. -/
theorem signature_unique (b : PhasedBehavior S R) (r : R) (sig : Signature)
    (h : ∀ s t, b.step r s t → (b.phase s, b.phase t) = sig) :
    b.signature r = sig := by
  obtain ⟨s, t, hs⟩ := b.realized r
  exact (b.signature_of_step hs).trans (h s t hs)

noncomputable def region (b : PhasedBehavior S R) (r : R) : Option EffectiveRegion :=
  regionOf (b.signature r)

/-- Signature preservation implies region preservation, including optional regions. -/
theorem region_preserved (b : PhasedBehavior S R) (e : Setoid R)
    (preserve : ∀ {r q}, e.r r q → b.signature r = b.signature q)
    (h : e.r r q) : b.region r = b.region q :=
  congrArg regionOf (preserve h)
end PhasedBehavior

/-- A relational replacement for the deterministic observable-role witness.
The kernel fields concern independently interpreted required outputs. The
obligation field preserves observed outcomes of realizations sharing an input;
it is an explicit preservation hypothesis, not inferred from role labels.
-/
structure RelationalRoleWitness (e : Setoid R)
    (artifact : W → Y) (standing : W → J) (outstanding : S → Bool) where
  behavior : PhasedBehavior S R
  roleAt : RequiredEffectivePosition → R
  placed : ∀ p s t, behavior.step (roleAt p) s t →
    (behavior.phase s, behavior.phase t) = requiredSignature p
  preservesSignature : ∀ {r q}, e.r r q → behavior.signature r = behavior.signature q
  indistinguishable : R → W → W → Prop
  preservesKernel : ∀ {r q}, e.r r q → ∀ u v,
    (indistinguishable r u v ↔ indistinguishable q u v)
  primaryKernel : ∀ u v, indistinguishable (roleAt .P) u v ↔ artifact u = artifact v
  standingKernel : ∀ u v, indistinguishable (roleAt .Q) u v ↔ standing u = standing v
  left : W
  right : W
  sameArtifact : artifact left = artifact right
  differentStanding : standing left ≠ standing right
  pending : S
  assessmentOutput : S
  closureOutput : S
  initiallyOpen : outstanding pending = true
  assessmentRealizes : behavior.step (roleAt .A) pending assessmentOutput
  closureRealizes : behavior.step (roleAt .C) pending closureOutput
  assessmentOpen : outstanding assessmentOutput = true
  closureClosed : outstanding closureOutput = false
  preservesObligation : ∀ {r q s t u}, e.r r q →
    behavior.step r s t → behavior.step q s u → outstanding t = outstanding u

namespace RelationalRoleWitness

theorem primary_standing_distinct
    (w : RelationalRoleWitness e artifact standing outstanding) :
    ¬ e.r (w.roleAt .P) (w.roleAt .Q) := by
  intro h
  exact w.differentStanding ((w.standingKernel w.left w.right).mp
    ((w.preservesKernel h w.left w.right).mp
      ((w.primaryKernel w.left w.right).mpr w.sameArtifact)))

theorem assessment_closure_distinct
    (w : RelationalRoleWitness e artifact standing outstanding) :
    ¬ e.r (w.roleAt .A) (w.roleAt .C) := by
  intro h
  have heq := w.preservesObligation h w.assessmentRealizes w.closureRealizes
  rw [w.assessmentOpen, w.closureClosed] at heq
  cases heq

theorem position_signature
    (w : RelationalRoleWitness e artifact standing outstanding)
    (p : RequiredEffectivePosition) :
    w.behavior.signature (w.roleAt p) = requiredSignature p :=
  w.behavior.signature_unique _ _ (w.placed p)

theorem position_region
    (w : RelationalRoleWitness e artifact standing outstanding)
    (p : RequiredEffectivePosition) :
    w.behavior.region (w.roleAt p) = some p.region := by
  unfold PhasedBehavior.region
  rw [w.position_signature, required_region]

/-- Region of every role is derived, with a harmless fallback for other signatures.
Required representatives always have allowed signatures; no exhaustiveness of
all fine roles is asserted.
-/
noncomputable def toEffectiveLowerBoundWitness
    (w : RelationalRoleWitness e artifact standing outstanding) :
    EffectiveLowerBoundWitness e where
  roleAt := w.roleAt
  roleRegion := fun r => (w.behavior.region r).getD .initialization
  positionRegion := by
    intro p
    rw [w.position_region]
    rfl
  equivalencePreservesRegion := by
    intro r q h
    exact congrArg (fun x => x.getD .initialization)
      (w.behavior.region_preserved e w.preservesSignature h)
  sameRegionNoncollapse := by
    intro a b hr he
    cases a <;> cases b <;> simp [RequiredEffectivePosition.region] at hr
    all_goals first
      | rfl
      | exact False.elim (w.primary_standing_distinct he)
      | exact False.elim (w.primary_standing_distinct (e.iseqv.symm he))
      | exact False.elim (w.assessment_closure_distinct he)
      | exact False.elim (w.assessment_closure_distinct (e.iseqv.symm he))

theorem six_classes (w : RelationalRoleWitness e artifact standing outstanding) :
    HasAtLeastSixClasses e := w.toEffectiveLowerBoundWitness.hasAtLeastSixClasses

/-- The prior conditional correspondence theorem now accepts derived relational
regions and obligation witnesses. It still requires the semantic correspondence.
-/
theorem conditional_attainment
    (w : RelationalRoleWitness e artifact standing outstanding)
    (correspondence : FRFPCorrespondenceWitness Contract) :
    HasAtLeastSixClasses e ∧ FRFPAttainsEffectiveLowerBound Contract :=
  frfp_attains_firstPrinciples_lowerBound w.toEffectiveLowerBoundWitness correspondence
end RelationalRoleWitness
end FirstPrinciplesRevision
