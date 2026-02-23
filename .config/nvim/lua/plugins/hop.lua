return {
	"smoka7/hop.nvim",
	version = "*",
	opts = {
		keys = "etovxqpdygfblzhckisuran",
	},

	-- Keymaps
	vim.keymap.set({ "n", "x", "o" }, "ff", "<cmd>HopCamelCase<cr>"),
	vim.keymap.set({ "n", "x", "o" }, "fs", "<cmd>HopChar1<cr>"), -- Great for special characters, eg: .!$&*()
	vim.keymap.set({ "n", "x", "o" }, "fe", "<cmd>HopPattern<cr>"),
	vim.keymap.set({ "n", "x", "o" }, "fl", "<cmd>HopLine<cr>"),
	vim.keymap.set({ "n", "x", "o" }, "fv", "<cmd>HopVertical<cr>"),

	-- like the normal find but should be better to use
	vim.keymap.set({ "n", "x", "o" }, "F", "<cmd>HopChar1CurrentLine<cr>"), -- Great for special characters, eg: .!$&*()
}
