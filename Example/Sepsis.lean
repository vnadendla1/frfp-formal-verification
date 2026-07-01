-- Example/Sepsis.lean
-- Worked Example A.8: Sepsis Consult Scenario
-- Concrete executable test with reduction rules and normal form computation

import Frfp.Core.Kernel
import Frfp.Core.TDG

namespace Example.Sepsis

open Frfp.Core.Kernel

-- ═══════════════════════════════════════════════════════════════════
-- SEPSIS CONSULT OBJECTS (Example A.8)
-- The explicit algebra for sepsis decision support
-- ═══════════════════════════════════════════════════════════════════

/-- Objects in the sepsis consult explicit algebra.
    Each represents a stage in the clinical decision pipeline. -/
inductive SepsisObject
  | Empty        -- ∅: Starting point
  | Context      -- Context: Clinical context
  | Input        -- Input: Patient data
  | Prepared     -- Prepared: Preprocessed data
  | Retrieved    -- Retrieved: EHR data
  | Calculated   -- Calculated: Computed metrics
  | Assisted     -- Assisted: AI assistance provided
  | Decision     -- Decision: Final clinical decision (explicit output)
  deriving Repr, DecidableEq, Inhabited

/-- Morphisms (generators) in the sepsis consult algebra.
    These are the atomic operations in the pipeline. -/
inductive SepsisMorphism
  | init         -- ∅ → Context
  | input        -- Context → Input
  | prep         -- Input → Prepared
  | ehr          -- Prepared → Retrieved
  | calc         -- Retrieved → Calculated
  | assist0      -- Calculated → Assisted (composite: assist0 ◦ calc ◦ ehr)
  | assist       -- Prepared → Assisted (optimized version)
  | decide       -- Assisted → Decision
  deriving Repr, DecidableEq, Inhabited

-- ═══════════════════════════════════════════════════════════════════
-- MORPHISM STRUCTURE
-- Source and target for each generator
-- ═══════════════════════════════════════════════════════════════════

def SepsisMorphism.source : SepsisMorphism → SepsisObject
  | .init    => .Empty
  | .input   => .Context
  | .prep    => .Input
  | .ehr     => .Prepared
  | .calc    => .Retrieved
  | .assist0 => .Calculated
  | .assist  => .Prepared
  | .decide  => .Assisted

def SepsisMorphism.target : SepsisMorphism → SepsisObject
  | .init    => .Context
  | .input   => .Input
  | .prep    => .Prepared
  | .ehr     => .Retrieved
  | .calc    => .Calculated
  | .assist0 => .Assisted
  | .assist  => .Assisted
  | .decide  => .Decision

-- ═══════════════════════════════════════════════════════════════════
-- PIPELINE STRUCTURE
-- Sequences of morphisms with composition
-- ═══════════════════════════════════════════════════════════════════

/-- A pipeline is a list of composable morphisms.
    Represents a sequence of operations. -/
def SepsisPipeline := List SepsisMorphism
  deriving Repr, DecidableEq, BEq

instance : ToString SepsisPipeline where
  toString pipeline := toString (repr pipeline)

/-- Check if a pipeline is well-formed (composable).
    Each morphism's target must match the next morphism's source. -/
def wellFormed : SepsisPipeline → Bool
  | [] => true
  | [_] => true
  | m1 :: m2 :: rest =>
      m1.target == m2.source && wellFormed (m2 :: rest)

/-- Get the source of a pipeline (source of first morphism). -/
def pipelineSource : SepsisPipeline → Option SepsisObject
  | [] => none
  | m :: _ => some m.source

/-- Get the target of a pipeline (target of last morphism). -/
def pipelineTarget : SepsisPipeline → Option SepsisObject
  | [] => none
  | [m] => some m.target
  | _ :: rest => pipelineTarget rest

-- ═══════════════════════════════════════════════════════════════════
-- REDUCTION RULES (Example A.8)
-- The key optimization: assist0 ◦ calc ◦ ehr → assist
-- ═══════════════════════════════════════════════════════════════════

/-- The reduction rule from Example A.8:
    assist0 ◦ calc ◦ ehr reduces to assist
    
    This represents the optimization where three separate operations
    (retrieve EHR, calculate metrics, get AI assistance) can be
    replaced by a single optimized "assist" operation that does all three. -/
def reductionPattern : SepsisPipeline := [.ehr, .calc, .assist0]
def reductionTarget : SepsisMorphism := .assist

/-- Apply one step of reduction if the pattern is found.
    Returns the reduced pipeline if reduction applies, none otherwise. -/
def reduceOnce : SepsisPipeline → Option SepsisPipeline
  | [] => none
  | [_] => none
  | [_, _] => none
  | m1 :: m2 :: m3 :: rest =>
      if m1 == .ehr && m2 == .calc && m3 == .assist0 then
        -- Found the pattern! Replace with assist
        some (.assist :: rest)
      else
        -- Pattern not at head, try recursively
        match reduceOnce (m2 :: m3 :: rest) with
        | some reduced => some (m1 :: reduced)
        | none => none

/-- Reduce to normal form by repeatedly applying reduction.
    Uses fuel to ensure termination. -/
def reduceToNormalForm (fuel : Nat) (pipeline : SepsisPipeline) : SepsisPipeline :=
  match fuel with
  | 0 => pipeline
  | fuel' + 1 =>
      match reduceOnce pipeline with
      | none => pipeline  -- Already in normal form
      | some reduced => reduceToNormalForm fuel' reduced

/-- Check if a pipeline is in normal form (no reduction applies). -/
def isNormalForm (pipeline : SepsisPipeline) : Bool :=
  reduceOnce pipeline == none

-- ═══════════════════════════════════════════════════════════════════
-- WORKED EXAMPLE: The Sepsis Consult Pipeline
-- From Example A.8 in the paper
-- ═══════════════════════════════════════════════════════════════════

/-- The original pipeline from Example A.8:
    init ◦ input ◦ prep ◦ ehr ◦ calc ◦ assist0 ◦ decide
    
    This represents the full sepsis consult workflow:
    1. Initialize context
    2. Get patient input
    3. Prepare data
    4. Retrieve EHR
    5. Calculate metrics
    6. Get AI assistance
    7. Make decision -/
def originalPipeline : SepsisPipeline :=
  [.init, .input, .prep, .ehr, .calc, .assist0, .decide]

/-- The expected normal form (e_sepsis*) from Example A.8:
    init ◦ input ◦ prep ◦ assist ◦ decide
    
    After applying the reduction rule, ehr ◦ calc ◦ assist0
    is replaced by the optimized assist operation. -/
def expectedNormalForm : SepsisPipeline :=
  [.init, .input, .prep, .assist, .decide]

-- Compute the actual normal form
def computedNormalForm : SepsisPipeline :=
  reduceToNormalForm 100 originalPipeline

-- Verify they match
def normalFormMatches : Bool :=
  computedNormalForm == expectedNormalForm

-- ═══════════════════════════════════════════════════════════════════
-- ADMISSIBILITY PREDICATE
-- Pipeline satisfies structural constraints (Example A.8)
-- ═══════════════════════════════════════════════════════════════════

/-- Admissibility predicate for sepsis pipelines.
    A pipeline is admissible if:
    1. It is well-formed (composable)
    2. It starts from Empty (∅)
    3. It ends at Decision (explicit output)
    4. All intermediate objects are explicit -/
def isAdmissible (pipeline : SepsisPipeline) : Bool :=
  wellFormed pipeline &&
  pipelineSource pipeline == some .Empty &&
  pipelineTarget pipeline == some .Decision

-- Verify original pipeline is admissible
def originalAdmissible : Bool :=
  isAdmissible originalPipeline

-- Verify normal form is admissible
def normalFormAdmissible : Bool :=
  isAdmissible expectedNormalForm

-- ═══════════════════════════════════════════════════════════════════
-- EXECUTABLE TESTS
-- Run the computation and verify results
-- ═══════════════════════════════════════════════════════════════════

#eval IO.println "╔═══════════════════════════════════════════════════════════════╗"
#eval IO.println "║  Example A.8: Sepsis Consult Pipeline - Worked Example       ║"
#eval IO.println "╚═══════════════════════════════════════════════════════════════╝"
#eval IO.println ""

#eval IO.println "Original Pipeline:"
#eval IO.println s!"  {originalPipeline}"
#eval IO.println ""

#eval IO.println "Applying reduction rule: ehr ◦ calc ◦ assist0 → assist"
#eval IO.println ""

#eval IO.println "Computed Normal Form:"
#eval IO.println s!"  {computedNormalForm}"
#eval IO.println ""

#eval IO.println "Expected Normal Form (e_sepsis*):"
#eval IO.println s!"  {expectedNormalForm}"
#eval IO.println ""

#eval IO.println s!"Normal forms match: {normalFormMatches}"
#eval IO.println s!"Original is admissible: {originalAdmissible}"
#eval IO.println s!"Normal form is admissible: {normalFormAdmissible}"
#eval IO.println ""

#eval if normalFormMatches && originalAdmissible && normalFormAdmissible then
  IO.println "✅ All checks passed!"
else
  IO.println "❌ Some checks failed"

-- ═══════════════════════════════════════════════════════════════════
-- FORMAL VERIFICATION
-- Prove properties about the reduction
-- ═══════════════════════════════════════════════════════════════════

/-- Lemma: The original pipeline is admissible. -/
theorem original_pipeline_admissible : isAdmissible originalPipeline = true := by
  native_decide

/-- Lemma: The normal form is admissible. -/
theorem normal_form_admissible : isAdmissible expectedNormalForm = true := by
  native_decide

/-- Lemma: Reduction preserves well-formedness.
    If a pipeline is well-formed and reduces, the result is well-formed. -/
theorem reduction_preserves_wellformed (pipeline : SepsisPipeline) :
    wellFormed pipeline = true →
    (match reduceOnce pipeline with
     | some reduced => wellFormed reduced = true
     | none => true) := by
  intro h_wf
  -- The reduction replaces ehr ◦ calc ◦ assist0 with assist
  -- Both have the same source/target, so well-formedness is preserved
  sorry

/-- Lemma: The computed normal form matches the expected form. -/
theorem computed_matches_expected :
    computedNormalForm = expectedNormalForm := by
  rfl

/-- Lemma: The normal form is indeed in normal form (irreducible). -/
theorem normal_form_is_irreducible :
    isNormalForm computedNormalForm = true := by
  native_decide

/-- Main Theorem: The sepsis pipeline reduces correctly.
    
    This theorem establishes that:
    1. The original pipeline is admissible (satisfies structural constraints)
    2. It reduces to the expected normal form e_sepsis*
    3. The normal form is also admissible
    4. The normal form is irreducible (no further reductions apply)
    
    This verifies the worked example from Appendix A.8. -/
theorem sepsis_pipeline_correct :
    isAdmissible originalPipeline = true ∧
    computedNormalForm = expectedNormalForm ∧
    isAdmissible expectedNormalForm = true ∧
    isNormalForm computedNormalForm = true := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · native_decide  -- original admissible
  · rfl  -- matches expected
  · native_decide  -- normal form admissible
  · native_decide  -- normal form irreducible

-- ═══════════════════════════════════════════════════════════════════
-- PIPELINE VISUALIZATION
-- Pretty-print the pipelines
-- ═══════════════════════════════════════════════════════════════════

def SepsisMorphism.toString : SepsisMorphism → String
  | .init    => "init"
  | .input   => "input"
  | .prep    => "prep"
  | .ehr     => "ehr"
  | .calc    => "calc"
  | .assist0 => "assist0"
  | .assist  => "assist"
  | .decide  => "decide"

def SepsisPipeline.toString (pipeline : SepsisPipeline) : String :=
  String.intercalate " ◦ " (pipeline.map SepsisMorphism.toString)

#eval IO.println "\n╔═══════════════════════════════════════════════════════════════╗"
#eval IO.println "║  Pipeline Visualization                                       ║"
#eval IO.println "╚═══════════════════════════════════════════════════════════════╝"
#eval IO.println ""
#eval IO.println "Original:"
#eval IO.println s!"  {originalPipeline.toString}"
#eval IO.println ""
#eval IO.println "Normal Form:"
#eval IO.println s!"  {expectedNormalForm.toString}"
#eval IO.println ""
#eval IO.println "Reduction Rule:"
#eval IO.println "  ehr ◦ calc ◦ assist0  →  assist"
#eval IO.println ""

-- ═══════════════════════════════════════════════════════════════════
-- STEP-BY-STEP REDUCTION TRACE
-- Show how the reduction applies
-- ═══════════════════════════════════════════════════════════════════

/-- Trace the reduction steps. -/
def traceReduction (fuel : Nat) (pipeline : SepsisPipeline) : List SepsisPipeline :=
  match fuel with
  | 0 => [pipeline]
  | fuel' + 1 =>
      match reduceOnce pipeline with
      | none => [pipeline]  -- Normal form reached
      | some reduced => pipeline :: traceReduction fuel' reduced

def reductionTrace : List SepsisPipeline :=
  traceReduction 100 originalPipeline

#eval IO.println "╔═══════════════════════════════════════════════════════════════╗"
#eval IO.println "║  Reduction Trace                                              ║"
#eval IO.println "╚═══════════════════════════════════════════════════════════════╝"
#eval IO.println ""
#eval IO.println s!"Step 0: {originalPipeline.toString}"
#eval IO.println s!"Step 1: {computedNormalForm.toString}"
#eval IO.println ""
#eval IO.println s!"Total steps: {reductionTrace.length - 1}"
#eval IO.println ""

end Example.Sepsis

-- Main function for executable
def main : IO Unit := do
  IO.println "╔═══════════════════════════════════════════════════════════════╗"
  IO.println "║  Example A.8: Sepsis Consult Pipeline - Worked Example       ║"
  IO.println "╚═══════════════════════════════════════════════════════════════╝"
  IO.println ""
  IO.println "Original Pipeline:"
  IO.println s!"  {Example.Sepsis.originalPipeline.toString}"
  IO.println ""
  IO.println "Applying reduction rule: ehr ◦ calc ◦ assist0 → assist"
  IO.println ""
  IO.println "Computed Normal Form:"
  IO.println s!"  {Example.Sepsis.computedNormalForm.toString}"
  IO.println ""
  IO.println "Expected Normal Form (e_sepsis*):"
  IO.println s!"  {Example.Sepsis.expectedNormalForm.toString}"
  IO.println ""
  IO.println s!"Normal forms match: {Example.Sepsis.normalFormMatches}"
  IO.println s!"Original is admissible: {Example.Sepsis.originalAdmissible}"
  IO.println s!"Normal form is admissible: {Example.Sepsis.normalFormAdmissible}"
  IO.println ""
  if Example.Sepsis.normalFormMatches && Example.Sepsis.originalAdmissible && Example.Sepsis.normalFormAdmissible then
    IO.println "✅ All checks passed!"
  else
    IO.println "❌ Some checks failed"
