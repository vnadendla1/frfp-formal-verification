import PaperIII.HumanAuthority

/-! Allocation uses all information available before authorization; its view is
not assumed to be RM. Necessity, validity, singleton standing and competence
remain supplied premises. The policy label alone supplies no actual authority. -/
namespace PaperIII.DefaultAuthority
inductive PrincipalType where
  | human | machine
  deriving DecidableEq

def ValidityPreserving {E C : Type} (c : E → C) (needHuman : E → Prop)
    (alloc : C → PrincipalType) : Prop :=
  ∀ e, needHuman e → alloc (c e) = .human

def EveryClassNeedsHuman {E C : Type} (c : E → C) (needHuman : E → Prop) : Prop :=
  ∀ e, ∃ witness, c witness = c e ∧ needHuman witness

theorem human_of_indistinguishable {E C : Type} {c : E → C}
    {needHuman : E → Prop} {alloc : C → PrincipalType}
    (valid : ValidityPreserving c needHuman alloc) {e e' : E}
    (same : c e = c e') (needed : needHuman e) :
    alloc (c e) = .human ∧ alloc (c e') = .human := by
  have h := valid e needed
  exact ⟨h, same ▸ h⟩

theorem human_default_of_class_coverage {E C : Type} {c : E → C}
    {needHuman : E → Prop} {alloc : C → PrincipalType}
    (valid : ValidityPreserving c needHuman alloc)
    (coverage : EveryClassNeedsHuman c needHuman) :
    ∀ e, alloc (c e) = .human := by
  intro e
  obtain ⟨w, same, needed⟩ := coverage e
  exact (human_of_indistinguishable valid same needed).2

/-- Actual principalhood needs a Human bearer, nominal singleton, and CanBear. -/
theorem human_valid_principal_of_indistinguishable {E C A O : Type}
    {c : E → C} {needHuman : E → Prop} {alloc : C → PrincipalType}
    (valid : ValidityPreserving c needHuman alloc)
    (χ : E → Charter A O) (obligation : E → O) (bearer : E → A)
    (Human : A → Prop) (canBear : E → A → O → Prop)
    (realized : ∀ e, alloc (c e) = .human → Human (bearer e))
    (singleton : ∀ e a, (χ e).roots a (obligation e) ↔ a = bearer e)
    (competent : ∀ e, canBear e (bearer e) (obligation e))
    {e e' : E} (same : c e = c e') (needed : needHuman e) :
    Human (bearer e') ∧ IsPrincipal (χ e') (obligation e') (bearer e') ∧
      HumanAuthority.ValidRoot (χ e') (canBear e') (obligation e') (bearer e') := by
  have hp := (roots_singleton_iff).mp (singleton e')
  exact ⟨realized e' (human_of_indistinguishable valid same needed).2,
    hp, hp.1, competent e'⟩

theorem human_valid_principals_of_class_coverage {E C A O : Type}
    {c : E → C} {needHuman : E → Prop} {alloc : C → PrincipalType}
    (valid : ValidityPreserving c needHuman alloc)
    (coverage : EveryClassNeedsHuman c needHuman)
    (χ : E → Charter A O) (obligation : E → O) (bearer : E → A)
    (Human : A → Prop) (canBear : E → A → O → Prop)
    (realized : ∀ e, alloc (c e) = .human → Human (bearer e))
    (singleton : ∀ e a, (χ e).roots a (obligation e) ↔ a = bearer e)
    (competent : ∀ e, canBear e (bearer e) (obligation e)) :
    ∀ e, Human (bearer e) ∧ IsPrincipal (χ e) (obligation e) (bearer e) ∧
      HumanAuthority.ValidRoot (χ e) (canBear e) (obligation e) (bearer e) := by
  intro e
  obtain ⟨w, same, needed⟩ := coverage e
  exact human_valid_principal_of_indistinguishable valid χ obligation bearer
    Human canBear realized singleton competent same needed

/-- An informative allocation view separates episodes: one Human-required case
is insufficient to force a universal default. -/
theorem some_need_does_not_imply_global_default :
    ∃ (c : Bool → Bool) (needHuman : Bool → Prop) (alloc : Bool → PrincipalType),
      ValidityPreserving c needHuman alloc ∧ (∃ e, needHuman e) ∧
      alloc (c false) = .machine := by
  refine ⟨id, fun e => e = true, fun e => if e then .human else .machine, ?_,
    ⟨true, rfl⟩, rfl⟩
  intro e h
  cases h
  rfl

theorem necessity_without_validity_does_not_force_human :
    ∃ (c : Bool → Unit) (needHuman : Bool → Prop) (alloc : Unit → PrincipalType),
      EveryClassNeedsHuman c needHuman ∧ ¬ ValidityPreserving c needHuman alloc ∧
      alloc (c true) = .machine := by
  refine ⟨fun _ => (), fun _ => True, fun _ => .machine, ?_, ?_, rfl⟩
  · intro e
    exact ⟨true, rfl, trivial⟩
  · intro valid
    cases valid true trivial

/-- No competent Human means no valid Human principal, not Machine succession. -/
theorem no_human_valid_principal_without_competence {A O : Type}
    (χ : Charter A O) (o : O) (Human : A → Prop) (canBear : A → O → Prop)
    (unavailable : ¬ ∃ a, Human a ∧ canBear a o) :
    ¬ ∃ a, Human a ∧ IsPrincipal χ o a ∧ HumanAuthority.ValidRoot χ canBear o a := by
  rintro ⟨a, human, _, _, competent⟩
  exact unavailable ⟨a, human, competent⟩
end PaperIII.DefaultAuthority
