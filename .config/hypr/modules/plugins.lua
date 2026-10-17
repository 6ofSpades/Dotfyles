-- Variables
local theme = os.getenv("HOME") .. "/.config/theme/generated/theme.lua"
local hypr_theme = os.getenv("HOME") .. "/.config/theme/generated/hyprland.lua"
local theme = require(theme)
local hypr_theme = require(hypr_theme)

----------------------------------------------------------------
-- Gloview
----------------------------------------------------------------
hl.bind("ALT + TAB", hl.plugin.gloview.toggle)

hl.config({
	plugin = {
		gloview = {
			layout = "rows",
			gap = 34,
			padding = 80,
			padding_top = 40,
			padding_bottom = 70,
			max_scale = 1.0,
			duration = 200,
			preview_round = 12,
			blur = 1,

			switch_animation = 1,
			switch_duration = 260,
			move_animation = 1,
			move_duration = 240,

			anchor = "top",
			strip_offset = 0,
			strip_height = 150,
			strip_margin = 22,
			strip_gap = 18,
			strip_card_round = 10,

			focus_follows_mouse = 1,
			scroll_switches_workspace = 1,
			passthrough_keys = 1,
			exit_on_click = 1,
			exit_on_switch = 0,

			key_close = "q,esc,alt+tab",
			key_next_workspace = "alt+l",
			key_prev_workspace = "alt+h",
			key_activate = "enter",
			key_close_window = "d",
			key_left = "h",
			key_right = "l",
			key_up = "k",
			key_down = "j",
			key_desktop = "s",
			key_all_workspaces = "a",
			key_workspace = "1,2,3,4,5,6,7,8,9,0",

			show_all_workspaces = 0,
			show_empty = 1,
			dynamic_workspaces = 1,
			autodelete_empty = 1,
			show_workspace_labels = 1,
			show_window_labels = 1,
			show_special = 1,
			strip_all_card = 0,
			drag_to_swap = 1,
			switch_on_drop = 0,
			switch_on_new_workspace = 1,

			hide_top_layers = 0,
			hide_overlay_layers = 0,

			-- layers that should appear over gloview
			-- you can get the name you want with `hyprctl layers`
			above_namespaces = "notifications",
			debug_logs = 0,

			-- selected window
			select_border_size = 2,
			select_border = hypr_theme.colors.border,

			close_button_color = theme.colors.red,
			backdrop_color = "#00000030",

			-- anchor bar color
			strip_band_color = "#00000080",

			-- empty workspaces and "all workspaces" button
			strip_card_color = "#ffffff10", -- incative
			strip_active_color = "#000000", -- active
			-- active workspace / button border
			strip_active_border = theme.ui.accent,
			strip_hover_border = hypr_theme.colors.border_inactive,
			strip_active_border_size = 2,
			strip_hover_border_size = 2,

			-- all workspaces button squares color
			strip_plus_color = "#ffffff80",

			-- window background when in preview ???
			preview_bg = "#00000000",

			shadow_color = "#00000080",

			-- window hovered with the mouse
			hover_border = theme.ui.accent,
			hover_border_size = 3,
		},
	},
})
