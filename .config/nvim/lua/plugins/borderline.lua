return {
	"mikesmithgh/borderline.nvim",
	enabled = false,
	lazy = true,
	event = "VeryLazy",
	config = function()
		require("borderline").setup({
			--  ...
		})
	end,
}
