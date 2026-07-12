return {
	"nvim-telescope/telescope.nvim",
	-- branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"isak102/telescope-git-file-history.nvim",
		"tpope/vim-fugitive",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local telescopeConfig = require("telescope.config")

		-- Clone the default Telescope configuration
		local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

		-- I want to search in hidden/dot files.
		table.insert(vimgrep_arguments, "--hidden")
		-- I don't want to search in the `.git` directory.
		table.insert(vimgrep_arguments, "--glob")
		table.insert(vimgrep_arguments, "!**/.git/*")

		telescope.setup({
			defaults = {
				vimgrep_arguments = vimgrep_arguments,
				path_display = { "smart" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous, -- move to prev result
						["<C-j>"] = actions.move_selection_next, -- move to next result
						["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
					},
				},
			},

			pickers = {
				find_files = {
					-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
					find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
				},
			},
		})

		telescope.load_extension("fzf")
		telescope.load_extension("git_file_history")

		-- spellcheck language picker
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local action_state = require("telescope.actions.state")

		local function change_spell_language()
			-- Define the options you want to appear in your picker
			local opts = {
				{ "English", "en" },
				{ "Spanish", "es" },
				{ "French", "fr" },
				{ "German", "de" },
				{ "Portuguese", "pt" },
				{ "Turn Spellcheck OFF", "off" },
			}

			pickers
				.new({}, {
					prompt_title = "Spellcheck Language",
					finder = finders.new_table({
						results = opts,
						entry_maker = function(entry)
							return {
								value = entry[2],
								display = entry[1],
								ordinal = entry[1],
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							actions.close(prompt_bufnr)
							local selection = action_state.get_selected_entry()

							if selection.value == "off" then
								vim.opt_local.spell = false
								print("Spellcheck disabled")
							else
								vim.opt_local.spell = true
								vim.opt_local.spelllang = selection.value
								print("Spellcheck set to: " .. selection.display)
							end
						end)
						return true
					end,
				})
				:find()
		end

		-- keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Fuzzy find files in cwd" })
		keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
		keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Fuzzy find open buffers" })
		keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>", { desc = "Find string in cwd" })
		keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Find string under cursor in cwd" })
		keymap.set(
			"n",
			"<leader>fg",
			"<cmd>Telescope git_file_history<cr>",
			{ desc = "Find and preview current file at previous commits" }
		)
		keymap.set("n", "<Leader>fl", change_spell_language, { desc = "Change spellcheck language" })
	end,
}
