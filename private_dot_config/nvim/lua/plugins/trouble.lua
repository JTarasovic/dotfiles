return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = function()
        local t = require("trouble")
        -- TODO(jdt): DRY
        local wrap = function(fn, opts)
            return function()
                if type(opts) == "function" then
                    opts = opts()
                end
                return fn(opts)
            end
        end

        return {
            { "<leader>xx", wrap(t.toggle, {}),                     mode = "n", desc = "Trouble toggle", },
            { "<leader>xd", wrap(t.toggle, "document_diagnostics"), mode = "n", desc = "Trouble toggle (document diag)", },
            { "<leader>xq", wrap(t.toggle, "quickfix"),             mode = "n", desc = "Trouble toggle (quickfix)", },
            { "<leader>xl", wrap(t.toggle, "loclist"),              mode = "n", desc = "Trouble toggle (loclist)", },
            {
                "<leader>xw",
                wrap(t.toggle, "workspace_diagnostics"),
                mode = "n",
                desc =
                "Trouble toggle (workspace diag)",
            },

        }
    end,
}
