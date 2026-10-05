# Paper III: actor-neutral theory and conditional Human authority

Run from the package root with the pinned Lean 4.29.0 toolchain:

```
lake build PaperIII
lake env lean scripts/AuditPaperIII.lean
python3 scripts/verify_paper_iii_published.py
```

Build the explicit PaperIII target. The preserved workspace Lake configuration names other libraries outside this isolated package. Mathlib is pinned by lake-manifest.json; lake exe cache get may download its compiled cache for a fresh installation.

The current audit covers 90 declarations across 34 claim groups: the retained 69-result core, 19 new authority declarations, and two reused Paper II recovery declarations. Only propext, Classical.choice, and Quot.sound are allowed foundational dependencies. The current claim map supplies manuscript numbering; comments in older source files retain historical numbering.

HumanAuthority.lean proves root existence, conditional Machine-root exclusion, Human classification, the combined recovery interface, an optional singleton result, plural authority without a principal, permitted delegated closure, and negative controls including unrooted cycles. It reuses ETSplit's neutral recovery theorem. No main FRFP or legacy BeyondSpecification module is imported.

The authority result needs valid occurrence existence, root-grounded standing, all-root authorization competence, faithful bearing, a selected recovered Tacit condition, an Explicit-only Machine model, and exhaustive interpreted categories. None is established for every collaboration. Paper I's role count does not supply successful completion or competence of every root. Paper II does not universally identify authorization as Tacit or reserve its realization for humans. The plural witness allows a Machine delegate to close a root-supplied decision while two Human roots remain and the singleton principal selector is undefined.

SOURCE_MANIFEST.json identifies the current distributed sources. Its source identifier is SHA-256 of the sorted file/hash mapping serialized as compact JSON. The current verifier checks that identifier, every file hash, the build, claim coverage, and foundational dependencies. The old verify_paper_iii.py belongs to historical workspace provenance, is not needed by this package, and must not replace these commands.

The separate Python revision machine in the structural supplement is an exhaustive executable check, not a joint Lean proof or an empirical dataset. GitHub access does not constitute a persistent archival DOI or journal submission.
