import AlgebraOfHumanAiCollaboration.EffectiveMinimality

/-!
# FRFP specification-level semantic bridge

This module encodes the six semantic comparisons stated in manuscript Section
14.1. Neutral contracts are defined independently of FRFP role names. A separate
semantic profile records the published meaning assigned to each FRFP role.
-/

namespace AlgebraOfHumanAiCollaboration

/-- Architecture-relevant semantic facts that a published role may satisfy. -/
structure RoleSemanticProfile where
  establishesInitialRegime : Prop
  primaryExplicitTransformation : Prop
  diagnosticCriterionStanding : Prop
  remainsPreBoundary : Prop
  activatesAugmentedDependencyRegime : Prop
  claimsLocalRecoveryOfMissingDependency : Prop
  substantiveAssessment : Prop
  leavesTerminalObligationOpen : Prop
  dischargesTerminalObligation : Prop

/-- A profile asserting no architecture-relevant semantic fact. -/
def emptyRoleSemanticProfile : RoleSemanticProfile where
  establishesInitialRegime := False
  primaryExplicitTransformation := False
  diagnosticCriterionStanding := False
  remainsPreBoundary := False
  activatesAugmentedDependencyRegime := False
  claimsLocalRecoveryOfMissingDependency := False
  substantiveAssessment := False
  leavesTerminalObligationOpen := False
  dischargesTerminalObligation := False

/--
Neutral effective contracts, stated without reference to FRFP constructor names.

The diagnostic contract is deliberately narrow. The boundary contract explicitly
rejects local decoding of the missing dependency. Assessment leaves terminal
closure open, while closure discharges it.
-/
def NeutralEffectiveContract
    (semantics : FRFPRole → RoleSemanticProfile)
    (position : RequiredEffectivePosition) (role : FRFPRole) : Prop :=
  match position with
  | .I => (semantics role).establishesInitialRegime
  | .P =>
      (semantics role).primaryExplicitTransformation ∧
      (semantics role).remainsPreBoundary
  | .Q =>
      (semantics role).diagnosticCriterionStanding ∧
      (semantics role).remainsPreBoundary
  | .B =>
      (semantics role).activatesAugmentedDependencyRegime ∧
      ¬ (semantics role).claimsLocalRecoveryOfMissingDependency
  | .A =>
      (semantics role).substantiveAssessment ∧
      (semantics role).leavesTerminalObligationOpen
  | .C => (semantics role).dischargesTerminalObligation

/--
Granular specification bridge assumptions. These fields expose the substantive
semantic facts rather than defining correspondence as equality of role names.
-/
structure FRFPSpecificationBridge
    (semantics : FRFPRole → RoleSemanticProfile) : Prop where
  riEstablishesInitialRegime :
    (semantics .RI).establishesInitialRegime
  ecPrimaryExplicitTransformation :
    (semantics .EC).primaryExplicitTransformation
  ecRemainsPreBoundary :
    (semantics .EC).remainsPreBoundary
  edDiagnosticCriterionStanding :
    (semantics .ED).diagnosticCriterionStanding
  edRemainsPreBoundary :
    (semantics .ED).remainsPreBoundary
  rbActivatesAugmentedDependencyRegime :
    (semantics .RB).activatesAugmentedDependencyRegime
  rbDoesNotClaimLocalRecovery :
    ¬ (semantics .RB).claimsLocalRecoveryOfMissingDependency
  teSubstantiveAssessment :
    (semantics .TE).substantiveAssessment
  teLeavesTerminalObligationOpen :
    (semantics .TE).leavesTerminalObligationOpen
  hfdDischargesTerminalObligation :
    (semantics .HFD).dischargesTerminalObligation

namespace FRFPSpecificationBridge

/-- The granular specification bridge constructs the generic correspondence witness. -/
theorem toCorrespondenceWitness
    (bridge : FRFPSpecificationBridge semantics) :
    FRFPCorrespondenceWitness (NeutralEffectiveContract semantics) := by
  refine ⟨?_⟩
  intro position
  cases position with
  | I => exact bridge.riEstablishesInitialRegime
  | P => exact ⟨bridge.ecPrimaryExplicitTransformation,
      bridge.ecRemainsPreBoundary⟩
  | Q => exact ⟨bridge.edDiagnosticCriterionStanding,
      bridge.edRemainsPreBoundary⟩
  | B => exact ⟨bridge.rbActivatesAugmentedDependencyRegime,
      bridge.rbDoesNotClaimLocalRecovery⟩
  | A => exact ⟨bridge.teSubstantiveAssessment,
      bridge.teLeavesTerminalObligationOpen⟩
  | C => exact bridge.hfdDischargesTerminalObligation

end FRFPSpecificationBridge

/--
Section 14.1 encoded as a closed semantic profile. `True` marks exactly the
architecture-relevant facts asserted by the specification-level comparison.
-/
def section14FRFPSemantics : FRFPRole → RoleSemanticProfile
  | .RI => {
      emptyRoleSemanticProfile with
      establishesInitialRegime := True
    }
  | .EC => {
      emptyRoleSemanticProfile with
      primaryExplicitTransformation := True
      remainsPreBoundary := True
    }
  | .ED => {
      emptyRoleSemanticProfile with
      diagnosticCriterionStanding := True
      remainsPreBoundary := True
    }
  | .RB => {
      emptyRoleSemanticProfile with
      activatesAugmentedDependencyRegime := True
    }
  | .TE => {
      emptyRoleSemanticProfile with
      substantiveAssessment := True
      leavesTerminalObligationOpen := True
    }
  | .HFD => {
      emptyRoleSemanticProfile with
      dischargesTerminalObligation := True
    }

/-- Kernel-checked encoding of the manuscript's six specification bridge facts. -/
theorem section14_specificationBridge :
    FRFPSpecificationBridge section14FRFPSemantics := by
  refine {
    riEstablishesInitialRegime := True.intro
    ecPrimaryExplicitTransformation := True.intro
    ecRemainsPreBoundary := True.intro
    edDiagnosticCriterionStanding := True.intro
    edRemainsPreBoundary := True.intro
    rbActivatesAugmentedDependencyRegime := True.intro
    rbDoesNotClaimLocalRecovery := ?_
    teSubstantiveAssessment := True.intro
    teLeavesTerminalObligationOpen := True.intro
    hfdDischargesTerminalObligation := True.intro
  }
  intro hfalse
  exact hfalse

/-- The manuscript semantics produces the previously open correspondence witness. -/
theorem section14_frfpCorrespondenceWitness :
    FRFPCorrespondenceWitness
      (NeutralEffectiveContract section14FRFPSemantics) :=
  section14_specificationBridge.toCorrespondenceWitness

/--
FRFP attainment no longer needs a caller-supplied correspondence witness once
the Section 14.1 semantic profile is selected. The independent lower-bound
witness remains an explicit input.
-/
theorem frfp_attains_lowerBound_under_section14_specification
    (requirements : EffectiveLowerBoundWitness semanticEquiv) :
    HasAtLeastSixClasses semanticEquiv ∧
      FRFPAttainsEffectiveLowerBound
        (NeutralEffectiveContract section14FRFPSemantics) := by
  exact frfp_attains_firstPrinciples_lowerBound requirements
    section14_frfpCorrespondenceWitness

end AlgebraOfHumanAiCollaboration
