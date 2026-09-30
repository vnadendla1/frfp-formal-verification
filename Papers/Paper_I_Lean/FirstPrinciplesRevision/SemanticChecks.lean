import FirstPrinciplesRevision.SemanticOperational

/-! Counterexamples to the overstrong inferences excluded by the revision. -/
namespace FirstPrinciplesRevision.Semantic.Checks
open AlgebraOfHumanAiCollaboration

def copyBoth : Contract (Bool × Bool) where
  pre := fun _ => True
  post := fun s t => t = s
  realizes := fun s _ => ⟨s, rfl⟩

theorem second_not_from_first :
    ¬ FactorsThrough (fun w : Bool × Bool => w.2) (fun w => w.1) := by
  intro h
  have heq := factorsThrough_kernelIncluded h (show
    (fun w : Bool × Bool => w.1) (false, false) = (fun w => w.1) (false, true) from rfl)
  cases heq

/-- J not factoring through Y does not separate two contracts that both supply
(Y,J). The artifact-interface condition in the positive theorem is necessary. -/
theorem combined_contract_counterexample :
    (¬ FactorsThrough (fun w : Bool × Bool => w.2) (fun w => w.1)) ∧
    Equivalent copyBoth copyBoth :=
  ⟨second_not_from_first, substitutes_refl _, substitutes_refl _⟩

/-- A family deficit can coexist with a locally determined closure verdict. -/
theorem family_deficit_not_individual_deficit :
    (¬ FactorsThrough (fun w : Bool × Bool => w) (fun w => w.1)) ∧
    FactorsThrough (fun _ : Bool × Bool => true) (fun w => w.1) := by
  constructor
  · intro h
    exact second_not_from_first ((show FactorsThrough (fun w : Bool × Bool => w.2)
      (fun w => w) from ⟨Prod.snd, fun _ => rfl⟩).trans h)
  · exact ⟨fun _ => true, fun _ => rfl⟩

def establishFirst : Contract (Bool × Bool) where
  pre := fun _ => True
  post := fun _ t => t.1 = true
  realizes := fun _ _ => ⟨(true, false), rfl⟩

def establishSecond : Contract (Bool × Bool) where
  pre := fun _ => True
  post := fun _ t => t.2 = true
  realizes := fun _ _ => ⟨(false, true), rfl⟩

/-- One event satisfies both contracts, yet a permitted outcome refutes equivalence. -/
theorem joint_realization_not_equivalence :
    establishFirst.post (false, false) (true, true) ∧
    establishSecond.post (false, false) (true, true) ∧
    ¬ Equivalent establishFirst establishSecond := by
  refine ⟨rfl, rfl, ?_⟩
  intro h
  exact bad_outcome (c := establishSecond) (d := establishFirst)
    (s := (false, false)) (t := (true, false)) trivial rfl (by simp [establishSecond]) h.1

/-- Merely naming two copies does not separate them. -/
theorem labels_do_not_separate :
    (semanticSetoid (fun _ : Position => copyBoth)).r .I .C :=
  ⟨substitutes_refl _, substitutes_refl _⟩

theorem empty_behavior_not_realizable (c : Contract S)
    (empty : ∀ s t, ¬ c.post s t) : ∀ s, ¬ c.pre s := by
  intro s hs
  obtain ⟨t, ht⟩ := c.realizes s hs
  exact empty s t ht

/-- The second coordinate varies, so these contracts have nondeterministic
outcomes; the positive proof does not require a deterministic transition map. -/
theorem nondeterministic_contract :
    establishFirst.post (false, false) (true, false) ∧
    establishFirst.post (false, false) (true, true) ∧
    (true, false) ≠ (true, true) := ⟨rfl, rfl, by decide⟩

/-- The concrete result applies to every sound effective equivalence, not just
exact equality of complete transition relations. -/
theorem any_sound_effective_equivalence (principal : Nat)
    (e : Setoid Operational.Role)
    (sound : ∀ a b, e.r a b → Equivalent
      (Operational.SemanticModel.contract principal a)
      (Operational.SemanticModel.contract principal b)) : HasAtLeastSixClasses e :=
  (Operational.SemanticModel.model principal).six_classes e sound
end FirstPrinciplesRevision.Semantic.Checks
