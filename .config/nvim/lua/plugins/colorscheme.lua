-- Config at:
-- https://github.com/folke/tokyonight.nvim/blob/5da1b76e64daf4c5d410f06bcb6b9cb640da7dfd/extras/lua/tokyonight_night.lua

return {
	"folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		local bg = "none"
		local accent = "#690085"
		local visual = "#690086"

		local purple = "#9A28e3"
		local violet = "#5F00f7"

		local fg = "#c0caf5"

		-- terminal colors
		local black = "#000000"
		local black_bright = "#616a94"
		local blue = "#1a75cf"
		local blue_bright = "#1a75cf"
		local cyan = "#00ffff"
		local cyan_bright = "#00ffff"
		local green = "#00bfa7"
		local green_bright = "#00bfa7"
		local magenta = "#8500bc"
		local magenta_bright = "#8500bc"
		local red = "#de646e"
		local red_bright = "#de646e"
		local white = "#dddddd"
		local white_bright = "#ffffff"
		local yellow = "#e0af68"
		local yellow_bright = "#e0af68"

		require("tokyonight").setup({
			style = "night",
			on_colors = function(colors)
				colors.fg = fg

				colors.bg = bg
				colors.bg_dark = bg
				colors.bg_float = bg
				colors.bg_sidebar = bg

				colors.border = accent
				colors.border_highlight = accent

				colors.black = bg
				colors.cyan = cyan
				colors.purple = purple
				colors.green = green
				colors.blue = blue
				colors.blue0 = violet
				-- colors.orange = "#0000ff"

				colors.comment = black_bright

				colors.bg_visual = visual

				colors.terminal = {
					black = black,
					black_bright = black_bright,
					blue = blue,
					blue_bright = blue_bright,
					cyan = cyan,
					cyan_bright = cyan_bright,
					green = green,
					green_bright = green_bright,
					magenta = magenta,
					magenta_bright = magenta_bright,
					red = red,
					red_bright = red_bright,
					white = white,
					white_bright = white_bright,
					yellow = yellow,
					yellow_bright = yellow_bright,
				}
			end,

			on_highlights = function(highlights)
				highlights.CursorLine = {
					bg = "#484848",
					bold = true,
				}
				highlights.CursorLineNr = {
					fg = cyan,
				}
				highlights.LineNrAbove = {
					fg = black_bright,
				}
				highlights.LineNrBelow = {
					fg = black_bright,
				}
				highlights.LineNr = {
					fg = white_bright,
				}
			end,
		})

		vim.cmd("colorscheme tokyonight")

		vim.opt.termguicolors = true
		vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark

		-- Manual overrides
		-- vim.api.nvim_set_hl(0, "Cursor", { bg = "#ff00ff" }) -- cause overriding the linenr is not working properly
	end,
}
