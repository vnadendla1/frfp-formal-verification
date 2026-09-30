# Paper I — Lean verification

Lean sources for *Governing Human–AI Collaboration from First Principles: Minimal Effective Role Structure* by V. Nadendla.

This is a standalone Lake package for the paper's conditional semantic-substitution lower bound and its finite operational realization. It includes the 15 transitive local source modules needed by the Paper I entry points. It does not import the repository's main FRFP library. The separate exploratory task-viability investigations are not part of this publication.

## Reproduce

Install [Elan](https://github.com/leanprover/elan), then from the repository root:

```sh
cd Papers/Paper_I_Lean
lake exe cache get
python3 scripts/verify.py
```

The toolchain is Lean 4.29.0. `lake-manifest.json` pins mathlib and its transitive dependency revisions. The verifier builds this package, audits 42 semantic declarations against standard Lean foundations, checks transitive proof dependencies, and checks the published source hashes. Verification results are written to `reports/`.

To build without the audit:

```sh
lake build
```

## Main files

- [SemanticRoles.lean](FirstPrinciplesRevision/SemanticRoles.lean): relational substitution, general regime separation, information and obligation-effect separators, all 15 pairs, and the six-class lower bound.
- [SemanticOperational.lean](FirstPrinciplesRevision/SemanticOperational.lean): reachable operational realization and semantic six-class instantiation.
- [SemanticChecks.lean](FirstPrinciplesRevision/SemanticChecks.lean): supporting checks and counterexamples to stronger claims.
- [AuditSemanticRoles.lean](scripts/AuditSemanticRoles.lean): declaration-level axiom audit.
- [CheckSemanticDependencies.lean](scripts/CheckSemanticDependencies.lean): checks that the semantic proofs consume the general regime-separation theorem and avoid the earlier preservation-based proof route.
- [Source hashes](source_sha256.json): identifies the copied source modules and audit scripts.

## Scope

The lower bound is conditional on the specified contracts, information restrictions, and sound effective equivalence. The finite realization proves satisfiability of those specifications, not their applicability to an arbitrary deployed system. The proof counts semantic contract classes, not people, agents, components, or execution events.

Some supporting definitions from earlier formal developments remain in the transitive import graph. The dependency audit checks that the semantic theorem itself does not rely on the earlier phase/region-preservation argument.
