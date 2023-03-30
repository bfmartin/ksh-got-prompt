# shellcheck shell=ksh
# got prompt support for ksh
#
# the version originally written for git is
# Copyright (C) 2006,2007 Shawn O. Pearce <spearce@spearce.org>
# Distributed under the GNU General Public License, version 2.0.
#
# this version is adapted for got by Byron F. MArtin, 2022
# https://www.github.com/bfmartin/ksh-got-prompt
#
# This script allows you to see repository status in your prompt.
#
# To enable:
#
#	1) Copy this file somewhere, e.g.
#		# cp prompt/ksh-got-prompt.sh /etc
#
#	2) Modify your kshrc file, like $HOME/.kshrc or /etc/ksh.kshrc
#		Add the following line:
#			. /etc/ksh-got-prompt.sh
#		Add or change the PS1 line configuring the prompt
#			PS1='[\u@\h \W$(__got_ps1 " (%s)")]\$ '
#
# The %s token is the placeholder for the shown status.
#
# The repository status will be displayed only if you are currently in a
# got repository or working tree.

# __got_ps1 accepts 0 or 1 arguments (i.e., format string)
# prints text to add to ksh PS1 prompt (includes branch name)
__got_ps1()
{
	# Using \[ and \] around colors is necessary to prevent
	# issues with command line editing/browsing/completion!
	# local c_red='\[\e[31m\]'
	# local c_brown='\[\e[33m\]'
	# local c_magenta='\[\e[35m\]'
	local c_green='\[\e[32m\]'
	local c_lblue='\[\e[1;34m\]'
	local c_clear='\[\e[0m\]'

	# local bad_color=$c_red
	local ok_color="$c_green"
	local flags_color="$c_lblue"
	local branch_color="$c_green"

	# save incoming exit status for later
	local exit=$?
	# default format
	local printf_format='(%s) '

	case "$#" in
		0|1)	printf_format="${1:-$printf_format}" ;;
		*)	return $exit ;;
	esac

	local rev_parse_exit_code
	local bare_repo="false"
	local inside_worktree="false"

	got info >/dev/null 2>&1
	rev_parse_exit_code="$?"

	if [ "$rev_parse_exit_code" -eq 0 ]; then
		inside_worktree="true"
	else
		# this is not a work tree. is it a repo?
		gotadmin info >/dev/null 2>&1
		rev_parse_exit_code="$?"

		if [ "$rev_parse_exit_code" -eq 1 ]; then
			# not repo. give up
			return $exit
		else
			# yes repo
			bare_repo="true"
		fi
	fi

	# these variables are used to compose the prompt string
	local b="" # branch name (previously also "GOT_DIR!", now unused)
	local c="" # bare
	local i="" # modified or deleted #
	local s="" # untracked %
	local z=" " # separates branch name from state

	local p="" # unused: compare to upstream
	local r="" # unused: state (rebase/merging/cherry-picking/reverting/bisecting)
	local u="" # unused: compare to upstream
	local w="" # unused: not sure of its use

	if [ "true" = "$bare_repo" ]; then
		c="${branch_color}BARE${c_clear}:"

	elif [ "true" = "$inside_worktree" ]; then
		# check the results of got status

		# M	modified file
		# m	modified file modes (executable bit only)
		# N	non-existent path specified on the command line
		# !	versioned file was expected on disk but is missing
		if [ "$(got status -s 'MmN!' | wc -l)" -ne 0 ]; then
			i="${ok_color}#"
		fi

		# A	file scheduled for addition in next commit
		# C	modified or added file which contains merge conflicts
		# D	file scheduled for deletion in next commit
		# ~	versioned file is obstructed by a non-regular file
		if [ "$(got status -s 'ACD~' | wc -l)" -ne 0 ]; then
			i="${ok_color}${i}+"
		fi

		# ?	unversioned item not tracked by got
		if [ "$(got status -s '?' | wc -l)" -ne 0 ]; then
			s="${flags_color}%"
		fi

		# which branch
		b="${ok_color}$(got branch)"
	fi

	# compose the prompt
	local f="$w$i$s$u" # combination of states, e.g., "#%" (plus unused vars)
	local gotstring="${c}${b}${f:+$z$f}${r}${p}${c_clear}" # add branch

	# shell check doesn't like a variable used as a format string
	# but we can't avoid it because the format string is passed in as
	# an arg, so disable
	# shellcheck disable=SC2059
	printf -- "$printf_format" "$gotstring"

	return $exit
}
