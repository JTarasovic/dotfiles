return {
    {
        "mfussenegger/nvim-lint",
        config = function()
            require("lint").linters_by_ft = {
                dockerfile = { "hadolint" },
                elixir = { "credo" },
                javascript = { "eslint_d" },
                typescript = { "eslint_d" },
                yaml = { "yamllint", "actionlint", },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost" }, {
                callback = function()
                    require("lint").try_lint()
                end,
            })
        end

    }
}
