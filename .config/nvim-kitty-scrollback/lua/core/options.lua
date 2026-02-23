-- Misc.
-- vim.cmd("let g:netrw_liststyle = 3") -- make nvim's file explorer show in list tree mode
vim.opt.mouse = "a" -- enable mouse support

vim.opt.cursorline = true -- highlights the current line you're in
vim.opt.scrolloff = 5 -- keep X lines visible when scrolling
vim.opt.sidescrolloff = 5 -- keep X columns visible when side-scrolling

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

-- Transparency
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })

-- Transparent highlights
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#484848" })
vim.api.nvim_set_hl(0, "Visual", { bg = "#6b1498" })

-- Scrollback thingys
vim.opt.swapfile = false
vim.opt.shada = ""
vim.opt.backup = false
vim.opt.writebackup = false
