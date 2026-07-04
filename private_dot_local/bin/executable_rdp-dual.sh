#!/usr/bin/env bash
# Split DisplayPort-3 (5120x1440) into two 2560x1440 logical monitors,
# launch xfreerdp3 in multimon, and tear the split down on exit.
set -x

OUTPUT="DisplayPort-3"
LEFT_NAME="RDP_LEFT"
RIGHT_NAME="RDP_RIGHT"

# --- Config: override via env or an .rdp file (see --rdp below) ---
HOST="${RDP_HOST:-}"
USER_="${RDP_USER:-}"
DOMAIN="${RDP_DOMAIN:-}"

usage() {
    echo "Usage: $0 [--rdp file.rdp] [host] [user]"
    exit 1
}

# --- Optional: pull host/user/domain from an .rdp file ---
parse_rdp() {
    local f="$1"
    [[ -f $f ]] || {
        echo "rdp file not found: $f" >&2
        exit 1
    }
    local addr user dom
    addr=$(rg -i '^full address' "$f" | head -1 | cut -d: -f3- | tr -d '\r')
    user=$(rg -i '^username' "$f" | head -1 | cut -d: -f3- | tr -d '\r')
    dom=$(rg -i '^domain' "$f" | head -1 | cut -d: -f3- | tr -d '\r')
    [[ -n $addr ]] && HOST="${HOST:-$addr}"
    [[ -n $user ]] && USER_="${USER_:-$user}"
    [[ -n $dom ]] && DOMAIN="${DOMAIN:-$dom}"
}

# --- Args ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --rdp)
            parse_rdp "$2"
            shift 2
            ;;
        -h | --help) usage ;;
        *)
            if [[ -z $HOST ]]; then HOST="$1"; elif [[ -z $USER_ ]]; then USER_="$1"; fi
            shift
            ;;
    esac
done

# [[ "${XDG_SESSION_TYPE:-}" == "x11" ]] || { echo "Not an X11 session (setmonitor won't work). Current: ${XDG_SESSION_TYPE:-unknown}" >&2; exit 1; }
[[ -n $HOST ]] || {
    echo "No host. Pass one or use --rdp." >&2
    usage
}

# --- Split: 5120 wide, 1200mm -> two 2560 halves, 600mm each ---
split_display() {
    xrandr --setmonitor "$LEFT_NAME" 2560/600x1440/340+0+0 "$OUTPUT"
    xrandr --setmonitor "$RIGHT_NAME" 2560/600x1440/340+2560+0 none
    xrandr --listactivemonitors
}

teardown() {
    xrandr --delmonitor "$RIGHT_NAME" 2> /dev/null || true
    xrandr --delmonitor "$LEFT_NAME" 2> /dev/null || true
}
trap teardown EXIT INT TERM

split_display

# --- Launch ---
ARGS=(/v:"$HOST" /multimon /dynamic-resolution +clipboard)
[[ -n $USER_ ]] && ARGS+=(/u:"$USER_")
[[ -n $DOMAIN ]] && ARGS+=(/d:"$DOMAIN")

echo "Connecting to $HOST ..."
xfreerdp3 "${ARGS[@]}" || true

# teardown runs automatically on exit
