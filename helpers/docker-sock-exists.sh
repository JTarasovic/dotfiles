#!/bin/sh

SOCK="$XDG_RUNTIME_DIR/docker.sock"

if [ -S "$SOCK" ];
then
    printf "%s" "$SOCK"
fi

exit 0
