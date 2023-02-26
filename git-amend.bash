#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

require(){
	hash "$@" || exit 127
}

require git
require git-revise

{
	read -r GIT_DIR
	read -r GIT_WORK_TREE
} < <(git rev-parse --git-dir --show-cdup)
export GIT_DIR
export GIT_WORK_TREE="${GIT_WORK_TREE:-.}"

branch=HEAD
if test $# -ge 2 && test "$1" = --branch; then
	branch=$2
	shift 2
fi

if test $# -ge 2 && test "$1" = --base; then
	base=$2
	shift 2
else
	base=("$GIT_DIR"/refs/remotes/origin/ma*)
	if test ${#base[@]} -eq 1; then
		base=${base##*/}
		base=$(git merge-base origin/"$base" "$branch")
	else
		base=
	fi
fi

show(){
	git diff --relative HEAD .

	local up
	up=$(git rev-parse --show-cdup)

	local n
	if test "$base" != ""; then
		n=$(git rev-list --count "$base..$branch")
	else
		n=$(git rev-list --count "$branch")
	fi
	((n++)) || true

	local l=0
	while read -r r; do
		local h=${r%% *}
		local r=${r#* }
		printf '\e[1;33m%2s \e[34m%s %s\n' "$l" "$h" "$r"
		git diff-tree --no-commit-id --name-only -r --root "$h" | while read -r f
		do
			printf '   '
			realpath --relative-to=. -- "$up$f"
		done
		((l++)) || true
	done < <(git log --pretty=format:$'%h \e[1;33m%s\e[30m%d\e[m' -n"$n" "$branch" && echo)
}

amend(){
	local commit=$1
	shift
	if [[ "$commit" =~ [0-9]+ ]]; then
		commit=HEAD~"$commit"
	fi

	local opts=()
	while test $# -ge 1 && test "${1:0:1}" = -; do
		opts+=("$1")
		shift
	done

	if test $# -eq 0; then
		set -- .
	fi

	git commit "${opts[@]}" --fixup "$commit" "$@"
	EDITOR=true git-revise --interactive --autosquash "${base:---root}"

	git show --relative "$commit" "$@"
}

if test $# -ge 1 && test "${1:0:1}" != -; then
	state=$(git rev-parse HEAD)
	amend "$@"
	printf "OK (Y/n)? "
	read -r ok
	if test "$ok" == n; then
		git reset "$state"
	fi
	show
elif test $# -eq 0; then
	show
else
	echo "Usage:"
	echo "    $0 [--base] [--branch]"
	echo "    $0 [N|HEAD~N] [-p|--patch] [PATHS]"
	exit 1
fi
