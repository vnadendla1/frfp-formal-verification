import Frfp.Minimal.BasisConsequences

namespace Frfp.Minimal.BasisSweep

open Frfp.Core.Kernel
open Frfp.Minimal.ReducedBasis
open Frfp.Minimal.BasisConsequences

/-!
Sweep module for theorem opportunities from the reduced basis.

Includes:
1) Proven consequences available now.
2) Candidate theorem statements (stubs) for future strengthening.
-/

/-- AI-only traces contain no boundary crossing primitive RB. -/
theorem ai_only_trace_no_boundary
    (tr : List Primitive)
    (hAI : ∀ p, p ∈ tr → is_AI_executable p = true) :
    Primitive.RB ∉ tr := by
  intro hIn
  have hRB : is_AI_executable Primitive.RB = true := hAI Primitive.RB hIn
  simp [is_AI_executable] at hRB

/-- Every primitive in an AI-only trace targets explicit space E0. -/
theorem ai_only_trace_targets_explicit
    (tr : List Primitive)
    (hAI : ∀ p, p ∈ tr → is_AI_executable p = true) :
    ∀ p, p ∈ tr → p.target = Object.E0 := by
  intro p hp
  exact (AE_derivable p (hAI p hp)).2

/-- Three-phase view for primitives: explicit, boundary, or tacit. -/
inductive PrimitivePhase where
  | explicit
  | boundary
  | tacit
  deriving Repr, DecidableEq

/-- Phase classifier induced by kernel primitive typing. -/
def phaseOf : Primitive → PrimitivePhase
  | Primitive.RI => PrimitivePhase.explicit
  | Primitive.EC => PrimitivePhase.explicit
  | Primitive.ED => PrimitivePhase.explicit
  | Primitive.RB => PrimitivePhase.boundary
  | Primitive.TE => PrimitivePhase.tacit
  | Primitive.HFD => PrimitivePhase.tacit

/-- Primitive phase partition is total. -/
theorem phase_partition (p : Primitive) :
    phaseOf p = PrimitivePhase.explicit ∨
    phaseOf p = PrimitivePhase.boundary ∨
    phaseOf p = PrimitivePhase.tacit := by
  cases p <;> simp [phaseOf]

/-- Boundary phase is uniquely represented by RB. -/
theorem phase_boundary_iff (p : Primitive) :
    phaseOf p = PrimitivePhase.boundary ↔ p = Primitive.RB := by
  cases p <;> simp [phaseOf]

/--
A concrete unresolved-ambiguity event at a natural index.
Encodes the AR violation shape as a bounded witness.
-/
def unresolvedAtNat (t : ProtocolTrace) (n : Nat) : Prop :=
  ∃ h : n < t.length,
    let i : Fin t.length := ⟨n, h⟩
    (t.get i).ambiguous = true ∧ (t.get i).clarified = false

/--
If unresolved ambiguity exists, there is a minimal witness index.
This gives canonical localization for AR-style violations.
-/
theorem first_unresolved_witness
    (t : ProtocolTrace)
    (hEx : ∃ n, unresolvedAtNat t n) :
    ∃ n, unresolvedAtNat t n ∧ ∀ m, m < n → ¬ unresolvedAtNat t m := by
  let P : Nat → Prop := unresolvedAtNat t
  have hP : ∃ n, P n := hEx
  refine ⟨Nat.find hP, Nat.find_spec hP, ?_⟩
  intro m hm hPm
  exact (Nat.find_min' hP hPm) (Nat.not_lt.mpr (Nat.le_of_lt hm))

/-!
Constructive stronger-admissibility model.

This section turns the prior theorem candidates into fully proved theorems
under stronger, extension-friendly invariants.
-/

/-- Strong IL as pairwise trace consistency on AI-labelled steps. -/
def IL_global (t : ProtocolTrace) : Prop :=
  ∀ a ∈ t, ∀ b ∈ t,
    a.isAI = true → b.isAI = true → a.intentTag = b.intentTag

/-- Strong AR: every ambiguous step is clarified. -/
def AR_global (t : ProtocolTrace) : Prop :=
  ∀ a ∈ t, a.ambiguous = true → a.clarified = true

/--
Strong CSC (order-free strengthening):
if any step is correctness-locked, then all steps are correctness-locked.
-/
def CSC_global (t : ProtocolTrace) : Prop :=
  (∃ a, a ∈ t ∧ a.correctnessLocked = true) →
  ∀ b, b ∈ t → b.correctnessLocked = true

/-- Combined strong governance admissibility. -/
def GovernanceAdmissibleStrong (t : ProtocolTrace) : Prop :=
  IL_global t ∧ AR_global t ∧ CSC_global t

/-- Compatibility side-conditions for extending a strongly admissible trace. -/
structure StepCompatibleStrong (t : ProtocolTrace) (s : StepRecord) : Prop where
  intentCompat : ∀ a, a ∈ t → a.isAI = true → s.isAI = true → a.intentTag = s.intentTag
  ambiguityCompat : s.ambiguous = true → s.clarified = true
  lockForward : (∃ a, a ∈ t ∧ a.correctnessLocked = true) → s.correctnessLocked = true
  lockBackward : s.correctnessLocked = true → ∀ a, a ∈ t → a.correctnessLocked = true

/--
Governance safety extension theorem (constructive, proved):
strong governance invariants are preserved under compatible one-step extension.
-/
theorem governance_safe_extension_theorem
    (t : ProtocolTrace)
    (s : StepRecord)
    (hAdm : GovernanceAdmissibleStrong t)
    (hCompat : StepCompatibleStrong t s) :
    GovernanceAdmissibleStrong (t ++ [s]) := by
  rcases hAdm with ⟨hIL, hAR, hCSC⟩
  constructor
  · intro a ha b hb hAIa hAIb
    have ha' : a ∈ t ∨ a = s := by
      simpa [List.mem_append, List.mem_singleton] using ha
    have hb' : b ∈ t ∨ b = s := by
      simpa [List.mem_append, List.mem_singleton] using hb
    cases ha' with
    | inl ha_t =>
        cases hb' with
        | inl hb_t =>
            exact hIL a ha_t b hb_t hAIa hAIb
        | inr hb_s =>
            rw [hb_s]
            exact hCompat.intentCompat a ha_t hAIa hAIb
    | inr ha_s =>
        cases hb' with
        | inl hb_t =>
            rw [ha_s]
            have hEq : b.intentTag = s.intentTag :=
              hCompat.intentCompat b hb_t hAIb hAIa
            exact hEq.symm
        | inr hb_s =>
            rw [ha_s, hb_s]
  · constructor
    · intro a ha hAmb
      have ha' : a ∈ t ∨ a = s := by
        simpa [List.mem_append, List.mem_singleton] using ha
      cases ha' with
      | inl ha_t => exact hAR a ha_t hAmb
      | inr ha_s =>
          rw [ha_s] at hAmb ⊢
          exact hCompat.ambiguityCompat hAmb
    · intro hEx b hb
      have hb' : b ∈ t ∨ b = s := by
        simpa [List.mem_append, List.mem_singleton] using hb
      have hEx' : (∃ a, a ∈ t ∧ a.correctnessLocked = true) ∨ s.correctnessLocked = true := by
        rcases hEx with ⟨a, ha, hLock⟩
        have ha' : a ∈ t ∨ a = s := by
          simpa [List.mem_append, List.mem_singleton] using ha
        cases ha' with
        | inl ha_t => exact Or.inl ⟨a, ha_t, hLock⟩
        | inr ha_s =>
            rw [ha_s] at hLock
            exact Or.inr hLock
      cases hb' with
      | inl hb_t =>
          cases hEx' with
          | inl hOld => exact hCSC hOld b hb_t
          | inr hNew => exact hCompat.lockBackward hNew b hb_t
      | inr hb_s =>
          rw [hb_s]
          cases hEx' with
          | inl hOld => exact hCompat.lockForward hOld
          | inr hNew => exact hNew

/--
Primitive-trace admissibility for normal form:
there exists an explicit block, optional unique boundary, and tacit block.
-/
def PrimitiveTraceAdmissibleStrong (tr : List Primitive) : Prop :=
  ∃ (expPhase tacPhase : List Primitive) (hasBoundary : Bool),
    tr = expPhase ++ (if hasBoundary then [Primitive.RB] else []) ++ tacPhase ∧
    (∀ p, p ∈ expPhase → phaseOf p = PrimitivePhase.explicit) ∧
    (∀ p, p ∈ tacPhase → phaseOf p = PrimitivePhase.tacit)

/--
Protocol normal form theorem (constructive, proved):
any strongly admissible primitive trace has the expected phase decomposition.
-/
theorem protocol_normal_form_theorem
    (tr : List Primitive)
    (hAdm : PrimitiveTraceAdmissibleStrong tr) :
    ∃ (expPhase tacPhase : List Primitive) (hasBoundary : Bool),
      tr = expPhase ++ (if hasBoundary then [Primitive.RB] else []) ++ tacPhase := by
  rcases hAdm with ⟨expPhase, tacPhase, hasBoundary, hEq, _, _⟩
  exact ⟨expPhase, tacPhase, hasBoundary, hEq⟩

end Frfp.Minimal.BasisSweep
