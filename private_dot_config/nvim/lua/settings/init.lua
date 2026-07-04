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

-- truncate lsp log every time we start otherwise it gets YUGE.
local _lsp_log = io.open(require("vim.lsp.log").get_filename(), "w")
if _lsp_log then _lsp_log:close() end

-- Insert a new commented line (using native gc's commenting, since Comment.nvim
-- doesn't provide these but its gco/gcO/gcA mappings were relied on).
local function comment_new_line(above)
    local cs = vim.bo.commentstring
    if cs == "" or not cs:find("%%s") then
        vim.api.nvim_echo({ { "commentstring is empty or invalid", "WarningMsg" } }, true, {})
        return
    end
    local left, right = cs:match("^(.-)%%s(.-)$")
    left, right = vim.trim(left), vim.trim(right)
    local indent = string.rep(" ", vim.fn.indent("."))
    local text = indent .. left .. (right ~= "" and (" " .. right) or "")
    local lnum = vim.fn.line(".")
    local target = above and (lnum - 1) or lnum
    vim.fn.append(target, text)
    local newline = target + 1
    vim.api.nvim_win_set_cursor(0, { newline, #indent + #left })
    if right ~= "" then
        vim.cmd("startinsert")
    else
        vim.cmd("startinsert!")
    end
end

local function comment_end_of_line()
    local cs = vim.bo.commentstring
    if cs == "" or not cs:find("%%s") then
        vim.api.nvim_echo({ { "commentstring is empty or invalid", "WarningMsg" } }, true, {})
        return
    end
    local left, right = cs:match("^(.-)%%s(.-)$")
    left, right = vim.trim(left), vim.trim(right)
    local lnum = vim.fn.line(".")
    local line = vim.fn.getline(lnum)
    local new_line = line .. " " .. left .. (right ~= "" and (" " .. right) or "")
    vim.fn.setline(lnum, new_line)
    vim.api.nvim_win_set_cursor(0, { lnum, #line + 1 + #left })
    if right ~= "" then
        vim.cmd("startinsert")
    else
        vim.cmd("startinsert!")
    end
end

vim.keymap.set("n", "gco", function() comment_new_line(false) end, { desc = "Comment new line below" })
vim.keymap.set("n", "gcO", function() comment_new_line(true) end, { desc = "Comment new line above" })
vim.keymap.set("n", "gcA", comment_end_of_line, { desc = "Comment at end of line" })
