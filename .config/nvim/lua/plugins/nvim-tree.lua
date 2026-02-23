-- file explorer
return {
	"nvim-tree/nvim-tree.lua",
	dependencies = "nvim-tree/nvim-web-devicons",
	-- enabled = false,
	config = function()
		local nvimtree = require("nvim-tree")

		-- recommended settings from nvim-tree docs
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		-- highlight overrides
		-- you can do :NvimTreeHiTest to see all highlights
		vim.cmd([[

      :hi NvimTreeWinSeparator        guifg=#690085

      :hi NvimTreeExecFile            guifg=#00bfa7

      :hi NvimTreeSymlink             guifg=#00ffff

      :hi NvimTreeFolderArrowClosed   guifg=#616a94
      :hi NvimTreeFolderArrowOpen     guifg=#616a94
      :hi NvimTreeIndentMarker        guifg=#616a94
    ]])

		nvimtree.setup({
			view = {
				width = 35,
				relativenumber = true,
			},
			-- change folder arrow icons
			renderer = {
				indent_markers = {
					enable = true,
				},
			},
			-- disable window_picker for
			-- explorer to work well with
			-- window splits
			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},
			filters = {
				custom = { ".DS_Store" },
			},
			git = {
				ignore = false,
			},
		})

		-- set keymaps
		local keymap = vim.keymap -- for conciseness

		keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
		keymap.set(
			"n",
			"<leader>ef",
			"<cmd>NvimTreeFindFileToggle<CR>",
			{ desc = "Toggle file explorer on current file" }
		) -- toggle file explorer on current file
		keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
		keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer
	end,
}
