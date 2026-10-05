import PaperIII.Models
import ETSplit

/-! Conditional Human authority. Constitutive standing, completion, faithful
authorization bearing, machine confinement, and exhaustive categories are
explicit premises. Paper II supplies recovery, not these authority bridges. -/
namespace PaperIII.HumanAuthority
open AlgebraOfHumanAiCollaboration

/-- Nominal designation plus competence; no participant category appears. -/
def ValidRoot (χ : Charter A O) (canBear : A → O → Prop) (o : O) (a : A) : Prop :=
  χ.roots a o ∧ canBear a o

def ValidRoots (χ : Charter A O) (canBear : A → O → Prop) (o : O) : Set A :=
  {a | ValidRoot χ canBear o a}

/-- Participant standing is the projection of an actual authorization/closure
occurrence with state- and obligation-indexed valid standing. -/
def BearerStanding (executor : T → A) (obligation : T → O)
    (authorizationOrClosure : T → Prop) (validStanding : Z → O → T → Prop)
    (z : Z) (o : O) (a : A) : Prop :=
  ∃ τ, obligation τ = o ∧ executor τ = a ∧ authorizationOrClosure τ ∧
    validStanding z o τ

/-- The chosen realized-governance interpretation. Completion is its elimination
rule, not a liveness theorem for every pending obligation. -/
def ValidGoverned (bearerStanding : A → O → Prop) (o : O) : Prop :=
  ∃ a, bearerStanding a o

def ValidRootGrounded (χ : Charter A O) (canBear standing : A → O → Prop) : Prop :=
  ∀ a o, standing a o → ∃ r, ValidRoot χ canBear o r ∧ Delegated χ o r a

/-- Abstract elimination interface; use occurrence-projected BearerStanding in applications. -/
def Completion (governed : O → Prop) (standing : A → O → Prop) : Prop :=
  ∀ o, governed o → ∃ a, standing a o

def HasHumanAuthority (χ : Charter A O) (canBear : A → O → Prop)
    (Human : A → Prop) (o : O) : Prop :=
  (∃ a, ValidRoot χ canBear o a) ∧ ∀ a, ValidRoot χ canBear o a → Human a

theorem roots_exist_of_valid_grounded_authorization
    {χ : Charter A O} {governed : O → Prop} {standing canBear : A → O → Prop}
    (completed : Completion governed standing)
    (grounded : ValidRootGrounded χ canBear standing) {o : O} (valid : governed o) :
    ∃ r, ValidRoot χ canBear o r := by
  obtain ⟨a, ha⟩ := completed o valid
  obtain ⟨r, hr, _⟩ := grounded a o ha
  exact ⟨r, hr⟩

/-- Rroot is independent candidate-root information; delegated payloads are occurrence inputs. -/
theorem no_machine_valid_root {X V M : Type} {Y : A → Type}
    {χ : Charter A O} {o : O} {Machine : A → Prop} {canBear : A → O → Prop}
    (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (missing : ¬ FactorsThrough D RM)
    (confined : ∀ a, Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a)) :
    ∀ a, ValidRoot χ canBear o a → ¬ Machine a := by
  intro a root machine
  exact missing ((faithful a root.2).trans (confined a machine))

theorem human_authority {X V M : Type} {Y : A → Type}
    {χ : Charter A O} {o : O} {Human Machine : A → Prop}
    {governed : O → Prop} {standing canBear : A → O → Prop}
    (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (completed : Completion governed standing) (grounded : ValidRootGrounded χ canBear standing)
    (missing : ¬ FactorsThrough D RM)
    (confined : ∀ a, Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a))
    (exhaustive : ∀ a, ValidRoot χ canBear o a → Human a ∨ Machine a) (valid : governed o) :
    HasHumanAuthority χ canBear Human o := by
  refine ⟨roots_exist_of_valid_grounded_authorization completed grounded valid, ?_⟩
  intro a root
  rcases exhaustive a root with human | machine
  · exact human
  · exact False.elim (no_machine_valid_root D RM Rroot missing confined faithful a root machine)

structure Recovery (X V : Type) where
  IC : (X → V) → Prop
  KC : X → X → Prop
  KF : X → X → Prop
  neutralSpectrum : (X → V) → Prop
  comparisonSpectrum : (X → V) → Prop
  explicitComparison : (X → V) → Prop
  tacitComparison : (X → V) → Prop
  C1 : ∀ {x y}, KC x y → KF x y
  C2 : ∀ {x y}, KF x y → KC x y
  R1 : ∀ f, IC f → neutralSpectrum f → comparisonSpectrum f
  R2 : ∀ f, IC f → comparisonSpectrum f → neutralSpectrum f
  explicitCharacterization : ∀ f, IC f → (explicitComparison f ↔ comparisonSpectrum f)
  tacitComplementarity : ∀ f, IC f → (tacitComparison f ↔ ¬ comparisonSpectrum f)

theorem recovery_correctness_alignment (h : Recovery X V) : h.KC = h.KF :=
  ETSplit.semantic_alignment h.C1 h.C2

/-- Minimal Paper II discharge: one spectral inclusion, Tacit elimination,
and admission of the selected basis. No correctness inclusions or reverse
spectral inclusion occur in this signature. -/
theorem spectral_modal_missing {X V M : Type}
    (IC neutral comparison tacit : (X → V) → Prop)
    (D : X → V) (RM : X → M) (selected : IC D)
    (R1 : ∀ f, IC f → neutral f → comparison f)
    (tacitElimination : ∀ f, IC f → tacit f → ¬ comparison f)
    (classified : tacit D)
    (admitted : FactorsThrough D RM → neutral D) : ¬ FactorsThrough D RM :=
  fun represented => tacitElimination D selected classified (R1 D selected (admitted represented))

theorem recovered_tacit_missing {X V M : Type} (h : Recovery X V)
    (D : X → V) (RM : X → M) (selected : h.IC D)
    (tacit : h.tacitComparison D)
    (admitted : FactorsThrough D RM → h.neutralSpectrum D) :
    ¬ FactorsThrough D RM :=
  spectral_modal_missing h.IC h.neutralSpectrum h.comparisonSpectrum h.tacitComparison
    D RM selected h.R1 (fun f hf ht => (h.tacitComplementarity f hf).mp ht) tacit admitted

theorem human_authority_from_recovery {X V M : Type} {Y : A → Type}
    {χ : Charter A O} {o : O} {Human Machine : A → Prop}
    {governed : O → Prop} {standing canBear : A → O → Prop}
    (h : Recovery X V) (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (selected : h.IC D) (tacit : h.tacitComparison D)
    (admitted : FactorsThrough D RM → h.neutralSpectrum D)
    (completed : Completion governed standing) (grounded : ValidRootGrounded χ canBear standing)
    (confined : ∀ a, Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a))
    (exhaustive : ∀ a, ValidRoot χ canBear o a → Human a ∨ Machine a) (valid : governed o) :
    HasHumanAuthority χ canBear Human o :=
  human_authority D RM Rroot completed grounded
    (recovered_tacit_missing h D RM selected tacit admitted)
    confined faithful exhaustive valid

theorem singleton_human_principal {χ : Charter A O} {Human : A → Prop}
    {canBear : A → O → Prop} {o : O} {a : A}
    (authority : HasHumanAuthority χ canBear Human o)
    (singleton : ∀ b, χ.roots b o ↔ b = a) :
    Human a ∧ principal χ o = some a := by
  have hp := (roots_singleton_iff).mp singleton
  obtain ⟨r, hr⟩ := authority.1
  have eq : r = a := (singleton r).mp hr.1
  exact ⟨eq ▸ authority.2 r hr, principal_eq_some hp⟩

theorem principal_none_of_distinct_roots {χ : Charter A O} {o : O} {a b : A}
    (ha : χ.roots a o) (hb : χ.roots b o) (distinct : a ≠ b) : principal χ o = none := by
  classical
  unfold principal
  apply dif_neg
  rintro ⟨p, hp⟩
  exact distinct ((hp.2 a ha).trans (hp.2 b hb).symm)

/-- Fixed-episode specialization: changing t supplies a new collection of premises. -/
theorem human_authority_at_episode {E X V M : Type} {Y : A → Type}
    (t : E) (χ : E → Charter A O) (canBear standing : E → A → O → Prop)
    (governed : E → O → Prop) (Human Machine : A → Prop) (o : O)
    (D : E → X → V) (RM : E → X → M) (Rroot : E → (a : A) → X → Y a)
    (completed : Completion (governed t) (standing t))
    (grounded : ValidRootGrounded (χ t) (canBear t) (standing t))
    (missing : ¬ FactorsThrough (D t) (RM t))
    (confined : ∀ a, Machine a → FactorsThrough (Rroot t a) (RM t))
    (faithful : ∀ a, canBear t a o → FactorsThrough (D t) (Rroot t a))
    (exhaustive : ∀ a, ValidRoot (χ t) (canBear t) o a → Human a ∨ Machine a)
    (valid : governed t o) : HasHumanAuthority (χ t) (canBear t) Human o :=
  human_authority (D t) (RM t) (Rroot t) completed grounded missing confined faithful exhaustive valid

/-- Application bridge, not derived from standing labels alone. -/
def ClosureBridge (executor : T → A) (authClose : T → Prop)
    (validStanding : Z → O → T → Prop) (validClose : A → O → P → Prop)
    (z : Z) (o : O) (action : P) : Prop :=
  ∀ τ, authClose τ → validStanding z o τ → validClose (executor τ) o action

theorem valid_close_of_occurrence {executor : T → A} {authClose : T → Prop}
    {validStanding : Z → O → T → Prop} {validClose : A → O → P → Prop}
    {z : Z} {o : O} {action : P}
    (bridge : ClosureBridge executor authClose validStanding validClose z o action)
    {τ : T} (auth : authClose τ) (standing : validStanding z o τ) :
    validClose (executor τ) o action := bridge τ auth standing

/-- A channel is independent exactly when it factors through the complete localRegime basis.
An application must justify this equivalence against its source/access closure. -/
def LocalBasisComplete (localRegime : (X → V) → Prop) (RM : X → M) : Prop :=
  ∀ f, localRegime f ↔ FactorsThrough f RM

theorem nonlocal_of_missing {localRegime : (X → V) → Prop} {RM : X → M} {D : X → V}
    (complete : LocalBasisComplete localRegime RM) (missing : ¬ FactorsThrough D RM) : ¬ localRegime D :=
  fun h => missing ((complete D).mp h)

/-- Singleton principal with the core theorem's complete premise set, including governance. -/
theorem singleton_human_principal_from_premises {X V M : Type} {Y : A → Type}
    {χ : Charter A O} {o : O} {a : A} {Human Machine : A → Prop}
    {governed : O → Prop} {standing canBear : A → O → Prop}
    (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (completed : Completion governed standing) (grounded : ValidRootGrounded χ canBear standing)
    (missing : ¬ FactorsThrough D RM)
    (confined : ∀ a, Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a))
    (exhaustive : ∀ a, ValidRoot χ canBear o a → Human a ∨ Machine a)
    (valid : governed o) (singleton : ∀ b, χ.roots b o ↔ b = a) :
    Human a ∧ principal χ o = some a :=
  singleton_human_principal
    (human_authority D RM Rroot completed grounded missing confined faithful exhaustive valid) singleton

namespace Witness
inductive Actor where
  | human1 | human2 | machine
  deriving DecidableEq
abbrev World := Bool × Bool
def Human (a : Actor) : Prop := a ≠ .machine
def Machine (a : Actor) : Prop := a = .machine
def charter : Charter Actor Unit where
  roots a _ := Human a
  originates a _ := a = .human1
  delegates _ a b := Human a ∧ b = .machine
def D : World → Bool := Prod.snd
def RM : World → Bool := Prod.fst
def rootRepresentation : Actor → World → World
  | .machine, x => (x.1, false)
  | _, x => x
def canBear (a : Actor) (_ : Unit) : Prop := FactorsThrough D (rootRepresentation a)
def occurrenceStanding (_ : Unit) (o : Unit) (τ : Actor × Unit) : Prop :=
  ∃ r, ValidRoot charter canBear o r ∧ Delegated charter o r τ.1
def standing (a : Actor) (o : Unit) : Prop :=
  BearerStanding Prod.fst Prod.snd (fun _ => True) occurrenceStanding () o a
def spectrum (f : World → Bool) : Prop := FactorsThrough f RM
def recovery : Recovery World Bool where
  IC _ := True
  KC x y := x = y
  KF x y := x = y
  neutralSpectrum := spectrum
  comparisonSpectrum := spectrum
  explicitComparison := spectrum
  tacitComparison f := ¬ spectrum f
  C1 h := h
  C2 h := h
  R1 _ _ h := h
  R2 _ _ h := h
  explicitCharacterization _ _ := Iff.rfl
  tacitComplementarity _ _ := Iff.rfl

theorem authorization_missing : ¬ FactorsThrough D RM := by
  rintro ⟨decoder, eq⟩
  have same : D (false, false) = D (false, true) :=
    (eq (false, false)).trans (eq (false, true)).symm
  cases same

theorem human1_valid_root : ValidRoot charter canBear () .human1 :=
  ⟨by simp [charter, Human], ⟨D, fun _ => rfl⟩⟩

theorem human2_valid_root : ValidRoot charter canBear () .human2 :=
  ⟨by simp [charter, Human], ⟨D, fun _ => rfl⟩⟩

theorem machine_delegate_has_grounded_standing : standing .machine () :=
  ⟨(.machine, ()), rfl, rfl, trivial, .human1, human1_valid_root,
    Relation.ReflTransGen.single ⟨by simp [Human], rfl⟩⟩

theorem plural_human_authority : HasHumanAuthority charter canBear Human () := by
  apply human_authority_from_recovery recovery D RM rootRepresentation
    (χ := charter) (Human := Human) (Machine := Machine)
    (governed := ValidGoverned standing) (standing := standing) (canBear := canBear)
  · trivial
  · exact authorization_missing
  · exact id
  · exact fun _ h => h
  · intro a o h
    obtain ⟨τ, _, executed, _, root, rooted, path⟩ := h
    exact ⟨root, rooted, executed ▸ path⟩
  · intro a machine
    cases machine
    exact ⟨fun b => (b, false), fun _ => rfl⟩
  · exact fun _ h => h
  · intro a _
    cases a <;> simp [Human, Machine]
  · exact ⟨.machine, machine_delegate_has_grounded_standing⟩

theorem plural_authority_without_principal :
    HasHumanAuthority charter canBear Human () ∧ principal charter () = none :=
  ⟨plural_human_authority,
    principal_none_of_distinct_roots (a := .human1) (b := .human2)
      (by simp [charter, Human]) (by simp [charter, Human]) (by decide)⟩

/-- An authoritative decision is supplied by a root, not decoded by the
delegated executor from RM. This is a proof-carrying toy contract, not a
cryptographic authentication or an empirical model of consent. -/
structure RootDecision (world : World) where
  issuer : Actor
  rooted : ValidRoot charter canBear () issuer
  decision : Bool
  faithfulDecision : decision = D world

def humanDecision (world : World) : RootDecision world :=
  ⟨.human1, human1_valid_root, D world, rfl⟩

def closeWithRootDecision {world : World} (_outstanding : Bool) (executor : Actor)
    (token : RootDecision world) (_path : Delegated charter () token.issuer executor) : Bool :=
  false

theorem valid_delegated_closure (world : World) :
    closeWithRootDecision true .machine (humanDecision world)
      (Relation.ReflTransGen.single ⟨by simp [humanDecision, Human], rfl⟩) = false ∧
    (humanDecision world).decision = D world := ⟨rfl, rfl⟩

def emptyCharter : Charter Bool Unit where
  roots _ _ := False
  originates _ _ := False
  delegates _ _ _ := True

theorem nonrepresentability_without_root_grounding :
    (¬ FactorsThrough D RM) ∧
    Completion (fun _ : Unit => True) (fun _ : Bool => fun _ : Unit => True) ∧
    ¬ HasHumanAuthority emptyCharter (fun _ _ => True) (fun _ => True) () := by
  refine ⟨authorization_missing, ?_, ?_⟩
  · exact fun _ _ => ⟨false, trivial⟩
  · rintro ⟨⟨_, root⟩, _⟩
    exact root.1

theorem root_existence_without_machine_exclusion :
    (∃ a, ValidRoot (rooted true) (fun _ _ => True) () a) ∧
    ¬ HasHumanAuthority (rooted true) (fun _ _ => True) (fun a => a = false) () := by
  refine ⟨⟨true, rfl, trivial⟩, ?_⟩
  intro authority
  have bad := authority.2 true ⟨rfl, trivial⟩
  cases bad

theorem machine_exclusion_without_root_existence :
    (∀ a, ValidRoot emptyCharter (fun _ _ => True) () a → ¬ (a = true)) ∧
    ¬ HasHumanAuthority emptyCharter (fun _ _ => True) (fun a => a = false) () := by
  refine ⟨fun _ root => False.elim root.1, ?_⟩
  rintro ⟨⟨_, root⟩, _⟩
  exact root.1

def cyclicCharter : Charter Bool Unit where
  roots _ _ := False
  originates _ _ := False
  delegates _ a b := a ≠ b

theorem unrooted_delegation_cycle :
    Delegated cyclicCharter () false true ∧
    Delegated cyclicCharter () true false ∧
    ¬ (∃ r, ValidRoot cyclicCharter (fun _ _ => True) () r ∧
      Delegated cyclicCharter () r true) := by
  exact ⟨Relation.ReflTransGen.single (by simp [cyclicCharter]),
    Relation.ReflTransGen.single (by simp [cyclicCharter]), fun ⟨_, root, _⟩ => root.1⟩

def mixedCharter : Charter Actor Unit where
  roots _ _ := True
  originates a _ := a = .human1
  delegates _ a b := Human a ∧ b = .machine

theorem machine_cannot_bear : ¬ canBear .machine () := by
  intro bear
  exact authorization_missing
    (bear.trans ⟨fun b => (b, false), fun _ => rfl⟩)

theorem nominal_machine_root_not_valid :
    mixedCharter.roots .machine () ∧ Machine .machine ∧
    ¬ canBear .machine () ∧ ¬ ValidRoot mixedCharter canBear () .machine :=
  ⟨trivial, rfl, machine_cannot_bear, fun root => machine_cannot_bear root.2⟩

theorem human_authority_with_nominal_machine_root :
    HasHumanAuthority mixedCharter canBear Human () ∧
    mixedCharter.roots .machine () := by
  refine ⟨⟨⟨.human1, trivial, ⟨D, fun _ => rfl⟩⟩, ?_⟩, trivial⟩
  intro a valid machine
  subst a
  exact machine_cannot_bear valid.2

/-- Delegated payload is an occurrence input, not independent root information. -/
theorem delegated_payload_does_not_confer_root_competence (world : World) :
    (humanDecision world).decision = D world ∧
    standing .machine () ∧ ¬ canBear .machine () :=
  ⟨rfl, machine_delegate_has_grounded_standing, machine_cannot_bear⟩

theorem exclusion_without_exhaustive_categories :
    (∀ a, ValidRoot (rooted true) (fun _ _ => True) () a → ¬ (False : Prop)) ∧
    ¬ HasHumanAuthority (rooted true) (fun _ _ => True) (fun _ => False) () :=
  ⟨fun _ _ => id, fun authority => authority.2 true ⟨rfl, trivial⟩⟩
/-- Omit confinement: the Machine has an identity root basis and is a valid root. -/
theorem missing_confinement_countermodel :
    (¬ FactorsThrough D RM) ∧
    FactorsThrough D (id : World → World) ∧
    ValidRoot (rooted true) (fun _ _ => True) () true ∧
    ¬ FactorsThrough (id : World → World) RM := by
  refine ⟨authorization_missing, ⟨D, fun _ => rfl⟩, ⟨rfl, trivial⟩, ?_⟩
  intro h
  exact authorization_missing ((show FactorsThrough D (id : World → World) from ⟨D, fun _ => rfl⟩).trans h)

/-- Omit faithful bearing: confined information coexists with stipulated competence. -/
theorem missing_faithful_bearing_countermodel :
    (¬ FactorsThrough D RM) ∧ FactorsThrough RM RM ∧
    ValidRoot (rooted true) (fun _ _ => True) () true ∧
    ¬ FactorsThrough D RM :=
  ⟨authorization_missing, ⟨id, fun _ => rfl⟩, ⟨rfl, trivial⟩, authorization_missing⟩

theorem nominal_principal_without_competence :
    principal (rooted true) () = some true ∧
    ¬ ValidRoot (rooted true) (fun _ _ => False) () true :=
  ⟨principal_eq_some (rooted_principal true), fun h => h.2⟩

/-- Paper I valid closure alone supplies no Paper III occurrence standing. -/
theorem valid_close_without_occurrence_bridge :
    (True : Prop) ∧ ¬ BearerStanding (fun _ : Unit => true) (fun _ => ())
      (fun _ => True) (fun _ : Unit => fun _ : Unit => fun _ : Unit => False) () () true :=
  ⟨trivial, fun ⟨_, _, _, _, h⟩ => h⟩

def localSources (f : World → Bool) : Prop := FactorsThrough f RM

theorem independent_basis_and_boundary_payload :
    LocalBasisComplete localSources RM ∧ ¬ localSources D ∧
    (∀ w, (humanDecision w).decision = D w) :=
  ⟨fun _ => Iff.rfl, authorization_missing, fun _ => rfl⟩

/-- The selected authorization judgment in this toy model is D itself. -/
theorem authorization_judgment_relevance :
    FactorsThrough D (fun w => (RM w, D w)) ∧ ¬ FactorsThrough D RM :=
  ⟨⟨Prod.snd, fun _ => rfl⟩, authorization_missing⟩

def validClose (a : Actor) (_ : Unit) (_ : Unit) : Prop := standing a ()

theorem closure_bridge_witness :
    ClosureBridge (Prod.fst : Actor × Unit → Actor) (fun _ => True)
      occurrenceStanding validClose () () () := by
  intro τ _ hs
  exact ⟨τ, Subsingleton.elim _ _, rfl, trivial, hs⟩

/-- A supplied token determines the compound occurrence; it does not enter RM. -/
theorem boundary_payload_closure_bridge :
    validClose .machine () () ∧ standing .machine () ∧ ¬ localSources D :=
  ⟨machine_delegate_has_grounded_standing, machine_delegate_has_grounded_standing, authorization_missing⟩

end Witness
end PaperIII.HumanAuthority
