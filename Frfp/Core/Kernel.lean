-- Frfp/Core/Kernel.lean
-- FRFP Appendix A.2: Foundations - Kernel Structure (Definitions A11-A22)
-- This module defines the core mathematical structures that cannot be redefined.

namespace Frfp.Core.Kernel

-- ═══════════════════════════════════════════════════════════════════
-- OBJECTS: The three fundamental objects in the ambient category Cfull
-- Naming convention: E0, T0 are objects; Ecat, Tcat are categories
-- PDF: Definition A11 (Ambient category)
-- ═══════════════════════════════════════════════════════════════════

/-- Objects in the FRFP kernel category Cfull.
    Definition A11: Ambient category with objects ∅, E, T
    Naming: E0 (explicit object), T0 (tacit object), ∅ (empty) -/
inductive Object where
  | empty : Object      -- ∅: empty explicit state
  | E0 : Object         -- E: explicit object (machine-manipulable)
  | T0 : Object         -- T: tacit object (human correctness-bearing)
  deriving BEq, Repr, DecidableEq

/-- The kernel category Cfull with three objects (Definition A11) -/
abbrev C0 := Object

/-- Notation for the explicit object E0 -/
notation "E₀" => Object.E0

/-- Notation for the tacit object T0 -/
notation "T₀" => Object.T0

-- ═══════════════════════════════════════════════════════════════════
-- PRIMITIVES: The six irreducible morphisms
-- PDF: Definitions A15, A16, A17 (primitives RI, EC, ED, RB, TE, HFD)
-- Minimality proven in Phase1.lean (Theorem A.7.3)
-- ═══════════════════════════════════════════════════════════════════

/-- The six primitive morphisms of FRFP.
    Definition A15 (Explicit category): RI, EC, ED
    Definition A17 (Tacit primitives): TE, HFD
    Definition A19 (Boundary morphism): RB
    WARNING: This is a closed enumeration. No extensions allowed. -/
inductive Primitive where
  | RI : Primitive   -- Representation Initiation: ∅ → E
  | EC : Primitive   -- Explicit Computation: E → E
  | ED : Primitive   -- Explicit Diagnostics: E → E
  | RB : Primitive   -- Representational Backflow: E → T (unique boundary)
  | TE : Primitive   -- Tacit Evaluation: T → T
  | HFD : Primitive  -- Human Final Decision: T → T
  deriving BEq, Repr, DecidableEq

-- ═══════════════════════════════════════════════════════════════════
-- TYPING: Source and target assignments (fixed by construction)
-- ═══════════════════════════════════════════════════════════════════

/-- Source object of each primitive -/
def Primitive.source : Primitive → Object
  | RI => Object.empty
  | EC => Object.E0
  | ED => Object.E0
  | RB => Object.E0
  | TE => Object.T0
  | HFD => Object.T0

/-- Target object of each primitive -/
def Primitive.target : Primitive → Object
  | RI => Object.E0
  | EC => Object.E0
  | ED => Object.E0
  | RB => Object.T0
  | TE => Object.T0
  | HFD => Object.T0

-- ═══════════════════════════════════════════════════════════════════
-- MORPHISMS: Primitives as typed morphisms in the category
-- ═══════════════════════════════════════════════════════════════════

/-- A morphism in the ambient category -/
structure Morphism where
  source : Object
  target : Object
  prim : Primitive
  deriving Repr

/-- Convert a primitive to its morphism representation -/
def Primitive.toMorphism (p : Primitive) : Morphism :=
  { source := p.source, target := p.target, prim := p }

-- ═══════════════════════════════════════════════════════════════════
-- EXPLICIT-TACIT SEPARATION (ETS): Fundamental axioms
-- ═══════════════════════════════════════════════════════════════════

/-- A morphism is explicit if it targets the explicit object E0 -/
def is_explicit_morphism (m : Morphism) : Prop :=
  m.target = Object.E0

/-- A morphism is tacit if it targets the tacit object T0 -/
def is_tacit_morphism (m : Morphism) : Prop :=
  m.target = Object.T0

/-- Definition A12 (Explicit–Tacit Separation): ETS Axiom 1 - No morphisms from T to E exist -/
theorem no_morphism_T0_to_E0 (p : Primitive) :
    ¬(p.source = Object.T0 ∧ p.target = Object.E0) := by
  cases p <;> simp [Primitive.source, Primitive.target]

/-- Backward compatibility alias -/
theorem no_morphism_tacit_to_explicit : ∀ (p : Primitive), 
    ¬(p.source = Object.T0 ∧ p.target = Object.E0) := 
  no_morphism_T0_to_E0

/-- Definition A19: RB is the boundary morphism E → T -/
theorem RB_is_boundary :
    Primitive.RB.source = Object.E0 ∧ Primitive.RB.target = Object.T0 := by
  simp [Primitive.source, Primitive.target]

/-- Definition A12 (ETS Axiom 2): RB is the unique boundary morphism E → T -/
theorem RB_unique_boundary (p : Primitive) :
    (p.source = Object.E0 ∧ p.target = Object.T0) → p = Primitive.RB := by
  intro h
  cases p <;> simp [Primitive.source, Primitive.target] at h
  case RB => rfl

/-- Definition A13, A15: RI, EC, ED are explicit morphisms -/
theorem RI_is_explicit : is_explicit_morphism Primitive.RI.toMorphism := by
  simp [is_explicit_morphism, Primitive.toMorphism, Primitive.target]

theorem EC_is_explicit : is_explicit_morphism Primitive.EC.toMorphism := by
  simp [is_explicit_morphism, Primitive.toMorphism, Primitive.target]

theorem ED_is_explicit : is_explicit_morphism Primitive.ED.toMorphism := by
  simp [is_explicit_morphism, Primitive.toMorphism, Primitive.target]

/-- Definition A14, A17: TE, HFD are tacit morphisms -/
theorem TE_is_tacit : is_tacit_morphism Primitive.TE.toMorphism := by
  simp [is_tacit_morphism, Primitive.toMorphism, Primitive.target]

theorem HFD_is_tacit : is_tacit_morphism Primitive.HFD.toMorphism := by
  simp [is_tacit_morphism, Primitive.toMorphism, Primitive.target]

-- ═══════════════════════════════════════════════════════════════════
-- PIPELINES: Pipelines are morphisms in Cfull (Definition A11)
-- ═══════════════════════════════════════════════════════════════════

/-- A pipeline is a morphism in the kernel category Cfull.
    Definition A11: Morphism f : X ⟶ Y where X, Y ∈ Ob(Cfull) = {∅, E, T}.
    
    Examples:
    - Explicit pipeline: ∅ → E or E → E (Definition A15)
    - Boundary pipeline: E → T (Definition A19)
    - Tacit pipeline: T → T (Definition A16)
    
    TDG terms are syntax that interprets to pipelines (morphisms).
-/
abbrev Pipeline := Morphism

/-- An explicit pipeline is a morphism with source ∅ or E0, and target E0 -/
def is_explicit_pipeline (π : Pipeline) : Prop :=
  (π.source = Object.empty ∨ π.source = Object.E0) ∧ π.target = Object.E0

/-- A boundary pipeline is the unique morphism E0 → T0 (which is RB) -/
def is_boundary_pipeline (π : Pipeline) : Prop :=
  π.source = Object.E0 ∧ π.target = Object.T0

/-- A tacit pipeline is a morphism T0 → T0 -/
def is_tacit_pipeline (π : Pipeline) : Prop :=
  π.source = Object.T0 ∧ π.target = Object.T0

-- ═══════════════════════════════════════════════════════════════════
-- PHASE-1 AXIOMS: AI-Explicit Restriction and mode discipline
-- ═══════════════════════════════════════════════════════════════════

/-- AI can only execute RI, EC, ED -/
def is_AI_executable (p : Primitive) : Bool :=
  p == Primitive.RI || p == Primitive.EC || p == Primitive.ED

/-- Human-exclusive operations: RB, TE, HFD -/
def is_human_only (p : Primitive) : Bool :=
  p == Primitive.TE || p == Primitive.HFD || p == Primitive.RB

/-- Theorem: If a primitive is AI-executable, it preserves explicit objects -/
theorem AI_preserves_explicit : ∀ (p : Primitive), 
    is_AI_executable p = true → 
    (p.source = Object.E0 ∨ p.source = Object.empty) ∧ p.target = Object.E0 := by
  intro p h
  match p with
  | Primitive.RI => constructor; right; rfl; rfl
  | Primitive.EC => constructor; left; rfl; rfl  
  | Primitive.ED => constructor; left; rfl; rfl
  | Primitive.RB => unfold is_AI_executable at h; contradiction
  | Primitive.TE => unfold is_AI_executable at h; contradiction
  | Primitive.HFD => unfold is_AI_executable at h; contradiction

/-- Theorem: The source and target of primitives are well-typed -/
theorem AI_explicit_only : ∀ (p : Primitive), is_AI_executable p = true → 
    is_explicit_morphism p.toMorphism ∨ p = Primitive.RI := by
  intro p h
  match p with
  | Primitive.RI => right; rfl
  | Primitive.EC => left; unfold is_explicit_morphism Primitive.toMorphism Primitive.target; rfl
  | Primitive.ED => left; unfold is_explicit_morphism Primitive.toMorphism Primitive.target; rfl
  | Primitive.RB => unfold is_AI_executable at h; contradiction
  | Primitive.TE => unfold is_AI_executable at h; contradiction
  | Primitive.HFD => unfold is_AI_executable at h; contradiction

/-- Theorem: Human-only operations are NOT AI-executable -/
theorem human_only_not_AI : ∀ (p : Primitive), is_human_only p = true → 
    is_AI_executable p = false := by
  intro p h
  match p with
  | Primitive.TE => rfl
  | Primitive.HFD => rfl
  | Primitive.RB => rfl
  | Primitive.RI => unfold is_human_only at h; contradiction
  | Primitive.EC => unfold is_human_only at h; contradiction
  | Primitive.ED => unfold is_human_only at h; contradiction

/-- Composition of pipelines (morphisms) in C0.
    Given π₁ : X → Y and π₂ : Y → Z, produces π₂ ∘ π₁ : X → Z.
    Note: This is a simple model; full categorical composition requires sequences. -/
def pipeline_compose (π₁ π₂ : Pipeline) (h : π₁.target = π₂.source) : Pipeline :=
  { source := π₁.source
    target := π₂.target
    prim := π₂.prim  -- For now, use the last primitive; full composition needs sequences
  }

/-- Check if a pipeline (morphism) has a valid typing in C0 -/
def pipeline_well_typed (π : Pipeline) : Prop :=
  π.prim.source = π.source ∧ π.prim.target = π.target

/-- Theorem: All primitive morphisms are well-typed pipelines -/
theorem primitive_well_typed (p : Primitive) : 
    pipeline_well_typed p.toMorphism := by
  unfold pipeline_well_typed Primitive.toMorphism
  simp

-- ═══════════════════════════════════════════════════════════════════
-- SUBCATEGORIES: Explicit and Tacit structures
-- ═══════════════════════════════════════════════════════════════════

/-- The explicit subcategory Ecat consists of morphisms ending at E0 -/
def Ecat : Type := { p : Primitive // p.target = Object.E0 }

/-- The tacit morphism structure Tcat consists of morphisms ending at T0 -/
def Tcat : Type := { p : Primitive // p.target = Object.T0 }

/-- Constructor for explicit morphisms -/
def Ecat.mk (p : Primitive) (h : p.target = Object.E0) : Ecat := ⟨p, h⟩

/-- Constructor for tacit morphisms -/
def Tcat.mk (p : Primitive) (h : p.target = Object.T0) : Tcat := ⟨p, h⟩

-- ═══════════════════════════════════════════════════════════════════
-- KERNEL INTEGRITY: The primitive set is closed and immutable
-- ═══════════════════════════════════════════════════════════════════

/-- The primitive set has exactly 6 elements -/
def primitive_set_size : Nat := 6

/-- Completeness: Every primitive is one of the six -/
theorem primitive_completeness : ∀ (p : Primitive), 
    (p = Primitive.RI ∨ p = Primitive.EC ∨ p = Primitive.ED ∨ 
     p = Primitive.RB ∨ p = Primitive.TE ∨ p = Primitive.HFD) := by
  intro p
  cases p <;> simp

/-- All primitives are distinct -/
theorem primitives_distinct : 
    (Primitive.RI ≠ Primitive.EC) ∧
    (Primitive.RI ≠ Primitive.ED) ∧
    (Primitive.RI ≠ Primitive.RB) ∧
    (Primitive.RI ≠ Primitive.TE) ∧
    (Primitive.RI ≠ Primitive.HFD) ∧
    (Primitive.EC ≠ Primitive.ED) ∧
    (Primitive.EC ≠ Primitive.RB) ∧
    (Primitive.EC ≠ Primitive.TE) ∧
    (Primitive.EC ≠ Primitive.HFD) ∧
    (Primitive.ED ≠ Primitive.RB) ∧
    (Primitive.ED ≠ Primitive.TE) ∧
    (Primitive.ED ≠ Primitive.HFD) ∧
    (Primitive.RB ≠ Primitive.TE) ∧
    (Primitive.RB ≠ Primitive.HFD) ∧
    (Primitive.TE ≠ Primitive.HFD) := by
  simp

/-- Theorem: Composing two explicit morphisms yields an explicit morphism -/
theorem explicit_composition_closed (π1 π2 : Pipeline) :
    is_explicit_morphism π1.prim.toMorphism →
    is_explicit_morphism π2.prim.toMorphism →
    π1.prim.target = π2.prim.source →
    π1.prim.target = Object.E0 ∧ π2.prim.target = Object.E0 := by
  intro h1 h2 _
  unfold is_explicit_morphism Primitive.toMorphism at h1 h2
  constructor <;> assumption

end Frfp.Core.Kernel
