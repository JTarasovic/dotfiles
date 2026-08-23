-- nvim-treesitter `main` branch. This is a full rewrite of the `master` branch
-- with an incompatible API: there is no `nvim-treesitter.configs`, and no
-- `highlight` / `indent` / `ensure_installed` / `auto_install` /
-- `incremental_selection` options. The plugin now only installs parsers and
-- ships queries; enabling features is done per-buffer against Neovim's own
-- treesitter API. Requires Neovim 0.12+ and the `tree-sitter` CLI (0.26.1+).
--
-- `incremental_selection` had no equivalent on `main` and was dropped.

local ensure_installed = {
    "vim", "regex", "lua", "bash", "markdown", "markdown_inline",
}

return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    -- `main` explicitly does not support lazy-loading
    lazy = false,
    build = ":TSUpdate",
    config = function()
        local ts = require("nvim-treesitter")

        -- `setup` is not called: its only option is `install_dir`, and we want
        -- the default (`stdpath("data")/site`).
        ts.install(ensure_installed)

        local installed = {}
        for _, lang in ipairs(ts.get_installed("parsers")) do
            installed[lang] = true
        end

        -- `get_available` fires the `User TSUpdate` autocmd and sorts the full
        -- parser table, so only pay for it on the first cache miss.
        local available
        local function is_available(lang)
            if not available then
                available = {}
                for _, l in ipairs(ts.get_available()) do
                    available[l] = true
                end
            end
            return available[lang] == true
        end

        -- Replaces master's `highlight = { enable = true }`,
        -- `indent = { enable = true }`, and the global foldexpr.
        --
        -- Each feature is gated on its query actually existing for the
        -- language. Having a parser does not imply having every query: `vim`
        -- ships no `indents.scm`, `regex` ships only `highlights.scm`. The
        -- master branch's modules checked this; on `main` it is on us. Without
        -- the check, `indentexpr` clobbers a good built-in indent script with a
        -- treesitter one that has no rules and flattens the buffer.
        local function enable(buf, lang)
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            local function has(query)
                return vim.treesitter.query.get(lang, query) ~= nil
            end

            if not (has("highlights") and pcall(vim.treesitter.start, buf, lang)) then
                return
            end
            -- treesitter indentation is flagged experimental on `main`
            if has("indents") then
                vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
            if has("folds") and vim.api.nvim_get_current_buf() == buf then
                vim.wo[0][0].foldmethod = "expr"
                vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
            end
        end

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("treesitter_enable", { clear = true }),
            callback = function(args)
                if args.match == "" then
                    return
                end
                local lang = vim.treesitter.language.get_lang(args.match) or args.match

                if installed[lang] then
                    enable(args.buf, lang)
                elseif is_available(lang) then
                    -- replaces master's `auto_install = true`
                    installed[lang] = true
                    ts.install(lang):await(function(err)
                        if err then
                            installed[lang] = nil
                            return
                        end
                        vim.schedule(function()
                            enable(args.buf, lang)
                        end)
                    end)
                end
            end,
        })

        vim.o.foldenable = false
    end,
}
