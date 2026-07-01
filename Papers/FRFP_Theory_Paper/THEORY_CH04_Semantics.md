# Chapter 4: Denotational and Operational Semantics

**Paper**: FRFP: A Formal Theory of Explicit–Tacit Computation  
**Chapter**: 4 of 7

---

## 4.1 Overview

This chapter defines the semantic interpretation of FRFP terms. Two complementary views are presented:

- **Denotational semantics**: TDG terms denote morphisms in a Grothendieck construction over indexed categories.
- **Operational semantics**: pipeline execution is modeled as a relation on runs, connected to a stochastic trajectory space via the `runToω` bijection.

Both views contain significant structures made explicit by the Lean formalization that were implicit or absent in the original published theory.

---

## 4.2 The Grothendieck Construction

FRFP uses a Grothendieck construction to model configurations — the full state of a pipeline execution including both categorical structure and index data.

**Definition 4.1** (Indexed category). Define a contravariant functor:
$$\mathbf{E}_{\mathrm{idx}} : \mathbb{N}^{\mathrm{op}} \to \mathbf{Cat}$$
mapping natural number indices $n$ to categories $\mathbf{E}_{\mathrm{idx}}(n)$ and index morphisms (decrements) to functors between them.

**Definition 4.2** (Grothendieck object / configuration). A configuration $\sigma$ is an object in the Grothendieck construction $\int \mathbf{E}_{\mathrm{idx}}$:
$$\sigma = (n,\ X_n) \quad \text{where } n \in \mathbb{N},\ X_n \in \mathrm{Ob}(\mathbf{E}_{\mathrm{idx}}(n))$$

**Definition 4.3** (Grothendieck morphism). A morphism between configurations $(n, X_n) \to (m, X_m)$ consists of an index morphism $n \to m$ and a morphism in the base category compatible with the reindexing functor.

**[Lean: `Frfp.Core.Grothendieck.GrothendieckObject`, `Frfp.Core.Grothendieck.GrothendieckMorphism`]**

---

## 4.3 Lean Correction: Reduction Acts on Objects

> **Lean correction (P-01)**: The original published theory is ambiguous about whether reduction steps operate on configurations, morphisms, or syntactic terms. The Lean formalization resolves this: **reduction is a relation on configurations** (Grothendieck objects), not on morphisms.

**Definition 4.4** (Reduction step). A reduction step is a relation $\to_r \subseteq \mathrm{GrothendieckObject} \times \mathrm{GrothendieckObject}$.

A morphism is *induced* by a reduction step, but the reduction step itself is not a morphism:

**Theorem 4.1** (Reduction induces morphism). If $\sigma_1 \to_r \sigma_2$, then there exists a Grothendieck morphism $m$ with $m.\mathrm{source} = \sigma_1$ and $m.\mathrm{target} = \sigma_2$:
$$\sigma_1 \to_r \sigma_2 \Rightarrow \exists m : \mathrm{GrothendieckMorphism},\ m.\mathrm{src} = \sigma_1 \wedge m.\mathrm{tgt} = \sigma_2$$

**[Lean: `Frfp.Core.Grothendieck.reduction_induces_morphism`]**

This distinction matters when reasoning about the categorical properties of reductions: reductions are arrows in an abstract reduction system (ARS), not arrows in $\mathbf{C}_0$.

---

## 4.4 Semantic Functions

Three semantic functions map syntactic objects to semantic ones:

**Definition 4.5** (Semantic evaluation). The function $\mathrm{Sem}$ maps a configuration to an object in the kernel category:
$$\mathrm{Sem} : \mathrm{GrothendieckObject} \to \mathrm{Object}$$

**Definition 4.6** (Correctness evaluation). The function $\gamma$ maps a kernel object to a correctness judgment:
$$\gamma : \mathrm{Object} \to \mathrm{CorrectnessJudgment}$$

**Definition 4.7** (Observable correctness). The observable correctness function $\mathrm{obs}$ over runs:
$$\mathrm{obs} = \gamma \circ \mathrm{Sem} \circ \mathrm{initial} : \mathrm{Runs}(P) \to \mathrm{CorrectnessJudgment}$$

where $\mathrm{initial}(\rho)$ extracts the initial configuration of run $\rho$.

**[Lean: `Frfp.Core.TacitDependence.Sem`, `.gamma`, `.obs`]** — these are axiomatized, as their definitions depend on external semantic domains.

> *Note*: $\mathrm{Sem}$, $\gamma$, $\mathrm{obs}$, and $\mathrm{CorrectnessJudgment}$ are all new explicit types introduced by the Lean formalization. They were implicit in the original paper's treatment of tacit-dependent correctness.

---

## 4.5 Runs and Trajectories

**Definition 4.8** (Run). A run $\rho$ of program $P$ is a maximal execution trace. The type of runs of $P$ is written $\mathrm{Runs}(P)$.

**Definition 4.9** (Allowed stochastic trajectory). The sample space $\Omega$ is the full space of stochastic trajectories. The *allowed* subspace $\Omega_{\mathrm{allowed}} \subseteq \Omega$ contains exactly those trajectories consistent with a valid run of $P$.

---

## 4.6 The runToω Bijection

> **Lean correction (P-02)**: Remark A.104 in the original paper asserts a correspondence between runs and allowed stochastic trajectories, but does not define it explicitly. The Lean formalization requires a concrete injective map with a round-trip property.

**Definition 4.10** (runToω). The run-to-trajectory correspondence:
$$\mathrm{runTo}\omega : \{\rho \mid \mathrm{Runs}(P)\ \rho\} \to \Omega_{\mathrm{allowed}}$$

with companion inverse:
$$\omega\mathrm{ToRun} : \Omega_{\mathrm{allowed}} \to \{\rho \mid \mathrm{Runs}(P)\ \rho\}$$

**[Lean: `Frfp.Core.OperationalSemantics.runToω`, `.ωToRun`]**

**Axiom** (runToω injectivity):
$$\mathrm{runTo}\omega(\rho_1) = \mathrm{runTo}\omega(\rho_2) \Rightarrow \rho_1 = \rho_2$$

**[Lean: `Frfp.Core.OperationalSemantics.runToω_injective`]**

**Axiom** (runToω round-trip):
$$\omega\mathrm{ToRun}(\mathrm{runTo}\omega(\rho)) = \rho$$

**[Lean: `Frfp.Core.OperationalSemantics.runToω_roundtrip`]**

> *Limitation*: Injectivity and the round-trip property are axiomatized. A complete proof would require formalizing the probability space construction. This is an open proof obligation.

**Interpretation**: `runToω` is the formal bridge between the operational semantics (discrete execution traces) and the probabilistic semantics (measure on trajectory space). Without this bridge, probabilistic properties of FRFP cannot be stated as theorems about runs.

---

## 4.7 Denotational Semantics of Pipelines

**Definition 4.11** (Pipeline denotation). The denotational semantics $\llbracket \cdot \rrbracket$ maps a TDG term to its morphism in $\mathbf{C}_0$:
$$\llbracket \varepsilon \rrbracket = \mathrm{id},\qquad \llbracket p \cdot t \rrbracket = \llbracket p \rrbracket \circ \llbracket t \rrbracket$$

where $\llbracket p \rrbracket = p.\mathrm{toMorphism}$ for each primitive $p$.

**Theorem 4.2** (Denotational–operational agreement). For any TDG term $t$ and its reduct $t'$, the denotations are equal:
$$t \to_c t' \Rightarrow \llbracket t \rrbracket = \llbracket t' \rrbracket$$

*Proof*. Each reduction rule is a semantic identity (equating compositions of primitives that have equal denotations). □

**[Lean: `Frfp.Core.Semantics`]**

---

## 4.8 Navigation Layer

**Definition 4.12** (Navigation morphism). A navigation morphism is an admissible path annotation on a TDG term, recording which reachable states were visited during reduction. Navigation morphisms form a groupoid.

**Definition 4.13** (Navigation equivalence). Two terms $t_1 \equiv_\nabla t_2$ if they are equal modulo navigation morphism annotations.

**Theorem 4.3** (Navigation equivalence is an equivalence relation).
- Reflexivity: $t \equiv_\nabla t$.
- Symmetry: $t_1 \equiv_\nabla t_2 \Rightarrow t_2 \equiv_\nabla t_1$.
- Transitivity: $t_1 \equiv_\nabla t_2 \wedge t_2 \equiv_\nabla t_3 \Rightarrow t_1 \equiv_\nabla t_3$.

**[Lean: `Frfp.Core.SemanticCorrectness.nav_equivalence_is_equivalence`]**

---

## 4.9 Immutability of Pipelines

**Theorem 4.4** (Pipeline immutability). Executing a pipeline does not modify its structure. A pipeline's source, target, and primitive are invariant under execution:
$$\mathrm{execute}(\Pi).\mathrm{structure} = \Pi.\mathrm{structure}$$

**[Lean: `Frfp.Core.ImmutabilityProof`]**

This theorem captures a key FRFP invariant: pipelines are static specifications. Execution produces outputs but does not rewrite the pipeline specification itself. This rules out self-modifying pipeline behavior.
