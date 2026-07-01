# Chapter 2: Vibecoding — AI-Assisted Lean Development

**Paper**: FRFP Lean Formal Verification  
**Chapter**: 2 of 8  
**Source documents**: *(self-contained; no appendix dependency)*

---

## 2.1 What is Vibecoding?

"Vibecoding" denotes iterative AI-assisted code or proof generation in which the human operator specifies intent and reviews output while a generative AI model proposes syntactic content. In conventional software development, vibecoding lacks a correctness oracle: without execution or tests, a human cannot reliably distinguish working code from plausibly working code.

Lean changes this dynamic fundamentally. Lean's type-checker is a deterministic correctness oracle: it either accepts or rejects every proof. The result is that vibecoded Lean proof attempts are immediately and unambiguously verified or falsified by the kernel, independent of the operator's understanding of the proof term.

This produces a principled workflow:

```
Human: specifies intent and theorem statement
AI: generates candidate proof or tactic block
Lean kernel: accepts or rejects
Human: routes to next iteration or accepts result
```

When Lean accepts, the result is formally guaranteed, regardless of whether the human operator fully understands each internal tactic step. This is the key property that makes vibecoding viable for formal mathematics at scale.

---

## 2.2 The FRFP Vibecoding Workflow

The formalization of FRFP followed a six-phase workflow:

**Phase 1: Foundation setup**  
- Install Lean 4 and Mathlib dependency.
- Define core inductive types (`Object`, `Primitive`) and basic kernel theorems.
- Establish import structure and naming conventions.
- Human role: architectural decisions, naming standards, dependency graph.

**Phase 2: Axiom seeding**  
- AI generates candidate axioms from informal paper statements.
- Human screens for consistency, redundancy, and interpretation accuracy.
- Lean kernel validates typing of all axiom signatures.
- Acceptance criterion: axiom must type-check and pass informal semantic review.

**Phase 3: Theorem attempts**  
- Human specifies target theorem (matching a paper claim or a proof obligation).
- AI generates proof attempt (tactic blocks, `by` expressions, `simp` calls).
- Lean kernel evaluates; accepted proofs are committed.
- Rejected proofs enter repair loop: AI re-attempts with error message as context.

**Phase 4: Axiom reduction**  
- Systematic audit of all axioms: categorize as derivable theorem, standard reference, or true premise.
- 41 axioms converted to theorems; all remaining axioms cite published references.
- Lean builds validate after each batch conversion.

**Phase 5: Documentation integration**  
- AI cross-references Lean code with paper sections and generates summary documents.
- Human reviews for accuracy of correspondences.

**Phase 6: Final validation**  
- Full clean build (`lake build`) with zero errors.
- Axiom audit confirms 0 uncited axioms.
- `grep sorry` confirms 0 live sorry.

---

## 2.3 Quantitative Results

### Productivity

| Metric | Value |
|---|---|
| Total theorems proven | 269 |
| Average time per theorem (with AI) | 15–30 minutes |
| Average time per complex theorem (e.g., Initiality) | 2–4 hours |
| Estimated time without AI | 5-10x longer |
| Developer count | 1 |
| Total timeline | 6 months |
| Total Lean source lines | ~15,000 |

### AI Attempt Success Rates

| Outcome | Rate |
|---|---|
| First attempt accepted by Lean | ~30% |
| Accepted after 1–2 iterations | ~60% |
| Required significant human intervention | ~10% |

### Error Categories

| Error type | Catch rate | Catcher |
|---|---|---|
| Type errors, wrong signatures | ~80% | Lean kernel immediately |
| Logic errors in proof structure | ~15% | AI review in next iteration |
| Semantic errors (wrong theorem formalized) | ~5% | Human review |

---

## 2.4 Failure Mode Taxonomy

Six failure modes were observed repeatedly throughout the project. Understanding these patterns is a primary practical lesson for similar formalization efforts.

**FM-1: Hallucinated Mathlib lemma names.**  
AI generates tactic blocks that call non-existent Mathlib lemmas (e.g., `Real.le_mul_iff_right` with wrong argument order, or entirely fictional names). Lean rejects immediately with "unknown identifier." Mitigation: provide the AI with a local lemma search result before requesting the proof.

**FM-2: Tactic drift across iterations.**  
After several repair iterations, the AI may introduce new errors while fixing old ones (for example, a tactic that worked in iteration 2 may be dropped in iteration 4). Mitigation: reset to the last working state and restart repair from that checkpoint.

**FM-3: Wrong theorem formalization.**  
AI produces a formally correct Lean statement and proof that does not match the intended informal claim. Lean accepts it, but the human reviewer finds the statement is weaker or different from the target. Mitigation: always write the informal statement as a comment above the theorem and compare before committing.

**FM-4: Axiom proliferation.**  
AI may generate proofs that succeed by introducing a new `axiom` rather than deriving from existing structure. Such steps are syntactically valid but undermine the axiom-minimization objective. Mitigation: prohibit the `axiom` keyword in AI-generated proof attempts unless explicitly authorized and flagged.

**FM-5: Import path errors.**  
AI may generate incorrect `import` statements (wrong module names or incorrect directory paths). Lean rejects these at parse time. Mitigation: maintain a canonical import list in a comment block and include it in each AI prompt.

**FM-6: Type universe mismatches.**  
AI places structures in the wrong Lean universe (`Prop` vs `Type`) requiring cascade edits. Mitigation: fix universe assignments early in each module and annotate them prominently in the module header.

---

## 2.5 What the Kernel Cannot Catch

Lean's kernel guarantees formal correctness of the proof, not correctness of the formalization. Two categories remain outside the kernel's reach:

1. **Wrong axiom semantics**: An axiom can be formally well-typed but semantically wrong (e.g., a commutativity axiom stated with swapped arguments that happens to type-check). Human review of axiom interpretations is essential.

2. **Missing theorems**: Lean will not tell you that you forgot to prove something important. The theorem inventory (Chapter 8) is the human's responsibility to maintain against the informal paper.

---

## 2.6 The Principal Triad

The vibecoding workflow for formal mathematics is best understood as three cooperating roles:

| Role | Agent | Responsibility |
|---|---|---|
| Semantic controller | Human | Decides what to prove and whether formalization matches intent |
| Proof generator | AI (LLM) | Proposes tactic blocks and proof terms |
| Correctness verifier | Lean kernel | Accepts or rejects every proof step |

No single agent in the triad is sufficient on its own. The kernel, without human direction, produces no theorems. The AI, without the kernel, produces plausible but unverified text. The human, without AI support, would require approximately 5-10x more time per theorem.

---

## 2.7 Lessons for Future Projects

1. **Establish naming conventions before writing any proofs.** Changing conventions later causes cascading edits. The NAMING_CONVENTION.md document saved significant time.

2. **Audit axioms in batches, not continuously.** Continuous axiom cleanup interrupts proof flow. Batching axiom reduction (Phase 4) kept the workflow coherent.

3. **Maintain a proof completion checklist.** A running list of "not yet proven" theorems prevents the false impression of completeness that builds when easy theorems are proven first.

4. **Keep AI context small and focused.** Long prompts with full module context cause AI to hallucinate plausible-but-wrong lemma names from the context. Shorter prompts with explicit target theorem and available types perform better.

5. **Accept sorry-first, prove-later.** Using `sorry` placeholders to scaffold proof structure before completion was consistently more efficient than attempting full proofs from scratch.
