# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

This is a [chezmoi](https://chezmoi.io) dotfiles repository managing shell configuration, editor setup, and system tooling across macOS and Linux.

## Critical Rule: Edit Source, Never Target

**Never edit a file that chezmoi manages directly in `$HOME`.** Always edit the source file in this repo, then apply. Editing the target file directly will be overwritten on the next `chezmoi apply`.

To check whether a file is managed: `chezmoi managed | grep <path>`. If it's listed, find the corresponding source file in this repo (reverse the naming conventions below) and edit that instead.

## Key Commands

```bash
chezmoi diff                              # preview what would change before applying
chezmoi -w /path/to/worktree diff         # diff against a specific worktree
chezmoi apply                             # apply all managed files to $HOME
chezmoi apply ~/.zshrc                    # apply a single file
chezmoi execute-template < dot_zshrc.tmpl # render a template to stdout
chezmoi git -- <args>                     # run git in the source directory
```

After editing template files, run `chezmoi diff` to verify the rendered output before `chezmoi apply`.

The shell functions `cmet` and `cmetf` (defined in `.chezmoitemplates/functions.tmpl`) are short aliases for `chezmoi execute-template` and its formatted variant.

## File Naming Conventions

chezmoi maps source filenames to their destinations via prefixes:

| Prefix | Meaning |
|---|---|
| `dot_` | Prepend `.` (e.g. `dot_zshrc` → `~/.zshrc`) |
| `private_` | Set permissions to 600/700 |
| `executable_` | Set permissions to 755 |
| `create_` | Create the file only if it doesn't exist |
| `.tmpl` suffix | Render as Go template before writing |
| `symlink_` | Create as a symlink |

Prefixes compose: `private_dot_config/` → `~/.config/` with 700 permissions.

## Template Architecture

Templates use Go's `text/template` with chezmoi's extra functions (`lookPath`, `output`, `stat`, `dig`, `lastpass`, etc.).

**Template data variables** (from `.chezmoi.toml.tmpl`):
- `.email`, `.fullname` — prompted on first init
- `.chezmoi.os` — `"darwin"` or `"linux"`
- `.chezmoi.homeDir` — user home directory
- `.chezmoi.sourceDir` — path to this source repo

**Shared partials** in `.chezmoitemplates/`:
- `aliases.tmpl` — shell aliases, OS- and tool-conditional
- `functions.tmpl` — shell functions, tool-conditional

Both are included in `dot_zshrc.tmpl` via `{{ template "aliases.tmpl" . }}`.

**Conditional inclusion pattern** used throughout:
```
{{ if lookPath "kubectl" -}}
... kubectl-specific config ...
{{- else -}}
# kubectl aliases omitted
{{- end }}
```

This means the rendered shell files adapt to whatever tools are installed at apply time.

## Key Files

- `.chezmoi.toml.tmpl` — chezmoi config: prompts for user data, sets `data.*` variables, registers the post-apply hook
- `.chezmoiexternal.toml` — external files fetched from URLs (delta themes, rofi themes, zsh plugins)
- `.chezmoiignore` — files excluded from management; OS-conditional (Linux-only files are excluded on macOS)
- `helpers/` — shell scripts executed at template render time via `{{ output "helpers/..." }}`; not deployed to `$HOME`
- `private_dot_local/bin/executable___chezmoi_post_apply.tmpl` — post-apply hook that regenerates zsh completions for installed tools

## OS Handling

Many template blocks are gated on `{{ if (eq .chezmoi.os "darwin") }}` / `{{ if (eq .chezmoi.os "linux") }}`. The `.chezmoiignore` file also excludes Linux-specific configs (i3, dunst, rofi, systemd) on macOS.

## Secrets

Secrets are pulled from LastPass at init time via the `lastpass`/`lastpassRaw` template functions (only when `lpass` is in PATH). Affected data: `feed.reddit_url`, `feed.reddit_username`, `openweathermap.api_key`, `yubico.favorites`. If `lpass` is absent, these default to empty strings.

## Neovim Config

See `private_dot_config/nvim/CLAUDE.md` for full Neovim documentation (plugins, LSP, linters, keybindings, version management).
