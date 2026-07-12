return {
	"romgrk/barbar.nvim",
	enabled = true,
	version = "^1.0.0",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
		"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	opts = {
		auto_hide = 0,
		exclude_ft = { "alpha" },
		animation = false,
	},
	config = function(_, opts)
		-- 1. Setup barbar with your options defined above
		require("barbar").setup(opts)

		-- 2. Define Keymaps safely inside the config function
		-- switch buffers
		vim.keymap.set("n", "<A-l>", "<cmd>BufferNext<CR>", { desc = "Cycle to next buffer" })
		vim.keymap.set("n", "<A-h>", "<cmd>BufferPrevious<CR>", { desc = "Cycle to previous buffer" })
		vim.keymap.set("n", "<leader>bb", "<cmd>BufferPick<CR>", { desc = "Pick a buffer" })
		vim.keymap.set("n", "<leader>bf", "<cmd>Telescope buffers<cr>", { desc = "Fuzzy find open buffers" })
		-- close buffers
		vim.keymap.set("n", "<A-x>", "<cmd>BufferClose<CR>", { desc = "Close current buffer" })
		vim.keymap.set("n", "<leader>bx", "<cmd>BufferPickDelete<CR>", { desc = "Pick close a buffer" })
		-- move buffers
		vim.keymap.set("n", "<leader>bh", "<cmd>BufferMovePrevious<CR>", { desc = "Move buffer to left" })
		vim.keymap.set("n", "<leader>bl", "<cmd>BufferMoveNext<CR>", { desc = "Move buffer to right" })
		-- pin buffers
		vim.keymap.set("n", "<leader>bp", "<cmd>BufferPin<CR>", { desc = "Pin buffer" })
	end,
}
