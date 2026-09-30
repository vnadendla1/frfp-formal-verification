import FirstPrinciplesRevision
import Lean

/-! Inspect transitive proof/type constants, not merely source-level imports. -/
open Lean in
run_cmd do
  let env ← getEnv
  let roots := #[
    ``FirstPrinciplesRevision.Semantic.SixRoleModel.six_classes,
    ``FirstPrinciplesRevision.Operational.SemanticModel.semantic_exactly_six]
  let forbidden := #[
    "AlgebraOfHumanAiCollaboration.EffectiveLowerBoundWitness",
    "AlgebraOfHumanAiCollaboration.ObservableRoleWitness",
    "FirstPrinciplesRevision.RelationalRoleWitness",
    "FirstPrinciplesRevision.PhasedBehavior",
    "AlgebraOfHumanAiCollaboration.RequiredEffectivePosition.region",
    "FirstPrinciplesRevision.requiredSignature",
    "FirstPrinciplesRevision.Operational.roleWitness",
    "FirstPrinciplesRevision.Operational.operational_exactly_six"]
  for root in roots do
    let mut pending := [root]
    let mut seen : Std.HashSet Name := {}
    while !pending.isEmpty do
      let name := pending.head!
      pending := pending.tail!
      if seen.contains name then continue
      seen := seen.insert name
      let label := name.toString
      if forbidden.any (fun stem => label == stem || (stem ++ ".").isPrefixOf label) then
        throwError "Legacy preservation dependency in {root}: {name}"
      if root == ``FirstPrinciplesRevision.Semantic.SixRoleModel.six_classes &&
          ("FirstPrinciplesRevision.Phase".isPrefixOf label ||
           "AlgebraOfHumanAiCollaboration.EffectiveRegion".isPrefixOf label) then
        throwError "Phase/region dependency in general semantic theorem: {name}"
      if let some info := env.find? name then
        pending := info.type.getUsedConstants.toList ++ pending
        if let some value := info.value? (allowOpaque := true) then
          pending := value.getUsedConstants.toList ++ pending
    unless seen.contains ``FirstPrinciplesRevision.Semantic.regime_separation do
      throwError "General regime-separation theorem not consumed by {root}"
    logInfo m!"SEMANTIC_DEPENDENCY_PASS {root}: {seen.size} transitive constants; no legacy preservation route"
