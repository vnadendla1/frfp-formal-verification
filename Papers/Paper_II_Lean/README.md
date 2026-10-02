# Paper II Lean reproducibility package

This package supports *Conditions for Recovering the Explicit-Tacit Separation*. It uses Lean 4.29.0, pinned by `lean-toolchain`, and the Lean standard distribution; no third-party package is required by these source files.

## Contents and verification scope

- `ETSplit.lean`: neutral factorization, correctness quotient, representation, conditional recovery and core witnesses; 26 audited theorem declarations.
- `FirstPrinciplesRevision/RecoveryDomain.lean` and `RecoveryDomainChecks.lean`: recovery restricted to the selected comparison domain; 7 audited results.
- `FirstPrinciplesRevision/ConcreteRecovery.lean`: finite safety/authorization comparison, typed interface, alignment conditions, modal classifications and failure witnesses; 21 audited results.
- `scripts/AuditETSplit.lean`, `AuditRecoveryDomain.lean`, `AuditConcreteRecovery.lean`: dependency audits of all 54 entries.
- `reports/`: package build and dependency-audit logs.
- `SHA256SUMS`: hashes identifying packaged sources, configuration, instructions and logs.

The shared `FirstPrinciplesRevision` namespace is retained, but this package contains only Paper II's recovery modules, not Paper I's full library. The criterion-to-task interpretation in manuscript §8 is not covered by these Lean checks. The finite example is stipulated; this study has no empirical dataset.

## Reproduce

Install Lean through elan, then run from this directory:

```sh
lake build
lake env lean scripts/AuditETSplit.lean
lake env lean scripts/AuditRecoveryDomain.lean
lake env lean scripts/AuditConcreteRecovery.lean
```

The audit scripts produce 26, 7 and 21 dependency entries respectively. Their foundations may include `propext`, `Classical.choice` and `Quot.sound`; there should be no project-specific axioms or proof placeholders. Successful compilation and these dependency logs establish only the stated conditional formal results.
