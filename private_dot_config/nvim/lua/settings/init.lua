vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"


local o = vim.o
-- OPTIONS
o.termguicolors = true
-- by default tabs are 4 spaces
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
-- and expand them
o.expandtab = true
-- allow backspacing over everything in insert mode
o.backspace = "indent,eol,start"
o.encoding = "utf-8"
o.laststatus = 2
o.history = 50
-- show the cursor position all the time
o.ruler = true
-- display incomplete commands
o.showcmd = true
-- do incremental searching
o.incsearch = true
-- turn on highlighting during searches
o.hlsearch = true
-- show line numbers
o.number = true
o.background = "dark"
o.mouse = "a"
-- keep a backup file (restore to previous version)
o.backup = true
-- keep an undo file (undo changes after closing)
o.undofile = true
o.backupdir = vim.fn.expand("~/.local/share/nvim/backup/")
o.inccommand = "split"
-- use system clipboard always
vim.opt.clipboard:append { "unnamedplus" }
-- vim.opt.fillchars:append { 'stl:\\', 'stlnc:\\' }

-- HACK(jdt): just truncate lsp log every time we start otherwise it gets YUGE.
io.popen(string.format("truncate --size 0 %s", require("vim.lsp.log").get_filename()), "w")
