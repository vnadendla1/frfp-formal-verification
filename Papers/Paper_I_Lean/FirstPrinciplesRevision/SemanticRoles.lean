import AlgebraOfHumanAiCollaboration.ApplicationWitnesses

/-! Paper I: substitution and six semantic classes without phase preservation.
Contract prerequisites and guarantees are application evidence, not role labels. -/
namespace FirstPrinciplesRevision.Semantic
open AlgebraOfHumanAiCollaboration
abbrev Position := RequiredEffectivePosition

/-- Every admitted use site has an outcome; empty behavior cannot substitute. -/
structure Contract (S : Type) where
  pre : S → Prop
  post : S → S → Prop
  realizes : ∀ s, pre s → ∃ t, post s t

/-- d replaces c without extra prerequisites or loss of required outcomes. -/
def Substitutes (d c : Contract S) : Prop :=
  ∀ s, c.pre s → d.pre s ∧ ∀ t, d.post s t → c.post s t

theorem substitutes_refl (c : Contract S) : Substitutes c c :=
  fun _ h => ⟨h, fun _ ht => ht⟩

theorem substitutes_trans {a b c : Contract S}
    (hab : Substitutes a b) (hbc : Substitutes b c) : Substitutes a c := by
  intro s hc
  obtain ⟨hb, hbc'⟩ := hbc s hc
  obtain ⟨ha, hab'⟩ := hab s hb
  exact ⟨ha, fun t ht => hbc' t (hab' t ht)⟩

def Equivalent (c d : Contract S) : Prop := Substitutes c d ∧ Substitutes d c

def semanticSetoid (contracts : R → Contract S) : Setoid R where
  r a b := Equivalent (contracts a) (contracts b)
  iseqv := ⟨fun _ => ⟨substitutes_refl _, substitutes_refl _⟩,
    fun h => ⟨h.2, h.1⟩,
    fun h k => ⟨substitutes_trans h.1 k.1, substitutes_trans k.2 h.2⟩⟩

/-- Semantic regime separation at a permitted use site: either a prerequisite
is absent, or an admitted substitute permits an outcome violating the required
establishment guarantee. Regime names and signatures supply no premise. -/
theorem regime_separation {c d : Contract S} {H : S → Prop} {s : S}
    (site : c.pre s)
    (separation : (¬ H s ∧ ∀ x, d.pre x → H x) ∨
      ((∀ t, c.post s t → H t) ∧
       (d.pre s → ∃ t, d.post s t ∧ ¬ H t))) : ¬ Substitutes d c := by
  intro h
  obtain ⟨admitted, preserves⟩ := h s site
  rcases separation with ⟨absent, requires⟩ | ⟨establishes, witness⟩
  · exact absent (requires s admitted)
  · obtain ⟨t, ht, missing⟩ := witness admitted
    exact missing (establishes t (preserves t ht))

theorem missing_precondition {b d : Contract S} {H : S → Prop} {s : S}
    (site : b.pre s) (absent : ¬ H s) (requires : ∀ x, d.pre x → H x) :
    ¬ Substitutes d b := regime_separation site (Or.inl ⟨absent, requires⟩)

/-- The establishing guarantee identifies the boundary. Failed replacement
already follows from the absent prerequisite at a permitted boundary site. -/
theorem boundary_noncollapse {b d : Contract S} {H : S → Prop} {s : S}
    (site : b.pre s) (absent : ¬ H s)
    (_establishes : ∀ x y, b.pre x → b.post x y → H y)
    (requires : ∀ x, d.pre x → H x) : ¬ Equivalent b d :=
  fun h => missing_precondition site absent requires h.2

theorem bad_outcome {c d : Contract S} {s t : S}
    (site : c.pre s) (allowed : d.post s t) (bad : ¬ c.post s t) :
    ¬ Substitutes d c := fun h => bad ((h s site).2 t allowed)

theorem local_cannot_acquire {b d : Contract S} {H : S → Prop} {s : S}
    (site : b.pre s)
    (repairs : ∀ x y, b.pre x → b.post x y → H y)
    (localOnly : ∀ x y, d.pre x → d.post x y → ¬ H y) :
    ¬ Substitutes d b := by
  apply regime_separation site (Or.inr ⟨fun t ht => repairs s t site ht, ?_⟩)
  intro hd
  obtain ⟨t, ht⟩ := d.realizes s hd
  exact ⟨t, ht, localOnly s t hd ht⟩

/-- A representation derived entirely from the local information cannot repair
an independently witnessed task deficit. This supplies the informational reason
for the local non-repair obligation in a semantic boundary application. -/
theorem local_information_cannot_repair {task : W → T} {localView : W → L}
    {available : W → E} (deficit : ¬ FactorsThrough task localView)
    (restricted : FactorsThrough available localView) : ¬ FactorsThrough task available :=
  fun success => deficit (success.trans restricted)

/-- An allowed production outcome exposes at most Y through the judgment readout;
evaluation guarantees J. This is a contract interface, not kernel preservation. -/
structure ArtifactInterface (p q : Contract S) (Y : W → V) (J : W → T) where
  site : W → S
  output : W → S
  readout : S → T
  querySite : ∀ w, q.pre (site w)
  productionOutcome : ∀ w, p.post (site w) (output w)
  artifactOnly : FactorsThrough (fun w => readout (output w)) Y
  evaluation : ∀ w t, q.post (site w) t → readout t = J w

theorem substitution_forces_factorization
    (a : ArtifactInterface p q Y J) (h : Substitutes p q) : FactorsThrough J Y := by
  obtain ⟨decode, hdecode⟩ := a.artifactOnly
  refine ⟨decode, fun w => ?_⟩
  exact (a.evaluation w _ ((h _ (a.querySite w)).2 _ (a.productionOutcome w))).symm.trans
    (hdecode w)

theorem production_not_evaluation (a : ArtifactInterface p q Y J)
    (deficit : ¬ FactorsThrough J Y) : ¬ Substitutes p q :=
  fun h => deficit (substitution_forces_factorization a h)

theorem assessment_not_closure {a c : Contract S} {O : S → Bool} {s t : S}
    (site : c.pre s) (assessment : a.post s t) (isOpen : O t = true)
    (settles : ∀ x y, c.pre x → c.post x y → O y = false) :
    ¬ Substitutes a c := by
  apply bad_outcome site assessment
  intro h
  have heq := settles s t site h
  rw [isOpen] at heq
  cases heq

/-- Reverse failure is conditional on assessment guaranteeing an open obligation. -/
theorem closure_not_assessment {a c : Contract S} {O : S → Bool} {s t : S}
    (site : a.pre s) (closure : c.post s t) (closed : O t = false)
    (leavesOpen : ∀ x y, a.pre x → a.post x y → O y = true) :
    ¬ Substitutes c a := by
  apply bad_outcome site closure
  intro h
  have heq := leavesOpen s t site h
  rw [closed] at heq
  cases heq

/-- Operational, information-access, and interface evidence. No pairwise
non-equivalence, phase map, or equivalence-preservation fields. -/
structure SixRoleModel (S R W V T : Type) where
  contracts : R → Contract S
  roleAt : Position → R
  operative : S → Prop
  sufficient : S → Prop
  initSite : S
  initAllowed : (contracts (roleAt .I)).pre initSite
  initAbsent : ¬ operative initSite
  initializes : ∀ s t, (contracts (roleAt .I)).pre s →
    (contracts (roleAt .I)).post s t → operative t
  requiresOperative : ∀ r, r ≠ .I → ∀ s, (contracts (roleAt r)).pre s → operative s
  localSite : ∀ r : Position, r = .P ∨ r = .Q → S
  localAllowed : ∀ r h, (contracts (roleAt r)).pre (localSite r h)
  localAbsent : ∀ r h, ¬ sufficient (localSite r h)
  TaskCase : Type
  TaskAnswer : Type
  LocalInfo : Type
  AvailableInfo : Type
  task : TaskCase → TaskAnswer
  localView : TaskCase → LocalInfo
  available : S → TaskCase → AvailableInfo
  localDeficit : ¬ FactorsThrough task localView
  sufficientMeans : ∀ s, sufficient s ↔ FactorsThrough task (available s)
  localRestriction : ∀ r, r = .P ∨ r = .Q → ∀ s t,
    (contracts (roleAt r)).pre s → (contracts (roleAt r)).post s t →
    FactorsThrough (available t) localView
  boundarySite : S
  boundaryAllowed : (contracts (roleAt .B)).pre boundarySite
  boundaryAbsent : ¬ sufficient boundarySite
  repairs : ∀ s t, (contracts (roleAt .B)).pre s →
    (contracts (roleAt .B)).post s t → sufficient t
  downstreamRequires : ∀ r, r = .A ∨ r = .C → ∀ s,
    (contracts (roleAt r)).pre s → sufficient s
  artifact : W → V
  judgment : W → T
  artifactInterface : ArtifactInterface (contracts (roleAt .P))
    (contracts (roleAt .Q)) artifact judgment
  judgmentDeficit : ¬ FactorsThrough judgment artifact
  obligation : S → Bool
  closureSite : S
  closureAllowed : (contracts (roleAt .C)).pre closureSite
  assessmentOutput : S
  assessmentAllowed : (contracts (roleAt .A)).post closureSite assessmentOutput
  assessmentOpen : obligation assessmentOutput = true
  closes : ∀ s t, (contracts (roleAt .C)).pre s →
    (contracts (roleAt .C)).post s t → obligation t = false

namespace SixRoleModel
variable (m : SixRoleModel S R W V T)

theorem initialization_separates (r : Position) (hr : r ≠ .I) :
    ¬ Substitutes (m.contracts (m.roleAt r)) (m.contracts (m.roleAt .I)) :=
  missing_precondition m.initAllowed m.initAbsent (m.requiresOperative r hr)

/-- Local non-repair is derived from task insufficiency and permitted information,
not assumed as a separator or inferred from phase membership. -/
theorem local_nonrepair (r : Position) (hr : r = .P ∨ r = .Q) (s t : S)
    (hs : (m.contracts (m.roleAt r)).pre s)
    (ht : (m.contracts (m.roleAt r)).post s t) : ¬ m.sufficient t := by
  intro h
  exact local_information_cannot_repair m.localDeficit
    (m.localRestriction r hr s t hs ht) ((m.sufficientMeans t).mp h)

theorem local_boundary_separates (r : Position) (hr : r = .P ∨ r = .Q) :
    ¬ Substitutes (m.contracts (m.roleAt r)) (m.contracts (m.roleAt .B)) :=
  local_cannot_acquire m.boundaryAllowed m.repairs (m.local_nonrepair r hr)

theorem local_downstream_separates (r d : Position)
    (hr : r = .P ∨ r = .Q) (hd : d = .A ∨ d = .C) :
    ¬ Substitutes (m.contracts (m.roleAt d)) (m.contracts (m.roleAt r)) :=
  missing_precondition (m.localAllowed r hr) (m.localAbsent r hr)
    (m.downstreamRequires d hd)

theorem boundary_downstream_separates (d : Position) (hd : d = .A ∨ d = .C) :
    ¬ Substitutes (m.contracts (m.roleAt d)) (m.contracts (m.roleAt .B)) :=
  missing_precondition m.boundaryAllowed m.boundaryAbsent (m.downstreamRequires d hd)

theorem pq_separates :
    ¬ Substitutes (m.contracts (m.roleAt .P)) (m.contracts (m.roleAt .Q)) :=
  production_not_evaluation m.artifactInterface m.judgmentDeficit

theorem ac_separates :
    ¬ Substitutes (m.contracts (m.roleAt .A)) (m.contracts (m.roleAt .C)) :=
  assessment_not_closure m.closureAllowed m.assessmentAllowed m.assessmentOpen m.closes

/-- Exhaustive 15-pair audit, independent of phases and regions. -/
theorem pairwise_noncollapse {a b : Position}
    (h : Equivalent (m.contracts (m.roleAt a)) (m.contracts (m.roleAt b))) : a = b := by
  cases a <;> cases b
  · rfl
  · exact False.elim (m.initialization_separates .P (by decide) h.2)
  · exact False.elim (m.initialization_separates .Q (by decide) h.2)
  · exact False.elim (m.initialization_separates .B (by decide) h.2)
  · exact False.elim (m.initialization_separates .A (by decide) h.2)
  · exact False.elim (m.initialization_separates .C (by decide) h.2)
  · exact False.elim (m.initialization_separates .P (by decide) h.1)
  · rfl
  · exact False.elim (m.pq_separates h.1)
  · exact False.elim (m.local_boundary_separates .P (by simp) h.1)
  · exact False.elim (m.local_downstream_separates .P .A (by simp) (by simp) h.2)
  · exact False.elim (m.local_downstream_separates .P .C (by simp) (by simp) h.2)
  · exact False.elim (m.initialization_separates .Q (by decide) h.1)
  · exact False.elim (m.pq_separates h.2)
  · rfl
  · exact False.elim (m.local_boundary_separates .Q (by simp) h.1)
  · exact False.elim (m.local_downstream_separates .Q .A (by simp) (by simp) h.2)
  · exact False.elim (m.local_downstream_separates .Q .C (by simp) (by simp) h.2)
  · exact False.elim (m.initialization_separates .B (by decide) h.1)
  · exact False.elim (m.local_boundary_separates .P (by simp) h.2)
  · exact False.elim (m.local_boundary_separates .Q (by simp) h.2)
  · rfl
  · exact False.elim (m.boundary_downstream_separates .A (by simp) h.2)
  · exact False.elim (m.boundary_downstream_separates .C (by simp) h.2)
  · exact False.elim (m.initialization_separates .A (by decide) h.1)
  · exact False.elim (m.local_downstream_separates .P .A (by simp) (by simp) h.1)
  · exact False.elim (m.local_downstream_separates .Q .A (by simp) (by simp) h.1)
  · exact False.elim (m.boundary_downstream_separates .A (by simp) h.1)
  · rfl
  · exact False.elim (m.ac_separates h.1)
  · exact False.elim (m.initialization_separates .C (by decide) h.1)
  · exact False.elim (m.local_downstream_separates .P .C (by simp) (by simp) h.1)
  · exact False.elim (m.local_downstream_separates .Q .C (by simp) (by simp) h.1)
  · exact False.elim (m.boundary_downstream_separates .C (by simp) h.1)
  · exact False.elim (m.ac_separates h.2)
  · rfl

theorem six_classes (e : Setoid R)
    (sound : ∀ a b, e.r a b → Equivalent (m.contracts a) (m.contracts b)) :
    HasAtLeastSixClasses e :=
  ⟨{ roleAt := m.roleAt, noncollapse := fun {_ _} h => m.pairwise_noncollapse (sound _ _ h) }⟩

theorem semantic_six_classes : HasAtLeastSixClasses (semanticSetoid m.contracts) :=
  m.six_classes _ (fun _ _ h => h)
end SixRoleModel
end FirstPrinciplesRevision.Semantic
