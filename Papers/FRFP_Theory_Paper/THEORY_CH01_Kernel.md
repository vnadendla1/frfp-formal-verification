# Chapter 1: The Kernel Category

**Paper**: FRFP: A Formal Theory of Explicit–Tacit Computation  
**Chapter**: 1 of 7

---

## 1.1 Overview

FRFP is built on a minimal three-object category $\mathbf{C}_0$ whose structure encodes the fundamental distinction between explicit (machine-manipulable) and tacit (human correctness-bearing) computation. This chapter defines $\mathbf{C}_0$, its six primitive morphisms, their typing rules, and the core theorems that follow directly from the definitions — without requiring any additional axioms.

---

## 1.2 Objects

**Definition 1.1** (Kernel category objects). The kernel category $\mathbf{C}_0$ has exactly three objects:

$$\mathrm{Ob}(\mathbf{C}_0) = \{\varnothing,\ E_0,\ T_0\}$$

| Object | Name | Interpretation |
|---|---|---|
| $\varnothing$ | Empty | The absent or uninitialized explicit state |
| $E_0$ | Explicit object | Machine-manipulable representations |
| $T_0$ | Tacit object | Human correctness-bearing knowledge |

The object set is closed. No extensions to $\mathbf{C}_0$ are permitted. **[Lean: `Frfp.Core.Kernel.Object`]**

The objects are sometimes written with subscript notation: $E_0$ (the explicit *object*) is distinct from $\mathbf{E}_{cat}$ (the *category* of explicit morphisms). This distinction is enforced in the Lean formalization by separate types and is critical for avoiding architectural confusion.

---

## 1.3 Primitive Morphisms

**Definition 1.2** (Primitives). The six primitive morphisms of $\mathbf{C}_0$ are:

| Primitive | Source | Target | Name | Role |
|---|---|---|---|---|
| $\mathrm{RI}$ | $\varnothing$ | $E_0$ | Representation Initiation | Creates an explicit representation |
| $\mathrm{EC}$ | $E_0$ | $E_0$ | Explicit Computation | AI processing within explicit space |
| $\mathrm{ED}$ | $E_0$ | $E_0$ | Explicit Diagnostics | AI checking/verification within explicit space |
| $\mathrm{RB}$ | $E_0$ | $T_0$ | Representational Backflow | The unique boundary crossing morphism |
| $\mathrm{TE}$ | $T_0$ | $T_0$ | Tacit Evaluation | Human evaluation within tacit space |
| $\mathrm{HFD}$ | $T_0$ | $T_0$ | Human Final Decision | Human closure within tacit space |

**[Lean: `Frfp.Core.Kernel.Primitive`]**

The primitive set is a closed enumeration. No new primitives may be added without a complete re-audit of all downstream theorems.

---

## 1.4 Subcategories

**Definition 1.3** (Explicit subcategory). $\mathbf{E}_{cat}$ is the full subcategory of morphisms targeting $E_0$:
$$\mathbf{E}_{cat} = \{p : \mathrm{Primitive} \mid p.\mathrm{target} = E_0\} = \{\mathrm{RI}, \mathrm{EC}, \mathrm{ED}\}$$

**Definition 1.4** (Tacit subcategory). $\mathbf{T}_{cat}$ is the full subcategory of morphisms targeting $T_0$:
$$\mathbf{T}_{cat} = \{p : \mathrm{Primitive} \mid p.\mathrm{target} = T_0\} = \{\mathrm{RB}, \mathrm{TE}, \mathrm{HFD}\}$$

**[Lean: `Frfp.Core.Kernel.Ecat`, `Frfp.Core.Kernel.Tcat`]**

The partition $\mathbf{E}_{cat} \cup \mathbf{T}_{cat}$ covers all six primitives and is disjoint, since no primitive targets both $E_0$ and $T_0$.

---

## 1.5 Core Typing Theorems

The following theorems are proved directly from the primitive definitions — no additional axioms are required. These form the bedrock on which the rest of the theory rests.

**Theorem 1.1** (Explicit–Tacit Separation). There is no primitive morphism from $T_0$ to $E_0$:
$$\forall p : \mathrm{Primitive},\ \neg(p.\mathrm{source} = T_0 \wedge p.\mathrm{target} = E_0)$$

*Proof*. By case analysis on the six primitives. None has source $T_0$ and target $E_0$. □  
**[Lean: `Frfp.Core.Kernel.no_morphism_T0_to_E0`]**

> *Note*: In the original published theory, ETS was listed as a primitive axiom. The Lean formalization shows it is a consequence of the primitive typing. See Chapter 2.

**Theorem 1.2** (Uniqueness of the boundary morphism). $\mathrm{RB}$ is the unique primitive crossing from $E_0$ to $T_0$:
$$\forall p : \mathrm{Primitive},\ (p.\mathrm{source} = E_0 \wedge p.\mathrm{target} = T_0) \Rightarrow p = \mathrm{RB}$$

*Proof*. By case analysis on the six primitives. Only $\mathrm{RB}$ has source $E_0$ and target $T_0$. □  
**[Lean: `Frfp.Core.Kernel.RB_unique_boundary`]**

**Theorem 1.3** (AI executability partition). Define `is_AI_executable` as $\{\mathrm{RI}, \mathrm{EC}, \mathrm{ED}\}$. Then:
$$\forall p,\ \text{is\_AI\_executable}(p) \Rightarrow (p.\mathrm{source} \in \{\varnothing, E_0\}) \wedge p.\mathrm{target} = E_0$$

*Proof*. By case analysis; $\mathrm{RI}, \mathrm{EC}, \mathrm{ED}$ each satisfy the condition; $\mathrm{RB}, \mathrm{TE}, \mathrm{HFD}$ each violate it. □  
**[Lean: `Frfp.Core.Kernel.AI_preserves_explicit`]**

**Corollary 1.1** (Human-exclusive tacit access). $\mathrm{RB}$, $\mathrm{TE}$, and $\mathrm{HFD}$ are never AI-executable and always operate in or enter tacit space. **[Lean: `Frfp.Core.Kernel.is_human_only`]**

---

## 1.6 Pipelines

**Definition 1.5** (Pipeline). A pipeline $\Pi$ is a morphism in $\mathbf{C}_0$: a triple $(\mathrm{src}, \mathrm{tgt}, p)$ where $p$ is the underlying primitive.

Pipelines are classified by their type:

| Pipeline type | Source | Target | Underlying primitives |
|---|---|---|---|
| Explicit pipeline | $\varnothing$ or $E_0$ | $E_0$ | $\mathrm{RI}$, $\mathrm{EC}$, $\mathrm{ED}$ |
| Boundary pipeline | $E_0$ | $T_0$ | $\mathrm{RB}$ (unique) |
| Tacit pipeline | $T_0$ | $T_0$ | $\mathrm{TE}$, $\mathrm{HFD}$ |

**Definition 1.6** (Pipeline composition). For pipelines $\Pi_1 : X \to Y$ and $\Pi_2 : Y \to Z$, their composition $\Pi_2 \circ \Pi_1 : X \to Z$ is defined when $\Pi_1.\mathrm{target} = \Pi_2.\mathrm{source}$.

**[Lean: `Frfp.Core.Kernel.pipeline_compose`]**

**Theorem 1.4** (Composition preserves typing). If $\Pi_1 : X \to Y$ and $\Pi_2 : Y \to Z$, then $(\Pi_2 \circ \Pi_1).\mathrm{source} = X$ and $(\Pi_2 \circ \Pi_1).\mathrm{target} = Z$. **[Lean: `Frfp.Core.Kernel.pipeline_compose`]**

---

## 1.7 Primitive Phase Partition

The six primitives are partitioned into three phases based on their typing:

**Definition 1.7** (Primitive phase). The phase of a primitive is defined by:

$$\mathrm{phase}(p) = \begin{cases}
\text{explicit} & \text{if } p \in \{\mathrm{RI}, \mathrm{EC}, \mathrm{ED}\} \\
\text{boundary} & \text{if } p = \mathrm{RB} \\
\text{tacit} & \text{if } p \in \{\mathrm{TE}, \mathrm{HFD}\}
\end{cases}$$

**[Lean: `Frfp.Minimal.BasisSweep.phaseOf`]**

**Theorem 1.5** (Phase partition). The phase function is total: every primitive has exactly one phase. **[Lean: `Frfp.Minimal.BasisSweep.phase_partition`]**

**Theorem 1.6** (Boundary uniqueness by phase). A primitive has boundary phase if and only if it is $\mathrm{RB}$. **[Lean: `Frfp.Minimal.BasisSweep.phase_boundary_iff`]**

---

## 1.8 The No-Return Principle

A fundamental structural property of $\mathbf{C}_0$ is that once a pipeline enters tacit space, it cannot return to explicit space:

**Theorem 1.7** (No tacit-to-explicit return). There is no sequence of primitives that goes from $T_0$ to $E_0$:
$$\nexists\ p_1, \ldots, p_n : \mathrm{Primitive},\quad p_1.\mathrm{source} = T_0 \wedge p_n.\mathrm{target} = E_0$$

This follows from Theorem 1.1 (ETS) by induction: every primitive either stays in tacit space ($T_0 \to T_0$) or goes to $E_0$ from $\varnothing$ or $E_0$.

The one-directional boundary $E_0 \xrightarrow{\mathrm{RB}} T_0$ is thus a genuine asymmetry in the categorical structure: not a functor, not an equivalence, but a one-way transition that formalizes the tacit grounding of AI outputs by human judgment.

---

## 1.9 Immutability of the Kernel

**Design principle** (Kernel immutability). The definitions of `Object`, `Primitive`, `Primitive.source`, and `Primitive.target` are immutable. No module in the library may shadow, redefine, or extend them.

This is enforced architecturally: `Kernel.lean` has no imports other than Lean's standard library, and all other modules depend on it. Any change to Kernel invalidates all 3305 downstream build jobs. **[Lean: `Frfp.Core.Kernel` — no extends, no shadows]**
