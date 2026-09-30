/-!
# Function factorization and informational kernels

This module formalizes the paper's basic criterion for when a target map can be
recovered from a representation. No Human/AI or FRFP-specific structure enters
the definitions.
-/

namespace AlgebraOfHumanAiCollaboration

/-- `target` factors through `representation` when some decoder recovers it. -/
def FactorsThrough (target : W → A) (representation : W → E) : Prop :=
  ∃ decoder : E → A, ∀ w, target w = decoder (representation w)

/-- Every distinction collapsed by `representation` is also collapsed by `target`. -/
def KernelIncluded (representation : W → E) (target : W → A) : Prop :=
  ∀ ⦃w₁ w₂⦄, representation w₁ = representation w₂ → target w₁ = target w₂

theorem factorsThrough_kernelIncluded
    (h : FactorsThrough target representation) :
    KernelIncluded representation target := by
  obtain ⟨decoder, hdecoder⟩ := h
  intro w₁ w₂ heq
  rw [hdecoder w₁, hdecoder w₂, heq]

/-- Factorizations compose. -/
theorem FactorsThrough.trans
    (hfg : FactorsThrough f g) (hgh : FactorsThrough g h) :
    FactorsThrough f h := by
  obtain ⟨decodeFG, hfg⟩ := hfg
  obtain ⟨decodeGH, hgh⟩ := hgh
  refine ⟨fun x => decodeFG (decodeGH x), ?_⟩
  intro w
  rw [hfg w, hgh w]

/--
The paper's factorization criterion for an arbitrary representation codomain.

`Nonempty W` is necessary: if `W` and `A` are empty but `E` is nonempty, kernel
inclusion holds vacuously while no decoder `E → A` exists.
-/
theorem factorsThrough_iff_kernelIncluded [Nonempty W]
    (target : W → A) (representation : W → E) :
    FactorsThrough target representation ↔ KernelIncluded representation target := by
  constructor
  · exact factorsThrough_kernelIncluded
  · intro hkernel
    classical
    let fallback : W := Classical.choice (inferInstance : Nonempty W)
    let decoder : E → A := fun e =>
      if hexists : ∃ w, representation w = e then
        target (Classical.choose hexists)
      else
        target fallback
    refine ⟨decoder, ?_⟩
    intro w
    let hexists : ∃ w', representation w' = representation w := ⟨w, rfl⟩
    change target w = if h : ∃ w', representation w' = representation w then
      target (Classical.choose h) else target fallback
    rw [dif_pos hexists]
    have hchosen :
        representation (Classical.choose hexists) = representation w :=
      Classical.choose_spec hexists
    exact (hkernel hchosen).symm

end AlgebraOfHumanAiCollaboration
