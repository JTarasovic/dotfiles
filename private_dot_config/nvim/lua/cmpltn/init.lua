local cmp = require("cmp")
local cmp_action = require("lsp-zero").cmp_action()
vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
cmp.setup({
    completion = {
        completeopt = "menu,menuone,noinsert",
    },
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },

    formatting = {
        format = require("lspkind").cmp_format({
            mode = "symbol_text",
        })
    },
    experimental = {
        ghost_text = {
            hl_group = "CmpGhostText",
        },
    },

    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    }),

    mapping = cmp.mapping.preset.insert({
        -- `Enter` key to confirm completion
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ["<S-CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

        -- Ctrl+Space to trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),

        -- Navigate between snippet placeholder
        ['<C-f>'] = cmp_action.luasnip_jump_forward(),
        ['<C-b>'] = cmp_action.luasnip_jump_backward(),

        -- Scroll up and down in the completion documentation
        ['<C-u>'] = cmp.mapping.scroll_docs(-4),
        ['<C-d>'] = cmp.mapping.scroll_docs(4),

        ["<C-e>"] = cmp.mapping.abort(),
    }),
})
