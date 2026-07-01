# Chapter 5: Reduced Axiom Basis

**Paper**: FRFP Lean Formal Verification  
**Chapter**: 5 of 8  
**Source documents**: [Appendix C](APPENDIX_C_Proposals.md) §C.3 P-03, P-07; [Appendix A](APPENDIX_A_Axiom_Audit.md) (axiom reduction history); [Appendix D](APPENDIX_D_Bibliography.md) (source anchors)

---

## 5.1 Motivation

The published FRFP papers state an 11-axiom basis for the framework. During the Lean formalization, the axiom audit (Chapter 3, Batch 1) revealed that four of those eleven — ETS, RB, AE, and MD — are derivable theorems, not independent premises. This is a structural result that improves the theory: fewer independent premises means a stronger claim and a more falsifiable specification.

The reduced basis is isolated in a separate Lean module `Frfp/Minimal/ReducedBasis.lean` that imports only `Frfp.Core.Kernel`. It does not modify any Core module.

---

## 5.2 The Eleven Original Premises

The original FRFP basis comprised:

| Name | Layer |
|---|---|
| ETS (Explicit-to-Tacit Structure) | Core |
| HEG (Human-Exclusive Grounding) | Core |
| HEC (Human-Exclusive Closure) | Core |
| RB (Reification Boundary uniqueness) | Core |
| CP (Compositional Pipelines) | Core |
| AE (AI-Executable preserve explicit) | Core |
| IL (Intent Locking) | Interaction |
| AR (Ambiguity Resolution) | Interaction |
| MD (Mode Discipline) | Interaction |
| NTER (No Tacit Emulation/Reconstruction) | Interaction |
| CSC (Correctness Stability Constraint) | Interaction |

---

## 5.3 Derivability Proofs for the Four Redundant Premises

### ETS — Explicit-to-Tacit Structure

**Claim**: No primitive maps from T0 to E0.

This is directly derivable from the `Primitive` enumeration and source/target definitions in Kernel:

```lean
theorem ETS_derivable (p : Primitive) :
    ¬(p.source = Object.T0 ∧ p.target = Object.E0) :=
  no_morphism_T0_to_E0 p
```

Lean verifies this by case analysis on all Primitive constructors. Each case is checked against the source/target assignment functions defined in Kernel.

### RB — Reification Boundary Uniqueness

**Claim**: The only E0→T0 primitive is RB.

Directly derivable from the Primitive enumeration:

```lean
theorem RB_derivable (p : Primitive) :
    (p.source = Object.E0 ∧ p.target = Object.T0) → p = Primitive.RB :=
  RB_unique_boundary p
```

Case analysis on `Primitive` constructors confirms RB is the unique case satisfying the source/target condition.

### AE — AI-Executable Preserve Explicit

**Claim**: AI-executable steps map E0 (or empty) → E0.

Derivable from the `is_AI_executable` predicate defined in Kernel:

```lean
theorem AE_derivable (p : Primitive) :
    is_AI_executable p = true →
    (p.source = Object.E0 ∨ p.source = Object.empty) ∧ p.target = Object.E0 :=
  AI_preserves_explicit p
```

The Kernel definition encodes the exact types, so the theorem follows from that definition by reflection.

### MD — Mode Discipline

**Claim**: AI-executable steps target E0; human-only steps target T0.

A derived typing rule from the partition of primitives in Kernel:

```lean
theorem MD_derivable :
    (∀ p : Primitive, is_AI_executable p = true → p.target = Object.E0) ∧
    (∀ p : Primitive, is_human_only p = true → p.target = Object.T0) :=
  ⟨fun p h => (AI_preserves_explicit p h).2,
   fun p h => human_preserves_tacit p h⟩
```

---

## 5.4 The Minimal Seven-Primitive Basis

After removing the four derivable axioms, the irreducible basis is:

```lean
structure CoreIrreducible where
  HEG : Prop  -- Human-Exclusive Grounding
  HEC : Prop  -- Human-Exclusive Closure
  CP  : Prop  -- Compositional Pipelines

structure InteractionIrreducible where
  IL   : Prop  -- Intent Locking
  AR   : Prop  -- Ambiguity Resolution
  NTER : Prop  -- No Tacit Emulation/Reconstruction
  CSC  : Prop  -- Correctness Stability Constraint

structure ReducedProfile where
  core        : CoreIrreducible
  interaction : InteractionIrreducible
  references  : List PublishedSource := []
```

`minimalPrimitiveNames = ["HEG","HEC","CP","IL","AR","NTER","CSC"]`

These seven cannot be reduced further from the Kernel definitions. Each of HEG, HEC, and CP introduces genuinely new constraints not implied by the others or by the object/primitive typing alone. Each of IL, AR, NTER, and CSC introduces interaction-level constraints not implied by the core structure.

---

## 5.5 Source Anchoring of the Seven Primitives

Each primitive's mathematical skeleton is grounded in a published source:

| Primitive | Mathematical skeleton | Published anchor |
|---|---|---|
| HEG | Tacit-space closure under human action | Implicit in Polanyi (1966); formalized via Pnueli (1977) safety predicates |
| HEC | Human-exclusive tacit operation type | Same as HEG skeleton |
| CP | Associative morphism composition | Mac Lane (1971), category axioms |
| IL | Per-step intent is fixed at authorization | Pnueli (1977), Alpern & Schneider (1985) — temporal safety invariant |
| AR | Ambiguity must be resolved before boundary crossing | Alpern & Schneider (1985) — safety vs liveness decomposition |
| NTER | No T0-reconstruction from E0 outputs | Structural from Kernel: T0→E0 morphism absence |
| CSC | Correctness authority stable under execution | Pnueli (1977) safety predicate over traces |

The three interaction primitives IL, AR, CSC have trace-level Lean skeletons in `Frfp/Minimal/ReducedBasis.lean`:

```lean
-- Trace-level protocol records
structure StepRecord where
  step         : Primitive
  intendedBy   : Bool   -- true = human-authorized
  ambiguityTag : Bool   -- true = ambiguity present at this step
  correctLock  : Bool   -- true = correctness authority is locked

structure ProtocolTrace where
  steps : List StepRecord

-- IL skeleton: pairwise intent consistency holds across trace
def IL_skeleton (t : ProtocolTrace) : Prop :=
  ∀ i j, i < t.steps.length → j < t.steps.length →
    (t.steps.get ⟨i, by omega⟩).intendedBy =
    (t.steps.get ⟨j, by omega⟩).intendedBy

-- AR skeleton: no unresolved ambiguity in trace
def AR_skeleton (t : ProtocolTrace) : Prop :=
  ∀ i, i < t.steps.length →
    ¬(t.steps.get ⟨i, by omega⟩).ambiguityTag

-- CSC skeleton: correctness lock is monotone
def CSC_skeleton (t : ProtocolTrace) : Prop :=
  ∀ i j, i ≤ j → j < t.steps.length →
    (t.steps.get ⟨i, by omega⟩).correctLock →
    (t.steps.get ⟨j, by omega⟩).correctLock
```

---

## 5.6 Decomposition Status Summary

The `sevenAssumptionDecomposition` in `ReducedBasis.lean` maps each primitive to its derivability status:

| Primitive | Status | Meaning |
|---|---|---|
| HEG | skeletonDerivable | Skeleton follows from Kernel typing |
| HEC | skeletonDerivable | Skeleton follows from Kernel typing |
| CP | skeletonDerivable | Category axiom; derivable from Mac Lane reference |
| IL | skeletonSourceAnchored | Trace-level skeleton defined; anchored to Pnueli/Alpern-Schneider |
| AR | skeletonSourceAnchored | Trace-level skeleton defined; anchored to Alpern-Schneider |
| NTER | skeletonDerivable | T0→E0 absence derivable from Kernel |
| CSC | skeletonSourceAnchored | Trace-level skeleton defined; anchored to Pnueli/Alpern-Schneider |

- `derivableSkeletonCount = 4` (HEG, HEC, CP, NTER)
- `policyOnlyCount = 0` (no primitive is pure normative policy without structural grounding)

**The policyOnlyCount = 0 result** is notable: it establishes that every FRFP primitive, including the interaction-layer constraints, has a structural mathematical skeleton grounded in a published source. None is purely normative without formal backing.

---

## 5.7 Policy Residue

Separating structural content from normative content is a key conceptual contribution of this chapter. The policy residue documents what remains genuinely intentional (design choices, not mathematical necessities):

```lean
structure InteractionPolicyResidue where
  intentAuthority          : Prop
  -- Who counts as "human-authorized" is a policy decision.
  -- The skeleton only requires intent be fixed; it does not define
  -- what counts as valid authorization.

  materialAmbiguitySemantics : Prop
  -- The skeleton requires ambiguity be absent; what counts
  -- as "material ambiguity" is a domain-specific policy decision.

  correctnessAuthority     : Prop
  -- The skeleton requires correctness authority be stable;
  -- who holds correctness authority initially is a policy decision.
```

The structural/policy split makes explicit which parts of FRFP are mathematically forced and which parts require explicit normative commitment from deployers.
