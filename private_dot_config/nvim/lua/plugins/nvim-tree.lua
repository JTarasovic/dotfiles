return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "antosha417/nvim-lsp-file-operations",
        "echasnovski/mini.base16",
    },
    config = function()
        require("nvim-tree").setup {}
    end,
}
