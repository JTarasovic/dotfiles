return {
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                dockerfile = { "hadolint" },
                elixir = { "credo" },
                yaml = { "yamllint", },
                ["yaml.gha"] = { "yamllint", "actionlint", },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end
    },
    {
        "yasuhiroki/github-actions-yaml.vim",
        lazy = false,
    },
}
