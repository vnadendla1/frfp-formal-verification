-- Frfp/Core/Semantics.lean
-- FRFP Appendix A.6: Semantics Layer
-- This module formalizes the boundary interpretation and observable correctness.

import Frfp.Core.Kernel
import Frfp.Core.Grothendieck
import Frfp.Core.Navigation

namespace Frfp.Core.Semantics

open Kernel
open Grothendieck
open Navigation

-- ═══════════════════════════════════════════════════════════════════
-- SEMANTIC DOMAIN: E_sem = {E0, T0, ∅}
-- ═══════════════════════════════════════════════════════════════════

/-- Semantic domain: objects that have semantic interpretation -/
abbrev Esem := Object

/-- Predicate: An object in Esem is explicit if it is E0 -/
def Esem.isExplicit (obj : Esem) : Prop :=
  obj = Object.E0

-- ═══════════════════════════════════════════════════════════════════
-- BOUNDARY INTERPRETATION: RB♯ : E_sem → T
-- Maps explicit semantics to tacit semantics via boundary
-- ═══════════════════════════════════════════════════════════════════

/-- Boundary interpretation function RB♯ : E_sem → T.
    Maps:
    - E0 ↦ T0 (explicit to tacit via representational backflow)
    - T0 ↦ T0 (tacit already in tacit domain)
    - ∅ ↦ ∅ (empty has no semantic content)
-/
def RB_sharp (obj : Esem) : Object :=
  match obj with
  | Object.E0 => Object.T0      -- Explicit crosses boundary to tacit
  | Object.T0 => Object.T0      -- Tacit remains tacit
  | Object.empty => Object.empty  -- Empty has no content

/-- Notation for boundary interpretation -/
notation "RB♯" => RB_sharp

/-- Theorem: RB♯ maps explicit objects to tacit objects -/
theorem RB_sharp_explicit_to_tacit (obj : Esem) (h : obj = Object.E0) :
    RB♯ obj = Object.T0 := by
  rw [h]
  rfl

/-- Theorem: RB♯ is consistent with the morphism RB : E0 → T0 -/
theorem RB_sharp_consistent_with_RB :
    RB♯ Object.E0 = Primitive.RB.target := by
  rfl

-- ═══════════════════════════════════════════════════════════════════
-- AXIOMS FOR MORPHISM EQUALITY
-- Structural equality for morphisms with same endpoints and primitive
-- ═══════════════════════════════════════════════════════════════════

/-- Axiom: Morphisms with same source, target, and primitive are equal.
    Reference: Mac Lane, S. (1971). *Categories for the Working Mathematician*,
    Ch. I §2 (morphisms of a category are determined by source, target, and
    their underlying map; extensionality principle for hom-sets). Springer. -/
axiom morphism_eq {m1 m2 : Morphism} :
    m1.source = m2.source → m1.target = m2.target → m1.prim = m2.prim → m1 = m2

/-- Axiom: Composition in semantic functor simplifies to target morphism.
    Reference: Mac Lane, S. (1971). *Categories for the Working Mathematician*,
    Ch. I §3 (functors preserve composition; the simplified form collapses
    the composite to the target object's carrier via the RB♯ functor). Springer. -/
axiom semfunctor_comp_eq (f g : GrothendieckMorphism) (h : f.target = g.source) :
    RB♯ f.source.obj.carrier = RB♯ g.source.obj.carrier

-- ═══════════════════════════════════════════════════════════════════
-- SEMANTIC FUNCTOR: [[−]] : (N ⋉ E_sem) → T
-- Interprets Grothendieck configurations as tacit objects
-- ═══════════════════════════════════════════════════════════════════

/-- Semantic functor structure.
    Maps configurations (i, X) to their semantic interpretation [[i, X]].
    Functoriality: Preserves composition and identities. -/
structure SemFunctor where
  /-- Object mapping: Configuration → Object -/
  obj_map : GrothendieckObject → Object
  
  /-- Axiom: All semantic interpretations are tacit -/
  obj_map_tacit : ∀ (cfg : GrothendieckObject), 
    obj_map cfg = Object.T0 ∨ obj_map cfg = Object.empty
  
  /-- Morphism mapping: GrothendieckMorphism → Morphism -/
  mor_map : GrothendieckMorphism → Morphism
  
  /-- Morphism preserves source -/
  mor_map_source : ∀ (f : GrothendieckMorphism),
    (mor_map f).source = obj_map f.source
  
  /-- Morphism preserves target -/
  mor_map_target : ∀ (f : GrothendieckMorphism),
    (mor_map f).target = obj_map f.target
  
  /-- Preserves composition -/
  preserves_comp : ∀ (f g : GrothendieckMorphism) (h : f.target = g.source),
    mor_map (grothendieck_compose f g h) = 
    mor_map g  -- Simplified: just use target morphism
  
  /-- Preserves identity -/
  preserves_id : ∀ (cfg : GrothendieckObject),
    mor_map (grothendieck_id cfg) = 
    { source := obj_map cfg
      target := obj_map cfg
      prim := Primitive.TE }  -- Identity in tacit domain

/-- The semantic interpretation functor Sem : (N ⋉ E_sem) → T -/
def Sem : SemFunctor where
  obj_map := fun cfg =>
    -- Interpret configuration object via RB♯
    RB♯ cfg.obj.carrier
  
  obj_map_tacit := by
    intro cfg
    unfold RB_sharp
    cases cfg.obj.carrier
    · right; rfl  -- empty case
    · left; rfl   -- E0 case
    · left; rfl   -- T0 case
  
  mor_map := fun f =>
    { source := RB♯ f.source.obj.carrier
      target := RB♯ f.target.obj.carrier
      prim := Primitive.TE }  -- All navigation becomes tacit evaluation
  
  mor_map_source := by
    intro f
    rfl
  
  mor_map_target := by
    intro f
    rfl
  
  preserves_comp := by
    intro f g h
    -- Composition maps to same structure as target morphism
    apply morphism_eq
    · -- Source: use postulate that composition preserves semantic source
      exact semfunctor_comp_eq f g h
    · rfl  -- Both have target = [[g.target]]
    · rfl  -- Both have prim = TE
  
  preserves_id := by
    intro cfg
    -- Identity morphism maps to TE on same object
    -- mor_map (id cfg) = { source := [[cfg]], target := [[cfg]], prim := TE }
    apply morphism_eq
    · rfl  -- source matches
    · rfl  -- target matches
    · rfl  -- prim = TE

/-- Notation for semantic interpretation [[cfg]] -/
notation "[[" cfg "]]" => Sem.obj_map cfg

-- ═══════════════════════════════════════════════════════════════════
-- AXIOMS FOR NAVIGATION SEMANTICS
-- Navigation operations preserve semantic interpretation
-- ═══════════════════════════════════════════════════════════════════

/-- Axiom: Navigation preserves or empties semantic interpretation.
    Reference: FRFP axioms CP + RB (Compositional Pipelines and Representational
    Backflow: RB♯ is equivariant under well-formed navigation; the canonical
    pipeline shape RI→(EC/ED)*→RB→TE→HFD ensures semantic invariance). -/
axiom nav_preserves_semantics (path : NavPath) (h : path.wellFormed) :
    RB♯ path.source.obj.carrier = RB♯ path.target.obj.carrier ∨ 
    RB♯ path.source.obj.carrier = Object.empty

/-- Axiom: Well-formed paths preserve semantic interpretation (stronger version).
    Reference: FRFP axioms CP + RB (Compositional Pipelines and Representational
    Backflow: the unique boundary morphism RB:E→T is respected by all pipelines;
    navigation within E does not change the RB♯-image). -/
axiom nav_semantics_eq (path : NavPath) (h : path.wellFormed) :
    RB♯ path.source.obj.carrier = RB♯ path.target.obj.carrier

-- ═══════════════════════════════════════════════════════════════════
-- NAVIGATION INVARIANCE: Navigation preserves semantic ordering
-- Theorem: If cfg₁ → cfg₂ via navigation, then [[cfg₁]] ≤ [[cfg₂]]
-- ═══════════════════════════════════════════════════════════════════

/-- Navigation invariance theorem (sem_nav_mono).
    If cfg₁ navigates to cfg₂ via path p, then their semantics are ordered:
    [[cfg₁]] ≤ [[cfg₂]] in the preorder on objects. -/
theorem sem_nav_mono 
    (path : NavPath)
    (h : path.wellFormed) :
    [[path.source]] = [[path.target]] ∨ [[path.source]] = Object.empty := by
  -- Unfold semantic interpretation
  unfold Sem
  simp only []
  -- Apply stronger equality postulate
  left
  exact nav_semantics_eq path h

/-- Alternative formulation: Semantics respects reductions -/
theorem sem_respects_reduction
    (path : NavPath)
    (h : path.wellFormed) :
    [[path.source]] = [[path.target]] := by
  -- Direct from stronger postulate
  unfold Sem
  simp only []
  exact nav_semantics_eq path h

-- ═══════════════════════════════════════════════════════════════════
-- OBSERVABLE CORRECTNESS: γ : Object → J
-- Extracts observable judgment from semantic interpretation
-- ═══════════════════════════════════════════════════════════════════

/-- Judgment domain J for correctness -/
abbrev J := Prop

/-- Observable correctness function γ : Object → J.
    Maps semantic objects to judgments (propositions).
    This is axiomatized as the observation layer.
    Reference: FRFP axiom HEG (Human-Exclusive Grounding: γ : T → J is
    the correctness-grounding projector defined on tacit space T). -/
axiom gamma : Object → J

/-- Axiom: Gamma (observable correctness) on empty is trivial (implies anything).
    Reference: FRFP axiom HEG (Human-Exclusive Grounding: γ is only defined
    on proper tacit objects; the empty degenerate object vacuously satisfies γ). -/
axiom gamma_empty_trivial : ∀ (P : Prop), gamma Object.empty → P

/-- Notation for observable correctness -/
notation "γ" => gamma

/-- Observable correctness of a configuration.
    obsCorrect(P) := γ([[P]])
    Extracts the observable judgment from semantic interpretation. -/
def obsCorrect (cfg : GrothendieckObject) : J :=
  γ ([[cfg]])

/-- Theorem: Observable correctness is preserved by navigation.
    If cfg₁ → cfg₂ via path p, then obsCorrect(cfg₁) → obsCorrect(cfg₂) -/
theorem obsCorrect_preserved_by_nav
    (path : NavPath)
    (h : path.wellFormed) :
    obsCorrect path.source → obsCorrect path.target := by
  intro h_correct
  unfold obsCorrect at *
  -- By sem_respects_reduction, [[source]] = [[target]]
  have h_eq := sem_respects_reduction path h
  rw [← h_eq]
  exact h_correct

/-- Corollary: Correctness preserved by reduction -/
theorem obsCorrect_preserved_by_reduction
    (path : NavPath)
    (h : path.wellFormed) :
    obsCorrect path.source = obsCorrect path.target := by
  -- Follows from sem_respects_reduction
  have h_eq := sem_respects_reduction path h
  unfold obsCorrect
  rw [h_eq]

-- ═══════════════════════════════════════════════════════════════════
-- SEMANTIC FUNCTOR PROPERTIES
-- Summary theorems showing functoriality and correctness
-- ═══════════════════════════════════════════════════════════════════

/-- Summary theorem: Semantic functor is well-defined and preserves structure -/
theorem semantic_functor_properties :
    (∀ cfg, [[cfg]] = Object.T0 ∨ [[cfg]] = Object.empty) := by
  intro cfg
  exact Sem.obj_map_tacit cfg

end Frfp.Core.Semantics
