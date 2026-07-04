# Neovim Config

`private_dot_config/nvim/` uses [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Entry point is `init.lua` (bootstraps lazy, loads `lua/settings/` then `lua/plugins/`).

## Plugin file map

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
| `lua/plugins/comments.lua` | Todo-comments (commenting itself uses Neovim's native `gc`/`gcc`; extra `gco`/`gcO`/`gcA` mappings are in `lua/settings/init.lua`) |
| `lua/plugins/which-key.lua` | Which-key keymap discovery |
| `lua/plugins/ui.lua` | Nord colorscheme, lualine statusline, colorizer, devicons |
| `lua/plugins/util.lua` | Plenary (dep), nvim-luadev (Lua REPL) |
| `lua/settings/init.lua` | All vim.opt options and core keymaps |

## Adding LSP servers

LSP servers must be **installed manually** (via Homebrew, system packages, or language-specific tooling). There is no Mason or auto-installer.

In `lua/plugins/lsp.lua`, add the server name to the `servers` table. Servers with no custom config get `{}`. Servers needing custom settings get a config table. The file iterates the table and calls `vim.lsp.enable(lsp)` + `vim.lsp.config(lsp, overrides)` (Neovim 0.11+ native LSP API — no nvim-lspconfig setup callbacks).

`lsp-format.nvim` is wired in as a global `on_attach` to handle format-on-save; servers that don't support formatting set `on_attach = {}` to opt out (e.g. `golangci_lint_ls`).

Currently configured: `bashls`, `denols`, `docker` (docker-language-server), `elixirls`, `golangci_lint_ls`, `gopls`, `lua_ls`, `rust_analyzer`, `taplo`, `terraformls`, `yamlls`.

## Adding linters

In `lua/plugins/lint.lua`, add the linter to the `linters_by_ft` table (filetype → linter name). nvim-lint runs on `BufWritePost` and `BufReadPost`.

Currently configured: `hadolint` (Dockerfile), `credo` (Elixir), `yamllint` (YAML), `actionlint` (GitHub Actions), `systemdlint` (Systemd).

## Keybinding conventions

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

## Lazy loading patterns

Most plugins use event-based loading. Common events:
- `VeryLazy` — deferred startup plugins
- `InsertEnter` — completion
- `BufReadPost` / `BufWritePost` — lint, treesitter
- `cmd` — plugins that only activate when a command is run

## Plugin version management

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

## `chezmoi` note

`symlink_autoload.tmpl` creates a symlink for the vim autoload directory. It is not a plugin file — do not edit it when modifying plugins.

`symlink_lazy-lock.json.tmpl` creates the `~/.config/nvim/lazy-lock.json` symlink (see Plugin version management above). It is not a plugin file — do not edit it when modifying plugins. The real lockfile is `.lazy-lock.json` in this same directory.
