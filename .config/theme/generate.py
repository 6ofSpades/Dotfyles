#!/usr/bin/env python3

# Arch:
# sudo pacman -S python-yaml
# sudo pacman -S python-tomlkit

import re
from pathlib import Path

import tomlkit
import yaml

BASE_DIR = Path.home() / ".config" / "theme"
OUTPUT_DIR = BASE_DIR / "generated"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

RGBA_RE = re.compile(r"rgba\((.+?),\s*([0-9]*\.?[0-9]+)\)")
RGB_RE = re.compile(r"rgb\((.+?)\)")


# ============================================================
# Load theme
# ============================================================

with open(BASE_DIR / "colors.yaml") as f:
    theme = yaml.safe_load(f)


# ============================================================
# Theme resolver
# ============================================================


def find_reference(name, data):
    """Search recursively for a key in the theme."""

    if not isinstance(data, dict):
        return None

    if name in data:
        return data[name]

    for value in data.values():
        if isinstance(value, dict):
            found = find_reference(name, value)
            if found is not None:
                return found

    return None


def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("#")

    return (
        int(hex_color[0:2], 16),
        int(hex_color[2:4], 16),
        int(hex_color[4:6], 16),
    )


def resolve(value):
    if value is None:
        return None

    if not isinstance(value, str):
        return value

    value = value.strip()

    #
    # literal color
    #

    if value.startswith("#"):
        return value

    #
    # rgba(...)
    #

    m = RGBA_RE.fullmatch(value)

    if m:
        color_name = m.group(1).strip()
        alpha = m.group(2)

        r, g, b = hex_to_rgb(resolve(color_name))

        return f"rgba({r},{g},{b},{alpha})"

    #
    # rgb(...)
    #

    m = RGB_RE.fullmatch(value)

    if m:
        color_name = m.group(1).strip()

        r, g, b = hex_to_rgb(resolve(color_name))

        return f"rgb({r},{g},{b})"

    #
    # reference
    #

    reference = find_reference(value, theme)

    if reference is not None:
        return resolve(reference)

    raise ValueError(f"Unknown theme value: {value}")


def resolve_dict(data):
    """Resolve an entire nested dictionary."""

    result = {}

    for key, value in data.items():
        if isinstance(value, dict):
            result[key] = resolve_dict(value)
        else:
            result[key] = resolve(value)

    return result


resolved_theme = resolve_dict(theme)

colors = resolved_theme["colors"]
ui = resolved_theme["ui"]
kitty = resolved_theme["kitty"]
hyprland = resolved_theme["hyprland"]
rofi = resolved_theme["rofi"]
mpv = resolved_theme["mpv"]
zathura = resolved_theme["zathura"]
dunst = resolved_theme["dunst"]
flameshot = resolved_theme["flameshot"]
btop = resolved_theme["btop"]
yazi = resolved_theme["yazi"]
traytui = resolved_theme["traytui"]


# ============================================================
# Utility functions
# ============================================================


def write_file(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)

    with open(path, "w") as f:
        f.write(content)

    print(f"Generated: {path}")


def lua_table(data, indent=0):
    lines = ["{"]

    for key, value in data.items():
        padding = " " * (indent + 4)

        if isinstance(value, dict):
            lines.append(f"{padding}{key} = {lua_table(value, indent + 4)},")
        else:
            lines.append(f'{padding}{key} = "{value}",')

    lines.append(" " * indent + "}")

    return "\n".join(lines)


# ============================================================
# Kitty
# ============================================================


def generate_kitty():
    kitty_config = f"""
foreground {colors["fg"]}
background {colors["bg"]}

cursor {ui["cursor"]}
cursor_text_color {ui["cursor_text_color"]}

selection_foreground {ui["selection_fg"]}
selection_background {ui["selection_bg"]}

color0 {colors["black"]}
color1 {colors["red"]}
color2 {colors["green"]}
color3 {colors["yellow"]}
color4 {colors["blue"]}
color5 {colors["magenta"]}
color6 {colors["cyan"]}
color7 {colors["white"]}

color8 {colors["black_bright"]}
color9 {colors["red_bright"]}
color10 {colors["green_bright"]}
color11 {colors["yellow_bright"]}
color12 {colors["blue_bright"]}
color13 {colors["magenta_bright"]}
color14 {colors["cyan_bright"]}
color15 {colors["white_bright"]}

transparent_background_colors {kitty["kitty_transparent"]}

active_tab_foreground   {kitty["active_tab_fg"]}
active_tab_background   {kitty["active_tab_bg"]}
inactive_tab_foreground {kitty["inactive_tab_fg"]}
inactive_tab_background {kitty["inactive_tab_bg"]}
""".strip()

    write_file(
        OUTPUT_DIR / "kitty.conf",
        kitty_config,
    )


# ============================================================
# Neovim
# ============================================================


def generate_nvim():
    nvim_theme = {
        "colors": colors,
        "ui": ui,
    }

    lua_content = "return " + lua_table(nvim_theme)

    write_file(
        OUTPUT_DIR / "theme.lua",
        lua_content,
    )


# ============================================================
# Hyprland
# ============================================================


def generate_hyprland():
    hypr_config = f"""
$border = rgb({hyprland["border"].replace("#", "")})
$border_pin = rgb({hyprland["border_pin"].replace("#", "")})
$border_maximized = rgb({hyprland["border_maximized"].replace("#", "")})
""".strip()

    write_file(
        OUTPUT_DIR / "hyprland.conf",
        hypr_config,
    )


# ============================================================
# Waybar / CSS
# ============================================================


def generate_gtk_css():
    lines = []

    for section in (colors, ui):
        for key, value in section.items():
            if value is None:
                continue

            lines.append(f"@define-color {key} {value};")

    write_file(
        OUTPUT_DIR / "colors-gtk.css",
        "\n".join(lines),
    )


def generate_web_css():
    lines = [":root {"]

    for key, value in colors.items():
        if value is None:
            continue

        lines.append(f"    --{key}: {value};")

    for key, value in ui.items():
        if value is None:
            continue

        lines.append(f"    --{key}: {value};")

    lines.append("}")

    write_file(
        OUTPUT_DIR / "colors-web.css",
        "\n".join(lines),
    )


# ============================================================
# Rofi
# ============================================================


def generate_rasi():
    lines = ["* {"]

    for key, value in colors.items():
        if value is None:
            continue
        # cause .rasi doesn't like "_", only "-"
        if "_" in key:
            key = key.replace("_", "-")

        value = hex_to_rgb(value)
        lines.append(f"    {key}: rgb{value};")

    for key, value in ui.items():
        if value is None:
            continue
        if "_" in key:
            key = key.replace("_", "-")

        value = hex_to_rgb(value)
        lines.append(f"    {key}: rgb{value};")

    for key, value in rofi.items():
        if value is None:
            continue

        lines.append(f"    {key}: {value};")

    lines.append("}")

    write_file(
        OUTPUT_DIR / "colors.rasi",
        "\n".join(lines),
    )


# ============================================================
# Dunst
# ============================================================


def generate_dunst():
    dunstcolors = f"""
[global]
    frame_color = "{dunst["frame_color"]}"

[urgency_low]
    # IMPORTANT: colors have to be defined in quotation marks.
    # Otherwise the "#" and following would be interpreted as a comment.
    background = "{dunst["urgency_low.background"]}"
    foreground = "{dunst["urgency_low.foreground"]}"
    highlight =  "{dunst["urgency_low.highlight"]}"
    timeout = 10
    # Icon for notifications with low urgency
    default_icon = dialog-information

[urgency_normal]
    background = "{dunst["urgency_normal.background"]}"
    foreground = "{dunst["urgency_normal.foreground"]}"
    highlight = "{dunst["urgency_normal.highlight"]}"
    timeout = 10
    override_pause_level = 30
    # Icon for notifications with normal urgency
    default_icon = dialog-information

[urgency_critical]
    background = "{dunst["urgency_critical.background"]}"
    foreground = "{dunst["urgency_critical.foreground"]}"
    highlight = "{dunst["urgency_critical.highlight"]}"
    frame_color = "{dunst["urgency_critical.frame_color"]}"
    timeout = 0
    override_pause_level = 60
    # Icon for notifications with critical urgency
    default_icon = dialog-warning
""".strip()

    write_file(
        OUTPUT_DIR / "01-dunstcolors.conf",
        dunstcolors,
    )


# ============================================================
# MPV / ModernZ
# ============================================================


def patch_config(
    source,
    output,
    replacements,
    prefix="",
    separator="=",
):
    with open(source) as f:
        lines = f.readlines()

    new_lines = []

    for line in lines:

        stripped = line.strip()

        #
        # Preserve comments and empty lines
        #

        if not stripped or stripped.startswith("#"):
            new_lines.append(line)
            continue

        if not stripped.startswith(prefix):
            new_lines.append(line)
            continue

        body = stripped[len(prefix) :]

        if separator not in body:
            new_lines.append(line)
            continue

        key, _ = body.split(separator, 1)

        key = key.strip()

        if key not in replacements:
            new_lines.append(line)
            continue

        value = replacements[key]

        #
        # None = don't touch
        #

        if value is None:
            new_lines.append(line)
            continue

        new_lines.append(f"{prefix}{key}{separator}{value}\n")

    write_file(output, "".join(new_lines))


def patch_toml_file(source, output, replacements):
    with open(source) as f:
        doc = tomlkit.parse(f.read())

    for path, value in replacements.items():

        if value is None:
            continue

        parts = path.split(".")

        obj = doc

        for part in parts[:-1]:
            obj = obj[part]

        obj[parts[-1]] = value

    write_file(output, tomlkit.dumps(doc))


def generate_mpv():
    patch_config(
        BASE_DIR / "templates" / "modernz.conf",
        OUTPUT_DIR / "modernz.conf",
        mpv,
    )


def generate_zathura():
    patch_config(
        BASE_DIR / "templates" / "zathurarc",
        OUTPUT_DIR / "zathurarc",
        zathura,
        prefix="set ",
        separator=" ",
    )


def generate_flameshot():
    patch_config(
        BASE_DIR / "templates" / "flameshot.ini",
        OUTPUT_DIR / "flameshot.ini",
        flameshot,
    )


def generate_btop():
    patch_config(
        BASE_DIR / "templates" / "btop.theme",
        OUTPUT_DIR / "btop.theme",
        btop,
        separator="=",
    )


def generate_yazi():
    patch_toml_file(
        BASE_DIR / "templates" / "theme.toml",
        OUTPUT_DIR / "theme.toml",
        yazi,
    )


def generate_traytui():
    patch_toml_file(
        BASE_DIR / "templates" / "config.toml",
        OUTPUT_DIR / "config.toml",
        traytui,
    )


# ============================================================
# Main
# ============================================================


def main():
    generate_kitty()
    generate_nvim()
    generate_hyprland()
    generate_gtk_css()
    generate_web_css()
    generate_mpv()
    generate_zathura()
    generate_dunst()
    generate_flameshot()
    generate_rasi()
    generate_btop()
    generate_yazi()
    generate_traytui()


if __name__ == "__main__":
    main()
