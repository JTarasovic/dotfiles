#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CACHE_DIR="$REPO_ROOT/.mise/env-cache"
CONFIG_HASH="$( { cat "$REPO_ROOT/mise.toml" 2>/dev/null; mise --version 2>/dev/null; } | sha256sum | cut -d' ' -f1)"
CACHE_FILE="$CACHE_DIR/$CONFIG_HASH.sh"

if [ -n "$CONFIG_HASH" ] && [ ! -s "$CACHE_FILE" ]; then
  mkdir -p "$CACHE_DIR"
  TMP_FILE="$(mktemp "$CACHE_DIR/.tmp.XXXXXX")"
  if ( cd "$REPO_ROOT" && mise env -s bash ) > "$TMP_FILE" 2>/dev/null; then
    mv "$TMP_FILE" "$CACHE_FILE"
  else
    rm -f "$TMP_FILE"
  fi
fi

[ -s "$CACHE_FILE" ] && source "$CACHE_FILE"
