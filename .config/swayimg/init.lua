--
-- Swayimg config converted from old INI format
--

--------------------------------------------------------------------------------
-- General
--------------------------------------------------------------------------------

swayimg.mode = "viewer"
swayimg.decoration = true
swayimg.overlay = false
swayimg.antialiasing = true

-- EXIF orientation enabled by default usually
swayimg.exif_orientation = true

--------------------------------------------------------------------------------
-- Image list
--------------------------------------------------------------------------------

swayimg.imagelist.order = "alpha"
swayimg.imagelist.reverse = false
swayimg.imagelist.recursive = false
swayimg.imagelist.adjacent = false
swayimg.imagelist.fsmon = true

--------------------------------------------------------------------------------
-- Text / Font
--------------------------------------------------------------------------------

swayimg.text.font = "JetBrainsMono Nerd Font"
swayimg.text.size = 14

-- old RGBA -> new ARGB format
swayimg.text.color = 0xffcccccc
swayimg.text.shadow = 0x80000000
swayimg.text.background = 0x00000000

swayimg.text.padding = 10

-- old:
-- info_timeout = 0
-- status_timeout = 0

swayimg.text.timeout = 0
swayimg.text.status_timeout = 0

--------------------------------------------------------------------------------
-- Viewer mode
--------------------------------------------------------------------------------

swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"

swayimg.viewer.set_window_background(0x80000000)

-- transparency = grid
swayimg.viewer.set_image_chessboard(20, 0x99333333, 0x994c4c4c)

swayimg.viewer.loop = true

swayimg.viewer.history = 1
swayimg.viewer.preload = 1

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

swayimg.slideshow.timeout = 3

swayimg.slideshow.default_scale = "fit"
swayimg.slideshow.default_position = "center"

swayimg.slideshow.set_window_background("auto")

swayimg.slideshow.set_text("bottomright", {
	"{dir}",
	"{status}",
})

--------------------------------------------------------------------------------
-- Gallery mode
--------------------------------------------------------------------------------

swayimg.gallery.thumb_size = 200

swayimg.gallery.cache = 100
swayimg.gallery.preload = false
swayimg.gallery.pstore = false

-- fill = yes
swayimg.gallery.aspect = "fill"

swayimg.gallery.window_color = 0x80000000

-- background color of images with transparent background
-- on gallery mode
swayimg.gallery.unselected_color = 0x99000000
swayimg.gallery.selected_color = 0xb2000000

swayimg.gallery.border_color = 0xffffffff

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
	swayimg.viewer.open("prev")
end)

swayimg.viewer.on_key("l", function()
	swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("Space", function()
	swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("f", function()
	swayimg.fullscreen = not swayimg.fullscreen
end)

swayimg.viewer.on_key("i", function()
	swayimg.text.visible = not swayimg.text.visible
end)

swayimg.viewer.on_key("Return", function()
	swayimg.mode = "gallery"
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
	swayimg.gallery.select("left")
end)

swayimg.gallery.on_key("l", function()
	swayimg.gallery.select("right")
end)

swayimg.gallery.on_key("k", function()
	swayimg.gallery.select("up")
end)

swayimg.gallery.on_key("j", function()
	swayimg.gallery.select("down")
end)

swayimg.gallery.on_key("Return", function()
	swayimg.mode = "viewer"
end)

swayimg.gallery.on_key("f", function()
	swayimg.fullscreen = not swayimg.fullscreen
end)

swayimg.gallery.on_key("i", function()
	swayimg.text.visible = not swayimg.text.visible
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

	swayimg.viewer.open("next")
end)

swayimg.gallery.on_key("Shift+Delete", function()
	local image = swayimg.gallery.get_image()

	os.execute('rm -f "' .. image.path .. '"')

	swayimg.text.set_status("File removed: " .. image.path)

	swayimg.gallery.select("right")
end)
