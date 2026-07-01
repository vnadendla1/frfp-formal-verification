# Appendix D: Bibliography and References

**Paper**: FRFP Lean Formal Verification  
**Appendix**: D  
**Source**: BIBLIOGRAPHY_GUIDE.md, references.bib

---

## D.1 Complete Reference List

### Floating-Point Arithmetic

**[IEEE19]**  
IEEE Standards Association.  
*IEEE Standard for Floating-Point Arithmetic (IEEE 754-2019)*.  
IEEE, 2019. doi:10.1109/IEEESTD.2019.8766229  
→ Justifies all 59 FloatTheory axioms (§4–6).

**[Mul18]**  
Muller, J.-M., et al.  
*Handbook of Floating-Point Arithmetic*, 2nd ed.  
Birkhäuser, 2018.  
→ Supporting reference for IEEE 754 arithmetic properties.

**[Bol11]**  
Boldo, S. and Melquiond, G.  
"Flocq: A Unified Library for Proving Floating-Point Algorithms in Coq."  
*ARITH 2011*, pp. 243–252.  
→ Example of formal IEEE 754 formalization (Coq).

---

### Probability Theory and Stochastic Processes

**[Bil95]**  
Billingsley, P.  
*Probability and Measure*, 3rd ed.  
Wiley, 1995.  
→ Justifies 21 probability/measure axioms. Key sections: §1 (measure axioms), §36 (stopping times, survival functions).

**[Dur19]**  
Durrett, R.  
*Probability: Theory and Examples*, 5th ed.  
Cambridge University Press, 2019.  
→ Justifies 4 stochastic process axioms (tail bounds, convergence).

---

### Term Rewriting and Abstract Reduction Systems

**[BN98]**  
Baader, F. and Nipkow, T.  
*Term Rewriting and All That*.  
Cambridge University Press, 1998.  
→ Justifies 18 rewriting/ARS axioms. Key results: Abstract Reduction Systems (Ch. 2), confluence (Ch. 2), normal forms.

**[New42]**  
Newman, M. H. A.  
"On theories with a combinatorial definition of 'equivalence'."  
*Annals of Mathematics* 43(2), pp. 223–243, 1942.  
→ Justifies 2 axioms. Source of Newman's Lemma (termination + local confluence implies global confluence).

**[Ter03]**  
Terese (collective).  
*Term Rewriting Systems*.  
Cambridge University Press, 2003.  
→ Comprehensive rewriting theory reference.

---

### Category Theory

**[ML71]**  
Mac Lane, S.  
*Categories for the Working Mathematician*.  
Springer, 1971. (2nd ed. 1998.)  
→ Justifies 7 category/groupoid axioms. Key: category axioms (Ch. 1), functor laws (Ch. 1), groupoid structure.

**[Lei14]**  
Leinster, T.  
*Basic Category Theory*.  
Cambridge University Press, 2014.  
→ Supporting constructive perspective on category axioms.

---

### Real Analysis

**[Rud76]**  
Rudin, W.  
*Principles of Mathematical Analysis*, 3rd ed.  
McGraw-Hill, 1976.  
→ Justifies 2 real analysis axioms (geometric limit-to-zero lemma, continuity).

---

### Graph Theory

**[Die10]**  
Diestel, R.  
*Graph Theory*, 4th ed.  
Springer, 2010.  
→ Justifies 1 graph theory axiom (reachability in navigation graphs).

---

### Information Theory

**[CT06]**  
Cover, T. M. and Thomas, J. A.  
*Elements of Information Theory*, 2nd ed.  
Wiley, 2006.  
→ Justifies 1 information theory axiom (entropy bounds).

---

### Temporal Logic and Safety Properties

**[Pnu77]**  
Pnueli, A.  
"The temporal logic of programs."  
*FOCS 1977*, pp. 46–57.  
→ Source anchor for IL and CSC skeleton predicates (temporal safety invariants over traces).

**[AS85]**  
Alpern, B. and Schneider, F. B.  
"Defining liveness."  
*Information Processing Letters* 21(4), pp. 181–185, 1985.  
→ Source anchor for AR skeleton (safety vs. liveness decomposition).

---

### Tacit Knowledge and Semantic Grounding

**[Pol66]**  
Polanyi, M.  
*The Tacit Dimension*.  
Doubleday, 1966.  
→ Conceptual background for HEG and HEC premises; tacit knowledge cannot be fully explicated.

**[Har90]**  
Harnad, S.  
"The symbol grounding problem."  
*Physica D* 42, pp. 335–346, 1990.  
→ Background for ETS principle; symbol grounding gap.

**[Sea80]**  
Searle, J. R.  
"Minds, brains, and programs."  
*Behavioral and Brain Sciences* 3(3), pp. 417–424, 1980.  
→ Chinese Room argument; syntax does not imply semantics.

---

### Formal Verification Tools

**[dML21]**  
de Moura, L. and Ullrich, S.  
"The Lean 4 theorem prover and programming language."  
*CADE 2021*, pp. 625–635.  
→ Lean 4 proof assistant (the verification tool used in this paper).

**[Mat26]**  
The Mathlib Community.  
*Mathlib4: The Lean 4 Mathematical Library*, v4.29.0.  
GitHub, 2026. https://github.com/leanprover-community/mathlib4  
→ Mathlib dependency used throughout; provides real analysis, algebra, and combinatorics foundations.

---

### Impossibility Results

**[Ric53]**  
Rice, H. G.  
"Classes of recursively enumerable sets and their decision problems."  
*Transactions of the American Mathematical Society* 74(2), pp. 358–366, 1953.  
→ Background for computability limits on tacit correctness checking.

**[Sip12]**  
Sipser, M.  
*Introduction to the Theory of Computation*, 3rd ed.  
Cengage, 2012.  
→ Computability theory reference.

---

### Governance and Multi-Agent Systems

**[Ost90]**  
Ostrom, E.  
*Governing the Commons*.  
Cambridge University Press, 1990.  
→ Institutional design background for governance layer.

**[Arr51]**  
Arrow, K. J.  
*Social Choice and Individual Values*.  
Wiley, 1951.  
→ Background for impossibility results in collective decision-making.

---

## D.2 Axiom-to-Reference Mapping Summary

| Axiom family | Primary reference | Secondary reference |
|---|---|---|
| Float arithmetic / order | [IEEE19] | [Mul18] |
| Probability / measure | [Bil95] | [Dur19] |
| Stopping times | [Bil95] §36 | [Dur19] |
| Term rewriting / ARS | [BN98] | [Ter03] |
| Newman's Lemma | [New42] | [BN98] |
| Category / groupoid axioms | [ML71] | [Lei14] |
| Real analysis | [Rud76] | — |
| Graph theory | [Die10] | — |
| Information theory | [CT06] | — |
| Temporal safety / traces | [Pnu77] | [AS85] |
| Safety vs liveness | [AS85] | — |
| FRFP HEG / HEC premises | [Pol66] | [Har90] |
| Lean 4 proof assistant | [dML21] | — |
| Mathlib library | [Mat26] | — |

---

## D.3 BibTeX Entries (Selected)

```bibtex
@standard{ieee754-2019,
  title     = {{IEEE Standard for Floating-Point Arithmetic}},
  number    = {754-2019},
  organization = {IEEE},
  year      = {2019},
  doi       = {10.1109/IEEESTD.2019.8766229}
}

@book{billingsley1995probability,
  author    = {Billingsley, Patrick},
  title     = {Probability and Measure},
  edition   = {3rd},
  publisher = {Wiley},
  year      = {1995}
}

@book{baader1998term,
  author    = {Baader, Franz and Nipkow, Tobias},
  title     = {Term Rewriting and All That},
  publisher = {Cambridge University Press},
  year      = {1998}
}

@article{newman1942theories,
  author    = {Newman, M. H. A.},
  title     = {On theories with a combinatorial definition of `equivalence'},
  journal   = {Annals of Mathematics},
  volume    = {43},
  number    = {2},
  pages     = {223--243},
  year      = {1942}
}

@book{maclane1998categories,
  author    = {Mac Lane, Saunders},
  title     = {Categories for the Working Mathematician},
  edition   = {2nd},
  publisher = {Springer},
  year      = {1998}
}

@article{pnueli1977temporal,
  author    = {Pnueli, Amir},
  title     = {The temporal logic of programs},
  booktitle = {18th Annual Symposium on Foundations of Computer Science (FOCS)},
  pages     = {46--57},
  year      = {1977}
}

@article{alpern1985defining,
  author    = {Alpern, Bowen and Schneider, Fred B.},
  title     = {Defining liveness},
  journal   = {Information Processing Letters},
  volume    = {21},
  number    = {4},
  pages     = {181--185},
  year      = {1985}
}

@book{rudin1976principles,
  author    = {Rudin, Walter},
  title     = {Principles of Mathematical Analysis},
  edition   = {3rd},
  publisher = {McGraw-Hill},
  year      = {1976}
}

@inproceedings{demoura2021lean4,
  author    = {de Moura, Leonardo and Ullrich, Sebastian},
  title     = {The {Lean 4} theorem prover and programming language},
  booktitle = {28th International Conference on Automated Deduction (CADE)},
  pages     = {625--635},
  year      = {2021}
}

@misc{mathlib2026,
  author    = {{The Mathlib Community}},
  title     = {{Mathlib4}: The {Lean 4} Mathematical Library},
  year      = {2026},
  url       = {https://github.com/leanprover-community/mathlib4}
}
```
