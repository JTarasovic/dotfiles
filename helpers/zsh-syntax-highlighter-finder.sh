#!/bin/bash

HIGHLIGHT=zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

for dir in /usr/local/share /usr/share /usr/share/zsh/plugins;
do
    search="$dir/$HIGHLIGHT"
    [[ -f "$search" ]] && { echo "source \"$search\""; exit 0; }
done
