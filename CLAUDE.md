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

`private_dot_config/nvim/` uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Entry point is `init.lua` (bootstraps lazy, loads `lua/settings/` then `lua/plugins/`).

### Plugin file map

| File | Responsibility |
|---|---|
| `lua/plugins/lsp.lua` | nvim-lspconfig — all LSP server configs |
| `lua/plugins/completion.lua` | nvim-cmp — completion engine (LSP, snippets, buffer, path) |
| `lua/plugins/lint.lua` | nvim-lint — linter-per-filetype config |
| `lua/plugins/treesitter.lua` | Treesitter parsers, highlighting, indentation |
| `lua/plugins/telescope.lua` | Telescope fuzzy finder + file browser extension |
| `lua/plugins/trouble.lua` | Trouble diagnostics panel |
| `lua/plugins/noice.lua` | Noice UI (cmdline, messages, popupmenu) |
| `lua/plugins/nvim-tree.lua` | File explorer sidebar |
| `lua/plugins/comments.lua` | Comment.nvim + Todo-comments |
| `lua/plugins/which-key.lua` | Which-key keymap discovery |
| `lua/plugins/ui.lua` | Nord colorscheme, lualine statusline, colorizer, devicons |
| `lua/plugins/util.lua` | Plenary (dep), nvim-luadev (Lua REPL) |
| `lua/settings/init.lua` | All vim.opt options and core keymaps |

### Adding LSP servers

LSP servers must be **installed manually** (via Homebrew, system packages, or language-specific tooling). There is no Mason or auto-installer.

In `lua/plugins/lsp.lua`, add the server name to the `servers` table. Servers with no custom config get `{}`. Servers needing custom settings get a config table. The file iterates the table and calls `vim.lsp.enable(lsp)` + `vim.lsp.config(lsp, overrides)` (Neovim 0.11+ native LSP API — no nvim-lspconfig setup callbacks).

`lsp-format.nvim` is wired in as a global `on_attach` to handle format-on-save; servers that don't support formatting set `on_attach = {}` to opt out (e.g. `golangci_lint_ls`).

Currently configured: `bashls`, `denols`, `docker` (docker-language-server), `elixirls`, `golangci_lint_ls`, `gopls`, `lua_ls`, `rust_analyzer`, `taplo`, `terraformls`, `yamlls`.

### Adding linters

In `lua/plugins/lint.lua`, add the linter to the `linters_by_ft` table (filetype → linter name). nvim-lint runs on `BufWritePost` and `BufReadPost`.

Currently configured: `hadolint` (Dockerfile), `credo` (Elixir), `yamllint` (YAML), `actionlint` (GitHub Actions), `systemdlint` (Systemd).

### Keybinding conventions

- Leader: `<space>`, LocalLeader: `\`
- All keymaps are registered with which-key groups:
  - `<leader>f` — file/find operations (Telescope)
  - `<leader>g` — grep/git operations (Telescope)
  - `<leader>x` — diagnostics (Trouble)
  - `<leader>n` — noice messages
  - `<leader>w` — LSP workspace
  - `<leader>j/k` — next/previous buffer; `<leader>q/Q` — delete buffer
- Insert mode: `jj` → Escape
- `Q` → format with `gq`

### Lazy loading patterns

Most plugins use event-based loading. Common events:
- `VeryLazy` — deferred startup plugins
- `InsertEnter` — completion
- `BufReadPost` / `BufWritePost` — lint, treesitter
- `cmd` — plugins that only activate when a command is run

### Plugin version management

The lockfile is stored as `private_dot_config/nvim/.lazy-lock.json` (dot-prefixed so chezmoi
ignores it as a target). `private_dot_config/nvim/symlink_lazy-lock.json.tmpl` tells chezmoi
to create `~/.config/nvim/lazy-lock.json` as a symlink pointing into the source dir. lazy.nvim
writes through the symlink directly, so changes land in the repo automatically.

`lazy-lock.json` pins exact commit SHAs for all plugins and is the source of truth for what's
installed. The global `defaults = { version = "*" }` in `init.lua` means plugins without an
explicit `version` field use the latest stable tag — the lockfile then freezes that to a
specific commit.

**To upgrade plugins:**
1. Open neovim → `:Lazy update`
2. Review with `:Lazy log`
3. `git -C ~/.local/share/chezmoi add private_dot_config/nvim/.lazy-lock.json`
4. Commit the updated lockfile

No `chezmoi add` needed — lazy.nvim writes the file directly into the source tree via the symlink.

**Intentional `version = false` exceptions** (floating HEAD — no releases):
- `nvim-treesitter/nvim-treesitter` — no releases, HEAD-only by design
- `nvim-lua/plenary.nvim` — no formal releases
- `nvim-tree/nvim-web-devicons` — conventional HEAD usage
- `neovim/nvim-lspconfig` — tracking HEAD given rapid Neovim 0.11+ API changes

All other plugins use `version = "*"` (latest stable tag) or an explicit version range (`L3MON4D3/LuaSnip` uses `"v2.*"`).

### `chezmoi` note

`symlink_autoload.tmpl` creates a symlink for the vim autoload directory. It is not a plugin file — do not edit it when modifying plugins.

`symlink_lazy-lock.json.tmpl` creates the `~/.config/nvim/lazy-lock.json` symlink (see Plugin version management above). It is not a plugin file — do not edit it when modifying plugins. The real lockfile is `.lazy-lock.json` in this same directory.
