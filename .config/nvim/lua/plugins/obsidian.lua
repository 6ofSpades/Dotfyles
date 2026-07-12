return {
	"obsidian-nvim/obsidian.nvim",
	event = "VeryLazy",
	version = "*",

	opts = {
		legacy_commands = false,

		workspaces = {
			{
				name = "personal",
				path = "~/Documents/Obsidian-Vaults/vault",
			},
		},

		-- use note title for filename instead of random zettel id
		note_id_func = function(title)
			return title
		end,

		-- directory where notes should be created by default
		notes_subdir = "Notes",

		-- templates folder
		templates = {
			folder = "Templates",
			date_format = "%Y-%m-%d-%a",
			time_format = "%H:%M",
		},

		-- daily notes folder
		daily_notes = {
			enabled = true,
			folder = "Daily",
			date_format = "YYYY-MM-DD",
			default_tags = { "journaling", "daily" },
			template = "Daily Journaling.md",
		},

		-- in which folder attachments are stored
		-- if this is set wrong you also won't be able to open attachments
		attachments = {
			folder = "./attachments",
			-- 1. for vault root, set it to `/`.
			-- 2. for fixed folder, set it to `/folder-name`.
			-- 3. for same folder as current file, set it to `./`
			-- 4. for sub folder in current folder, set it to `./folder-name`
		},

		ui = {
			enable = false,
		},
	},

	config = function(_, opts)
		require("obsidian").setup(opts)

		vim.api.nvim_create_autocmd("User", {
			pattern = "ObsidianNoteEnter",
			callback = function(ev)
				-- linebreak when inside notes
				vim.opt_local.wrap = true
				vim.opt_local.linebreak = true
				vim.opt_local.breakindent = true

				-- folding
				vim.opt_local.foldmethod = "expr"
				vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				vim.opt_local.foldlevel = 99

				-- better navigation with linebreaks
				vim.keymap.set("n", "j", "gj", { buffer = ev.buf })
				vim.keymap.set("n", "k", "gk", { buffer = ev.buf })
				vim.keymap.set("n", "0", "g0", { buffer = ev.buf })
				vim.keymap.set("n", "$", "g$", { buffer = ev.buf })

				vim.keymap.set("n", "<leader>oc", function()
					local obsidian = require("obsidian")
					local workspace = obsidian.get_client().current_workspace

					if not workspace or not workspace.path then
						print("No Obsidian workspace active")
						return
					end

					local path = vim.fn.fnameescape(tostring(workspace.path))

					vim.cmd("lcd " .. path)

					print("Workspace cwd: " .. path)
				end, { desc = "Change cwd to Obsidian workspace" })
			end,
		})
	end,

	keys = {
		{ "<leader>of", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian quick switch notes" },
		{ "<leader>os", "<cmd>Obsidian search<CR>", desc = "Obsidian search with ripgrep" },
		{ "<leader>oh", "<cmd>Obsidian help<CR>", desc = "Obsidian help" },
		{ "<leader>oo", "<cmd>Obsidian open<CR>", desc = "Open current note in Obsidian" },
		{ "<leader>or", "<cmd>Obsidian rename<CR>", desc = "Rename current Obsidian note or link under cursor" },
		{ "<leader>od", "<cmd>Obsidian dailies<CR>", desc = "Open Obsidian daily notes picker" },
		{ "<leader>otp", "<cmd>Obsidian templates<CR>", desc = "Insert template into current note" },
		{ "<leader>ott", "<cmd>Obsidian tags<CR>", desc = "Get a picker list of Obsidian tags" },
		{ "<leader>on", "<cmd>Obsidian new<CR>", desc = "Create new note in Obsidian workspace" },
		{ "<leader>ow", "<cmd>Obsidian workspace<CR>", desc = "Select Obsidian workspace" },
		{ "<leader>ol", "<cmd>Obsidian links<CR>", desc = "List Obsidian links in current note" },
		{
			"<leader>op",
			"<cmd>Obsidian paste_img<CR>",
			desc = "Paste image from the clipboard in current note at cursor position",
		},
	},
}
