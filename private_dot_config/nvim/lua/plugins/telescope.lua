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
            local e = require("telescope").extensions
            local utils = require("telescope.utils")
            local lsputils = require("lspconfig").util
            local wrap = function(fn, opts)
                return function()
                    if type(opts) == "function" then
                        opts = opts()
                    end
                    return fn(opts)
                end
            end

            local get_root_dir = function()
                lsputils.root_pattern(".git")(utils.buffer_dir())
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
                    wrap(t.buffers, {}),
                    mode = "n",
                    desc = "Telescope buffers (all)",
                },
                {
                    "<leader><",
                    wrap(t.buffers, { only_cwd = true, }),
                    mode = "n",
                    desc = "Telescope buffers (cwd)",
                },
                {
                    "<leader>fb",
                    wrap(e.file_browser.file_browser, {}),
                    mode = "n",
                    desc = "Telescope file_browser",
                },
                {
                    -- This will restrict the list of files to only those in the current dir
                    -- Generally, not very helpful unless you want to open a sibling
                    "<leader>fF",
                    wrap(t.find_files, function() return { cwd = utils.buffer_dir, hidden = true, } end),
                    mode = "n",
                    desc = "Telescope find_files (relative)",
                },
                {
                    "<leader>ff",
                    wrap(t.find_files, { hidden = true, }),
                    mode = "n",
                    desc = "Telescope find_files",
                },
                {
                    -- lists recently edited files in the current project / working dir
                    "<leader>fr",
                    wrap(t.oldfiles, function() return { cwd = get_root_dir() } end),
                    mode = "n",
                    desc = "Telescope oldfiles (relative)",
                },
                {
                    -- lists recently edited files regardless of location
                    "<leader>fR",
                    wrap(t.oldfiles, {}),
                    mode = "n",
                    desc = "Telescope oldfiles",
                },
                {
                    "<leader>fg",
                    wrap(e.live_grep_args.live_grep_args, {}),
                    mode = "n",
                    desc = "Telescope live_grep_args",
                },
                {
                    "<leader>gb",
                    wrap(t.current_buffer_fuzzy_find, {}),
                    mode = "n",
                    desc = "Telescope fuzzy find current buffer",
                },
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
                prompt_prefix = "❯ ",
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
