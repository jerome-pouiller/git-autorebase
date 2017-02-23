#!/bin/bash

ACTION=$1
COMMIT=$(git rev-parse --short $2)
[[ "$COMMIT" ]] || exit 1
CORRECT=
for A in p pick r reword e edit s squash f fixup x exec d delete t split; do
     [[ $ACTION == $A ]] && CORRECT=1
done 
[[ "$CORRECT" ]] || exit 1
if [[ $ACTION == "delete" || $ACTION == "d" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i -e '/^pick $COMMIT/d'" git rebase -i $COMMIT^^
elif [[ $ACTION == "split" || $ACTION == "t" ]]; then
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/edit $COMMIT/'" git rebase -i $COMMIT^^ || exit 1
    git reset --soft HEAD^
    echo "Hints:"
    echo "  Select files to be commited using 'git reset', 'git add' or 'git add -p'"
    echo "  Commit using 'git commit -c $COMMIT'"
    echo "  Finish with 'git rebase --continue'"
else
    GIT_SEQUENCE_EDITOR="sed -i -e 's/^pick $COMMIT/$1 $COMMIT/'" git rebase -i $COMMIT^^
fi
