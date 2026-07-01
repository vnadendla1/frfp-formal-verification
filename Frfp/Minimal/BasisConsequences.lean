import Frfp.Minimal.ReducedBasis

namespace Frfp.Minimal.BasisConsequences

open Frfp.Core.Kernel
open Frfp.Minimal.ReducedBasis

/-!
Consequences derivable from the reduced FRFP basis and kernel typing.

This module is intentionally separate from Core and focuses on reusable
lemmas for new projects that adopt the minimal basis.
-/

/-- Any primitive with tacit source must be TE or HFD. -/
theorem tacit_source_classification (p : Primitive) :
    p.source = Object.T0 → p = Primitive.TE ∨ p = Primitive.HFD := by
  intro h
  cases p <;> simp [Primitive.source] at h

/-- Tacit-source steps are closed in tacit space. -/
theorem tacit_source_stays_tacit (p : Primitive) :
    p.source = Object.T0 → p.target = Object.T0 := by
  intro h
  cases p <;> simp [Primitive.source, Primitive.target] at h ⊢

/-- AI-executable primitives cannot target tacit space. -/
theorem ai_never_targets_tacit (p : Primitive) :
    is_AI_executable p = true → p.target ≠ Object.T0 := by
  intro hAI hT
  have hE : p.target = Object.E0 := (AE_derivable p hAI).2
  cases hE.trans hT.symm

/-- AI-executable and human-only sets are disjoint. -/
theorem ai_human_disjoint (p : Primitive) :
    is_AI_executable p = true → is_human_only p = false := by
  intro hAI
  cases p <;> simp [is_AI_executable, is_human_only] at hAI ⊢

/-- The only primitive that enters tacit space from explicit space is RB. -/
theorem unique_boundary_entry (p : Primitive) :
    p.source = Object.E0 → p.target = Object.T0 → p = Primitive.RB := by
  intro hS hT
  exact RB_derivable p ⟨hS, hT⟩

/-- Pairwise intent consistency on AI-labelled steps (IL skeleton). -/
theorem IL_pairwise_intent_consistency
    (t : ProtocolTrace)
    (hIL : IL_skeleton t)
    (i j : Fin t.length)
    (hAIi : (t.get i).isAI = true)
    (hAIj : (t.get j).isAI = true) :
    (t.get i).intentTag = (t.get j).intentTag :=
  hIL i j hAIi hAIj

/-- Ambiguous steps are clarified before action (AR skeleton). -/
theorem AR_no_unresolved_ambiguity
    (t : ProtocolTrace)
    (hAR : AR_skeleton t)
    (i : Fin t.length)
    (hAmb : (t.get i).ambiguous = true) :
    (t.get i).clarified = true :=
  hAR i hAmb

/-- Once correctness is locked, later steps preserve the lock (CSC skeleton). -/
theorem CSC_lock_is_monotone
    (t : ProtocolTrace)
    (hCSC : CSC_skeleton t)
    (i j : Fin t.length)
    (hLe : i.1 ≤ j.1)
    (hLock : (t.get i).correctnessLocked = true) :
    (t.get j).correctnessLocked = true :=
  hCSC i j hLe hLock

end Frfp.Minimal.BasisConsequences
