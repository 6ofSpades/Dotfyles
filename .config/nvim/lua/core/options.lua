-- Misc.
vim.cmd("let g:netrw_liststyle = 3") -- make nvim's file explorer show in list tree mode
vim.opt.mouse = "a" -- enable mouse support

-- don't show mode, since it's already on the status bar
vim.opt.showmode = false

vim.opt.cursorline = true -- highlights the current line you're in
vim.opt.scrolloff = 5 -- keep X lines visible when scrolling
vim.opt.sidescrolloff = 5 -- keep X columns visible when side-scrolling
vim.opt.wrap = false -- ":h wrap" to see what this does
vim.opt.relativenumber = true
vim.opt.number = true

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s) See `:help 'confirm'`
vim.o.confirm = true

-- Tabs and identation
vim.opt.tabstop = 2 -- 2 spaces for tabs
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting a new one

-- Search settings
vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- if you include mixed case in your search, assumes case-sensitive
-- this basically makes search always case insensitive, unless you incluse an upper-case letter in the search

-- Clipboard
-- Sync clipboard between OS and Neovim. Schedule the setting after `UiEnter` because it can
-- increase startup-time. Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.api.nvim_create_autocmd("UIEnter", {
	callback = function()
		vim.o.clipboard = "unnamedplus"
	end,
})

-- Split windows
vim.opt.splitright = true -- if you split vertically, window will go to the right
vim.opt.splitbelow = true -- if you split horizontally, window will go to the bottom

vim.opt.signcolumn = "yes" -- show sign column so that text doesn't shift

vim.opt.laststatus = 3
vim.opt.fillchars = {
	vert = "┆",
	-- verthoriz = "=",
	-- horiz = "𜸍",
	eob = " ", -- remove the tildas that appear at the end of file or on empty lines
}

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
