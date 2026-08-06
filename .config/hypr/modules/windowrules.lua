--[[
  modules/windowrules.lua
  Converted from windowrules.conf.
  See https://wiki.hypr.land/Configuring/Basics/Window-Rules/ and .../Layer-Rules/
]]

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({
	name = "fix-xwayland-drags", -- fix some dragging issues with XWayland
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

-- -- opacity --
hl.window_rule({ match = { class = "^(obsidian)$" }, opacity = "0.99" }) -- makes obsidian work with blur, for some reason
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, opacity = "0.85" }) -- OBS
hl.window_rule({ match = { class = "^(com.azefsw-audioconnect-desktop-app-MainKt)$" }, opacity = "0.9" }) -- Audiorelay
hl.window_rule({ match = { class = "^(com.github.th[_-]ch.youtube[_-]music)$" }, opacity = "0.99" }) -- pear-desktop
hl.window_rule({ match = { class = "^(spotify)$" }, opacity = "0.8" })
hl.window_rule({ match = { class = "portmaster" }, opacity = "0.85" })
hl.window_rule({ match = { class = "[sS]team" }, opacity = "0.85" })
hl.window_rule({ match = { initial_title = "[sS]team" }, opacity = "0.85" }) -- steam update window
hl.window_rule({ match = { class = "syncthingtray" }, opacity = "0.8" })
hl.window_rule({ match = { class = "com.github.wwmm.easyeffects" }, opacity = "0.85" })
hl.window_rule({ match = { class = "signal" }, opacity = "0.85" })
hl.window_rule({ match = { class = "org.telegram.desktop" }, opacity = "0.85" })

-- -- floating, size, center --
hl.window_rule({ match = { initial_title = "termfilechooser" }, float = true })
hl.window_rule({ match = { initial_title = "termfilechooser" }, size = "monitor_w*0.65 monitor_h*0.65" })
hl.window_rule({ match = { class = "nvim-anywhere" }, float = true })
hl.window_rule({ match = { class = "nvim-anywhere" }, size = "monitor_w*0.30 monitor_h*0.35" })
hl.window_rule({ match = { class = "protonvpn-app" }, float = true })
hl.window_rule({ match = { class = "protonvpn-app" }, center = true })
hl.window_rule({ match = { class = "gimp" }, float = true })
hl.window_rule({ match = { class = "org.qbittorrent.qBittorrent" }, float = true })
hl.window_rule({ match = { initial_title = "Gamescope WSI Layer Error" }, float = true })
hl.window_rule({ match = { class = "org.kde.kdenlive" }, float = true })
hl.window_rule({ match = { class = "pytab" }, float = true })
hl.window_rule({ match = { class = "pytab" }, size = "monitor_w*0.40 monitor_h*0.60" })
hl.window_rule({ match = { class = "tridactyl-insert" }, float = true })
hl.window_rule({ match = { class = "tridactyl-insert" }, size = "monitor_w*0.40 monitor_h*0.40" })

-- -- workspaces --
hl.window_rule({ match = { class = "zen" }, workspace = "2" })
hl.window_rule({ match = { class = "vesktop" }, workspace = "4 silent" })
hl.window_rule({ match = { class = "signal" }, workspace = "4" })
hl.window_rule({ match = { class = "virt-manager" }, workspace = "6" })
hl.window_rule({ match = { class = "[sS]team" }, workspace = "7 silent" })
hl.window_rule({ match = { initial_title = "[sS]team" }, workspace = "7 silent" })
hl.window_rule({ match = { class = "net.lutris.Lutris" }, workspace = "10" })
hl.window_rule({ match = { class = "steam_app_default" }, workspace = "10 silent" })
hl.window_rule({ match = { class = "gamescope" }, workspace = "10 silent" })
hl.window_rule({ match = { content = "3" }, workspace = "10" }) -- windows with content type "game"
hl.window_rule({ match = { initial_title = "^(qBittorrent)$" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "solaar" }, workspace = "special:magic silent" })
hl.window_rule({ match = { class = "^(com.github.th[_-]ch.youtube[_-]music)$" }, workspace = "special:music silent" })
hl.window_rule({ match = { class = "portmaster" }, workspace = "special:portmaster silent" })

-- -- blur --
hl.window_rule({ match = { class = "steam_app_default" }, no_blur = true })
hl.window_rule({ match = { class = "gamescope" }, no_blur = true })

-- -- workspace rules --
hl.workspace_rule({ workspace = "special:magic", gaps_out = 25 })

-- -- animation overrides --
hl.window_rule({ match = { class = "pytab" }, animation = "gnomed" })
-- hl.window_rule({ match = { class = "pytab" }, no_anim = true })

-- -- special overrides --
-- tearing and render_unfocused
hl.window_rule({ match = { workspace = "10" }, immediate = true })
hl.window_rule({ match = { workspace = "10" }, render_unfocused = true })

-- picture-in-picture
hl.window_rule({
	name = "picture-in-picture",
	match = { title = "^(Picture-in-Picture)$" },

	float = true,
	pin = true,
	no_initial_focus = true,
	keep_aspect_ratio = true,
	move = "monitor_w-window_w-2 monitor_h-window_h-2",
})
-- flameshot pinned image
hl.window_rule({
	name = "flameshot-pin",
	match = { title = "^(flameshot-pin)$" },

	float = true,
	pin = true,
	center = true,
	size = "window_w*1 window_h*1",
})
-- flameshot window when screenshotting
hl.window_rule({
	name = "flameshot-window",
	match = { title = "^(flameshot)$" },

	center = true,
	animation = "gnomed",
	stay_focused = true,
	workspace = "special:flameshot",
})

hl.window_rule({
	name = "tray-tui",
	match = { class = "tray-tui" },

	float = true,
	animation = "slide",
	size = "monitor_w*0.6 monitor_h*0.7",
	move = { "monitor_w / 2 - (monitor_w * 0.6 / 2)", "monitor_h - monitor_h * 0.7 - 2" },
	stay_focused = true,
})
hl.window_rule({
	name = "wiremix",
	match = { class = "wiremix" },

	float = true,
	animation = "slide",
	size = "monitor_w*0.35 monitor_h*0.35",
	move = { "monitor_w / 2 - (monitor_w * 0.35 / 2)", "monitor_h - monitor_h * 0.35 - 2" },
	stay_focused = true,
})
hl.window_rule({
	name = "quick-notes",
	match = { class = "quick-notes" },

	float = true,
	animation = "slide",
	size = "monitor_w*0.5 monitor_h*0.64",
	move = { "monitor_w / 2 - (monitor_w * 0.5 / 2)", "monitor_h - monitor_h * 0.64 - 2" },
})

-- -- layer rules --
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, blur_popups = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0 })

-- dunst, mako, etc
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })
hl.layer_rule({ match = { namespace = "notifications" }, ignore_alpha = 0 }) -- avoids buggy borders when using blur
hl.layer_rule({ match = { namespace = "notifications" }, animation = "slide" }) -- cool slide animation :O

hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0 })

-- wlogout
hl.layer_rule({ match = { namespace = "logout_dialog" }, blur = true })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, xray = true })

hl.layer_rule({ match = { namespace = "quickshell" }, blur = true })
hl.layer_rule({ match = { namespace = "quickshell" }, ignore_alpha = 0 })
hl.layer_rule({ match = { namespace = "quickshell" }, animation = "slide" })

hl.layer_rule({ match = { namespace = "hyprpicker" }, no_anim = true })

-- wl-kbptr
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })

-- wvkbd virtual keyboard
hl.layer_rule({ match = { namespace = "wvkbd" }, blur = true })
