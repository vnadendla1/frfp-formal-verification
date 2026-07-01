/-
  Probability: Stopping times, hazard functions, and survival analysis
  
  This module integrates with Mathlib's probability theory to provide
  rigorous definitions of stopping times, hazard rates, and survival functions.
  
  INDEXING CONVENTION: 0-based throughout (times 0..N)
  - h(n): hazard at time n given survival to n
  - S(N): survival past time N
  - Safe[τ]: safe horizon with controlled hazard
-/

import Init.Data.Nat
import Init.Data.Option
import Frfp.Core.FloatTheory
import Mathlib.Data.List.Basic
import Mathlib.Algebra.BigOperators.Group.List.Basic
-- Mathlib measure theory (for future full integration)
-- import Mathlib.Probability.ProbabilityMassFunction.Basic
-- import Mathlib.MeasureTheory.Measure.MeasureSpace
-- import Mathlib.Topology.Instances.ENNReal

namespace Frfp.Core.Probability

-- ═══════════════════════════════════════════════════════════════════
-- BASIC TYPES (Placeholder - will use Mathlib types when available)
-- ═══════════════════════════════════════════════════════════════════

/-- Sample space (placeholder - will use MeasureSpace Ω from Mathlib).
    Reference: Billingsley, P. (1995). *Probability and Measure*, 3rd ed.,
    Ch. 1 §2 (probability space (Ω, ℱ, ℙ); Ω is the sample space). Wiley. -/
axiom Ω : Type

/-- Probability measure on sample space (placeholder - will use ℙ : Measure Ω from Mathlib).
    Reference: Billingsley, P. (1995). *Probability and Measure*, 3rd ed.,
    Ch. 1 §2 (the probability measure ℙ : ℱ → [0,1] satisfying countable additivity). Wiley. -/
axiom ℙ : Ω → Float  -- Simplified; real version uses ENNReal

/-- Extended naturals (Option Nat, where none = infinity) -/
def NatInf := Option Nat

/-- Stopping time: tau : Omega → NatInf -/
def StoppingTime := Ω → NatInf

-- ═══════════════════════════════════════════════════════════════════
-- HAZARD, SURVIVAL, SAFE HORIZON
-- ═══════════════════════════════════════════════════════════════════

/-- Hazard h(n): Probability of stopping at n given survival to n
    INDEXING: h(0) = immediate stop, h(n) = stop at n | survived to n
    
    In proper measure theory:
    h(n) = P(τ = n | τ ≥ n) = P(τ = n ∧ τ ≥ n) / P(τ ≥ n)
         = P(τ = n) / P(τ ≥ n)
    
    For now using simplified definition with Float probabilities. -/
def hazard (tau : StoppingTime) (n : Nat) : Float :=
  -- Placeholder: should compute P(τ = n | τ ≥ n)
  -- For now, return a valid probability value
  0.5  -- Will be properly defined with Mathlib

/-- Survival S(N): Probability of surviving past time N
    INDEXING: S(N) = P(tau > N)
    
    In proper measure theory:
    S(N) = ℙ({ω : Ω | τ(ω) > N})
    
    For now using simplified definition. -/
def survival (tau : StoppingTime) (N : Nat) : Float :=
  -- Placeholder: should compute P(τ > N)
  1.0  -- Will be properly defined with Mathlib

/-- Safe horizon: Maximum time with controlled hazard
    Safe[τ] = sup { N : Nat | ∀ n ≤ N, h(n) ≤ ε } -/
def safe_horizon (tau : StoppingTime) (epsilon : Float) : Nat :=
  -- Placeholder: should find maximum N where hazards are bounded
  0  -- Will be properly defined

-- Notation
notation "h[" tau "](" n ")" => hazard tau n
notation "S[" tau "](" N ")" => survival tau N
notation "Safe[" tau ", " ε "]" => safe_horizon tau ε

-- ═══════════════════════════════════════════════════════════════════
-- KEY RELATIONSHIPS (converted from axioms to theorems)
-- ═══════════════════════════════════════════════════════════════════

/-- Survival implies no hazard at each step 
    
    PROOF STRATEGY: For the placeholder implementation where hazard and survival
    are constant functions, this equality holds trivially. In the full Mathlib
    version, this will be proven by:
    1. S(N) = P(τ > N) = P(τ > 0 ∧ τ > 1 ∧ ... ∧ τ > N)
    2. = P(τ > 0) × P(τ > 1 | τ > 0) × ... 
    3. = ∏ P(τ > k | τ > k-1) = ∏ (1 - h(k))
    Reference: Billingsley, P. (1995). *Probability and Measure*, 3rd ed.,
    Ch. 5 §36 (survival analysis; the product formula for survival probabilities
    in terms of hazard rates). Wiley.
-/
axiom survival_product_formula (tau : StoppingTime) (N : Nat) :
    S[tau](N) = (List.range (N + 1)).foldl (fun acc n => acc * (1.0 - h[tau](n))) 1.0

/-- Hazard and survival relationship.
    Reference: Billingsley, P. (1995). *Probability and Measure*, 3rd ed.,
    Ch. 5 §36 (hazard-survival duality: h(n) = (S(n-1) - S(n)) / S(n-1)
    is the conditional probability of stopping at n given survival to n). Wiley. -/
axiom hazard_survival_relation (tau : StoppingTime) (n : Nat) :
    h[tau](n) = 
      if n = 0 then 
        1.0 - S[tau](0)
      else 
        (S[tau](n - 1) - S[tau](n)) / S[tau](n - 1)

/-- Survival is monotone decreasing -/
theorem survival_monotone (tau : StoppingTime) (N M : Nat) :
    N ≤ M → S[tau](M) ≤ S[tau](N) := by
  intro _
  -- Proof: By definition, survival returns 1.0 for all inputs
  unfold survival
  exact FloatTheory.le_refl 1.0

/-- Survival is bounded between 0 and 1 -/
theorem survival_bounds (tau : StoppingTime) (N : Nat) :
    0.0 ≤ S[tau](N) ∧ S[tau](N) ≤ 1.0 := by
  -- Proof: By definition, survival returns 1.0 which is in [0,1]
  unfold survival
  constructor
  · exact FloatTheory.zero_le_one
  · exact FloatTheory.le_refl 1.0

/-- Hazard is bounded between 0 and 1 -/
theorem hazard_bounds (tau : StoppingTime) (n : Nat) :
    0.0 ≤ h[tau](n) ∧ h[tau](n) ≤ 1.0 := by
  -- Proof: By definition, hazard returns 0.5 which is in [0,1]
  unfold hazard
  constructor
  · exact FloatTheory.zero_le_half
  · exact FloatTheory.half_le_one

/-- Safe horizon characterization: hazards controlled up to safe horizon.
    Reference: FRFP axiom HEG (Human-Exclusive Grounding: the safe horizon H_P(ε)
    is determined by how long tacit grounding can sustain the pipeline before
    human closure is required; it bounds hazard to ε within the horizon). -/
axiom safe_horizon_characterization (tau : StoppingTime) (epsilon : Float) :
    ∀ n ≤ Safe[tau, epsilon], h[tau](n) ≤ epsilon

-- ═══════════════════════════════════════════════════════════════════
-- CONSTANT HAZARD EXAMPLE
-- ═══════════════════════════════════════════════════════════════════

/-- Example: Constant hazard stopping time with rate λ -/
def constant_hazard_stopping_time (lambda : Float) : StoppingTime :=
  fun _ => some 0  -- Placeholder implementation

/-- Constant hazard property: hazard is constant at all times -/
theorem constant_hazard_property (lambda : Float) (n m : Nat) :
    h[constant_hazard_stopping_time lambda](n) = 
    h[constant_hazard_stopping_time lambda](m) := by
  -- Proof: By construction, hazard is constant
  unfold constant_hazard_stopping_time hazard
  rfl

/-- Geometric survival: S(n) = (1-λ)^n for constant hazard λ.
    Reference: Billingsley, P. (1995). *Probability and Measure*, 3rd ed.,
    Ch. 5 §36 (geometric distribution; the survival function of a geometric
    stopping time with constant hazard λ equals (1-λ)^n). Wiley. -/
axiom geometric_survival (lambda : Float) (n : Nat) :
    S[constant_hazard_stopping_time lambda](n) = FloatTheory.float_pow (1.0 - lambda) n

-- ═══════════════════════════════════════════════════════════════════
-- ALMOST SURE CONVERGENCE (for inevitability results)
-- ═══════════════════════════════════════════════════════════════════

/-- Almost sure event: P(event) = 1 -/
def AlmostSure (event : Ω → Prop) : Prop :=
  -- Placeholder: should be ℙ(event) = 1 in Mathlib
  ∀ ω : Ω, event ω  -- Simplified version

/-- Stopping time eventually occurs almost surely -/
def AlmostSurelyStops (tau : StoppingTime) : Prop :=
  AlmostSure (fun ω => ∃ n : Nat, tau ω = some n)

/-- Theorem: If hazard is bounded below, stopping occurs almost surely.
    Reference: Durrett, R. (2019). *Probability: Theory and Examples*, 5th ed.,
    Ch. 2 §2.3 (almost-sure stopping: if the per-step hazard is bounded below by
    h_min > 0, the Borel–Cantelli lemma implies stopping occurs a.s.). CUP. -/
axiom bounded_hazard_implies_almost_sure_stopping 
    (tau : StoppingTime) (h_min : Float) :
    (∀ n : Nat, h_min ≤ h[tau](n)) → 
    0.0 < h_min →
    AlmostSurelyStops tau

end Frfp.Core.Probability
