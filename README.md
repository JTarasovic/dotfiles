# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Quick Start

```bash
chezmoi init --apply https://github.com/<github-username>/dotfiles
```

## Dependencies

### macOS

```bash
brew install \
    chezmoi \
    git \
    lastpass-cli \
    neovim \
    starship \
    fzf \
    ripgrep \
    fd \
    bat \
    eza \
    git-delta \
    zsh-syntax-highlighting

brew tap homebrew/cask-fonts && brew install --cask font-jetbrains-mono-nerd-font

lpass login $EMAIL
chezmoi init $GITHUB_USERNAME --apply
```

### Linux

- `chezmoi`, `git`, `zsh`, `neovim`, `starship`, `fzf`, `ripgrep`, `fd`, `bat`
- `i3`, `i3status-rust`, `dunst`, `rofi`
- `udiskie`, `playerctl`, `pactl`, `light-locker`
- `libsecret` (provides `secret-tool`; Debian/Ubuntu package is `libsecret-tools`) — RDP credential caching
- `yubioath-desktop`
- JetBrains Mono Nerd Font

### Optional / enhances functionality

- `kubectl`, `istioctl`, `helm` — shell completions auto-generated if present
- `lpass` — LastPass CLI for secret injection at `chezmoi init` time

---

## Neovim Config

`~/.config/nvim/` — a modular Lua config built on [lazy.nvim](https://github.com/folke/lazy.nvim).

### Plugins

| Category | Plugin | Purpose |
|---|---|---|
| **LSP** | nvim-lspconfig + lsp-format.nvim | Language server management + format-on-save |
| **Completion** | nvim-cmp | Completion (LSP, snippets, path, buffer) |
| **Syntax** | nvim-treesitter | Highlighting, indentation, folding |
| **Linting** | nvim-lint | Per-filetype linters |
| **Find** | Telescope + file-browser | Fuzzy file/buffer/grep search |
| **Diagnostics** | Trouble | Diagnostics panel, references, quickfix |
| **Explorer** | nvim-tree | File tree sidebar |
| **UI** | Noice | Better cmdline, messages, popupmenu |
| **UI** | Lualine | Statusline (Nord theme) |
| **UI** | Nord colorscheme | Dark blue colorscheme |
| **Comments** | Comment.nvim + todo-comments | Commenting & TODO highlighting |
| **Keymaps** | which-key | Keymap discovery |

### Language Servers

All language servers must be installed manually (Homebrew, system packages, or language toolchain). Neovim's native LSP API (`vim.lsp.enable` / `vim.lsp.config`) is used directly — no Mason.

| Language | Server |
|---|---|
| Bash | `bash-language-server` |
| Deno / TypeScript | `deno` |
| Dockerfile / Compose | `docker-language-server` |
| Elixir | `elixir-ls` |
| Go | `gopls`, `golangci-lint-langserver` |
| Lua | `lua-language-server` |
| Rust | `rust-analyzer` |
| TOML | `taplo` |
| Terraform | `terraform-ls` |
| YAML | `yaml-language-server` |

### Linters

| Filetype | Linter |
|---|---|
| Dockerfile | `hadolint` |
| Elixir | `credo` |
| YAML | `yamllint` |
| GitHub Actions | `actionlint` |
| Systemd | `systemdlint` |

### Key Bindings

Leader: `<Space>` · LocalLeader: `\`

**Files & Search** (`<leader>f`)

| Key | Action |
|---|---|
| `<leader>ff` | Find files (all, including hidden) |
| `<leader>fF` | Find files (relative to current dir) |
| `<leader>fb` | File browser |
| `<leader>fr` | Recent files (project root) |
| `<leader>fR` | Recent files (all) |

**Grep** (`<leader>g`)

| Key | Action |
|---|---|
| `<leader>fg` | Live grep with args |
| `<leader>gb` | Fuzzy grep current buffer |

**Buffers**

| Key | Action |
|---|---|
| `<leader>,` | All buffers |
| `<leader><` | Buffers in current dir |
| `<leader>j` | Next buffer |
| `<leader>k` | Previous buffer |
| `<leader>q` | Delete buffer |
| `<leader>Q` | Force delete buffer |

**Diagnostics** (`<leader>x`)

| Key | Action |
|---|---|
| `<leader>xx` | Buffer diagnostics |
| `<leader>xX` | All diagnostics |
| `<leader>xs` | Symbols |
| `<leader>xl` | LSP references/definitions |
| `<leader>xL` | Location list |
| `<leader>xQ` | Quickfix list |

**LSP**

| Key | Action |
|---|---|
| `gd` / `grd` | Go to definition |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |

**Noice Messages** (`<leader>n`)

| Key | Action |
|---|---|
| `<leader>nl` | Last message |
| `<leader>nh` | Message history |
| `<leader>na` | All messages |
| `<leader>nd` | Dismiss all |

**Other**

| Key | Action |
|---|---|
| `<leader>/` | Clear search highlight |
| `jj` | Escape (insert mode) |
| `Q` | Format with gq |
| `<C-U>` | Undo + keep indent (insert mode) |

---

## Secrets

Secrets are injected from LastPass at `chezmoi init` time via `lpass`. If `lpass` is not in PATH, values default to empty strings. Affected: Reddit feed URL/username, OpenWeatherMap API key, YubiKey favorites.

## Template Rendering

```bash
chezmoi execute-template < dot_zshrc.tmpl   # render to stdout
chezmoi diff                                 # preview changes
chezmoi apply                                # apply all
```

Shell aliases `cmet` / `cmetf` (in `.chezmoitemplates/functions.tmpl`) are short forms of the above.
