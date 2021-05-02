#!/bin/sh

printf "%s" "$(bluetoothctl paired-devices | grep "$1" | cut -d " " -f 2)"
