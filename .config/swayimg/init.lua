--
-- Swayimg config converted from old INI format
--

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

swayimg.set_mode("viewer")
swayimg.enable_decoration(false)
swayimg.enable_overlay(false)
swayimg.enable_antialiasing(true)

-- EXIF orientation enabled by default usually
swayimg.enable_exif_orientation(true)

--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

swayimg.imagelist.set_order("alpha")
swayimg.imagelist.enable_reverse(false)
swayimg.imagelist.enable_recursive(false)
swayimg.imagelist.enable_adjacent(false)
swayimg.imagelist.enable_fsmon(true)

--------------------------------------------------------------------------------
-- Text / Font
--------------------------------------------------------------------------------

swayimg.text.set_font("JetBrainsMono Nerd Font")
swayimg.text.set_size(14)

-- old RGBA -> new ARGB format
swayimg.text.set_foreground(0xffcccccc)
swayimg.text.set_shadow(0xd0000000)
swayimg.text.set_background(0x00000000)

swayimg.text.set_padding(10)

-- old:
-- info_timeout = 0
-- status_timeout = 0

swayimg.text.set_timeout(0)
swayimg.text.set_status_timeout(0)

--------------------------------------------------------------------------------
-- Viewer mode
--------------------------------------------------------------------------------

swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_default_position("center")

swayimg.viewer.set_window_background(0x80000000)

-- transparency = grid
swayimg.viewer.set_image_chessboard(20, 0xff333333, 0xff4c4c4c)

swayimg.viewer.enable_loop(true)

swayimg.viewer.limit_history(1)
swayimg.viewer.limit_preload(1)

-- Info overlays
swayimg.viewer.set_text("topleft", {
	"{name}",
	"{format}",
	"{sizehr}",
	"{frame.width}x{frame.height}",
	"{meta.Exif.Image.Model}",
})

swayimg.viewer.set_text("topright", {
	"{list.index}/{list.total}",
})

swayimg.viewer.set_text("bottomleft", {
	"{scale}",
	"{frame.index}/{frame.total}",
})

swayimg.viewer.set_text("bottomright", {
	"{status}",
})

--------------------------------------------------------------------------------
-- Slideshow mode
--------------------------------------------------------------------------------

swayimg.slideshow.set_timeout(3)

swayimg.slideshow.set_default_scale("fit")
swayimg.slideshow.set_default_position("center")

swayimg.slideshow.set_window_background("auto")

swayimg.slideshow.set_text("bottomright", {
	"{dir}",
	"{status}",
})

--------------------------------------------------------------------------------
-- Gallery mode
--------------------------------------------------------------------------------

swayimg.gallery.set_thumb_size(200)

swayimg.gallery.limit_cache(100)
swayimg.gallery.enable_preload(false)
swayimg.gallery.enable_pstore(false)

-- fill = yes
swayimg.gallery.set_aspect("fill")

swayimg.gallery.set_window_color(0x80000000)

swayimg.gallery.set_unselected_color(0xff202020)
swayimg.gallery.set_selected_color(0xff404040)

swayimg.gallery.set_border_color(0xff000000)

-- Gallery text
swayimg.gallery.set_text("topright", {
	"{list.index}/{list.total}",
})

swayimg.gallery.set_text("bottomleft", {
	"{name}",
	"{status}",
})

--------------------------------------------------------------------------------
-- Viewer keybinds
--------------------------------------------------------------------------------

swayimg.viewer.on_key("h", function()
	swayimg.viewer.switch_image("prev")
end)

swayimg.viewer.on_key("l", function()
	swayimg.viewer.switch_image("next")
end)

swayimg.viewer.on_key("Space", function()
	swayimg.viewer.switch_image("next")
end)

swayimg.viewer.on_key("f", function()
	swayimg.toggle_fullscreen()
end)

swayimg.viewer.on_key("Return", function()
	swayimg.set_mode("gallery")
end)

swayimg.viewer.on_key("Escape", function()
	swayimg.exit()
end)

swayimg.viewer.on_key("q", function()
	swayimg.exit()
end)

-- zooming
swayimg.viewer.on_key("Equal", function()
	local scale = swayimg.viewer.get_scale()
	swayimg.viewer.set_abs_scale(scale * 1.1)
end)

swayimg.viewer.on_key("Minus", function()
	local scale = swayimg.viewer.get_scale()
	swayimg.viewer.set_abs_scale(scale / 1.1)
end)

-- fit/fill/real
swayimg.viewer.on_key("z", function()
	swayimg.viewer.set_fix_scale("fit")
end)

swayimg.viewer.on_key("Shift+z", function()
	swayimg.viewer.set_fix_scale("fill")
end)

swayimg.viewer.on_key("0", function()
	swayimg.viewer.set_fix_scale("real")
end)

-- Move zoomed image with Shift+h/j/k/l
local pan_amount = 100

swayimg.viewer.on_key("Shift+h", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x + pan_amount, pos.y)
end)

swayimg.viewer.on_key("Shift+l", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x - pan_amount, pos.y)
end)

swayimg.viewer.on_key("Shift+k", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x, pos.y + pan_amount)
end)

swayimg.viewer.on_key("Shift+j", function()
	local pos = swayimg.viewer.get_position()
	swayimg.viewer.set_abs_position(pos.x, pos.y - pan_amount)
end)

--------------------------------------------------------------------------------
-- Gallery keybinds
--------------------------------------------------------------------------------

swayimg.gallery.on_key("h", function()
	swayimg.gallery.switch_image("left")
end)

swayimg.gallery.on_key("l", function()
	swayimg.gallery.switch_image("right")
end)

swayimg.gallery.on_key("k", function()
	swayimg.gallery.switch_image("up")
end)

swayimg.gallery.on_key("j", function()
	swayimg.gallery.switch_image("down")
end)

swayimg.gallery.on_key("Return", function()
	swayimg.set_mode("viewer")
end)

swayimg.gallery.on_key("f", function()
	swayimg.toggle_fullscreen()
end)

swayimg.gallery.on_key("Escape", function()
	swayimg.exit()
end)

swayimg.gallery.on_key("q", function()
	swayimg.exit()
end)

--------------------------------------------------------------------------------
-- Delete file
--------------------------------------------------------------------------------

swayimg.viewer.on_key("Shift+Delete", function()
	local image = swayimg.viewer.get_image()

	os.execute('rm -f "' .. image.path .. '"')

	swayimg.text.set_status("File removed: " .. image.path)

	swayimg.viewer.switch_image("next")
end)

swayimg.gallery.on_key("Shift+Delete", function()
	local image = swayimg.gallery.get_image()

	os.execute('rm -f "' .. image.path .. '"')

	swayimg.text.set_status("File removed: " .. image.path)

	swayimg.gallery.switch_image("right")
end)
