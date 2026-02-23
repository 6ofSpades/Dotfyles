# Pre-requisites

You need asar installed to unpack Signal.

## On Arch:

`sudo pacman -S asar`

# Usage

**Run `./patch.sh`, that's it.**

It will extract Signal to a temporary location, apply the CSS theme in the folder and patch for transparency to work.

# Customizing

You can edit the `theme.css` before patching for customizing the theme.
You can also edit the tray icons and they will be patched too.

If you wanna do some debugging or understand which element to edit, you can close Signal then run it with:

```bash
signal-desktop --enable-dev-tools
```

Then you can press `Ctrl + Shift + I` to open the devtools in Signal.
