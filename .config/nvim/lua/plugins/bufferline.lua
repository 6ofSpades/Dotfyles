-- better looking tabs
-- bufferline-configuration
return {
	"akinsho/bufferline.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	version = "*",

	opts = {
		options = {
			-- mode = "tabs",
			separator_style = "slope", -- slant, slope, thick, thin
			indicator = { style = "none" }, -- icon, underline, none
			show_close_icon = false,
			show_buffer_close_icons = false,
			always_show_bufferline = true, -- whether or not to show bufferline if there's only one buffer open

			custom_filter = function(buf, _)
				-- Empty directory buffers appear after restoring a session and
				-- they should be ignored cause it's annoying.
				-- Without this you'll see an empty buffer on the line every time.
				local buf_name = vim.api.nvim_buf_get_name(buf)
				local state = vim.uv.fs_stat(buf_name)
				if state and state.type == "directory" then
					return false
				end

				return true
			end,
		},

		highlights = {
			fill = {
				bg = "#000000",
			},
			background = {
				bg = "#252525",
			},

			buffer_selected = {
				fg = "#ffffff",
				bg = "#56007b",
				bold = true,
				italic = true,
			},
			buffer_visible = {
				fg = "#ffffff",
				bg = "#56007b",
				bold = true,
				italic = true,
			},
			hint_visible = {
				bg = "#56007b",
			},
			info_visible = {
				bg = "#56007b",
			},
			indicator_visible = {
				bg = "#56007b",
			},

			separator_selected = {
				fg = "#252525",
				bg = "#56007b",
			},
			separator_visible = {
				fg = "#252525",
				bg = "#56007b",
			},
			separator = {
				fg = "#252525",
				bg = "#252525",
			},
			close_button = {
				bg = "#252525",
			},
			close_button_visible = {
				bg = "#252525",
			},
			duplicate_visible = {
				bg = "#252525",
				italic = true,
			},
			duplicate = {
				bg = "#252525",
				italic = true,
			},
			duplicate_selected = {
				bg = "#56007b",
				italic = true,
			},
			modified_selected = {
				bg = "#56007b",
			},
			modified = {
				bg = "#252525",
			},
			modified_visible = {
				bg = "#56007b",
			},

			pick_selected = {
				-- fg = '<colour-value-here>',
				bg = "#56007b",
				bold = true,
				italic = true,
			},
			pick_visible = {
				-- fg = '<colour-value-here>',
				bg = "#56007b",
				bold = true,
				italic = true,
			},
			pick = {
				-- fg = '<colour-value-here>',
				bg = "#252525",
				bold = true,
				italic = true,
			},

			tab = {
				-- fg = '<colour-value-here>',
				bg = "#252525",
			},
			tab_selected = {
				fg = "#ffffff",
				bg = "#2074ce",
			},
			tab_separator = {
				fg = "#000000",
				bg = "#252525",
			},
			tab_separator_selected = {
				fg = "#000000",
				bg = "#2074ce",
				-- sp = "<colour-value-here>",
				-- underline = "<colour-value-here>",
			},
		},
	},

	-- Keymaps
	vim.keymap.set("n", "<leader>bx", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" }),
	vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer to the left" }),
	vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer to the right" }),
}
