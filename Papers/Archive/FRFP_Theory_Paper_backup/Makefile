.PHONY: pdf clean distclean

MAIN = main
PDFLATEX = pdflatex -interaction=nonstopmode -halt-on-error

pdf:
	$(PDFLATEX) $(MAIN).tex
	$(PDFLATEX) $(MAIN).tex
	@echo "Built $(MAIN).pdf"

clean:
	rm -f *.aux *.log *.toc *.out *.bbl *.blg *.fls *.fdb_latexmk *.synctex.gz

distclean: clean
	rm -f $(MAIN).pdf
