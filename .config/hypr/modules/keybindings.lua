--[[
  modules/keybindings.lua
  Converted from keybindings.conf.

  Flag mapping used below (classic hyprlang bind-flag letters -> hl.bind() opts table):
    l -> locked            r -> release        e -> repeating
    n -> non_consuming      m -> mouse = true  (mouse binds use `mouse = true`; add
                             `drag = true` alongside it if you only want the bind to fire
                             once the mouse has moved past binds.drag_threshold)
    t -> transparent        i -> ignore_mods    s -> (not used in this file)
    u -> submap_universal  (confirmed: this makes the bind work from inside any submap,
                             same as it did in classic hyprlang)
]]

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- terminal / browser / fileManager / hyprscripts come from hyprland.lua's top-level locals.
-- Since Hyprland gives each require()'d file its own scope, we redeclare the ones we need here.
local terminal = "kitty"
local browser = "zen-browser"
local fileManager = terminal .. " yazi"
local hyprscripts = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

-- wlogout
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("pkill wlogout || wlogout -b 4"))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal), { submap_universal = true }) -- TODO: this used to open floating+centered at 50%/50% via
-- `[float; size (monitor_w*0.5) (monitor_h*0.5); center 1]`.
-- exec-time window rules like that aren't in hl.exec_cmd's rule
-- table; easiest fix is a named hl.window_rule() matching this
-- terminal's class/title, or pass a rule table as hl.exec_cmd's
-- 2nd argument if your Hyprland build supports float/size/center there.
-- hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser), { submap_universal = true })
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager), { submap_universal = true })
hl.bind(
	mainMod .. " + Y",
	hl.dsp.exec_cmd(
		"pkill tray-tui || "
			.. hyprscripts
			.. '/open-and-focus "kitty -1 --instance-group=tui --class tray-tui tray-tui" "tray-tui"'
	),
	{ submap_universal = true }
)
hl.bind(
	mainMod .. " + B",
	hl.dsp.exec_cmd(
		"pkill wiremix || "
			.. hyprscripts
			.. '/open-and-focus "kitty -1 --instance-group=tui --class wiremix wiremix" "wiremix"'
	),
	{ submap_universal = true }
)
hl.bind(mainMod .. " + CTRL + N", hl.dsp.exec_cmd(hyprscripts .. "/nvim-anywhere"), { submap_universal = true })

-- hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"), { submap_universal = true })

-- hyprctl hyprsunset
hl.bind(
	mainMod .. " + F12",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset gamma +10 && notify-send -a Hyprsunset "Gamma:" "$(hyprctl hyprsunset gamma)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true }
)
hl.bind(
	mainMod .. " + F11",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset gamma -10 && notify-send -a Hyprsunset "Gamma:" "$(hyprctl hyprsunset gamma)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true }
)
hl.bind(
	mainMod .. " + SHIFT + F12",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset temperature +100 && notify-send -a Hyprsunset "Temperature:" "$(hyprctl hyprsunset temperature)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true }
)
hl.bind(
	mainMod .. " + SHIFT + F11",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset temperature -100 && notify-send -a Hyprsunset "Temperature:" "$(hyprctl hyprsunset temperature)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true }
)
hl.bind(
	mainMod .. " + F10",
	hl.dsp.exec_cmd("killall hyprsunset & sleep 0.2 && hyprsunset"),
	{ submap_universal = true }
) -- reset hyprsunset

-- ------
-- Keybind grabbing block
-- Track the current toggle state (defaulting to true based on your snippet)
local grabDisabled = true

hl.bind(mainMod .. " + F9", function()
	-- Flip the boolean value (true becomes false, false becomes true)
	grabDisabled = not grabDisabled

	-- Apply the updated configuration value
	hl.config({
		binds = {
			disable_keybind_grabbing = grabDisabled,
		},
	})

	-- Send a notification to see the current state on screen
	local statusText = grabDisabled and "Enabled" or "Disabled"
	hl.dispatch(
		hl.dsp.exec_cmd(
			"notify-send -a Hyprland -t 2000 -i preferences-desktop-keyboard -u low -r 242 'Keybind Grabbing Block:' '"
				.. statusText
				.. "'"
		)
	)
end)
-- ------

-- quick-notes with obsidian/nvim
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(hyprscripts .. "/quick-notes"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("obsidian"))

-- screenshot
hl.bind(
	"Print",
	hl.dsp.exec_cmd(hyprscripts .. '/open-and-focus "flameshot gui" "flameshot"'),
	{ submap_universal = true }
)
hl.bind(
	"SHIFT + Print",
	hl.dsp.exec_cmd(hyprscripts .. '/open-and-focus "flameshot gui --last-region" "flameshot"'),
	{ submap_universal = true }
)

-- close windows
hl.bind(mainMod .. " + C", hl.dsp.window.close(), { submap_universal = true })
hl.bind(mainMod .. " + CTRL + C", hl.dsp.window.kill(), { submap_universal = true }) -- for when a window is not responding

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })) -- Maximize window
hl.bind(mainMod .. " + P", function()
	hl.dispatch(hl.dsp.window.pin())
	hl.exec_cmd("paplay " .. hyprscripts .. "/.pop-alert.mp3")
end)
hl.bind(mainMod .. " + O", hl.dsp.layout("togglesplit")) -- dwindle
hl.bind(mainMod .. " + SHIFT + O", hl.dsp.layout("swapsplit")) -- dwindle
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" })) -- fullscreen window

hl.bind(
	mainMod .. " + CTRL + W",
	hl.dsp.exec_cmd(
		'virsh --connect qemu:///system start "microsoft-sucks" & virt-manager --connect qemu:///system --show-domain-console "microsoft-sucks"'
	)
)

-- Rofi
hl.bind(
	"ALT + SPACE",
	hl.dsp.exec_cmd("pkill rofi || rofi -show drun -icon-theme candy-icons"),
	{ submap_universal = true }
)
hl.bind("ALT + TAB", hl.dsp.exec_cmd("pkill rofi || rofi -show window"), { submap_universal = true })
hl.bind(
	mainMod .. " + EQUAL",
	hl.dsp.exec_cmd(
		'pkill rofi || rofi -rofi-qalc ./build -show "qalc" -automatic-save-to-history -history-length 7 -no-sort'
	)
)
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd(
		"pkill rofi || rofi -modi clipboard:"
			.. os.getenv("HOME")
			.. "/.config/hypr/scripts/clipvault-rofi -show clipboard -show-icons -config "
			.. os.getenv("HOME")
			.. "/.config/rofi/clipboard.rasi"
	)
)
hl.bind(
	mainMod .. " + W",
	hl.dsp.exec_cmd("pkill rofi || nice -n 19 " .. os.getenv("HOME") .. "/.config/hypr/scripts/wp-selector")
) -- launch with low priority to avoid CPU spikes
hl.bind(mainMod .. " + U", hl.dsp.exec_cmd("pkill rofi || " .. hyprscripts .. "/rofi-rbw"))
hl.bind(
	mainMod .. " + PERIOD",
	hl.dsp.exec_cmd(
		[[rofimoji --hidden-descriptions --skin-tone light --selector-args="-theme ~/.config/rofi/moji.rasi -kb-secondary-copy ''" -f emojis kaomoji ]]
			.. os.getenv("HOME")
			.. [[/.config/rofi/custom_mojis.csv --keybinding-copy Ctrl+c --typer wl-ime-type --prompt "🤯🤡🎉 "]]
	)
)
hl.bind(mainMod .. " + SEMICOLON", hl.dsp.exec_cmd("pkill rofi || rofi -show run"))

hl.bind(
	mainMod .. " + COMMA",
	hl.dsp.exec_cmd(
		"( pkill hyprpicker && "
			.. hyprscripts
			.. "/submap-handling ) || ( "
			.. hyprscripts
			.. "/submap-handling MOUSE & sleep 0.1 && hyprpicker -aa && "
			.. hyprscripts
			.. "/submap-handling )"
	),
	{ submap_universal = true }
)

-- dunst
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind(mainMod .. " + X", hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("pkill rofi || dunstctl action"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }), { submap_universal = true })
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }), { submap_universal = true })
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }), { submap_universal = true })
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }), { submap_universal = true })

-- To switch between windows in a floating workspace
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd(hyprscripts .. "/cycle-float-tile"), { submap_universal = true }) -- change focus to another window

-- For moving the windows
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + C", hl.dsp.window.center())

-- For resizing the windows
-- I wanted to bind these to CTRL instead of ALT but my current keyboard is shit -_-
hl.bind(
	mainMod .. " + CTRL + l",
	hl.dsp.window.resize({ x = 20, y = 0, relative = true }),
	{ repeating = true, submap_universal = true }
)
hl.bind(
	mainMod .. " + CTRL + h",
	hl.dsp.window.resize({ x = -20, y = 0, relative = true }),
	{ repeating = true, submap_universal = true }
)
hl.bind(
	mainMod .. " + CTRL + k",
	hl.dsp.window.resize({ x = 0, y = -20, relative = true }),
	{ repeating = true, submap_universal = true }
)
hl.bind(
	mainMod .. " + CTRL + j",
	hl.dsp.window.resize({ x = 0, y = 20, relative = true }),
	{ repeating = true, submap_universal = true }
)

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, submap_universal = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, submap_universal = true })

-- Switch workspaces with mainMod + [0-9]
-- Will always try to switch to a tiling window after switching workspace
for i = 1, 10 do
	local key = (i == 10) and "0" or tostring(i)
	hl.bind(
		mainMod .. " + " .. key,
		hl.dsp.exec_cmd(hyprscripts .. "/workspace-switch " .. i),
		{ submap_universal = true }
	)
end

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = (i == 10) and "0" or tostring(i)
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", follow = false }))

hl.bind(mainMod .. " + CTRL + M", hl.dsp.workspace.toggle_special("music"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e+1" }))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
	{ repeating = true, locked = true, submap_universal = true }
)

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, submap_universal = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, submap_universal = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, submap_universal = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, submap_universal = true })

-- Scrolling layout for hyprscrolling plugin
hl.bind(mainMod .. " + RIGHT", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + LEFT", hl.dsp.layout("move -col"))

----------------------------------------------------------------
-- SUBMAPS
----------------------------------------------------------------

-- Making sure we can always get out of any submap with mainMod+Esc, in case something goes wrong
hl.bind(
	mainMod .. " + ESCAPE",
	hl.dsp.exec_cmd(hyprscripts .. "/submap-handling"),
	{ submap_universal = true, non_consuming = true }
)

----- "MOUSE" submap: keyboard-driven mouse control (used with wl-kbptr / ydotool)
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling MOUSE"), { submap_universal = true })

hl.define_submap("MOUSE", function()
	-- reset submap, call wl-kbptr, then enable MOUSE submap again
	-- f as in find
	hl.bind(
		"F",
		hl.dsp.exec_cmd(
			"hyprctl dispatch submap reset && wl-kbptr && hyprctl dispatch submap MOUSE && ydotool mousemove -x -1 -y 0 && ydotool mousemove -x +1 -y 0"
		),
		{ ignore_mods = true }
	)
	-- g as in go-to
	hl.bind(
		"G",
		hl.dsp.exec_cmd(
			"hyprctl dispatch submap reset && wl-kbptr -o modes=tile && hyprctl dispatch submap MOUSE && ydotool mousemove -x -1 -y 0 && ydotool mousemove -x +1 -y 0"
		),
		{ ignore_mods = true }
	)
	-- the trailing mouse-move nudge works around wl-kbptr's mousemove being a bit buggy

	-- move mouse
	hl.bind(
		"H",
		hl.dsp.exec_cmd("ydotool mousemove -x -10 -y 0"),
		{ ignore_mods = true, repeating = true, transparent = true }
	)
	hl.bind(
		"J",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y +10"),
		{ ignore_mods = true, repeating = true, transparent = true }
	)
	hl.bind(
		"K",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y -10"),
		{ ignore_mods = true, repeating = true, transparent = true }
	)
	hl.bind(
		"L",
		hl.dsp.exec_cmd("ydotool mousemove -x +10 -y 0"),
		{ ignore_mods = true, repeating = true, transparent = true }
	)

	hl.bind(
		"O",
		hl.dsp.exec_cmd("ydotool mousemove -a 1920 0 && " .. hyprscripts .. "/submap-handling"),
		{ ignore_mods = true }
	) -- O as in "Out of my way"
	hl.bind("C", hl.dsp.exec_cmd("ydotool mousemove -a 960 540"), { ignore_mods = true }) -- C as in "Center cursor"
	hl.bind(
		"Y",
		hl.dsp.exec_cmd(
			"ydotool key 29:1 46:1 46:0 29:0 && ydotool mousemove -a 1920 0 && " .. hyprscripts .. "/submap-handling"
		),
		{ ignore_mods = true }
	) -- send ctrl+c to copy, then reset

	hl.bind("M", hl.dsp.exec_cmd(hyprscripts .. "/mark-cursor mark"), { ignore_mods = true })
	hl.bind("apostrophe", hl.dsp.exec_cmd(hyprscripts .. "/mark-cursor move"), { ignore_mods = true })

	-- move further
	hl.bind("SHIFT + H", hl.dsp.exec_cmd("ydotool mousemove -x -100 -y 0"), { repeating = true })
	hl.bind("SHIFT + J", hl.dsp.exec_cmd("ydotool mousemove -x 0 -y +100"), { repeating = true })
	hl.bind("SHIFT + K", hl.dsp.exec_cmd("ydotool mousemove -x 0 -y -100"), { repeating = true })
	hl.bind("SHIFT + L", hl.dsp.exec_cmd("ydotool mousemove -x +100 -y 0"), { repeating = true })

	-- move closer
	hl.bind("CTRL + H", hl.dsp.exec_cmd("ydotool mousemove -x -1 -y 0"), { repeating = true })
	hl.bind("CTRL + J", hl.dsp.exec_cmd("ydotool mousemove -x 0 -y +1"), { repeating = true })
	hl.bind("CTRL + K", hl.dsp.exec_cmd("ydotool mousemove -x 0 -y -1"), { repeating = true })
	hl.bind("CTRL + L", hl.dsp.exec_cmd("ydotool mousemove -x +1 -y 0"), { repeating = true })

	-- Start a nested "SCROL" submap while holding tab.
	-- This works around scroll events "leaking" through key-based mods (e.g. ALT+J while
	-- scrolling behaves like scroll-while-holding-ALT rather than a clean scroll-down), by
	-- using a genuine submap switch instead of a modifier.
	hl.bind("TAB", hl.dsp.submap("SCROL"), { ignore_mods = true, transparent = true })

	hl.define_submap("SCROL", function()
		-- even with this workaround, these scrolling binds don't behave very well
		hl.bind("H", hl.dsp.exec_cmd("ydotool mousemove -w -- -1 0"), { repeating = true })
		hl.bind("J", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 -1"), { repeating = true })
		hl.bind("K", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 1"), { repeating = true })
		hl.bind("L", hl.dsp.exec_cmd("ydotool mousemove -w -- 1 0"), { repeating = true })

		hl.bind("D", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 -1000"), { repeating = true })
		hl.bind("U", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 1000"), { repeating = true })

		hl.bind("TAB", hl.dsp.submap("MOUSE"), { ignore_mods = true, release = true, transparent = true })

		-- mouse clicks
		-- to press with left hand
		hl.bind("A", hl.dsp.exec_cmd("ydotool click 40"))
		hl.bind("A", hl.dsp.exec_cmd("ydotool click 80"), { release = true, transparent = true })
		-- to press with right hand
		hl.bind("B", hl.dsp.exec_cmd("ydotool click 40"))
		hl.bind("B", hl.dsp.exec_cmd("ydotool click 80"), { release = true, transparent = true })
		-- to press with thumb, or reset submap automatically
		hl.bind(
			"SPACE",
			hl.dsp.exec_cmd("ydotool click C0 && ydotool mousemove -a 1920 0 && " .. hyprscripts .. "/submap-handling")
		)
		-- to toggle instead of having to hold
		hl.bind("V", hl.dsp.exec_cmd("ydotool click 40"))
		hl.bind("SHIFT + V", hl.dsp.exec_cmd("ydotool click 80"))
		-- right click
		hl.bind("D", hl.dsp.exec_cmd("ydotool click 41"))
		hl.bind("D", hl.dsp.exec_cmd("ydotool click 81"), { release = true, transparent = true })
		-- middle/scroll click
		hl.bind("S", hl.dsp.exec_cmd("ydotool click 42"))
		hl.bind("S", hl.dsp.exec_cmd("ydotool click 82"), { release = true, transparent = true })

		-- resetting the mouse-downs, in case you forget to mouse-up manually before switching submaps
		hl.bind("ESCAPE", hl.dsp.exec_cmd("ydotool click 80")) -- just in case you forget to mouse up
		hl.bind("O", hl.dsp.exec_cmd("ydotool click 80"))
		hl.bind("CTRL + SPACE", hl.dsp.exec_cmd("ydotool click 80"))

		hl.bind("ESCAPE", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling"))

		-- returns to the MOUSE submap (classic `submap = reset` inside a nested submap)
		hl.bind("Escape", hl.dsp.submap("MOUSE"))
	end)
end)

----- "PLCTL" submap: media player control
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling PLCTL"), { submap_universal = true })

hl.define_submap("PLCTL", function()
	hl.bind("H", hl.dsp.exec_cmd(hyprscripts .. "/plctl h"), { repeating = true })
	hl.bind("L", hl.dsp.exec_cmd(hyprscripts .. "/plctl l"), { repeating = true })
	hl.bind("J", hl.dsp.exec_cmd(hyprscripts .. "/plctl j"), { repeating = true })
	hl.bind("K", hl.dsp.exec_cmd(hyprscripts .. "/plctl k"), { repeating = true })

	hl.bind("F", hl.dsp.exec_cmd("pkill rofi || " .. hyprscripts .. "/plctl select")) -- list players
	hl.bind("TAB", hl.dsp.exec_cmd("pkill rofi || " .. hyprscripts .. "/plctl tab")) -- cycle to next player
	hl.bind("C", hl.dsp.exec_cmd(hyprscripts .. "/plctl clear && paplay " .. hyprscripts .. "/.pop-alert.mp3")) -- clear player selection

	hl.bind("SHIFT + L", hl.dsp.exec_cmd(hyprscripts .. "/plctl next"))
	hl.bind("SHIFT + H", hl.dsp.exec_cmd(hyprscripts .. "/plctl previous"))

	hl.bind("SPACE", hl.dsp.exec_cmd(hyprscripts .. "/plctl play-pause"))
	hl.bind(
		"SHIFT + SPACE",
		hl.dsp.exec_cmd(hyprscripts .. "/plctl play-pause & " .. hyprscripts .. "/submap-handling")
	)

	for i = 0, 9 do
		hl.bind(tostring(i), hl.dsp.exec_cmd(hyprscripts .. "/plctl " .. (i * 10) .. "%"))
	end

	-- returns to the global submap
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

----- "MVRSW" submap: move/resize-window
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling MVRSW"), { submap_universal = true })

hl.define_submap("MVRSW", function()
	hl.bind("H", hl.dsp.focus({ direction = "left" }), { repeating = true })
	hl.bind("J", hl.dsp.focus({ direction = "down" }), { repeating = true })
	hl.bind("K", hl.dsp.focus({ direction = "up" }), { repeating = true })
	hl.bind("L", hl.dsp.focus({ direction = "right" }), { repeating = true })

	hl.bind("Tab", hl.dsp.exec_cmd(hyprscripts .. "/cycle-float-tile"), { repeating = true }) -- change focus to another window

	hl.bind("C", hl.dsp.window.center())
	hl.bind("F", hl.dsp.window.float({ action = "toggle" }))
	hl.bind("M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
	hl.bind("CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

	hl.bind("S", hl.dsp.exec_cmd(hyprscripts .. "/swapwindow"))
	hl.bind("SHIFT + S", hl.dsp.exec_cmd(hyprscripts .. "/swapwindow & " .. hyprscripts .. "/submap-handling"))

	hl.bind("B", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw blur"))
	hl.bind("SHIFT + B", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw blur-all"))
	hl.bind("EQUAL", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw opacityp"), { repeating = true })
	hl.bind("MINUS", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw opacitym"), { repeating = true })

	-- move windows
	hl.bind("SHIFT + H", hl.dsp.window.move({ x = -25, y = 0, relative = true }), { repeating = true })
	hl.bind("SHIFT + J", hl.dsp.window.move({ x = 0, y = 25, relative = true }), { repeating = true })
	hl.bind("SHIFT + K", hl.dsp.window.move({ x = 0, y = -25, relative = true }), { repeating = true })
	hl.bind("SHIFT + L", hl.dsp.window.move({ x = 25, y = 0, relative = true }), { repeating = true })
	hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
	hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
	hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))

	-- resize windows
	hl.bind("CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
	hl.bind("CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })
	hl.bind("CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
	hl.bind("CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })

	-- hl.bind("1", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw "))

	-- move in same place (resize from one edge while moving to compensate)
	hl.bind("CTRL + SHIFT + H", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + H", hl.dsp.window.move({ x = 25, y = 0, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + J", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + J", hl.dsp.window.move({ x = 0, y = -25, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + K", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + K", hl.dsp.window.move({ x = 0, y = 25, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + L", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
	hl.bind("CTRL + SHIFT + L", hl.dsp.window.move({ x = -25, y = 0, relative = true }), { repeating = true })

	-- note: workspace 10 is bound to the "0" key, same as everywhere else in this config
	-- (the original file had a literal "10" here, which was never a valid key name)
	for i = 1, 10 do
		local key = (i == 10) and "0" or tostring(i)
		hl.bind(key, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
		hl.bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
	end

	-- returns to the global submap
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

----------------------------- DYNAMIC SUBMAP -----------------------------
hl.bind(
	"ALT_L",
	hl.dsp.exec_cmd(hyprscripts .. "/dynamic-submaps"),
	{ ignore_mods = true, transparent = true, non_consuming = true }
)

hl.define_submap("DYNAM", function()
	-- ydotool doesn't work well here (and neither does wlrctl, since it lacks arrow keys),
	-- so this uses the native sendshortcut dispatcher instead.
	hl.bind("ALT + H", hl.dsp.send_shortcut({ mods = "", key = "LEFT", window = "activewindow" }), { repeating = true })
	hl.bind("ALT + J", hl.dsp.send_shortcut({ mods = "", key = "DOWN", window = "activewindow" }), { repeating = true })
	hl.bind("ALT + K", hl.dsp.send_shortcut({ mods = "", key = "UP", window = "activewindow" }), { repeating = true })
	hl.bind(
		"ALT + L",
		hl.dsp.send_shortcut({ mods = "", key = "RIGHT", window = "activewindow" }),
		{ repeating = true }
	)

	hl.bind("ALT + W", function()
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "RIGHT", window = "activewindow" }))
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "RIGHT", window = "activewindow" }))
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "LEFT", window = "activewindow" }))
	end, { repeating = true })
	hl.bind(
		"ALT + B",
		hl.dsp.send_shortcut({ mods = "CTRL", key = "LEFT", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + E",
		hl.dsp.send_shortcut({ mods = "CTRL", key = "RIGHT", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + D",
		hl.dsp.send_shortcut({ mods = "CTRL", key = "Delete", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + X",
		hl.dsp.send_shortcut({ mods = "", key = "Delete", window = "activewindow" }),
		{ repeating = true }
	)

	hl.bind("ALT + 0", hl.dsp.send_shortcut({ mods = "", key = "Home", window = "activewindow" }), { repeating = true })
	hl.bind(
		"ALT + SHIFT + I",
		hl.dsp.send_shortcut({ mods = "", key = "Home", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + SHIFT + 4",
		hl.dsp.send_shortcut({ mods = "", key = "End", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + SHIFT + A",
		hl.dsp.send_shortcut({ mods = "", key = "End", window = "activewindow" }),
		{ repeating = true }
	)

	-- for switching tabs in a browser (Vimium doesn't work on protected pages)
	hl.bind(
		"ALT + SHIFT + J",
		hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Down", window = "activewindow" }),
		{ repeating = true }
	)
	hl.bind(
		"ALT + SHIFT + K",
		hl.dsp.send_shortcut({ mods = "CTRL", key = "Page_Up", window = "activewindow" }),
		{ repeating = true }
	)

	-- use "reset" to go back to the global submap
	hl.bind("ALT_L", hl.dsp.submap("reset"), { ignore_mods = true, release = true, transparent = true })
end)
