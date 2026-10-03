import AlgebraOfHumanAiCollaboration.Authorization

/-!
# An explicit operational bridge for the B representative

Acquisition accepts an external payload. It is not a deterministic recovery of
that payload from the local state. Realization/readout and phase laws are input
contracts; their truth for an implementation and exhaustive local access remain
application obligations. No global region-preservation theorem is inferred.
-/
namespace AlgebraOfHumanAiCollaboration

inductive AcquisitionPhase where
  | local
  | augmented
deriving DecidableEq, Repr

structure AcquisitionRealization
    {Role State W Y J : Type u}
    {semanticEquiv : Setoid Role} {artifact : W → Y} {standing : W → J}
    {outstanding : State → Bool}
    (roles : ObservableRoleWitness semanticEquiv artifact standing outstanding)
    (Local Payload : Type u) where
  start : Local → State
  perform : Role → State → Payload → State
  readout : State → Local × Payload
  phase : State → AcquisitionPhase
  startIsLocal : ∀ l, phase (start l) = .local
  boundaryIsAugmented : ∀ l d, phase (perform (roles.roleAt .B) (start l) d) = .augmented
  boundaryReadout : ∀ l d, readout (perform (roles.roleAt .B) (start l) d) = (l, d)

namespace AcquisitionRealization

def acquiredView (a : AcquisitionRealization roles Local Payload)
    (localMap : W → Local) (additional : W → Payload) : W → Local × Payload :=
  fun w => a.readout (a.perform (roles.roleAt .B) (a.start (localMap w)) (additional w))

theorem acquiredView_eq (a : AcquisitionRealization roles Local Payload)
    (localMap : W → Local) (additional : W → Payload) (w : W) :
    a.acquiredView localMap additional w = (localMap w, additional w) :=
  a.boundaryReadout (localMap w) (additional w)

theorem repairs_task (a : AcquisitionRealization roles Local Payload)
    (d : DependencyRepairWitness task localMap additional) :
    FactorsThrough task (a.acquiredView localMap additional) := by
  refine ⟨d.decode, ?_⟩
  intro w
  rw [a.acquiredView_eq]
  exact d.recovers w

theorem needs_nonlocal_payload (a : AcquisitionRealization roles Local Payload)
    (d : DependencyRepairWitness task localMap additional) :
    UsesOutsideLocal (a.acquiredView localMap additional) localMap :=
  success_requires_outside_local d.deficit (a.repairs_task d)

theorem changes_phase (a : AcquisitionRealization roles Local Payload) (l : Local) (p : Payload) :
    a.phase (a.start l) ≠ a.phase (a.perform (roles.roleAt .B) (a.start l) p) := by
  rw [a.startIsLocal, a.boundaryIsAugmented]
  decide

theorem activates_exclusive_cut (a : AcquisitionRealization roles Local Payload)
    (d : DependencyRepairWitness task localMap additional)
    (hcut : BoundaryExclusive localMap (a.acquiredView localMap additional) activated) :
    activated := hcut (a.needs_nonlocal_payload d)

end AcquisitionRealization

/-- Both conclusions refer to the B representative of the supplied governance witness. -/
theorem governed_acquisition_and_six_classes
    (g : GovernanceRoleWitness semanticEquiv artifact standing model)
    (a : AcquisitionRealization g.toObservableRoleWitness Local Payload)
    (d : DependencyRepairWitness task localMap additional) :
    UsesOutsideLocal (a.acquiredView localMap additional) localMap ∧
      HasAtLeastSixClasses semanticEquiv :=
  ⟨a.needs_nonlocal_payload d, g.six_classes⟩

end AlgebraOfHumanAiCollaboration
