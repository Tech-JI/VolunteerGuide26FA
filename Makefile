# Tech-JI Dev Guide -> PDF
#
#   make guide.pdf      freshman handbook (English, beamer slide deck)
#   make pdf            build guide.pdf
#   make check          verify the toolchain
#   make clean          remove generated PDF
#
# Requires: pandoc, xelatex, and the fonts Noto Sans, DejaVu Sans Mono.

PANDOC  ?= pandoc
ENGINE   = xelatex

# Guide is a beamer deck: every "##" heading is one slide.
BEAMER_OPTS = -t beamer --slide-level=2 --toc-depth=1 --listing \
              --highlight-style=tango --lua-filter=mermaid.lua

GUIDE = Guide.md

.PHONY: pdf guide guide-tex check clean

pdf: guide.pdf

guide.pdf: $(GUIDE) mermaid.lua
	$(PANDOC) $(GUIDE) -o $@ $(BEAMER_OPTS) --pdf-engine=$(ENGINE)
	@echo "built $@"

guide-tex: $(GUIDE) mermaid.lua
	$(PANDOC) $(GUIDE) -o guide.tex -s $(BEAMER_OPTS) --pdf-engine=$(ENGINE)
	@echo "built guide.tex (inspect the log for Overfull/Underfull)"

guide: guide.pdf

check:
	@command -v $(PANDOC) >/dev/null || { echo "missing: pandoc"; exit 1; }
	@command -v $(ENGINE) >/dev/null || { echo "missing: xelatex"; exit 1; }
	@echo "toolchain ok"

clean:
	rm -f guide.pdf
