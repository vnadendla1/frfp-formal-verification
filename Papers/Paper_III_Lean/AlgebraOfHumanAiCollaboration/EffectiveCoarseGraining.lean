import AlgebraOfHumanAiCollaboration.SemanticRoles

/-!
# Rich-to-effective six-role coarse-graining

This module encodes a projection from richer internal role descriptions onto the
paper's six effective positions. Constructing an `EffectiveCoarseGraining` is a
modeling choice; the separate effective-minimality theorem establishes the
conditional lower bound without assuming that every rich ontology has such a
projection.
-/

namespace AlgebraOfHumanAiCollaboration

universe u v

variable {PreFine : Type u} {PostFine : Type v}
variable {preSemanticEquiv : Setoid PreFine}
variable {postSemanticEquiv : Setoid PostFine}

/-- The two retained effective classes in the pre-boundary regime. -/
inductive PreBoundaryEffectiveClass where
  | primary
  | standing
deriving DecidableEq, Repr

/-- The two retained effective classes in the post-boundary regime. -/
inductive PostBoundaryEffectiveClass where
  | assessment
  | closure
deriving DecidableEq, Repr

/--
The neutral six-role effective architecture. The constructors represent the
architecture-level target, not an enumeration of all possible rich roles.
-/
inductive EffectiveRole where
  | initialization
  | preBoundary (role : PreBoundaryEffectiveClass)
  | boundary
  | postBoundary (role : PostBoundaryEffectiveClass)
deriving DecidableEq, Repr

/-- Neutral paper-facing name `I`. -/
abbrev EffectiveRole.I : EffectiveRole := .initialization

/-- Neutral paper-facing name `P`. -/
abbrev EffectiveRole.P : EffectiveRole := .preBoundary .primary

/-- Neutral paper-facing name `Q`. -/
abbrev EffectiveRole.Q : EffectiveRole := .preBoundary .standing

/-- Neutral paper-facing name `B`. -/
abbrev EffectiveRole.B : EffectiveRole := .boundary

/-- Neutral paper-facing name `A`. -/
abbrev EffectiveRole.A : EffectiveRole := .postBoundary .assessment

/-- Neutral paper-facing name `C`. -/
abbrev EffectiveRole.C : EffectiveRole := .postBoundary .closure

/--
Explicit coarse-graining data for the two fine internal regimes.

The classification functions are total, so every supplied fine role is assigned
to a retained effective class. Representative fields ensure that neither class
is empty. Compatibility fields require semantically equivalent fine roles to
receive the same effective classification; the converse is intentionally absent,
because coarse-graining is allowed to collapse fine distinctions.
-/
structure EffectiveCoarseGraining
    (preSemanticEquiv : Setoid PreFine)
    (postSemanticEquiv : Setoid PostFine) where
  classifyPre : PreFine → PreBoundaryEffectiveClass
  classifyPost : PostFine → PostBoundaryEffectiveClass
  preRespectsEquivalence :
    ∀ ⦃left right⦄, preSemanticEquiv.r left right →
      classifyPre left = classifyPre right
  postRespectsEquivalence :
    ∀ ⦃left right⦄, postSemanticEquiv.r left right →
      classifyPost left = classifyPost right
  primaryRepresentative : PreFine
  standingRepresentative : PreFine
  assessmentRepresentative : PostFine
  closureRepresentative : PostFine
  primaryClassified : classifyPre primaryRepresentative = .primary
  standingClassified : classifyPre standingRepresentative = .standing
  assessmentClassified : classifyPost assessmentRepresentative = .assessment
  closureClassified : classifyPost closureRepresentative = .closure

namespace EffectiveCoarseGraining

/-- Embed the classified fine pre-boundary role into the six-role model. -/
def effectivePreRole
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (role : PreFine) : EffectiveRole :=
  .preBoundary (model.classifyPre role)

/-- Embed the classified fine post-boundary role into the six-role model. -/
def effectivePostRole
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (role : PostFine) : EffectiveRole :=
  .postBoundary (model.classifyPost role)

/-- Equivalent fine pre-boundary roles have the same effective role. -/
theorem effectivePreRole_respects_equivalence
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (hequiv : preSemanticEquiv.r left right) :
    model.effectivePreRole left = model.effectivePreRole right := by
  change EffectiveRole.preBoundary (model.classifyPre left) =
    EffectiveRole.preBoundary (model.classifyPre right)
  rw [model.preRespectsEquivalence hequiv]

/-- Equivalent fine post-boundary roles have the same effective role. -/
theorem effectivePostRole_respects_equivalence
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (hequiv : postSemanticEquiv.r left right) :
    model.effectivePostRole left = model.effectivePostRole right := by
  change EffectiveRole.postBoundary (model.classifyPost left) =
    EffectiveRole.postBoundary (model.classifyPost right)
  rw [model.postRespectsEquivalence hequiv]

/-- Every fine pre-boundary role is assigned to `P` or `Q`. -/
theorem effectivePreRole_is_P_or_Q
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (role : PreFine) :
    model.effectivePreRole role = EffectiveRole.P ∨
      model.effectivePreRole role = EffectiveRole.Q := by
  cases hclass : model.classifyPre role with
  | primary => exact Or.inl (congrArg EffectiveRole.preBoundary hclass)
  | standing => exact Or.inr (congrArg EffectiveRole.preBoundary hclass)

/-- Every fine post-boundary role is assigned to `A` or `C`. -/
theorem effectivePostRole_is_A_or_C
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (role : PostFine) :
    model.effectivePostRole role = EffectiveRole.A ∨
      model.effectivePostRole role = EffectiveRole.C := by
  cases hclass : model.classifyPost role with
  | assessment => exact Or.inl (congrArg EffectiveRole.postBoundary hclass)
  | closure => exact Or.inr (congrArg EffectiveRole.postBoundary hclass)

/-- The chosen model actually represents `P`. -/
theorem realizes_P
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv) :
    model.effectivePreRole model.primaryRepresentative = EffectiveRole.P := by
  exact congrArg EffectiveRole.preBoundary model.primaryClassified

/-- The chosen model actually represents `Q`. -/
theorem realizes_Q
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv) :
    model.effectivePreRole model.standingRepresentative = EffectiveRole.Q := by
  exact congrArg EffectiveRole.preBoundary model.standingClassified

/-- The chosen model actually represents `A`. -/
theorem realizes_A
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv) :
    model.effectivePostRole model.assessmentRepresentative = EffectiveRole.A := by
  exact congrArg EffectiveRole.postBoundary model.assessmentClassified

/-- The chosen model actually represents `C`. -/
theorem realizes_C
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv) :
    model.effectivePostRole model.closureRepresentative = EffectiveRole.C := by
  exact congrArg EffectiveRole.postBoundary model.closureClassified

end EffectiveCoarseGraining

end AlgebraOfHumanAiCollaboration
