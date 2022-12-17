#!/bin/ksh

# this runs some primitive unit tests for ksh prompts for got
# run this using "make test"
# this script requires one parameter, a directory for the test repos
#
# the directory for the test repos cannot be within this project dir
# because this got repo would conflict with the test repo
#
# prompt values for each are compared against expected values

# confirm command line parameter is a dir for testing
[ "$#" -eq 1 ] || { echo 'run this using "make test"'; exit 1; }
TMPDIR=$1
[ -d "$TMPDIR" ] || { echo 'run this using "make test"'; exit 1; }

REPOSDIR=$TMPDIR/got/repos # test repositories

TOPDIR=$(dirname "$(readlink -f "$0")")/.. # top of repo dir
GOODDIR=$TOPDIR/testdata/got # good results dir
RESULTSDIR=$TMPDIR/got/results # test results
CDPATH= # supress extra messages, in case

####################################
# run the test repos

# function to run a test and compare the results to known good results
runtest() {
	dir="$1"

	# execute test
	echo testing "$dir"
	__got_ps1 "(%s)" > "$RESULTSDIR/$dir"
	echo >> "$RESULTSDIR/$dir"

	# compare results against expected
	cmp -s "$RESULTSDIR/$dir" "$GOODDIR/$dir" || {
		echo "test $dir failed"
		echo "	expected: $(cat "$GOODDIR/$dir")"
		echo "	received: $(cat "$RESULTSDIR/$dir")"
	}
}

####################################
# start here

# source the prompt from this work dir
. "$TOPDIR"/prompt/ksh-got-prompt.sh

mkdir -p "$RESULTSDIR"

cd "$REPOSDIR" || exit
for dir in *; do
	cd "$dir" || exit
	runtest "$dir"
	cd ..
done
