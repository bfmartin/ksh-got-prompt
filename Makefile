# TESTDIR specifies where to create repos for testing.
# this directory can't be within this project dir because the got status
# of this project would conflict with the test repository.
TESTDIR != mktemp -d

.PHONY: test

test:
	@bin/setup.sh ${TESTDIR} >/dev/null
	@bin/test.sh ${TESTDIR}
	@rm -rf ${TESTDIR}

# housekeeping tasks. only of interest to the author
SHX = prompt/ksh-got-prompt.sh bin/*
XTRAC = Makefile
sinclude ${HOME}/bin/lib/Makefile-global
