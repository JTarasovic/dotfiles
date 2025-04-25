return {
    { "chrisbra/Colorizer", },
    {
        "gbprod/nord.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require('nord').setup()
            vim.cmd.colorscheme("nord")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", },
        opts = { options = { theme = "nord" }, },
    },
    { "nvim-tree/nvim-web-devicons", lazy = true },
}
