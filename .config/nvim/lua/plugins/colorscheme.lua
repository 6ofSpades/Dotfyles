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

				colors.border = theme.nvim.floatborders
				colors.border_highlight = theme.nvim.floatborders

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

				colors.black = theme.colors.black
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
				-- splits borders
				highlights.WinSeparator = {
					fg = theme.nvim.splitborders,
				}

				-- markdown small code block
				highlights["@markup.raw.markdown_inline"] = {
					fg = theme.colors.magenta,
					bg = theme.colors.gray0,
				}

				-- folds
				highlights.Folded = {
					fg = theme.colors.blue,
					bg = theme.colors.gray0,
				}

				-- search highlights
				highlights.Search = {
					fg = theme.nvim.searchfg,
					bg = theme.nvim.searchbg,
				}
				highlights.IncSearch = {
					fg = theme.nvim.incsearchfg,
					bg = theme.nvim.incsearchbg,
				}

				-- suggestions menu
				highlights.Pmenu = {
					fg = theme.colors.fg,
					bg = theme.colors.gray1,
				}
				highlights.PmenuSel = {
					bg = theme.ui.cursor_line,
				}
				highlights.PmenuMatch = {
					fg = theme.nvim.searchfg,
				}
				highlights.PmenuMatchSel = {
					fg = theme.nvim.searchfg,
				}
				-- scrollbar
				highlights.PmenuSbar = {
					bg = theme.colors.gray0,
				}
				highlights.PmenuThumb = {
					bg = theme.ui.accent,
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
				-- inactive buffer
				highlights.BufferInactive = {
					fg = theme.colors.gray2,
					bg = theme.colors.gray1,
				}
				highlights.BufferInactiveSign = {
					fg = theme.colors.bg,
					bg = theme.colors.gray0,
				}
				-- inactive modified buffer
				highlights.BufferInactiveMod = {
					fg = theme.colors.yellow,
					bg = theme.colors.gray1,
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
					bg = theme.colors.gray1,
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
				highlights.MarkSignNumHL = {
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

				-- whichkey
				highlights.WhichKeyBorder = {
					fg = theme.nvim.floatborders,
				}
				highlights.WhichKeyTitle = {
					fg = theme.nvim.floatborders,
				}

				highlights.WhichKey = {
					fg = theme.nvim.whichkeykey,
				}
				highlights.WhichKeySeparator = {
					fg = theme.nvim.whichkeyseparator,
				}
				highlights.WhichKeyDesc = {
					fg = theme.nvim.whichkeydescription,
				}
				highlights.WhichKeyGroup = {
					fg = theme.nvim.whichkeygroup,
				}

				-- Telescope
				highlights.TelescopeBorder = {
					fg = theme.nvim.telescopeborder,
				}
				highlights.TelescopePromptBorder = {
					fg = theme.nvim.telescopepromptborder,
				}
				highlights.TelescopePromptTitle = {
					fg = theme.nvim.telescopeprompttitle,
				}
				highlights.TelescopePreviewBorder = {
					fg = theme.nvim.telescopepreviewborder,
				}
				highlights.TelescopePreviewTitle = {
					fg = theme.nvim.telescopepreviewtitle,
				}
				highlights.TelescopeSelection = {
					bg = theme.nvim.telescopeselection,
				}
				highlights.TelescopePromptPrefix = {
					fg = theme.nvim.telescopepromptprefix,
				}
				highlights.TelescopeMatching = {
					fg = theme.nvim.telescopematch,
				}

				-- nvimtree
				highlights.NvimTreeWinSeparator = {
					fg = theme.nvim.splitborders,
				}
			end,
		})

		vim.cmd("colorscheme tokyonight")

		vim.opt.termguicolors = true
		vim.opt.background = "dark" -- colorschemes that can be light or dark will be made dark
	end,
}
