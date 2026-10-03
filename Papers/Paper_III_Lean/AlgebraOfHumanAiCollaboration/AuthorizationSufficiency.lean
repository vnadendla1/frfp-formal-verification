import AlgebraOfHumanAiCollaboration.Authorization

/-!
# Authorization sufficiency and principal-grounded provenance

This module separates two questions. Factorization determines whether an
operative representation contains enough information for a family of
authorization judgments. Principal-grounded closure instead depends on
independently supplied principal data and authorization-provenance laws.
-/

namespace AlgebraOfHumanAiCollaboration

universe u v w

variable {Λ : Type v} {W E : Type u} {Decision : Λ → Type w}

/-- The product-valued judgment collecting an indexed authorization family. -/
def jointAuthorization (authorization : (idx : Λ) → W → Decision idx) :
    W → ((idx : Λ) → Decision idx) :=
  fun state idx => authorization idx state

/-- Sufficiency for every judgment is equivalent to sufficiency for their joint map. -/
theorem authorizationFamilySufficient_iff_joint
    (authorization : (idx : Λ) → W → Decision idx) (representation : W → E) :
    (∀ idx, FactorsThrough (authorization idx) representation) ↔
      FactorsThrough (jointAuthorization authorization) representation := by
  constructor
  · intro h
    classical
    let decoder := fun idx => Classical.choose (h idx)
    have hdecoder : ∀ idx state,
        authorization idx state = decoder idx (representation state) := by
      intro idx
      exact Classical.choose_spec (h idx)
    refine ⟨fun encoded idx => decoder idx encoded, ?_⟩
    intro state
    funext idx
    exact hdecoder idx state
  · intro h idx
    obtain ⟨decoder, hdecoder⟩ := h
    refine ⟨fun encoded => decoder encoded idx, ?_⟩
    intro state
    exact congrFun (hdecoder state) idx

/-- Kernel form of simultaneous sufficiency for an authorization family. -/
def AuthorizationFamilyKernelIncluded
    (authorization : (idx : Λ) → W → Decision idx) (representation : W → E) : Prop :=
  ∀ ⦃state₁ state₂⦄, representation state₁ = representation state₂ →
    ∀ idx, authorization idx state₁ = authorization idx state₂

/-- The family-level kernel criterion, under the same nonempty-domain condition
as the general factorization converse. -/
theorem authorizationFamilySufficient_iff_kernelIncluded [Nonempty W]
    (authorization : (idx : Λ) → W → Decision idx) (representation : W → E) :
    (∀ idx, FactorsThrough (authorization idx) representation) ↔
      AuthorizationFamilyKernelIncluded authorization representation := by
  constructor
  · intro h state₁ state₂ heq idx
    exact factorsThrough_kernelIncluded (h idx) heq
  · intro h idx
    apply (factorsThrough_iff_kernelIncluded (authorization idx) representation).2
    intro state₁ state₂ heq
    exact h heq idx

/-- The authorization family distinguishes every distinct pair in `domain`. -/
def AuthorizationFamilySeparatesOn
    (authorization : (idx : Λ) → W → Decision idx) (domain : W → Prop) : Prop :=
  ∀ ⦃state₁ state₂⦄, domain state₁ → domain state₂ → state₁ ≠ state₂ →
    ∃ idx, authorization idx state₁ ≠ authorization idx state₂

/-- A representation sufficient for a separating authorization family is
injective on the authorization-relevant domain. -/
theorem authorizationSeparation
    (authorization : (idx : Λ) → W → Decision idx) (representation : W → E)
    (domain : W → Prop)
    (hsufficient : ∀ idx, FactorsThrough (authorization idx) representation)
    (hseparates : AuthorizationFamilySeparatesOn authorization domain) :
    ∀ ⦃state₁ state₂⦄, domain state₁ → domain state₂ →
      representation state₁ = representation state₂ → state₁ = state₂ := by
  intro state₁ state₂ hstate₁ hstate₂ heq
  apply Classical.byContradiction
  intro hne
  obtain ⟨idx, hdistinguishes⟩ := hseparates hstate₁ hstate₂ hne
  exact hdistinguishes (factorsThrough_kernelIncluded (hsufficient idx) heq)

/-- A finite trace of zero or more valid delegations.

This records provenance only. It carries no scope, time, expiry, revocation, or
reaffirmation semantics; applications requiring those constraints must enrich
the authorization specification.
-/
inductive DelegationTrace (delegates : Participant → Participant → Prop) :
    Participant → Participant → Prop where
  | refl (participant : Participant) : DelegationTrace delegates participant participant
  | step {source delegate target : Participant} :
      delegates source delegate →
      DelegationTrace delegates delegate target →
      DelegationTrace delegates source target

/-- Application data selecting the principal, obligation, and action. -/
structure PrincipalStipulation (Participant Obligation Action : Type u) where
  principal : Participant
  obligation : Obligation
  action : Action

/-- The paper-scoped Human-Principal Axiom represented as explicit application
data, rather than as a global Lean axiom. It specializes the otherwise
actor-neutral principal stipulation without entering the role lower bound. -/
structure HumanPrincipalAxiom
    (spec : PrincipalStipulation Participant Obligation Action) where
  human : Participant
  principal_eq : spec.principal = human

/-- Authorization semantics kept separate from the principal stipulation.
Validity entails authority, but the source of that authority is supplied by a
separate grounding law in the theorem below. -/
structure AuthorizationProvenanceSemantics
    (Participant Obligation Action : Type u) where
  validClose : Participant → Obligation → Action → Prop
  hasAuthority : Participant → Obligation → Action → Prop
  delegates : Obligation → Participant → Participant → Prop
  validCloseRequiresAuthority :
    ∀ participant obligation action,
      validClose participant obligation action →
        hasAuthority participant obligation action

/-- Every valid closure for the selected obligation and action is performed by
the principal or by a participant reached through valid delegation. -/
def PrincipalGroundedClosure
    (spec : PrincipalStipulation Participant Obligation Action)
    (semantics : AuthorizationProvenanceSemantics Participant Obligation Action) : Prop :=
  ∀ participant,
    semantics.validClose participant spec.obligation spec.action →
      participant = spec.principal ∨
        DelegationTrace (semantics.delegates spec.obligation)
          spec.principal participant

/-- Principal-grounded closure follows from validity-implies-authority and an
independently supplied law grounding derivative authority in the stipulated
principal. Principalhood alone does not prove provenance. -/
theorem principalGroundedClosure
    (spec : PrincipalStipulation Participant Obligation Action)
    (semantics : AuthorizationProvenanceSemantics Participant Obligation Action)
    (authorityGrounded : ∀ participant,
      semantics.hasAuthority participant spec.obligation spec.action →
        participant = spec.principal ∨
          DelegationTrace (semantics.delegates spec.obligation)
            spec.principal participant) :
    PrincipalGroundedClosure spec semantics := by
  intro participant hvalid
  exact authorityGrounded participant
    (semantics.validCloseRequiresAuthority participant spec.obligation spec.action hvalid)

/-- Human-grounded closure is a specialization of principal-grounded closure,
not a consequence of the actor-neutral theory. -/
theorem humanGroundedClosure
    (spec : PrincipalStipulation Participant Obligation Action)
    (semantics : AuthorizationProvenanceSemantics Participant Obligation Action)
    (humanAxiom : HumanPrincipalAxiom spec)
    (authorityGrounded : ∀ participant,
      semantics.hasAuthority participant spec.obligation spec.action →
        participant = spec.principal ∨
          DelegationTrace (semantics.delegates spec.obligation)
            spec.principal participant) :
    ∀ participant,
      semantics.validClose participant spec.obligation spec.action →
        participant = humanAxiom.human ∨
          DelegationTrace (semantics.delegates spec.obligation)
            humanAxiom.human participant := by
  intro participant hvalid
  simpa [humanAxiom.principal_eq] using
    (principalGroundedClosure spec semantics authorityGrounded participant hvalid)

end AlgebraOfHumanAiCollaboration
