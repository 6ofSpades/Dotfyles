-- Config at:
-- https://github.com/folke/tokyonight.nvim/blob/5da1b76e64daf4c5d410f06bcb6b9cb640da7dfd/extras/lua/tokyonight_night.lua

return {
	"folke/tokyonight.nvim",
	enabled = true,
	priority = 1000,
	config = function()
		local theme = dofile(vim.fn.expand("~/.config/theme/generated/theme.lua"))

		require("tokyonight").setup({
			style = "night",
			on_colors = function(colors)
				colors.fg = theme.colors.fg
				colors.bg = theme.colors.bg

				colors.bg_dark = theme.colors.bg
				colors.bg_float = theme.colors.bg
				colors.bg_sidebar = theme.colors.bg

				colors.border = theme.ui.accent
				colors.border_highlight = theme.ui.accent

				colors.comment = theme.colors.black_bright

				colors.bg_visual = theme.ui.selection_bg

				colors.terminal = {
					black = theme.colors.black,
					black_bright = theme.colors.black_bright,
					blue = theme.colors.blue,
					blue_bright = theme.colors.blue_bright,
					cyan = theme.colors.cyan,
					cyan_bright = theme.colors.cyan_bright,
					green = theme.colors.green,
					green_bright = theme.colors.green_bright,
					magenta = theme.colors.magenta,
					magenta_bright = theme.colors.magenta_bright,
					red = theme.colors.red,
					red_bright = theme.colors.red_bright,
					white = theme.colors.white,
					white_bright = theme.colors.white_bright,
					yellow = theme.colors.yellow,
					yellow_bright = theme.colors.yellow_bright,
				}

				colors.black = theme.colors.bg
				colors.cyan = theme.colors.cyan
				colors.purple = theme.colors.magenta2
				colors.green = theme.colors.green
				colors.blue = theme.colors.blue
				colors.blue0 = theme.colors.magenta3
				colors.orange = theme.colors.red
			end,

			on_highlights = function(highlights)
				highlights.CursorLine = {
					bg = theme.ui.cursor_line,
					bold = true,
				}
				highlights.CursorLineNr = {
					fg = theme.ui.cursor_line_number,
				}
				highlights.LineNrAbove = {
					fg = theme.ui.line_number,
				}
				highlights.LineNrBelow = {
					fg = theme.ui.line_number,
				}
				highlights.LineNr = {
					fg = theme.ui.line_number,
				}

				-- barbar.nvim
				-- https://github.com/romgrk/barbar.nvim#highlighting
				-- current buffer
				highlights.BufferCurrent = {
					fg = theme.colors.white,
					bg = theme.colors.bg,
					bold = true,
					italic = true,
				}
				highlights.BufferCurrentSign = {
					fg = theme.ui.accent,
					bg = theme.ui.accent,
				}
				-- visible buffer
				highlights.BufferVisible = {
					fg = theme.colors.fg,
					bg = theme.colors.bg,
				}
				-- tabs
				highlights.BufferTabpagesSep = {
					bg = theme.ui.accent,
					fg = theme.colors.white,
				}
				highlights.BufferTabpages = {
					bg = theme.ui.accent,
				}
				-- buffer bar background
				highlights.BufferTabpageFill = {
					bg = theme.ui.cursor_line,
				}
				-- buffer picker
				highlights.BufferVisibleTarget = {
					fg = theme.colors.red,
				}
				highlights.BufferCurrentTarget = {
					fg = theme.colors.red,
				}
				highlights.BufferInactiveTarget = {
					fg = theme.colors.red,
				}

				-- marks.nvim
				highlights.MarkSignHL = {
					fg = theme.colors.red,
				}

				-- hop.nvim
				highlights.HopNextKey = {
					fg = theme.colors.red,
					bg = "#000001",
				}
				highlights.HopNextKey1 = {
					fg = theme.colors.magenta,
					bg = "#000001",
				}
				highlights.HopNextKey2 = {
					fg = theme.colors.blue,
					bg = "#000001",
				}
				highlights.HopUnmatched = {
					fg = theme.colors.black_bright, -- Fades out normal text
					bg = theme.colors.bg,
				}
			end,
		})

		vim.cmd("colorscheme tokyonight")

		vim.opt.termguicolors = true
		vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark
	end,
}
