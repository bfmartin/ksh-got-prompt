# Show the Status of a GOT Repo in a KSH Prompt

This will show the status of a `got` work tree in a `ksh` prompt. It's targeted at developers on the OpenBSD system.

## To Enable

### Install Shell Scipt

Copy the file `ksh-got-prompt.sh` somewhere. For example:

~~~
  # cp prompt/ksh-got-prompt.sh /etc
~~~

### Configure yor `kshrc` file

In your kshrc file (e.g. `$HOME/.kshrc` or `/etc/ksh.kshrc`), add the following line:

~~~
  . /etc/ksh-got-prompt.sh`
~~~

In the same file, add this line, or change the existing PS1 line to this:

~~~
  export PS1='\h $(__got_ps1 "(%s) ")$ '
~~~

## Features

The prompt only shows if the current directory is a work tree or a repository.

The prompt will show these items:

* Branch name (shows when in a worktree)
* Untracked files (shows ?)
* Modified and removed files (shows #)
* Added or deleted but not committed files (shows +)
* Bare repository (shows BARE:)

### Does not Work (Yet)

While lots of information is available through the `got info` and `gotadmin info` commands, I am not able to find everything. If anyone knows how to determine this information, please open an issue or pull request. These items are not working:

* Commits ahead of or behind upstream
* Repo status: detached upstream / rebase / merge / cherrypick / reverting / bisection
* Bare repos don't show branch

Plus, colours in the status would be nice.

### Removed Functionality

These features are in the `git` version that I chose to remove.

* Setting variables (like `GIT_PS1_SHOWUNTRACKEDFILES`) to control display of states like untracked or modified files. For simplicity, you get everything.
* Showing `GOT_DIR!` when in the `.got` directory of a work tree. This makes sense for `git` since the repo is usually in `.git`, but in `got` the repo is elsewhere.

## Requirements

At least OpenBSD 7.2 and `got` version 0.76.

Earlier versions have not been tested, and functionality would depend on the capabilities of the `got` version.

The only optional software that is required is the `got` package. If you are here, you already have it installed, Just in case, though, install like this (as root):

~~~
  # pkg_add got
~~~

## Customising Your Prompt

ksh-got-prompt accepts one optional parameter, a format string.

The default value is "(%s)". The %s will be replaced with the got info.

Use "(%s) " to add a space character after the repo information.

See the PS1 variable in the reference documentation at [https://man.openbsd.org/ksh#Parameters](https://man.openbsd.org/ksh#Parameters) to further customise your prompt.

Here's what I use:

~~~
  export PS1='\[$(if [ $? = 0 ]; then echo "\e[32m";else echo "\e[31m"; fi)\h\e[00m:$? \w $(__got_ps1 "(%s) ")\$ \]'
~~~

Rendered as

![Sample prompt](images/prompt-example.png)

Tip: Enclose the prompt string in single quotes. Double quotes won't work as expected.

## Unit Tests

If you want to hack on the code, you may be interested in the unit tests. To run, run this command:

~~~
  make test
~~~

## History

ksh-git-prompt for `git` was created by Shawn O. Pearce <spearce@spearce.org> in 2006 and is copyrighted by them. It is available in multiple places in slightly different forms. It is released under the GNU General Public License 2.0.

This version for `got` builds upon that, though the code base has diverged by neccesity.
