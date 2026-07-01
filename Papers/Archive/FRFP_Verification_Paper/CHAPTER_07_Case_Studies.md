# Chapter 7: Case Studies

**Paper**: FRFP Lean Formal Verification  
**Chapter**: 7 of 8  
**Source documents**: [Appendix C](APPENDIX_C_Proposals.md) §C.3 P-01, P-02; [Appendix B](APPENDIX_B_Architecture.md) (Sepsis module); [Appendix A](APPENDIX_A_Axiom_Audit.md) (SemanticCorrectness metrics)

---

## 7.1 Purpose of Case Studies

Three case studies demonstrate that the FRFP formal library is executable and interpretable against realistic scenarios, not merely an abstract mathematical structure:

1. **Sepsis consult pipeline** (Example A.8): An end-to-end executable pipeline in a clinical decision-support context.
2. **Grothendieck construction** (Appendix A.6–A.7): The architectural choice and its formalization consequences.
3. **runToω bijection** (Remark A.104): The formal bridge between pipeline runs and stochastic trajectories.

A fourth case study covers the semantic correctness result (Appendix A.7.7) as an executable test.

---

## 7.2 Case Study 1: Sepsis Consult Pipeline

### 7.2.1 Scenario

Example A.8 in the FRFP paper describes a sepsis clinical consult as a worked example of a pipeline with a concrete reduction rule. The Lean formalization implements this example as a fully executable module: `Example/Sepsis.lean` (351 lines).

### 7.2.2 Objects and Morphisms

```lean
inductive SepsisObject
  | Empty        -- ∅: Starting point
  | Context      -- Clinical context (E0)
  | Input        -- Patient data (E0)
  | Prepared     -- Preprocessed data (E0)
  | Retrieved    -- EHR data (E0)
  | Calculated   -- Computed metrics (E0)
  | Assisted     -- AI assistance provided (E0)
  | Decision     -- Final clinical decision (T0)

inductive SepsisMorphism
  | init         -- ∅ → Context
  | input        -- Context → Input
  | prep         -- Input → Prepared
  | ehr          -- Prepared → Retrieved
  | calc         -- Retrieved → Calculated
  | assist0      -- Calculated → Assisted (composite)
  | assist       -- Prepared → Assisted (optimized shortcut)
  | decide       -- Assisted → Decision  [T0: human-only]
```

Note that `decide` maps to a tacit-space object (Decision is a T0 object) and is therefore human-only. AI assistance ends at `Assisted` (E0).

### 7.2.3 Reduction Rule

The key optimization from Example A.8:

```
ehr ◦ calc ◦ assist0  →  assist
```

Three separate operations (retrieve EHR, calculate metrics, AI assistance) are replaced by a single optimized step when the full EHR context is available:

```lean
def reduceOnce : SepsisPipeline → Option SepsisPipeline
  | m1 :: m2 :: m3 :: rest =>
      if m1 == .ehr && m2 == .calc && m3 == .assist0 then
        some (.assist :: rest)
      else
        match reduceOnce (m2 :: m3 :: rest) with
        | some reduced => some (m1 :: reduced)
        | none => none
  | _ => none
```

### 7.2.4 Normal Form Computation

The module provides an executable `normalize` function that applies `reduceOnce` until no further reductions apply. The normalized form is verified to be unique (modulo navigation, per the `unique_nf_mod_nav` theorem from Chapter 4).

**Original pipeline**: `[init, input, prep, ehr, calc, assist0, decide]`  
**Normalized form**: `[init, input, prep, assist, decide]`

The reduction eliminates two intermediate steps, demonstrating that the formal reduction system captures real optimization patterns in clinical workflows.

### 7.2.5 Formal Properties Verified

The Sepsis module demonstrates all five key FRFP properties by construction:
1. AI steps stay in E0 (all morphisms except `decide` are E0-typed).
2. Only `decide` crosses to T0 (exactly one RB-equivalent step).
3. The pipeline is associatively composable (CP holds by construction).
4. No T0→E0 step exists (ETS derivable, confirmed by typing).
5. The normalized form is unique.

---

## 7.3 Case Study 2: Grothendieck Construction

### 7.3.1 Architectural Decision

The Grothendieck construction is the mathematical structure used to combine the base category (pipelines and morphisms) with the fiber category (configuration state at each point in the pipeline). Lean forced an explicit architectural decision that was implicit in the paper:

**Critical finding**: Reduction steps operate on `GrothendieckObject` (configurations, i.e., objects), NOT on morphisms. A morphism is induced by a reduction step, but the reduction step itself is a relation on objects.

This distinction matters because:
- Morphisms in the Grothendieck category encode pipeline structure (which steps connect which objects).
- Configurations encode execution state (what values are at each object at a given time).
- Reduction is a state transition, not a structural transformation of the pipeline.

### 7.3.2 Lean Formalization

```lean
-- Configuration = GrothendieckObject
-- Morphism = GrothendieckMorphism
-- Reduction step is a relation on configurations, NOT a morphism

theorem reduction_induces_morphism :
    ReductionStep cfg1 cfg2 →
    ∃ (m : GrothendieckMorphism), m.source = cfg1 ∧ m.target = cfg2
```

The morphism is induced by the reduction, not equal to it.

### 7.3.3 Consequence for Paper

This finding (Proposal P-01) requires the paper to add explicit language distinguishing:
- The pipeline graph (static structure, morphisms).
- The execution state space (dynamic, configurations).
- Reduction as a relation on the state space that induces morphisms.

---

## 7.4 Case Study 3: runToω Bijection

### 7.4.1 Background

Remark A.104 in the FRFP paper claims a correspondence between pipeline runs (execution sequences) and stochastic trajectories (sample paths of the associated stopping-time process). This correspondence is essential for the probability-theoretic results.

### 7.4.2 What Lean Required

The paper treated the correspondence informally. Lean required:

1. An explicit function `runToω : {ρ // Runs P ρ} → Ωallowed`.
2. An inverse `ωToRun : Ωallowed → {ρ // Runs P ρ}` (noncomputable).
3. Injectivity: `runToω ρ1 = runToω ρ2 → ρ1 = ρ2`.
4. Round-trip: `ωToRun (runToω ρ) = ρ`.
5. Measurability: `runToω` maps into the measurable subspace of allowed trajectories.

Items 3 and 4 were axiomatized (as they encode substantive mathematical content about the probability space structure). They are labeled as reference-class axioms citing Billingsley (1995).

### 7.4.3 Consequence for Paper

Remark A.104 should be upgraded to a full Proposition with an explicit construction of `runToω`, statement of its four properties, and a proof sketch for items 1–2 (constructive) and explicit statements for items 3–5 (requiring additional measure-theoretic assumptions).

---

## 7.5 Case Study 4: Semantic Correctness (Appendix A.7.7)

### 7.5.1 The Theorem

`SemanticCorrectness.lean` formalizes two-part Theorem A.7.7:

**Part 1**: Normal forms are unique modulo navigation equivalence.  
**Part 2**: Observable correctness is invariant under all reductions.

### 7.5.2 Key Concept: Navigation Equivalence

Two configurations are navigation-equivalent if one can reach the other via navigation morphisms (forward or backward traversal in the pipeline graph). This equivalence relation is the navigation groupoid action.

```lean
def NavEquivalent (cfg1 cfg2 : GrothendieckObject) : Prop :=
  ∃ path : List NavigationMorphism,
    path.foldl applyNav cfg1 = cfg2
```

### 7.5.3 Executable Test

The module provides executable tests for `IsNormalForm` and `NavEquivalent` on concrete configurations. This makes the theorem testable, not just provable.

### 7.5.4 Key Insight

Semantic stability (`obsCorrect_invariant`) is the property that makes FRFP pipelines semantically meaningful: reducing a pipeline does not change what is observably correct. This is what distinguishes FRFP reduction from arbitrary transformation — it is semantic-preserving.

---

## 7.6 Case Studies Summary

| Case study | Module | Key result | Paper section |
|---|---|---|---|
| Sepsis pipeline | Example/Sepsis.lean | Executable normal form; all 5 FRFP properties by construction | A.8 |
| Grothendieck construction | Frfp/Core/Grothendieck.lean | Reduction on objects, not morphisms | A.6–A.7 |
| runToω bijection | Frfp/Core/OperationalSemantics.lean | 4-property explicit bijection construction | Remark A.104 |
| Semantic correctness | Frfp/Core/SemanticCorrectness.lean | Normal forms + observable invariance | A.7.7 |
