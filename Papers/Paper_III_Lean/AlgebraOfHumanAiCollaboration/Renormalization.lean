import AlgebraOfHumanAiCollaboration.EffectiveCoarseGraining

/-!
# Architecture-preserving renormalization

This module states what a valid fine-to-effective renormalization must preserve.
It defines the open existence proposition but does not assert or assume a witness.
-/

namespace AlgebraOfHumanAiCollaboration

universe u v w x y z

variable {FineRoleType : Type u}
variable {Obligation : Type v} {Observable : Type w} {Value : Type x}
variable {PreFine : Type y} {PostFine : Type z}
variable {preSemanticEquiv : Setoid PreFine}
variable {postSemanticEquiv : Setoid PostFine}

/-- Roles in a richer description before an effective projection is selected. -/
inductive RichRole (PreFine : Type u) (PostFine : Type v) where
  | initialization
  | preBoundary (role : PreFine)
  | boundary
  | postBoundary (role : PostFine)

/-- Backward-compatible name for the richer role description. -/
abbrev FineRole := RichRole

/--
Architecture-relevant semantics shared by the fine and effective descriptions.
The fields are deliberately neutral and make each preservation obligation
independently inspectable.
-/
structure ArchitectureSemantics
    (Role : Type u) (Obligation : Type v)
    (Observable : Type w) (Value : Type x) where
  taskSufficient : Role → Prop
  admissibleComposition : Role → Role → Role → Prop
  dependencyAllowed : Role → Role → Prop
  boundaryAcquiring : Role → Prop
  satisfiesObligation : Obligation → Role → Prop
  episodeOpen : Role → Prop
  episodeTerminal : Role → Prop
  observe : Observable → Role → Value
  allowedTransition : Role → Role → Prop

variable {fine : ArchitectureSemantics FineRoleType Obligation Observable Value}
variable {effective : ArchitectureSemantics EffectiveRole Obligation Observable Value}
variable {renormalize : FineRoleType → EffectiveRole}
variable {left right : FineRoleType} {observable : Observable}

/--
The preservation contract for an architecture-respecting quotient. Logical
properties are preserved and reflected; observables are preserved by equality.
-/
structure PreservesArchitecture
    (fine : ArchitectureSemantics FineRoleType Obligation Observable Value)
    (effective : ArchitectureSemantics EffectiveRole Obligation Observable Value)
    (renormalize : FineRoleType → EffectiveRole) : Prop where
  taskSufficiency : ∀ role,
    fine.taskSufficient role ↔ effective.taskSufficient (renormalize role)
  composition : ∀ left right result,
    fine.admissibleComposition left right result ↔
      effective.admissibleComposition
        (renormalize left) (renormalize right) (renormalize result)
  dependency : ∀ source target,
    fine.dependencyAllowed source target ↔
      effective.dependencyAllowed (renormalize source) (renormalize target)
  boundary : ∀ role,
    fine.boundaryAcquiring role ↔ effective.boundaryAcquiring (renormalize role)
  obligation : ∀ obligation role,
    fine.satisfiesObligation obligation role ↔
      effective.satisfiesObligation obligation (renormalize role)
  openEpisode : ∀ role,
    fine.episodeOpen role ↔ effective.episodeOpen (renormalize role)
  terminalEpisode : ∀ role,
    fine.episodeTerminal role ↔ effective.episodeTerminal (renormalize role)
  observable : ∀ observable role,
    fine.observe observable role = effective.observe observable (renormalize role)
  transition : ∀ source target,
    fine.allowedTransition source target ↔
      effective.allowedTransition (renormalize source) (renormalize target)

namespace PreservesArchitecture

/-- Task insufficiency is preserved as the negation of task sufficiency. -/
theorem taskInsufficiency
    (preservation : PreservesArchitecture fine effective renormalize)
    (role : FineRoleType) :
    (¬ fine.taskSufficient role) ↔
      ¬ effective.taskSufficient (renormalize role) := by
  constructor
  · intro hfine heffective
    exact hfine ((preservation.taskSufficiency role).2 heffective)
  · intro heffective hfine
    exact heffective ((preservation.taskSufficiency role).1 hfine)

/--
Fine roles collapsed to one effective role must agree on every declared
architecture-relevant observable.
-/
theorem collapsed_roles_observationally_equal
    (preservation : PreservesArchitecture fine effective renormalize)
    (hcollapsed : renormalize left = renormalize right)
    (observable : Observable) :
    fine.observe observable left = fine.observe observable right := by
  calc
    fine.observe observable left =
        effective.observe observable (renormalize left) :=
      preservation.observable observable left
    _ = effective.observe observable (renormalize right) :=
      congrArg (effective.observe observable) hcollapsed
    _ = fine.observe observable right :=
      (preservation.observable observable right).symm

/-- A distinction visible to a declared observable cannot be coarse-grained away. -/
theorem observable_difference_prevents_collapse
    (preservation : PreservesArchitecture fine effective renormalize)
    (hdifferent : fine.observe observable left ≠ fine.observe observable right) :
    renormalize left ≠ renormalize right := by
  intro hcollapsed
  exact hdifferent
    (preservation.collapsed_roles_observationally_equal hcollapsed observable)

end PreservesArchitecture

namespace EffectiveCoarseGraining

/-- Extend the supplied internal classifiers to all roles in the fine architecture. -/
def renormalizeRole
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv) :
    RichRole PreFine PostFine → EffectiveRole
  | .initialization => EffectiveRole.I
  | .preBoundary role => model.effectivePreRole role
  | .boundary => EffectiveRole.B
  | .postBoundary role => model.effectivePostRole role

end EffectiveCoarseGraining

/-- A supplied coarse-graining is valid when its induced role map preserves semantics. -/
def IsValidRenormalization
    (model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv)
    (fine : ArchitectureSemantics
      (RichRole PreFine PostFine) Obligation Observable Value)
    (effective : ArchitectureSemantics
      EffectiveRole Obligation Observable Value) : Prop :=
  PreservesArchitecture fine effective model.renormalizeRole

/--
The open renormalization conjecture: suitable classification data exists and its
induced map preserves all declared architecture-relevant structure.

Defining this proposition introduces no postulate and supplies no proof of existence.
-/
def RenormalizationConjecture
    (preSemanticEquiv : Setoid PreFine)
    (postSemanticEquiv : Setoid PostFine)
    (fine : ArchitectureSemantics
      (RichRole PreFine PostFine) Obligation Observable Value)
    (effective : ArchitectureSemantics
      EffectiveRole Obligation Observable Value) : Prop :=
  ∃ model : EffectiveCoarseGraining preSemanticEquiv postSemanticEquiv,
    IsValidRenormalization model fine effective

end AlgebraOfHumanAiCollaboration
