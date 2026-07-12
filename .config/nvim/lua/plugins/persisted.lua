-- Lua
return {
	"olimorris/persisted.nvim",
	-- event = "BufReadPre", -- Ensure the plugin loads only when a buffer has been loaded
	opts = {
		---@return bool
		should_save = function()
			-- Do not save if the alpha dashboard is the current filetype
			if vim.bo.filetype == "alpha" then
				return false
			end
			return true
		end,
	},

	config = function(_, opts)
		require("persisted").setup(opts)

		-- restore the order the buffers were in barbar
		vim.opt.sessionoptions:append("globals")
		vim.api.nvim_create_autocmd({ "User" }, {
			pattern = "PersistedSavePre",
			group = vim.api.nvim_create_augroup("PersistedHooks", {}),
			callback = function()
				vim.api.nvim_exec_autocmds("User", { pattern = "SessionSavePre" })
			end,
		})

		-- Keymaps
		vim.keymap.set(
			"n",
			"<leader>wr",
			"<cmd>Persisted load<CR>",
			{ desc = "Load the session for the current directory" }
		)

		vim.keymap.set(
			"n",
			"<leader>ws",
			"<cmd>Persisted save<CR>",
			{ desc = "Save the session for the current directory" }
		)

		vim.keymap.set(
			"n",
			"<leader>wf",
			"<cmd>Telescope persisted<CR>",
			{ desc = "Fuzzy find sessions with Telescope" }
		)
	end,
}
