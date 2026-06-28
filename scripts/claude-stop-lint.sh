#!/usr/bin/env bash
# claude-stop-lint.sh — Claude Code Stop hook for shell guardrails.
#
# Contract (from Claude Code docs):
#   - stdin: JSON with session metadata including stop_hook_active and cwd.
#   - exit 0: allow Claude to stop.
#   - exit 2 + stderr: block the stop; stderr is fed back to Claude as feedback.
#   - stop_hook_active=true means this hook already triggered a block this turn;
#     we must exit 0 to prevent an infinite loop (Claude Code also caps at 8 blocks).
#
# This hook only runs linting when shell-relevant files are dirty in the working
# tree, so it is silent on turns that don't touch shell code.
set -euo pipefail

INPUT=$(cat)

# ── Loop prevention ───────────────────────────────────────────────────────────
# If stop_hook_active is true, this hook already blocked once this turn.
# Exit 0 unconditionally to avoid an infinite block loop.
if [[ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active')" == "true" ]]; then
    exit 0
fi

# ── Locate repo root ──────────────────────────────────────────────────────────
REPO_ROOT=$(git rev-parse --show-toplevel 2> /dev/null) || {
    # Not inside a git repo — nothing to lint.
    exit 0
}

# ── Check for shell-relevant dirty files ─────────────────────────────────────
# Only lint when this Claude turn actually touched something lintable.
# Pattern matches source paths that lint-shell.sh cares about.
# sed splits porcelain v1 rename lines (`R  old -> new`) into two separate lines
# so the $-anchored extensions match both the old and new path.
SHELL_PATTERN='\.(tmpl|sh)$|private_dot_local/bin/executable_|\.chezmoitemplates/|^helpers/|^scripts/'

if ! git -C "$REPO_ROOT" status --porcelain 2> /dev/null \
    | cut -c4- \
    | sed 's/ -> /\n/' \
    | grep -qE "$SHELL_PATTERN"; then
    exit 0
fi

# ── Run lint ──────────────────────────────────────────────────────────────────
LINT_SCRIPT="$REPO_ROOT/scripts/lint-shell.sh"

if [[ ! -x $LINT_SCRIPT ]]; then
    printf 'warning: lint script not found or not executable: %s\n' "$LINT_SCRIPT" >&2
    printf 'hint: ensure scripts/ is committed and scripts/*.sh are chmod +x.\n' >&2
    exit 0
fi

if LINT_OUTPUT=$("$LINT_SCRIPT" 2>&1); then
    exit 0
else
    printf '%s\n' "$LINT_OUTPUT" >&2
    exit 2
fi
