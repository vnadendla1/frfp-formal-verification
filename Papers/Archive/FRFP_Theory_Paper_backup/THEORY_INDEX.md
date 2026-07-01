# FRFP: A Formal Theory of Explicit–Tacit Computation
## The Lean-Corrected and Extended Account

**Status**: Manuscript complete — April 2026  
**Based on**: Lean 4.29.0 formal verification; 269 machine-checked theorems  
**Companion to**: FRFP Lean Formal Verification (verification companion paper)

---

## Abstract

The Foundational Reasoning and Feedback Protocol (FRFP) is a categorical framework distinguishing *explicit* (machine-manipulable) from *tacit* (human correctness-bearing) computation, together with a protocol governing the boundary between them. This paper presents the FRFP theory in the form established by complete machine-checked formalization in Lean 4.

The formalization yields four refinements to the published theory:

1. **Basis reduction**: the original 11 premises reduce to 7 independent axioms. Four (ETS, RB, AE, MD) are derivable theorems, not independent assumptions.
2. **Precision corrections**: six definitions required strengthening — notably, credence bounds must be explicit, degradation requires clamping, and normal-form uniqueness holds only modulo navigation equivalence.
3. **New formal structures**: three types implicit in the original paper are made explicit — the `runToω` bijection, the `CorrectnessJudgment` type, and the lifted-action commutativity lemma.
4. **Novel theorems**: three non-trivial results emerge directly from proof obligations — a canonical first-unresolved-witness theorem, a governance-safe trace-extension theorem, and a protocol normal-form decomposition theorem.

This presentation treats the Lean formalization as authoritative: where the published paper and Lean code diverge, the Lean version is stated explicitly and the divergence is documented.

---

## Chapter Map

| Chapter | Title | Key content |
|---|---|---|
| [01](THEORY_CH01_Kernel.md) | The Kernel Category | 3-object category, 6 primitives, typing theorems, pipelines |
| [02](THEORY_CH02_Basis.md) | The Reduced Axiom Basis | 7 irreducible premises, 4 derivable theorems, source anchoring |
| [03](THEORY_CH03_Reduction.md) | Reduction and Confluence | TDG grammar, reduction rules, termination, confluence, normal forms |
| [04](THEORY_CH04_Semantics.md) | Denotational and Operational Semantics | Grothendieck construction, runToω bijection, semantic correctness |
| [05](THEORY_CH05_Dynamic.md) | Dynamic and Probabilistic Layer | Credence, degradation, stopping times, 5 proven probability theorems |
| [06](THEORY_CH06_Collective.md) | Collective and Governance Layer | Epistemic algebra, institutional layer, governance invariants |
| [07](THEORY_CH07_NewResults.md) | Novel Results from Formalization | 3 new theorems, 8 direct consequences, open questions |

---

## Notation

| Symbol | Meaning |
|---|---|
| $\mathbf{C}_0$ | The kernel category with objects $\{\varnothing, E_0, T_0\}$ |
| $E_0$ | The explicit object |
| $T_0$ | The tacit object |
| $\mathbf{E}_{cat}$ | The explicit subcategory (morphisms targeting $E_0$) |
| $\mathbf{T}_{cat}$ | The tacit subcategory (morphisms targeting $T_0$) |
| $\Pi$ | A pipeline (morphism in $\mathbf{C}_0$) |
| $\mathcal{P}$ | A protocol trace (list of step records) |
| $\sigma$ | A configuration (object in the Grothendieck construction) |
| $\equiv_\nabla$ | Navigation equivalence relation |
| $\delta$ | Degradation operator on credence |
| $S(n)$ | Survival function at step $n$ |
| $h(n)$ | Hazard rate at step $n$ |
| $\omega$ | A stochastic trajectory |
| $\Omega$ | Sample space of stochastic trajectories |

---

## Lean Reference Conventions

Throughout the paper, Lean theorems and definitions are referenced using the pattern:

> **[Lean: `module.theorem_name`]** — for a machine-checked result  
> **[Lean: `axiom name`]** — for an explicitly postulated assumption

The full Lean source is at `Frfp/Core/` and `Frfp/Minimal/` in the verification repository. All theorems marked **[Lean: ...]** have zero `sorry` and are accepted by the Lean 4.29.0 kernel.

---

## Key Corrections at a Glance

Before the detailed presentation, the table below summarizes the most important corrections the formalization makes to the original published theory:

| Original claim | Lean-corrected version | Location |
|---|---|---|
| ETS is a primitive axiom | ETS is a theorem (from kernel typing) | Ch. 2 |
| RB uniqueness is a primitive axiom | RB uniqueness is a theorem (from kernel enumeration) | Ch. 2 |
| Normal forms are unique | Normal forms are unique modulo $\equiv_\nabla$ | Ch. 3 |
| Reduction operates on morphisms | Reduction operates on configurations (objects) | Ch. 4 |
| Credence is unbounded | Credence $\in [0,1]$ must be enforced by construction | Ch. 5 |
| Degradation: $c' = c - \delta t$ | Degradation: $c' = \max(0, \min(1, c - \delta t))$ | Ch. 5 |
| Run–trajectory correspondence is informal | `runToω` is a formal injective bijection | Ch. 4 |
