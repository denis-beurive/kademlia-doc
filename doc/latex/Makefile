# This document illustrates the use of the "make" tool to produce PDF files from LaTeX sources.
#
#      Generate the PDF file:               make
#      Remove all temporary file:           make clean
#      Remove all files except the sources: make clear
#
# You may need to customise this document.

LATEX_EXE     = /usr/bin/lualatex
LATEX_OPTIONS = -halt-on-error -shell-escape -interaction=nonstopmode --output-format=pdf
PDF_VIEWER    = xdg-open

all: kad.pdf distances.pdf buckets.pdf

kad.pdf: kad.tex basic.cls
	${LATEX_EXE} ${LATEX_OPTIONS} $< && echo "SUCCESS" # && ${PDF_VIEWER} $@

distances.pdf: distances.tex basic.cls
	${LATEX_EXE} ${LATEX_OPTIONS} $< && echo "SUCCESS" # && ${PDF_VIEWER} $@

buckets.pdf: buckets.tex basic.cls
	${LATEX_EXE} ${LATEX_OPTIONS} $< && echo "SUCCESS" # && ${PDF_VIEWER} $@

clean:
	rm -f *.log *.out *.aux

clear: clean
	rm -f *.pdf *.dim