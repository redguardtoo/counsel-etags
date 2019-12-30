SHELL = /bin/sh
EMACS ?= emacs
PROFILER =

.PHONY: test

# Delete byte-compiled files etc.
clean:
	rm -f *~
	rm -f \#*\#
	rm -f *.elc

# Run tests.
test: clean
	$(EMACS) -batch -Q -l test/dummy.el -l counsel-etags-sdk.el -l counsel-etags-javascript.el -l counsel-etags.el -l test/counsel-etags-tests.el
