# Governing Human–AI Collaboration from First Principles III: Actor-Neutral Principalhood, Adequacy, and Constitutive Revision

Use the pinned Lean 4.29.0 toolchain. From the package root run:

```
lake build PaperIII
lake env lean scripts/PaperIIIDependencyTests.lean
lake env lean scripts/AuditPaperIII.lean
python3 scripts/verify_paper_iii_published.py
```

The audit covers 108 declarations in 40 claim groups and 34 distributed files. Allowed foundational dependencies are propext, Classical.choice, and Quot.sound; no project-specific global axioms or proof placeholders are permitted. Build the explicit PaperIII target; the workspace Lake file also names libraries outside this package. Pinned Mathlib dependencies are recorded in lake-manifest.json.

The core Machine-exclusion theorem consumes only nonrepresentation, faithful bearing, and confinement. spectral_modal_missing uses one forward spectral inclusion, Tacit elimination, selected-domain membership, and basis admission; it uses no correctness inclusions, reverse spectral inclusion, or Explicit characterization. Recovery packages the full sufficient route separately. The dependency tests compile these reduced interfaces without a Recovery object or Paper I role package.

human_authority_at_episode exposes fixed-episode parameters; no persistence across changed premises is asserted. ValidRoot combines nominal standing and CanBear. Classification is required for valid roots in the eligible application domain. Principal selects nominal singleton roots. Human is an interpretation permitting individual, collective, and institutional participants.

ClosureBridge is an application implication from valid authorization/closure occurrences to participant-level valid closure. LocalBasisComplete connects declared local sources to the complete independent representation; the application must establish that interface from its source/access calculus and interpretation map. The finite witness checks a first-coordinate local basis and a nonlocal Human-issued decision payload. Delegated closure is a compound occurrence with root-grounded executor standing. Authorization relevance is checked independently; GovInd is not mandatory for Human authority.

StandingSensitiveContinuation is the charter postulate for equal-content occurrences with different standing and successor sets. It is distinct from Paper I’s assessment–closure result. Negative controls cover missing grounding, confinement, faithful bearing, exhaustive classification, competence, and the occurrence bridge.

SOURCE_MANIFEST.json records source hashes and their canonical aggregate identifier. The verifier checks hashes, compilation, dependency tests, full claim coverage, and permitted foundational axioms. The structural supplement supplies separate exhaustive Python revision/settlement and authority-boundary checks; these constructed models are not empirical validation or a joint Lean transition-system proof.
