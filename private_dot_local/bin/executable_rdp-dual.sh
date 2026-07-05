#!/usr/bin/env bash
# Split DisplayPort-3 (5120x1440) into two 2560x1440 logical monitors,
# launch xfreerdp3 in multimon, and tear the split down on exit.
#
# Credentials can be cached in the GNOME keyring so this runs fully
# non-interactively (e.g. from a rofi launcher via --detached):
#   rdp-dual.sh --rdp file.rdp --set-creds   # one-time: prompts and stores the password

OUTPUT="DisplayPort-3"
LEFT_NAME="RDP_LEFT"
RIGHT_NAME="RDP_RIGHT"
KEYRING_SERVICE="rdp-dual"

ORIGINAL_ARGS=("$@")

# --- Config: override via env or an .rdp file (see --rdp below) ---
HOST="${RDP_HOST:-}"
USER_="${RDP_USER:-}"
DOMAIN="${RDP_DOMAIN:-}"
SET_CREDS=false
DETACHED=false

usage() {
    echo "Usage: $0 [--rdp file.rdp] [--set-creds] [--detached] [host] [user]"
    exit 1
}

# --- Optional: pull host/user/domain from an .rdp file ---
parse_rdp() {
    local f="$1"
    [[ -f $f ]] || {
        echo "rdp file not found: $f" >&2
        exit 1
    }
    local addr user dom content
    # grep, not rg: this runs from rofi's Exec=, which has no login shell to
    # put mise-managed tools like rg on PATH.
    #
    # Windows' Remote Desktop Connection saves .rdp files as UTF-16LE (BOM
    # FF FE); grep can't match that directly, so normalize to UTF-8 first.
    if [[ $(head -c2 "$f" | od -An -tx1 | tr -d ' \n') == "fffe" ]]; then
        content=$(iconv -f UTF-16LE -t UTF-8 "$f")
    else
        content=$(cat "$f")
    fi
    addr=$(grep -i '^full address' <<< "$content" | head -1 | cut -d: -f3- | tr -d '\r')
    user=$(grep -i '^username' <<< "$content" | head -1 | cut -d: -f3- | tr -d '\r')
    dom=$(grep -i '^domain' <<< "$content" | head -1 | cut -d: -f3- | tr -d '\r')
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
        --set-creds)
            SET_CREDS=true
            shift
            ;;
        --detached)
            DETACHED=true
            shift
            ;;
        -h | --help) usage ;;
        *)
            if [[ -z $HOST ]]; then HOST="$1"; elif [[ -z $USER_ ]]; then USER_="$1"; fi
            shift
            ;;
    esac
done

# --- Detached (rofi) launch with nothing usable to run silently: go
# straight to an interactive terminal instead of hanging with no tty. ---
relaunch_interactive() {
    local log="${1:-}"
    local -a args=()
    local a
    for a in "${ORIGINAL_ARGS[@]}"; do
        [[ $a == "--detached" ]] || args+=("$a")
    done
    alacritty -e bash -c '
        log="$1"; shift
        script="$1"; shift
        if [[ -s $log ]]; then
            cat "$log"
            echo
            echo "Retrying interactively..."
        fi
        exec "$script" "$@"
    ' _ "$log" "$0" "${args[@]}"
}

# [[ "${XDG_SESSION_TYPE:-}" == "x11" ]] || { echo "Not an X11 session (setmonitor won't work). Current: ${XDG_SESSION_TYPE:-unknown}" >&2; exit 1; }
if [[ -z $HOST ]]; then
    if [[ $DETACHED == true ]]; then
        relaunch_interactive ""
        exit 0
    fi
    echo "No host. Pass one or use --rdp." >&2
    usage
fi

# --- Keyring attribute set shared by --set-creds (store) and lookup ---
# so the two can never drift out of sync.
set_keyring_attrs() {
    KEYRING_ATTRS=(service "$KEYRING_SERVICE" host "$HOST" username "$USER_")
}

if [[ $SET_CREDS == true ]]; then
    [[ -n $USER_ ]] || {
        echo "Need a user (via arg/env/--rdp) to store credentials" >&2
        exit 1
    }
    set_keyring_attrs
    if secret-tool store --label="RDP credentials for ${USER_}@${HOST}" "${KEYRING_ATTRS[@]}"; then
        exit 0
    else
        echo "Failed to store credentials in the keyring" >&2
        exit 1
    fi
fi

# --- Look up a cached password, if any ---
PASSWORD=""
HAVE_CREDS=false
if [[ -n $USER_ ]]; then
    set_keyring_attrs
    if PASSWORD=$(timeout 5 secret-tool lookup "${KEYRING_ATTRS[@]}" 2> /dev/null) && [[ -n $PASSWORD ]]; then
        HAVE_CREDS=true
    fi
fi

if [[ $DETACHED == true && $HAVE_CREDS != true ]]; then
    relaunch_interactive ""
    exit 0
fi

[[ $HAVE_CREDS == true ]] || echo "No cached credentials for ${USER_:-<user>}@$HOST — run '$0 --rdp <file> --set-creds' to cache the password." >&2

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
build_user_flag() {
    if [[ -n $DOMAIN ]]; then
        printf '%s' "/u:${USER_}@${DOMAIN}"
    else
        printf '%s' "/u:${USER_}"
    fi
}

BASE_ARGS=(/v:"$HOST" /multimon /dynamic-resolution +clipboard)

# Runs xfreerdp3. When a cached password is available, the whole argument
# list (including /p:) is fed via /args-from:fd (one arg per line) so the
# password never appears in argv (visible via ps/proc). /from-stdin doesn't
# work here: it still drives xfreerdp3's own tty-based passphrase prompt,
# which fails when stdin isn't a real terminal.
run_xfreerdp() {
    local rc
    if [[ $HAVE_CREDS == true ]]; then
        xfreerdp3 /args-from:fd:3 3< <(
            printf '%s\n' "${BASE_ARGS[@]}" /cert:tofu "$(build_user_flag)" "/p:${PASSWORD}"
        )
        rc=$?
    else
        local -a args=("${BASE_ARGS[@]}")
        [[ -n $USER_ ]] && args+=(/u:"$USER_")
        [[ -n $DOMAIN ]] && args+=(/d:"$DOMAIN")
        xfreerdp3 "${args[@]}"
        rc=$?
    fi
    return $rc
}

echo "Connecting to $HOST ..."

if [[ $DETACHED == true ]]; then
    LOG=$(mktemp)
    if run_xfreerdp > "$LOG" 2>&1; then
        rm -f "$LOG"
    else
        relaunch_interactive "$LOG"
    fi
else
    run_xfreerdp || true
fi

# teardown runs automatically on exit
