#!/bin/sh

PATH="/usr/bin"
pathmunge () {
    # exit early if dir doesn't exist
    [ ! -d "$1" ] && return
    # if path isn't already in $PATH
    if ! echo "$PATH" | grep -Eq "(^|:)$1($|:)" ; then
         PATH=$1:$PATH
    fi
}

pathmunge /usr/local/bin
pathmunge /usr/local/go/bin
pathmunge /usr/local/heroku/bin
pathmunge "$HOME/.rvm/bin"
pathmunge "$HOME/mongo/current/bin"
pathmunge "$HOME/Library/Python/3.7/bin"
pathmunge "${KREW_ROOT:-$HOME/.krew}/bin"
pathmunge "$HOME/.cargo/bin"
pathmunge "$HOME/go/bin"
pathmunge "$HOME/.local/bin"

echo "export PATH=\"$PATH\""
