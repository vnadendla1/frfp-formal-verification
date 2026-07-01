# Chapter 2: The Reduced Axiom Basis

**Paper**: FRFP: A Formal Theory of Explicit–Tacit Computation  
**Chapter**: 2 of 7

---

## 2.1 From 11 Premises to 7

The original published FRFP theory enumerates 11 named premises: ETS, RB, AE, MD, HEG, HEC, CP, IL, AR, NTER, CSC. The Lean formalization establishes that four of these (ETS, RB, AE, MD) are theorems derivable directly from the kernel definitions. The minimal independent basis therefore has exactly **7 primitive assumptions**.

| Premise | Original status | Lean status | Location |
|---|---|---|---|
| ETS | Axiom | **Theorem** (kernel typing) | Thm 2.1 |
| RB | Axiom | **Theorem** (kernel enumeration) | Thm 2.2 |
| AE | Axiom | **Theorem** (AI-executable typing) | Thm 2.3 |
| MD | Axiom | **Theorem** (AI/human partition) | Thm 2.4 |
| HEG | Axiom | **Axiom** (retained) | §2.3 |
| HEC | Axiom | **Axiom** (retained) | §2.3 |
| CP | Axiom | **Axiom** (retained) | §2.3 |
| IL | Axiom | **Axiom** (retained) | §2.4 |
| AR | Axiom | **Axiom** (retained) | §2.4 |
| NTER | Axiom | **Axiom** (retained) | §2.4 |
| CSC | Axiom | **Axiom** (retained) | §2.4 |

---

## 2.2 Derivable Theorems (No Longer Axioms)

### ETS — Explicit–Tacit Separation

**Theorem 2.1** (ETS is a theorem). There is no primitive from $T_0$ to $E_0$:
$$\forall p : \mathrm{Primitive},\ \neg(p.\mathrm{source} = T_0 \wedge p.\mathrm{target} = E_0)$$

**[Lean: `Frfp.Minimal.ReducedBasis.ETS_derivable`]** — proved by delegating to `no_morphism_T0_to_E0`.

*Why not an axiom*: ETS holds because the primitive enumeration simply contains no $T_0 \to E_0$ morphism. It is a fact about the closed enumeration, not an independent assumption.

---

### RB — Boundary Uniqueness

**Theorem 2.2** (RB uniqueness is a theorem). $\mathrm{RB}$ is the unique primitive from $E_0$ to $T_0$:
$$\forall p : \mathrm{Primitive},\ (p.\mathrm{source} = E_0 \wedge p.\mathrm{target} = T_0) \Rightarrow p = \mathrm{RB}$$

**[Lean: `Frfp.Minimal.ReducedBasis.RB_derivable`]** — proved by delegation to `RB_unique_boundary`.

*Why not an axiom*: This holds by exhaustive case analysis on the six primitives.

---

### AE — AI-Explicit Restriction

**Theorem 2.3** (AE is a theorem). Every AI-executable primitive stays within explicit space:
$$\forall p,\ \text{is\_AI\_executable}(p) \Rightarrow (p.\mathrm{source} \in \{\varnothing, E_0\}) \wedge p.\mathrm{target} = E_0$$

**[Lean: `Frfp.Minimal.ReducedBasis.AE_derivable`]** — proved by delegation to `AI_preserves_explicit`.

---

### MD — Mode Discipline

**Theorem 2.4** (MD is a theorem). AI-executable primitives always target $E_0$; human-only primitives always target $T_0$:
$$(\forall p,\ \text{is\_AI\_executable}(p) \Rightarrow p.\mathrm{target} = E_0) \wedge (\forall p,\ \text{is\_human\_only}(p) \Rightarrow p.\mathrm{target} = T_0)$$

**[Lean: `Frfp.Minimal.ReducedBasis.MD_derivable`]**

*Why not an axiom*: MD follows from the definition of `is_AI_executable` and `is_human_only` combined with kernel typing.

---

## 2.3 Core Irreducible Premises

The three core premises below are retained as genuine axioms. They capture domain commitments that cannot be derived from the kernel structure alone.

### HEG — Human-Exclusive Grounding

**Axiom HEG** (Human-Exclusive Grounding). Tacit evaluation and human final decision — the primitives $\mathrm{TE}$ and $\mathrm{HFD}$ — are exclusively executable by humans. No AI system can perform tacit grounding.

*Formal skeleton*: The structural part is derivable:
$$\mathrm{HEG}_{\mathrm{skel}}: \mathrm{TE}.\mathrm{target} = T_0 \wedge \mathrm{HFD}.\mathrm{target} = T_0$$

**[Lean: `Frfp.Minimal.ReducedBasis.HEG_skeleton_derivable`]**

*Policy residue*: The normative claim — that only humans may execute $\mathrm{TE}$ and $\mathrm{HFD}$ — is a governance premise. Lean formalizes the structural half but not the authority assignment.

---

### HEC — Human-Exclusive Closure

**Axiom HEC** (Human-Exclusive Closure). The final-decision primitive $\mathrm{HFD}$ is an endomorphism of tacit space that only humans may apply. No AI system may simulate or substitute for this closure.

*Formal skeleton*:
$$\mathrm{HEC}_{\mathrm{skel}}: \mathrm{HFD}.\mathrm{source} = T_0 \wedge \mathrm{HFD}.\mathrm{target} = T_0$$

**[Lean: `Frfp.Minimal.ReducedBasis.HEC_skeleton_derivable`]**

---

### CP — Compositional Pipelines

**Axiom CP** (Compositional Pipelines). Pipelines compose in a way that preserves the source and target boundary:
$$(\Pi_2 \circ \Pi_1).\mathrm{source} = \Pi_1.\mathrm{source},\quad (\Pi_2 \circ \Pi_1).\mathrm{target} = \Pi_2.\mathrm{target}$$

*Formal skeleton*: This is proved from the kernel composition definition.

**[Lean: `Frfp.Minimal.ReducedBasis.CP_skeleton_derivable`]**

*Policy residue*: CP also carries a normative claim that pipelines are the only valid composition mechanism — AI cannot bypass pipeline sequencing by direct state manipulation.

---

## 2.4 Interaction Irreducible Premises

Four premises govern the interaction protocol between AI and human over traces.

### IL — Intent Locking

**Axiom IL** (Intent Locking). All AI steps in a protocol trace share a common intent tag. An AI step cannot unilaterally change the declared intent of the interaction:
$$\forall a, b \in \mathcal{P},\ a.\mathrm{isAI} = \top \wedge b.\mathrm{isAI} = \top \Rightarrow a.\mathrm{intentTag} = b.\mathrm{intentTag}$$

*Source anchor*: Temporal safety / invariant-over-traces semantics. **[Pnueli 1977]**

---

### AR — Ambiguity Resolution

**Axiom AR** (Ambiguity Resolution). Every ambiguous step in a protocol trace must be clarified before the interaction proceeds:
$$\forall a \in \mathcal{P},\ a.\mathrm{ambiguous} = \top \Rightarrow a.\mathrm{clarified} = \top$$

*Source anchor*: Liveness over traces; safety/liveness decomposition. **[Alpern–Schneider 1985]**

---

### NTER — No Tacit Emulation/Reconstruction

**Axiom NTER** (No Tacit Emulation or Reconstruction). No AI step attempts to construct a morphism from $T_0$ to $E_0$, i.e., no AI step attempts to emulate or substitute for tacit human judgment.

*Formal skeleton*:
$$\forall p,\ p.\mathrm{source} = T_0 \Rightarrow p.\mathrm{target} \neq E_0$$

**[Lean: `Frfp.Minimal.ReducedBasis.NTER_skeleton_derivable`]**

This is structurally identical to ETS. The distinction is normative: NTER is the *protocol* prohibition on AI attempting tacit emulation; ETS is the *mathematical* fact that the kernel category contains no such morphism.

---

### CSC — Correctness Stability Constraint

**Axiom CSC** (Correctness Stability Constraint). Once a step in a protocol trace is correctness-locked, all subsequent steps are correctness-locked. Correctness locking is monotone:
$$(\exists a \in \mathcal{P},\ a.\mathrm{correctnessLocked} = \top) \Rightarrow \forall b \in \mathcal{P},\ b.\mathrm{correctnessLocked} = \top$$

*Source anchor*: Temporal safety (invariant preservation). **[Pnueli 1977]**

---

## 2.5 Source Anchoring of External Assumptions

Modules beyond the kernel require additional axioms from established mathematics. These are not FRFP axioms — they are well-established results imported from cited literature.

| Family | Representative axioms | Primary source |
|---|---|---|
| IEEE 754 float arithmetic | Associativity, commutativity, distributivity, order | [IEEE 754-2019] |
| Probability / measure | Countable additivity, normalization, independence | [Billingsley 1995] |
| Stopping times | Measurability, Markov property | [Billingsley 1995] §36 |
| Stochastic tail bounds | Markov inequality, geometric decay | [Durrett 2019] |
| Term rewriting / ARS | Termination, local confluence implies confluence | [Baader–Nipkow 1998] |
| Newman's Lemma | Confluence from termination + local confluence | [Newman 1942] |
| Category / groupoid | Associativity, identity, groupoid inverses | [Mac Lane 1971] |
| Real analysis | Geometric limit-to-zero | [Rudin 1976] |
| Temporal safety | Safety properties over infinite traces | [Pnueli 1977] |
| Safety vs liveness | Decomposition of liveness properties | [Alpern–Schneider 1985] |

**[Lean: `Frfp.Minimal.ReducedBasis.sourceBackedFamilies`]**

---

## 2.6 Decomposition: Skeleton vs Policy Residue

Each of the 7 retained axioms decomposes into two parts:

- **Skeleton**: the mathematically structural part, derivable or source-anchored to published mathematics.
- **Policy residue**: the irreducible normative/governance commitment.

| Axiom | Skeleton | Policy residue |
|---|---|---|
| HEG | $\mathrm{TE}, \mathrm{HFD}$ target $T_0$ (Lean-proved) | Only humans may execute these |
| HEC | $\mathrm{HFD}$ is a $T_0$-endomorphism (Lean-proved) | No AI substitution for closure |
| CP | Composition preserves source/target (Lean-proved) | Pipelines are the only valid composition |
| IL | Trace invariant (Pnueli 1977) | Intent is a shared, locked resource |
| AR | Liveness (Alpern–Schneider 1985) | Ambiguity must be resolved |
| NTER | Structural = ETS (Lean-proved) | AI prohibited from tacit emulation attempts |
| CSC | Safety/monotonicity (Pnueli 1977) | Correctness lock is irreversible |

The policy residue of all seven axioms is where the human-authority commitments of FRFP live. These cannot be formalized as mathematical theorems — they are governance premises.

**[Lean: `Frfp.Minimal.ReducedBasis.DecompositionStatus`]**
