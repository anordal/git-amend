#!/usr/bin/env bash
set -e

branch=HEAD
if test $# -ge 1; then
	branch=$1
fi

if test $# -ge 2; then
	base=$2
else
	base=$(git merge-base origin/master "$branch")
fi

n=$(git rev-list "$base..$branch" --count)
((n+=2)) || true

l=0
while read -r r; do
	h=${r%% *}
	r=${r#* }
	printf '\e[1;33m%2s \e[34m%s %s\n' "$l" "$h" "$r"
	git diff-tree --no-commit-id --name-only -r "$h"
	((l++)) || true
done < <(git log --pretty=format:$'%h \e[1;33m%s\e[30m%d\e[m' -n"$n" "$branch")
