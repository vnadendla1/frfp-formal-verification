# Appendix E: Naming Conventions

**Paper**: FRFP Lean Formal Verification  
**Appendix**: E  
**Source**: NAMING_CONVENTION.md

---

## E.1 Problem and Solution

### The Problem

In early formalization iterations, names like `Object.explicit` and `Object.tacit` were ambiguous:
- Were they **objects** in the kernel category?
- Were they **categories** (like "the explicit category")?

This mixing led to architectural confusion when referring to `E` (an object) vs `Ecat` (a subcategory type).

### The Solution: Subscript-0 for Objects, Suffix-cat for Categories

**Key rule**: Objects have subscript 0 (`E0`, `T0`); categories/types have suffix `cat` (`Ecat`, `Tcat`).

| Name | Type | Meaning |
|---|---|---|
| `E0` | Object in C0 | The explicit object in the kernel category |
| `T0` | Object in C0 | The tacit object in the kernel category |
| `C0` | Category | The kernel category with objects {∅, E0, T0} |
| `Ecat` | Type/Subcategory | The explicit subcategory (morphisms → E0) |
| `Tcat` | Type/Subcategory | The tacit subcategory (morphisms → T0) |

- **E0 is an object** — it is NOT a category.
- **Ecat is a type** — it is NOT an object.
- **C0 is the kernel category** containing objects {∅, E0, T0}.

---

## E.2 Core Kernel Definitions

```lean
-- The 3-object kernel category
inductive Object where
  | empty : Object   -- ∅ (initial object)
  | E0    : Object   -- Explicit object (NOT a category!)
  | T0    : Object   -- Tacit object (NOT a category!)

-- C0: The kernel category itself
abbrev C0 := Object

-- Mathematical notation
notation "E₀" => Object.E0
notation "T₀" => Object.T0

-- Subcategory types (dependent types)
def Ecat : Type := { p : Primitive // p.target = Object.E0 }
def Tcat : Type := { p : Primitive // p.target = Object.T0 }
```

---

## E.3 Correct and Incorrect Usage

```lean
-- ✅ CORRECT: E0 is an object
def explicit_object : Object := Object.E0

-- ✅ CORRECT: Ecat is a type of morphisms
def explicit_morphism : Ecat := ⟨Primitive.EC, rfl⟩

-- ✅ CORRECT: RB is a boundary morphism E0 → T0
theorem rb_goes_from_E0_to_T0 :
    Primitive.RB.source = Object.E0 ∧ Primitive.RB.target = Object.T0

-- ❌ WRONG: Treating E0 as a category
def morphism_in_E0 : E0 := ...  -- Type error: E0 is Object, not Type

-- ❌ WRONG: Treating Ecat as an object
def ecat_object : Object := Ecat  -- Type error: Ecat is Type, not Object
```

---

## E.4 Module-Level Naming Patterns

| Pattern | Example | Meaning |
|---|---|---|
| `*State` | `TacitState`, `EpistemicState` | State structures |
| `*Layer` | `DynamicLayer`, `CollectiveLayer` | Layer definitions |
| `*Morphism` | `GrothendieckMorphism`, `PopMorphism` | Category morphisms |
| `*Graph` | `CommunicationGraph`, `TacitDependenceGraph` | Graph structures |
| `*Op` | `KnowledgeOp`, `BeliefRevision` | Operations/operators |
| `*Framework` | `Phase1Framework`, `GovernanceFramework` | Framework definitions |

---

## E.5 Type vs Instance Naming

**Types** (PascalCase):
```lean
structure TacitState where ...
structure Pipeline where ...
inductive Object where ...
```

**Instances / Functions** (camelCase or lowercase):
```lean
def degradation : TacitState → TacitState := δ
def survival : StoppingTime → Nat → Float := ...
def hazard : StoppingTime → Nat → Float := ...
```

---

## E.6 Theorem Naming Conventions

| Pattern | Example | Meaning |
|---|---|---|
| `*_refl` | `tacitState_le_refl` | Reflexivity |
| `*_symm` | `sameNF_symm` | Symmetry |
| `*_trans` | `sameNF_trans` | Transitivity |
| `*_monotone` | `degradation_monotone` | Monotonicity |
| `*_bounds` | `survival_bounds`, `hazard_bounds` | Value bounds |
| `*_characterization` | `safe_horizon_characterization` | Characterization theorem |
| `*_iff` | `boundary_morphism_iff` | If-and-only-if |
| `*_exists` | `semantic_function_exists` | Existence |
| `*_unique` | `RB_unique_boundary` | Uniqueness |

---

## E.7 Axiom Naming Conventions

| Pattern | Example | Purpose |
|---|---|---|
| `axiom *_inhabited` | `epistemic_state_inhabited` | Type inhabitance |
| `axiom *_nonneg` | `zero_nonneg` | Non-negativity |
| `axiom *_bounds` | `half_bounds` | Value bounds |
| `axiom *_comm` | `float_mul_comm` | Commutativity |
| `axiom *_assoc` | `float_add_assoc` | Associativity |
| `axiom *_idempotent` | `belief_revision_idempotent` | Idempotence |

---

## E.8 Mathematical Notation in Lean

```lean
notation "E₀" => Object.E0         -- Explicit object
notation "T₀" => Object.T0         -- Tacit object
notation "Ω"  => ProbabilitySpace  -- Sample space
notation "ℙ"  => ProbabilityMeasure -- Probability measure
notation "δ"  => degradation        -- Degradation operator
notation "⪯"  => tacit_preorder     -- Tacit preorder

infixr:90 " ≫ " => Pipeline.compose  -- Pipeline composition
notation "f ⟶ g" => Morphism         -- Category morphism
```

---

## E.9 Backward Compatibility Aliases

To ease migration from earlier naming:

```lean
-- Old name → new name alias
theorem no_morphism_tacit_to_explicit : ∀ (p : Primitive),
    ¬(p.source = Object.T0 ∧ p.target = Object.E0) :=
  no_morphism_T0_to_E0
```

---

## E.10 Future Extension Rules

When extending FRFP beyond Phase 1:

- **Phase 2 objects**: Use similar subscript convention (e.g., `M0` for meta-object)
- **Phase 2 categories**: Use `Mcat` for meta-category
- **Higher phases**: Maintain subscript-0 for objects, suffix-cat for categories
- **New layers**: Follow `*Layer` pattern (e.g., `MetaLayer.lean`)
- **New structures**: Follow module-specific conventions in Section E.4

---

## E.11 Compliance Status

As of Lean 4.29.0 verification:

| Convention | Status |
|---|---|
| All kernel definitions use E0/T0 | ✅ |
| All theorems reference E0/T0 correctly | ✅ |
| Subcategories Ecat/Tcat properly typed | ✅ |
| 21 Core modules follow consistent patterns | ✅ |
| Theorem and axiom naming standardized | ✅ |
| Build succeeds with `lake build` | ✅ |
| All proofs machine-checked by Lean 4 | ✅ |
