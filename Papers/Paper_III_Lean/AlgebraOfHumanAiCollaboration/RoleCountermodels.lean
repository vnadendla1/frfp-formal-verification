import AlgebraOfHumanAiCollaboration.Renormalization

/-!
# Role-count countermodels

These finite examples show that a lower bound of two semantic classes does not
establish exact two-class exhaustiveness. They also exhibit the information loss
introduced by a manually selected three-to-two effective classification.
-/

namespace AlgebraOfHumanAiCollaboration

universe u

/-- At most two semantic classes cover the role type. -/
def HasAtMostTwoClasses (semanticEquiv : Setoid Role) : Prop :=
  ∃ first second : Role, ∀ role : Role,
    semanticEquiv.r role first ∨ semanticEquiv.r role second

/-- Exact two-class exhaustiveness combines the lower and upper bounds. -/
def HasExactlyTwoClasses (semanticEquiv : Setoid Role) : Prop :=
  HasAtLeastTwoClasses semanticEquiv ∧ HasAtMostTwoClasses semanticEquiv

/-- The equality relation packaged as a semantic equivalence. -/
def equalitySetoid (Role : Type u) : Setoid Role where
  r := Eq
  iseqv := {
    refl := Eq.refl
    symm := Eq.symm
    trans := Eq.trans
  }

/-- Three pairwise inequivalent roles cannot be covered by two classes. -/
theorem pairwiseThree_not_hasAtMostTwoClasses
    (semanticEquiv : Setoid Role)
    (hab : ¬ semanticEquiv.r a b)
    (hac : ¬ semanticEquiv.r a c)
    (hbc : ¬ semanticEquiv.r b c) :
    ¬ HasAtMostTwoClasses semanticEquiv := by
  intro hatMost
  obtain ⟨first, second, hcover⟩ := hatMost
  obtain haFirst | haSecond := hcover a
  · obtain hbFirst | hbSecond := hcover b
    · exact hab (semanticEquiv.iseqv.trans haFirst
        (semanticEquiv.iseqv.symm hbFirst))
    · obtain hcFirst | hcSecond := hcover c
      · exact hac (semanticEquiv.iseqv.trans haFirst
          (semanticEquiv.iseqv.symm hcFirst))
      · exact hbc (semanticEquiv.iseqv.trans hbSecond
          (semanticEquiv.iseqv.symm hcSecond))
  · obtain hbFirst | hbSecond := hcover b
    · obtain hcFirst | hcSecond := hcover c
      · exact hbc (semanticEquiv.iseqv.trans hbFirst
          (semanticEquiv.iseqv.symm hcFirst))
      · exact hac (semanticEquiv.iseqv.trans haSecond
          (semanticEquiv.iseqv.symm hcSecond))
    · exact hab (semanticEquiv.iseqv.trans haSecond
        (semanticEquiv.iseqv.symm hbSecond))

/-- A fine pre-boundary regime with a third genuine semantic role. -/
inductive ThreeFinePreRole where
  | primary
  | standing
  | additional
deriving DecidableEq, Repr

/-- A minimal post-boundary regime for the coarse-graining example. -/
inductive TwoFinePostRole where
  | assessment
  | closure
deriving DecidableEq, Repr

abbrev threeFinePreEquiv : Setoid ThreeFinePreRole :=
  equalitySetoid ThreeFinePreRole

abbrev twoFinePostEquiv : Setoid TwoFinePostRole :=
  equalitySetoid TwoFinePostRole

/-- The three-role regime certainly has at least two semantic classes. -/
theorem threeFinePre_hasAtLeastTwoClasses :
    HasAtLeastTwoClasses threeFinePreEquiv := by
  refine ⟨.primary, .standing, ?_⟩
  intro h
  exact ThreeFinePreRole.noConfusion h

/-- The three fine roles are pairwise inequivalent. -/
theorem threeFinePre_not_hasAtMostTwoClasses :
    ¬ HasAtMostTwoClasses threeFinePreEquiv := by
  apply pairwiseThree_not_hasAtMostTwoClasses
    (a := ThreeFinePreRole.primary)
    (b := ThreeFinePreRole.standing)
    (c := ThreeFinePreRole.additional)
    threeFinePreEquiv
  · intro h
    exact ThreeFinePreRole.noConfusion h
  · intro h
    exact ThreeFinePreRole.noConfusion h
  · intro h
    exact ThreeFinePreRole.noConfusion h

/-- Therefore `>= 2` does not establish exact two-class exhaustiveness. -/
theorem threeFinePre_not_hasExactlyTwoClasses :
    ¬ HasExactlyTwoClasses threeFinePreEquiv := by
  intro hexact
  exact threeFinePre_not_hasAtMostTwoClasses hexact.2

/--
An explicit modeling choice that assigns the third fine pre-boundary role to the
retained effective primary class.
-/
def threeToTwoCoarseGraining :
    EffectiveCoarseGraining threeFinePreEquiv twoFinePostEquiv where
  classifyPre
    | .primary => .primary
    | .standing => .standing
    | .additional => .primary
  classifyPost
    | .assessment => .assessment
    | .closure => .closure
  preRespectsEquivalence := by
    intro left right heq
    cases heq
    rfl
  postRespectsEquivalence := by
    intro left right heq
    cases heq
    rfl
  primaryRepresentative := .primary
  standingRepresentative := .standing
  assessmentRepresentative := .assessment
  closureRepresentative := .closure
  primaryClassified := rfl
  standingClassified := rfl
  assessmentClassified := rfl
  closureClassified := rfl

/-- The chosen effective model identifies `additional` with `primary`. -/
theorem threeToTwo_collapses_additional :
    threeToTwoCoarseGraining.effectivePreRole .additional =
      threeToTwoCoarseGraining.effectivePreRole .primary := by
  rfl

/-- The two collapsed fine roles remain semantically inequivalent. -/
theorem additional_not_fineEquivalent_primary :
    ¬ threeFinePreEquiv.r .additional .primary := by
  intro h
  exact ThreeFinePreRole.noConfusion h

end AlgebraOfHumanAiCollaboration
