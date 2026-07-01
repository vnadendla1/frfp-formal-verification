# Appendix B: Module Architecture and Dependency Map

**Paper**: FRFP Lean Formal Verification  
**Appendix**: B  
**Source**: ARCHITECTURE.md, MODULE_DEPENDENCIES.md

---

## B.1 Architectural Principles

The FRFP formal library is organized around four immutability and isolation principles:

1. **Kernel is immutable**: No module can extend or modify `Kernel.lean`. It is the mathematical bedrock and cannot be edited without a full proof audit.
2. **Acyclic dependencies**: No circular imports exist. Lean enforces this at build time.
3. **Layered architecture**: Modules build strictly upward through five dependency layers.
4. **Minimal coupling**: Each module imports only what it directly needs, not entire layers.

---

## B.2 Module Hierarchy

```
Frfp/
├── Core/
│   ├── Kernel.lean              [~200 lines]  IMMUTABLE FOUNDATION
│   │   Objects: ∅, E0, T0
│   │   Primitives: enumerated with typed source/target
│   │   Key theorems: no_morphism_T0_to_E0, RB_unique_boundary,
│   │                 AI_preserves_explicit, pipeline_compose
│   │   Axioms: 0 (all theorems)
│   │
│   ├── Phase1.lean              [~160 lines]  MINIMALITY & INITIALITY
│   │   Theorem A.32: each primitive is necessary
│   │   Theorem A.34: FRFP is the unique canonical Phase-1 framework
│   │   Axioms: 0
│   │
│   ├── TDG.lean                 [~189 lines]  FREE CATEGORY & TDG
│   │   Task Decomposition Grammar and free category construction
│   │   Tacit monoid structure
│   │   Axioms: 0
│   │
│   ├── Grothendieck.lean        [~255 lines]  GROTHENDIECK CONSTRUCTION
│   │   Indexed category Eᵢdx : ℕᵒᵖ ⥤ Cat
│   │   Configuration objects and morphisms
│   │   Reduction on objects (not morphisms)
│   │   Axioms: 1 (Mac Lane extensionality)
│   │
│   ├── Navigation.lean          [~193 lines]  NAVIGATION CONSTRAINTS
│   │   Admissible paths, reachability, groupoid structure
│   │   Axioms: 12 (ARS + CP/AE)
│   │
│   ├── FloatTheory.lean         [~400 lines]  IEEE 754 FOUNDATION
│   │   Float arithmetic and order axioms
│   │   66 derived theorems
│   │   Axioms: 53 (IEEE 754-2019)
│   │
│   ├── Probability.lean         [~300 lines]  STOPPING TIMES
│   │   Stopping times, hazard rates, survival functions
│   │   Axioms: 7 (Billingsley / Durrett)
│   │
│   ├── ProbabilityProven.lean   [~250 lines]  PROVEN PROBABILITY
│   │   5 fully proven probability theorems
│   │   Axioms: 0 (note: uses Mathlib)
│   │
│   ├── EpistemicAlgebra.lean    [~220 lines]  EPISTEMIC ALGEBRA
│   │   Knowledge operators, belief revision
│   │   Axioms: 0
│   │
│   ├── DynamicLayer.lean        [~797 lines]  DYNAMIC SEMANTICS
│   │   Tacit state evolution, δ-degradation
│   │   Entropy drift, population dynamics
│   │   Axioms: 20
│   │
│   ├── Semantics.lean           [~240 lines]  DENOTATIONAL SEMANTICS
│   │   Semantic functions, pipeline interpretation
│   │   Axioms: 6
│   │
│   ├── OperationalSemantics.lean [~400 lines] OPERATIONAL RULES
│   │   runToω bijection, reduction rules
│   │   Axioms: 9
│   │
│   ├── ExplicitArtifact.lean    [~180 lines]  ARTIFACT PROPERTIES
│   │   Explicit artifact transferability and typing
│   │   Axioms: 3
│   │
│   ├── SemanticCorrectness.lean [~300 lines]  SEMANTIC CORRECTNESS
│   │   Theorem A.7.7: normal forms + observable invariance
│   │   Axioms: 5
│   │
│   ├── TacitDependence.lean     [~300 lines]  TACIT DEPENDENCE
│   │   Irreversibility, HEG uniqueness
│   │   Axioms: 8
│   │
│   ├── InstitutionalLayer.lean  [~451 lines]  INSTITUTIONAL LAYER
│   │   Population structures, credence, policy alignment
│   │   Axioms: 3
│   │
│   ├── CollectiveLayer.lean     [~350 lines]  COLLECTIVE LAYER
│   │   Multi-agent coordination, consensus impossibility
│   │   Axioms: 8
│   │
│   ├── Governance.lean          [~150 lines]  GOVERNANCE
│   │   Governance predicates derived from collective layer
│   │   Axioms: 0
│   │
│   ├── RatLemmas.lean           [~200 lines]  RAT LEMMAS
│   │   Rational number lemmas (all via Mathlib)
│   │   Axioms: 0
│   │
│   └── ImmutabilityProof.lean   [~150 lines]  IMMUTABILITY
│       Pipeline immutability under execution
│       Axioms: 4
│
├── Minimal/
│   ├── ReducedBasis.lean        [~250 lines]  REDUCED BASIS
│   │   7-primitive minimal basis, source anchors, derivability map
│   │   Imports: Frfp.Core.Kernel only
│   │
│   ├── BasisConsequences.lean   [~180 lines]  DIRECT CONSEQUENCES
│   │   8 theorem-level consequences of the reduced basis
│   │
│   └── BasisSweep.lean          [~300 lines]  NOVEL THEOREMS
│       Stronger admissibility model
│       3 novel theorems: first_unresolved_witness,
│       governance_safe_extension_theorem,
│       protocol_normal_form_theorem
│
└── Example/
    └── Sepsis.lean              [351 lines]   CASE STUDY
        Executable sepsis consult pipeline with reduction
```

---

## B.3 Five-Layer Dependency Structure

```
Layer 0 — Foundation:
  Kernel.lean                   (imports: Lean std only)

Layer 1 — Core Theory:
  Phase1.lean                   (imports: Kernel)
  TDG.lean                      (imports: Kernel)
  Grothendieck.lean             (imports: Kernel)
  Navigation.lean               (imports: Kernel)
  FloatTheory.lean              (imports: Lean std only)

Layer 2 — Semantic Foundation:
  Probability.lean              (imports: Kernel, FloatTheory)
  EpistemicAlgebra.lean         (imports: Kernel, TDG)
  Semantics.lean                (imports: Kernel, TDG, Grothendieck)

Layer 3 — Dynamic & Operational:
  DynamicLayer.lean             (imports: Kernel, EpistemicAlgebra, Probability, FloatTheory)
  OperationalSemantics.lean     (imports: Kernel, TDG, Semantics)
  ExplicitArtifact.lean         (imports: Kernel, TDG, OperationalSemantics)

Layer 4 — Correctness & Properties:
  SemanticCorrectness.lean      (imports: Kernel, Semantics, DynamicLayer)
  Confluence.lean               (imports: Kernel, TDG, OperationalSemantics)
  TacitDependence.lean          (imports: Kernel, TDG, DynamicLayer)

Layer 5 — Multi-Agent:
  InstitutionalLayer.lean       (imports: Kernel, DynamicLayer, EpistemicAlgebra)
  CollectiveLayer.lean          (imports: Kernel, DynamicLayer, InstitutionalLayer,
                                           ExplicitArtifact)
  Governance.lean               (imports: Kernel, InstitutionalLayer, CollectiveLayer)
```

---

## B.4 Critical Dependencies

Three modules are depended upon by the most other modules:

| Module | Direct dependents | Indirect dependents |
|---|---|---|
| `Kernel.lean` | All 20 other modules | Entire tree |
| `FloatTheory.lean` | Probability, DynamicLayer | ~12 modules |
| `TDG.lean` | EpistemicAlgebra, Semantics, OperationalSemantics, ExplicitArtifact, Confluence, TacitDependence | ~8 modules |

**Implication for maintenance**: Any change to Kernel, FloatTheory, or TDG requires validating all dependents. The `lake build` command catches all failures automatically.

---

## B.5 Minimal Basis Isolation

`Frfp/Minimal/` modules are intentionally isolated:

- They import only `Frfp.Core.Kernel`, not the full library.
- This means they can be compiled independently of the full 3305-job Core build.
- Adding new Minimal modules does not risk breaking Core.

This isolation is enforced by the import statement at the top of each Minimal file:
```lean
import Frfp.Core.Kernel
-- Note: does NOT import Frfp.Core.*
```

---

## B.6 Adding New Modules

Rules for adding a new module:

1. Determine which layer it belongs to based on its dependencies.
2. Import only modules from lower layers (never same or higher layer).
3. Add the module to `lakefile.lean` if it is a new library target.
4. Run `lake build` and confirm zero new errors.
5. Update the dependency map in this appendix.
6. If the module introduces axioms, add them to the axiom audit (Appendix A).
