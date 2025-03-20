return {
    {
        "nvim-telescope/telescope.nvim",
        config = function(_, opts)
            local telescope = require("telescope")
            telescope.setup(opts)
            telescope.load_extension("file_browser")
            telescope.load_extension("fzf")
            telescope.load_extension("live_grep_args")
        end,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-live-grep-args.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim",   build = 'make' },
            { "nvim-telescope/telescope-file-browser.nvim", dependencies = { "nvim-tree/nvim-web-devicons", }, }
        },
        keys = function()
            local t = require("telescope.builtin")
            local utils = require("telescope.utils")
            local wrap = function(fn, opts)
                return function()
                    if type(opts) == "function" then
                        opts = opts()
                    end
                    return fn(opts)
                end
            end

            return {
                {
                    "<leader>:",
                    wrap(t.command_history, {}),
                    mode = "n",
                    desc = "Telescope command_history",
                },
                {
                    "<leader>,",
                    "<cmd>Telescope buffers show_all_buffers=true<cr>",
                    mode = "n",
                    desc = "Telescope buffers (all)",
                },
                {
                    "<leader>fb",
                    "<cmd>:lua require('telescope').extensions.file_browser.file_browser()<CR>",
                    mode = "n",
                    desc = "Telescope file_browser",
                },
                {
                    "<leader>fF",
                    wrap(t.find_files, function() return { cwd = utils.buffer_dir() } end),
                    mode = "n",
                    desc = "Telescope find_files (relative)",
                },
                {
                    "<leader>ff",
                    wrap(t.find_files, {}),
                    mode = "n",
                    desc = "Telescope find_files",
                },
                {
                    "<leader>fR",
                    wrap(t.oldfiles, function() return { cwd = utils.buffer_dir() } end),
                    mode = "n",
                    desc = "Telescope oldfiles (relative)",
                },
                {
                    "<leader>fr",
                    wrap(t.oldfiles, {}),
                    mode = "n",
                    desc = "Telescope oldfiles",
                },
                {
                    "<leader>fg",
                    -- need to late bind as the extension is loaded after this would be evaluated if fn
                    "<cmd>:lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
                    mode = "n",
                    desc = "Telescope live_grep_args",
                },
                {
                    "<leader>gb",
                    wrap(t.current_buffer_fuzzy_find, {}),
                    mode = "n",
                    desc = "Telescope fuzzy find current buffer",
                },

                -- {
                --     "<leader>,",
                --     "<cmd>Telescope buffers show_all_buffers=true<cr>",
                --     mode = "n",
                --     desc = "Telescope buffers (all)",
                -- },

            }
        end,
        opts = {
            extensions = {
                fzf = {
                    fuzzy = true,
                    override_generic_sorter = true,
                    override_file_sorter = true,
                }
            },
            defaults = {
                -- prompt_prefix = "󰱼 ",
                prompt_prefix = " ",
                selection_caret = " ",
                winblend = 15,
                layout_strategy = "vertical",
                layout_config = {
                    vertical = {
                        height = 0.99,
                        preview_height = 0.66,
                    }
                },
            },
        },

    },

}
