return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",

	dependencies = {
		"windwp/nvim-ts-autotag",
	},

	config = function()
		local ts = require("nvim-treesitter")

		ts.install({
			"bash",
			"c",
			"css",
			"dockerfile",
			"gitignore",
			"graphql",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"prisma",
			"python",
			"query",
			"svelte",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				pcall(vim.treesitter.start, args.buf)
			end,
		})

		require("nvim-ts-autotag").setup()
	end,
}
