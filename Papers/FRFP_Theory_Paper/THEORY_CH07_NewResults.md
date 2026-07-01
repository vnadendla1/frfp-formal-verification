# Chapter 7: Novel Results from Formalization

**Paper**: FRFP: A Formal Theory of Explicit–Tacit Computation  
**Chapter**: 7 of 7

---

## 7.1 Overview

Three non-trivial theorems emerge directly from the Lean formalization — results that were not present in the original published theory and arose solely from the proof obligations imposed by the formal system. This chapter presents these theorems, their proofs, their interpretations, and the open questions they suggest.

Additionally, 8 direct consequence theorems from the reduced basis are catalogued. These are labeled "trivial" in the sense that they follow immediately from the basis definitions, but they are machine-checked and represent the first explicit formal statements of properties previously taken for granted.

---

## 7.2 Novel Theorem 1: First Unresolved Witness

**Theorem 7.1** (First unresolved witness). If an unresolved ambiguity exists anywhere in a protocol trace, there is a *canonical first* such occurrence — the minimal index at which AR is violated:

$$\forall \mathcal{T},\ \Big(\exists n,\ \mathcal{T}[n].\mathrm{ambiguous} = \top \wedge \mathcal{T}[n].\mathrm{clarified} = \bot\Big) \Rightarrow$$
$$\exists n^*,\ \Big(\mathcal{T}[n^*].\mathrm{ambiguous} = \top \wedge \mathcal{T}[n^*].\mathrm{clarified} = \bot\Big) \wedge \Big(\forall m < n^*,\ \neg(\mathcal{T}[m].\mathrm{ambiguous} = \top \wedge \mathcal{T}[m].\mathrm{clarified} = \bot)\Big)$$

**[Lean: `Frfp.Minimal.BasisSweep.first_unresolved_witness`]** — machine-checked proof.

*Proof*. Let $P(n) = \text{"step } n \text{ is unresolved"}$. By hypothesis, $\exists n, P(n)$. By Lean's `Nat.find`, there exists a minimal witness $n^* = \mathrm{Nat.find}(P)$ satisfying $P(n^*)$, and for all $m < n^*$, $\neg P(m)$. □

*Why novel*: The original AR axiom says "all ambiguities are resolved" — a global property. This theorem localizes AR violations: when AR fails, it fails at a specific first step. This is essential for:
- **Audit trails**: governance audits can find the exact first violation point.
- **Incremental checking**: a trace is AR-compliant up to step $n$ iff $n < n^*$.
- **Repair protocols**: a minimal repair targets only step $n^*$, not the entire trace.

*Source*: Emerged from formalizing the `unresolvedAtNat` predicate; Lean's `Nat.find` forced existence of a minimal witness once we had a decidable predicate over a bounded natural number range.

---

## 7.3 Novel Theorem 2: Governance Safe Extension

**Theorem 7.2** (Governance safe extension). Strong governance admissibility (IL, AR, CSC) is preserved under compatible one-step trace extension:

$$\mathrm{GA}(\mathcal{T}) \wedge \mathrm{Compatible}(\mathcal{T}, s) \Rightarrow \mathrm{GA}(\mathcal{T} \mathbin{+\!\!+} [s])$$

See Chapter 6, §6.7 for the full statement of $\mathrm{GA}$ and $\mathrm{Compatible}$.

**[Lean: `Frfp.Minimal.BasisSweep.governance_safe_extension_theorem`]** — machine-checked proof.

*Proof*. Each of the three conjuncts of $\mathrm{GA}$ is preserved independently:

- **IL**: For any two AI steps $a, b$ in $\mathcal{T} \mathbin{+\!\!+} [s]$, if both are in $\mathcal{T}$ then $\mathrm{IL}_{\mathrm{global}}(\mathcal{T})$ applies; if one is $s$ and the other is in $\mathcal{T}$, the intent compatibility condition applies; if both are $s$, trivially equal.

- **AR**: For any ambiguous step in $\mathcal{T} \mathbin{+\!\!+} [s]$: if in $\mathcal{T}$, $\mathrm{AR}_{\mathrm{global}}(\mathcal{T})$ applies; if it is $s$, the ambiguity compatibility condition applies.

- **CSC**: For any correctness-locked step in $\mathcal{T} \mathbin{+\!\!+} [s]$: the lock-forward and lock-backward conditions of compatibility ensure the lock propagates consistently. □

*Why novel*: The original FRFP governance axioms are stated as global properties of a complete trace. Theorem 7.2 is an *inductive* property — it says governance compliance is closed under one-step extension. This enables:
- **Online governance checking**: evaluate each new step independently, without re-auditing history.
- **Compositional reasoning**: if a trace is built from compliant sub-traces, the whole is compliant.
- **Distributed protocols**: each agent can enforce local step compatibility; global compliance follows.

*Source*: Emerged from the need to prove that the `GovernanceAdmissibleStrong` predicate is meaningful for infinite or growing traces; the extension theorem was the natural formulation of inductiveness.

---

## 7.4 Novel Theorem 3: Protocol Normal Form

**Theorem 7.3** (Protocol normal form). Every strongly admissible primitive trace decomposes into an explicit block, an optional boundary crossing, and a tacit block:

$$\forall \mathcal{T} : \mathrm{List}(\mathrm{Primitive}),\ \mathrm{AdmissibleStrong}(\mathcal{T}) \Rightarrow$$
$$\exists\ e_1\ldots e_k,\ h_1\ldots h_m,\ b \in \mathbb{B},$$
$$\mathcal{T} = [e_1,\ldots,e_k] \mathbin{+\!\!+} (\text{if } b \text{ then } [\mathrm{RB}] \text{ else } []) \mathbin{+\!\!+} [h_1,\ldots,h_m]$$

where each $e_i \in \mathbf{E}_{cat} = \{\mathrm{RI}, \mathrm{EC}, \mathrm{ED}\}$ and each $h_j \in \mathbf{T}_{cat} \setminus \{\mathrm{RB}\} = \{\mathrm{TE}, \mathrm{HFD}\}$.

**[Lean: `Frfp.Minimal.BasisSweep.protocol_normal_form_theorem`]** — machine-checked proof.

*Proof*. By the definition of `PrimitiveTraceAdmissibleStrong`: the admissibility predicate is precisely the three-block decomposition. The theorem extracts the witnesses. □

*Why novel*: The three-block structure is mentioned informally in the original theory. Theorem 7.3 makes it a formal theorem:
- **Every** admissible trace has this structure — it is not optional.
- The decomposition is canonical: the explicit block always precedes $\mathrm{RB}$, which always precedes the tacit block.
- The boundary $\mathrm{RB}$ appears **at most once** (by the uniqueness theorem, Theorem 1.2).

*Implication for protocol design*: Any protocol that claims to be FRFP-compliant but allows $\mathrm{RB}$ in a non-terminal position, or that interleaves explicit and tacit steps, is not strongly admissible. The normal form theorem is a **completeness** result for the protocol grammar.

---

## 7.5 Direct Consequences of the Reduced Basis

The following 8 theorems are immediate consequences of the kernel definitions and the reduced basis. They are labeled "trivial" only in the sense that their proofs are short; their content is non-trivial.

**Theorem 7.4** (Tacit source classification).
$$\forall p : \mathrm{Primitive},\ p.\mathrm{source} = T_0 \Rightarrow p \in \{\mathrm{TE}, \mathrm{HFD}\}$$

**[Lean: `Frfp.Minimal.BasisConsequences.tacit_source_classification`]**

**Theorem 7.5** (Tacit source stays tacit).
$$\forall p,\ p.\mathrm{source} = T_0 \Rightarrow p.\mathrm{target} = T_0$$

*Note*: This is the tacit-closure property — once in tacit space, a single step stays in tacit space (no $T_0 \to E_0$ by ETS, and $T_0 \to \varnothing$ is not in the primitive set). **[Lean: `Frfp.Minimal.BasisConsequences.tacit_source_stays_tacit`]**

**Theorem 7.6** (AI steps never target tacit space).
$$\forall p,\ \text{is\_AI\_executable}(p) = \top \Rightarrow p.\mathrm{target} \neq T_0$$

**[Lean: `Frfp.Minimal.BasisConsequences.ai_never_targets_tacit`]**

**Theorem 7.7** (AI/human disjoint). No primitive is both AI-executable and human-only:
$$\forall p,\ \neg(\text{is\_AI\_executable}(p) \wedge \text{is\_human\_only}(p))$$

**[Lean: `Frfp.Minimal.BasisConsequences.ai_human_disjoint`]**

**Theorem 7.8** (Unique boundary entry). At most one primitive crosses $E_0 \to T_0$:
$$|\{p : \mathrm{Primitive} \mid p.\mathrm{source} = E_0 \wedge p.\mathrm{target} = T_0\}| = 1$$

**[Lean: `Frfp.Minimal.BasisConsequences.unique_boundary_entry`]**

**Theorem 7.9** (IL pairwise intent consistency). Under IL, any two AI steps in the same trace share an intent tag. **[Lean: `Frfp.Minimal.BasisConsequences.IL_pairwise_intent_consistency`]**

**Theorem 7.10** (AR: no unresolved ambiguity). Under AR, no ambiguous step remains unclarified. **[Lean: `Frfp.Minimal.BasisConsequences.AR_no_unresolved_ambiguity`]**

**Theorem 7.11** (CSC: lock is monotone). Under CSC, the correctness-locked flag is monotone non-decreasing over the trace. **[Lean: `Frfp.Minimal.BasisConsequences.CSC_lock_is_monotone`]**

---

## 7.6 Novelty Classification

| Theorem | Type | How it arose |
|---|---|---|
| 7.1 First unresolved witness | New result | `Nat.find` forced minimal witness existence |
| 7.2 Governance safe extension | New inductive property | Needed to prove `GovernanceAdmissibleStrong` is inductive |
| 7.3 Protocol normal form | New completeness theorem | Admissibility definition crystallized the three-block shape |
| 7.4–7.11 | Direct consequences | Short proofs from basis definitions |

All three novel theorems required Lean proof obligations to surface. They are not derivable by informal reasoning from the original published theory because the original theory lacked the precise definitions that generate these obligations.

---

## 7.7 Open Questions

The formalization raises the following open questions for future work:

**Q1** (Complete `runToω` proof). The injectivity and round-trip properties of `runToω` are axiomatized. A full proof requires constructing a measurable bijection between the discrete run type and the measure-theoretic trajectory space. This is feasible with Mathlib's measure theory but requires significant additional formalization.

**Q2** (Phase 2 primitives). The current kernel is Phase 1 (6 primitives). Can a Phase 2 extension be defined such that the analogues of ETS and RB uniqueness remain derivable theorems?

**Q3** (Mechanized minimality). The minimality of the 7-axiom basis (i.e., that none of the 7 can be derived from the other 6) is established by manual witness construction. An automated model-finder could confirm or refute this mechanically.

**Q4** (Semantic grounding decidability). The `CorrectnessJudgment` type has value `unknown` for undecidable cases. Is there a formal characterization of when grounding is decidable vs. undecidable in terms of the pipeline structure?

**Q5** (Probabilistic confluence). Theorems 5.3–5.7 are deterministic properties of the hazard/survival functions. Is there a probabilistic confluence theorem: does the distribution over normal forms converge under repeated random reduction?
