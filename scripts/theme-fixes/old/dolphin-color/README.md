# What is this

To have Dolphin theme working properly on Hyprland without the need to have KDE installed, you need to install `qt6ct-kde` instead of the vanilla `qt6ct`, and choose a `KColoScheme`.

The problem is that, even though this fixes most of Dolphin's theme problems, the selection color (like when you're selecting folders) doesn't pickup your accent color, and if you wanna change it you have to manually tweak the colorscheme config, which should be located in `/usr/share/color-schemes/<color scheme name>.colors`.

Then, after you have tweaked stuff, it will probably reset after a update, so here is a script to automate stuff that you can run after every update.
