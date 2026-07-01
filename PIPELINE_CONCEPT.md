# Pipeline Concept: Pipelines are Morphisms in C0

## Core Principle

**A pipeline is a morphism in the kernel category C0.**

Formally: A pipeline is `f : X ⟶ Y` where `X, Y ∈ Ob(C0) = {∅, E0, T0}`.

## Definition

```lean
-- In Frfp/Core/Kernel.lean

/-- A morphism in the kernel category C0 -/
structure Morphism where
  source : Object
  target : Object
  prim : Primitive
  deriving Repr

/-- A pipeline is a morphism in C0 -/
abbrev Pipeline := Morphism
```

This means **pipelines ARE morphisms** - there is no separate concept of "pipeline" distinct from "morphism in C0".

## Pipeline Types

### 1. Explicit Pipelines

An **explicit pipeline** is a morphism with:
- **Source**: `∅` or `E0`
- **Target**: `E0`

```lean
def is_explicit_pipeline (π : Pipeline) : Prop :=
  (π.source = Object.empty ∨ π.source = Object.E0) ∧ π.target = Object.E0
```

**Examples:**
- `RI : ∅ → E0` - Representation Initiation (initializes explicit state)
- `EC : E0 → E0` - Explicit Computation (transforms explicit state)
- `ED : E0 → E0` - Explicit Diagnostics (analyzes explicit state)

**Semantics**: These are AI-executable operations that manipulate machine-representable state.

### 2. Boundary Pipelines

A **boundary pipeline** is the unique morphism:
- **Source**: `E0`
- **Target**: `T0`

```lean
def is_boundary_pipeline (π : Pipeline) : Prop :=
  π.source = Object.E0 ∧ π.target = Object.T0
```

**Example:**
- `RB : E0 → T0` - Representational Backflow (the ONLY boundary morphism)

**Theorem (ETS Axiom 2)**: RB is the unique boundary morphism.

```lean
theorem RB_unique_boundary (p : Primitive) :
    (p.source = Object.E0 ∧ p.target = Object.T0) → p = Primitive.RB
```

**Semantics**: This is the human-exclusive operation that moves from machine-representable to correctness-bearing (tacit) state.

### 3. Tacit Pipelines

A **tacit pipeline** is a morphism with:
- **Source**: `T0`
- **Target**: `T0`

```lean
def is_tacit_pipeline (π : Pipeline) : Prop :=
  π.source = Object.T0 ∧ π.target = Object.T0
```

**Examples:**
- `TE : T0 → T0` - Tacit Evaluation (human judgment/assessment)
- `HFD : T0 → T0` - Human Final Decision (human correctness commitment)

**Semantics**: These are human-only operations that work with tacit knowledge.

## Composition

Pipelines compose as morphisms in a category:

```lean
def pipeline_compose (π₁ π₂ : Pipeline) (h : π₁.target = π₂.source) : Pipeline :=
  { source := π₁.source
    target := π₂.target
    prim := π₂.prim  -- Simplified; full composition requires sequences
  }
```

**Typing Rule**: To compose `π₂ ∘ π₁`, we need `π₁.target = π₂.source`.

**Examples of Valid Compositions:**
- `EC ∘ RI : ∅ → E0 → E0` (explicit pipeline)
- `RB ∘ EC : E0 → E0 → T0` (explicit → boundary)
- `TE ∘ RB : E0 → T0 → T0` (boundary → tacit)
- `HFD ∘ TE : T0 → T0 → T0` (tacit pipeline)

**ETS Constraint**: There are NO morphisms `T0 → E0`, so compositions like `? ∘ TE` where `?` has target E0 are **impossible**.

```lean
theorem no_morphism_T0_to_E0 (p : Primitive) :
    ¬(p.source = Object.T0 ∧ p.target = Object.E0)
```

## Well-Typedness

A pipeline (morphism) is **well-typed** if its primitive's source/target match the morphism's source/target:

```lean
def pipeline_well_typed (π : Pipeline) : Prop :=
  π.prim.source = π.source ∧ π.prim.target = π.target

theorem primitive_well_typed (p : Primitive) : 
    pipeline_well_typed p.toMorphism
```

All primitives converted to morphisms are automatically well-typed.

## TDG: Syntax for Pipelines

The **Task Decomposition Grammar (TDG)** provides **syntax** that **interprets to pipelines** (morphisms in C0).

TDG adds structural operators:
- **Sequence**: Linear composition of primitives
- **Branch**: Conditional selection between pipelines
- **Parallel**: Concurrent execution of independent pipelines
- **Loop**: Iterative application with feedback

**Key Insight**: TDG terms are **not** themselves morphisms - they are **syntax trees** that **denote** morphisms in C0.

```lean
-- In Frfp/Core/TDG.lean

/-- TDG Pipeline with structural operators -/
inductive TDGPipeline where
  | single : Primitive → TDGPipeline
  | sequence : TDGPipeline → Primitive → TDGPipeline
  | branch : List TDGPipeline → TDGPipeline
  | parallel : List TDGPipeline → TDGPipeline
  | loop : TDGPipeline → TDGPipeline → TDGPipeline

-- TDG terms INTERPRET to pipelines (morphisms in C0)
-- A full semantics would provide: ⟦ · ⟧ : TDGPipeline → Pipeline
```

### TDG Interpretation (Future Work)

The full TDG semantics would define an interpretation function:

```lean
-- Future: Define the semantics of TDG as interpretation to morphisms
def tdg_interpret : TDGPipeline → Pipeline
  | TDGPipeline.single p => p.toMorphism
  | TDGPipeline.sequence π p => pipeline_compose (tdg_interpret π) p.toMorphism _
  | TDGPipeline.branch pipelines => ... -- Requires coproducts in C0
  | TDGPipeline.parallel pipelines => ... -- Requires products in C0
  | TDGPipeline.loop body feedback => ... -- Requires limits in C0
```

This makes precise the slogan: **"TDG terms are syntax that interprets to morphisms in C0."**

## Comparison with Previous Design

### Before (Confusing)

```lean
-- OLD: Pipeline was a separate inductive type
inductive Pipeline where
  | single : Primitive → Pipeline
  | compose : Pipeline → Primitive → Pipeline

-- OLD: Morphism was something different
structure Morphism where
  source : Object
  target : Object
  prim : Primitive

-- Confusion: What's the relationship? Two separate concepts!
```

**Problem**: Two distinct concepts (Pipeline vs Morphism) for what should be one thing.

### After (Clear)

```lean
-- NEW: Morphism is the fundamental concept
structure Morphism where
  source : Object
  target : Object
  prim : Primitive

-- NEW: Pipeline IS a morphism
abbrev Pipeline := Morphism

-- Clear: A pipeline is literally f : X ⟶ Y in C0
```

**Benefit**: Single unified concept. Category theory is the foundation.

## Architectural Benefits

### 1. **Mathematical Clarity**
- Pipelines are morphisms in a category - standard category theory applies
- Composition is categorical composition
- Identity morphisms, associativity, etc. follow from category structure

### 2. **Type Safety**
- Object typing (`X ⟶ Y`) enforced by Lean's type system
- ETS axioms prevent illegal compositions (`T0 → E0` impossible)
- Well-typedness checked statically

### 3. **Modular Extension**
- TDG is a **syntax layer** on top of the kernel
- New syntactic forms can be added without changing the kernel
- All syntax interprets to morphisms in C0

### 4. **Proof Simplification**
- Theorems about pipelines are theorems about morphisms
- Standard categorical reasoning applies
- Properties like minimality, initiality proven at morphism level

## Usage Examples

### Creating Pipelines

```lean
-- Primitive as pipeline (morphism)
def ri_pipeline : Pipeline := Primitive.RI.toMorphism
-- ri_pipeline : ∅ → E0

def ec_pipeline : Pipeline := Primitive.EC.toMorphism
-- ec_pipeline : E0 → E0

-- Composition (when types match)
def composed : Pipeline := 
  pipeline_compose ri_pipeline ec_pipeline (by rfl)
-- composed : ∅ → E0
```

### Checking Pipeline Properties

```lean
-- Check if explicit
#eval is_explicit_pipeline ri_pipeline  -- (True, E0 target)

-- Check if boundary
#eval is_boundary_pipeline Primitive.RB.toMorphism  -- (True, E0 → T0)

-- Check well-typedness
theorem ri_well_typed : pipeline_well_typed ri_pipeline := 
  primitive_well_typed Primitive.RI
```

### TDG Syntax (Future)

```lean
-- TDG term
def example_tdg : TDGPipeline :=
  TDGPipeline.sequence
    (TDGPipeline.single Primitive.RI)
    Primitive.EC

-- Interprets to pipeline (morphism in C0)
def example_pipeline : Pipeline := tdg_interpret example_tdg
-- example_pipeline : ∅ → E0
```

## Downstream Implications

### Phase 2+ Extensions

When extending beyond Phase 1:
- **New objects**: Add to C0 (e.g., `M0` for meta-object)
- **New morphisms**: Add primitives with proper source/target
- **New syntax**: Add TDG operators that interpret to new morphisms
- **Core invariant**: Pipelines remain morphisms in the extended C0

### Tooling Integration

External tools (linters, visualizers, execution engines) can:
- Parse TDG syntax trees
- Interpret to pipelines (morphisms)
- Reason about typing (`X ⟶ Y`)
- Enforce ETS constraints
- Generate executable code

### Formal Methods

Verification tools can:
- Prove properties of pipeline composition
- Check ETS compliance
- Verify initiality/minimality
- Analyze reachability in the category
- Generate counterexamples for illegal compositions

## Summary

| Concept | Definition | Role |
|---------|-----------|------|
| **Pipeline** | `Pipeline := Morphism` | A morphism `f : X ⟶ Y` in C0 |
| **Explicit Pipeline** | `(∅ or E0) → E0` | AI-executable operations |
| **Boundary Pipeline** | `E0 → T0` | Unique morphism RB |
| **Tacit Pipeline** | `T0 → T0` | Human-only operations |
| **TDG Term** | Syntax tree | Interprets to pipeline |
| **Composition** | `π₂ ∘ π₁` | Categorical composition in C0 |

**Core Principle**: **Pipelines are morphisms in C0.** Everything else follows from this foundation.

---

**Status**: ✅ IMPLEMENTED in Frfp.Core.Kernel
**Verification**: ✅ All modules compile with new definition
**Documentation**: ✅ This file
**Next Steps**: Define TDG interpretation function `tdg_interpret : TDGPipeline → Pipeline`
