-- better looking status bar
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local theme = dofile(vim.fn.expand("~/.config/theme/generated/theme.lua"))

		local my_lualine_theme = {
			normal = {
				a = { bg = theme.nvim.mode_normal_bg, fg = theme.nvim.mode_normal_fg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.nvim.mode_normal_bg, gui = "italic,bold" },
			},
			insert = {
				a = { bg = theme.nvim.mode_insert_bg, fg = theme.nvim.mode_insert_fg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.nvim.mode_insert_bg, gui = "italic,bold" },
			},
			visual = {
				a = { bg = theme.nvim.mode_visual_bg, fg = theme.nvim.mode_visual_fg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.nvim.mode_visual_bg, gui = "italic,bold" },
			},
			command = {
				a = { bg = theme.nvim.mode_command_bg, fg = theme.nvim.mode_command_fg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.nvim.mode_command_bg, gui = "italic,bold" },
			},
			replace = {
				a = { bg = theme.nvim.mode_replace_bg, fg = theme.nvim.mode_replace_fg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.nvim.mode_replace_bg, gui = "italic,bold" },
			},
			inactive = {
				a = { bg = theme.nvim.mode_inactive_bg, fg = theme.nvim.mode_inactive_fg },
				b = { bg = theme.nvim.mode_inactive_bg, fg = theme.nvim.mode_inactive_fg },
				c = { bg = theme.nvim.mode_inactive_bg, fg = theme.nvim.mode_inactive_fg },
			},
		}

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = my_lualine_theme,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_x = {
					{
						require("noice").api.status.mode.get,
						cond = require("noice").api.status.mode.has,
						color = { fg = theme.colors.red },
					},
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = theme.colors.red },
					},
					{ "encoding" },
					{ "filetype" },
				},
				lualine_y = {
					{ "progress", color = { bg = theme.nvim.mode_alt_bg } },
				},
			},
		})
	end,
}
