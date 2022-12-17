#!/bin/ksh

# this sets up some primitive unit test for ksh prompt for got
# run this using "make test"
# this script requires one parameter, a directory for the test repos
#
# the directory for the test repos cannot be within this project dir
# because this got repo would conflict with the test repo
#
# prompt values are set up to be compared against expected values

# confirm command line parameter is a dir for testing
[ "$#" -eq 1 ] || { echo 'run this using "make test"'; exit 1; }
TMPDIR=$1
[ -d "$TMPDIR" ] || { echo 'run this using "make test"'; exit 1; }

REPOSDIR=$TMPDIR/got/repos # test repositories
mkdir -p "$REPOSDIR"

####################################
# set up the test repos

# this function needs to be run first
# this is a repo that will be cloned. bare repo
setup_got_orig() {
	# create some text files to import into original
	mkdir tmp
	echo "this is the original repo" > tmp/README.txt
	echo "just basic stuff so far" > tmp/TODO.txt

	gotadmin init original.git
	got import -r original.git -I obj -m "initial import" ./tmp

	# cleanups
	rm -rf tmp
}

# work tree withe file added but not committed
setup_got_added() {
	got checkout original.git added
	cd added || exit
	echo "this is a modified repo" > new.txt
	got add new.txt
}

# work tree with different branch name than master
setup_got_branch() {
	got checkout original.git branch
	cd branch || exit
	got branch newbranch
}

# work tree multiple status items
setup_got_combined() {
	got checkout original.git combined
	cd combined || exit
	got branch combinedbranch
	echo "this is a modified repo" > README.txt
	echo "this is a modified repo" > new.txt
	got add new.txt
	echo "release 0.0.1 initial beta" > RELEASES.txt
}

# work tree with modified file
setup_got_modified() {
	got checkout original.git modified
	cd modified || exit
	echo "this is a modified repo" > README.txt
}

# not a work tree or repo
setup_got_notarepo() {
	mkdir notarepo
	cd notarepo || exit
	echo "ya ya ya" > README.txt
}

# work tree with file removed but not committed
setup_got_removed() {
	got checkout original.git removed
	cd removed || exit
	rm README.txt
}

# work tree with no modified or new files
setup_got_unmodified() {
	got checkout original.git unmodified
}

# work tree contains untracked file
setup_got_untracked() {
	got checkout original.git untracked
	cd untracked || exit
	echo "release 0.0.1 initial beta" > RELEASES.txt
}

####################################
# start here
# run eack setup
for dir in orig added branch combined modified notarepo removed unmodified untracked; do
	cd "$REPOSDIR" && eval setup_got_$dir
done
