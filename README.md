# git-amend

## Motivation

Working with a commit stack in git leaves a lot to be desired:

### My workflow, in an ideal world

Drag a hunk into a commit. How hard does it have to be.

### My workflow, as git makes it

Create an "asdf" commit as a hunk transportation vehicle and squash it into the commit it belongs to.
While not looking at it, by editing a file.
Then, look at the result.
If it wasn't the commit it belonged to,
find the likely previous state in the reflog and
try undoing without losing work.

Or, as some prefer, make it a fixup commit, which requires identifying the belonging commit upfront – same problem.

Or use git-absorb, which solves that automagically, but operates on staged files.
I don't know if it's only me, but I never want to _stage_ files!
It's a recipe for accidents, like any hidden state in a user interface.
Just commit whatever it is directly instead.

## Usage

### First, show changes in the current directory on top of the commit stack

    git amend

    --- README.md
    +++ README.md
    @@ -12,22 +12,27 @@ Roses are red
     Violets are
    -violet
    +blue

     0 101ba11 WIP: Something completely different (HEAD -> master)
               src/main.rs
     1 5eababe Readme: Fix documentation bugs
               README.md
     2 f00c0de Merge pull request #9999 from acme/feature-foo (origin/master, origin/HEAD)

This diff shows what you _can_ commit:
Unlike `git diff`, the shown filenames are relative (like you need to use them),
and it shows all uncommitted changes no matter what state the index is in
(such as any added but not yet committed files, which is normally a pitfall).

The commit stack is numbered with each commit's `HEAD~N` index and annotated with branch names in parenthesis and their files.
The last shown commit is the last commit that is in common with the origin's main branch.
This is the main-branch commit you are on top of.

### Then, if some of those changes belong in one of those commits

Amend commit HEAD~1 with all or some of the shown changes:

    git amend 1

or

    git amend 1 README.md

or

    git amend 1 --patch README.md

It then shows what the resulting commit for the mentioned files will look like and asks you if it looks ok. Answering "n" will undo.

Finally, it goes back to showing the remaining changes on top of the stack again.

## Install

Copy it without file extension to somewhere in your path:

    install git-amend.bash "$HOME"/.local/bin/git-amend

If you use this command often, just choose a shorter name.
It does not need to begin with "git-" other than
if you like to type "git " first.

### Dependencies

It uses [git-revise](https://github.com/mystor/git-revise).
For a good reason: Unlike regular rebase, you can revise and amend commits while compiling, because these tools don't touch your workspace.

Dependencies are checked at startup. This also works before installation (missing dependency is exit status 127):

    ./git-amend.bash; echo "Exit status $?"

## Bugs

* It will implicitly and surprisingly autosquash any fixups you had from before
just because that's what it uses internally. That is not a priority right now. It is merely the first functional prototype of that DnD GUI I hope exists one day. Which might also use libraries and do things properly.
