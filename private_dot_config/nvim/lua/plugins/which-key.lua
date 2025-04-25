return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
    end,
    dependencies = {
        { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    opts = function()
        local wk = require("which-key")
        local set_keymap = vim.keymap.set

        -- KEYMAPS
        set_keymap("", "Q", "gq", {})
        set_keymap("i", "<C-U>", "<C-G>u<C-U>", { remap = false })
        set_keymap("i", "jj", "<esc>l", { remap = false })

        wk.add({
            -- TODO: fix up these icons and colors.
            { "<leader>g", group = "grep", icon = { icon = "󰑑", hl = "WhichKeyIconBlue" } },
            { "<leader>x", group = "trouble", icon = { icon = "󰒺", hl = "WhichKeyIconBlue" } },
            { "<leader>w", group = "workspace", icon = { icon = "", hl = "WhichKeyIconBlue" } },
            { "<leader>f", group = "files", },
            { "<leader>n", group = "noice", },
        })

        return {}
    end,
    keys = {
        { "<leader>/",  "<cmd>lua vim.fn.setreg('/', '')<cr>",                                   desc = "Clear last search" },
        { "<leader>j",  "<cmd>bnext<cr>",                                                        desc = "Next buffer" },
        { "<leader>k",  "<cmd>bprevious<cr>",                                                    desc = "Previous buffer" },
        { "<leader>q",  "<cmd>bdelete<cr>",                                                      desc = "Delete buffer" },
        { "<leader>Q",  "<cmd>bdelete!<cr>",                                                     desc = "Delete buffer (force)" },
        { "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>",                       desc = "Add folder" },
        { "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", desc = "List folders" },
        { "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>",                    desc = "Remove folder" },
        { "grd",        "<cmd>lua vim.lsp.buf.definition()<cr>",                                 desc = "Go to definition" },
        { "gd",         "<cmd>lua vim.lsp.buf.definition()<cr>",                                 desc = "Go to definition" },
    },
}
