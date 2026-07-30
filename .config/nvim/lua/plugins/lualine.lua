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
				a = { bg = theme.colors.blue, fg = theme.colors.bg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.colors.blue, gui = "italic,bold" },
			},
			insert = {
				a = { bg = theme.colors.green, fg = theme.colors.bg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.colors.green, gui = "italic,bold" },
			},
			visual = {
				a = { bg = theme.colors.magenta, fg = theme.colors.bg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.colors.magenta, gui = "italic,bold" },
			},
			command = {
				a = { bg = theme.colors.yellow, fg = theme.colors.bg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.colors.yellow, gui = "italic,bold" },
			},
			replace = {
				a = { bg = theme.colors.red, fg = theme.colors.bg, gui = "italic,bold" },
				b = { bg = theme.colors.bg, fg = theme.colors.fg },
				c = { bg = theme.colors.bg, fg = theme.colors.fg },
				y = { fg = theme.colors.red, gui = "italic,bold" },
			},
			inactive = {
				a = { bg = theme.colors.gray1, fg = theme.colors.black_bright },
				b = { bg = theme.colors.gray1, fg = theme.colors.black_bright },
				c = { bg = theme.colors.gray1, fg = theme.colors.black_bright },
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
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = theme.colors.red },
					},
					{ "encoding" },
					{ "filetype" },
				},
				lualine_y = {
					{ "progress", color = { bg = theme.colors.gray1 } },
				},
			},
		})
	end,
}
