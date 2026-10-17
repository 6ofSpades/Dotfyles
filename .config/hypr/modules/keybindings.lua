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
local fileManager = terminal .. " yazi"
local hyprscripts = os.getenv("HOME") .. "/.config/hypr/scripts"

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more

-- wlogout
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("pkill wlogout || wlogout -b 4"))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal .. " --class kitty-float"), { submap_universal = true })
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
	{ submap_universal = true, locked = true }
)
hl.bind(
	mainMod .. " + F11",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset gamma -10 && notify-send -a Hyprsunset "Gamma:" "$(hyprctl hyprsunset gamma)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true, locked = true }
)
hl.bind(
	mainMod .. " + SHIFT + F12",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset temperature +100 && notify-send -a Hyprsunset "Temperature:" "$(hyprctl hyprsunset temperature)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true, locked = true }
)
hl.bind(
	mainMod .. " + SHIFT + F11",
	hl.dsp.exec_cmd(
		'hyprctl hyprsunset temperature -100 && notify-send -a Hyprsunset "Temperature:" "$(hyprctl hyprsunset temperature)" -t 2000 -i text-x-script -u low -r 2427'
	),
	{ submap_universal = true, locked = true }
)
hl.bind(
	mainMod .. " + F10",
	hl.dsp.exec_cmd("killall hyprsunset & sleep 0.2 && hyprsunset"),
	{ submap_universal = true, locked = true }
) -- reset hyprsunset

hl.bind(
	mainMod .. " + F8",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null"),
	{ submap_universal = true, locked = true }
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
end, { allow_input_capture = true, dont_inhibit = true })
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
hl.bind(mainMod .. " + D", hl.dsp.window.close(), { submap_universal = true })
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.window.kill(), { submap_universal = true }) -- for when a window is not responding

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

-- Group windows
hl.bind(mainMod .. " + ALT + L", hl.dsp.group.next())
hl.bind(mainMod .. " + ALT + H", hl.dsp.group.prev())

hl.bind(mainMod .. " + G", hl.dsp.submap("GROUP"))
hl.define_submap("GROUP", function()
	hl.bind("G", hl.dsp.group.toggle(), { ignore_mods = true })
	hl.bind("G", hl.dsp.submap("reset"), { ignore_mods = true })

	hl.bind("ALT + L", hl.dsp.group.next())
	hl.bind("ALT + H", hl.dsp.group.prev())

	hl.bind("SHIFT + H", hl.dsp.window.move({ direction = "left", group_aware = true }))
	hl.bind("SHIFT + L", hl.dsp.window.move({ direction = "right", group_aware = true }))
	hl.bind("SHIFT + K", hl.dsp.window.move({ direction = "up", group_aware = true }))
	hl.bind("SHIFT + J", hl.dsp.window.move({ direction = "down", group_aware = true }))

	hl.bind("SHIFT + H", hl.dsp.submap("reset"))
	hl.bind("SHIFT + L", hl.dsp.submap("reset"))
	hl.bind("SHIFT + K", hl.dsp.submap("reset"))
	hl.bind("SHIFT + J", hl.dsp.submap("reset"))

	hl.bind("L", hl.dsp.group.lock_active())
	hl.bind("L", hl.dsp.submap("reset"))

	-- returns to the global submap
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

-- Rofi
hl.bind(
	"ALT + SPACE",
	hl.dsp.exec_cmd("pkill rofi || rofi -show drun -icon-theme candy-icons"),
	{ submap_universal = true }
)
hl.bind("ALT + CTRL + TAB", hl.dsp.exec_cmd("pkill rofi || rofi -show window"), { submap_universal = true })
hl.bind(
	mainMod .. " + EQUAL",
	hl.dsp.exec_cmd(
		'pkill rofi || rofi -rofi-qalc ./build -show "qalc" -automatic-save-to-history -history-length 7 -no-sort'
	)
)
hl.bind(
	mainMod .. " + V",
	hl.dsp.exec_cmd(
		"pkill clipse || "
			.. hyprscripts
			.. '/open-and-focus "kitty -1 --instance-group=tui --class clipse clipse" "clipse"'
	)
)
hl.bind(
	mainMod .. " + W",
	hl.dsp.exec_cmd("pkill rofi || nice -n 19 ionice -c 3 " .. os.getenv("HOME") .. "/.config/hypr/scripts/wp-selector")
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

-- resize window to percentage of monitor
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 10"))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 20"))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 30"))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 40"))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 50"))
hl.bind(mainMod .. " + CTRL + 6", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 60"))
hl.bind(mainMod .. " + CTRL + 7", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 70"))
hl.bind(mainMod .. " + CTRL + 8", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 80"))
hl.bind(mainMod .. " + CTRL + 9", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 90"))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 100"))

-- Switch workspaces with mainMod + [0-9]
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
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5%+"),
	{ repeating = true, locked = true, submap_universal = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5%-"),
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

-- change repeat delay and rate when entering the MOUSE submap
-- and then change back when exiting
local current_delay = hl.get_config("input.repeat_delay")
local current_rate = hl.get_config("input.repeat_rate")
hl.on("keybinds.submap", function(submap_name)
	if submap_name == "MOUSE" then
		-- Switched INTO the MOUSE submap: speed things up
		hl.config({
			input = {
				repeat_delay = 100,
				repeat_rate = 40,
			},
		})
	elseif submap_name == "" then
		-- Returned to the default/normal state: restore regular speed
		hl.config({
			input = {
				repeat_delay = current_delay,
				repeat_rate = current_rate,
			},
		})
	end
end)

hl.define_submap("MOUSE", function()
	-- reset submap, call wl-kbptr, then enable MOUSE submap again
	-- f as in find
	hl.bind("F", function()
		hl.dispatch(hl.dsp.submap("reset"))
		hl.dispatch(
			hl.dsp.exec_cmd(
				"wl-kbptr && hyprctl dispatch \"hl.dsp.submap('MOUSE')\" && ydotool mousemove -x -1 -y 0 && ydotool mousemove -x +1 -y 0 "
			)
		)
	end, { ignore_mods = true })

	-- g as in go-to
	hl.bind("G", function()
		hl.dispatch(hl.dsp.submap("reset"))
		hl.dispatch(
			hl.dsp.exec_cmd(
				"wl-kbptr -o modes=tile && hyprctl dispatch \"hl.dsp.submap('MOUSE')\" && ydotool mousemove -x -1 -y 0 && ydotool mousemove -x +1 -y 0 "
			)
		)
	end, { ignore_mods = true })
	-- the trailing mouse-move nudge works around wl-kbptr's mousemove being a bit buggy

	-- move mouse
	hl.bind(
		"H",
		hl.dsp.exec_cmd("ydotool mousemove -x -10 -y 0"),
		{ ignore_mods = false, repeating = true, transparent = true }
	)
	hl.bind(
		"J",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y +10"),
		{ ignore_mods = false, repeating = true, transparent = true }
	)
	hl.bind(
		"K",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y -10"),
		{ ignore_mods = false, repeating = true, transparent = true }
	)
	hl.bind(
		"L",
		hl.dsp.exec_cmd("ydotool mousemove -x +10 -y 0"),
		{ ignore_mods = false, repeating = true, transparent = true }
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
	hl.bind(
		"SHIFT + H",
		hl.dsp.exec_cmd("ydotool mousemove -x -100 -y 0"),
		{ repeating = true, non_consuming = false, ignore_mods = false }
	)
	hl.bind(
		"SHIFT + J",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y +100"),
		{ repeating = true, non_consuming = false, ignore_mods = false }
	)
	hl.bind(
		"SHIFT + K",
		hl.dsp.exec_cmd("ydotool mousemove -x 0 -y -100"),
		{ repeating = true, non_consuming = false, ignore_mods = false }
	)
	hl.bind(
		"SHIFT + L",
		hl.dsp.exec_cmd("ydotool mousemove -x +100 -y 0"),
		{ repeating = true, non_consuming = false, ignore_mods = false }
	)

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
	hl.bind("TAB", hl.dsp.submap("MOUSE"), { ignore_mods = true, release = true, transparent = true })

	hl.define_submap("SCROL", function()
		-- even with this workaround, these scrolling binds don't behave very well
		hl.bind("H", hl.dsp.exec_cmd("ydotool mousemove -w -- -1 0"), { repeating = true })
		hl.bind("J", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 -1"), { repeating = true })
		hl.bind("K", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 1"), { repeating = true })
		hl.bind("L", hl.dsp.exec_cmd("ydotool mousemove -w -- 1 0"), { repeating = true })

		hl.bind("D", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 -1000"), { repeating = true })
		hl.bind("U", hl.dsp.exec_cmd("ydotool mousemove -w -- 0 1000"), { repeating = true })

		hl.bind("TAB", hl.dsp.submap("MOUSE"), { ignore_mods = true, release = true, transparent = true })
	end)

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
end)

----- "PLCTL" submap: media player control
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling PLCTL"), { submap_universal = true })

hl.on("keybinds.submap", function(submap_name)
	if submap_name == "PLCTL" then
		-- show which player selected when changing into the submap
		hl.exec_cmd(hyprscripts .. "/plctl which")
	end
end)

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
	hl.bind("ESCAPE", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling"))
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

	-- resize window to percentage of monitor
	hl.bind("CTRL + 1", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 10"))
	hl.bind("CTRL + 2", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 20"))
	hl.bind("CTRL + 3", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 30"))
	hl.bind("CTRL + 4", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 40"))
	hl.bind("CTRL + 5", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 50"))
	hl.bind("CTRL + 6", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 60"))
	hl.bind("CTRL + 7", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 70"))
	hl.bind("CTRL + 8", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 80"))
	hl.bind("CTRL + 9", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 90"))
	hl.bind("CTRL + 0", hl.dsp.exec_cmd(hyprscripts .. "/mvrsw resize-percent 100"))

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
	hl.bind("ESCAPE", hl.dsp.exec_cmd(hyprscripts .. "/submap-handling"))
end)

-- obs shortcuts
hl.bind(mainMod .. " + R", hl.dsp.submap("OBS-R"))
hl.define_submap("OBS-R", function()
	hl.bind("SPACE", hl.dsp.exec_cmd("obs-cmd recording toggle"), { ignore_mods = true })
	hl.bind("SPACE", hl.dsp.submap("reset"), { ignore_mods = true })

	hl.bind("P", hl.dsp.exec_cmd("obs-cmd recording toggle-pause"), { ignore_mods = true })
	hl.bind("P", hl.dsp.submap("reset"), { ignore_mods = true })

	-- returns to the global submap
	hl.bind("Escape", hl.dsp.submap("reset"))
end)

----------------------------- DYNAMIC BINDS -----------------------------
local dynamic_classes = {
	zen = true,
	vesktop = true,
	["discord-canary"] = true,
	["Mullvad Browser"] = true,
	["brave-browser"] = true,
	steam = true,
	firefox = true,
}

local dynamic_bindings = {
	"ALT + H",
	"ALT + J",
	"ALT + K",
	"ALT + L",

	"ALT + W",
	"ALT + B",
	"ALT + E",
	"ALT + D",
	"ALT + X",

	"ALT + 0",
	"ALT + I",
	"ALT + SHIFT + 4",
	"ALT + A",

	"ALT + SHIFT + J",
	"ALT + SHIFT + K",
}

local function unbind_dynamic()
	for _, key in ipairs(dynamic_bindings) do
		hl.unbind(key)
	end
end

local function bind_dynamic()
	-- Vim-style cursor movement
	hl.bind("ALT + H", hl.dsp.send_shortcut({ mods = "", key = "LEFT", window = "activewindow" }), { repeating = true })

	hl.bind("ALT + J", hl.dsp.send_shortcut({ mods = "", key = "DOWN", window = "activewindow" }), { repeating = true })

	hl.bind("ALT + K", hl.dsp.send_shortcut({ mods = "", key = "UP", window = "activewindow" }), { repeating = true })

	hl.bind(
		"ALT + L",
		hl.dsp.send_shortcut({ mods = "", key = "RIGHT", window = "activewindow" }),
		{ repeating = true }
	)

	-- Word movement
	hl.bind("ALT + W", function()
		hl.dispatch(hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "RIGHT",
			window = "activewindow",
		}))
		hl.dispatch(hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "RIGHT",
			window = "activewindow",
		}))
		hl.dispatch(hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "LEFT",
			window = "activewindow",
		}))
	end, { repeating = true })

	hl.bind(
		"ALT + B",
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "LEFT",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + E",
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "RIGHT",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + D",
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "Delete",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + X",
		hl.dsp.send_shortcut({
			mods = "",
			key = "Delete",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	-- Beginning / end of line
	hl.bind(
		"ALT + 0",
		hl.dsp.send_shortcut({
			mods = "",
			key = "Home",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + I",
		hl.dsp.send_shortcut({
			mods = "",
			key = "Home",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + SHIFT + 4",
		hl.dsp.send_shortcut({
			mods = "",
			key = "End",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + A",
		hl.dsp.send_shortcut({
			mods = "",
			key = "End",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	-- Browser tabs
	hl.bind(
		"ALT + SHIFT + J",
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "Page_Down",
			window = "activewindow",
		}),
		{ repeating = true }
	)

	hl.bind(
		"ALT + SHIFT + K",
		hl.dsp.send_shortcut({
			mods = "CTRL",
			key = "Page_Up",
			window = "activewindow",
		}),
		{ repeating = true }
	)
end

local function update_dynamic_binds(window)
	-- Always remove the previous set first.
	unbind_dynamic()

	-- Only install the binds for our special applications.
	if window ~= nil and dynamic_classes[window.class] then
		bind_dynamic()
	end
end

-- Update whenever the active window changes.
hl.on("window.active", function(window)
	update_dynamic_binds(window)
end)

-- Set the correct state when the Lua config is initially loaded.
update_dynamic_binds(hl.get_active_window())

----------------------------- DYNAMIC ALT INDICATOR -----------------------------
local hypr_theme = os.getenv("HOME") .. "/.config/theme/generated/hyprland.lua"
local hypr_theme = require(hypr_theme)

local alt_down = false
local alt_indicator_active = false

local function dynamic_context_active()
	local window = hl.get_active_window()

	if window == nil then
		return false
	end

	return dynamic_classes[window.class] == true
end

local function set_alt_indicator(active)
	if active == alt_indicator_active then
		return
	end

	alt_indicator_active = active

	if active then
		hl.config({
			general = {
				col = {
					active_border = {
						colors = { hypr_theme.colors.border_alt },
					},
				},
			},
		})
		hl.window_rule({ match = { fullscreen = true }, border_color = hypr_theme.colors.border_alt })
		hl.window_rule({ match = { pin = true }, border_color = hypr_theme.colors.border_alt })
	else
		hl.config({
			general = {
				col = {
					active_border = {
						colors = { hypr_theme.colors.border, hypr_theme.colors.border_animation },
						angle = 45,
					},
				},
			},
		})
		hl.window_rule({ match = { fullscreen = true }, border_color = hypr_theme.colors.border_maximized })
		hl.window_rule({ match = { pin = true }, border_color = hypr_theme.colors.border_pin })
	end
end

-- Alt pressed.
-- transparent = true is important here: it allows Alt to continue
-- behaving normally while we use the bind only as an indicator.
hl.bind("ALT_L", function()
	if dynamic_context_active() then
		set_alt_indicator(true)
	end
end, { transparent = true })

-- Alt released.
-- The modifier is included in the bind so Hyprland recognizes this
-- as the release of the Alt modifier itself.
hl.bind("ALT + ALT_L", function()
	set_alt_indicator(false)
end, {
	release = true,
	transparent = true,
	ignore_mods = true,
})

-- If the focused window changes while Alt is held, update the
-- indicator to match the new context.
hl.on("window.active", function()
	if alt_down then
		set_alt_indicator(dynamic_context_active())
	else
		set_alt_indicator(false)
	end
end)
