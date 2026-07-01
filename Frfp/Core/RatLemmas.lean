/-
  FRFP Formalization: Rational Number Lemmas
  ==========================================
  
  Helper lemmas for working with Rational numbers in [0,1].
  ALL AXIOMS CONVERTED TO THEOREMS (16/16 proven)
-/

import Mathlib.Tactic

namespace Frfp.Core.RatLemmas

theorem zero_le_half : (0 : Rat) ≤ 1/2 := by norm_num
theorem half_le_one : (1/2 : Rat) ≤ 1 := by norm_num
theorem zero_le_one : (0 : Rat) ≤ 1 := by norm_num

theorem half_le_half : (1/2 : Rat) ≤ 1/2 := le_refl _
theorem rat_le_refl (x : Rat) : x ≤ x := le_refl x
theorem nat_le_refl (n : Nat) : n ≤ n := Nat.le_refl n

theorem bounded_between (x y z : Rat)
    (h1 : 0 ≤ x) (h2 : x ≤ y) (h3 : y ≤ z) (h4 : z ≤ 1) :
    0 ≤ y ∧ y ≤ 1 :=
  ⟨le_trans h1 h2, le_trans h3 h4⟩

theorem Rat_add_le_add_right (a b c : Rat) : a ≤ b ↔ a + c ≤ b + c :=
  (add_le_add_iff_right c).symm

theorem Rat_add_le_add_left (a b c : Rat) : a ≤ b ↔ c + a ≤ c + b :=
  (add_le_add_iff_left c).symm

theorem Rat_mul_le_mul_of_nonneg_right (a b c : Rat) : a ≤ b → 0 ≤ c → a * c ≤ b * c :=
  fun h hc => mul_le_mul_of_nonneg_right h hc

theorem Rat_inv_pos (a : Rat) : 0 < a → 0 < a⁻¹ :=
  fun h => inv_pos.mpr h

theorem Rat_mul_inv_cancel (a : Rat) (h : a ≠ 0) : a * a⁻¹ = 1 :=
  mul_inv_cancel₀ h

theorem Rat_ofNat_add (m n : Nat) : ((m + n : Nat) : Rat) = (m : Rat) + (n : Rat) := by
  push_cast; ring

theorem Rat_zero_le_one : (0 : Rat) ≤ 1 := by norm_num

private theorem foldl_add_comm (vals : List Rat) (init acc : Rat) :
    vals.foldl (· + ·) (init + acc) = init + vals.foldl (· + ·) acc := by
  induction vals generalizing acc with
  | nil => simp
  | cons head tail ih =>
    simp only [List.foldl]
    have heq : init + acc + head = init + (acc + head) := by ring
    rw [heq, ih]

theorem foldl_add_nonneg (vals : List Rat) (init : Rat)
    (hinit : 0 ≤ init) (hall : ∀ x ∈ vals, 0 ≤ x) :
    0 ≤ vals.foldl (· + ·) init := by
  induction vals generalizing init with
  | nil => simpa
  | cons head tail ih =>
    simp only [List.foldl]
    apply ih
    · have := hall head ((by simp : head ∈ head :: tail)); linarith
    · intro x hx; exact hall x (List.mem_cons_of_mem head hx)

theorem foldl_add_le_length (vals : List Rat)
    (hall : ∀ x ∈ vals, x ≤ 1) :
    vals.foldl (· + ·) 0 ≤ (vals.length : Rat) := by
  induction vals with
  | nil => simp
  | cons head tail ih =>
    have h_head : head ≤ 1 := hall head ((by simp : head ∈ head :: tail))
    have h_tail : ∀ x ∈ tail, x ≤ 1 := fun x hx => hall x (List.mem_cons_of_mem head hx)
    have ih' := ih h_tail
    have comm : tail.foldl (· + ·) head = head + tail.foldl (· + ·) 0 := by
      have h := foldl_add_comm tail head 0; simp at h; linarith
    simp only [List.foldl, List.length, Nat.cast_succ]
    rw [show (0 : Rat) + head = head by ring, comm]
    push_cast
    linarith

end Frfp.Core.RatLemmas
