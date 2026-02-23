-- Lua
return {
	"olimorris/persisted.nvim",
	-- event = "BufReadPre", -- Ensure the plugin loads only when a buffer has been loaded
	opts = {
		-- Your config goes here ...
	},

	-- Keymaps
	vim.keymap.set(
		"n",
		"<leader>wr",
		"<cmd>Persisted load<CR>",
		{ desc = "Load the session for the current directory" }
	),

	vim.keymap.set(
		"n",
		"<leader>ws",
		"<cmd>Persisted save<CR>",
		{ desc = "Save the session for the current directory" }
	),

	vim.keymap.set("n", "<leader>wf", "<cmd>Telescope persisted<CR>", { desc = "Fuzzy find sessions with Telescope" }),
}
