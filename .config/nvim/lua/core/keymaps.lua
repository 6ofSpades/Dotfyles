-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- Make go and gO insert new lines while still staying in normal mode
vim.keymap.set("n", "gO", "O<Esc>")
vim.keymap.set("n", "go", "o<Esc>")

vim.keymap.set({ "n" }, "H", "<C-w>h")
vim.keymap.set({ "n" }, "J", "<C-w>j")
vim.keymap.set({ "n" }, "K", "<C-w>k")
vim.keymap.set({ "n" }, "L", "<C-w>l")

-- Window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })

vim.keymap.set(
	"n",
	"<leader>se",
	"<cmd>windo set nowinfixheight<cr><cmd>windo set nowinfixwidth<cr><C-w>=",
	{ desc = "Make splits equal size" }
)

vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split window" })

-- Resizing splits
vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize -2<cr>", { desc = "Increase Window Width" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize +2<cr>", { desc = "Decrease Window Width" })

vim.keymap.set("n", "<leader>st", "<C-w>T", { desc = "Move split into a new tab" })

vim.keymap.set("n", "<leader>sch", "<C-w>H", { desc = "Move split to the far left" })
vim.keymap.set("n", "<leader>scj", "<C-w>J", { desc = "Move split to the far down" })
vim.keymap.set("n", "<leader>sck", "<C-w>K", { desc = "Move split to the far up" })
vim.keymap.set("n", "<leader>scl", "<C-w>L", { desc = "Move split to the far right" })

-- Tabs
vim.keymap.set("n", "<leader>to", "<cmd>tabnew %<CR>", { desc = "Open new tab with current buffer" })
vim.keymap.set("n", "<leader>tk", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- think as tab kill. tk is easier to press than tx
vim.keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>th", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
vim.keymap.set("n", "<leader>tp", "g<Tab>", { desc = "Go to previously visited tab" })

vim.keymap.set("n", "<A-l>", "<cmd>bnext<CR>", { desc = "Cycle to next buffer" })
vim.keymap.set("n", "<A-h>", "<cmd>bprev<CR>", { desc = "Cycle to previous buffer" })
vim.keymap.set("n", "<A-x>", "<cmd>bd<CR>", { desc = "Delete current buffer" })

-- Better navigation in insert mode
vim.keymap.set("i", "<a-h>", "<Left>")
vim.keymap.set("i", "<a-j>", "<Down>")
vim.keymap.set("i", "<a-k>", "<Up>")
vim.keymap.set("i", "<a-l>", "<Right>")

vim.keymap.set("i", "<a-b>", "<Esc>bi")
vim.keymap.set("i", "<a-e>", "<Esc>ea")
vim.keymap.set("i", "<a-w>", "<Esc>lwi")
vim.keymap.set("i", "<a-x>", "<Delete>")
vim.keymap.set("i", "<a-d>", "<Right><Esc>cw")

vim.keymap.set("i", "<a-0>", "<Home>")
vim.keymap.set("i", "<a-$>", "<End>")

vim.keymap.set("i", "<C-BS>", "<Esc>ciw")
