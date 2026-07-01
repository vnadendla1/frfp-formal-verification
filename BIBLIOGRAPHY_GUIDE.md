# Bibliography Maintenance Guide

**File**: [references.bib](references.bib)  
**Created**: April 17, 2026  
**Purpose**: Academic citations for FRFP formal verification axiom justification

---

## Overview

The `references.bib` file contains BibTeX entries for all academic references used to justify axioms, provide theoretical foundations, and support the formal verification work in the FRFP project.

## Organization

The bibliography is organized by topic:

1. **Syntax-Semantics Gap** - Harnad, Polanyi, Searle, Gödel, McCarthy
2. **Floating-Point Arithmetic** - IEEE 754, Muller, Boldo
3. **Probability Theory** - Billingsley, Durrett
4. **Rewriting Theory** - Baader & Nipkow, Newman, Terese
5. **Category Theory** - Mac Lane, Leinster
6. **Formal Verification** - Lean 4, Mathlib
7. **AI Safety** - Russell, Amodei
8. **Epistemology** - Hintikka, McCarthy
9. **Impossibility Results** - Rice, Sipser
10. **Governance** - Ostrom, Arrow

## Key Axiom → Reference Mapping

### Semantic Gap Axioms

- **`explicit_mechanism_tacit_predicate_gap`** (InstitutionalLayer.lean):
  - Primary: `harnad1990symbol` - Symbol grounding problem
  - Supporting: `polanyi1966tacit` - Tacit knowledge
  - Supporting: `searle1980minds` - Chinese Room (syntax ≠ semantics)
  - Supporting: `godel1931formally` - Formal system limitations

- **`low_quality_precludes_high_credence`** (InstitutionalLayer.lean):
  - `polanyi1966tacit` - Quality of tacit knowledge matters

### Infrastructure Axioms

- **FloatTheory.lean** (75 axioms):
  - Primary: `ieee754-2019` - IEEE floating-point standard
  - Supporting: `muller2018handbook` - Comprehensive reference
  - Formalization: `boldo2011flocq` - Coq formalization example

- **RatLemmas.lean** (13 axioms):
  - Lean 4 standard library (no external reference needed)
  - Future: May reference Lean 4 documentation

- **DynamicLayer.lean** (8 probability axioms):
  - Primary: `billingsley1995probability` - Probability and Measure
  - Supporting: `durrett2019probability` - Modern treatment

- **Navigation.lean** (7 axioms):
  - Primary: `baader1998term` - Term Rewriting and All That
  - Classical: `newman1942theories` - Newman's lemma original paper
  - Comprehensive: `terese2003term` - Complete rewriting theory

- **Grothendieck.lean** (1 axiom - extensionality):
  - Primary: `maclane1998categories` - Categories for the Working Mathematician
  - Modern: `leinster2014basic` - Constructive perspective

### Framework Axioms

- **ETS Principle** (`no_morphism_T0_to_E0`):
  - `polanyi1966tacit` - Tacit knowledge cannot be fully explicated
  - `harnad1990symbol` - Symbol grounding gap

- **Impossibility Results** (TacitDependence.lean):
  - `rice1953classes` - Rice's theorem (undecidability background)
  - `sipser2012introduction` - Computability theory

## Usage in LaTeX Documents

### In Paper Preamble
```latex
\bibliographystyle{plain}  % or alpha, acm, ieee, etc.
\bibliography{references}
```

### Citing References
```latex
The semantic gap axiom is justified by the symbol grounding 
problem \cite{harnad1990symbol}, tacit knowledge theory 
\cite{polanyi1966tacit}, and the Chinese Room argument 
\cite{searle1980minds}.
```

### Multiple Citations
```latex
The axiom is well-established in theoretical literature 
\cite{harnad1990symbol,polanyi1966tacit,searle1980minds,godel1931formally}.
```

## Maintenance Checklist

### When Adding a New Axiom

1. ✅ Identify if axiom needs external justification
2. ✅ Search for appropriate academic reference
3. ✅ Add BibTeX entry to `references.bib` in appropriate section
4. ✅ Update `AXIOM_AUDIT.md` with citation reference
5. ✅ Update this mapping section if new axiom category
6. ✅ Commit both files together

### BibTeX Entry Template

```bibtex
@article{author2026title,
  title={The Paper Title},
  author={Last, First and Last2, First2},
  journal={Journal Name},
  volume={42},
  number={3},
  pages={123--456},
  year={2026},
  publisher={Publisher},
  note={Brief explanation of relevance to FRFP axioms.}
}
```

### Quality Standards

- ✅ Include DOI when available
- ✅ Use full journal/conference names (abbreviated in style file)
- ✅ Add `note` field explaining axiom relevance
- ✅ Include edition numbers for books
- ✅ Use consistent author name formatting
- ✅ Verify publication year accuracy

## Integration with Documentation

### Files Referencing Bibliography

1. **AXIOM_AUDIT.md** - Main audit document with axiom justifications
2. **InstitutionalLayer.lean** - Comments cite semantic gap references
3. **FloatTheory.lean** - Header comments cite IEEE 754
4. **Navigation.lean** - Comments cite Baader & Nipkow
5. **Future papers** - Will cite all axiom justifications

### Cross-Reference Strategy

When documenting an axiom:
```lean
/-- Semantic gap axiom: Explicit mechanisms cannot evaluate tacit predicates.
    
    Justification:
    - Symbol grounding [Harnad 1990]
    - Tacit knowledge [Polanyi 1966]
    - Syntax-semantics gap [Searle 1980]
    
    See references.bib for complete citations. -/
axiom explicit_mechanism_tacit_predicate_gap : ...
```

## Validation

### Before Committing Changes

```bash
# Check BibTeX syntax (if bibtex installed)
bibtex references.aux 2>&1 | grep -i error

# Or use online validators:
# - https://biblatex-linter.herokuapp.com/
# - https://truben.no/latex/bibtex/
```

### Before Publication Submission

1. ✅ Verify all AXIOM_AUDIT.md citations are in references.bib
2. ✅ Check all references have complete metadata
3. ✅ Ensure notes explain axiom relevance
4. ✅ Remove unused entries (if journal requires)
5. ✅ Follow journal-specific BibTeX style requirements

## Future Enhancements

### Planned Additions

- [ ] Add formal verification community references (Coq, Isabelle, HOL)
- [ ] Include empirical AI safety papers (when validating empirical axioms)
- [ ] Add institutional theory references (Ostrom expanded)
- [ ] Include complexity theory references (if needed for termination proofs)

### Integration Ideas

- [ ] Automated citation checker (grep AXIOM_AUDIT.md for uncited axioms)
- [ ] Bibliography coverage report (axioms vs references)
- [ ] Auto-generate reference summary for each module
- [ ] Link to online paper versions (arXiv, DOI)

## Quick Reference

### Most Frequently Cited

1. **Polanyi (1966)** - Tacit knowledge foundation
2. **Harnad (1990)** - Symbol grounding problem
3. **IEEE 754-2019** - Floating-point standard
4. **Baader & Nipkow (1998)** - Rewriting theory
5. **Mac Lane (1998)** - Category theory

### Standard Phrases for Papers

**Floating-Point**:
> "Following standard practice in formal verification, we axiomatize 
> IEEE 754 floating-point arithmetic [IEEE 2019] rather than 
> formalizing the complete specification, which would require weeks 
> of effort and is well-established in the literature [Muller 2018]."

**Semantic Gap**:
> "The semantic gap axiom formalizes a well-established theoretical 
> limitation: syntactic mechanisms operating on explicit representations 
> cannot universally evaluate semantic predicates requiring tacit 
> information [Harnad 1990; Polanyi 1966]. This gap between syntax 
> and semantics is fundamental [Searle 1980] and cannot be closed 
> by additional computation alone [Gödel 1931]."

**Rewriting Theory**:
> "We axiomatize Newman's lemma [Newman 1942] and critical pair 
> analysis [Baader & Nipkow 1998] as these are standard, well-proven 
> results in rewriting theory. Full mechanization would require 
> 15-20 hours and duplicate existing formal proofs in the 
> literature [Terese 2003]."

---

## Questions?

For bibliography maintenance questions:
- Check BibTeX documentation: https://www.bibtex.org/
- Lean community standards: https://leanprover-community.github.io/
- Academic citation guides: https://www.chicagomanualofstyle.org/

Last updated: April 17, 2026
