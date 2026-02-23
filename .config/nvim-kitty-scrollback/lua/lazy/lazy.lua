-- This is the plugin manager

-- This will basically auto install lazy when you open nvim if it's not already installed

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
		-- { import = "plugins.lsp"},
	},

	-- colorscheme that will be used when installing plugins.
	-- install = { colorscheme = { "habamax" } },
	-- automatically check for plugin updates
	checker = {
		enabled = true,
		notify = false,
	},
	ui = {
		border = "rounded",
	},
	change_detection = {
		notify = false,
	},
})
