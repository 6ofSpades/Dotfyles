return {
	"MeanderingProgrammer/render-markdown.nvim",
	-- dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
	-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
	---@module 'render-markdown'
	---@type render.md.UserConfig
	opts = {
		code = {
			language_border = " ", -- disable the black background
			-- language_left = "",
			-- language_right = "",
			-- border = "thick",
			-- above = "_",
			-- below = "⎺",
		},
		heading = {
			width = "block",
			left_pad = 2,
			right_pad = 4,
		},
		bullet = { icons = { "•", "◦" } },
	},
}
