import PaperIII.Principalhood
import PaperIII.Revision
import PaperIII.ProblemAdequacy
import Mathlib.Logic.Relation

namespace PaperIII
open AlgebraOfHumanAiCollaboration

/-- Lemma 1's alternative domain qualification. -/
theorem factorization_with_inhabited_target {X Y Z : Type} [Nonempty Z]
    (f : X → Z) (R : X → Y) : FactorsThrough f R ↔ KernelIncluded R f := by
  constructor
  · exact factorsThrough_kernelIncluded
  · intro h
    classical
    refine ⟨fun y => if hx : ∃ x, R x = y then f (Classical.choose hx)
      else Classical.choice (inferInstance : Nonempty Z), ?_⟩
    intro x
    dsimp only
    rw [dif_pos (show ∃ z, R z = R x from ⟨x, rfl⟩)]
    exact (h (Classical.choose_spec (show ∃ z, R z = R x from ⟨x, rfl⟩))).symm

theorem empty_domain_counterexample :
    KernelIncluded (fun x : Empty => Empty.elim x : Empty → Unit)
      (id : Empty → Empty) ∧
    ¬ FactorsThrough (id : Empty → Empty) (fun x : Empty => Empty.elim x : Empty → Unit) := by
  constructor
  · intro x
    exact Empty.elim x
  · rintro ⟨d, _⟩
    exact Empty.elim (d ())

theorem nonfactorability_has_collision {X Y Z : Type} [Nonempty X]
    (f : X → Z) (R : X → Y) (missing : ¬ FactorsThrough f R) :
    ∃ x y, R x = R y ∧ f x ≠ f y := by
  classical
  apply Classical.byContradiction
  intro h
  apply missing
  apply (factorsThrough_iff_kernelIncluded f R).mpr
  intro x y same
  apply Classical.byContradiction
  intro different
  exact h ⟨x, y, same, different⟩

inductive Provenance where
  | root | derived | none
  deriving DecidableEq

structure TransitionOccurrence (Role Actor : Type) where
  contract : Role
  executor : Actor
  provenance : Provenance
  deriving DecidableEq

/-- Same executor, different contracts and provenance. -/
theorem executor_does_not_determine_contract_or_standing :
    ∃ a b : TransitionOccurrence Bool Bool,
      a.executor = b.executor ∧ a.contract ≠ b.contract ∧ a.provenance ≠ b.provenance := by
  exact ⟨⟨false, true, .derived⟩, ⟨true, true, .none⟩, rfl, by decide, by decide⟩

/-- Same contract, different executors and provenance. -/
theorem contract_does_not_determine_executor_or_standing :
    ∃ a b : TransitionOccurrence Bool Bool,
      a.contract = b.contract ∧ a.executor ≠ b.executor ∧ a.provenance ≠ b.provenance := by
  exact ⟨⟨false, false, .root⟩, ⟨false, true, .derived⟩, rfl, by decide, by decide⟩

def operationalUpdate (f : X → X) (z : X × Charter A O) : X × Charter A O :=
  (f z.1, z.2)

theorem operational_update_preserves_charter (f : X → X) (z : X × Charter A O) :
    (operationalUpdate f z).2 = z.2 := rfl

theorem operational_update_preserves_principal (f : X → X) (z : X × Charter A O) (o : O) :
    principal (operationalUpdate f z).2 o = principal z.2 o := rfl

def rooted (a : Bool) : Charter Bool Unit where
  roots b _ := b = a
  originates b _ := b = a
  delegates _ _ _ := True

theorem rooted_principal (a : Bool) : IsPrincipal (rooted a) () a :=
  ⟨rfl, fun _ h => h⟩

theorem capability_change_without_principal_change :
    ∃ z : Bool × Charter Bool Unit,
      (operationalUpdate not z).1 ≠ z.1 ∧
      principal (operationalUpdate not z).2 () = principal z.2 () :=
  ⟨(false, rooted false), by decide, rfl⟩

/-- Delegation closure is a relation in a fixed charter, not an amendment to its roots. -/
def Delegated (χ : Charter A O) (o : O) : A → A → Prop :=
  Relation.ReflTransGen (χ.delegates o)

theorem human_delegates_machine_without_substitution :
    Delegated (rooted false) () false true ∧
    principal (rooted false) () = some false ∧
    ¬ IsPrincipal (rooted false) () true := by
  refine ⟨Relation.ReflTransGen.single trivial, principal_eq_some (rooted_principal false), ?_⟩
  intro h
  have bad := h.1
  cases bad

def coRooted : Charter Bool Unit where
  roots _ _ := True
  originates a _ := a = false
  delegates _ _ _ := False

theorem origin_without_no_co_root :
    OriginGrounding coRooted ∧ coRooted.originates false () ∧
    coRooted.roots false () ∧ ¬ IsPrincipal coRooted () false := by
  refine ⟨fun _ _ _ => trivial, rfl, trivial, ?_⟩
  intro h
  have bad := h.2 true trivial
  cases bad

theorem co_roots_have_no_selected_principal : principal coRooted () = none := by
  classical
  unfold principal
  apply dif_neg
  rintro ⟨a, ha⟩
  cases a with
  | false => have bad := ha.2 true trivial; cases bad
  | true => have bad := ha.2 false trivial; cases bad

def originWithoutRule : Charter Bool Unit where
  roots _ _ := False
  originates _ _ := True
  delegates _ _ _ := False

theorem origin_requires_adopted_rule :
    originWithoutRule.originates false () ∧ ¬ originWithoutRule.roots false () :=
  ⟨trivial, id⟩

def informative : Bool → Bool := id
def reduced : Bool → Unit := fun _ => ()

theorem concrete_governing_certificate : GovInd True informative reduced informative := by
  refine ⟨trivial, ?_, ⟨Prod.snd, fun _ => rfl⟩⟩
  intro h
  have bad : false = true := factorsThrough_kernelIncluded h (w₁ := false) (w₂ := true) rfl
  cases bad

theorem certificate_requires_independent_specification :
    ¬ GovInd False informative reduced informative := fun h => h.1

theorem grounding_without_no_co_root :
    Grounding coRooted () True informative reduced (fun (_ : Bool) (_ : Bool → Bool) => True) ∧
    GovInd True informative reduced informative ∧
    coRooted.roots false () ∧ ¬ IsPrincipal coRooted () false :=
  ⟨fun _ _ _ _ => trivial, concrete_governing_certificate,
    trivial, origin_without_no_co_root.2.2.2⟩

theorem information_and_realization_do_not_imply_root :
    GovInd True informative reduced informative ∧
    (fun (_ : Bool) (_ : Bool → Bool) => True) false informative ∧
    ¬ originWithoutRule.roots false () :=
  ⟨concrete_governing_certificate, trivial, id⟩

/-- The neutral theorem also admits a machine-labelled principal. -/
theorem machine_principal_model : principal (rooted true) () = some true :=
  principal_eq_some (rooted_principal true)

/-- Each bit is recoverable from its own representation; the pair is not recoverable from either. -/
theorem aggregate_not_itemwise_failure :
    FactorsThrough (Prod.fst : Bool × Bool → Bool) Prod.fst ∧
    FactorsThrough (Prod.snd : Bool × Bool → Bool) Prod.snd ∧
    ¬ FactorsThrough (id : Bool × Bool → Bool × Bool) Prod.fst ∧
    ¬ FactorsThrough (id : Bool × Bool → Bool × Bool) Prod.snd := by
  refine ⟨⟨id, fun _ => rfl⟩, ⟨id, fun _ => rfl⟩, ?_, ?_⟩
  · intro h
    have bad := factorsThrough_kernelIncluded h (w₁ := (false, false)) (w₂ := (false, true)) rfl
    have : false = true := congrArg Prod.snd bad
    cases this
  · intro h
    have bad := factorsThrough_kernelIncluded h (w₁ := (false, false)) (w₂ := (true, false)) rfl
    have : false = true := congrArg Prod.fst bad
    cases this

inductive Institution where
  | organization

def institutionBearer : SourceBearer (rooted false) Institution where
  sourceOriginates _ _ := True
  authorizedBearer _ a _ := a = false
  bearingRule _ _ _ _ bearer := bearer

theorem institutional_origin_yields_human_bearer :
    institutionBearer.sourceOriginates .organization () ∧
    institutionBearer.authorizedBearer .organization false () ∧
    principal (rooted false) () = some false := by
  refine ⟨trivial, rfl, ?_⟩
  apply human_principal_origin false (fun _ => True) () trivial institutionBearer
    (fun _ _ h => h) (Or.inr ⟨.organization, trivial, rfl⟩)
  intro b hb
  exact hb

def scopedCharter : Charter Bool Bool where
  roots a o := a = o
  originates a o := a = o
  delegates _ _ _ := False

theorem human_scope_does_not_extend_to_other_obligations :
    HumanPrincipalClass scopedCharter false (fun o => o = false) ∧
    principal scopedCharter true = some true := by
  constructor
  · intro o ho
    subst o
    exact ⟨rfl, fun _ h => h⟩
  · exact principal_eq_some ⟨rfl, fun _ h => h⟩

def groundingWithoutOrigin : Charter Bool Unit where
  roots a _ := a = false
  originates _ _ := False
  delegates _ _ _ := False

theorem grounding_route_without_origin :
    Grounding groundingWithoutOrigin () True informative reduced
      (fun a (_ : Bool → Bool) => a = false) ∧
    GovInd True informative reduced informative ∧
    IsPrincipal groundingWithoutOrigin () false ∧
    ¬ groundingWithoutOrigin.originates false () :=
  ⟨fun _ _ _ realized => realized, concrete_governing_certificate,
    ⟨rfl, fun _ h => h⟩, id⟩

theorem origin_route_without_realization :
    OriginGrounding (rooted false) ∧ (rooted false).originates false () ∧
    IsPrincipal (rooted false) () false ∧
    ¬ (fun (_ : Bool) (_ : Bool → Bool) => False) false informative :=
  ⟨fun _ _ h => h, rfl, rooted_principal false, id⟩
end PaperIII
