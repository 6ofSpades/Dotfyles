-- Misc.
-- vim.cmd("let g:netrw_liststyle = 3") -- make nvim's file explorer show in list tree mode
vim.opt.mouse = "a" -- enable mouse support

-- don't show mode, since it's already on the status bar
vim.opt.showmode = false

vim.opt.cursorline = true -- highlights the current line you're in
vim.opt.scrolloff = 5 -- keep X lines visible when scrolling
vim.opt.sidescrolloff = 5 -- keep X columns visible when side-scrolling

-- Enable line wrapping
vim.opt.wrap = true
vim.opt.linebreak = true

-- Search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes case-sensitive
-- this basically makes search always case insensitive, unless you incluse an upper-case letter in the search

-- Split windows
vim.opt.splitright = true -- if you split vertically, window will go to the right
vim.opt.splitbelow = true -- if you split horizontally, window will go to the bottom

-- vim.opt.laststatus = 3
vim.opt.fillchars = {
	vert = "┆",
	eob = " ", -- remove the tildas that appear at the end of file or on empty lines
}

-- Scrollback thingys
vim.opt.swapfile = false
vim.opt.shada = ""
vim.opt.backup = false
vim.opt.writebackup = false

-- Clipboard
-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.o.clipboard = "unnamedplus"
	end,
})

-- Automatically enable English spellcheck for text and markdown files
-- English is by default, you can change language with Telescope
-- Also wrap and linebreak
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "markdown", "text" },
	callback = function()
		vim.opt_local.spell = true
		vim.opt_local.spelllang = "en"
		vim.opt.wrap = true
		vim.opt.linebreak = true
	end,
})
