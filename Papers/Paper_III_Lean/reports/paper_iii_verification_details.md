# Paper III verification details

Formal artifact: this package; SOURCE_MANIFEST.json identifies the exact distributed sources.

Formal artifact: this package. Source identifier: `9b5d8fd0a0159d37e9ea87723e85e313f32de94d5bae8d7a079e40271000ba57`. The theorem excluding Machine valid roots is `PaperIII.HumanAuthority.no_machine_valid_root`; nominal Machine roots remain permitted. `BearerStanding` projects an actual authorization/closure occurrence with valid standing to its executor. Under the realized-governance interpretation, Completion is definitional elimination, not liveness.

The current audit has 118 declarations in 43 mapped groups, covering all audited declarations; the manifest identifies 35 distributed source/configuration files. Definitions and constructed witnesses retain explicit application assumptions. Detailed supporting declarations are listed in `paper_iii_claim_map.json`.

**Table 8 supplement. Numbered results and their formal counterparts.**

| Paper result | Lean theorem | Formal assumptions | Module/source file | Required application evidence |
|---|---|---|---|---|
| Lemma 1 | AlgebraOfHumanAiCollaboration.factorsThrough_iff_kernelIncluded | Nonempty domain; maps with supplied codomains | AlgebraOfHumanAiCollaboration/Factorization.lean | Fixed comparison domain and map interpretations |
| Countermodel 1 | FiniteAdequacyModel.finite_specification_adequacy_incompleteness | Stated Boolean model and task predicate | PaperIII/ProblemAdequacy.lean | Possibility witness; no empirical frequency claim |
| Proposition 1 | discovery_without_admission | Boolean candidates; discovery true and admission false | PaperIII/Revision.lean | Discovery/admission distinction in the selected policy |
| Proposition 2 | inadequacy_without_particular_revision | Unit case; adequacy false; no candidate admitted | PaperIII/Revision.lean | Policy-specific repair/admission evidence |
| Proposition 3 | operational_update_preserves_principal | Product update fixes charter | PaperIII/Models.lean | Operational versus authorized charter-change interpretation |
| Countermodel 2 | GovernedMachine.distinct_contracts_one_implementation; GovernedMachine.assessment_open_closure_settles | One transition machine; contract/status observables | PaperIII/GovernedMachine.lean | Component witness; full Section 10 machine checked separately in Python |
| Theorem 1 | specificationAdequacyFactorization | Nonempty state space; supplied adequacy and representation | PaperIII/ProblemAdequacy.lean | Supplied adequacy criterion and operative representation |
| Theorem 2 | finite_capacity_nonexhaustibility | Surjective quotient; finite images; $|Q_A|>N$ and each image $\le N$ | PaperIII/Capacity.lean | Independent quotient, nonempty feasible family, strict inequality and uniform bound |
| Theorem 3 | admission_induced_insufficiency | Missing criterion; heterogeneous revised quotient; old sufficiency and admission as context | PaperIII/Revision.lean | Valid admission, actual dependent-family extension, fixed semantic domain |
| Theorem 4 | principal_through_origin | Origin Grounding; origin; no co-root | PaperIII/Principalhood.lean | Adopted origin rule, origin evidence, complete root set |
| Theorem 5 | rooted_through_grounding | Grounding; GovInd; realization | PaperIII/Principalhood.lean | Adopted grounding; independent basis and certificate; realization |
| Corollary 1 | principal_through_grounding | Theorem 5 premises; no co-root | PaperIII/Principalhood.lean | Theorem 5 evidence and exclusion of every distinct co-root |
| Theorem 6 | epistemicNonCollapse | Adequacy does not factor through R; Q does | PaperIII/NonCollapse.lean | Adequacy gap and availability of diagnostic content |
| Theorem 7 | standingSensitiveContinuationNonCollapse | Equal content; invalid/valid standing; StandingSensitiveContinuation | PaperIII/NonCollapse.lean | Standing validity and standing-sensitive continuation policy |
| Theorem 8 | assessmentClosureNonCollapse | Designated successor states with open/settled values | PaperIII/NonCollapse.lean | Status interpretation; contract-level preservation if claimed |
| Theorem 9 | HumanAuthority.roots_exist_of_valid_grounded_authorization | Completion; ValidRootGrounded; valid obligation | PaperIII/HumanAuthority.lean | Actual valid occurrence and valid-root permitted standing |
| Theorem 10 | HumanAuthority.no_machine_valid_root | Nonfactorability; confinement on valid roots; ValidRoot; faithful bearing | PaperIII/HumanAuthority.lean | Complete Machine basis and independently interpreted authorization contract |
| Theorem 11 | HumanAuthority.human_authority_at_episode; HumanAuthority.human_authority | Fixed episode; nonrepresentation; occurrence/standing/bearing bridges; exhaustive valid-root categories | PaperIII/HumanAuthority.lean | All Section 8 interfaces; Paper I role interpretation is supplied separately |
| Corollary 2 | HumanAuthority.singleton_human_principal_from_premises | All Human Authority Theorem premises; valid governance; nominal singleton roots | PaperIII/HumanAuthority.lean | Complete root-set analysis for the optional unique participant |
| Proposition 5 | DefaultAuthority.human_of_indistinguishable; human_valid_principal_of_indistinguishable | Valid allocation; equal views; required-Human witness; bearer, singleton and competence for actual principal | PaperIII/DefaultAuthority.lean | Complete timely allocation information and independently justified necessity |
| Corollary 3 | DefaultAuthority.human_default_of_class_coverage; human_valid_principals_of_class_coverage | Valid allocation; every realized class has a required-Human witness; actual-principal bridge where claimed | PaperIII/DefaultAuthority.lean | Specified scope; coverage; singleton and competent Human bearers |
| Plural witness and negative controls | HumanAuthority.Witness.plural_authority_without_principal; witnesses in Section 8.3 | Stated finite models and omitted interfaces | PaperIII/HumanAuthority.lean | Interpreted examples, not observed collaborations |

## Reproduction

Extract `Paper_III_Formal_Reproduction.zip` into a fresh directory. Run:

```
lake build PaperIII
lake env lean scripts/PaperIIIDependencyTests.lean
lake env lean scripts/AuditPaperIII.lean
python3 scripts/verify_paper_iii_published.py
```

The verifier checks every source hash, canonical manifest identity, build, 118-declaration axiom audit, complete coverage of 43 claim groups, and the renamed theorem. Allowed foundational dependencies are only propext, Classical.choice, and Quot.sound; the core contains no proof placeholders, project-specific global axioms, or native_decide.

Extract the structural supplement into another fresh directory and run `python3 manuscripts/restructure/check_paper_iii_finite.py`. Its SUPPLEMENT_MANIFEST.json records the hashes of the script, outputs, figure assets and enclosed core archive. The finite check covers 3,456 full states, 96 reachable states and 2,688 reachable transitions over four semantic worlds. It is separate from the Lean core; no joint transition-system composition is claimed.

Final submission extracted-source reproduction is recorded in `paper_iii_sections6_13_reproduction_20261006.json`; project outputs are rebuilt from the supplied sources. Archive SHA-256 values and the full file mapping are in `paper_iii_scientific_freeze_artifact.json` and `Paper_III_Supplement_Manifest.json`. 

Lean checks conditional consequences. It does not validate an application's charter legitimacy, complete information basis, independent specification, actual occurrence evidence or Human/collective/institutional interpretation. No archival DOI has been assigned to this artifact.

## Cross-paper interfaces and dependency tests

Proposition 4 is `HumanAuthority.spectral_modal_missing`: it uses selected-domain membership, forward spectrum inclusion R1, Tacit elimination, and basis admission. C1/C2/R2 and the Explicit characterization are absent from its type and proof. `scripts/PaperIIIDependencyTests.lean` checks this reduced interface and the core exclusion theorem without a Recovery object or Paper I role package. Full recovery supplies a sufficient route through `recovered_tacit_missing`.

`ClosureBridge` and `valid_close_of_occurrence` connect occurrence-level valid standing to participant-level closure as an application implication. `LocalBasisComplete` supplies the auditable equivalence between local source membership and factorization through the independent basis. The application still establishes the source/access closure and W-to-X interpretation. The toy model enumerates all 16 Boolean channels on four worlds; four are independent functions of u. The v decision crosses the root-issued payload boundary. Eight compound delegated occurrences preserve the basis, standing, closure bridge, and Human root provenance.

New controls isolate missing confinement, faithful bearing, nominal competence, and the occurrence bridge. Existing controls isolate missing root grounding and exhaustive classification. The compound closure witness is separate from the revision machine that expands its representation to identity.

## Domain and cross-paper consistency

Confinement and exhaustive classification are both quantified directly over valid roots. The dependency test checks the restricted signatures of no_machine_valid_root and human_authority. The fixed-episode theorem and singleton corollary use the same restriction. Audit counts remain 118 declarations, 43 groups, and 35 source/configuration files.

Paper I principal-grounded closure has IsPrincipal and ValidClose jointly in its antecedent. Boundary beta and contract B are distinct: the Python witness records a boundary-crossing payload and leaves B realization unasserted. Application evidence separately establishes acquisition and closure contracts and authorization relevance. These relevance tests are an application bridge rather than additional hypotheses in the exclusion proof.

The central result order is Theorem 9, Proposition 4, Theorem 10, Theorem 11, and Corollary 2. Manuscript sections are authority (8), application evidence (9), and finite realizations (10). Figure 2 displays relevance and the shared valid-root domain.

## Final manuscript interpretation audit

The Sections 6–13 revision preserves all theorem premises and proofs. Corollary 1 now explicitly describes nominal principalhood. Realizes remains the supplied distinction-bearing relation; independent-bearing and timing requirements are application interpretations, not extra encoded fields. Completion provides an actual standing-bearing occurrence, and ValidRootGrounded separately traces it to a competent nominal root. The mortgage and flight walkthroughs in Sections 10.5–10.6 are stipulated formal interpretations outside the Lean proofs and Python enumeration. The revision model uses A-semantic for the revised criterion and Q-record for artifact-dependent assessment. Subsequent action execution is outside the enumerated transition model.

Proposition 5 and Corollary 3 in Section 11.5 are verified in PaperIII/DefaultAuthority.lean. The audit has 118 declarations and 43 claim groups. Allocation labels are connected to actual Human valid principals only through explicit Human-bearer interpretation, nominal singleton standing, and CanBear premises.
