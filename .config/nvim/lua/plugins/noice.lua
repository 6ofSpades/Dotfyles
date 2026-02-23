return {
	"folke/noice.nvim",
	event = "VeryLazy",
	opts = {
		-- add any options here
	},
	dependencies = {
		-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
		"MunifTanjim/nui.nvim",
		-- OPTIONAL:
		--   `nvim-notify` is only needed, if you want to use the notification view.
		--   If not available, we use `mini` as the fallback
		"rcarriga/nvim-notify",
	},
	config = function()
		local noice = require("noice")

		noice.setup({
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
			views = {
				cmdline_popup = {
					position = {
						row = 5,
						col = "50%",
					},
					size = {
						width = 60,
						height = "auto",
					},
				},
				popupmenu = {
					relative = "editor",
					position = {
						row = 8,
						col = "50%",
					},
					size = {
						width = 60,
						height = 10,
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
		})

		-- Overriding highlights
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { link = "NoiceCmdlinePopupBorderInput" })
		vim.api.nvim_set_hl(0, "NoicePopupmenuSelected", { link = "Visual" })
		-- vim.api.nvim_set_hl(0, "NoiceScrollbar", { link = "Visual" })
		-- vim.api.nvim_set_hl(0, "NoiceScrollbarThumb", { link = "Visual" })
	end,

	vim.keymap.set("n", "<leader>nn", function()
		require("noice").cmd("last")
	end, { desc = "Last notification in float window" }),

	vim.keymap.set("n", "<leader>nh", function()
		require("noice").cmd("history")
	end, { desc = "Notification in split window" }),

	vim.keymap.set("n", "<leader>nx", function()
		require("noice").cmd("dismiss")
	end, { desc = "Dismiss all notifications" }),

	vim.keymap.set("n", "<leader>nf", function()
		require("noice").cmd("telescope")
	end, { desc = "Notification search in Telescope" }),

	vim.keymap.set("n", "<leader>ns", function()
		require("noice").cmd("stats")
	end, { desc = "Notification show debugging stats" }),
}
