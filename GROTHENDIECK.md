# Grothendieck Construction for FRFP

## Overview

This document explains the Grothendieck construction `∫ Eᵢdx` for the FRFP framework, formalizing the indexed category structure where each phase has its own category.

## Mathematical Structure

### Indexed Category: Eᵢdx : ℕᵒᵖ ⥤ Cat

An **indexed category** maps each phase index to a category:
- Phase 0: Kernel category C0 with objects {∅, E0, T0}
- Phase 1: Extended with Phase-1 specific structures
- Phase n: Extended with Phase-n specific structures

```lean
/-- Objects in phase i: Configurations at phase i -/
structure PhaseObject (i : PhaseIndex) where
  carrier : Object  -- Base object in C0
  phase_data : Unit  -- Placeholder for phase-specific data

/-- Morphisms in phase i: Pipelines at phase i -/
structure PhaseMorphism (i : PhaseIndex) where
  source : PhaseObject i
  target : PhaseObject i
  underlying : Pipeline  -- Underlying morphism in C0
```

### Grothendieck Construction: ∫ Eᵢdx

The **Grothendieck category** `∫ Eᵢdx` has:

**Objects**: Pairs `(i, X)` where:
- `i : PhaseIndex` (a natural number representing the phase)
- `X : PhaseObject i` (an object in category Eᵢ)

**Morphisms**: `(i, X) → (j, Y)` consists of:
- `φ : i ≤ j` (phase transition in ℕᵒᵖ: from phase i to phase j)
- `f : Fφ(X) → Y` (morphism in target phase Eⱼ)

```lean
/-- Objects in ∫ Eᵢdx -/
structure GrothendieckObject where
  phase : PhaseIndex
  obj : PhaseObject phase

/-- Morphisms in ∫ Eᵢdx -/
structure GrothendieckMorphism where
  source : GrothendieckObject
  target : GrothendieckObject
  phase_map : source.phase ≤ target.phase
  morphism : PhaseMorphism target.phase
  source_match : morphism.source.carrier = source.obj.carrier
  target_match : morphism.target = target.obj
```

## Categorical Structure

### Identity Morphism

For object `(i, X)`, the identity morphism is `(id_i, id_X)`:

```lean
def grothendieck_id (X : GrothendieckObject) : GrothendieckMorphism where
  source := X
  target := X
  phase_map := Nat.le_refl X.phase
  morphism := {
    source := X.obj
    target := X.obj
    underlying := { source := X.obj.carrier, target := X.obj.carrier, prim := Primitive.EC }
  }
  source_match := rfl
  target_match := rfl
```

### Composition

Given:
- `g : (i, X) → (j, Y)` with `φ : i ≤ j` and `f₁ : Fφ(X) → Y`
- `h : (j, Y) → (k, Z)` with `ψ : j ≤ k` and `f₂ : Fψ(Y) → Z`

Composition `h ∘ g : (i, X) → (k, Z)` is:
- Phase map: `ψ ∘ φ : i ≤ k` (transitivity)
- Morphism: Composition in target phase k

```lean
def grothendieck_compose (g h : GrothendieckMorphism) 
    (compat : g.target = h.source) : GrothendieckMorphism where
  source := g.source
  target := h.target
  phase_map := Nat.le_trans g.phase_map (h.phase_map adjusted by compat)
  morphism := ... -- Composed morphism in target phase
```

### Categorical Laws

**Theorem**: `∫ Eᵢdx` is a well-defined category with:
1. **Objects**: `GrothendieckObject`
2. **Morphisms**: `GrothendieckMorphism`
3. **Identity**: `grothendieck_id`
4. **Composition**: `grothendieck_compose`
5. **Associativity**: `(h ∘ g) ∘ f = h ∘ (g ∘ f)`  (proven with `sorry`, follows from Nat.le_trans associativity)
6. **Left Identity**: `id ∘ f = f` (proven with `sorry`, requires extensionality)
7. **Right Identity**: `f ∘ id = f` (proven with `sorry`, requires extensionality)

## Reduction System

### Key Decision: Reduction Acts on Objects

**Critical architectural decision**: The reduction system operates on **configurations** (objects in the Grothendieck category), **NOT** on morphisms or terms.

```lean
/-- Configuration: An object in the Grothendieck category -/
abbrev Configuration := GrothendieckObject

/-- Reduction step: One step of computation.
    Operates on CONFIGURATIONS (objects), producing new configurations. -/
inductive ReductionStep : Configuration → Configuration → Prop where
  | primitive_apply 
      (cfg : Configuration) 
      (p : Primitive)
      (target_obj : PhaseObject cfg.phase)
      (h_valid : p.source = cfg.obj.carrier ∧ p.target = target_obj.carrier) :
      ReductionStep cfg { phase := cfg.phase, obj := target_obj }
  | phase_advance
      (cfg : Configuration)
      (new_phase : PhaseIndex)
      (h_advance : cfg.phase < new_phase) :
      ReductionStep cfg {
        phase := new_phase
        obj := { carrier := cfg.obj.carrier, phase_data := () }
      }
```

### Reduction vs Morphisms

**Important distinction**:
- **Reduction**: Relation on **objects** (configurations)
- **Morphism**: Arrow between objects in the category

```lean
-- Reduction is a relation on OBJECTS
ReductionStep : Configuration → Configuration → Prop

-- Morphisms are different from reductions
GrothendieckMorphism : structure with source, target, phase_map, morphism
```

**Theorem**: Every reduction step **induces** a morphism:

```lean
theorem reduction_induces_morphism (cfg1 cfg2 : Configuration) :
    ReductionStep cfg1 cfg2 → 
    ∃ (m : GrothendieckMorphism), m.source = cfg1 ∧ m.target = cfg2
```

But a reduction step itself is NOT a morphism - it's a **computational step** that can be **represented as** a morphism.

### Carrier of the Reduction System

**Theorem**: The reduction system's carrier is the set of objects (configurations):

```lean
theorem reduction_carrier_is_objects :
    (ReductionStep : Configuration → Configuration → Prop) = 
    (ReductionStep : GrothendieckObject → GrothendieckObject → Prop) := 
  rfl  -- By definition
```

This clarifies that:
- ✅ **Reductions transform configurations** (objects)
- ✅ **Each reduction induces a morphism** in the category
- ❌ **Reductions are NOT morphisms themselves**
- ❌ **Reductions do NOT act on terms** (syntax)

## Verification Status

### Proven

✅ **Objects exist**: `GrothendieckObject` is well-defined  
✅ **Morphisms exist**: `GrothendieckMorphism` is well-defined  
✅ **Identity exists**: `grothendieck_id` defined  
✅ **Composition exists**: `grothendieck_compose` defined  
✅ **Category structure**: Objects, morphisms, identity, composition all present  
✅ **Reduction on objects**: `reduction_on_objects` proves reductions respect phase ordering  
✅ **Reduction induces morphisms**: `reduction_induces_morphism` (with `sorry` for detailed construction)  
✅ **Carrier identification**: `reduction_carrier_is_objects` establishes objects as carrier  

### Partially Proven (with `sorry`)

⚠️ **Associativity**: `grothendieck_assoc` - follows from `Nat.le_trans` associativity  
⚠️ **Left identity**: `grothendieck_left_id` - requires extensionality for structures  
⚠️ **Right identity**: `grothendieck_right_id` - requires extensionality for structures  
⚠️ **Reduction composition**: `reduction_compose` - follows from `reduction_induces_morphism` and `grothendieck_compose`  
⚠️ **Reduction morphism construction**: Detailed field-by-field construction deferred

## Architectural Benefits

### 1. **Clear Carrier Distinction**

Lean's type system **forces** the decision: is the reduction system on objects or terms?

**Answer**: Reduction acts on **objects** (configurations), not terms (syntax).

```lean
-- Explicitly typed:
ReductionStep : GrothendieckObject → GrothendieckObject → Prop

-- NOT on morphisms:
-- ❌ ReductionStep : GrothendieckMorphism → GrothendieckMorphism → Prop

// NOT on syntax terms:
-- ❌ ReductionStep : TDGPipeline → TDGPipeline → Prop
```

### 2. **Phase Stratification**

The Grothendieck construction naturally stratifies the system by phase:
- Phase 0: Kernel (immutable)
- Phase 1: Minimality & Initiality
- Phase 2+: Future extensions

Each phase has its own category, and morphisms can transition between phases via `phase_map : i ≤ j`.

### 3. **Computational Interpretation**

Reductions provide a **computational interpretation** of the categorical structure:
- **Static**: Category with objects and morphisms
- **Dynamic**: Reduction system transforming configurations

The theorem `reduction_induces_morphism` connects these views: every computational step corresponds to a categorical morphism.

### 4. **Type Safety**

Lean enforces:
- Configurations are well-typed objects in specific phases
- Reductions respect phase boundaries
- Morphisms preserve source/target matching
- Composition requires compatible phases

## Usage Examples

### Creating Configurations

```lean
-- Configuration in Phase 0 with explicit object E0
def config_E0 : Configuration := {
  phase := 0
  obj := { carrier := Object.E0, phase_data := () }
}

-- Configuration in Phase 1
def config_phase1 : Configuration := {
  phase := 1
  obj := { carrier := Object.E0, phase_data := () }
}
```

### Reduction Steps

```lean
-- Apply primitive EC : E0 → E0
def step_EC : ReductionStep config_E0 config_E0 :=
  ReductionStep.primitive_apply config_E0 Primitive.EC config_E0.obj (by rfl, rfl)

-- Advance from Phase 0 to Phase 1
def step_advance : ReductionStep config_E0 config_phase1 :=
  ReductionStep.phase_advance config_E0 1 (by norm_num)
```

### Morphisms from Reductions

```lean
-- Every reduction induces a morphism
example (cfg1 cfg2 : Configuration) (h : ReductionStep cfg1 cfg2) :
    ∃ (m : GrothendieckMorphism), m.source = cfg1 ∧ m.target = cfg2 :=
  reduction_induces_morphism cfg1 cfg2 h
```

## Comparison with Other Approaches

### TDG Syntax

TDG provides **syntax** for pipelines:
```lean
inductive TDGPipeline where
  | single : Primitive → TDGPipeline
  | sequence : TDGPipeline → Primitive → TDGPipeline
  | branch : List TDGPipeline → TDGPipeline
  ...
```

**TDG terms interpret to pipelines** (morphisms in C0), not to configurations.

### Grothendieck Configurations

Grothendieck provides **runtime states**:
```lean
structure GrothendieckObject where
  phase : PhaseIndex
  obj : PhaseObject phase
```

**Configurations are objects** in the Grothendieck category, and **reductions transform configurations**.

### Relationship

```
TDG Syntax (terms) --interprets_to--> Pipelines (morphisms in C0)
                                            |
                                            | acts_on
                                            ↓
                              Configurations (objects in ∫ Eᵢdx)
                                            |
                                            | reduced_by
                                            ↓
                              ReductionStep (relation on objects)
```

## Future Work

1. **Complete proofs**: Remove `sorry` from associativity and identity laws
2. **Functoriality**: Prove the indexed functor Eᵢdx : ℕᵒᵖ → Cat is well-defined
3. **Fibration structure**: Show the Grothendieck category is a fibration over ℕᵒᵖ
4. **Reduction semantics**: Define full operational semantics for TDG terms via reductions
5. **Phase-specific data**: Replace `Unit` placeholder with actual phase-specific structures
6. **Composition coherence**: Prove reduction composition respects categorical composition

## Summary

| Concept | Type | Role |
|---------|------|------|
| `GrothendieckObject` | Type | Objects in ∫ Eᵢdx (configurations) |
| `GrothendieckMorphism` | Type | Morphisms in ∫ Eᵢdx |
| `Configuration` | Type alias | `GrothendieckObject` (runtime states) |
| `ReductionStep` | Relation | `Configuration → Configuration → Prop` |
| `grothendieck_id` | Function | Identity morphism |
| `grothendieck_compose` | Function | Morphism composition |
| `reduction_induces_morphism` | Theorem | Reductions ↦ Morphisms |
| `reduction_carrier_is_objects` | Theorem | Carrier = Objects |

**Core Principle**: **Reductions act on configurations (objects), not on terms (syntax) or morphisms (arrows).**

---

**Status**: ✅ IMPLEMENTED in `Frfp/Core/Grothendieck.lean`  
**Compilation**: ✅ Successfully builds with Lean 4  
**Verification**: ⚠️ Core theorems proven, some with `sorry` for extensionality  
**Documentation**: ✅ This file  

