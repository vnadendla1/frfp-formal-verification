import AlgebraOfHumanAiCollaboration.EffectiveCoarseGraining

/-!
# Effective six-role lower bound and FRFP realization

This module formalizes the revised paper's central claim boundary. Six is a
conditional lower bound on architecture-level semantic equivalence classes; it
is not asserted as the cardinality of a maximally rich role ontology.
-/

namespace AlgebraOfHumanAiCollaboration

/-- The four architecture regions used by the lower-bound argument. -/
inductive EffectiveRegion where
  | initialization
  | preBoundary
  | boundary
  | postBoundary
deriving DecidableEq, Repr

/-- The six independently required architecture-level positions. -/
inductive RequiredEffectivePosition where
  | I
  | P
  | Q
  | B
  | A
  | C
deriving DecidableEq, Repr

/-- Region occupied by each required effective position. -/
def RequiredEffectivePosition.region : RequiredEffectivePosition → EffectiveRegion
  | .I => .initialization
  | .P => .preBoundary
  | .Q => .preBoundary
  | .B => .boundary
  | .A => .postBoundary
  | .C => .postBoundary

/-- Six indexed roles that are pairwise non-collapsible under semantic equivalence. -/
structure SixClassWitness (semanticEquiv : Setoid Role) where
  roleAt : RequiredEffectivePosition → Role
  noncollapse : ∀ ⦃left right⦄,
    semanticEquiv.r (roleAt left) (roleAt right) → left = right

/-- Paper-facing meaning of the effective lower bound `N_eff >= 6`. -/
def HasAtLeastSixClasses (semanticEquiv : Setoid Role) : Prop :=
  Nonempty (SixClassWitness semanticEquiv)

/--
Explicit First-Principles witness conditions for the six-class lower bound.

`sameRegionNoncollapse` contains the conditional internal-role witness result in
the pre- and post-boundary regions. `equivalencePreservesRegion` exposes the
cross-region non-identification condition required by the revised paper.
-/
structure EffectiveLowerBoundWitness (semanticEquiv : Setoid Role) where
  roleAt : RequiredEffectivePosition → Role
  roleRegion : Role → EffectiveRegion
  positionRegion : ∀ position,
    roleRegion (roleAt position) = position.region
  equivalencePreservesRegion : ∀ ⦃left right⦄,
    semanticEquiv.r left right → roleRegion left = roleRegion right
  sameRegionNoncollapse : ∀ ⦃left right : RequiredEffectivePosition⦄,
    left.region = right.region →
    semanticEquiv.r (roleAt left) (roleAt right) →
    left = right

namespace EffectiveLowerBoundWitness

/-- Equivalent required roles must occupy the same architecture region. -/
theorem required_roles_same_region
    (witness : EffectiveLowerBoundWitness semanticEquiv)
    (hequivalent : semanticEquiv.r
      (witness.roleAt left) (witness.roleAt right)) :
    left.region = right.region := by
  calc
    left.region = witness.roleRegion (witness.roleAt left) :=
      (witness.positionRegion left).symm
    _ = witness.roleRegion (witness.roleAt right) :=
      witness.equivalencePreservesRegion hequivalent
    _ = right.region := witness.positionRegion right

/-- Roles from different architecture regions cannot be identified. -/
theorem crossRegion_noncollapse
    (witness : EffectiveLowerBoundWitness semanticEquiv)
    (hdifferent : left.region ≠ right.region) :
    ¬ semanticEquiv.r (witness.roleAt left) (witness.roleAt right) := by
  intro hequivalent
  exact hdifferent (witness.required_roles_same_region hequivalent)

/-- The explicit First-Principles witness conditions yield six distinct classes. -/
theorem hasAtLeastSixClasses
    (witness : EffectiveLowerBoundWitness semanticEquiv) :
    HasAtLeastSixClasses semanticEquiv := by
  refine ⟨{
    roleAt := witness.roleAt
    noncollapse := ?_
  }⟩
  intro left right hequivalent
  exact witness.sameRegionNoncollapse
    (witness.required_roles_same_region hequivalent) hequivalent

end EffectiveLowerBoundWitness

/-- Revised paper's First-Principles effective-role lower-bound theorem. -/
theorem firstPrinciples_effectiveRoleLowerBound
    (witness : EffectiveLowerBoundWitness semanticEquiv) :
    HasAtLeastSixClasses semanticEquiv :=
  witness.hasAtLeastSixClasses

/-- A complete six-class presentation: six non-collapsible representatives cover all roles. -/
structure ExactlySixClassWitness (semanticEquiv : Setoid Role)
    extends SixClassWitness semanticEquiv where
  complete : ∀ role, ∃ position,
    semanticEquiv.r role (roleAt position)

/-- Paper-facing meaning of an effective theory having exactly six classes. -/
def HasExactlySixClasses (semanticEquiv : Setoid Role) : Prop :=
  Nonempty (ExactlySixClassWitness semanticEquiv)

/-- The six published FRFP effective roles, introduced only at the comparison layer. -/
inductive FRFPRole where
  | RI
  | EC
  | ED
  | RB
  | TE
  | HFD
deriving DecidableEq, Repr

/-- Equality is the comparison-layer semantic equivalence for the six-role witness. -/
def frfpSemanticEquiv : Setoid FRFPRole where
  r := Eq
  iseqv := {
    refl := Eq.refl
    symm := Eq.symm
    trans := Eq.trans
  }

/-- Independent positions mapped to their published FRFP counterparts. -/
def frfpRoleAt : RequiredEffectivePosition → FRFPRole
  | .I => .RI
  | .P => .EC
  | .Q => .ED
  | .B => .RB
  | .A => .TE
  | .C => .HFD

/-- Inverse position of each published FRFP role. -/
def FRFPRole.position : FRFPRole → RequiredEffectivePosition
  | .RI => .I
  | .EC => .P
  | .ED => .Q
  | .RB => .B
  | .TE => .A
  | .HFD => .C

theorem frfp_position_roleAt (position : RequiredEffectivePosition) :
    (frfpRoleAt position).position = position := by
  cases position <;> rfl

theorem frfp_roleAt_position (role : FRFPRole) :
    frfpRoleAt role.position = role := by
  cases role <;> rfl

/-- FRFP has exactly six effective role classes at the comparison layer. -/
theorem frfp_hasExactlySixClasses :
    HasExactlySixClasses frfpSemanticEquiv := by
  refine ⟨{
    roleAt := frfpRoleAt
    noncollapse := ?_
    complete := ?_
  }⟩
  · intro left right hequal
    calc
      left = (frfpRoleAt left).position := (frfp_position_roleAt left).symm
      _ = (frfpRoleAt right).position := congrArg FRFPRole.position hequal
      _ = right := frfp_position_roleAt right
  · intro role
    exact ⟨role.position, (frfp_roleAt_position role).symm⟩

/--
Semantic correspondence obligations kept separate from the independent lower
bound. A caller must show that each published role realizes its neutral contract.
-/
structure FRFPCorrespondenceWitness
    (Contract : RequiredEffectivePosition → FRFPRole → Prop) : Prop where
  realizes : ∀ position, Contract position (frfpRoleAt position)

/-- FRFP realizes six classes and all supplied neutral correspondence contracts. -/
def FRFPAttainsEffectiveLowerBound
    (Contract : RequiredEffectivePosition → FRFPRole → Prop) : Prop :=
  HasExactlySixClasses frfpSemanticEquiv ∧
    Nonempty (FRFPCorrespondenceWitness Contract)

/--
Conditional FRFP effective-minimality result: qualifying architectures require
six classes, while FRFP has six and realizes every supplied correspondence
obligation.
-/
theorem frfp_attains_firstPrinciples_lowerBound
    (requirements : EffectiveLowerBoundWitness semanticEquiv)
    (correspondence : FRFPCorrespondenceWitness Contract) :
    HasAtLeastSixClasses semanticEquiv ∧
      FRFPAttainsEffectiveLowerBound Contract := by
  exact ⟨requirements.hasAtLeastSixClasses,
    frfp_hasExactlySixClasses, ⟨correspondence⟩⟩

end AlgebraOfHumanAiCollaboration
