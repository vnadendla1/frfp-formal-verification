# Paper III: actor-neutral theory and conditional Human authority

Run from the package root with the pinned Lean 4.29.0 toolchain:

```
lake build PaperIII
lake env lean scripts/AuditPaperIII.lean
python3 scripts/verify_paper_iii_published.py
```

Build the explicit PaperIII target. The preserved workspace Lake configuration names other libraries outside this isolated package. Mathlib is pinned by lake-manifest.json; lake exe cache get may download its compiled cache for a fresh installation.

The current audit covers 95 declarations across 36 claim groups: the retained 69-result core, 24 authority declarations, and two reused Paper II recovery declarations. Only propext, Classical.choice, and Quot.sound are allowed foundational dependencies. The current claim map supplies manuscript numbering; comments in older source files retain historical numbering.

HumanAuthority.lean proves root existence, conditional Machine valid-root exclusion, Human classification, the combined recovery interface, an optional singleton result, plural authority without a principal, permitted delegated closure, and negative controls including unrooted cycles. It reuses ETSplit's neutral recovery theorem. No main FRFP or legacy BeyondSpecification module is imported.

The authority result needs valid occurrence existence, valid-root-grounded standing, type-neutral valid-root contract competence, faithful bearing, a selected recovered Tacit condition, an Explicit-only Machine model, and exhaustive interpreted categories. None is established for every collaboration. Paper I's role count does not supply successful completion or competence of every root. Paper II does not universally identify authorization as Tacit or reserve its realization for humans. The plural witness allows a Machine delegate to close a root-supplied decision while two Human roots remain and the singleton principal selector is undefined.

SOURCE_MANIFEST.json identifies the current distributed sources. Its source identifier is SHA-256 of the sorted file/hash mapping serialized as compact JSON. The current verifier checks that identifier, every file hash, the build, claim coverage, and foundational dependencies. The old verify_paper_iii.py belongs to historical workspace provenance, is not needed by this package, and must not replace these commands.

The separate Python revision machine in the structural supplement is an exhaustive executable check, not a joint Lean proof or an empirical dataset. GitHub access does not constitute a persistent archival DOI or journal submission.

ValidRoot is nominal charter membership conjoined with CanBear. ValidRoots filters the primitive roots; neither validity nor CanBear mentions participant type. RootCompetence is removed. Rroot is the independently available candidate-root basis; supplied delegated decisions are occurrence inputs. A mixed nominal charter includes a Machine that fails validity while valid Human authority holds. Principal still selects nominal singleton roots.

The Machine-exclusion declaration is `HumanAuthority.no_machine_valid_root`; it does not exclude nominal Machine roots. `BearerStanding` projects executor standing from an actual authorization/closure occurrence with state- and obligation-indexed valid standing. The realized-governance interpretation `ValidGoverned` is occurrence existence, so Completion is its elimination rule. The abstract core also allows another governance interpretation when the application separately proves Completion. The plural witness instantiates the occurrence projection; neither interpretation derives liveness for pending obligations.
