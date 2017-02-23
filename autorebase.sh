#!/bin/bash
# vim: set sw=4 expandtab:
#
# Licence: GPLv2+
# Created: 2013-10-09 10:08:24+01:00
# Main authors:
#     - Jérôme Pouiller <jezz@sysmic.org>
#

ACTION=$1
COMMIT=$(git rev-parse --short $2)
PARENT=$(git rev-parse --short $COMMIT^)
[[ "$COMMIT" ]] || exit 1
CORRECT=
for A in p pick r reword e edit s squash f fixup x exec d drop t split; do
     [[ $ACTION == $A ]] && CORRECT=1
done
[[ "$CORRECT" ]] || exit 1
if [[ $ACTION == "drop" || $ACTION == "d" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i -e '/^pick $COMMIT/d'" git rebase -i $PARENT
elif [[ $ACTION == "split" || $ACTION == "t" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/edit $COMMIT/'" git rebase -i $PARENT || exit 1
    git reset --soft HEAD^
    echo "Hints:"
    echo "  Select files to be commited using 'git reset', 'git add' or 'git add -p'"
    echo "  Commit using 'git commit -c $COMMIT'"
    echo "  Finish with 'git rebase --continue'"
else
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/$1 $COMMIT/'" git rebase -i $PARENT
fi
