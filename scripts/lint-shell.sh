#!/usr/bin/env bash
# lint-shell.sh — single source of truth for shell guardrails in this repo.
#
# Called by:
#   - pre-commit framework:    pre-commit run shell-guardrails
#   - Claude Code Stop hook:   scripts/claude-stop-lint.sh
#
# Usage: scripts/lint-shell.sh [--list]
#   --list   Print which files are in each linting bucket, then exit (no checks run).
#
# Policy (enforced):
#   - shellcheck --severity=warning on plain bash/sh scripts and rendered templates.
#   - shfmt -d (check-only, never modifies files) on plain bash/sh scripts.
#   - Zsh files: render-only validation via `chezmoi cat` (shellcheck has no zsh support).
#   - shfmt is NOT run on rendered templates (diffs can't be applied back to source).
#   - Vendored/third-party files are skipped.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Config ────────────────────────────────────────────────────────────────────

# Files excluded from linting (vendored or otherwise intentionally skipped).
# Paths are relative to REPO_ROOT.
VENDORED=(
    "private_dot_local/bin/executable_rofi-power-menu"
)

# shfmt flags — match the user's existing cmetf function
SHFMT_FLAGS=(-d -s -bn -i 4 -ci -sr)

# ── Helpers ───────────────────────────────────────────────────────────────────

LIST_ONLY=false
[[ ${1:-} == "--list" ]] && LIST_ONLY=true

fail=0

is_vendored() {
    local rel="$1"
    for v in "${VENDORED[@]}"; do
        [[ $rel == "$v" ]] && return 0
    done
    return 1
}

get_shebang_dialect() {
    local file="$1"
    local line
    line=$(head -1 "$file")
    case "$line" in
        *zsh*) echo "zsh" ;;
        *bash*) echo "bash" ;;
        *"env sh"* | *"/bin/sh"*) echo "sh" ;;
        *) echo "unknown" ;;
    esac
}

run_shellcheck_stdin() {
    local dialect="$1"
    shift 1
    # Pass "$@" directly — safe in bash 3.2 even when empty (unlike "${arr[@]}" on empty local arrays)
    if ! shellcheck --severity=warning -s "$dialect" "$@" - 2>&1; then
        echo "  ↳ Fix the issue in the source template (above is output of rendered file)"
        return 1
    fi
}

lint_plain_file() {
    local f="$1"
    local rel="${f#"$REPO_ROOT/"}"

    if is_vendored "$rel"; then
        echo "  SKIP (vendored): $rel"
        return 0
    fi

    local dialect
    dialect=$(get_shebang_dialect "$f")

    if [[ $LIST_ONLY == true ]]; then
        echo "  [$dialect] $rel"
        return 0
    fi

    case "$dialect" in
        zsh)
            echo "  SKIP (zsh — not lintable by shellcheck/shfmt): $rel"
            ;;
        bash | sh)
            echo "  Checking: $rel"
            if ! shellcheck --severity=warning "$f" 2>&1; then
                fail=1
            fi
            if ! shfmt "${SHFMT_FLAGS[@]}" "$f" 2>&1; then
                fail=1
            fi
            ;;
        *)
            echo "  SKIP (unknown shebang): $rel"
            ;;
    esac
}

# ── Bucket 1: Dev scripts (scripts/*.sh) ─────────────────────────────────────

echo "── Dev scripts (scripts/) ──"
while IFS= read -r f; do
    lint_plain_file "$f"
done < <(find "$REPO_ROOT/scripts" -name "*.sh" | sort)
echo

# ── Bucket 2: Plain scripts (lint directly, no rendering) ─────────────────────

echo "── Plain scripts ──"

# helpers/*.sh
while IFS= read -r f; do
    lint_plain_file "$f"
done < <(find "$REPO_ROOT/helpers" -name "*.sh" | sort)

# private_dot_local/bin/executable_* (skip .tmpl variants)
while IFS= read -r f; do
    [[ $f == *.tmpl ]] && continue
    lint_plain_file "$f"
done < <(find "$REPO_ROOT/private_dot_local/bin" -name "executable_*" | sort)
echo

# ── Bucket 3: Rendered templates (shellcheck only) ───────────────────────────

echo "── Rendered templates (shellcheck, no shfmt) ──"

# Format: "chezmoi_target|dialect[|--extra-flag ...]"
TEMPLATES=(
    "$HOME/.bashrc|bash|--exclude=SC2154"
    "$HOME/.bash_profile|bash"
    "$HOME/.env.sh|sh"
    "$HOME/.local/bin/__chezmoi_post_apply|bash"
)

for entry in "${TEMPLATES[@]}"; do
    IFS='|' read -r target dialect extra_flags <<< "${entry}|"

    if [[ $LIST_ONLY == true ]]; then
        echo "  [render:$dialect] $target"
        continue
    fi

    echo "  Checking: $(basename "$target") (rendered as $dialect)"

    # Render first: capture stdout only; stderr goes to terminal so render errors are visible
    # and distinguishable from shellcheck findings (V2 fix).
    local_rendered=$(chezmoi cat "$target") || {
        echo "  ✗ FAIL: template rendering error (see above)"
        fail=1
        continue
    }

    # Split extra_flags into an array so multi-flag entries work (e.g. "--exclude=A --exclude=B").
    # read -ra is safe here: we only reach this branch when extra_flags is non-empty (V3 fix).
    if [[ -n ${extra_flags:-} ]]; then
        read -ra extra_arr <<< "$extra_flags"
        if ! printf '%s\n' "$local_rendered" | run_shellcheck_stdin "$dialect" "${extra_arr[@]}"; then
            fail=1
        fi
    else
        if ! printf '%s\n' "$local_rendered" | run_shellcheck_stdin "$dialect"; then
            fail=1
        fi
    fi
done
echo

# ── Bucket 4: Zsh — render/parse validation only ────────────────────────────

echo "── Zsh render validation (no shellcheck/shfmt) ──"

ZSH_TARGETS=(
    "$HOME/.zshrc"
    "$HOME/.config/claude-code/.zshrc"
)

for target in "${ZSH_TARGETS[@]}"; do
    if [[ $LIST_ONLY == true ]]; then
        echo "  [render:zsh] $target"
        continue
    fi

    echo "  Render-check: $target"
    if ! chezmoi cat "$target" > /dev/null 2>&1; then
        echo "  ✗ FAIL: 'chezmoi cat $target' failed — template rendering error"
        fail=1
    fi
done
echo

# ── Result ────────────────────────────────────────────────────────────────────

[[ $LIST_ONLY == true ]] && exit 0

if [[ $fail -ne 0 ]]; then
    echo "✗ Shell guardrails FAILED — fix the issues above before committing."
    exit 1
else
    echo "✓ Shell guardrails passed."
fi
