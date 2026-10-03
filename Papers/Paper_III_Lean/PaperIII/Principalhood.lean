import AlgebraOfHumanAiCollaboration.Factorization

namespace PaperIII
open AlgebraOfHumanAiCollaboration

/-- Actor-neutral charter core. Admission/closure/amendment are supplied by the governed system. -/
structure Charter (Actor Obligation : Type) where
  roots : Actor → Obligation → Prop
  originates : Actor → Obligation → Prop
  delegates : Obligation → Actor → Actor → Prop

def IsPrincipal (χ : Charter A O) (o : O) (a : A) : Prop :=
  χ.roots a o ∧ ∀ b, χ.roots b o → b = a

/-- A partial principal function: no unique root means no selected principal. -/
noncomputable def principal (χ : Charter A O) (o : O) : Option A := by
  classical
  exact if h : ∃ a, IsPrincipal χ o a then some (Classical.choose h) else none

theorem principal_unique {χ : Charter A O} {o : O} {a b : A}
    (ha : IsPrincipal χ o a) (hb : IsPrincipal χ o b) : a = b := hb.2 a ha.1

theorem principal_eq_some {χ : Charter A O} {o : O} {a : A}
    (ha : IsPrincipal χ o a) : principal χ o = some a := by
  classical
  unfold principal
  rw [dif_pos ⟨a, ha⟩]
  congr 1
  exact principal_unique (Classical.choose_spec (show ∃ b, IsPrincipal χ o b from ⟨a, ha⟩)) ha

theorem principal_eq_some_iff {χ : Charter A O} {o : O} {a : A} :
    principal χ o = some a ↔ IsPrincipal χ o a := by
  classical
  constructor
  · intro h
    unfold principal at h
    split at h
    next hex =>
      have heq := Option.some.inj h
      exact heq ▸ Classical.choose_spec hex
    next => cases h
  · exact principal_eq_some

theorem roots_singleton_iff {χ : Charter A O} {o : O} {a : A} :
    (∀ b, χ.roots b o ↔ b = a) ↔ IsPrincipal χ o a := by
  constructor
  · intro h
    exact ⟨(h a).mpr rfl, fun b hb => (h b).mp hb⟩
  · intro h b
    exact ⟨h.2 b, fun eq => eq ▸ h.1⟩

def OriginGrounding (χ : Charter A O) : Prop :=
  ∀ a o, χ.originates a o → χ.roots a o

/-- Theorem 4, no actor identity or performance assumptions. -/
theorem principal_through_origin {χ : Charter A O} {a : A} {o : O}
    (rule : OriginGrounding χ) (origin : χ.originates a o)
    (noCoRoot : ∀ b, χ.roots b o → b = a) : IsPrincipal χ o a :=
  ⟨rule a o origin, noCoRoot⟩

def GovInd {X U B D : Type} (IndSpec : Prop)
    (criterion : X → U) (basis : X → B) (distinction : X → D) : Prop :=
  IndSpec ∧ ¬ FactorsThrough criterion basis ∧
    FactorsThrough criterion (fun x => (basis x, distinction x))

def Grounding {X U B D : Type} (χ : Charter A O) (o : O)
    (IndSpec : Prop) (criterion : X → U) (basis : X → B)
    (realizes : A → (X → D) → Prop) : Prop :=
  ∀ a d, GovInd IndSpec criterion basis d → realizes a d → χ.roots a o

/-- Theorem 5. The constitutive rule is a hypothesis, never derived from factorization. -/
theorem rooted_through_grounding {X U B D : Type} {χ : Charter A O} {o : O}
    {IndSpec : Prop} {criterion : X → U} {basis : X → B}
    {realizes : A → (X → D) → Prop} {a : A} {d : X → D}
    (rule : Grounding χ o IndSpec criterion basis realizes)
    (certified : GovInd IndSpec criterion basis d) (realized : realizes a d) :
    χ.roots a o := rule a d certified realized

/-- Corollary 1. -/
theorem principal_through_grounding {X U B D : Type} {χ : Charter A O} {o : O}
    {IndSpec : Prop} {criterion : X → U} {basis : X → B}
    {realizes : A → (X → D) → Prop} {a : A} {d : X → D}
    (rule : Grounding χ o IndSpec criterion basis realizes)
    (certified : GovInd IndSpec criterion basis d) (realized : realizes a d)
    (noCoRoot : ∀ b, χ.roots b o → b = a) : IsPrincipal χ o a :=
  ⟨rooted_through_grounding rule certified realized, noCoRoot⟩

/-- Institutional source and participant bearer are different types/relations. -/
structure SourceBearer (χ : Charter A O) (Institution : Type) where
  sourceOriginates : Institution → O → Prop
  authorizedBearer : Institution → A → O → Prop
  bearingRule : ∀ i a o, sourceOriginates i o → authorizedBearer i a o → χ.originates a o

/-- Theorem 9, including the source-bearer route and the designated obligation scope. -/
theorem human_principal_origin {χ : Charter A O} (H : A) (OH : O → Prop)
    (o : O) (_scope : OH o) (sb : SourceBearer χ I) (rule : OriginGrounding χ)
    (origin : χ.originates H o ∨ ∃ i, sb.sourceOriginates i o ∧ sb.authorizedBearer i H o)
    (noCoRoot : ∀ b, χ.roots b o → b = H) : principal χ o = some H := by
  apply principal_eq_some
  apply principal_through_origin rule _ noCoRoot
  rcases origin with direct | ⟨i, hi, hb⟩
  · exact direct
  · exact sb.bearingRule i H o hi hb

/-- Definition 5's scoped direct specialization. -/
def HumanPrincipalClass (χ : Charter A O) (H : A) (OH : O → Prop) : Prop :=
  ∀ o, OH o → IsPrincipal χ o H

theorem direct_human_specialization {χ : Charter A O} {H : A} {OH : O → Prop}
    (h : HumanPrincipalClass χ H OH) {o : O} (ho : OH o) : principal χ o = some H :=
  principal_eq_some (h o ho)

/-- Theorem 10. -/
theorem human_rooted_grounding {X U B D : Type} {χ : Charter A O} (H : A)
    (OH : O → Prop) (o : O) (_scope : OH o) {IndSpec : Prop}
    {criterion : X → U} {basis : X → B} {realizes : A → (X → D) → Prop}
    {d : X → D} (rule : Grounding χ o IndSpec criterion basis realizes)
    (certified : GovInd IndSpec criterion basis d) (realized : realizes H d) :
    χ.roots H o := rooted_through_grounding rule certified realized

/-- Corollary 2, with explicit no-co-root condition. -/
theorem human_principal_grounding {X U B D : Type} {χ : Charter A O} (H : A)
    (OH : O → Prop) (o : O) (scope : OH o) {IndSpec : Prop}
    {criterion : X → U} {basis : X → B} {realizes : A → (X → D) → Prop}
    {d : X → D} (rule : Grounding χ o IndSpec criterion basis realizes)
    (certified : GovInd IndSpec criterion basis d) (realized : realizes H d)
    (noCoRoot : ∀ b, χ.roots b o → b = H) : principal χ o = some H :=
  principal_eq_some ⟨human_rooted_grounding H OH o scope rule certified realized, noCoRoot⟩
end PaperIII
