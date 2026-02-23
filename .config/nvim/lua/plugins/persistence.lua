return {
	"folke/persistence.nvim",
	event = "BufReadPre", -- this will only start session saving when an actual file was opened
	enabled = false,
	opts = {
		-- add any custom options here
	},

	-- Keymaps
	-- vim.keymap.set("n", "<leader>wr", function()
	-- 	require("persistence").load()
	-- end, { desc = "Load the session for the current directory" }),
	--
	-- vim.keymap.set("n", "<leader>wR", function()
	-- 	require("persistence").select()
	-- end, { desc = "Select a session to load" }),
	--
	-- vim.keymap.set("n", "<leader>wl", function()
	-- 	require("persistence").load({ last = true })
	-- end, { desc = "Load the last session" }),
	--
	-- vim.keymap.set("n", "<leader>wx", function()
	-- 	require("persistence").stop()
	-- end, { desc = "Stop Persistence => session won't be saved on exit" }),
}
