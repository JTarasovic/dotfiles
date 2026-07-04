#!/usr/bin/env bash

# Init call: xfreerdp runs "action.sh key" and reads the combo list from stdout
if [ "$#" -eq 1 ] && [ "$1" = "key" ]; then
    echo "Super_L+2"
    echo "Control_L+Alt_L+2"
    exit 0
fi

# Init: list xevents to hook (we want none; give it one to keep it quiet)
if [ "$1" = "xevent" ] && [ -z "$2" ]; then
    echo "FocusIn"
    exit 0
fi

# Key call: "action.sh key <combo>"
echo "$@" >>/tmp/rdp-keys.log
case "$2" in
*Super*2* | *Control*Alt*2*)
    i3-msg workspace 2 >/dev/null
    echo key-local
    ;;
esac

echo ignored
