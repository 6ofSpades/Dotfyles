-- opens a picker for you to select a filetype
-- and get syntax highlighting when using nvim anywhere

local M = {}

local favorite_filetypes = {
	"none", -- Added option to turn off syntax highlighting
	"markdown",
	"python",
	"javascript",
	"typescript",
	"json",
	"html",
	"css",
	"bash",
	"lua",
}

function M.setup()
	local function open_filetype_picker()
		vim.ui.select(favorite_filetypes, {
			prompt = "Select Filetype for Syntax Highlighting:",
			format_item = function(item)
				if item == "none" then
					return " Clear syntax / Turn off "
				end
				return " Let there be: " .. item
			end,
		}, function(choice)
			if choice then
				if choice == "none" then
					vim.bo.filetype = "" -- Clears the filetype, effectively turning off syntax
					print("Syntax highlighting turned off")
				else
					vim.bo.filetype = choice
					print("Filetype set to " .. choice)
				end
			end
		end)
	end

	-- Bind the keymap inside the setup function
	vim.keymap.set("n", "<leader>ff", open_filetype_picker, { desc = "Pick filetype" })
end

return M
