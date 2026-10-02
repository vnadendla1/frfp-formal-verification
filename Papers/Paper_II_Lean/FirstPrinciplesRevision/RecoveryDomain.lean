import ETSplit

/-! Paper II recovery on the comparison domain only. Kept independent of main
FRFP so the revised interface can be checked with the preserved paper library. -/
namespace FRFPMerge

structure RecoveryObligations (Content : Type) where
  IC : Content → Prop
  neutralSpectrum : Content → Prop
  frfpSpectrum : Content → Prop
  explicitFRFP : Content → Prop
  tacitFRFP : Content → Prop
  R1 : ∀ f, IC f → neutralSpectrum f → frfpSpectrum f
  R2 : ∀ f, IC f → frfpSpectrum f → neutralSpectrum f
  explicitCharacterization : ∀ f, IC f → (explicitFRFP f ↔ frfpSpectrum f)
  tacitComplementarity : ∀ f, IC f → (tacitFRFP f ↔ ¬ frfpSpectrum f)

/-- Apply the unchanged positive recovery theorem to the comparison subtype. -/
theorem conditional_explicit_recovery (h : RecoveryObligations Content) :
    ∀ f, h.IC f → (h.neutralSpectrum f ↔ h.explicitFRFP f) := by
  let Domain := { f : Content // h.IC f }
  have recovered := ETSplit.recovery_positive
    (fun _ : Domain => True)
    (fun f : Domain => h.neutralSpectrum f.val)
    (fun f : Domain => h.frfpSpectrum f.val)
    (fun f : Domain => h.explicitFRFP f.val)
    (fun f => h.R1 f.val f.property)
    (fun f => h.R2 f.val f.property)
    (by intro f; simpa using h.explicitCharacterization f.val f.property)
  intro f hf
  simpa [ETSplit.NeutralRep] using recovered ⟨f, hf⟩

/-- No condition is imposed on tacit classifications outside the subtype. -/
theorem conditional_tacit_recovery (h : RecoveryObligations Content) :
    ∀ f, h.IC f → (¬ h.neutralSpectrum f ↔ h.tacitFRFP f) := by
  let Domain := { f : Content // h.IC f }
  have recovered := ETSplit.recovery_negative
    (fun _ : Domain => True)
    (fun f : Domain => h.neutralSpectrum f.val)
    (fun f : Domain => h.frfpSpectrum f.val)
    (fun f : Domain => h.tacitFRFP f.val)
    (fun f => h.R1 f.val f.property)
    (fun f => h.R2 f.val f.property)
    (by intro f; simpa using h.tacitComplementarity f.val f.property)
  intro f hf
  simpa [ETSplit.NeutralNonRep] using recovered ⟨f, hf⟩
end FRFPMerge
