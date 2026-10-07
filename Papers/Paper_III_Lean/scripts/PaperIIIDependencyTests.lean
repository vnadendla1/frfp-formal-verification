import PaperIII
open AlgebraOfHumanAiCollaboration PaperIII.HumanAuthority

-- This test has no correctness relations, C1/C2, R2, or Explicit characterization.
example {X V M : Type} (IC neutral comparison tacit : (X → V) → Prop)
    (D : X → V) (RM : X → M) (selected : IC D)
    (forward : ∀ f, IC f → neutral f → comparison f)
    (eliminate : ∀ f, IC f → tacit f → ¬ comparison f)
    (classified : tacit D) (admitted : FactorsThrough D RM → neutral D) :
    ¬ FactorsThrough D RM :=
  spectral_modal_missing IC neutral comparison tacit D RM selected forward eliminate classified admitted

-- No recovery object or Paper I role package appears in the exclusion interface.
example {A O X V M : Type} {Y : A → Type}
    (χ : PaperIII.Charter A O) (o : O) (Machine : A → Prop) (canBear : A → O → Prop)
    (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (missing : ¬ FactorsThrough D RM)
    (confined : ∀ a, ValidRoot χ canBear o a → Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a)) :
    ∀ a, ValidRoot χ canBear o a → ¬ Machine a :=
  no_machine_valid_root D RM Rroot missing confined faithful

-- Classification and confinement use the same valid-root domain.
example {A O X V M : Type} {Y : A → Type}
    (χ : PaperIII.Charter A O) (o : O) (Human Machine : A → Prop)
    (canBear standing : A → O → Prop) (governed : O → Prop)
    (D : X → V) (RM : X → M) (Rroot : (a : A) → X → Y a)
    (completed : Completion governed standing) (grounded : ValidRootGrounded χ canBear standing)
    (missing : ¬ FactorsThrough D RM)
    (confined : ∀ a, ValidRoot χ canBear o a → Machine a → FactorsThrough (Rroot a) RM)
    (faithful : ∀ a, canBear a o → FactorsThrough D (Rroot a))
    (classified : ∀ a, ValidRoot χ canBear o a → Human a ∨ Machine a)
    (valid : governed o) : HasHumanAuthority χ canBear Human o :=
  human_authority D RM Rroot completed grounded missing confined faithful classified valid

-- Allocation information is independent of RM and of any Recovery package.
example {E C : Type} {c : E → C} {need : E → Prop}
    {alloc : C → PaperIII.DefaultAuthority.PrincipalType}
    (valid : PaperIII.DefaultAuthority.ValidityPreserving c need alloc)
    (coverage : PaperIII.DefaultAuthority.EveryClassNeedsHuman c need) :
    ∀ e, alloc (c e) = .human :=
  PaperIII.DefaultAuthority.human_default_of_class_coverage valid coverage
