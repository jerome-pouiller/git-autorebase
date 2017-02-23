#!/bin/bash
# vim: set sw=4 expandtab:
#
# Licence: GPLv2+
# Created: 2013-10-09 10:08:24+01:00
# Main authors:
#     - Jérôme Pouiller <jezz@sysmic.org>
#

die() {
       echo $@
       exit 1
}

[[ ${#*} -ge 2 ]] || die "syntax: git autorebase ACTION COMMIT"
ACTION=$1
shift
ORIGIN=$(git rev-parse --short HEAD)
COMMIT=$(git rev-parse --short $*)
[[ $COMMIT ]] || die "Invalid commit \"$*\""
PARENT=$(git rev-parse --short $COMMIT^)
git merge-base --is-ancestor $COMMIT $ORIGIN || die "$COMMIT is not an ancestor of HEAD"
CORRECT=
for A in p pick r reword e edit s squash f fixup x exec d drop t split; do
     [[ $ACTION == $A ]] && CORRECT=1
done
[[ "$CORRECT" ]] || die "$ACTION is not a correct action"
if [[ $ACTION == "split" || $ACTION == "t" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/edit $COMMIT/'" git rebase -i $PARENT || exit 1
    git reset --soft HEAD^
    git diff --stat --staged
    echo "Hints:"
    echo "  - Select files to be commited with 'git reset', 'git add' or"
    echo "    'git add -p'"
    echo "  - Commit using 'git commit -c $COMMIT'"
    echo "  - Finish with 'git rebase --continue'"
else
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/$ACTION $COMMIT/'" git rebase -i $PARENT
fi
