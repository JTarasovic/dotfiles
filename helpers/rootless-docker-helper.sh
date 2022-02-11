#!/bin/sh

SOCK="$($1)"
if [ -n "$SOCK" ];
then
    printf "export DOCKER_HOST=unix://%s" "$SOCK"
fi

exit 0
