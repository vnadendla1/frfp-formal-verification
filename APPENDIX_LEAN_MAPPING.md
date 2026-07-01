# Complete Bidirectional Mapping: Appendix ↔ Lean Formalization

This document provides a comprehensive mapping between mathematical structures in the PDF Appendix A and their Lean implementations in the FRFP formalization.

**PDF Structure**: All appendices are in Appendix A with subsections A.1-A.12. Definition numbering is A11-A141.

---

## Table of Contents

1. [Appendix A.1-A.8: Static Epistemic Architecture](#appendix-a1-a8-static-epistemic-architecture)
2. [Appendix A.9: Epistemic Dynamics](#appendix-a9-epistemic-dynamics)
3. [Appendix A.10: Collective Epistemic Dynamics](#appendix-a10-collective-epistemic-dynamics)
4. [Appendix A.11: Impossibility Results](#appendix-a11-impossibility-results)
5. [Appendix A.12: Institutional and Governance Layer](#appendix-a12-institutional-and-governance-layer)
6. [Summary Statistics](#summary-statistics)

---

## Appendix A.1-A.8: Static Epistemic Architecture

### A.2: Foundations - Kernel Structure

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A11**: Ambient category Cfull | `inductive Object` | Kernel.lean:247 | 3 objects: E₀, T₀, ∅ |
| **Def A12**: Explicit-Tacit Separation (ETS) | `theorem no_morphism_T0_to_E0` | Kernel.lean:327 | Core axiom: no T₀ → E₀ morphisms |
| **Def A13**: Explicit modality | `def is_explicit_morphism` | Kernel.lean:319 | Morphisms ending at E₀ |
| **Def A14**: Tacit modality | `def is_tacit_morphism` | Kernel.lean:323 | Morphisms ending at T₀ |
| **Def A15**: Explicit category E | `def Ecat` | Kernel.lean:453 | Subtype of primitives targeting E₀ |
| **Def A16**: Tacit category T | `def Tcat` | Kernel.lean:456 | Subtype of primitives targeting T₀ |
| **Def A17**: Tacit primitives (TE, HFD) | `inductive Primitive` | Kernel.lean:268 | 6 total primitives |
| **Def A18**: Correctness quotient γ | `structure CorrectnessQuotient` | Phase1.lean:699 | Maps T → CorrectnessClass |
| **Def A19**: Boundary morphism RB | `Primitive.RB` | Kernel.lean:268 | E₀ → T₀ mapping |
| **Def A20**: Semantic RB functor | `def RB_sharp` | Semantics.lean:1509 | Functor version: Esem → T |
| **Def A21**: Interaction Protocols | `structure Phase0Constraints` | Phase1.lean:709 | IL, AR, MD, NTER, CSC |
| **Def A22**: Epistemic Spaces axioms | `def FRFP_Phase0` | Phase1.lean:717 | Complete phase-0 constraints |

### A.3: TDG and Free Explicit Category

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A23**: TDG signature | `inductive TDGPipeline` | TDG.lean:745 | AST for pipeline terms |
| **Def A24**: Free explicit category | `theorem free_explicit_algebra` | TDG.lean:797 | Universal property |
| - | `structure FreeCategoryProperty` | TDG.lean:783 | Formalized free construction |

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A25**: TDG shape | `inductive TDGShape` | TDG.lean:730 | Objects: Ø, E, T |
| **Def A26**: Shape of TDG term | `def pipeline_shape` | TDG.lean:754 | Extracts shape from pipeline |
| **Def A27**: Shape category S | `def shape_of_primitive` | TDG.lean:738 | Primitive → shape mapping |
| **Def A28**: Explicit reduction →E | `inductive ReductionStep` | Grothendieck.lean:1024 | Single reduction step |

### A.4: Navigation and Shapes

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A29**: Navigation category N₀ | `inductive NavPath` | Navigation.lean:1135 | Paths in reduction graph |
| **Def A30**: Navigation groupoid N | `def NavigationGroupoid` | Navigation.lean:1281 | Quotient by rewrite equivalence |
| **Def A31**: Projection to shapes | `def pipeline_shape` | TDG.lean:754 | p: E → S |
| **Def A32**: Fibers | `structure PhaseObject` | Grothendieck.lean:887 | Fiber categories |
| **Def A33**: Cartesian liftings | `structure IndexedCategory` | Grothendieck.lean:902 | Reindexing functors |

### A.5: Grothendieck Construction

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A34**: Grothendieck N ⋉ E | `structure GrothendieckObject` | Grothendieck.lean:919 | (phase, obj) pairs |
| **Def A35**: Combined reduction | `inductive CombinedReduction` | Confluence.lean:2089 | Explicit + navigation |

### A.6: Semantics

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A36**: Semantic bracket ⟦-⟧ | `structure SemFunctor` | Semantics.lean:1537 | Denotational semantics |
| **Def A37**: Navigation invariance | `theorem sem_nav_mono` | Semantics.lean:1614 | Navigation preserves semantics |
| **Def A38**: Observable correctness | `def obsCorrect` | Semantics.lean:1646 | γ(Sem(cfg)) : J |

### A.7: Main Theorems (Phase-1)

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| Well-formedness | `theorem pipeline_well_typed` | Kernel.lean:439 | Type checking |
| Explicit completeness | `theorem explicit_morphisms_closed` | TDG.lean:832 | Closure properties |
| Minimality | `theorem minimality` | Phase1.lean:554 | 6 primitives minimal |
| **Def A39**: Epistemic Spaces framework | `structure Phase1Framework` | Phase1.lean:565 | Complete axiomatization |
| Epistemic Spaces initiality | `theorem phase1_initiality` | Phase1.lean:637 | Universal construction |
| **Def A40**: Epistemic Algebra architecture | `structure EpAlgArch` | EpistemicAlgebra.lean:1710 | Category of architectures |
| Epistemic Algebra canonicality | `theorem FRFP_EpAlg_canonical` | EpistemicAlgebra.lean:1973 | FRFP is initial |
| Confluence of N ⋉ E | `theorem confluent_combined` | Confluence.lean:2228 | Unique normal forms |
| Semantic correctness | `theorem semantic_correctness_theorem` | SemanticCorrectness.lean:2457 | Main correctness theorem |

---

## Appendix A.9: Epistemic Dynamics

### A.9.2-A.9.6: Basic Dynamics

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A41**: Tacit context preorder | `structure TacitState` | DynamicLayer.lean:592 | (T, ≤) with grounding |
| **Def A42**: Context degradation δ | `def tacitDegradation` | DynamicLayer.lean:618 | T → T monotone |
| **Def A43**: Pipeline transformer | `def iteratedDegradation` | DynamicLayer.lean:631 | δⁿ iteration |
| **Def A44**: Run | `structure Run` | DynamicLayer.lean:645 | Sequence of states |
| **Def A45**: Requirement map | `def requirementMap` | DynamicLayer.lean:658 | E → T minimal context |
| **Def A46**: Hallucination | `def isHallucination` | DynamicLayer.lean:672 | t ≺ Req(e) |

### A.9.6-A.9.7: Hallucination Inevitability

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A48**: Nontrivial requirement floor | `axiom nontrivial_requirement_floor` | DynamicLayer.lean:685 | Minimum requirement |
| Hallucination inevitability | `theorem hallucination_inevitability` | DynamicLayer.lean:698 | Almost-sure eventual hallucination |
| **Def A51**: Explicit-only hallucination | `def ExplicitOnlyHallucination` | DynamicLayer.lean:718 | No tacit access |
| **Prop A52**: Containment not elimination | `axiom containment_not_elimination` | DynamicLayer.lean:725 | Can't eliminate hallucinations |

### A.9.8-A.9.10: Confidence and Feedback

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A53**: Explicit plausibility | `def explicitPlausibility` | DynamicLayer.lean:738 | π: E → [0,1] |
| **Def A54**: Extended tacit state | `structure ExtendedTacitState` | DynamicLayer.lean:745 | T × ℝ≥0 with credence |
| **Def A55**: Confidence inflation | `def confidenceInflation` | DynamicLayer.lean:755 | Φ: (T × E) → T × ℝ≥0 |
| **Def A57**: Requirement escalation | `axiom requirement_escalation` | DynamicLayer.lean:770 | Req increases with confidence |
| **Def A58**: Feedback-coupled degradation | `def feedbackCoupledDegradation` | DynamicLayer.lean:780 | δ_FB combines δ and Φ |
| **Def A59**: Extended run with feedback | `structure ExtendedRun` | DynamicLayer.lean:795 | Run with confidence tracking |

### A.9.11-A.9.13: Accelerated Hallucination

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A60**: Grounding measure and loss rate | `def groundingMeasure` | DynamicLayer.lean:810 | μ: T → ℝ≥0 |
| **Prop A61**: Loss rate increases with credence | `axiom loss_rate_credence_monotone` | DynamicLayer.lean:820 | Higher c → faster loss |
| **Def A62**: Feedback-coupled update | `def feedbackCoupledUpdate` | DynamicLayer.lean:830 | Joint (t,c,e) update |
| Accelerated hallucination | `theorem accelerated_hallucination` | DynamicLayer.lean:845 | Feedback reduces safe time |
| Accelerated inevitability | `axiom accelerated_hallucination_inevitability` | DynamicLayer.lean:855 | P(τ_FB < τ) = 1 |

### A.9.14: Entropy Drift

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A64**: Entropy functional | `def entropyFunctional` | DynamicLayer.lean:870 | S: T → ℝ |
| Entropy drift theorem | `axiom entropy_drift_theorem` | DynamicLayer.lean:880 | E[S(t_{n+1})] ≥ E[S(t_n)] |

### A.9.15-A.9.16: Stochastic Pipelines

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A68**: Trajectory | `def Trajectory` | DynamicLayer.lean:505 | ω ∈ Ω paths |
| **Def A69**: Hallucination events | `def hallucinationEvent` | DynamicLayer.lean:520 | Indicators I_n |
| **Def A71**: Output distribution | `def outputDistribution` | DynamicLayer.lean:535 | Probabilistic confluence |
| **Def A72**: Hallucination time | `def hallucinationTime` | DynamicLayer.lean:545 | τ: Ω → ℕ ∪ {∞} |
| **Lemma A73**: Pathwise inevitability | `axiom pathwise_inevitability` | DynamicLayer.lean:555 | τ < ∞ a.s. |
| **Lemma A76**: Finite-time bound | `axiom finite_time_bound` | DynamicLayer.lean:565 | Uniform loss bound |
| **Def A77**: Finite-horizon probability | `def finiteHorizonProb` | DynamicLayer.lean:470 | p_N = P(τ ≤ N) |
| **Prop A78**: Monotone convergence | `axiom monotone_convergence_horizon` | DynamicLayer.lean:480 | p_N ↗ 1 |
| **Prop A79**: Multiple runs | `axiom multiple_runs_horizon` | DynamicLayer.lean:490 | K runs analysis |
| **Def A80**: Per-step hazard | `def perStepHazard` | DynamicLayer.lean:570 | h_n conditional probability |
| **Def A81**: Finite-horizon survival | `def survivalProbability` | DynamicLayer.lean:580 | S_N = 1 - p_N |
| **Def A82**: Safe horizon | `def safeHorizon` | DynamicLayer.lean:415 | H_P(ε) max safe N |
| **Def A84**: Dynamic refinement | `def DynamicRefinement` | DynamicLayer.lean:430 | Partial order on implementations |

---

## Appendix A.10: Collective Epistemic Dynamics

### A.10.2-A.10.5: Population Structure

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A87**: Epistemic agent | `structure EpistemicAgent` | CollectiveLayer.lean:25 | Agent with tacit state |
| **Def A88**: Epistemic population | `structure EpistemicPopulation` | CollectiveLayer.lean:35 | Indexed family of agents |
| **Def A89**: Communication graph | `structure CommunicationGraph` | CollectiveLayer.lean:50 | G: connectivity |
| **Def A90**: Collective state | `structure CollectiveState` | CollectiveLayer.lean:65 | Product states |
| **Def A91**: Population semantics | `def populationSemantics` | CollectiveLayer.lean:80 | Functor interpretation |

### A.10.6-A.10.7: Collective Dynamics

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A92**: Markovian collective dynamics | `structure MarkovDynamics` | CollectiveLayer.lean:95 | Transition kernel |
| **Def A93**: Collective hallucination | `def collectiveHallucination` | CollectiveLayer.lean:110 | Population-level event |
| **Def A94**: Collective hallucination time | `def collectiveHallucinationTime` | CollectiveLayer.lean:125 | τ_coll stopping time |

### A.10.8-A.10.11: Consensus

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A95**: Consensus functor | `structure ConsensusFunctor` | CollectiveLayer.lean:140 | C: E^n → E |
| **Def A96**: Tacit-stable consensus | `def isTacitStableConsensus` | CollectiveLayer.lean:180 | Preserves under-grounding |
| **Corollary A116**: No grounding gain | `axiom no_grounding_from_consensus` | CollectiveLayer.lean:190 | Consensus can't restore grounding |
| **Corollary A117**: No automated consensus | `axiom no_automated_consensus_guarantee` | CollectiveLayer.lean:210 | Impossibility result |

### A.10.12-A.10.13: Collective Theorems

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| Collective inevitability | `axiom collective_hallucination_inevitability` | CollectiveLayer.lean:155 | P(τ_coll < ∞) = 1 |
| Consensus stability | `axiom consensus_stability_theorem` | CollectiveLayer.lean:200 | Stability under connectivity |

---

## Appendix A.11: Impossibility Results

### A.11.2-A.11.4: Framework

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A97**: Executions in N⋉E | `inductive Execution` | OperationalSemantics.lean:325 | Trace semantics |
| **Def A98**: Admissibility predicate | `def isAdmissible` | OperationalSemantics.lean:340 | IL, AR, MD, NTER, CSC |
| **Def A99**: Admissible runs | `def AdmissibleRuns` | OperationalSemantics.lean:355 | Runs(P) |
| **Def A101**: Syntactic explicit identity | `def syntacticIdentity` | TacitDependence.lean:25 | Literal equality |
| **Def A102**: Semantic explicit identity | `def semanticIdentity` | TacitDependence.lean:35 | Normal-form equality |

### A.11.5-A.11.6: Tacit Dependence

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A105**: Tacit-dependent predicates | `def TacitDependent` | TacitDependence.lean:50 | Varies with tacit state |
| Schema theorem | `axiom tacit_dependent_not_explicit_implementable` | TacitDependence.lean:235 | Core impossibility |

### A.11.7: No-Go Corollaries

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| **Def A109**: Explicit-only monitor | `abbrev ExplicitOnlyMonitor` | TacitDependence.lean:335 | M: E → {ok, flag} |
| **Def A110**: Perfect detector | `def PerfectDetector` | TacitDependence.lean:340 | Correctness condition |
| **Corollary A111**: No perfect detector | `theorem no_perfect_hallucination_detector` | TacitDependence.lean:355 | Main impossibility |
| **Corollary A112**: No elimination under degradation | `axiom no_elimination_hallucination_degradation` | TacitDependence.lean:365 | Can't guarantee τ = ∞ |
| **Corollary A113**: No infinite safe horizon | `axiom no_explicit_infinite_safe_horizon` | TacitDependence.lean:375 | H_P(ε) < ∞ |
| **Def A114**: Correctness oracle | `def CorrectnessOracle` | TacitDependence.lean:350 | Ω: E → J |
| **Corollary A115**: No correctness oracle | `axiom no_explicit_correctness_oracle` | TacitDependence.lean:390 | Can't automate γ∘⟦-⟧ |
| **Corollary A118**: Detection ≠ elimination | `axiom detection_not_elimination` | TacitDependence.lean:420 | Explicit checks insufficient |

### A.11.8: Corollaries (Additional)

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| No RBM hallucination bound | `axiom no_rbm_hallucination_bound` | TacitDependence.lean:400 | Retrieval doesn't eliminate |
| RLHF non-sufficiency | `axiom rlhf_non_sufficiency` | TacitDependence.lean:410 | Feedback loops insufficient |

---

## Appendix A.12: Institutional and Governance Layer

### A.12.2-A.12.4: Institutional Aggregation

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A119**: Epistemic agent (inst. view) | `structure EpistemicAgent` | InstitutionalLayer.lean:25 | Reuses collective agent |
| **Def A120**: Epistemic population | `structure EpistemicPopulation` | InstitutionalLayer.lean:40 | Population with institution |
| **Def A121**: Admissible run | `def AdmissibleRun` | InstitutionalLayer.lean:55 | Well-typed execution |
| **Def A122**: Replication family | `structure ReplicationFamily` | InstitutionalLayer.lean:285 | R(P) replicated runs |
| **Def A123**: Population semantic profile | `structure PopulationSemanticProfile` | InstitutionalLayer.lean:295 | {ρ_i}_{i∈I} |
| **Def A124**: Institutional aggregator | `structure InstitutionalAggregator` | InstitutionalLayer.lean:305 | I_P: Profile → J |
| **Def A125**: Institutional outcome | `def institutionalOutcome` | InstitutionalLayer.lean:318 | I_P(R(P)) |
| **Def A126**: Explicit-only institution | `def ExplicitOnlyInstitution` | InstitutionalLayer.lean:328 | Uses only explicit artifacts |
| **Def A127**: Repeatability | `def isRepeatable` | InstitutionalLayer.lean:340 | Convergence of replications |
| **Def A128**: Reproducibility | `def isReproducible` | InstitutionalLayer.lean:350 | Stability across populations |
| **Def A129**: Institutional stability | `def institutionalStability` | InstitutionalLayer.lean:360 | I stable under perturbations |

### A.12.5-A.12.6: Institutional Impossibility

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| Institutional non-automation | `axiom institutional_non_automation` | InstitutionalLayer.lean:378 | No explicit-only correctness-preserving I |
| **Def A131**: Peer review operator | `structure PeerReviewOperator` | InstitutionalLayer.lean:395 | I_PR specific aggregator |
| Peer review limitations | `axiom peer_review_non_sufficiency` | InstitutionalLayer.lean:420 | Peer review can't guarantee correctness |

### A.12.7-A.12.11: Governance

| Appendix Definition | Lean Implementation | Location | Notes |
|---------------------|---------------------|----------|-------|
| **Def A132**: Category of institutions | `structure InstitutionCategory` | InstitutionalLayer.lean:435 | Inst morphisms |
| **Def A133**: Governance operator | `structure GovernanceOperator` | Governance.lean:18 | G: Inst → Inst endofunctor |
| **Def A134**: Governance observable | `def GovernanceObservable` | Governance.lean:76 | Functional on institutions |
| **Def A135**: Governed evolution | `structure GovernedEvolution` | Governance.lean:28 | Timestamped dynamics |
| **Def A136**: Legal constraint | `structure LegalConstraint` | Governance.lean:36 | Predicate on institutions |
| **Def A137**: Lawful governance | `def isLawful` | Governance.lean:46 | G respects legal constraints |
| **Def A138/A139**: Explicit-only governance | `def ExplicitOnlyGovernance` | Governance.lean:67 | Governance using only explicit |
| **Corollary A140**: Human oversight necessity | `axiom human_oversight_necessity` | Governance.lean:146 | Lawful governance requires humans |
| **Def A141**: Disciplined agent | `structure DisciplinedAgent` | Governance.lean:160 | AI system with oversight |

### A.12.9-A.12.10: Governance Theorems

| Appendix Result | Lean Implementation | Location | Notes |
|-----------------|---------------------|----------|-------|
| Governance non-automation | `axiom governance_non_automation` | Governance.lean:127 | No fully automated governance |
| Oversight necessity | `axiom oversight_necessity_theorem` | Governance.lean:146 | Structural requirement |

---

## Summary Statistics

**Last Updated**: April 18, 2026

| Metric | Value |
|--------|-------|
| Total theorems/lemmas | 269 |
| Total axioms | 155 (40 FRFP base + 115 externally cited) |
| Core modules | 21 |
| Lines of Lean 4 | ~9,500 |
| Live sorrys | 0 |
| Uncited axioms | 0 |
| Build jobs | 3305 ✅ |

- **Total Definitions**: 130+ mapped structures
