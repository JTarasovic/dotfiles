return {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
        { "L3MON4D3/LuaSnip", version = "v2.*", build = "make install_jsregexp" },
        "onsails/lspkind.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lsp-signature-help",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
    },

    opts = function()
        vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
        local cmp = require("cmp")

        return {
            completion = {
                completeopt = "menu,menuone,noinsert,fuzzy",
            },

            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },

            formatting = {
                format = require("lspkind").cmp_format({
                    mode = "symbol",
                    ellipsis_char = "",
                    show_labelDetails = true,
                    maxwidth = {
                        menu = function() return math.floor(0.5 * vim.o.columns) end,
                        abbr = function() return math.floor(0.5 * vim.o.columns) end,
                    },
                })
            },

            experimental = {
                ghost_text = {
                    hl_group = "CmpGhostText",
                },
            },

            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "luasnip" },
                { name = "path" },
            }, {
                { name = "buffer", keyword_length = 3, }
            }),

            mapping = cmp.mapping.preset.insert({
                -- `Enter` key to confirm completion
                -- ["<CR>"] = cmp.mapping({
                --     i = function(fallback)
                --         if cmp.visible() and cmp.get_active_entry() then
                --             cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
                --         else
                --             fallback()
                --         end
                --     end,
                --     s = cmp.mapping.confirm({ select = true }),
                --     c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                -- }),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),

                -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true, }),

                -- Ctrl+Space to trigger completion menu
                ['<C-Space>'] = cmp.mapping.complete(),

                -- Navigate between snippet placeholder
                -- ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                -- ['<C-b>'] = cmp_action.luasnip_jump_backward(),

                -- Scroll up and down in the completion documentation
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),

                ["<C-e>"] = cmp.mapping.abort(),
            }),
        }
    end,
}
