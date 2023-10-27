return {
    {
        'numToStr/Comment.nvim',
        lazy = false,
        opts = {},
    },
    {
        "folke/todo-comments.nvim",
        config = true,
        dependencies = { "nvim-lua/plenary.nvim" },
        lazy = false,
        opts = {
            highlight = { pattern = [[.*<(KEYWORDS).*:]] },
        },
    }
}
