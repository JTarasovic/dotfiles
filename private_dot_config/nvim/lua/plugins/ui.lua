return {
    "chrisbra/Colorizer",
    {
        "nordtheme/vim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme nord]])
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", },
        opts = { options = { theme = "nord" }, },
    },
    { "nvim-tree/nvim-web-devicons", lazy = true },
}
