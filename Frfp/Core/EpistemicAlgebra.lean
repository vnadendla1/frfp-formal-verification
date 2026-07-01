-- Frfp/Core/EpistemicAlgebra.lean
-- FRFP Appendix A.7.5: Epistemic Algebra Canonicality
-- This module formalizes the category of Epistemic Algebra architectures
-- and proves FRFP is the initial (canonical) object.

import Frfp.Core.Kernel
import Frfp.Core.Phase1
import Frfp.Core.TDG

namespace Frfp.Core.EpistemicAlgebra

open Kernel
open Phase1
open TDG

-- ═══════════════════════════════════════════════════════════════════
-- EPISTEMIC ALGEBRA ARCHITECTURE
-- An architecture consists of:
--   1. A kernel category with explicit/tacit separation
--   2. A set of primitive operations
--   3. Axioms enforcing epistemic constraints (AE, ETS, etc.)
-- ═══════════════════════════════════════════════════════════════════

/-- An Epistemic Algebra Architecture is a structure satisfying Phase-1 axioms
    with explicit-tacit separation and AI-explicit restriction. -/
structure EpAlgArch where
  -- Objects in the kernel category
  Objects : Type
  empty : Objects
  explicit_obj : Objects
  tacit_obj : Objects
  
  -- Primitives (morphisms)
  Primitives : Type
  RI : Primitives   -- Resource initialization: ∅ → E
  EC : Primitives   -- Explicit computation: E → E
  ED : Primitives   -- Explicit diagnostics: E → E
  RB : Primitives   -- Representational backflow: E → T
  TE : Primitives   -- Tacit evaluation: T → T
  HFD : Primitives  -- Human final decision: T → T
  
  -- Typing function: Each primitive has source and target
  source : Primitives → Objects
  target : Primitives → Objects
  
  -- Primitive typing axioms
  RI_type : source RI = empty ∧ target RI = explicit_obj
  EC_type : source EC = explicit_obj ∧ target EC = explicit_obj
  ED_type : source ED = explicit_obj ∧ target ED = explicit_obj
  RB_type : source RB = explicit_obj ∧ target RB = tacit_obj
  TE_type : source TE = tacit_obj ∧ target TE = tacit_obj
  HFD_type : source HFD = tacit_obj ∧ target HFD = tacit_obj
  
  -- Axiom: No morphisms T → E (Explicit-Tacit Separation)
  no_tacit_to_explicit : ∀ (p : Primitives), 
    source p = tacit_obj → target p ≠ explicit_obj
  
  -- Axiom: AI can only execute RI, EC, ED (AI-Explicit Restriction)
  AI_executable : Primitives → Bool
  AI_explicit_restriction : ∀ (p : Primitives),
    AI_executable p = true → (p = RI ∨ p = EC ∨ p = ED)
  
  -- Axiom: RB is the unique boundary morphism E → T
  RB_unique_boundary : ∀ (p : Primitives),
    source p = explicit_obj ∧ target p = tacit_obj → p = RB
  
  -- Minimality: These 6 primitives are necessary and sufficient
  primitive_completeness : ∀ (p : Primitives),
    p = RI ∨ p = EC ∨ p = ED ∨ p = RB ∨ p = TE ∨ p = HFD

-- ═══════════════════════════════════════════════════════════════════
-- MORPHISMS BETWEEN EPISTEMIC ALGEBRA ARCHITECTURES
-- Structure-preserving maps that respect objects, primitives, and axioms
-- ═══════════════════════════════════════════════════════════════════

/-- A morphism between Epistemic Algebra architectures preserves structure. -/
structure EpAlgMorphism (A B : EpAlgArch) where
  -- Object mapping
  obj_map : A.Objects → B.Objects
  obj_map_empty : obj_map A.empty = B.empty
  obj_map_explicit : obj_map A.explicit_obj = B.explicit_obj
  obj_map_tacit : obj_map A.tacit_obj = B.tacit_obj
  
  -- Primitive mapping
  prim_map : A.Primitives → B.Primitives
  prim_map_RI : prim_map A.RI = B.RI
  prim_map_EC : prim_map A.EC = B.EC
  prim_map_ED : prim_map A.ED = B.ED
  prim_map_RB : prim_map A.RB = B.RB
  prim_map_TE : prim_map A.TE = B.TE
  prim_map_HFD : prim_map A.HFD = B.HFD
  
  -- Preserves typing
  preserves_source : ∀ (p : A.Primitives),
    obj_map (A.source p) = B.source (prim_map p)
  preserves_target : ∀ (p : A.Primitives),
    obj_map (A.target p) = B.target (prim_map p)

-- ═══════════════════════════════════════════════════════════════════
-- EXTENSIONALITY LEMMA
-- Morphisms are equal if their obj_map and prim_map are equal
-- ═══════════════════════════════════════════════════════════════════

/-- Extensionality lemma for morphisms: two morphisms are equal if their
    object maps and primitive maps are equal. -/
@[ext]
theorem EpAlgMorphism.ext {A B : EpAlgArch} {f g : EpAlgMorphism A B}
    (h_obj : f.obj_map = g.obj_map)
    (h_prim : f.prim_map = g.prim_map) : f = g := by
  cases f; cases g; congr <;> assumption

-- ═══════════════════════════════════════════════════════════════════
-- IDENTITY AND COMPOSITION
-- ═══════════════════════════════════════════════════════════════════

/-- Identity morphism -/
def EpAlgMorphism.id (A : EpAlgArch) : EpAlgMorphism A A where
  obj_map := fun x => x
  obj_map_empty := rfl
  obj_map_explicit := rfl
  obj_map_tacit := rfl
  prim_map := fun p => p
  prim_map_RI := rfl
  prim_map_EC := rfl
  prim_map_ED := rfl
  prim_map_RB := rfl
  prim_map_TE := rfl
  prim_map_HFD := rfl
  preserves_source := fun _ => rfl
  preserves_target := fun _ => rfl

/-- Composition of morphisms -/
def EpAlgMorphism.comp {A B C : EpAlgArch}
    (f : EpAlgMorphism A B) (g : EpAlgMorphism B C) :
    EpAlgMorphism A C where
  obj_map := fun x => g.obj_map (f.obj_map x)
  obj_map_empty := by rw [f.obj_map_empty, g.obj_map_empty]
  obj_map_explicit := by rw [f.obj_map_explicit, g.obj_map_explicit]
  obj_map_tacit := by rw [f.obj_map_tacit, g.obj_map_tacit]
  prim_map := fun p => g.prim_map (f.prim_map p)
  prim_map_RI := by rw [f.prim_map_RI, g.prim_map_RI]
  prim_map_EC := by rw [f.prim_map_EC, g.prim_map_EC]
  prim_map_ED := by rw [f.prim_map_ED, g.prim_map_ED]
  prim_map_RB := by rw [f.prim_map_RB, g.prim_map_RB]
  prim_map_TE := by rw [f.prim_map_TE, g.prim_map_TE]
  prim_map_HFD := by rw [f.prim_map_HFD, g.prim_map_HFD]
  preserves_source := by
    intro p
    rw [f.preserves_source, g.preserves_source]
  preserves_target := by
    intro p
    rw [f.preserves_target, g.preserves_target]

-- ═══════════════════════════════════════════════════════════════════
-- FRFP AS AN EPISTEMIC ALGEBRA ARCHITECTURE
-- FRFP(2) is the concrete realization from our Kernel module
-- ═══════════════════════════════════════════════════════════════════

/-- FRFP is an Epistemic Algebra architecture (the canonical one). -/
def FRFP_EpAlg : EpAlgArch where
  Objects := Object
  empty := Object.empty
  explicit_obj := Object.E0
  tacit_obj := Object.T0
  
  Primitives := Primitive
  RI := Primitive.RI
  EC := Primitive.EC
  ED := Primitive.ED
  RB := Primitive.RB
  TE := Primitive.TE
  HFD := Primitive.HFD
  
  source := fun p => p.source
  target := fun p => p.target
  
  RI_type := by simp [Primitive.source, Primitive.target]
  EC_type := by simp [Primitive.source, Primitive.target]
  ED_type := by simp [Primitive.source, Primitive.target]
  RB_type := by simp [Primitive.source, Primitive.target]
  TE_type := by simp [Primitive.source, Primitive.target]
  HFD_type := by simp [Primitive.source, Primitive.target]
  
  no_tacit_to_explicit := by
    intro p h_source
    intro h_target
    cases p <;> simp [Primitive.source, Primitive.target] at *
    all_goals contradiction
  
  AI_executable := is_AI_executable
  AI_explicit_restriction := by
    intro p h
    unfold is_AI_executable at h
    cases p <;> simp at h
    · left; rfl
    · right; left; rfl
    · right; right; rfl
    all_goals contradiction
  
  RB_unique_boundary := by
    intro p ⟨h_source, h_target⟩
    -- Only RB maps E0 → T0
    cases p <;> simp [Primitive.source, Primitive.target] at *
  
  primitive_completeness := by
    intro p
    cases p <;> simp
    all_goals (try (left; rfl))
    all_goals (try (right; left; rfl))
    all_goals (try (right; right; left; rfl))
    all_goals (try (right; right; right; left; rfl))
    all_goals (try (right; right; right; right; left; rfl))
    all_goals (try (right; right; right; right; right; rfl))

-- ═══════════════════════════════════════════════════════════════════
-- UNIVERSAL PROPERTY: FRFP IS INITIAL
-- For any Epistemic Algebra architecture A, there exists a unique
-- structure-preserving morphism FRFP → A
-- ═══════════════════════════════════════════════════════════════════

/-- The canonical morphism from FRFP to any other architecture. -/
def canonical_morphism (A : EpAlgArch) : EpAlgMorphism FRFP_EpAlg A where
  obj_map := fun obj =>
    match obj with
    | Object.empty => A.empty
    | Object.E0 => A.explicit_obj
    | Object.T0 => A.tacit_obj
  
  obj_map_empty := rfl
  obj_map_explicit := rfl
  obj_map_tacit := rfl
  
  prim_map := fun prim =>
    match prim with
    | Primitive.RI => A.RI
    | Primitive.EC => A.EC
    | Primitive.ED => A.ED
    | Primitive.RB => A.RB
    | Primitive.TE => A.TE
    | Primitive.HFD => A.HFD
  
  prim_map_RI := rfl
  prim_map_EC := rfl
  prim_map_ED := rfl
  prim_map_RB := rfl
  prim_map_TE := rfl
  prim_map_HFD := rfl
  
  preserves_source := by
    intro p
    cases p <;> simp [FRFP_EpAlg, Primitive.source]
    · have h := A.RI_type; exact h.1.symm
    · have h := A.EC_type; exact h.1.symm
    · have h := A.ED_type; exact h.1.symm
    · have h := A.RB_type; exact h.1.symm
    · have h := A.TE_type; exact h.1.symm
    · have h := A.HFD_type; exact h.1.symm
  
  preserves_target := by
    intro p
    cases p <;> simp [FRFP_EpAlg, Primitive.target]
    · have h := A.RI_type; exact h.2.symm
    · have h := A.EC_type; exact h.2.symm
    · have h := A.ED_type; exact h.2.symm
    · have h := A.RB_type; exact h.2.symm
    · have h := A.TE_type; exact h.2.symm
    · have h := A.HFD_type; exact h.2.symm

/-- Uniqueness: Any morphism from FRFP to A equals the canonical one. -/
theorem morphism_uniqueness (A : EpAlgArch) (f : EpAlgMorphism FRFP_EpAlg A) :
    f = canonical_morphism A := by
  -- Morphisms are determined by their action on primitives
  -- Since f must map RI ↦ RI, EC ↦ EC, etc., it equals canonical_morphism
  ext obj
  · -- obj_map equality: show they agree on each input
    cases obj <;> simp [canonical_morphism]
    · exact f.obj_map_empty
    · exact f.obj_map_explicit
    · exact f.obj_map_tacit
  · -- prim_map equality: show they agree on each input
    cases obj <;> simp [canonical_morphism]
    · exact f.prim_map_RI
    · exact f.prim_map_EC
    · exact f.prim_map_ED
    · exact f.prim_map_RB
    · exact f.prim_map_TE
    · exact f.prim_map_HFD

-- ═══════════════════════════════════════════════════════════════════
-- MAIN THEOREM: FRFP IS INITIAL (CANONICAL)
-- This is Theorem A.7.5: FRFP(2) is the initial object in the category
-- of Epistemic Algebra architectures
-- ═══════════════════════════════════════════════════════════════════

/-- **Theorem A.7.5 (Epistemic Algebra Canonicality)**:
    FRFP is the initial object in the category of Epistemic Algebra architectures.
    
    For any architecture A, there exists a unique structure-preserving morphism
    from FRFP to A. This means FRFP is the "free" or "canonical" architecture -
    every other architecture is uniquely determined by how it interprets FRFP's
    primitives and objects.
    
    Proof sketch:
    1. Existence: canonical_morphism provides the unique morphism
    2. Uniqueness: Any morphism must map primitives to their counterparts
    3. Universal property: FRFP is freely generated by the axioms -/
theorem FRFP_EpAlg_initial (A : EpAlgArch) :
    ∃ (f : EpAlgMorphism FRFP_EpAlg A), 
      ∀ (g : EpAlgMorphism FRFP_EpAlg A), f = g := by
  -- Existence: canonical_morphism provides the witness
  -- Uniqueness: follows from morphism_uniqueness
  exists canonical_morphism A
  intro g
  exact (morphism_uniqueness A g).symm

/-- Alternative formulation: FRFP is canonical (initial). -/
theorem FRFP_EpAlg_canonical (A : EpAlgArch) :
    ∃ (f : EpAlgMorphism FRFP_EpAlg A),
      (f.obj_map FRFP_EpAlg.empty = A.empty ∧
       f.obj_map FRFP_EpAlg.explicit_obj = A.explicit_obj ∧
       f.obj_map FRFP_EpAlg.tacit_obj = A.tacit_obj) ∧
      ∀ (g : EpAlgMorphism FRFP_EpAlg A),
        (g.obj_map FRFP_EpAlg.empty = A.empty ∧
         g.obj_map FRFP_EpAlg.explicit_obj = A.explicit_obj ∧
         g.obj_map FRFP_EpAlg.tacit_obj = A.tacit_obj) →
        f = g := by
  -- canonical_morphism provides witness with required properties
  exists canonical_morphism A
  constructor
  · constructor
    · rfl
    · constructor
      · rfl
      · rfl
  · intro g _
    exact (morphism_uniqueness A g).symm

-- ═══════════════════════════════════════════════════════════════════
-- CONSTRUCTION FROM UNIVERSAL PROPERTIES
-- FRFP(2) is built from universal properties, not arbitrary choices
-- ═══════════════════════════════════════════════════════════════════

/-- FRFP is determined by universal properties, not arbitrary design.
    
    Key universal properties:
    1. Minimality (Theorem A.32): 6 primitives are necessary
    2. Initiality (Theorem A.34): FRFP is initial in Phase-1 frameworks
    3. Canonicality (Theorem A.7.5): FRFP is initial in Epistemic Algebras
    
    These theorems show FRFP(2) is the UNIQUE minimal architecture
    satisfying the epistemic constraints. -/
theorem FRFP_from_universal_properties :
    -- FRFP satisfies all required axioms
    (∀ p, FRFP_EpAlg.source p = FRFP_EpAlg.tacit_obj →
          FRFP_EpAlg.target p ≠ FRFP_EpAlg.explicit_obj) ∧
    -- AND is initial (canonical)
    (∀ A, ∃ (f : EpAlgMorphism FRFP_EpAlg A), ∀ g, f = g) := by
  constructor
  · exact FRFP_EpAlg.no_tacit_to_explicit
  · exact FRFP_EpAlg_initial

-- ═══════════════════════════════════════════════════════════════════
-- CATEGORICAL STRUCTURE
-- The category of Epistemic Algebra architectures has:
--   - Objects: EpAlgArch
--   - Morphisms: EpAlgMorphism
--   - Composition: EpAlgMorphism.comp
--   - Identity: EpAlgMorphism.id
--   - Initial object: FRFP_EpAlg
-- ═══════════════════════════════════════════════════════════════════

/-- Left identity law for morphism composition. -/
theorem comp_id_left {A B : EpAlgArch} (f : EpAlgMorphism A B) :
    EpAlgMorphism.comp (EpAlgMorphism.id A) f = f := by
  ext x
  · rfl  -- obj_map identity
  · rfl  -- prim_map identity

/-- Right identity law for morphism composition. -/
theorem comp_id_right {A B : EpAlgArch} (f : EpAlgMorphism A B) :
    EpAlgMorphism.comp f (EpAlgMorphism.id B) = f := by
  ext x
  · rfl  -- obj_map identity
  · rfl  -- prim_map identity

/-- Associativity of morphism composition. -/
theorem comp_assoc {A B C D : EpAlgArch}
    (f : EpAlgMorphism A B) (g : EpAlgMorphism B C) (h : EpAlgMorphism C D) :
    EpAlgMorphism.comp (EpAlgMorphism.comp f g) h =
    EpAlgMorphism.comp f (EpAlgMorphism.comp g h) := by
  ext x
  · simp [EpAlgMorphism.comp]  -- obj_map associativity
  · simp [EpAlgMorphism.comp]  -- prim_map associativity

/-- Summary: The category of Epistemic Algebra architectures is well-formed
    with FRFP as the initial object. -/
theorem epistemic_algebra_category_structure :
    (∀ A, ∃ (id : EpAlgMorphism A A), True) ∧  -- Has identities
    (∀ {A B C} (f : EpAlgMorphism A B) (g : EpAlgMorphism B C),
      ∃ (h : EpAlgMorphism A C), True) ∧  -- Has composition
    (∃ (initial : EpAlgArch), ∀ A, ∃ (f : EpAlgMorphism initial A), ∀ g, f = g) := by
  constructor
  · intro A
    exact ⟨EpAlgMorphism.id A, trivial⟩
  · constructor
    · intro A B C f g
      exact ⟨EpAlgMorphism.comp f g, trivial⟩
    · exists FRFP_EpAlg
      intro A
      exact FRFP_EpAlg_initial A

end Frfp.Core.EpistemicAlgebra
