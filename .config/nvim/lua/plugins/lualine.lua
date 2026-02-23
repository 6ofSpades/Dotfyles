-- better looking status bar
return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		local colors = {
			blue = "#1a75cf",
			green = "#00bfa7",
			violet = "#8500bc",
			yellow = "#e0af68",
			-- red = "#FF4A4A",
			red = "#de646e",
			fg = "#ffffff",
			dark_fg = "#000001",
			bg = "#000000",
		}

		local my_lualine_theme = {
			normal = {
				a = { bg = colors.blue, fg = colors.dark_fg, gui = "italic,bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
				y = { fg = colors.blue, gui = "italic,bold" },
			},
			insert = {
				a = { bg = colors.green, fg = colors.dark_fg, gui = "italic,bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
				y = { fg = colors.green, gui = "italic,bold" },
			},
			visual = {
				a = { bg = colors.violet, fg = colors.dark_fg, gui = "italic,bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
				y = { fg = colors.violet, gui = "italic,bold" },
			},
			command = {
				a = { bg = colors.yellow, fg = colors.dark_fg, gui = "italic,bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
				y = { fg = colors.yellow, gui = "italic,bold" },
			},
			replace = {
				a = { bg = colors.red, fg = colors.dark_fg, gui = "italic,bold" },
				b = { bg = colors.bg, fg = colors.fg },
				c = { bg = colors.bg, fg = colors.fg },
				y = { fg = colors.red, gui = "italic,bold" },
			},
			inactive = {
				a = { bg = colors.inactive_bg, fg = colors.inactive_fg },
				b = { bg = colors.inactive_bg, fg = colors.inactive_fg },
				c = { bg = colors.inactive_bg, fg = colors.inactive_fg },
			},
		}

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				theme = my_lualine_theme,
				-- component_separators = { left = '', right = ''},
				-- section_separators = { left = '', right = ''},
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
						color = { fg = "#ff9e64" },
					},
					{ "encoding" },
					{ "filetype" },
				},
				lualine_y = {
					{
						require("noice").api.statusline.mode.get,
						cond = require("noice").api.statusline.mode.has,
						color = { bg = "#313131", fg = "#ff00ff" },
					},
					{ "progress", color = { bg = "#313131" } },
				},
			},
		})
	end,
}
