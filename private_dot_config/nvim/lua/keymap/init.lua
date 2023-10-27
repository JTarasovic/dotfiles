local wk = require("which-key")
local set_keymap = vim.keymap.set

-- KEYMAPS
set_keymap("", "Q", "gq", {})
set_keymap("i", "<C-U>", "<C-G>u<C-U>", { remap = false })
set_keymap("i", "jj", "<esc>l", { remap = false })

wk.register({
    ["<leader>"] = {
        ["/"] = { "<cmd>lua vim.fn.setreg('/', '')<cr>", "Clear last search" },
        j = { "<cmd> bnext<cr>", "Next buffer" },
        k = { "<cmd> bprevious<cr>", "Previous buffer" },
        f = { name = "+files", },
        g = { name = "+grep", },
        n = { name = "+noice", },
        q = { "<cmd>bdelete<cr>", "Delete buffer" },
        w = {
            name = "+workspace",
            a = { "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>", "Add folder" },
            r = { "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>", "Remove folder" },
            l = { "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", "List folders" },
        },
        x = { name = "+trouble" },
    },
})
