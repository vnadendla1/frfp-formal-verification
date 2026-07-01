/-
  FRFP Formalization: Rational Number Lemmas
  ==========================================
  
  Helper lemmas for working with Rational numbers in [0,1].
  These lemmas support Credence bound proofs.
-/

namespace Frfp.Core.RatLemmas

/-- 0 ≤ 1/2 - Provable by computation -/
theorem zero_le_half : (0 : Rat) ≤ 1/2 := by decide

/-- 1/2 ≤ 1 - Provable by computation -/
theorem half_le_one : (1/2 : Rat) ≤ 1 := by decide

/-- 0 ≤ 1 - Provable by computation -/
theorem zero_le_one : (0 : Rat) ≤ 1 := by decide

/-- 1/2 ≤ 1/2 (reflexivity) - Follows from reflexivity of ≤ -/
theorem half_le_half : (1/2 : Rat) ≤ 1/2 := Rat.le_refl _

/-- Reflexivity for Rat -/
theorem rat_le_refl (x : Rat) : x ≤ x := Rat.le_refl x

/-- Reflexivity for Nat - Proven using Nat.le_refl from standard library -/
theorem nat_le_refl (n : Nat) : n ≤ n := Nat.le_refl n

/-- For any x ≤ y ≤ z, if 0 ≤ x and z ≤ 1, then 0 ≤ y ≤ 1 -/
theorem bounded_between (x y z : Rat) 
    (h1 : 0 ≤ x) (h2 : x ≤ y) (h3 : y ≤ z) (h4 : z ≤ 1) : 
    0 ≤ y ∧ y ≤ 1 := by
  constructor
  · exact Rat.le_trans h1 h2
  · exact Rat.le_trans h3 h4

-- Helper axioms for Rat arithmetic
-- These are standard properties of Rat from Lean 4
theorem Rat_add_le_add_right (a b c : Rat) : a ≤ b ↔ a + c ≤ b + c := Rat.add_le_add_iff_right c

theorem Rat_add_le_add_left (a b c : Rat) : a ≤ b ↔ c + a ≤ c + b := Rat.add_le_add_iff_left c

theorem Rat_mul_le_mul_of_nonneg_right (a b c : Rat) : a ≤ b → 0 ≤ c → a * c ≤ b * c := 
  Rat.mul_le_mul_of_nonneg_right

theorem Rat_inv_pos (a : Rat) : 0 < a → 0 < a⁻¹ := Rat.inv_pos.mpr

theorem Rat_mul_inv_cancel (a : Rat) (h : a ≠ 0) : a * a⁻¹ = 1 := Rat.mul_inv_cancel h

theorem Rat_ofNat_add (m n : Nat) : ((m + n : Nat) : Rat) = (m : Rat) + (n : Rat) := by
  simp [Rat.ofNat_add]

theorem Rat_zero_le_one : (0 : Rat) ≤ 1 := by decide

-- Core lemmas for list sums - proven by induction on list structure
theorem foldl_add_nonneg (vals : List Rat) (init : Rat) 
    (hinit : 0 ≤ init) (hall : ∀ x ∈ vals, 0 ≤ x) : 
    0 ≤ vals.foldl (· + ·) init := by
  induction vals generalizing init with
  | nil => 
    simp [List.foldl]
    exact hinit
  | cons head tail ih =>
    simp [List.foldl]
    apply ih
    · -- Show 0 ≤ init + head
      apply add_nonneg
      · exact hinit
      · exact hall head (List.mem_cons_self head tail)
    · -- Show all elements in tail are non-negative
      intro x hx
      exact hall x (List.mem_cons_of_mem head hx)

-- Helper: foldl with + distributes over init
theorem foldl_add_comm (vals : List Rat) (init acc : Rat) :
    vals.foldl (· + ·) (init + acc) = init + vals.foldl (· + ·) acc := by
  induction vals generalizing acc with
  | nil => simp [List.foldl]
  | cons head tail ih =>
    simp [List.foldl]
    rw [ih (head + acc)]
    rw [ih head]
    ring

theorem foldl_add_le_length (vals : List Rat)
    (hall : ∀ x ∈ vals, x ≤ 1) :
    vals.foldl (· + ·) 0 ≤ (vals.length : Rat) := by
  induction vals with
  | nil => 
    simp [List.foldl, List.length]
  | cons head tail ih =>
    simp only [List.foldl, List.length, Rat.zero_add]
    have h_head : head ≤ 1 := hall head (List.mem_cons_self head tail)
    have h_tail : ∀ x ∈ tail, x ≤ 1 := fun x hx => hall x (List.mem_cons_of_mem head hx)
    have ih' := ih h_tail
    -- Use foldl_add_comm to show: tail.foldl (· + ·) head = head + tail.foldl (· + ·) 0
    have comm : tail.foldl (· + ·) head = head + tail.foldl (· + ·) 0 := by
      have := foldl_add_comm tail head 0
      simp [Rat.add_zero] at this
      exact this
    rw [comm]
    -- Now show: head + tail.foldl (· + ·) 0 ≤ (tail.length + 1 : Nat)
    calc head + tail.foldl (· + ·) 0
        ≤ 1 + tail.foldl (· + ·) 0 := (Rat_add_le_add_right head 1 _).mp h_head
      _ ≤ 1 + (tail.length : Rat) := (Rat_add_le_add_left _ _ 1).mp ih'
      _ = ((tail.length + 1 : Nat) : Rat) := by norm_cast; omega

-- Helper lemmas for manual proofs

theorem add_nonneg (a b : Rat) (ha : 0 ≤ a) (hb : 0 ≤ b) : 0 ≤ a + b := by
  have h1 : 0 + 0 ≤ a + 0 := (Rat_add_le_add_right 0 a 0).mp ha
  have h2 : a + 0 ≤ a + b := (Rat_add_le_add_left 0 b a).mp hb
  calc 0 = 0 + 0 := (Rat.zero_add 0).symm
       _ ≤ a + 0 := h1
       _ ≤ a + b := h2

theorem add_le_add {a b c d : Rat} (hab : a ≤ b) (hcd : c ≤ d) : a + c ≤ b + d := by
  have h1 : a + c ≤ b + c := (Rat_add_le_add_right a b c).mp hab
  have h2 : b + c ≤ b + d := (Rat_add_le_add_left c d b).mp hcd
  exact Rat.le_trans h1 h2

theorem ofNat_nonneg (n : Nat) : 0 ≤ (n : Rat) := by
  cases n with
  | zero => rfl
  | succ n =>
    have ih : (0 : Rat) ≤ n := ofNat_nonneg n
    calc 0 ≤ (n : Rat) := ih
         _ = (n : Rat) + 0 := (Rat.add_zero (n : Rat)).symm
         _ ≤ (n : Rat) + 1 := (Rat_add_le_add_left 0 1 (n : Rat)).mp Rat_zero_le_one
         _ = ((n + 1 : Nat) : Rat) := (Rat_ofNat_add n 1).symm

theorem div_nonneg (a b : Rat) (ha : 0 ≤ a) (hb : 0 < b) : 0 ≤ a / b := by
  rw [Rat.div_def]
  exact Rat.mul_nonneg ha (Rat.le_of_lt (Rat_inv_pos b hb))

theorem div_le_one (a b : Rat) (h : a ≤ b) (hb : 0 < b) : a / b ≤ 1 := by
  rw [Rat.div_def]
  have hb' : b ≠ 0 := Rat.ne_of_gt hb
  have hinv : 0 < b⁻¹ := Rat_inv_pos b hb
  calc a * b⁻¹ ≤ b * b⁻¹ := by
                    apply Rat_mul_le_mul_of_nonneg_right
                    · exact h
                    · exact Rat.le_of_lt hinv
             _ = 1 := Rat_mul_inv_cancel b hb'

/-- Average of bounded values is bounded -/
theorem average_bounded (vals : List Rat) (n : Rat) (hn : 0 < n)
    (hn_ge : ↑vals.length ≤ n)
    (hall_nonneg : ∀ x ∈ vals, 0 ≤ x)
    (hall_le_one : ∀ x ∈ vals, x ≤ 1) :
    let sum := vals.foldl (· + ·) 0
    0 ≤ sum / n ∧ sum / n ≤ 1 := by
  constructor
  · -- Lower bound: sum ≥ 0 implies sum/n ≥ 0
    have sum_nonneg : 0 ≤ vals.foldl (· + ·) 0 := foldl_add_nonneg vals 0 (by rfl) hall_nonneg
    exact div_nonneg (vals.foldl (· + ·) 0) n sum_nonneg hn
  · -- Upper bound: sum ≤ length ≤ n implies sum/n ≤ 1
    have sum_le_length : vals.foldl (· + ·) 0 ≤ (vals.length : Rat) := 
      foldl_add_le_length vals hall_le_one
    have : vals.foldl (· + ·) 0 ≤ n := Rat.le_trans sum_le_length hn_ge
    exact div_le_one (vals.foldl (· + ·) 0) n this hn

/-- Min of bounded values is bounded -/
theorem min_bounded (vals : List Rat) (init : Rat)
    (hinit_nonneg : 0 ≤ init) (hinit_le_one : init ≤ 1)
    (hall_nonneg : ∀ x ∈ vals, 0 ≤ x)
    (hall_le_one : ∀ x ∈ vals, x ≤ 1) :
    let result := vals.foldl min init
    0 ≤ result ∧ result ≤ 1 := by
  constructor
  · -- min preserves lower bound
    induction vals generalizing init with
    | nil => simp; exact hinit_nonneg
    | cons x xs ih =>
      simp only [List.foldl]
      have hx : 0 ≤ x := hall_nonneg x (List.mem_cons.mpr (Or.inl rfl))
      have : 0 ≤ min init x := by
        rw [Rat.min_def]
        split
        · exact hinit_nonneg
        · exact hx
      apply ih
      · exact this
      · rw [Rat.min_def]; split; exact hinit_le_one; exact hall_le_one x (List.mem_cons.mpr (Or.inl rfl))
      · intro y hy; exact hall_nonneg y (List.mem_cons.mpr (Or.inr hy))
      · intro y hy; exact hall_le_one y (List.mem_cons.mpr (Or.inr hy))
  · -- min preserves upper bound
    induction vals generalizing init with
    | nil => simp; exact hinit_le_one
    | cons x xs ih =>
      simp only [List.foldl]
      have hx : x ≤ 1 := hall_le_one x (List.mem_cons.mpr (Or.inl rfl))
      have : min init x ≤ 1 := by
        rw [Rat.min_def]
        split
        · exact hinit_le_one
        · exact hx
      apply ih
      · rw [Rat.min_def]; split; exact hinit_nonneg; exact hall_nonneg x (List.mem_cons.mpr (Or.inl rfl))
      · exact this
      · intro y hy; exact hall_nonneg y (List.mem_cons.mpr (Or.inr hy))
      · intro y hy; exact hall_le_one y (List.mem_cons.mpr (Or.inr hy))

/-- Max of bounded values is bounded -/
theorem max_bounded (vals : List Rat) (init : Rat)
    (hinit_nonneg : 0 ≤ init) (hinit_le_one : init ≤ 1)
    (hall_nonneg : ∀ x ∈ vals, 0 ≤ x)
    (hall_le_one : ∀ x ∈ vals, x ≤ 1) :
    let result := vals.foldl max init
    0 ≤ result ∧ result ≤ 1 := by
  constructor
  · -- max preserves lower bound
    induction vals generalizing init with
    | nil => simp; exact hinit_nonneg
    | cons x xs ih =>
      simp only [List.foldl]
      have hx : 0 ≤ x := hall_nonneg x (List.mem_cons.mpr (Or.inl rfl))
      have : 0 ≤ max init x := by
        rw [Rat.max_def]
        split
        · exact hx
        · exact hinit_nonneg
      apply ih
      · exact this
      · rw [Rat.max_def]; split; exact hall_le_one x (List.mem_cons.mpr (Or.inl rfl)); exact hinit_le_one
      · intro y hy; exact hall_nonneg y (List.mem_cons.mpr (Or.inr hy))
      · intro y hy; exact hall_le_one y (List.mem_cons.mpr (Or.inr hy))
  · -- max preserves upper bound
    induction vals generalizing init with
    | nil => simp; exact hinit_le_one
    | cons x xs ih =>
      simp only [List.foldl]
      have hx : x ≤ 1 := hall_le_one x (List.mem_cons.mpr (Or.inl rfl))
      have : max init x ≤ 1 := by
        rw [Rat.max_def]
        split
        · exact hx
        · exact hinit_le_one
      apply ih
      · rw [Rat.max_def]; split; exact hall_nonneg x (List.mem_cons.mpr (Or.inl rfl)); exact hinit_nonneg
      · exact this
      · intro y hy; exact hall_nonneg y (List.mem_cons.mpr (Or.inr hy))
      · intro y hy; exact hall_le_one y (List.mem_cons.mpr (Or.inr hy))

end Frfp.Core.RatLemmas
