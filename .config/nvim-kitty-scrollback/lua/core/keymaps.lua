-- Set <space> as the leader key
-- See `:help mapleader`
-- NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "

-- Use <Esc> to exit terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

vim.keymap.set({ "n" }, "H", "<C-w>h")
vim.keymap.set({ "n" }, "J", "<C-w>j")
vim.keymap.set({ "n" }, "K", "<C-w>k")
vim.keymap.set({ "n" }, "L", "<C-w>l")

-- Window management
-- Split right
vim.keymap.set("n", "<leader>sl", "<C-w>v", { desc = "Split window right" })

-- Split left
vim.keymap.set("n", "<leader>sh", function()
	vim.cmd("leftabove vsplit")
end, { desc = "Split window left" })

-- Split below
vim.keymap.set("n", "<leader>sj", "<C-w>s", { desc = "Split window below" })

-- Split above
vim.keymap.set("n", "<leader>sk", function()
	vim.cmd("leftabove split")
end, { desc = "Split window above" })

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
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<leader>to", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
vim.keymap.set("n", "<leader>tk", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- think as tab kill. tk is easier to press than tx
vim.keymap.set("n", "<leader>tl", "<cmd>tabn<CR>", { desc = "Go to next tab" })
vim.keymap.set("n", "<leader>th", "<cmd>tabp<CR>", { desc = "Go to previous tab" })

vim.keymap.set("n", "<A-l>", "<cmd>bnext<CR>", { desc = "Cycle to next buffer" })
vim.keymap.set("n", "<A-h>", "<cmd>bprev<CR>", { desc = "Cycle to previous buffer" })
vim.keymap.set("n", "<A-x>", "<cmd>bd<CR>", { desc = "Delete current buffer" })
vim.keymap.set("n", "<leader>bx", "<cmd>BufferLinePickClose<CR>", { desc = "Pick buffer to close" })
vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer to the left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer to the right" })

-- Select all with Ctrl-a
vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Keep cursor in place after yanking in visual mode
vim.keymap.set("v", "y", "ygv<Esc>")

-- Keep cursor and selection after pasting in visual mode
vim.keymap.set("v", "p", "pgv")

-- Don't end of line in blank character when in visual mode
-- vim.keymap.set("v", "$", "$h")

-- swap ' and ` just cause it's easier on ABNT keyboard
vim.keymap.set("n", "'", "`")
