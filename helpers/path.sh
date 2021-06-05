#!/bin/sh

# start with an empty path
# shellcheck disable=2123
PATH=""

resolvelink() {
    /usr/bin/perl -MCwd -le 'print Cwd::abs_path(shift)' "$1"
}

pathmunge() {
    path="$1"
    # exit early if dir doesn't exist
    [ ! -d "$path" ] && return

    # resolve symlink
    path="$(resolvelink "$path")"

    # if path isn't already in $PATH
    if ! echo "$PATH" | /usr/bin/grep -Eq "(^|:)$path($|:)" ; then
         PATH=$path:$PATH
    fi
}

pathmunge /bin
pathmunge /sbin
pathmunge /usr/bin
pathmunge /usr/sbin
pathmunge /usr/local/bin
pathmunge /usr/local/go/bin
pathmunge /usr/local/heroku/bin
pathmunge "/usr/local/opt/mysql-client@5.7/bin"
pathmunge "$HOME/.rvm/bin"
pathmunge "$HOME/mongo/current/bin"
pathmunge "$HOME/Library/Python/3.7/bin"
pathmunge "${KREW_ROOT:-$HOME/.krew}/bin"
pathmunge "$HOME/.cargo/bin"
pathmunge "$HOME/go/bin"
pathmunge "$HOME/.local/bin"

echo "export PATH=\"$PATH\""
