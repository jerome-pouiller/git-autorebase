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
COMMIT=$(git rev-parse --short "$*")
[[ $COMMIT ]] || die "Invalid commit \"$*\""
PARENT=$(git rev-parse --short $COMMIT^)
if ! git merge-base --is-ancestor $COMMIT $ORIGIN
then
    die "$COMMIT is not an ancestor of HEAD"
fi

case $ACTION in
d | delete | drop)
    # Delete line (more general way to drop commit)
    GIT_SEQUENCE_EDITOR="sed -i -e '/^pick $COMMIT/{d;q}'" \
        git rebase -i $PARENT
    ;;
t | split)
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/edit $COMMIT/'" \
        git rebase -i $PARENT || exit 1
    git reset --soft HEAD^
    git diff --stat --staged
    echo "Hints:"
    echo "  - Select files to be commited with 'git reset', 'git add' or"
    echo "    'git add -p'"
    echo "  - Commit using 'git commit -c $COMMIT'"
    echo "  - Finish with 'git rebase --continue'"
    ;;
p | pick   | r | reword | e | edit | \
s | squash | f | fixup  | x | exec )
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/$ACTION $COMMIT/'" \
        git rebase -i $PARENT
    ;;
*)
    die "$ACTION is not a correct rebase -i action"
    ;;
esac
