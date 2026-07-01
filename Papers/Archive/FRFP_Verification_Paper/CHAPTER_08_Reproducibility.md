# Chapter 8: Reproducibility Package

**Paper**: FRFP Lean Formal Verification  
**Chapter**: 8 of 8  
**Source documents**: [Appendix A](APPENDIX_A_Axiom_Audit.md) (full axiom audit), [Appendix B](APPENDIX_B_Architecture.md) (module map + dependencies), [Appendix E](APPENDIX_E_Naming_Conventions.md) (naming conventions)

---

## 8.1 Environment Requirements

| Component | Required version |
|---|---|
| Lean | 4.29.0 (pinned in `lean-toolchain`) |
| Mathlib | v4.29.0 (pinned in `lake-manifest.json`) |
| Lake (build system) | Bundled with Lean |
| OS | Linux or macOS |
| RAM | ≥ 8 GB recommended (Mathlib compilation) |
| Disk | ≥ 4 GB (Mathlib build cache) |

The exact Lean and Mathlib versions are pinned in repository files:
- `lean-toolchain`: `leanprover/lean4:v4.29.0`
- `lake-manifest.json`: Mathlib at commit hash for v4.29.0

---

## 8.2 Build Instructions

**Step 1: Install Lean 4**
```bash
curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
source ~/.profile
```

**Step 2: Enter repository**
```bash
cd FRFP_Math_Verification/
```

**Step 3: Download Mathlib cache (avoids 4-hour recompile)**
```bash
lake exe cache get
```

**Step 4: Build all modules**
```bash
lake build
```

Expected output: `Build completed successfully. 3305 jobs.`

**Step 5: Verify zero sorry**
```bash
grep -r '\bsorry\b' Frfp/ Example/ FRFPReport.lean \
  | grep -v '^\s*--' | wc -l
```
Expected output: `0`

**Step 6: Run executable report**
```bash
lake exe FRFPReport
```

---

## 8.3 Module Map

### Core Library (`Frfp/Core/`)

| Module | Lines | Axioms | Theorems | Description |
|---|---|---|---|---|
| Kernel.lean | ~200 | 11 | 12 | Object types, Primitive, core typing theorems |
| FloatTheory.lean | ~400 | 53 | 66 | IEEE 754 float axioms + derived theorems |
| Probability.lean | ~300 | 21 | 15 | Stopping times, hazard rates |
| ProbabilityProven.lean | ~250 | 0 | 5 | Five fully-proven probability theorems |
| TacitDependence.lean | ~200 | 8 | 12 | Tacit dependency irreversibility |
| ExplicitArtifact.lean | ~180 | 6 | 10 | Explicit artifact properties |
| ImmutabilityProof.lean | ~150 | 4 | 8 | Immutability under pipeline execution |
| ConfluenceProof.lean | ~350 | 18 | 22 | Church-Rosser via Newman's Lemma |
| OperationalSemantics.lean | ~400 | 12 | 18 | runToω bijection, operational rules |
| SemanticCorrectness.lean | ~300 | 6 | 15 | Normal forms, observable invariance |
| NavigationGroupoid.lean | ~250 | 7 | 10 | Navigation morphisms, groupoid action |
| Grothendieck.lean | ~450 | 5 | 20 | Grothendieck construction, configurations |
| CollectiveLayer.lean | ~350 | 4 | 18 | Multi-agent results, consensus impossibility |
| InteractionProtocol.lean | ~200 | 8 | 12 | IL, AR, MD, NTER, CSC protocol axioms |
| FallbackMechanism.lean | ~180 | 4 | 8 | Fallback protocol properties |
| DynamicLayer.lean | ~300 | 5 | 14 | Entropy drift, population dynamics |
| TDG.lean | ~200 | 3 | 10 | Tacit-dependent grounding properties |
| Minimality.lean | ~150 | 0 | 6 | Each primitive is necessary |
| Initiality.lean | ~200 | 0 | 8 | FRFP is unique canonical framework |
| SemanticGrounding.lean | ~250 | 4 | 10 | Grounding properties |
| Semantics.lean | ~200 | 3 | 10 | Top-level semantic integration |

### Minimal Basis (`Frfp/Minimal/`)

| Module | Lines | Description |
|---|---|---|
| ReducedBasis.lean | ~250 | 7-primitive basis, source anchors, derivability map, skeletons |
| BasisConsequences.lean | ~180 | 8 direct consequence theorems |
| BasisSweep.lean | ~300 | Stronger admissibility model; 3 novel theorems |

### Case Studies (`Example/`)

| Module | Lines | Description |
|---|---|---|
| Sepsis.lean | 351 | Executable sepsis consult pipeline with reduction |

### Root Files

| File | Description |
|---|---|
| Frfp.lean | Library entry point; imports all Core modules |
| FRFPReport.lean | Executable final verification report |
| lakefile.lean | Build configuration |
| lean-toolchain | Pins Lean version |
| lake-manifest.json | Pins Mathlib version |

---

## 8.4 Complete Theorem Inventory

### Kernel
- `no_morphism_T0_to_E0`, `RB_unique_boundary`, `AI_preserves_explicit`, `human_preserves_tacit`, `pipeline_compose`

### Reduced Basis (Minimal) — Derivable
- `ETS_derivable`, `RB_derivable`, `AE_derivable`, `MD_derivable`

### Reduced Basis (Minimal) — Consequences
- `tacit_source_classification`, `tacit_source_stays_tacit`, `ai_never_targets_tacit`, `ai_human_disjoint`, `unique_boundary_entry`, `IL_pairwise_intent_consistency`, `AR_no_unresolved_ambiguity`, `CSC_lock_is_monotone`

### Reduced Basis (Minimal) — Novel
- `first_unresolved_witness` ★
- `governance_safe_extension_theorem` ★
- `protocol_normal_form_theorem` ★

### Confluence
- `diamond_property`, `confluence`, `termination_explicit`

### Semantic Correctness
- `unique_nf_mod_nav`, `obsCorrect_invariant`, `nav_equivalence_is_equivalence`

### Probability (Fully Proven)
- `survival_product_formula`, `hazard_survival_relation`, `survival_monotone`, `expected_stop_is_hazard_sum`, `infinite_product_limit`

### Collective Layer
- `consensus_no_grounding`, `entropy_drift_monotone`, `population_collapse_bound`

### Minimality / Initiality
- Six Minimality theorems (one per primitive)
- Initiality theorem

★ = Novel; not present in published papers.

---

## 8.5 Build Validation Checklist

Before tagging a release:

- [ ] `lake build` exits 0 with 3305 jobs.
- [ ] `grep -r '\bsorry\b' Frfp/ Example/ | grep -v '\s*--'` returns empty.
- [ ] All 155 `axiom` declarations have citation comments.
- [ ] `lake exe FRFPReport` completes without error.
- [ ] `Frfp/Minimal/` modules compile independently.
- [ ] Sepsis example produces expected normalized form.

---

## 8.6 Publication Package and Documentation Scope

The publication package consists of this verification paper only — the eight chapters and five appendices (A through E) in the `Papers/FRFP_Verification_Paper/` directory. The following are **not** part of the publication package:

- `archive/` — working history and scratch files; excluded from publication.
- Root-level `.md` files in `FRFP_Math_Verification/` (e.g., `AXIOM_AUDIT.md`, `ARCHITECTURE.md`, `LEAN_VIBECODING_WHITEPAPER.md`) — these are source/working documents. Their content has been consolidated into the chapters and appendices of this paper:
  - `AXIOM_AUDIT.md` + `AXIOM_JUSTIFICATION.md` → Appendix A
  - `ARCHITECTURE.md` + `MODULE_DEPENDENCIES.md` → Appendix B
  - `LEAN_VERIFICATION_PROPOSALS.md` → Appendix C
  - `BIBLIOGRAPHY_GUIDE.md` + `references.bib` → Appendix D
  - `NAMING_CONVENTION.md` → Appendix E
  - All other source documents → consolidated into Chapters 1–7

**This paper (Chapters 1–8 + Appendices A–E) is the complete and self-contained documentation for the FRFP Lean verification.** No external files are required to understand or reproduce the results.

---

## 8.7 Known Limitations

1. **IEEE 754 axiom family**: 59 float arithmetic axioms assumed from IEEE standard, not derived from Lean's native float semantics. Convertible to theorems if Mathlib gains a complete IEEE 754 formalization.

2. **runToω injectivity and round-trip**: Axiomatized. A complete proof requires formalizing the probability space construction.

3. **Minimality proofs**: Witness models constructed manually; no automated model-finder used.

4. **Navigation groupoid inverses**: The groupoid inverse axiom is assumed from Mac Lane (1971). A computational inverse requires specifying the navigation graph.
