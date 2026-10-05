/-!
Machine verification of the mathematical core of
"Conditions for Recovering the Explicit-Tacit Separation".

The paper's factorization criterion needs a small repair: as written, it is
false when the semantic domain and target codomain are empty but the
representation codomain is inhabited.  The main development therefore assumes
`Nonempty X`, which is natural for a semantic state space and supplies every
target actually occurring as the codomain of a function from `X` with an
inhabitant.
-/

universe u v w uι uρ

namespace ETSplit

section Factorization

variable {X : Type u} {Y : Type v} {Z : Type w}

/-- `f` factors through `r` via a total set-theoretic decoder. -/
def Factors (f : X → Z) (r : X → Y) : Prop :=
  ∃ d : Y → Z, ∀ x, f x = d (r x)

/-- Every distinction collapsed by `r` is also collapsed by `f`. -/
def KerLE (r : X → Y) (f : X → Z) : Prop :=
  ∀ ⦃x x'⦄, r x = r x' → f x = f x'

theorem factors_implies_kerLE {f : X → Z} {r : X → Y} :
    Factors f r → KerLE r f := by
  rintro ⟨d, hd⟩ x x' h
  rw [hd x, hd x', h]

theorem factors_of_kerLE [Nonempty Z] {f : X → Z} {r : X → Y} :
    KerLE r f → Factors f r := by
  intro h
  classical
  let d : Y → Z := fun y =>
    if hy : ∃ x, r x = y then f (Classical.choose hy)
    else Classical.choice inferInstance
  refine ⟨d, ?_⟩
  intro x
  have hx : ∃ x', r x' = r x := ⟨x, rfl⟩
  simp only [d, dif_pos hx]
  exact h (Classical.choose_spec hx).symm

theorem factorization_criterion [Nonempty Z] {f : X → Z} {r : X → Y} :
    Factors f r ↔ KerLE r f :=
  ⟨factors_implies_kerLE, factors_of_kerLE⟩

theorem factors_trans {W : Type} {f : X → Z} {g : X → Y} {r : X → W} :
    Factors f g → Factors g r → Factors f r := by
  rintro ⟨d₁, h₁⟩ ⟨d₂, h₂⟩
  refine ⟨d₁ ∘ d₂, ?_⟩
  intro x
  simp only [Function.comp_apply, ← h₂ x, ← h₁ x]

theorem factors_through_injective [Nonempty Z]
    {f : X → Z} {r : X → Y} (hr : Function.Injective r) : Factors f r := by
  apply factors_of_kerLE
  intro x x' h
  exact congrArg f (hr h)

theorem factors_through_id (f : X → Z) : Factors f (id : X → X) := by
  exact ⟨f, fun _ => rfl⟩

/-- Formal counterexample to the paper's unqualified Lemma 1. -/
theorem empty_domain_counterexample :
    let f : Empty → Empty := fun x => nomatch x
    let r : Empty → Unit := fun x => nomatch x
    KerLE r f ∧ ¬ Factors f r := by
  dsimp
  constructor
  · intro x
    exact nomatch x
  · rintro ⟨d, _⟩
    exact nomatch d ()

end Factorization

section Correctness

variable {ι : Type uι} {X : Type u} (A : ι → Type v)
variable (J : (i : ι) → X → A i)

/-- Intersection of the kernels of all primitive correctness criteria. -/
def CommonKer (x x' : X) : Prop := ∀ i, J i x = J i x'

theorem commonKer_refl (x : X) : CommonKer A J x x := fun _ => rfl
theorem commonKer_symm {x x' : X} : CommonKer A J x x' → CommonKer A J x' x :=
  fun h i => (h i).symm
theorem commonKer_trans {x y z : X} :
    CommonKer A J x y → CommonKer A J y z → CommonKer A J x z :=
  fun h₁ h₂ i => (h₁ i).trans (h₂ i)

def correctnessSetoid : Setoid X where
  r := CommonKer A J
  iseqv := ⟨commonKer_refl A J, commonKer_symm A J, commonKer_trans A J⟩

def CorrectnessQuotient := Quotient (correctnessSetoid A J)

def correctnessQuotientMap (x : X) : CorrectnessQuotient A J :=
  Quotient.mk (correctnessSetoid A J) x

theorem quotient_eq_iff {x x' : X} :
    correctnessQuotientMap A J x = correctnessQuotientMap A J x' ↔
      CommonKer A J x x' := by
  constructor
  · exact Quotient.exact
  · intro h
    apply Quotient.sound
    exact h

def AllCriteriaFactor {Y : Type} (r : X → Y) : Prop :=
  ∀ i, Factors (J i) r

theorem correctness_preservation [Nonempty X] {Y : Type} {r : X → Y} :
    AllCriteriaFactor A J r ↔
      ∀ ⦃x x'⦄, r x = r x' → CommonKer A J x x' := by
  constructor
  · intro h x x' hr i
    exact factors_implies_kerLE (h i) hr
  · intro h i
    let x₀ : X := Classical.choice inferInstance
    letI : Nonempty (A i) := ⟨J i x₀⟩
    apply factors_of_kerLE
    intro x x' hr
    exact h hr i

theorem canonical_correctness_quotient [Nonempty X] {Y : Type} {r : X → Y} :
    AllCriteriaFactor A J r ↔ Factors (correctnessQuotientMap A J) r := by
  rw [correctness_preservation A J]
  let q := correctnessQuotientMap A J
  haveI : Nonempty (CorrectnessQuotient A J) :=
    ⟨q (Classical.choice inferInstance)⟩
  rw [factorization_criterion]
  constructor
  · intro h x x' hr
    exact (quotient_eq_iff A J).2 (h hr)
  · intro h x x' hr
    exact (quotient_eq_iff A J).1 (h hr)

/-- A content depends only on correctness state. -/
def IsCorrectnessContent {Z : Type} (f : X → Z) : Prop :=
  ∀ ⦃x x'⦄, CommonKer A J x x' → f x = f x'

theorem content_factors_through_quotient [Nonempty X] {Z : Type} {f : X → Z} :
    IsCorrectnessContent A J f ↔ Factors f (correctnessQuotientMap A J) := by
  let x₀ : X := Classical.choice inferInstance
  letI : Nonempty Z := ⟨f x₀⟩
  rw [factorization_criterion]
  constructor
  · intro h x x' hq
    exact h ((quotient_eq_iff A J).1 hq)
  · intro h x x' hk
    exact h ((quotient_eq_iff A J).2 hk)

/-- Proposition 1, aggregate-to-item direction. -/
theorem aggregate_implies_item {Y Z : Type} {r : X → Y} {f : X → Z}
    (hAggregate : Factors (correctnessQuotientMap A J) r)
    (hContent : Factors f (correctnessQuotientMap A J)) :
    Factors f r :=
  factors_trans hContent hAggregate

/-- Proposition 1, joint-to-individual direction, represented without choosing a
particular encoding of heterogeneous families. -/
theorem joint_implies_individual {Y : Type} {F : Type}
    (content : F → (i : ι) → X → A i) (r : X → Y)
    (hJoint : ∀ a i, Factors (content a i) r) :
    ∀ a i, Factors (content a i) r := hJoint

end Correctness

section Regimes

variable {X : Type u} {Z : Type v}
variable {ρ : Type uρ} (Y : ρ → Type w) (R : (k : ρ) → X → Y k)
variable (Allowed : ρ → Prop)

def Representable (f : X → Z) : Prop :=
  ∃ k, Allowed k ∧ Factors f (R k)

def Spectrum (I : (X → Z) → Prop) (f : X → Z) : Prop :=
  I f ∧ Representable Y R Allowed f

theorem operational_spectrum_inclusion
    (OperationalFactors : {k : ρ} → (X → Z) → (X → Y k) → Prop)
    (hop : ∀ {k f r}, OperationalFactors (k := k) f r → Factors f r)
    {I : (X → Z) → Prop} {f : X → Z}
    (h : I f ∧ ∃ k, Allowed k ∧ OperationalFactors (k := k) f (R k)) :
    Spectrum Y R Allowed I f := by
  rcases h with ⟨hI, k, hk, hf⟩
  exact ⟨hI, k, hk, hop hf⟩

end Regimes

section Recovery

variable {Content : Type}
variable (IC NeutralSpec FRFPSpec ExplicitFRFP TacitFRFP : Content → Prop)

def NeutralRep (f : Content) : Prop := IC f ∧ NeutralSpec f
def NeutralNonRep (f : Content) : Prop := IC f ∧ ¬ NeutralSpec f

/-- The representational half of Theorem 3. -/
theorem recovery_positive
    (R1 : ∀ f, NeutralSpec f → FRFPSpec f)
    (R2 : ∀ f, FRFPSpec f → NeutralSpec f)
    (hExplicit : ∀ f, ExplicitFRFP f ↔ IC f ∧ FRFPSpec f) :
    ∀ f, NeutralRep IC NeutralSpec f ↔ ExplicitFRFP f := by
  intro f
  rw [hExplicit]
  constructor
  · rintro ⟨hI, hN⟩
    exact ⟨hI, R1 f hN⟩
  · rintro ⟨hI, hF⟩
    exact ⟨hI, R2 f hF⟩

/-- The complementary Tacit half of Theorem 3. -/
theorem recovery_negative
    (R1 : ∀ f, NeutralSpec f → FRFPSpec f)
    (R2 : ∀ f, FRFPSpec f → NeutralSpec f)
    (hTacit : ∀ f, TacitFRFP f ↔ IC f ∧ ¬ FRFPSpec f) :
    ∀ f, NeutralNonRep IC NeutralSpec f ↔ TacitFRFP f := by
  intro f
  rw [hTacit]
  constructor
  · rintro ⟨hI, hN⟩
    exact ⟨hI, fun hF => hN (R2 f hF)⟩
  · rintro ⟨hI, hF⟩
    exact ⟨hI, fun hN => hF (R1 f hN)⟩

theorem semantic_alignment
    {X : Type} {KC KF : X → X → Prop}
    (C1 : ∀ {x y}, KC x y → KF x y)
    (C2 : ∀ {x y}, KF x y → KC x y) : KC = KF := by
  funext x y
  apply propext
  exact ⟨C1, C2⟩

end Recovery

section BoundaryAndRevision

variable {X Q S : Type}

/-- Injection form of the finite-string boundary result.  Taking `S = String`
turns the right side into the usual "at most countable" condition. -/
theorem unrestricted_representation_iff_injects
    [Nonempty X] [Nonempty Q] (q : X → Q) (hq : Function.Surjective q) :
    (∃ r : X → S, Factors q r) ↔
      ∃ e : Q → S, Function.Injective e := by
  constructor
  · rintro ⟨r, d, hd⟩
    classical
    have hdSurj : Function.Surjective d := by
      intro z
      rcases hq z with ⟨x, hx⟩
      refine ⟨r x, ?_⟩
      simpa [hx] using (hd x).symm
    let e : Q → S := fun z => Classical.choose (hdSurj z)
    refine ⟨e, ?_⟩
    intro a b hab
    have ha : d (e a) = a := Classical.choose_spec (hdSurj a)
    have hb : d (e b) = b := Classical.choose_spec (hdSurj b)
    exact ha.symm.trans ((congrArg d hab).trans hb)
  · rintro ⟨e, he⟩
    refine ⟨e ∘ q, ?_⟩
    apply factors_of_kerLE
    intro x y h
    exact he h

/-- Abstract core of Proposition 4: if the new quotient carries a newly admitted
criterion, an old representation that loses that criterion cannot carry the new
quotient. -/
theorem correctness_revision_invalidation
    {Y Z : Type} {qNew : X → Q} {newCriterion : X → Z} {oldRep : X → Y}
    (hNewCriterion : Factors newCriterion qNew)
    (hLost : ¬ Factors newCriterion oldRep) :
    ¬ Factors qNew oldRep := by
  intro hNew
  exact hLost (factors_trans hNewCriterion hNew)

end BoundaryAndRevision

section Examples

abbrev ReleaseState := Bool × Bool

def safety (x : ReleaseState) : Bool := x.1
def authorization (x : ReleaseState) : Bool := x.2
def safetyRep (x : ReleaseState) : ReleaseState := (x.1, false)
def jointRep (x : ReleaseState) : ReleaseState := x

theorem safety_through_safetyRep : Factors safety safetyRep := by
  exact ⟨fun y => y.1, fun _ => rfl⟩

theorem authorization_not_through_safetyRep : ¬ Factors authorization safetyRep := by
  intro h
  have hk := factors_implies_kerLE h
  have hs : safetyRep (true, false) = safetyRep (true, true) := rfl
  have hfalse : false = true := hk hs
  exact Bool.noConfusion hfalse

theorem authorization_through_jointRep : Factors authorization jointRep := by
  exact ⟨authorization, fun _ => rfl⟩

theorem semantic_failure_witness :
    safety (true, false) = safety (true, true) ∧
    authorization (true, false) ≠ authorization (true, true) := by
  decide

end Examples

end ETSplit
