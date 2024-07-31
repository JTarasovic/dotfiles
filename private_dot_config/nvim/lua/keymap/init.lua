local wk = require("which-key")
local set_keymap = vim.keymap.set

-- KEYMAPS
set_keymap("", "Q", "gq", {})
set_keymap("i", "<C-U>", "<C-G>u<C-U>", { remap = false })
set_keymap("i", "jj", "<esc>l", { remap = false })

wk.add({
    { "<leader>/",  "<cmd>lua vim.fn.setreg('/', '')<cr>",                                   desc = "Clear last search" },
    { "<leader>f",  group = "files" },
    { "<leader>g",  group = "grep" },
    { "<leader>j",  "<cmd>bnext<cr>",                                                        desc = "Next buffer" },
    { "<leader>k",  "<cmd>bprevious<cr>",                                                    desc = "Previous buffer" },
    { "<leader>n",  group = "noice" },
    { "<leader>q",  "<cmd>bdelete<cr>",                                                      desc = "Delete buffer" },
    { "<leader>w",  group = "workspace" },
    { "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>",                       desc = "Add folder" },
    { "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>", desc = "List folders" },
    { "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>",                    desc = "Remove folder" },
    { "<leader>x",  group = "trouble" },
})
