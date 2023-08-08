SHELL = /bin/sh
EMACS ?= emacs
PROFILER =
EMACS_BATCH_OPTS=--batch -Q \
-L . \
-L deps/ \
-L deps/counsel-0.14.0/ \
-L deps/ivy-0.14.0/ \
-L deps/swiper-0.14.0/ \
-l tests/dummy.el \
-l counsel-etags.el

RM = @rm -rf

.PHONY: test deps compile clean

# Delete byte-compiled files etc.
clean:
	$(RM) *~
	$(RM) \#*\#
	$(RM) *.elc
	$(RM) deps/*

deps:
	@mkdir -p deps;
	@if [ ! -f deps/counsel-0.14.0/counsel.el ]; then curl -L https://stable.melpa.org/packages/counsel-0.14.0.tar | tar x -C deps/; fi;
	@if [ ! -f deps/ivy-0.14.0/ivy.el ]; then curl -L https://stable.melpa.org/packages/ivy-0.14.0.tar | tar x -C deps/; fi;
	@if [ ! -f deps/swiper-0.14.0/swiper.el ]; then curl -L https://stable.melpa.org/packages/swiper-0.14.0.tar | tar x -C deps/; fi;

compile: deps
	$(RM) *.elc
	@$(EMACS) ${EMACS_BATCH_OPTS} -l tests/my-byte-compile.el 2>&1 | grep -E "([Ee]rror|[Ww]arning):" && exit 1 || exit 0

test: compile deps
	$(EMACS) $(EMACS_BATCH_OPTS) -l tests/counsel-etags-tests.el
