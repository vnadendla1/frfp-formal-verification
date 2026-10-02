import FirstPrinciplesRevision.RecoveryDomain

/-!
Paper II worked comparison with a typed interface and both alignment axes.
This is a stipulated finite comparison model, not recovered frozen-main FRFP
semantics, and supplies no P0 evidence.
-/
namespace FirstPrinciplesRevision.ConcreteRecovery
open ETSplit
abbrev State := Bool × Bool
abbrev Content := State → Bool

inductive Item where
  | safety | authorization
  deriving DecidableEq

def interpret : Item → Content
  | .safety => Prod.fst
  | .authorization => Prod.snd

/-- Independently declared correctness: both safety and authorization matter. -/
def KC (x y : State) : Prop := x.1 = y.1 ∧ x.2 = y.2
/-- The comparison lists the same obligations in reverse order and reverse polarity. -/
def KF (x y : State) : Prop := (!x.2, !x.1) = (!y.2, !y.1)

theorem C1 {x y : State} (h : KC x y) : KF x y := by
  have heq : x = y := Prod.ext h.1 h.2
  subst y
  rfl

theorem C2 {x y : State} (h : KF x y) : KC x y := by
  have h1 := congrArg Prod.snd h
  have h2 := congrArg Prod.fst h
  constructor
  · simpa using congrArg Bool.not h1
  · simpa using congrArg Bool.not h2

theorem correctness_alignment : KC = KF := semantic_alignment C1 C2

/-- Every candidate Boolean observation is correctness-bearing in this model,
since the two independently declared criteria separate the entire state space. -/
theorem contents_respect_correctness (f : Content) {x y : State} (h : KC x y) : f x = f y :=
  congrArg f (Prod.ext h.1 h.2)

def contentEquiv : Setoid Content where
  r f g := Factors f g ∧ Factors g f
  iseqv := ⟨fun _ => ⟨⟨id, fun _ => rfl⟩, ⟨id, fun _ => rfl⟩⟩,
    fun h => ⟨h.2, h.1⟩,
    fun h k => ⟨factors_trans h.1 k.1, factors_trans k.2 h.2⟩⟩

/-- Typed interface into correctness contents modulo mutual factorization. -/
def interface (i : Item) : Quotient contentEquiv := Quotient.mk _ (interpret i)
/-- Comparison domain is exactly the preimage of the interface image. -/
def IC (f : Content) : Prop := ∃ i, Quotient.mk contentEquiv f = interface i

theorem interpreted_item_in_domain (i : Item) : IC (interpret i) := ⟨i, rfl⟩

theorem domain_invariant {f g : Content} (h : contentEquiv.r f g) : IC f ↔ IC g := by
  have heq : Quotient.mk contentEquiv f = Quotient.mk contentEquiv g := Quotient.sound h
  unfold IC
  rw [heq]

/-- Two singleton representation regimes: direct checklist and reversed code.
Neither representation carries the authorization coordinate. -/
def neutralRep : State → Bool := Prod.fst
def comparisonRep (x : State) : Bool := !x.1

def neutralSpectrum (f : Content) : Prop := Factors f neutralRep
def comparisonSpectrum (f : Content) : Prop := Factors f comparisonRep

theorem R1 (f : Content) : neutralSpectrum f → comparisonSpectrum f := by
  rintro ⟨d, hd⟩
  refine ⟨fun b => d (!b), ?_⟩
  intro x
  simpa [comparisonRep, neutralRep] using hd x

theorem R2 (f : Content) : comparisonSpectrum f → neutralSpectrum f := by
  rintro ⟨d, hd⟩
  exact ⟨fun b => d (!b), hd⟩

/-- Modal predicates come from the comparison representation's kernel test,
separately from the neutral spectrum's decoder definition. -/
def comparisonExplicit (f : Content) : Prop := KerLE comparisonRep f
def comparisonTacit (f : Content) : Prop :=
  ∃ x y, comparisonRep x = comparisonRep y ∧ f x ≠ f y

theorem explicit_characterization (f : Content) :
    comparisonExplicit f ↔ comparisonSpectrum f :=
  (factorization_criterion).symm

theorem tacit_characterization (f : Content) :
    comparisonTacit f ↔ ¬ comparisonSpectrum f := by
  constructor
  · rintro ⟨x, y, hr, hne⟩ hf
    exact hne (factors_implies_kerLE hf hr)
  · intro hn
    classical
    apply Classical.byContradiction
    intro hnone
    apply hn
    apply factors_of_kerLE
    intro x y hr
    apply Classical.byContradiction
    intro hne
    exact hnone ⟨x, y, hr, hne⟩

def obligations : FRFPMerge.RecoveryObligations Content where
  IC := IC
  neutralSpectrum := neutralSpectrum
  frfpSpectrum := comparisonSpectrum
  explicitFRFP := comparisonExplicit
  tacitFRFP := comparisonTacit
  R1 := fun f _ => R1 f
  R2 := fun f _ => R2 f
  explicitCharacterization := fun f _ => explicit_characterization f
  tacitComplementarity := fun f _ => tacit_characterization f

/-- Both semantic equality and modal recovery, with an explicit image domain. -/
theorem concrete_recovery : KC = KF ∧
    (∀ f, IC f → (neutralSpectrum f ↔ comparisonExplicit f)) ∧
    (∀ f, IC f → (¬ neutralSpectrum f ↔ comparisonTacit f)) :=
  ⟨correctness_alignment, FRFPMerge.conditional_explicit_recovery obligations,
    FRFPMerge.conditional_tacit_recovery obligations⟩

theorem safety_representable : neutralSpectrum (interpret .safety) :=
  ⟨id, fun _ => rfl⟩

theorem authorization_not_representable : ¬ neutralSpectrum (interpret .authorization) := by
  intro h
  have heq := factors_implies_kerLE h (x := (false, false)) (x' := (false, true)) rfl
  cases heq

theorem both_classes_occupied :
    (∃ f, IC f ∧ comparisonExplicit f) ∧ (∃ f, IC f ∧ comparisonTacit f) := by
  exact ⟨⟨interpret .safety, interpreted_item_in_domain _,
      (explicit_characterization _).mpr (R1 _ safety_representable)⟩,
    ⟨interpret .authorization, interpreted_item_in_domain _,
      (tacit_characterization _).mpr (fun h => authorization_not_representable (R2 _ h))⟩⟩

/-- Representation-axis negative control: adding the joint record only on the
comparison side violates R2 for an included item. -/
def expandedComparisonSpectrum (f : Content) : Prop :=
  comparisonSpectrum f ∨ Factors f (fun x : State => x)

theorem expanded_comparison_breaks_R2 :
    ∃ f, IC f ∧ expandedComparisonSpectrum f ∧ ¬ neutralSpectrum f := by
  exact ⟨interpret .authorization, interpreted_item_in_domain _,
    Or.inr ⟨Prod.snd, fun _ => rfl⟩, authorization_not_representable⟩

/-- Semantic-axis negative control: omitting authorization loses a correctness
distinction even when representation regimes stay fixed. -/
def safetyOnlyCorrectness (x y : State) : Prop := x.1 = y.1

theorem omitted_authorization_breaks_C1 :
    ∃ x y, safetyOnlyCorrectness x y ∧ ¬ KF x y := by
  refine ⟨(false, false), (false, true), rfl, ?_⟩
  intro h
  have bad := (C2 h).2
  cases bad

/-- The typed interface does not collapse the two selected cognitive items. -/
theorem interface_injective : Function.Injective interface := by
  intro i j h
  cases i <;> cases j
  · rfl
  · exact (authorization_not_representable (Quotient.exact h).2).elim
  · exact (authorization_not_representable (Quotient.exact h).1).elim
  · rfl

/-- The shorthand spectrum is the preserved paper's singleton-regime definition. -/
theorem neutral_regime_definition (f : Content) :
    neutralSpectrum f ↔ Representable (fun _ : Unit => Bool)
      (fun _ : Unit => neutralRep) (fun _ => True) f := by
  constructor
  · intro h; exact ⟨(), trivial, h⟩
  · rintro ⟨_, _, h⟩; exact h

theorem comparison_regime_definition (f : Content) :
    comparisonSpectrum f ↔ Representable (fun _ : Unit => Bool)
      (fun _ : Unit => comparisonRep) (fun _ => True) f := by
  constructor
  · intro h; exact ⟨(), trivial, h⟩
  · rintro ⟨_, _, h⟩; exact h

/-- Expanding only the neutral regime yields the opposite spectrum failure. -/
theorem expanded_neutral_breaks_R1 :
    ∃ f, IC f ∧ (neutralSpectrum f ∨ Factors f (fun x : State => x)) ∧
      ¬ comparisonSpectrum f := by
  exact ⟨interpret .authorization, interpreted_item_in_domain _,
    Or.inr ⟨Prod.snd, fun _ => rfl⟩, fun h => authorization_not_representable (R2 _ h)⟩

/-- If comparison correctness ignores authorization, the neutral theory adds
an absent distinction, violating C2 instead of C1. -/
theorem extra_neutral_distinction_breaks_C2 :
    ∃ x y, safetyOnlyCorrectness x y ∧ ¬ KC x y := by
  refine ⟨(false, false), (false, true), rfl, ?_⟩
  intro h
  cases h.2
end FirstPrinciplesRevision.ConcreteRecovery
