return {
	"catgoose/nvim-colorizer.lua",
	event = "BufReadPre",
	opts = {
		parsers = {
			hex = { default = true },
			names = { enable = false }, -- example: red, blue, purple, etc.
			rgb = { enable = true },
			hsl = { enable = false }, -- hsl()/hsla() functions
			css_color = { enable = false }, -- color() function (srgb, display-p3, a98-rgb, etc.)
			xterm = { enable = false }, -- xterm 256-color codes (#xNN, \e[38;5;NNNm)
		},
	},
}
