# FRFP Module Dependencies

## Overview

This document maps the dependency structure of the FRFP formalization, showing which modules import from which others. Understanding this hierarchy is essential for navigating the codebase and maintaining architectural integrity.

## Dependency Principles

1. **Kernel is Immutable**: No module can extend or modify the Kernel
2. **Acyclic Dependencies**: No circular imports allowed (enforced by Lean)
3. **Layered Architecture**: Modules build up from foundation to complex structures
4. **Minimal Coupling**: Each module imports only what it needs

## Dependency Layers

```
Layer 0 (Foundation):
  Kernel.lean (imports: std only)

Layer 1 (Core Theory):
  Phase1.lean       (imports: Kernel)
  TDG.lean          (imports: Kernel)
  Grothendieck.lean (imports: Kernel)
  Navigation.lean   (imports: Kernel)
  FloatTheory.lean  (imports: std only)

Layer 2 (Semantic Foundation):
  Probability.lean      (imports: Kernel, FloatTheory)
  EpistemicAlgebra.lean (imports: Kernel, TDG)
  Semantics.lean        (imports: Kernel, TDG, Grothendieck)

Layer 3 (Dynamic & Operational):
  DynamicLayer.lean         (imports: Kernel, EpistemicAlgebra, Probability, FloatTheory)
  OperationalSemantics.lean (imports: Kernel, TDG, Semantics)
  ExplicitArtifact.lean     (imports: Kernel, TDG, OperationalSemantics)

Layer 4 (Correctness & Properties):
  SemanticCorrectness.lean (imports: Kernel, Semantics, DynamicLayer)
  Confluence.lean          (imports: Kernel, TDG, OperationalSemantics)
  TacitDependence.lean     (imports: Kernel, TDG, DynamicLayer)

Layer 5 (Multi-Agent):
  InstitutionalLayer.lean (imports: Kernel, DynamicLayer, EpistemicAlgebra)
  CollectiveLayer.lean    (imports: Kernel, DynamicLayer, InstitutionalLayer, ExplicitArtifact)
  Governance.lean         (imports: Kernel, InstitutionalLayer, CollectiveLayer)
```

## Module-by-Module Import Analysis

### Layer 0: Foundation

#### Kernel.lean
**Imports**: None (only Lean std library)
**Exports**: `Object`, `Primitive`, `Morphism`, `Pipeline`, `Ecat`, `Tcat`, ETS axioms
**Purpose**: Immutable foundation - defines C0, primitives, typing rules
**Dependencies**: None
**Dependents**: ALL other modules (directly or transitively)

---

### Layer 1: Core Theory

#### Phase1.lean
**Imports**: `Kernel`
**Exports**: `Phase1Framework`, `minimality`, `phase1_initiality`
**Purpose**: Proves Theorems A.32 (Minimality) and A.34 (Initiality)
**Dependencies**: `Kernel`
**Dependents**: `Frfp.lean` (main export)

#### TDG.lean
**Imports**: `Kernel`
**Exports**: `TDGShape`, `TDGPipeline`, `free_explicit_algebra`, tacit operations (TE, HFD)
**Purpose**: Task Decomposition Grammar and free category construction
**Dependencies**: `Kernel`
**Dependents**: `EpistemicAlgebra`, `Semantics`, `OperationalSemantics`, `ExplicitArtifact`, `Confluence`, `TacitDependence`

#### Grothendieck.lean
**Imports**: `Kernel`
**Exports**: `GrothendieckObject`, `GrothendieckMorphism`, indexed category `Eᵢdx`
**Purpose**: Grothendieck construction for phase-indexed categories
**Dependencies**: `Kernel`
**Dependents**: `Semantics`

#### Navigation.lean
**Imports**: `Kernel`
**Exports**: `NavigationConstraint`, `admissible_path`, `reachability`
**Purpose**: Navigation constraints in state space (Definition A.10)
**Dependencies**: `Kernel`
**Dependents**: None (standalone structural definition)

#### FloatTheory.lean
**Imports**: None (only Lean std library)
**Exports**: IEEE 754 axioms, float bounds, monotonicity lemmas
**Purpose**: Foundational axioms for float arithmetic used in degradation
**Dependencies**: None
**Dependents**: `Probability`, `DynamicLayer`

---

### Layer 2: Semantic Foundation

#### Probability.lean
**Imports**: `Kernel`, `FloatTheory`
**Exports**: `StoppingTime`, `survival`, `hazard`, `safe_horizon`
**Purpose**: Stopping times and probability measures (Definition A.9.2)
**Dependencies**: `Kernel`, `FloatTheory`
**Dependents**: `DynamicLayer`

#### EpistemicAlgebra.lean
**Imports**: `Kernel`, `TDG`
**Exports**: `EpistemicState`, `BeliefRevision`, knowledge operators
**Purpose**: Epistemic algebra structures (Definition A.9)
**Dependencies**: `Kernel`, `TDG`
**Dependents**: `DynamicLayer`, `InstitutionalLayer`

#### Semantics.lean
**Imports**: `Kernel`, `TDG`, `Grothendieck`
**Exports**: `DenotationalSemantics`, semantic functions for pipelines
**Purpose**: Denotational semantics (Definition A.9.4)
**Dependencies**: `Kernel`, `TDG`, `Grothendieck`
**Dependents**: `SemanticCorrectness`, `OperationalSemantics`

---

### Layer 3: Dynamic & Operational

#### DynamicLayer.lean
**Imports**: `Kernel`, `EpistemicAlgebra`, `Probability`, `FloatTheory`
**Exports**: `TacitState`, `degradation`, `GroundedTacitState`
**Purpose**: Dynamic layer semantics with δ-degradation (Definition A.9.3)
**Dependencies**: `Kernel`, `EpistemicAlgebra`, `Probability`, `FloatTheory`
**Dependents**: `SemanticCorrectness`, `TacitDependence`, `InstitutionalLayer`, `CollectiveLayer`

**Key Property**: Uses FloatTheory for 15+ proofs about degradation monotonicity

#### OperationalSemantics.lean
**Imports**: `Kernel`, `TDG`, `Semantics`
**Exports**: `Run`, `Trajectory`, `run_trajectory_link` (Remark A.104)
**Purpose**: Operational semantics and run-trajectory correspondence (Definition A.11)
**Dependencies**: `Kernel`, `TDG`, `Semantics`
**Dependents**: `ExplicitArtifact`, `Confluence`

**Status**: 100% complete (all structural theorems proven)

#### ExplicitArtifact.lean
**Imports**: `Kernel`, `TDG`, `OperationalSemantics`
**Exports**: `SameSyn`, `SameNF`, syntactic vs. semantic identity
**Purpose**: Two notions of artifact identity (Definition A.11.4)
**Dependencies**: `Kernel`, `TDG`, `OperationalSemantics`
**Dependents**: `CollectiveLayer`

**Key Theorems**: `sameNF_symm`, `sameNF_trans` (equivalence relation properties)

---

### Layer 4: Correctness & Properties

#### SemanticCorrectness.lean
**Imports**: `Kernel`, `Semantics`, `DynamicLayer`
**Exports**: `semantic_correctness` (Theorem A.9.5)
**Purpose**: Proves semantic correctness theorem
**Dependencies**: `Kernel`, `Semantics`, `DynamicLayer`
**Dependents**: None (top-level theorem)

#### Confluence.lean
**Imports**: `Kernel`, `TDG`, `OperationalSemantics`
**Exports**: `confluence`, `diamond_property`, `church_rosser`
**Purpose**: Confluence properties (Definition A.11.3)
**Dependencies**: `Kernel`, `TDG`, `OperationalSemantics`
**Dependents**: None (top-level property)

#### TacitDependence.lean
**Imports**: `Kernel`, `TDG`, `DynamicLayer`
**Exports**: `TacitDependenceGraph`, dependency tracking structures
**Purpose**: Tacit dependence graphs and implicit knowledge flow
**Dependencies**: `Kernel`, `TDG`, `DynamicLayer`
**Dependents**: None (analysis structure)

---

### Layer 5: Multi-Agent

#### InstitutionalLayer.lean
**Imports**: `Kernel`, `DynamicLayer`, `EpistemicAlgebra`
**Exports**: `Population`, `PopMorphism`, `policy_alignment`
**Purpose**: Institutional layer with population structures
**Dependencies**: `Kernel`, `DynamicLayer`, `EpistemicAlgebra`
**Dependents**: `CollectiveLayer`, `Governance`

#### CollectiveLayer.lean
**Imports**: `Kernel`, `DynamicLayer`, `InstitutionalLayer`, `ExplicitArtifact`
**Exports**: `Agent`, `Population`, `CommunicationGraph`, `collective_hallucination_detection`
**Purpose**: Collective layer with multi-agent dynamics (Definition A.9.6)
**Dependencies**: `Kernel`, `DynamicLayer`, `InstitutionalLayer`, `ExplicitArtifact`
**Dependents**: `Governance`

**Key Feature**: Most complex dependency structure (4 direct imports)

#### Governance.lean
**Imports**: `Kernel`, `InstitutionalLayer`, `CollectiveLayer`
**Exports**: `GovernanceFramework`, `Policy`, audit trail structures
**Purpose**: Governance structures and regulatory compliance
**Dependencies**: `Kernel`, `InstitutionalLayer`, `CollectiveLayer`
**Dependents**: None (top-level application)

---

## Import Hierarchy Visualization

```
                                    Kernel.lean
                                        │
                    ┌───────────────────┼───────────────────┐
                    │                   │                   │
                Phase1.lean         TDG.lean        Grothendieck.lean
                                        │                   │
                                        │                   │
                    ┌───────────────────┼───────────────────┘
                    │                   │
            EpistemicAlgebra.lean   Semantics.lean
                    │                   │
                    │                   └──────────────┐
                    │                                  │
        ┌───────────┴──────────┐          OperationalSemantics.lean
        │                      │                      │
   DynamicLayer.lean   (+ Probability,         ExplicitArtifact.lean
        │                FloatTheory)                 │
        │                      │                      │
        │          ┌───────────┴────────┐             │
        │          │                    │             │
        │   SemanticCorrectness    Confluence         │
        │                                             │
        ├─────────────────┬───────────────────────────┘
        │                 │
   TacitDependence   InstitutionalLayer.lean
                          │
                          │
                    CollectiveLayer.lean
                          │
                          │
                    Governance.lean


FloatTheory.lean (independent) ──────┐
                                     │
Navigation.lean (independent)        ├──> Used by higher layers
                                     │
Probability.lean ─────────────────── ┘
```

## Dependency Rules

### 1. No Upstream Dependencies
❌ **FORBIDDEN**: Higher layers cannot be imported by lower layers
❌ **FORBIDDEN**: `Kernel` cannot import anything except std library
❌ **FORBIDDEN**: Circular dependencies at any level

### 2. Minimal Import Philosophy
✅ **GOOD**: Import only what you directly use
✅ **GOOD**: Keep dependency chains short when possible
✅ **GOOD**: Document why each import is needed

### 3. Transitive Dependencies
- **Note**: When importing a module, you get access to all its transitive imports
- Example: `CollectiveLayer` imports `InstitutionalLayer`, which imports `DynamicLayer`, which imports `Kernel`
- Therefore: `CollectiveLayer` has transitive access to `Kernel`, `DynamicLayer`, etc.

## Critical Dependencies

### FloatTheory Usage
- **Used by**: `Probability`, `DynamicLayer`
- **Purpose**: Provides axioms for float arithmetic (IEEE 754)
- **Why needed**: 15+ proofs in `DynamicLayer` depend on float bounds and monotonicity
- **Axioms**: 32 (this is by design - foundational assumptions about float arithmetic)

### Probability Usage
- **Used by**: `DynamicLayer`
- **Purpose**: Stopping times, survival functions, hazard rates
- **Why needed**: Dynamic layer needs probabilistic termination guarantees
- **Mathlib Status**: 5 theorems await Mathlib integration (measure theory)

### TDG Usage
- **Used by**: 6 modules (`EpistemicAlgebra`, `Semantics`, `OperationalSemantics`, `ExplicitArtifact`, `Confluence`, `TacitDependence`)
- **Purpose**: TDG grammar and free category structure
- **Why critical**: Central to FRFP's syntactic structure
- **Status**: 100% complete (3 theorems, 0 axioms, 0 sorry)

## Adding New Modules

When adding a new module to FRFP:

1. **Identify Layer**: Determine which layer it belongs to based on what it imports
2. **Minimize Imports**: Only import what you directly need
3. **Check Cycles**: Ensure no circular dependencies (Lean will error if there are)
4. **Update Frfp.lean**: Add import statement to main entry point
5. **Document Dependencies**: Update this file with the new module's dependencies
6. **Test Build**: Run `lake build` to ensure all dependencies resolve

## Example: Adding a Hypothetical Module

Suppose you want to add `Verification.lean` that proves properties about the entire system:

```lean
-- Verification.lean
import Frfp.Core.Kernel
import Frfp.Core.Phase1
import Frfp.Core.SemanticCorrectness
import Frfp.Core.Confluence

namespace Frfp.Core.Verification
-- Your verification theorems here
end Frfp.Core.Verification
```

**Layer**: Layer 5 (depends on Layer 4 modules)
**Update**: Add `import Frfp.Core.Verification` to `Frfp.lean`
**Document**: Add entry to this file under Layer 5

## Dependency Metrics

| Metric | Value |
|--------|-------|
| Total Modules | 18 (Core) + 2 (Frfp.lean, Example) |
| Average Imports per Module | ~2.5 |
| Max Import Depth | 5 layers |
| Modules with 0 imports | 2 (Kernel, FloatTheory) |
| Modules with 4+ imports | 1 (CollectiveLayer) |
| Most Depended-Upon Module | Kernel (18 dependents) |
| Least Depended-Upon Modules | Navigation (0 dependents) |

## Checking Dependencies

To check what a module imports:

```bash
# Direct imports
grep "^import Frfp.Core" Frfp/Core/ModuleName.lean

# All imports in the project
find Frfp/Core -name "*.lean" -exec grep -H "^import" {} \;
```

To visualize the dependency graph:

```bash
# Using Lean's import graph tool (requires importGraph package)
lake exe graph

# Manual inspection
grep -r "^import Frfp.Core" Frfp/Core/*.lean | sort
```

## Conclusion

The FRFP module dependency structure is:
- ✅ **Acyclic**: No circular dependencies
- ✅ **Layered**: Clear stratification from foundation to applications
- ✅ **Minimal**: Each module imports only what it needs
- ✅ **Maintainable**: Easy to understand and extend
- ✅ **Type-Safe**: Lean enforces dependency correctness at compile time

**Key Insight**: The dependency structure mirrors the mathematical structure of the paper, with the Kernel as the immutable foundation and higher layers building up the theory progressively.
