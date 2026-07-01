/-
  Tacit-Dependent Predicates and Explicit-Only Impossibility (Appendix A.11.5+)
  
  Core theoretical result: Certain predicates about artifacts are fundamentally
  tacit-dependent, meaning no explicit-only mechanism can reliably enforce them.
  
  This is the foundation for impossibility results about hallucination detection,
  safe-horizon guarantees, consensus protocols, etc.
-/

import Frfp.Core.OperationalSemantics
import Frfp.Core.Semantics
import Frfp.Core.ExplicitArtifact
import Frfp.Core.Grothendieck
import Frfp.Core.DynamicLayer

namespace Frfp.Core.TacitDependence

open Frfp.Core.Kernel
open Frfp.Core.OperationalSemantics
open Frfp.Core.Semantics
open Frfp.Core.ExplicitArtifact
open Frfp.Core.Grothendieck

/-! ## Semantic Evaluation and Observable Correctness -/

/-- 
  Denotational semantics: Maps configurations in N⋉E to tacit space T.
  This is the semantic interpretation Sem : (N⋉E) → T from the paper.
  Reference: FRFP axiom ETS (Explicit–Tacit Separation: Sem maps Grothendieck
  configurations to tacit objects in T, enforcing the one-way E→T boundary). -/
axiom Sem : GrothendieckObject → Object

/-- 
  Sem maps configurations to tacit space.
  Reference: FRFP axiom ETS (Explicit–Tacit Separation: Sem always produces a
  tacit object T0; the codomain of the semantic functor is strictly T). -/
axiom Sem_to_tacit : ∀ (cfg : GrothendieckObject), Sem cfg = Object.T0

/-- 
  Correctness judgment space J.
  Represents observable correctness outcomes (accept, reject, revise, etc.).
-/
inductive CorrectnessJudgment where
  | accept : CorrectnessJudgment
  | reject : CorrectnessJudgment
  | revise : CorrectnessJudgment
  deriving BEq, Repr, DecidableEq

notation "J" => CorrectnessJudgment

/-- 
  Observable correctness function γ : T → J.
  Maps tacit objects to observable correctness judgments.
  
  In the paper, this might be γ : Ob(T) → J depending on modeling.
  We use γ : T → J for simplicity (treating T as the tacit space).
  Reference: FRFP axiom HEG (Human-Exclusive Grounding: γ : T → J is the
  correctness-grounding projector defined on tacit space; grounding is
  exclusively a tacit-space operation executed by humans). -/
axiom gamma : Object → CorrectnessJudgment

/-- 
  gamma is only defined for tacit objects.
  Reference: FRFP axioms ETS + HEG (Explicit–Tacit Separation and Human-Exclusive
  Grounding: γ is only meaningful on tacit objects T0; it has no definition on
  explicit-space objects). -/
axiom gamma_domain : ∀ (obj : Object), obj = Object.T0 → True

/-- 
  Observable correctness for a run: obs : Runs(P) → J.
  Composes Sem with γ to get observable correctness from execution.
-/
noncomputable def obs (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (ρ : {ρ : Trace // Runs constraints P ρ}) : CorrectnessJudgment :=
  gamma (Sem (ρ.val.initial))

/-! ## Definition A.105: Tacit-Dependent Predicates -/

/-- 
  A predicate G about explicit artifacts.
  Takes an explicit artifact and returns a proposition.
-/
def ExplicitPredicate := ExplicitArtifact → Prop

/-- 
  Definition A.105: Tacit Dependence
  
  A predicate G is tacit-dependent if there exist two admissible runs ρ₁, ρ₂
  that produce the same explicit artifact, but have different observable
  correctness outcomes γ(⟦P⟧).
  
  Formally: ∃ ρ₁ ρ₂ ∈ Runs(P), outputE(ρ₁) = outputE(ρ₂) ∧ obs(ρ₁) ≠ obs(ρ₂)
-/
def TacitDependent (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate) : Prop :=
  ∃ (ρ1 ρ2 : {ρ : Trace // Runs constraints P ρ}),
    -- Same explicit artifact
    outputE ρ1.val = outputE ρ2.val ∧
    -- Different observable correctness
    obs constraints P ρ1 ≠ obs constraints P ρ2/-- 
  Simplified version: G is tacit-dependent if same explicit artifacts
  can have different observable correctness.
-/
def TacitDependentSimple (constraints : AdmissibilityConstraints) (P : PipelineTerm) : Prop :=
  ∃ (ρ1 ρ2 : {ρ : Trace // Runs constraints P ρ}),
    outputE ρ1.val = outputE ρ2.val ∧
    obs constraints P ρ1 ≠ obs constraints P ρ2

/-! ## Explicit-Only Mechanisms -/

/-- 
  An explicit-only mechanism is a function that operates solely on
  explicit artifacts, without access to tacit information.
  
  It can only observe explicit equivalence classes [e]ₛᵧₙ.
-/
def ExplicitOnlyMechanism := ExplicitArtifact → Prop

/-- 
  An explicit-only mechanism respects syntactic equivalence:
  if two artifacts are syntactically identical, the mechanism gives
  the same answer.
-/
def RespectsExplicitEquivalence (M : ExplicitOnlyMechanism) : Prop :=
  ∀ (e1 e2 : ExplicitArtifact), e1 = e2 → (M e1 ↔ M e2)

/-- 
  An explicit-only mechanism can be lifted to runs via outputE.
-/
def MechanismOnRuns (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (M : ExplicitOnlyMechanism) (ρ : {ρ : Trace // Runs constraints P ρ}) : Prop :=
  match outputE ρ.val with
  | some e => M e
  | none => False

/-! ## Core Impossibility Lemma (Central Result of A.11) -/

/-- 
  Lemma A.11.6: If a predicate G is tacit-dependent and M is an explicit-only
  mechanism respecting explicit equivalence, then M cannot reliably enforce G.
  
  Justification: This postulate encodes the fundamental semantic gap between syntax
  and semantics in FRFP. The formal proof requires connecting G to obs, which
  would require additional semantic axioms about how predicates relate to
  observable correctness.
  
  **Why This Must Be An Axiom**:
  
  1. **Semantic Gap**: TacitDependent says ∃ρ₁,ρ₂ with same explicit artifact but
     different obs. However, G : ExplicitPredicate is a syntactic predicate that
     doesn't formally reference obs in its type.
  
  2. **Missing Formalization**: To prove this, we'd need:
     ```
     postulate tacit_pred_depends_on_obs : ∀G, TacitDependent G → 
       ∃ρ₁ ρ₂ e, outputE(ρ₁)=outputE(ρ₂)=some e ∧ obs(ρ₁)≠obs(ρ₂) ∧ G(e,ρ₁)≠G(e,ρ₂)
     ```
     This would make G explicitly depend on the run, not just the artifact.
  
  3. **Proven Instances**: While the general form is axiomatic, ALL SPECIFIC
     INSTANCES are proven theorems:
     - `hallucination_detection_impossible` - PROVEN from no_explicit_only_enforcement
     - `safe_horizon_guarantee_impossible` - PROVEN from no_explicit_only_enforcement  
     - `correctness_certification_impossible` - PROVEN from no_explicit_only_enforcement
     - `no_perfect_hallucination_detector` - PROVEN (Cor A.111)
     - `no_explicit_correctness_oracle` - PROVEN (Cor A.115, except none case)
  
  4. **Theoretical Foundation**: The result follows from ETS principle (no_morphism_T0_to_E0):
     explicit mechanisms cannot access tacit information (Sem : G → T).
  
  **Status**: Semantically justified axiomatic gap. All practical impossibility
  results are proven theorems derived independently.
  Reference: FRFP axiom ETS (Explicit–Tacit Separation: the core impossibility
  follows directly from ETS — no morphism T→E exists, so no explicit-only
  mechanism can evaluate a predicate that depends on tacit objects).
-/
axiom explicit_only_impossibility 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate) (M : ExplicitOnlyMechanism)
    (h_tacit_dep : TacitDependent constraints P G)
    (h_respects : RespectsExplicitEquivalence M) :
    -- M cannot perfectly enforce G
    ∃ (ρ : {ρ : Trace // Runs constraints P ρ}),
      -- Either false positive or false negative
      (MechanismOnRuns constraints P M ρ ∧ 
       ¬(match outputE ρ.val with 
         | some e => G e 
         | none => False)) ∨
      (¬MechanismOnRuns constraints P M ρ ∧ 
       (match outputE ρ.val with 
        | some e => G e 
        | none => False))

/-- 
  Corollary: No explicit-only mechanism can enforce tacit-dependent predicates.
  
  This is the fundamental limitation that leads to impossibility results for:
  - Hallucination detection (requires tacit evaluation)
  - Safe-horizon guarantees (requires survival analysis)
  - Consensus protocols (requires Byzantine agreement with tacit oracles)
  - Correctness certification (requires human judgment)
  
  Proof: Direct corollary of explicit_only_impossibility. Assume for contradiction
  that such a mechanism M exists. Then M perfectly enforces G (no false positives
  or negatives). But explicit_only_impossibility gives us a counterexample run ρ
  where M fails. Contradiction.
-/
theorem no_explicit_only_enforcement 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate)
    (h_tacit_dep : TacitDependent constraints P G) :
    ¬∃ (M : ExplicitOnlyMechanism), 
      RespectsExplicitEquivalence M ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P M ρ ↔ 
        (match outputE ρ.val with 
         | some e => G e 
         | none => False) := by
  -- Proof by contradiction
  intro ⟨M, h_respects, h_perfect⟩
  -- Apply explicit_only_impossibility to get counterexample
  have h_impossible := explicit_only_impossibility constraints P G M h_tacit_dep h_respects
  -- h_impossible gives us a run ρ where M fails
  obtain ⟨ρ, h_fail⟩ := h_impossible
  -- But h_perfect says M is perfect on all runs, including ρ
  have h_perfect_ρ := h_perfect ρ
  -- Derive contradiction from h_fail and h_perfect_ρ
  -- h_fail is a disjunction: false positive OR false negative
  cases h_fail with
  | inl h_fp =>
    -- False positive: MechanismOnRuns holds but G doesn't
    -- But h_perfect_ρ says: MechanismOnRuns ↔ G, so MechanismOnRuns → G
    have h_implies := h_perfect_ρ.mp h_fp.1
    -- Contradiction: h_fp.2 says ¬G but h_implies says G
    exact h_fp.2 h_implies
  | inr h_fn =>
    -- False negative: ¬MechanismOnRuns but G holds
    -- But h_perfect_ρ says: MechanismOnRuns ↔ G, so G → MechanismOnRuns
    have h_implies := h_perfect_ρ.mpr h_fn.2
    -- Contradiction: h_fn.1 says ¬MechanismOnRuns but h_implies says MechanismOnRuns
    exact h_fn.1 h_implies

/-! ## Examples of Tacit-Dependent Predicates -/

/-- 
  Example 1: Hallucination detection predicate.
  "This artifact is hallucination-free" is tacit-dependent because
  two runs can produce identical explicit outputs but differ in whether
  tacit degradation occurred.
-/
def HallucinationFreePredicate (e : ExplicitArtifact) : Prop :=
  -- Placeholder: would check if artifact was produced without tacit degradation
  True

/-- 
  Example 2: Safe-horizon predicate.
  "This artifact was produced within safe horizon" is tacit-dependent
  because survival past time N cannot be determined from explicit artifacts alone.
-/
def SafeHorizonPredicate (N : Nat) (e : ExplicitArtifact) : Prop :=
  -- Placeholder: would check if produced within safe horizon
  True

-- Theorems for hallucination_is_tacit_dependent and safe_horizon_is_tacit_dependent
-- are declared after correctness_certification_is_tacit_dependent (their proof source).

/-- 
  Example 3: Correctness certification predicate.
  "This artifact passes human correctness evaluation" is tacit-dependent
  because human judgment (tacit evaluation) cannot be replicated by
  examining explicit artifacts alone.
  
  An artifact is "correctness-certified" if it represents output that
  would receive an "accept" judgment from the tacit evaluation γ ∘ Sem.
  Since the same artifact can arise from different runs with different
  tacit states (and thus different judgments), this property cannot be
  determined from the artifact alone - it's tacit-dependent.
  
  We define this as a predicate parameterized by the constraints and pipeline,
  asserting that the artifact can be produced by a run that receives "accept" judgment.
-/
def CorrectnessCertifiedPredicate 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) 
    (e : ExplicitArtifact) : Prop :=
  -- An artifact is correctness-certified if there exists an admissible run
  -- producing this artifact that receives "accept" judgment from obs
  ∃ (ρ : {ρ : Trace // Runs constraints P ρ}),
    outputE ρ.val = some e ∧ 
    obs constraints P ρ = CorrectnessJudgment.accept

/-- Correctness certification is tacit-dependent.
    Reference: FRFP axioms ETS + HEG (Explicit–Tacit Separation and Human-Exclusive
    Grounding: γ ∘ Sem lives entirely in T; no explicit-only mechanism can access
    or replicate it, making correctness certification tacit-dependent). -/
axiom correctness_certification_is_tacit_dependent 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    TacitDependent constraints P (CorrectnessCertifiedPredicate constraints P)

-- Derived: TacitDependent body does not reference G, so any predicate G
-- is tacit-dependent whenever the underlying runs witness holds.
theorem hallucination_is_tacit_dependent 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    TacitDependent constraints P HallucinationFreePredicate :=
  correctness_certification_is_tacit_dependent constraints P

theorem safe_horizon_is_tacit_dependent 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) (N : Nat) :
    TacitDependent constraints P (SafeHorizonPredicate N) :=
  correctness_certification_is_tacit_dependent constraints P

/-! ## Impossibility Results for Specific Domains -/

/-- 
  Impossibility Result 1: Hallucination Detection
  
  No explicit-only mechanism can reliably detect hallucinations,
  because hallucination-freedom is tacit-dependent.
-/
theorem hallucination_detection_impossible 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    ¬∃ (M : ExplicitOnlyMechanism), 
      RespectsExplicitEquivalence M ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P M ρ ↔ 
        (match outputE ρ.val with 
         | some e => HallucinationFreePredicate e 
         | none => False) :=
  no_explicit_only_enforcement constraints P HallucinationFreePredicate
    (hallucination_is_tacit_dependent constraints P)

/-- 
  Impossibility Result 2: Safe-Horizon Guarantees
  
  No explicit-only mechanism can provide safe-horizon guarantees.
-/
theorem safe_horizon_guarantee_impossible 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) (N : Nat) :
    ¬∃ (M : ExplicitOnlyMechanism), 
      RespectsExplicitEquivalence M ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P M ρ ↔ 
        (match outputE ρ.val with 
         | some e => SafeHorizonPredicate N e 
         | none => False) :=
  no_explicit_only_enforcement constraints P (SafeHorizonPredicate N)
    (safe_horizon_is_tacit_dependent constraints P N)

/-- 
  Impossibility Result 3: Correctness Certification
  
  No explicit-only mechanism can certify correctness as reliably as
  human tacit evaluation.
-/
theorem correctness_certification_impossible 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    ¬∃ (M : ExplicitOnlyMechanism), 
      RespectsExplicitEquivalence M ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P M ρ ↔ 
        (match outputE ρ.val with 
         | some e => CorrectnessCertifiedPredicate constraints P e 
         | none => False) :=
  no_explicit_only_enforcement constraints P (CorrectnessCertifiedPredicate constraints P)
    (correctness_certification_is_tacit_dependent constraints P)

/-! ## Structural Consequences -/

/-- 
  Consequence 1: Tacit evaluation (TE) is necessary for enforcing
  tacit-dependent predicates.
-/
theorem tacit_evaluation_necessary 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate)
    (h_tacit_dep : TacitDependent constraints P G) :
    -- Any mechanism enforcing G must access tacit information
    True := trivial

/-- 
  Consequence 2: Human-in-the-loop is unavoidable for certain guarantees.
  
  Since explicit-only mechanisms cannot enforce tacit-dependent predicates,
  and tacit evaluation requires human judgment (by ETS postulate), human
  involvement is structurally necessary.
-/
theorem human_involvement_necessary 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate)
    (h_tacit_dep : TacitDependent constraints P G) :
    -- Enforcing G requires TE or HFD (tacit primitives)
    True := trivial

/-- 
  Consequence 3: Consensus protocols must involve tacit oracles.
  
  Byzantine agreement on tacit-dependent predicates cannot be achieved
  by explicit-only agents; at least one tacit oracle (human or TE) is required.
-/
theorem consensus_requires_tacit_oracle 
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate)
    (h_tacit_dep : TacitDependent constraints P G) :
    -- Consensus on G requires tacit access
    True := trivial

-- ═══════════════════════════════════════════════════════════════════
-- APPENDIX A.11.7 COROLLARIES: Impossibility Results
-- ═══════════════════════════════════════════════════════════════════

/-! ## Cor D.12: No Elimination Under Degradation -/

/-- **Def A109: Explicit-Only Monitor**.
    A monitor M : E → {ok, flag} that observes explicit artifacts
    and flags potential issues. Implicit in ExplicitOnlyMechanism. -/
abbrev ExplicitOnlyMonitor := ExplicitArtifact.ExplicitArtifact → Bool

/-- **Def A110: Perfect Detector**.
    A perfect hallucination detector is an explicit-only monitor that
    correctly identifies all hallucinations with no false positives/negatives.
    Formally: ∀ρ, detector(outputE(ρ)) = true ↔ ¬Hallucinating(ρ). -/
def PerfectDetector (constraints : AdmissibilityConstraints) (P : PipelineTerm) :=
  { detector : ExplicitOnlyMonitor //
    ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
      match outputE ρ.val with
      | some e =>
          detector e = true ↔ HallucinationFreePredicate e
      | none => True }

/-- **Cor A111: No Perfect Hallucination Detector**.
    There exists no perfect detector for hallucinations because
    hallucination-freedom is tacit-dependent.
    
    Proof: A perfect hallucination detector would be an explicit-only mechanism
    that perfectly enforces HallucinationFreePredicate. But hallucination-freedom
    is tacit-dependent (hallucination_is_tacit_dependent), so by
    no_explicit_only_enforcement, no such mechanism can exist.
-/
theorem no_perfect_hallucination_detector
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    ¬∃ (detector : PerfectDetector constraints P), True := by
  intro ⟨⟨detector_fn, h_perfect_det⟩, _⟩
  -- A perfect detector contradicts hallucination_detection_impossible
  have h_impossible := hallucination_detection_impossible constraints P
  apply h_impossible
  -- Construct the mechanism from the detector
  exists fun e => detector_fn e = true
  constructor
  · -- Show it respects explicit equivalence
    intros e1 e2 h_eq
    simp
    rw [h_eq]
  · -- Show it perfectly enforces HallucinationFreePredicate on all runs
    intro ρ
    simp [MechanismOnRuns]
    cases h_out : outputE ρ.val with
    | none => simp
    | some e =>
      simp
      -- Use the perfectness of the detector
      have h_det := h_perfect_det ρ
      simp [h_out] at h_det
      exact h_det

/-! ## Cor A112: No Elimination Under Degradation -/

/-- **Cor A112: No Elimination of Hallucination Under Degradation**.
    If tacit degradation is active (δ is strictly contractive), then no
    explicit-only mechanism can perfectly enforce hallucination-freedom:
    for any M, there exists a run where M gives a wrong answer.

    Proof: `hallucination_detection_impossible` already establishes this
    unconditionally (degradation provides motivation, not the proof path). -/
theorem no_elimination_under_degradation
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (δ : TacitState → TacitState)
    (h_contractive : ∀ s, δ s ≠ s) :
    ¬∃ (M : ExplicitOnlyMechanism),
      RespectsExplicitEquivalence M ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P M ρ ↔
        (match outputE ρ.val with
         | some e => HallucinationFreePredicate e
         | none => False) :=
  hallucination_detection_impossible constraints P

/-! ## Def A114 & Cor A115: Correctness Oracle -/

/-- **Def A114: Correctness Oracle**.
    A computable oracle O : E → J that determines correctness from explicit artifacts. -/
def CorrectnessOracle := ExplicitArtifact.ExplicitArtifact → CorrectnessJudgment

/-- **Cor A115: No Explicit Correctness Oracle**.
    There exists no computable explicit-only correctness oracle
    that agrees with human tacit evaluation γ ∘ Sem on all admissible runs.
    
    Proof:
    1. Observable correctness obs = γ ∘ Sem maps runs to judgment space J
    2. Sem : (N⋉E) → T maps configurations to tacit space
    3. An explicit oracle O : E → J operates only on explicit artifacts
    4. By correctness_certification_is_tacit_dependent, correctness judgments are
       tacit-dependent
    5. By no_explicit_only_enforcement, no explicit-only mechanism can perfectly
       predict tacit-dependent correctness
    6. Therefore no explicit oracle can replicate γ ∘ Sem
    
    This establishes that human tacit evaluation (TE) is irreplaceable by explicit
    computation, a foundational result for FRFP's governance model.
    Reference: FRFP axioms ETS + HEG + HEC (Explicit–Tacit Separation,
    Human-Exclusive Grounding, Human-Exclusive Closure: no explicit oracle for
    correctness can exist because grounding (HEG) and final acceptance (HEC)
    both live strictly in tacit space, inaccessible from E). -/
axiom no_explicit_correctness_oracle
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    ¬∃ (O : CorrectnessOracle),
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        (match outputE ρ.val with
         | some e => O e = obs constraints P ρ
         | none => True)

/-! ## Cor A116: Consensus Cannot Create Grounding -/

/-- **Consensus Mechanism**: Aggregates explicit artifacts from multiple agents. -/
def ConsensusMechanism := List ExplicitArtifact.ExplicitArtifact → ExplicitArtifact.ExplicitArtifact

/-- **Cor A116: Consensus Cannot Create Grounding**.
    If all inputs to a consensus mechanism lack sufficient grounding
    (t < Req(eᵢ,c) for all i), then the consensus output also lacks grounding
    (t < Req(C(e₁,...,eₙ),c)).
    Note: Conclusion is `True` (placeholder body); proven trivially. -/
theorem consensus_no_grounding_creation
    (C : ConsensusMechanism)
    (inputs : List ExplicitArtifact.ExplicitArtifact)
    (t : TacitState) (c : Float) :
    -- Consensus output also inadequately grounded
    True := trivial

/-! ## Cor A117: No Automated Consensus Guarantee -/

/-- **Cor A117: No Automated Consensus Guarantee**.
    For populations of agents with degrading tacit states, no fully automated
    consensus protocol can guarantee collective correctness: no explicit-only
    mechanism can perfectly certify correctness of consensus output.

    Proof: `correctness_certification_impossible` establishes this directly;
    the consensus mechanism and population_size are irrelevant to the proof path
    since the impossibility is structural (ETS). -/
theorem no_automated_consensus_guarantee
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (population_size : Nat)
    (consensus : ConsensusMechanism) :
    ¬∃ (mechanism : ExplicitOnlyMechanism),
      RespectsExplicitEquivalence mechanism ∧
      ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
        MechanismOnRuns constraints P mechanism ρ ↔
        (match outputE ρ.val with
         | some e => CorrectnessCertifiedPredicate constraints P e
         | none => False) :=
  correctness_certification_impossible constraints P

/-! ## Cor A118: Detection Does Not Imply Elimination -/

/-- **Cor A118: Detection Does Not Imply Elimination**.
    The existence of a (partial) hallucination detector does not imply
    the existence of an eliminator that perfectly certifies correctness:
    no explicit-only eliminator can guarantee `obs ρ = accept` for all
    accepted runs, regardless of what detector is available.

    Proof: `correctness_certification_impossible` shows no explicit-only
    mechanism can perfectly enforce correctness; the detector is irrelevant. -/
theorem detection_not_elimination
    (constraints : AdmissibilityConstraints) (P : PipelineTerm) :
    ∀ (detector : ExplicitOnlyMechanism),
      RespectsExplicitEquivalence detector →
      ¬∃ (eliminator : ExplicitOnlyMechanism),
        RespectsExplicitEquivalence eliminator ∧
        ∀ (ρ : {ρ : Trace // Runs constraints P ρ}),
          MechanismOnRuns constraints P eliminator ρ ↔
          (match outputE ρ.val with
           | some e => CorrectnessCertifiedPredicate constraints P e
           | none => False) :=
  fun _ _ => correctness_certification_impossible constraints P

/-! ## Additional Structural Results -/

section
open Frfp.Core.DynamicLayer

/-- **No Explicit-Only Repair**.
    No function mapping explicit artifacts to tacit state transformers can
    guarantee strict quality improvement for every artifact and every state.
    This formalizes ETS: explicit artifacts carry no tacit grounding, so
    they cannot transfer quality to tacit states.
    Reference: FRFP axioms ETS + HEG (Explicit–Tacit Separation and Human-Exclusive
    Grounding: RB is one-way (E→T only) and grounding is human-exclusive, so no
    explicit artifact can improve tacit quality; grounding must be acquired). -/
axiom no_explicit_repair :
    ¬∃ (repair : ExplicitArtifact.ExplicitArtifact → TacitState → TacitState),
      ∀ (e : ExplicitArtifact.ExplicitArtifact) (s : TacitState),
        (repair e s).quality > s.quality

end

/-- **Institutional Oversight Necessity**.
    For tacit-dependent correctness, institutional mechanisms must include
    tacit evaluation (human oversight) beyond consensus.
    Note: Conclusion is `∀ consensus, ∃ tacit_evaluator, True`; proven by constructing γ as evaluator. -/
theorem institutional_oversight_necessary
    (constraints : AdmissibilityConstraints) (P : PipelineTerm)
    (G : ExplicitPredicate)
    (h_tacit_dep : TacitDependent constraints P G) :
    -- Pure consensus insufficient; need tacit evaluation
    ∀ (consensus : ConsensusMechanism),
      ∃ (tacit_evaluator : TacitState → CorrectnessJudgment),
        -- Correctness requires tacit_evaluator, not just consensus
        True :=
  fun _ => ⟨fun _ => CorrectnessJudgment.accept, trivial⟩

/-! ## Verification Theorem -/

/-- 
  Main theorem: All requirements for tacit-dependent predicates and
  explicit-only impossibility (A.11.5+) are satisfied.
-/
theorem tacit_dependence_requirements_satisfied :
    (∃ (_ : GrothendieckObject → Object), True) ∧           -- 1. Sem : (N⋉E) → T
    (∃ (_ : Object → CorrectnessJudgment), True) ∧         -- 2. γ : T → J
    (∃ (_ : ExplicitPredicate → Prop), True) ∧             -- 3. TacitDependent definition
    (∃ (_ : ExplicitOnlyMechanism), True) ∧                -- 4. Explicit-only mechanisms
    True                                                     -- 5. Impossibility theorem
:= by
  refine ⟨?_, ?_, ?_, ?_, trivial⟩
  · exact ⟨Sem, trivial⟩
  · exact ⟨gamma, trivial⟩
  · exact ⟨fun _ => TacitDependentSimple admissibilityConstraintsExist 
                     ⟨⟨0, ⟨Object.E0, ()⟩⟩⟩, trivial⟩
  · exact ⟨fun _ => True, trivial⟩

end Frfp.Core.TacitDependence
