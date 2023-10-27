return {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v3.x",
    lazy = true,
    -- config = false,
    config = function()
        local lsp_zero = require("lsp-zero")
        local lsp_config = require("lspconfig")

        lsp_zero.set_sign_icons({
            error = "",
            warn = "",
            hint = "",
            info = "",
        })

        lsp_zero.on_attach(function(client, bufnr)
            -- see :help lsp-zero-keybindings
            -- to learn the available actions
            lsp_zero.default_keymaps({ buffer = bufnr, preserve_mappings = false, })
            if client.supports_method('textDocument/formatting') then
                require('lsp-format').on_attach(client)
            end
        end)

        -- TODO(jdt): this is haute garbage. fix it.
        local els_path = io.popen("which elixir-ls"):read()

        local get_mix_under_git = function(fname)
            local git_root = lsp_config.util.find_git_ancestor(fname)
            local root = vim.fs.find({ 'mix.exs', }, { path = git_root, type = "file", })
            return vim.fs.dirname(root[1])
        end

        local servers = {
            bashls = {},
            denols = {
                root_dir = lsp_config.util.root_pattern("deno.json", "deno.jsonc"),
                single_file_support = false,
            },
            elixirls = {
                cmd = { els_path },
                root_dir = function(fname)
                    -- vim.notify(vim.inspect(els_path), vim.log.levels.INFO)
                    return get_mix_under_git(fname)
                end
            },
            lua_ls = lsp_zero.nvim_lua_ls(),
            nixd = {},
            terraformls = {},
            tsserver = {
                root_dir = lsp_config.util.root_pattern("package.json"),
                single_file_support = false,
            },
        }

        for lsp, overrides in pairs(servers) do
            lsp_zero.configure(lsp, overrides)
        end
    end,
    dependencies = {
        "lukas-reineke/lsp-format.nvim",
        {
            "neovim/nvim-lspconfig",
            dependencies = {
                "hrsh7th/cmp-nvim-lsp",
            }
        },
        -- autocompletion
        {
            "hrsh7th/nvim-cmp",
            version = false,
            event = "InsertEnter",
            dependencies = {
                "onsails/lspkind.nvim",
                "L3MON4D3/LuaSnip",
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-path",
                "saadparwaiz1/cmp_luasnip",
            },
        },
    },
}
