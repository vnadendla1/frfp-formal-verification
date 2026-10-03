import PaperIII.Models

namespace PaperIII.GovernedMachine

inductive Contract where
  | discover | assess | revise | close | amend
  deriving DecidableEq

structure MachineCharter where
  root : Bool
  validAdmit : Bool
  validClose : Bool
  validAmend : Bool
  deriving DecidableEq

structure State where
  representation : Bool
  assessment : Bool
  candidateDiscovered : Bool
  criterionRevised : Bool
  outstanding : Bool
  charter : MachineCharter
  deriving DecidableEq

/-- One state type and one implementation for every contract, including explicit permission checks. -/
def step : Contract → State → State
  | .discover, s => { s with candidateDiscovered := true }
  | .assess, s => { s with assessment := s.representation }
  | .revise, s => if s.charter.validAdmit then { s with criterionRevised := true } else s
  | .close, s => if s.charter.validClose then { s with outstanding := false } else s
  | .amend, s => if s.charter.validAmend then
      { s with charter := { s.charter with root := !s.charter.root } } else s

def initial : State := ⟨true, false, false, false, true, ⟨false, true, true, true⟩⟩

theorem distinct_contracts_one_implementation :
    step .assess initial ≠ step .revise initial ∧
    step .revise initial ≠ step .close initial ∧
    step .assess initial ≠ step .close initial := by decide

theorem assessment_open_closure_settles :
    (step .assess initial).outstanding = true ∧ (step .close initial).outstanding = false :=
  ⟨rfl, rfl⟩

theorem discovery_does_not_revise (s : State) :
    (step .discover s).criterionRevised = s.criterionRevised := rfl

theorem revision_requires_permission (s : State) (h : s.charter.validAdmit = false) :
    step .revise s = s := by simp [step, h]

theorem closure_requires_permission (s : State) (h : s.charter.validClose = false) :
    step .close s = s := by simp [step, h]

theorem amendment_requires_permission (s : State) (h : s.charter.validAmend = false) :
    step .amend s = s := by simp [step, h]

theorem non_amendment_preserves_charter (c : Contract) (s : State) (h : c ≠ .amend) :
    (step c s).charter = s.charter := by
  cases c <;> simp_all [step]
  all_goals split <;> rfl

/-- Valid charter amendment can change the principal; operational invariance is not an absolute ban. -/
theorem valid_amendment_changes_root :
    (step .amend initial).charter.root ≠ initial.charter.root := by decide

def standingCharter (s : State) : PaperIII.Charter Bool Unit := PaperIII.rooted s.charter.root

theorem operational_contracts_preserve_principal (c : Contract) (s : State) (h : c ≠ .amend) :
    principal (standingCharter (step c s)) () = principal (standingCharter s) () := by
  unfold standingCharter
  rw [non_amendment_preserves_charter c s h]
end PaperIII.GovernedMachine
