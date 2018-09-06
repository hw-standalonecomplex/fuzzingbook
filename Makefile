# Fuzzingbook Makefile

# Chapters to include in the book, in this order
PUBLISHED_CHAPTERS = \
	Preface.ipynb \
	Intro_Testing.ipynb \
	Basic_Fuzzing.ipynb \
	Coverage.ipynb \
	Mutation_Fuzzing.ipynb \
	Grammars.ipynb

UNPUBLISHED_CHAPTERS = \
	Derivation_Trees.ipynb
	
CHAPTERS = $(PUBLISHED_CHAPTERS) $(UNPUBLISHED_CHAPTERS)

# Coming up next:
# Parsing?

# Later
# - Reducing.ipynb

# Additional notebooks (not to be included)
APPENDICES = \
	Guide_for_Authors.ipynb \
	Template.ipynb \
	ExpectError.ipynb \
	Timer.ipynb
FRONTMATTER = \
	Main.ipynb

# All sources
SOURCE_FILES = \
	$(FRONTMATTER) \
	$(CHAPTERS) \
	$(APPENDICES)

# The bibliography file
BIB = fuzzingbook.bib

# Where the notebooks are
NOTEBOOKS = notebooks

# Sources in the notebooks folder
SOURCES = $(SOURCE_FILES:%=$(NOTEBOOKS)/%)
PUBLISHED_SOURCES = $(PUBLISHED_CHAPTERS:%=$(NOTEBOOKS)/%)

# Where to place the pdf, html, slides
PDF_TARGET      = pdf/
HTML_TARGET     = html/
SLIDES_TARGET   = slides/
CODE_TARGET     = code/
WORD_TARGET     = word/
MARKDOWN_TARGET = markdown/
DOCS_TARGET     = docs/

# Various derived files
TEXS      = $(SOURCE_FILES:%.ipynb=$(PDF_TARGET)%.tex)
PDFS      = $(SOURCE_FILES:%.ipynb=$(PDF_TARGET)%.pdf)
HTMLS     = $(SOURCE_FILES:%.ipynb=$(HTML_TARGET)%.html)
SLIDES    = $(SOURCE_FILES:%.ipynb=$(SLIDES_TARGET)%.slides.html)
PYS       = $(SOURCE_FILES:%.ipynb=$(CODE_TARGET)%.py)
WORDS     = $(SOURCE_FILES:%.ipynb=$(WORD_TARGET)%.docx)
MARKDOWNS = $(SOURCE_FILES:%.ipynb=$(MARKDOWN_TARGET)%.md)

CHAPTER_PYS = $(CHAPTERS:%.ipynb=$(CODE_TARGET)%.py)

PDF_FILES     = $(SOURCE_FILES:%.ipynb=$(PDF_TARGET)%_files)
HTML_FILES    = $(SOURCE_FILES:%.ipynb=$(HTML_TARGET)%_files)
SLIDES_FILES  = $(SOURCE_FILES:%.ipynb=$(SLIDES_TARGET)%_files)

# Configuration
# What we use for production: nbpublish (preferred), bookbook, or nbconvert
PUBLISH ?= nbpublish

# What we use for LaTeX: latexmk (preferred), or pdflatex
LATEX ?= latexmk

## Tools
# Python
PYTHON ?= python3

# The nbpublish tool (preferred; https://github.com/chrisjsewell/ipypublish)
# (see nbpublish -h for details)
NBPUBLISH ?= nbpublish

# The bookbook tool (okay for chapters and books; but no citations yet)
# https://github.com/takluyver/bookbook
BOOKBOOK_LATEX ?= $(PYTHON) -m bookbook.latex
BOOKBOOK_HTML  ?= $(PYTHON) -m bookbook.html

# The nbconvert alternative (okay for chapters; doesn't work for book; no citations)
NBCONVERT ?= jupyter nbconvert

# Notebook merger
NBMERGE = $(PYTHON) utils/nbmerge.py

# LaTeX
PDFLATEX ?= pdflatex
BIBTEX ?= bibtex
LATEXMK ?= latexmk
LATEXMK_OPTS ?= -pdf -quiet

# Word
PANDOC ?= pandoc

# Markdown (see https://github.com/aaren/notedown)
NOTEDOWN ?= notedown

# Style checks
PYCODESTYLE = pycodestyle
PYCODESTYLE_OPTS = --config setup.cfg

ifndef PUBLISH
# Determine publishing program
OUT := $(shell which $(NBPUBLISH) > /dev/null && echo yes)
ifeq ($(OUT),yes)
# We have nbpublish
PUBLISH = nbpublish
else
# Issue a warning message
OUT := $(shell $(NBPUBLISH) -h > /dev/null)
# We have nbconvert
PUBLISH = nbconvert
PUBLISH_PLUGINS = 
endif
endif

ifndef LATEX
# Determine publishing program
OUT := $(shell which $(LATEXMK) > /dev/null && echo yes)
ifeq ($(OUT),yes)
# We have latexmk
LATEX = $(LATEXMK)
else
# Issue a warning message
OUT := $(shell $(LATEXMK) -h > /dev/null)
# We have pdflatex
LATEX = $(PDFLATEX)
endif
endif


ifeq ($(PUBLISH),bookbook)
# Use bookbook
CONVERT_TO_HTML   = $(NBCONVERT) --to html --output-dir=$(HTML_TARGET)
CONVERT_TO_TEX    = $(NBCONVERT) --to latex --template fuzzingbook.tplx --output-dir=$(PDF_TARGET)
BOOK_TEX    = $(PDF_TARGET)book.tex
BOOK_PDF    = $(PDF_TARGET)book.pdf
BOOK_HTML   = $(HTML_TARGET)book.html
BOOK_HTML_FILES = $(HTML_TARGET)book_files
BOOK_PDF_FILES  = $(PDF_TARGET)book_files
PUBLISH_PLUGINS = 
else
ifeq ($(PUBLISH),nbpublish)
# Use nbpublish
CONVERT_TO_HTML   = $(NBPUBLISH) -f html_ipypublish_chapter --outpath $(HTML_TARGET)
CONVERT_TO_TEX    = $(NBPUBLISH) -f latex_ipypublish_chapter --outpath $(PDF_TARGET)
# CONVERT_TO_SLIDES = $(NBPUBLISH) -f slides_ipypublish_all --outpath $(SLIDES_TARGET)
BOOK_TEX    = $(PDF_TARGET)book.tex
BOOK_PDF    = $(PDF_TARGET)book.pdf
BOOK_HTML   = $(HTML_TARGET)book.html
BOOK_HTML_FILES = $(HTML_TARGET)book_files
BOOK_PDF_FILES  = $(PDF_TARGET)book_files
PUBLISH_PLUGINS = \
    ipypublish_plugins/html_ipypublish_chapter.py \
	ipypublish_plugins/latex_ipypublish_book.py \
	ipypublish_plugins/latex_ipypublish_chapter.py
else
# Use standard Jupyter tools
CONVERT_TO_HTML   = $(NBCONVERT) --to html --output-dir=$(HTML_TARGET)
CONVERT_TO_TEX    = $(NBCONVERT) --to latex --template fuzzingbook.tplx --output-dir=$(PDF_TARGET)
# CONVERT_TO_SLIDES = $(NBCONVERT) --to slides --output-dir=$(SLIDES_TARGET)
BOOK_TEX   = 
BOOK_PDF   = 
BOOK_HTML  = 
BOOK_HTML_FILES = 
BOOK_PDF_FILES  = 
PUBLISH_PLUGINS = 
endif
endif

# For Python, we can always use the standard Jupyter tools
CONVERT_TO_PYTHON = $(NBCONVERT) --to python --output-dir=$(CODE_TARGET)

# For slides, we also use the standard Jupyter tools
# Main reason: Jupyter has a neat interface to control slides/sub-slides/etc
CONVERT_TO_SLIDES = $(NBCONVERT) --to slides --output-dir=$(SLIDES_TARGET)
REVEAL_JS = $(SLIDES_TARGET)reveal.js

# For Word .docx files, we start from the HTML version
CONVERT_TO_WORD = $(PANDOC) 

# For Markdown .md files, we use markdown
# Note: adding --run re-executes all code
# CONVERT_TO_MARKDOWN = $(NOTEDOWN) --to markdown
CONVERT_TO_MARKDOWN = $(NBCONVERT) --to markdown --output-dir=$(MARKDOWN_TARGET)


# Short targets
# Default target is "chapters", as that's what you'd typically like to recreate after a change
chapters default run: html code

# The book is recreated after any change to any source
book:	book-html book-pdf
all:	chapters pdf code slides book
and more:	word markdown

# Individual targets
html:	ipypublish-chapters $(HTMLS)
pdf:	ipypublish-chapters $(PDFS)
python code:	$(PYS)
slides:	$(SLIDES) $(REVEAL_JS)
word doc docx: $(WORDS)
md markdown: $(MARKDOWNS)

book-pdf:  ipypublish-book $(BOOK_PDF)
book-html: ipypublish-book $(BOOK_HTML)

ifeq ($(PUBLISH),bookbook)
ipypublish-book:
ipypublish-chapters:
else
ifeq ($(PUBLISH),nbpublish)
ipypublish-book:
ipypublish-chapters:
else
ipypublish-book:
	@echo "To create the book, you need the 'nbpublish' program."
	@echo "This is part of the 'ipypublish' package"
	@echo "at https://github.com/chrisjsewell/ipypublish"
ipypublish-chapters:
	@echo "Warning: Using '$(NBCONVERT)' instead of '$(NBPUBLISH)'"
	@echo "Documents will be created without citations and references"
	@echo "Install the 'ipypublish' package"
	@echo "from https://github.com/chrisjsewell/ipypublish"
endif
endif

# Invoke notebook and editor: `make jupyter lab`
edit notebook:
	jupyter notebook

lab:
	jupyter lab
	
jupyter:


# Help
help:
	@echo "Welcome to the 'fuzzingbook' Makefile!"
	@echo ""
	@echo "* make chapters (default) -> HTML and code for all chapters (notebooks)"
	@echo "* make (pdf|html|code|slides|word|markdown) -> given subcategory only"
	@echo "* make book -> entire book in PDF and HTML"
	@echo "* make all -> all inputs in all output formats"
	@echo "* make style -> style checker"
	@echo "* make crossref -> cross reference checker"
	@echo "* make publish -> place on official web site"
	@echo "* make clean -> delete all derived files"
	@echo ""
	@echo "Created files end here:"
	@echo "* PDFs -> '$(PDF_TARGET)', HTML -> '$(HTML_TARGET)', Python code -> '$(CODE_TARGET)', Slides -> '$(SLIDES_TARGET)'"
	@echo "* Web site files -> '$(DOCS_TARGET)'"
	@echo ""
	@echo "Settings:"
	@echo "* Use make PUBLISH=(nbconvert|nbpublish|bookbook) to choose a converter"
	@echo "  (default: automatic)"

# Conversion rules - chapters
ifeq ($(LATEX),pdflatex)
# Use PDFLaTeX
$(PDF_TARGET)%.pdf:	$(PDF_TARGET)%.tex $(BIB)
	@echo Running LaTeX...
	@-test -L $(PDF_TARGET)/pics || ln -s ../pics $(PDF_TARGET)
	cd $(PDF_TARGET) && $(PDFLATEX) $*
	-cd $(PDF_TARGET) && $(BIBTEX) $*
	cd $(PDF_TARGET) && $(PDFLATEX) $*
	cd $(PDF_TARGET) && $(PDFLATEX) $*
	@cd $(PDF_TARGET) && $(RM) $*.aux $*.bbl $*.blg $*.log $*.out $*.toc $*.frm $*.lof $*.lot $*.fls
	@cd $(PDF_TARGET) && $(RM) -r $*.tex $*_files
	@echo Created $@
else
# Use LaTeXMK
$(PDF_TARGET)%.pdf:	$(PDF_TARGET)%.tex $(BIB)
	@echo Running LaTeXMK...
	@-test -L $(PDF_TARGET)/pics || ln -s ../pics $(PDF_TARGET)
	cd $(PDF_TARGET) && $(LATEXMK) $(LATEXMK_OPTS) $*
	@cd $(PDF_TARGET) && $(RM) $*.aux $*.bbl $*.blg $*.log $*.out $*.toc $*.frm $*.lof $*.lot $*.fls $*.fdb_latexmk
	@cd $(PDF_TARGET) && $(RM) -r $*.tex $*_files
	@echo Created $@
endif

$(PDF_TARGET)%.tex:	$(NOTEBOOKS)/%.ipynb $(BIB) $(PUBLISH_PLUGINS)
	$(CONVERT_TO_TEX) $<
	@cd $(PDF_TARGET) && $(RM) $*.nbpub.log

$(HTML_TARGET)%.html: $(NOTEBOOKS)/%.ipynb $(BIB) $(PUBLISH_PLUGINS) utils/post-html.py
	$(CONVERT_TO_HTML) $<
	$(PYTHON) utils/post-html.py $@ $(PUBLISHED_SOURCES)
	@cd $(HTML_TARGET) && $(RM) $*.nbpub.log $*_files/$(BIB)
	@-test -L $(HTML_TARGET)/pics || ln -s ../pics $(HTML_TARGET)

$(SLIDES_TARGET)%.slides.html: $(NOTEBOOKS)/%.ipynb $(BIB)
	$(eval TMPDIR := $(shell mktemp -d))
	sed 's/\.ipynb)/\.slides\.html)/g' $< > $(TMPDIR)/$(notdir $<)
	$(CONVERT_TO_SLIDES) $(TMPDIR)/$(notdir $<)
	@cd $(SLIDES_TARGET) && $(RM) $*.nbpub.log $*_files/$(BIB)
	@-test -L $(HTML_TARGET)/pics || ln -s ../pics $(HTML_TARGET)
	@-$(RM) -fr $(TMPDIR)

# Reconstructing the reveal.js dir
$(REVEAL_JS):
	git submodule update --init

$(MARKDOWN_TARGET)%.md:	$(NOTEBOOKS)/%.ipynb $(BIB)
	$(RM) -r $(MARKDOWN_TARGET)$(basename $(notdir $<)).md $(MARKDOWN_TARGET)$(basename $(notdir $<))_files
	$(CONVERT_TO_MARKDOWN) $<


# For code, we comment out fuzzingbook imports, 
# ensuring we import a .py and not the .ipynb file
$(CODE_TARGET)%.py:	$(NOTEBOOKS)/%.ipynb
	$(CONVERT_TO_PYTHON) $<
	sh utils/adjust-py-export.sh < $@ > $@~ && mv $@~ $@
	
# For word, we convert from the HTML file
$(WORD_TARGET)%.docx: $(HTML_TARGET)%.html $(WORD_TARGET)pandoc.css
	$(PANDOC) --css=$(WORD_TARGET)pandoc.css $< -o $@

# Conversion rules - entire book
# We create a book/ folder with the chapters ordered by number, 
# and let the book converters run on this
ifeq ($(PUBLISH),nbpublish)
# With nbpublish
$(PDF_TARGET)book.tex: $(SOURCES) $(BIB) $(PUBLISH_PLUGINS)
	-$(RM) -r book
	mkdir book
	chapter=0; \
	for file in $(CHAPTERS); do \
		chnum=$$(printf "%02d" $$chapter); \
	    ln -s ../$(NOTEBOOKS)/$$file book/$$(echo $$file | sed 's/.*/Ch'$${chnum}'_&/g'); \
		chapter=$$(expr $$chapter + 1); \
	done
	ln -s ../$(BIB) book
	$(NBPUBLISH) -f latex_ipypublish_book --outpath $(PDF_TARGET) book
	$(RM) -r book
	cd $(PDF_TARGET) && $(RM) book.nbpub.log
	@echo Created $@

$(HTML_TARGET)book.html: $(SOURCES) $(BIB)
	-$(RM) -r book
	mkdir book
	chapter=0; \
	for file in $(CHAPTERS); do \
		chnum=$$(printf "%02d" $$chapter); \
	    ln -s ../$(NOTEBOOKS)/$$file book/$$(echo $$file | sed 's/.*/Ch'$${chnum}'_&/g'); \
		chapter=$$(expr $$chapter + 1); \
	done
	ln -s ../$(BIB) book
	$(CONVERT_TO_HTML) book
	$(RM) -r book
	cd $(HTML_TARGET) && $(RM) book.nbpub.log book_files/$(BIB)
	@echo Created $@
else
# With bookbook
$(PDF_TARGET)book.tex: $(SOURCES) $(BIB) $(PUBLISH_PLUGINS)
	-$(RM) -r book
	mkdir book
	chapter=0; \
	for file in $(CHAPTERS); do \
		chnum=$$(printf "%02d" $$chapter); \
		ln -s ../$(NOTEBOOKS)/$$file book/$$(echo $$file | sed 's/.*/'$${chnum}'-&/g'); \
		chapter=$$(expr $$chapter + 1); \
	done
	cd book; $(BOOKBOOK_LATEX)
	mv book/combined.tex $@
	$(RM) -r book
	@echo Created $@

$(HTML_TARGET)book.html: $(SOURCES) $(BIB) $(PUBLISH_PLUGINS)
	-$(RM) -r book
	mkdir book
	for file in $(CHAPTERS); do \
	    ln -s ../$(NOTEBOOKS)/$$file book/$$(echo $$file | sed 's/[^-0-9]*\([-0-9][0-9]*\)_\(.*\)/\1-\2/g'); \
	done
	cd book; $(BOOKBOOK_HTML)
	mv book/html/index.html $@
	mv book/html/*.html $(HTML_TARGET)
	$(RM) -r book
	@echo Created $@
endif

## Some checks

# Style checks
style check-style checkstyle: $(PYS)
	$(PYCODESTYLE) $(PYCODESTYLE_OPTS) $(PYS)
	@echo "All style checks passed."

# List of Cross References
crossref check-crossref xref: $(SOURCES)
	@echo "Referenced notebooks (* = missing)"
	@files=$$(grep '\.ipynb)' $(SOURCES) | sed 's/.*[(]\([a-zA-Z0-9_][a-zA-Z0-9_]*\.ipynb\)[)].*/\1/' | sort | uniq); \
	for file in $$files; do \
		if [ -f $(NOTEBOOKS)/$$file ]; then \
		    echo '  ' $$file; \
		else \
			echo '* ' $$file; \
		fi \
	done

# Run all code
PYS_OUT = $(SOURCE_FILES:%.ipynb=$(CODE_TARGET)%.py.out)
$(CODE_TARGET)%.py.out:	$(CODE_TARGET)%.py
	$(PYTHON) $< > $@ 2>&1 || (echo "Error while running $(PYTHON)" >> $@; tail $@; exit 1)

check-code: code $(PYS_OUT)
	@grep "^Error while running" $(PYS_OUT) || echo "All code checks passed."
	
# Publishing
docs: publish-html publish-code publish-slides $(DOCS_TARGET)index.md
	@echo "Now use 'make publish' to commit changes to docs."

# TODO: Also remove Twitter scripts
$(DOCS_TARGET)index.md: README.md
	echo '<h1>Generating Software Tests</h1>' > $@
	tail +2 README.md >> $@

publish: docs
	git add $(DOCS_TARGET)*
	-git status
	-git commit -m "Doc update" $(DOCS_TARGET)
	@echo "Now use 'git push' to place docs on website."

# Add/update HTML code in repository
publish-html: html
	@test -d $(DOCS_TARGET) || mkdir $(DOCS_TARGET)
	@test -d $(DOCS_TARGET)html || mkdir $(DOCS_TARGET)html
	cp -pr $(HTML_TARGET) $(DOCS_TARGET)html

publish-code: code
	@test -d $(DOCS_TARGET) || mkdir $(DOCS_TARGET)
	@test -d $(DOCS_TARGET)code || mkdir $(DOCS_TARGET)code
	cp -pr $(CODE_TARGET) $(DOCS_TARGET)code

publish-slides: slides
	@test -d $(DOCS_TARGET) || mkdir $(DOCS_TARGET)
	@test -d $(DOCS_TARGET)slides || mkdir $(DOCS_TARGET)slides
	cp -pr $(SLIDES_TARGET) $(DOCS_TARGET)slides


# As an alternative, we may also push .md files directly, allowing us to use a theme.
# However, this loses math rendering and citations
publish-markdown: markdown
	cp -pr markdown/* docs
	cp $(DOCS_TARGET)Main.md $(DOCS_TARGET)index.md


# Cleanup
AUX = *.aux *.bbl *.blg *.log *.out *.toc *.frm *.lof *.lot \
	  $(PDF_TARGET)*.aux \
	  $(PDF_TARGET)*.bbl \
	  $(PDF_TARGET)*.blg \
	  $(PDF_TARGET)*.log \
	  $(PDF_TARGET)*.out \
	  $(PDF_TARGET)*.toc \
	  $(PDF_TARGET)*.frm \
	  $(PDF_TARGET)*.lof \
	  $(PDF_TARGET)*.lot

clean-code:
	$(RM) $(PYS) $(PYS_OUT)

clean-chapters:
	$(RM) $(TEXS) $(PDFS) $(HTMLS) $(SLIDES) $(WORDS) $(MARKDOWNS)
	$(RM) -r $(PDF_FILES) $(HTML_FILES) $(SLIDES_FILES)

clean-book:
	$(RM) $(BOOK_TEX) $(BOOK_PDF) $(BOOK_HTML)
	$(RM) -r $(BOOK_HTML_FILES) $(BOOK_PDF_FILES)

clean-aux:
	$(RM) $(AUX)
	
clean-docs:
	$(RM) -r $(DOCS_TARGET)*.md $(DOCS_TARGET)html $(DOCS_TARGET)code $(DOCS_TARGET)slides

clean: clean-code clean-chapters clean-book clean-aux clean-docs
	@echo "All derived files deleted"

realclean: clean
	cd $(PDF_TARGET); $(RM) *.pdf
	cd $(HTML_TARGET); $(RM) *.html; $(RM) -r *_files
	cd $(SLIDES_TARGET); $(RM) *.html
	cd $(CODE_TARGET); $(RM) *.py*
	cd $(WORD_TARGET); $(RM) *.docx
	cd $(MARKDOWN_TARGET); $(RM) *.md
	@echo "All old files deleted"
