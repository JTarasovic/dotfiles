#!/bin/sh

if ! systemctl is-active bluetooth.service > /dev/null 2>&1; then
    exit 0
fi

printf "%s" "$(bluetoothctl devices Paired | grep "$1" | cut -d " " -f 2)"
