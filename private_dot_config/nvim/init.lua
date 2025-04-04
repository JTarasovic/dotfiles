require("settings")

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {})

-- TODO(jdt): move completion configuration into plugin config...
require("cmpltn")
require("keymap")

-- local ft = require('Comment.ft')
-- ft({ "cpp", }, { "//%s", "/*%s*/" })
-- ft({ "", }, { "//%s", "/*%s*/" })
