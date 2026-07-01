# Chapter 6: Collective and Governance Layer

**Paper**: FRFP: A Formal Theory of Explicit–Tacit Computation  
**Chapter**: 6 of 7

---

## 6.1 Overview

This chapter extends FRFP from single-pipeline interactions to multi-agent settings. Three layers build on the kernel:

1. **Epistemic algebra** — knowledge operators and belief revision for individual agents.
2. **Institutional layer** — population structures, credence distributions, and multi-agent impossibility results.
3. **Governance layer** — derived governance predicates and the safe extension theorem.

---

## 6.2 Epistemic Algebra

**Definition 6.1** (Epistemic state). An epistemic state for an agent is a record encoding the agent's current knowledge about the pipeline's tacit validity. It includes:
- A credence value $c \in [0,1]$ (see Chapter 5).
- A belief set over possible pipeline configurations.
- An update history (finite sequence of knowledge operations).

**[Lean: `Frfp.Core.EpistemicAlgebra.EpistemicState`]**

**Definition 6.2** (Knowledge operator). A knowledge operator $K$ maps an epistemic state to a proposition:
$$K : \mathrm{EpistemicState} \to \mathrm{Prop}$$

Knowledge operators satisfy standard modal epistemic axioms (T, 4, 5 as appropriate for the application). **[Lean: `Frfp.Core.EpistemicAlgebra.KnowledgeOp`]**

**Definition 6.3** (Belief revision). A belief revision operation updates an epistemic state given new evidence:
$$\mathrm{BeliefRevision} : \mathrm{EpistemicState} \times \mathrm{Evidence} \to \mathrm{EpistemicState}$$

**Axiom** (Belief revision idempotence). Revising with the same evidence twice is the same as revising once:
$$\mathrm{BeliefRevision}(\mathrm{BeliefRevision}(s, e), e) = \mathrm{BeliefRevision}(s, e)$$

**[Lean: `Frfp.Core.EpistemicAlgebra.belief_revision_idempotent`]**

---

## 6.3 Institutional Layer

**Definition 6.4** (Population). A population is a finite set of agents $\mathcal{A} = \{a_1, \ldots, a_n\}$ each carrying an epistemic state. The population is modeled as a structure with:
- Agent set and associated epistemic states.
- A population credence (aggregate of individual credences).
- A degradation profile (per-agent degradation rates).

**[Lean: `Frfp.Core.InstitutionalLayer`]**

**Definition 6.5** (Population credence). The population credence $\bar{c}$ is the weighted average of individual credences:
$$\bar{c} = \frac{1}{|\mathcal{A}|}\sum_{a \in \mathcal{A}} c(a)$$

**Theorem 6.1** (Population collapse bound). Under continuous degradation without human evaluation, population credence reaches zero in finite time:
$$\exists N,\ \bar{c}'(N) = 0$$

**[Lean: `Frfp.Core.CollectiveLayer.population_collapse_bound`]**

---

## 6.4 Consensus Impossibility

**Theorem 6.2** (No grounding by consensus). A consensus operation over AI agents cannot produce tacit grounding. Formally, no combination of AI-only operations yields a correctness judgment:
$$\mathrm{ConsensusAI}(\mathcal{A}) \not\Rightarrow \mathrm{CorrectnessJudgment.correct}$$

**[Lean: `Frfp.Core.CollectiveLayer.consensus_no_grounding`]**

This theorem formalizes a key FRFP claim: voting, averaging, or ensemble aggregation among AI systems cannot substitute for human tacit judgment. Even if all agents agree, their consensus lives in explicit space; tacit grounding requires $\mathrm{HFD}$.

*Interpretation*: The theorem says explicit-space consensus (no matter how sophisticated) does not produce a `correct` CorrectnessJudgment. The latter requires a $\mathrm{HFD}$ primitive, which is human-exclusive. The proof follows from the ETS theorem: no AI operation produces a morphism targeting $T_0$, so no AI consensus reaches the tacit space where correctness lives.

---

## 6.5 Governance Framework

**Definition 6.6** (Governance predicate). A governance predicate $G$ is a predicate on protocol traces that captures a governance invariant. Three primary governance predicates:

**Definition 6.7** (Strong IL — global intent consistency).
$$\mathrm{IL}_{\mathrm{global}}(\mathcal{T}) \iff \forall a, b \in \mathcal{T},\ a.\mathrm{isAI} = \top \wedge b.\mathrm{isAI} = \top \Rightarrow a.\mathrm{intentTag} = b.\mathrm{intentTag}$$

**[Lean: `Frfp.Minimal.BasisSweep.IL_global`]**

**Definition 6.8** (Strong AR — full ambiguity resolution).
$$\mathrm{AR}_{\mathrm{global}}(\mathcal{T}) \iff \forall a \in \mathcal{T},\ a.\mathrm{ambiguous} = \top \Rightarrow a.\mathrm{clarified} = \top$$

**[Lean: `Frfp.Minimal.BasisSweep.AR_global`]**

**Definition 6.9** (Strong CSC — correctness lock propagation).
$$\mathrm{CSC}_{\mathrm{global}}(\mathcal{T}) \iff \Big(\exists a \in \mathcal{T},\ a.\mathrm{locked} = \top\Big) \Rightarrow \forall b \in \mathcal{T},\ b.\mathrm{locked} = \top$$

**[Lean: `Frfp.Minimal.BasisSweep.CSC_global`]**

**Definition 6.10** (Strong governance admissibility).
$$\mathrm{GA}(\mathcal{T}) \iff \mathrm{IL}_{\mathrm{global}}(\mathcal{T}) \wedge \mathrm{AR}_{\mathrm{global}}(\mathcal{T}) \wedge \mathrm{CSC}_{\mathrm{global}}(\mathcal{T})$$

**[Lean: `Frfp.Minimal.BasisSweep.GovernanceAdmissibleStrong`]**

---

## 6.6 Step Compatibility

**Definition 6.11** (Step compatibility). A new step $s$ is compatible with a strongly admissible trace $\mathcal{T}$ if:

1. **Intent compatibility**: $\forall a \in \mathcal{T},\ a.\mathrm{isAI} = \top \wedge s.\mathrm{isAI} = \top \Rightarrow a.\mathrm{intentTag} = s.\mathrm{intentTag}$
2. **Ambiguity compatibility**: $s.\mathrm{ambiguous} = \top \Rightarrow s.\mathrm{clarified} = \top$
3. **Lock forward**: $(\exists a \in \mathcal{T},\ a.\mathrm{locked} = \top) \Rightarrow s.\mathrm{locked} = \top$
4. **Lock backward**: $s.\mathrm{locked} = \top \Rightarrow \forall a \in \mathcal{T},\ a.\mathrm{locked} = \top$

**[Lean: `Frfp.Minimal.BasisSweep.StepCompatibleStrong`]**

---

## 6.7 Governance Safe Extension Theorem

**Theorem 6.3** (Governance safe extension). Strong governance admissibility is preserved under compatible one-step extension:

$$\mathrm{GA}(\mathcal{T}) \wedge \mathrm{Compatible}(\mathcal{T}, s) \Rightarrow \mathrm{GA}(\mathcal{T} \mathbin{+\!\!+} [s])$$

**[Lean: `Frfp.Minimal.BasisSweep.governance_safe_extension_theorem`]** — machine-checked proof.

*Proof*. By case analysis on the membership of an arbitrary element of $\mathcal{T} \mathbin{+\!\!+} [s]$: it is either in $\mathcal{T}$ (where $\mathrm{GA}(\mathcal{T})$ applies) or equals $s$ (where the compatibility conditions apply). □

This theorem is the key safety result for FRFP governance: it establishes that the governance invariants are inductive — any compliant trace can be safely extended by a compliant step. This means governance compliance can be checked incrementally without re-auditing the entire trace history.

---

## 6.8 Entropy Drift in Collective Settings

In multi-agent settings, the entropy drift theorem extends:

**Theorem 6.4** (Collective entropy drift). Under AI-only rounds (no $\mathrm{TE}$ or $\mathrm{HFD}$ steps from any agent), the population-level entropy is non-decreasing:
$$H_{\mathrm{pop}}(t_2) \geq H_{\mathrm{pop}}(t_1) \quad \text{for } t_1 \leq t_2 \text{ with no human steps}$$

**[Lean: `Frfp.Core.CollectiveLayer`]**

---

## 6.9 Policy Residue in the Collective Layer

The governance layer has significant policy residue — properties that are governance commitments rather than mathematical theorems:

| Property | Mathematical skeleton | Policy residue |
|---|---|---|
| IL | Intent tag invariant over traces | Intent is a shared governance resource |
| AR | Every ambiguity flag implies clarification flag | Ambiguity is not acceptable in production |
| CSC | Correctness lock is trace-monotone | Once locked, correctness is never revisited |
| HEG/HEC | Tacit primitives target $T_0$ | Only humans may ground these |
| Consensus impossibility | No AI primitive targets $T_0$ | AI consensus cannot substitute for human judgment |

The policy residue is where FRFP's governance philosophy lives. Lean verifies the mathematical skeletons; the residue is the normative commitment that users of the framework adopt.
