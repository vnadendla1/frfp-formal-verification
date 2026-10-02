import FirstPrinciplesRevision.RecoveryDomain

namespace FirstPrinciplesRevision.RecoveryDomainChecks
open FRFPMerge

/-- The two included items occupy opposite classes. The excluded item has
arbitrary modal predicates and intentionally mismatching representation spectra. -/
def domainModel (outsideExplicit outsideTacit : Prop) : RecoveryObligations (Option Bool) where
  IC f := f ≠ none
  neutralSpectrum f := f = some true
  frfpSpectrum f := f = none ∨ f = some true
  explicitFRFP f := match f with | none => outsideExplicit | some b => b = true
  tacitFRFP f := match f with | none => outsideTacit | some b => b = false
  R1 := by intro f _ hf; exact Or.inr hf
  R2 := by intro f hi hf; exact hf.resolve_left hi
  explicitCharacterization := by
    intro f hi
    cases f with
    | none => exact (hi rfl).elim
    | some b => simp
  tacitComplementarity := by
    intro f hi
    cases f with
    | none => exact (hi rfl).elim
    | some b => cases b <;> simp

theorem included_explicit (e t : Prop) :
    (domainModel e t).neutralSpectrum (some true) ↔ (domainModel e t).explicitFRFP (some true) :=
  conditional_explicit_recovery (domainModel e t) _ (by intro h; cases h)

theorem included_tacit (e t : Prop) :
    ¬ (domainModel e t).neutralSpectrum (some false) ↔ (domainModel e t).tacitFRFP (some false) :=
  conditional_tacit_recovery (domainModel e t) _ (by intro h; cases h)

theorem outside_modal_freedom (e t : Prop) :
    ((domainModel e t).explicitFRFP none ↔ e) ∧ ((domainModel e t).tacitFRFP none ↔ t) :=
  ⟨Iff.rfl, Iff.rfl⟩

theorem outside_spectra_may_differ (e t : Prop) :
    (domainModel e t).frfpSpectrum none ∧ ¬ (domainModel e t).neutralSpectrum none :=
  ⟨Or.inl rfl, by intro h; cases h⟩

/-- The removed unconditional conclusion really would be false in an admitted model. -/
theorem unrestricted_recovery_fails :
    ¬ (∀ f, (domainModel True True).neutralSpectrum f ↔ (domainModel True True).explicitFRFP f) := by
  intro h
  have bad := (h none).mpr trivial
  cases bad
end FirstPrinciplesRevision.RecoveryDomainChecks
