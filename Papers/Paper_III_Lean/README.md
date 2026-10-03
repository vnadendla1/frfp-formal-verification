# Paper III: principalhood, adequacy, and constitutive revision

Formal companion to V. Nadendla’s *Governing Human–AI Collaboration*. This standalone package preserves the checked Lean sources and pinned dependencies of the Paper III reproduction bundle. It extends Paper I’s independently supplied authority specification; it does not derive principal identity from information, computational power, or human/artificial status.

## Build and declaration audit

Install Lean through elan, then run from this directory:

```bash
lake exe cache get
lake build PaperIII
lake env lean scripts/AuditPaperIII.lean
python3 scripts/check_published_sources.py
```

The pinned toolchain is Lean 4.29.0. Build the explicit `PaperIII` target: the preserved workspace Lake configuration also names other libraries that are outside this isolated package. The audit covers 69 declarations across 27 claim groups. Its only foundational dependencies are `propext`, `Classical.choice`, and `Quot.sound`. Governance assumptions remain theorem premises; these proofs do not establish empirical truth, charter legitimacy, or application-specific evidence.

The source identifier is `0cc0f517f0770d6802800a3ada09c6a16969f3eacfc85aed6c0857e24ac25f82`. `SOURCE_MANIFEST.json` records the unchanged core file hashes. The original core archive and structural supplement, with their hash records, are in `reports/`.

## Separate finite realization

```bash
python3 manuscripts/restructure/check_paper_iii_finite.py
```

The executable model exhaustively checks 3,456 operational records, 96 reachable states, 2,688 reachable transitions, and four complete traces. This Python check is separate from the 69-declaration Lean audit; it is neither a joint-machine Lean theorem nor empirical validation. The structural supplement also includes the architecture figure and drawing script.

## Historical provenance scope

The preserved `scripts/verify_paper_iii.py` is a historical workspace verifier. It depends on reviewed upstream files and their historical locations, which are not part of this standalone package. A changed reviewed input in the original workspace prevents its historical provenance check from passing. Do not use it as this package’s reproduction command or interpret the source/build audit as resolving that discrepancy. Use the commands above for the published core.

GitHub provides public source access. No persistent archival DOI is assigned to this Paper III artifact.
