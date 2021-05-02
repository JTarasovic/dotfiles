#!/bin/sh

printf "%s" "$(rofi --help \
    | grep -A 10 "Detected modi:" \
    | grep '\*' \
    | cut -d '*' -f 2 \
    | tr -d ' ' \
    | xargs)"
