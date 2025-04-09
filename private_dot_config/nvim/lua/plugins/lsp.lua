return {
    "neovim/nvim-lspconfig",
    lazy = false,
    version = false,
    config = function()
        local lspconfig = require("lspconfig")
        local runtime_path = vim.split(package.path, ';')
        table.insert(runtime_path, 'lua/?.lua')
        table.insert(runtime_path, 'lua/?/init.lua')

        local util = lspconfig.util

        local servers = {
            bashls = {},
            denols = {
                root_dir = util.root_pattern("deno.json", "deno.jsonc", "package.json"),
                single_file_support = false,
            },
            elixirls = { cmd = { io.popen("which elixir-ls"):read() }, },
            golangci_lint_ls = {},
            gopls = {},
            lua_ls = {
                settings = {
                    Lua = {
                        -- Disable telemetry
                        telemetry = { enable = false },
                        runtime = {
                            -- Tell the language server which version of Lua you're using
                            -- (most likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            path = runtime_path,
                        },
                        diagnostics = {
                            -- Get the language server to recognize the `vim` global
                            globals = { 'vim' }
                        },
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                -- Make the server aware of Neovim runtime files
                                vim.env.VIMRUNTIME,
                                '${3rd}/luv/library'
                            }
                        }
                    }
                }
            },
            nixd = {},
            rust_analyzer = {},
            -- tailwindcss = {},
            terraformls = {},
            yamlls = {
                settings = {
                    schemas = {
                        ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                    },
                },
            },
            -- tsserver = {
            --     root_dir = lspconfig.util.root_pattern("package.json"),
            --     single_file_support = false,
            -- },
        }

        for lsp, overrides in pairs(servers) do
            local use = vim.tbl_deep_extend("force", overrides, { on_attach = require('lsp-format').on_attach })
            lspconfig[lsp].setup(use)
        end
    end,
    dependencies = {
        "lukas-reineke/lsp-format.nvim",
    },
}
