-- Frfp.lean
-- Main entry point for FRFP library
-- Exports the immutable kernel and Phase-1 theorems
-- Note: Example.Sepsis is not imported here to avoid main function conflicts
-- It can be imported separately when needed

import Frfp.Core.Kernel
import Frfp.Core.Phase1
import Frfp.Core.TDG
import Frfp.Core.Grothendieck
import Frfp.Core.Navigation
import Frfp.Core.Probability
import Frfp.Core.Semantics
import Frfp.Core.EpistemicAlgebra
import Frfp.Core.Confluence
import Frfp.Core.SemanticCorrectness
import Frfp.Core.DynamicLayer
import Frfp.Core.CollectiveLayer
import Frfp.Core.OperationalSemantics
import Frfp.Core.ExplicitArtifact
import Frfp.Core.TacitDependence
import Frfp.Core.InstitutionalLayer
import Frfp.Core.Governance

-- Re-export core namespaces for convenience
namespace Frfp.Core

-- The kernel is immutable and closed
export Frfp.Core.Kernel (
  Object Primitive Morphism Pipeline
  C0 Ecat Tcat  -- Category and subcategory types
  is_explicit_morphism is_tacit_morphism
  is_AI_executable is_human_only
  no_morphism_T0_to_E0 no_morphism_tacit_to_explicit  -- Both versions
  RB_unique_boundary
  AI_explicit_only human_only_not_AI
  primitive_set_size primitive_completeness
)

-- Phase-1 theorems establish minimality and initiality
export Frfp.Core.Phase1 (
  Phase1Framework FRFP_Phase1 Phase1Morphism
  minimality phase1_initiality
  need_RI need_EC need_ED need_RB need_TE need_HFD
)

-- TDG provides the free category construction
export Frfp.Core.TDG (
  TDGShape TDGPipeline CorrectnessClass CorrectnessQuotient
  Phase0Constraints TacitMonoid FreeCategoryProperty
  free_explicit_algebra shape_preserves_structure
)

-- Grothendieck construction for indexed categories
export Frfp.Core.Grothendieck (
  PhaseIndex PhaseObject PhaseMorphism IndexedCategory
  GrothendieckObject GrothendieckMorphism Configuration
  grothendieck_id grothendieck_compose
  ReductionStep ReductionStar
  reduction_induces_morphism reduction_carrier_is_objects
  grothendieck_category_exists reduction_system_well_defined
)

-- Navigation groupoid with oriented rewriting
export Frfp.Core.Navigation (
  NavPath NavigationGroupoid NavRewrite NavRewriteStar NavEquiv
  normalize locally_confluent confluent
  nav_rewrite_terminating nav_confluent normal_forms_exist_unique
)

-- Probability: stopping times, hazards, survival
export Frfp.Core.Probability (
  StoppingTime NatInf hazard survival safe_horizon
  survival_product_formula hazard_survival_relation survival_monotone
  survival_bounds hazard_bounds safe_horizon_characterization
  constant_hazard_stopping_time constant_hazard_property geometric_survival
  bounded_hazard_implies_almost_sure_stopping
)

-- Semantics: boundary interpretation and observable correctness
export Frfp.Core.Semantics (
  Esem RB_sharp Sem obsCorrect gamma
  sem_nav_mono sem_respects_reduction
  obsCorrect_preserved_by_nav obsCorrect_preserved_by_reduction
  semantic_functor_properties
)

-- Epistemic Algebra: category of architectures and FRFP canonicality
export Frfp.Core.EpistemicAlgebra (
  EpAlgArch EpAlgMorphism FRFP_EpAlg
  canonical_morphism FRFP_EpAlg_initial FRFP_EpAlg_canonical
  FRFP_from_universal_properties epistemic_algebra_category_structure
)

-- Confluence: combined reduction on N ⋉ E
export Frfp.Core.Confluence (
  ExplicitReduction NavigationReduction CombinedReduction
  LocallyConfluent Confluent Terminating
  join_mixed_peak confluent_combined unique_normal_forms
  combined_reduction_properties
)

-- Semantic Correctness: Theorem A.7.7
export Frfp.Core.SemanticCorrectness (
  IsNormalForm NavEquivalent
  unique_nf_mod_nav obsCorrect_invariant
  semantic_correctness_theorem frfp_semantic_correctness_properties
)

-- Dynamic Layer: Appendix A.9 & A.11.2
export Frfp.Core.DynamicLayer (
  TacitState tacitDegradation iteratedDegradation
  ExplicitArtifact requirementMap
  Trajectory AllowedTrajectorySpace Ω_allowed isAdmissible
  hallucinationTime finiteHorizonEvent p_N
  safeHorizon PipelineSafeHorizon
  hazardFunction survivalFunction
  AdmissibleImplementation
  dynamic_layer_requirements_satisfied
)

-- Collective Layer: Appendix A.10
export Frfp.Core.CollectiveLayer (
  Agent defaultAgent credence groundedBase
  Population PopulationState
  SharedArtifact GlobalExplicitState
  CommunicationGraph canCommunicate neighbors
  ConsensusOperator averagingConsensus
  GlobalState MarkovKernel standardKernel
  collectiveHallucinating CollectiveTrajectory
  collectiveHallucinationTime p_N_collective
  collectiveSafeHorizon collectiveResilience
  PopulationMorphism popId popCompose
  collective_layer_requirements_satisfied
)

-- Operational Semantics: Appendix A.11.3
export Frfp.Core.OperationalSemantics (
  Config Step reduces Trace FiniteTrace
  AdmissibilityConstraints Adm0
  PipelineTerm ExecTrace Runs isAdmissibleRun
  traceToTrajectory
  operational_semantics_requirements_satisfied
)

-- Explicit Artifact: Appendix A.11.4
export Frfp.Core.ExplicitArtifact (
  ExplicitArtifact outputE
  ExplicitReduction IsExplicitNormalForm nf
  SameSyn SameNF
  sameSynEquiv sameNFEquiv
  TraceSynQuotient TraceNFQuotient synToNFQuotient
  sameSyn_implies_sameNF
  explicit_artifact_requirements_satisfied
)

-- Tacit Dependence: Appendix A.11.5+
export Frfp.Core.TacitDependence (
  CorrectnessJudgment
  Sem gamma obs
  ExplicitPredicate TacitDependent TacitDependentSimple
  ExplicitOnlyMechanism RespectsExplicitEquivalence MechanismOnRuns
  explicit_only_impossibility no_explicit_only_enforcement
  HallucinationFreePredicate SafeHorizonPredicate CorrectnessCertifiedPredicate
  hallucination_detection_impossible safe_horizon_guarantee_impossible
  correctness_certification_impossible
  tacit_dependence_requirements_satisfied
)

-- Institutional Layer: Appendix A.12
export Frfp.Core.InstitutionalLayer (
  Credence ExtendedTacitState
  AgentInst InstitutionalJudgment gamma_inst
  EpistemicPopulation PopulationPreorder PopMorphism CategoryPop
  PopulationDegradation degradation_monotone
  AggregationOperator aggregate_credences population_judgment
  AutomatedGovernanceMechanism TacitGovernancePredicate
  no_fully_automated_governance human_oversight_necessary
  replicate_population replication_preserves_structure
  aggregation_monotone degradation_aggregation_commute
  institutional_layer_requirements_satisfied
)

-- Note: Example.Sepsis exports are not included in the core Frfp namespace
-- to avoid main function conflicts. Import Example.Sepsis directly when needed.

end Frfp.Core
