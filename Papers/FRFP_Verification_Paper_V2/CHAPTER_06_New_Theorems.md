# Chapter 6: New Theorems from Formalization

**Paper**: FRFP Lean Formal Verification  
**Chapter**: 6 of 8  
**Source documents**: [Appendix C](APPENDIX_C_Proposals.md) (all 11 proposals, full text)

---

## 6.1 Overview

The formalization produced three categories of new results:

1. **Proposals for theory incorporation** (11 items): gaps, clarifications, or structural decisions forced by Lean's type system that were not explicit in the published papers.
2. **Direct consequences of the reduced basis** (8 theorems): straightforward derivations from the 7-primitive basis; verified in `BasisConsequences.lean`.
3. **Novel structural theorems** (3 results): non-trivial theorems not conjectured before formalization; verified in `BasisSweep.lean`.

---

## 6.2 Theory Incorporation Proposals

These proposals emerged from proof obligations in Lean. They are recommended additions or clarifications to the FRFP theory papers.

**P-01 — Reduction operates on objects, not morphisms.**  
Lean's type system forced an explicit architectural decision: reduction steps are relations on `GrothendieckObject` (configurations), not on morphisms. A morphism is induced by a reduction step but is distinct from it. The paper should state this explicitly.

```lean
theorem reduction_induces_morphism :
    ReductionStep cfg1 cfg2 →
    ∃ (m : GrothendieckMorphism), m.source = cfg1 ∧ m.target = cfg2
```

**P-02 — runToω bijection must be explicit.**  
Remark A.104 treated runs and stochastic trajectories as corresponding but did not define the bijection map. Lean required a concrete function `runToω`, an inverse `ωToRun`, injectivity, and a round-trip property. These four properties should be stated in the paper.

**P-03 — 41 axioms are provable theorems.**  
A systematic audit converted 41 candidate axioms to Lean theorems. The paper's axiom count should be revised from 193 to 155, with the reduction explicitly documented.

**P-04 — Credence clamping is a theorem, not an axiom.**  
The clamping of credence values to [0,1] is a consequence of IEEE 754 order properties, not an independent assumption.

**P-05 — Probability theorems have Lean proofs.**  
Five probability theorems (survival product formula, hazard-survival relation, survival monotonicity, expected stopping time, infinite product limit) are machine-verified. They were stated as axioms in early versions.

**P-06 — Confluence key lemma needs explicit statement.**  
Lean's confluence proof required a key lemma (diamond property for each pair of reductions) that was implicit in the paper. This lemma should be stated as Lemma A.7.6a in the paper.

**P-07 — Normal forms modulo navigation, not absolute.**  
The paper's normal-form result was stated as absolute uniqueness. Lean showed uniqueness only holds modulo navigation equivalence. The paper statement needs this qualification.

**P-08 — Observable correctness invariance is a separate theorem.**  
Lean separates semantic correctness into two distinct theorems (unique normal forms, observable invariance). These should be numbered separately in the paper.

**P-09 — NTER derivable from Kernel typing.**  
No-Tacit-Emulation is not an independent premise; it follows from the absence of T0→E0 morphisms in the Kernel. The paper should note this derivability.

**P-10 — Policy residue is explicit and separated.**  
The interaction premises IL, AR, CSC each have a structural skeleton (derivable or source-anchored) and a residual policy component (normative choice). The paper should distinguish these explicitly.

**P-11 — Grothendieck construction is the architectural choice, not just a tool.**  
Lean's formalization of the multi-agent layer required the Grothendieck construction as a structural necessity. The paper should promote this from "mathematical tool" to "architectural premise."

---

## 6.3 Direct Consequences of the Reduced Basis

These eight theorems follow directly from the 7-primitive basis without additional assumptions. They are verified in `Frfp/Minimal/BasisConsequences.lean`.

| Theorem | Statement | Novelty |
|---|---|---|
| `tacit_source_classification` | T0-source step is TE or HFD | Trivial: from Kernel typing |
| `tacit_source_stays_tacit` | T0-source → T0-target | Trivial: from Kernel morphism map |
| `ai_never_targets_tacit` | AI-executable → target ≠ T0 | Trivial: from `AI_preserves_explicit` |
| `ai_human_disjoint` | AI ∧ human predicates → false | Trivial: from is_AI_executable/is_human_only disjointness |
| `unique_boundary_entry` | E0→T0 iff RB | Trivial: from `RB_unique_boundary` |
| `IL_pairwise_intent_consistency` | IL skeleton application | Trivial: definition unfolding |
| `AR_no_unresolved_ambiguity` | AR skeleton application | Trivial: definition unfolding |
| `CSC_lock_is_monotone` | CSC skeleton application | Trivial: definition unfolding |

All eight are derivable from existing Kernel theorems with one or two tactic steps. They are included for completeness and as a test suite for the skeleton definitions.

---

## 6.4 Novel Structural Theorems

Three results from `Frfp/Minimal/BasisSweep.lean` are non-trivial and were not present in or implied by the published papers.

### 6.4.1 Canonical Earliest-Unresolved-Witness Theorem

**Theorem `first_unresolved_witness`:**

```lean
theorem first_unresolved_witness
    (t : ProtocolTrace) (h : ¬ AR_skeleton t) :
    ∃ i, i < t.steps.length ∧
         (t.steps.get ⟨i, by omega⟩).ambiguityTag ∧
         ∀ j, j < i →
           ¬(t.steps.get ⟨j, by omega⟩).ambiguityTag
```

**Statement in words**: If a trace violates the Ambiguity Resolution constraint, there exists a canonical earliest step index at which the first unresolved ambiguity appears, and all prior steps are ambiguity-free.

**Why this is novel**: The published papers state AR as a global condition (no ambiguity anywhere) but do not study the localizing structure of violations. This theorem provides a canonical diagnostic: given a failing trace, the earliest violation is well-defined and findable.

**Why this is non-trivial**: The result requires constructive well-foundedness — existence of a minimum index for a non-empty decidable predicate over a finite list. While the mathematical content is elementary, the formalization required careful handling of `List.get` bounds and `omega` arithmetic.

**Physical interpretation**: In an FRFP deployment, if an audit finds a governance failure, this theorem guarantees a canonical root-cause step exists — the first point at which the failure was introduced. This is operationally significant for root-cause analysis.

### 6.4.2 Governance-Safe Trace-Extension Theorem

**Theorem `governance_safe_extension_theorem`:**

```lean
theorem governance_safe_extension_theorem
    (t : ProtocolTrace) (s : StepRecord)
    (ht : GovernanceAdmissibleStrong t)
    (hs : StepCompatibleStrong s t) :
    GovernanceAdmissibleStrong { steps := t.steps ++ [s] }
```

**Statement in words**: If a trace is governance-admissible (satisfies IL, AR, and CSC globally) and a new step is compatible with that trace (preserves intent consistency, adds no ambiguity, and preserves correctness lock), then the extended trace is also governance-admissible.

**Why this is novel**: This is a positive result about trace extension — not just "what can go wrong" but "when can you safely add a step." It converts the three static invariants (IL, AR, CSC) into a dynamic rule for incremental trace construction.

**Why this is non-trivial**: The proof requires showing that the three global predicates `IL_global`, `AR_global`, `CSC_global` are preserved under list append with a compatible element. The key technical step is that the extended trace's pairwise conditions hold because the new element satisfies the per-step compatibility conditions relative to all previous elements.

**Theoretical significance**: This theorem can serve as a verification algorithm: if a governance layer checks `StepCompatibleStrong` before admitting each new step, it guarantees `GovernanceAdmissibleStrong` for the entire trace by induction. This is an online monitoring characterization.

### 6.4.3 Protocol Phase-Decomposition Theorem

**Theorem `protocol_normal_form_theorem`:**

```lean
theorem protocol_normal_form_theorem
    (t : ProtocolTrace)
    (ht : PrimitiveTraceAdmissibleStrong t) :
    ∃ (t_E t_B t_T : List StepRecord),
      t.steps = t_E ++ t_B ++ t_T ∧
      (∀ s ∈ t_E, phaseOf s = PrimitivePhase.explicit) ∧
      (∀ s ∈ t_B, phaseOf s = PrimitivePhase.boundary) ∧
      (∀ s ∈ t_T, phaseOf s = PrimitivePhase.tacit)
```

**Statement in words**: Every admissible FRFP trace can be decomposed into three consecutive phases: an explicit phase (AI-accessible steps), a boundary phase (reification), and a tacit phase (human-only steps). The decomposition is canonical by the phase classifier `phaseOf`.

**Why this is novel**: The published papers describe the three-phase structure informally as an intuition. The formal result establishes that the phase decomposition is not just possible but necessary and unique for every admissible trace.

**Why this is non-trivial**: The proof requires showing that the phase classifier `phaseOf` is total and exhaustive (`phase_partition` theorem), and that an admissible trace cannot have phase inversions (tacit steps before boundary, or boundary before explicit). These non-inversion properties follow from the Kernel's morphism typing constraints.

**Theoretical significance**: Phase decomposition connects FRFP governance traces to the classical theory of sequential systems with phases (entry/processing/exit). It provides a normal-form theorem for governance traces analogous to the normal-form theorem for reduction sequences.

---

## 6.5 Novelty Classification Summary

| Theorem | Class | Basis for classification |
|---|---|---|
| All 8 `BasisConsequences` theorems | Trivial extension | Direct unfolding of definitions or one-step Kernel applications |
| `first_unresolved_witness` | Novel | Constructive localization not present or implied in published papers |
| `governance_safe_extension_theorem` | Novel | Dynamic extension rule; not conjectured; requires non-trivial technical content |
| `protocol_normal_form_theorem` | Novel | Formal phase-decomposition; strengthens informal paper intuition to a theorem |
| 11 theory proposals (P-01 through P-11) | Clarifications/corrections | Not theorems themselves, but required changes to paper statements |

The three novel theorems have direct operational and theoretical significance beyond being formal restatements of existing claims.
