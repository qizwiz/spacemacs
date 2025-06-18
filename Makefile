# Makefile for running proof helpers locally

EMACS = emacs
EMACSFLAGS = -Q \
	-l ~/.spacemacs \
	--eval "(dotspacemacs/user-config)" \
	-L ~/.emacs.d/lisp -L ~/.emacs.d/lisp/proofs

PROOFS := commit-message chat explain-region generate-docstring

proof-%:
	$(EMACS) $(EMACSFLAGS) -l proof-harness -l proof-$* --eval "(princ (my/prove-$* \"$(DIR)\"))"

proof: $(patsubst %,proof-%,$(PROOFS))
	@echo "All proofs ran."

# --- Lint target: ensure all Elisp files have balanced parentheses ---
LISP_DIRS := $(HOME)/.emacs.d/lisp $(HOME)/.emacs.d/lisp/proofs

lint:
	@echo "Running check-parens on $(LISP_DIRS)"
	$(EMACS) --batch -Q -l scripts/check-parens.el

# allow `make DIR=/path proof-commit-message`
DIR ?= $(shell pwd)
