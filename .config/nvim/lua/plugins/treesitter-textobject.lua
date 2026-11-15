return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	branch = "main",
	init = function()
		-- Disable entire built-in ftplugin mappings to avoid conflicts.
		-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
		vim.g.no_plugin_maps = true

		-- Or, disable per filetype (add as you like)
		-- vim.g.no_python_maps = true
		-- vim.g.no_ruby_maps = true
		-- vim.g.no_rust_maps = true
		-- vim.g.no_go_maps = true
	end,
	config = function()
		require("nvim-treesitter-textobjects").setup({
			select = {
				enable = true,
				lookahead = true,
			},
		})
		-- Function textobjects
		vim.keymap.set({ "x", "o" }, "af", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
		end, { desc = "Select outer function" })
		vim.keymap.set({ "x", "o" }, "if", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
		end, { desc = "Select inner function" })

		-- Class textobjects
		vim.keymap.set({ "x", "o" }, "ac", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
		end, { desc = "Select outer class" })
		vim.keymap.set({ "x", "o" }, "ic", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
		end, { desc = "Select inner class" })

		-- Scope textobjects
		vim.keymap.set({ "x", "o" }, "as", function()
			require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
		end, { desc = "Select local scope" })

		-- Markdown Fenced Code Block textobjects
		local select = require("nvim-treesitter-textobjects.select")

		vim.keymap.set({ "x", "o" }, "aC", function()
			select.select_textobject("@code_block.outer", "textobjects")
		end, { desc = "Around Markdown code block" })

		vim.keymap.set({ "x", "o" }, "iC", function()
			select.select_textobject("@code_block.inner", "textobjects")
		end, { desc = "Inside Markdown code block" })
	end,
}
