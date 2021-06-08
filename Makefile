SHELL = /bin/sh
EMACS ?= emacs
PROFILER =

.PHONY: test deps

# Delete byte-compiled files etc.
clean:
	rm -f *~
	rm -f \#*\#
	rm -f *.elc

deps:
	@mkdir -p deps;
	@if [ ! -f deps/counsel.el ]; then curl -L https://stable.melpa.org/packages/counsel-0.13.4.el > deps/counsel.el; fi;
	@if [ ! -f deps/ivy-0.13.4/ivy.el ]; then curl -L https://stable.melpa.org/packages/ivy-0.13.4.tar | tar x -C deps/; fi;
	@if [ ! -f deps/swiper-0.13.4.el ]; then curl -L https://stable.melpa.org/packages/swiper-0.13.4.el > deps/swiper.el; fi;

test: clean deps
	$(EMACS) -batch -Q -L deps/ -L deps/ivy-0.13.4/ -L deps/swiper-0.13.4/ -l test/dummy.el -l counsel-etags.el -l test/counsel-etags-tests.el
