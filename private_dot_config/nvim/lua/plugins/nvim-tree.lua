return {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    dependencies = {
        {"nvim-tree/nvim-web-devicons", version = false },
        "antosha417/nvim-lsp-file-operations",
        "echasnovski/mini.base16",
    },
    config = function()
        require("nvim-tree").setup {}
    end,
}
