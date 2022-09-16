#!/bin/bash

# TODO: generalize this script?

HIGHLIGHT=zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

for dir in /usr/local/share /usr/share /usr/share/zsh/plugins /opt/homebrew/share;
do
    search="$dir/$HIGHLIGHT"
    [[ -f "$search" ]] && { echo "source \"$search\""; exit 0; }
done

exit 0
