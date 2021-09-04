#!/bin/sh

SOCK="$XDG_RUNTIME_DIR/docker.sock"

if [ -S "$SOCK" ]; then
    printf "export DOCKER_HOST=unix://%s" "$SOCK"
fi

exit 0
