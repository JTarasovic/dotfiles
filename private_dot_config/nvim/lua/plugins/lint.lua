return {
    {
        "mfussenegger/nvim-lint",
        config = function()
            local lint = require("lint")

            lint.linters_by_ft = {
                dockerfile = { "hadolint" },
                elixir = { "credo" },
                yaml = { "yamllint", },
                ["yaml.gha"] = { "yamllint", "actionlint", },
                systemd = { "systemdlint" },
                -- terraform = { "tflint" },
            }

            lint.linters.actionlint.args = { '-format', '{{json .}}' }
            lint.linters.actionlint.stdin = false
            lint.linters.actionlint.append_fname = true

            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end
    },
    {
        "yasuhiroki/github-actions-yaml.vim",
        lazy = false,
    },
}
