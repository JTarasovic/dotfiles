local function lua_on_init(client)
    if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
            return
        end
    end

    client.config.settings.Lua = vim.tbl_deep_extend('force', {
        runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
            checkThirdParty = false,
            library = {
                vim.env.VIMRUNTIME,
                vim.fn.expand("$VIMRUNTIME/lua/"),
                vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                "${3rd}/luv/library",
                "${3rd}/busted/library",
            }
        }
    }, client.config.settings.Lua)
end

-- desired LSPs and configs
local servers = {
    bashls = {},
    denols = {},
    -- experimenting with new docker "official" language server
    docker = {
        cmd = { 'docker-language-server', 'start', '--verbose', '--debug', '--stdio' },
        filetypes = { 'yaml.docker-compose', 'dockerfile' },
        root_markers = { 'Dockerfile', 'docker-compose.yaml', 'docker-compose.yml', 'compose.yaml', 'compose.yml', '.git' },
    },
    elixirls = {
        cmd = { io.popen("which elixir-ls"):read() },
    },
    golangci_lint_ls = {
        on_attach = {}, -- doesn't support formatting
    },
    gopls = {},
    -- harper_ls = {
    --     on_attach = {}, -- doesn't support formatting
    --     settings = { ["harper-ls"] = { userDictPath = "~/.config/harper-ls/dictionary.txt" }, },
    -- },
    lua_ls = {
        on_init = lua_on_init,
        settings = { Lua = { telemetry = { enable = false }, } }
    },
    -- nixd = {},
    rust_analyzer = {},
    -- tailwindcss = {},
    taplo = {},
    terraformls = {},
    yamlls = {
        settings = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
            },
        },
    },
}



return {
    "neovim/nvim-lspconfig",
    lazy = false,
    version = false,
    config = function()
        -- GENERIC CONFIG
        vim.lsp.config('*', {
            root_markers = { '.git' },
            on_attach = require('lsp-format').on_attach,
        })

        -- DIAGNOSTICS
        vim.diagnostic.config({
            -- virtual_lines = { current_line = true },
            virtual_lines = true,
            virtual_text = false,
            jump = {
                float = true,
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = '',
                    [vim.diagnostic.severity.WARN]  = '',
                    [vim.diagnostic.severity.HINT]  = '󰌵',
                    [vim.diagnostic.severity.INFO]  = '',
                },
            },
        })

        -- ENABLE & CONFIGURE
        for lsp, overrides in pairs(servers) do
            vim.lsp.enable(lsp)
            vim.lsp.config(lsp, overrides)
        end
    end,
    dependencies = {
        "lukas-reineke/lsp-format.nvim",
    },
}
