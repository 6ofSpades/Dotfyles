#!/usr/bin/env python3

# Arch:
# sudo pacman -S python-yaml
# sudo pacman -S python-tomlkit
# sudo pacman -S python-json5

import json
import re
import subprocess
from pathlib import Path
from sys import prefix

import json5
import tomlkit
import yaml

BASE_DIR = Path.home() / ".config"
OUTPUT_DIR = BASE_DIR / "theme" / "generated"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

RGBA_RE = re.compile(r"rgba\((.+?),\s*([0-9]*\.?[0-9]+)\)")
RGB_RE = re.compile(r"rgb\((.+?)\)")


# ============================================================
# Load theme
# ============================================================

with open(BASE_DIR / "theme" / "colors.yaml") as f:
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

    ALPHA_RE = re.compile(r"^(.+)\+([0-9a-fA-F]{2})$")

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
    # color+alpha
    #

    m = ALPHA_RE.fullmatch(value)

    if m:
        color_name = m.group(1).strip()
        alpha = m.group(2)

        color = resolve(color_name)

        if not color.startswith("#"):
            raise ValueError(f"Cannot add alpha to non-hex color: {color}")

        return f"{color}{alpha}"

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
    # Scoped reference
    #

    if value.startswith("$"):
        path = value[1:].split(".")

        obj = theme

        for part in path:
            if not isinstance(obj, dict) or part not in obj:
                raise ValueError(f"Unknown theme path: {value}")

            obj = obj[part]

        return resolve(obj)

    #
    # normal reference
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
nvim = resolved_theme["nvim"]
kitty = resolved_theme["kitty"]
git = resolved_theme["git"]
hyprland = resolved_theme["hyprland"]
waybar = resolved_theme["waybar"]
rofi = resolved_theme["rofi"]
mpv = resolved_theme["mpv"]
zathura = resolved_theme["zathura"]
dunst = resolved_theme["dunst"]
flameshot = resolved_theme["flameshot"]
btop = resolved_theme["btop"]
yazi = resolved_theme["yazi"]
traytui = resolved_theme["traytui"]
clipse = resolved_theme["clipse"]
wiremix = resolved_theme["wiremix"]
surge = resolved_theme["surge"]
pytab = resolved_theme["pytab"]
pyhist = resolved_theme["pyhist"]
pear_desktop = resolved_theme["pear_desktop"]
wlkbptr = resolved_theme["wlkbptr"]
wvkbd = resolved_theme["wvkbd"]
fzf = resolved_theme["fzf"]
tlrc = resolved_theme["tlrc"]
gdu = resolved_theme["gdu"]
fastfetch = resolved_theme["fastfetch"]
wlogout = resolved_theme["wlogout"]


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

background_opacity {kitty["background_opacity"]}

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

transparent_background_colors {kitty["transparent1"]}@{kitty["transparent1o"]} {kitty["transparent2"]}@{kitty["transparent2o"]} {kitty["transparent3"]}@{kitty["transparent3o"]}

active_tab_foreground   {kitty["active_tab_fg"]}
active_tab_background   {kitty["active_tab_bg"]}
inactive_tab_foreground {kitty["inactive_tab_fg"]}
inactive_tab_background {kitty["inactive_tab_bg"]}

active_border_color {kitty["active_border_color"]}
inactive_border_color {kitty["inactive_border_color"]}
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
        "nvim": nvim,
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
    lines = []

    for section in (colors, ui, hyprland):
        for key, value in section.items():
            # value = resolve(value)

            # None = don't generate anything
            if value is None:
                continue

            if value.startswith("#"):
                value = f"rgb({value[1:]})"

            lines.append(f"${key} = {value}")

    write_file(
        OUTPUT_DIR / "hyprland.conf",
        "\n".join(lines) + "\n",
    )


def generate_hyprland_lua():
    hypr_config = {
        "colors": hyprland,
    }

    lua_content = "return " + lua_table(hypr_config)

    write_file(
        OUTPUT_DIR / "hyprland.lua",
        lua_content,
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

        # putting "theme" before the key so it doesn't conflict with any web pages
        lines.append(f"    --theme{key}: {value} !important;")

    for key, value in ui.items():
        if value is None:
            continue

        lines.append(f"    --theme{key}: {value} !important;")

    lines.append("}")

    write_file(
        OUTPUT_DIR / "colors-web.css",
        "\n".join(lines),
    )


def generate_waybar():
    lines = []

    for section in (waybar,):
        for key, value in section.items():
            if value is None:
                continue

            lines.append(f"@define-color {key} {value};")

    write_file(
        BASE_DIR / "waybar" / "themes" / "waybar.css",
        "\n".join(lines),
    )


# Pear-desktop / Youtube music CSS
def generate_peardesktop():
    file = f"""
/* make backgrounds fully black */
body {{
  background-color: {pear_desktop["background-color"]} !important;
}}
ytmusic-player-bar {{
  background-color: {pear_desktop["background-color"]} !important;
}}
/* transparent background color when using the transparency plugin */
:root {{
  --ytmd-transparent-player-transparency-color: {pear_desktop["background-color"]} !important;
}}

/* progress bar color */
#progress-bar.ytmusic-player-bar {{
  --paper-slider-active-color: linear-gradient(
    90deg,
    {pear_desktop["progress-bar-1"]} 80%,
    {pear_desktop["progress-bar-2"]}
  ) !important;
}}
/* knob color */
#progress-bar.ytmusic-player-bar[focused],
ytmusic-player-bar:hover #progress-bar.ytmusic-player-bar {{
  --paper-slider-knob-color: {pear_desktop["knob"]} !important;
}}
""".strip()

    write_file(
        BASE_DIR / "YouTube Music" / "themes" / "pear-desktop.css",
        file,
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
    sufix="",
    strip_hash=False,
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

        if strip_hash and value.startswith("#"):
            value = value[1:]

        new_lines.append(f"{prefix}{key}{separator}{value}{sufix}\n")

    write_file(output, "".join(new_lines))


def patch_sectioned_config(
    source,
    output,
    replacements,
    separator="=",
    quote=False,
):
    with open(source) as f:
        lines = f.readlines()

    new_lines = []
    current_section = None

    for line in lines:

        stripped = line.strip()

        #
        # Preserve comments and empty lines
        #

        if not stripped or stripped.startswith("#"):
            new_lines.append(line)
            continue

        #
        # Detect section
        #

        if stripped.startswith("[") and stripped.endswith("]"):
            current_section = stripped[1:-1]
            new_lines.append(line)
            continue

        if separator not in stripped:
            new_lines.append(line)
            continue

        key, _ = stripped.split(separator, 1)
        key = key.strip()

        #
        # Build section.key
        #

        lookup_key = f"{current_section}.{key}"

        if lookup_key not in replacements:
            new_lines.append(line)
            continue

        value = replacements[lookup_key]

        #
        # None = don't touch
        #

        if value is None:
            new_lines.append(line)
            continue

        #
        # Optionally quote value
        #

        if quote:
            value = f'"{value}"'

        new_lines.append(f"{key}{separator}{value}\n")

    write_file(output, "".join(new_lines))


def patch_toml_file(
    source,
    output,
    replacements,
    wrapper=None,
):
    with open(source) as f:
        doc = tomlkit.parse(f.read())

    for path, value in replacements.items():

        if value is None:
            continue

        if wrapper:
            value = wrapper(value)

        parts = path.split(".")

        obj = doc

        for part in parts[:-1]:
            obj = obj[part]

        obj[parts[-1]] = value

    write_file(output, tomlkit.dumps(doc))


def patch_json_file(source, output, replacements):
    with open(source) as f:
        data = json.load(f)

    for path, value in replacements.items():

        value = resolve(value)

        # None = don't touch
        if value is None:
            continue

        parts = path.split(".")

        obj = data

        for part in parts[:-1]:
            obj = obj[part]

        obj[parts[-1]] = value

    write_file(
        output,
        json.dumps(data, indent=2) + "\n",
    )


def patch_yaml_file(source, output, replacements):
    with open(source) as f:
        data = yaml.safe_load(f)

    for path, value in replacements.items():

        if value is None:
            continue

        parts = path.split(".")

        obj = data

        for part in parts[:-1]:
            obj = obj[part]

        obj[parts[-1]] = value

    write_file(
        output,
        yaml.safe_dump(
            data,
            sort_keys=False,
            allow_unicode=True,
        ),
    )


def patch_fastfetch(source, output, replacements):
    with open(source) as f:
        data = json5.load(f)

    for path, value in replacements.items():

        if value is None:
            continue

        parts = path.split(".")

        #
        # Normal JSON path
        #

        if parts[0] != "module" and parts[0] != "modules":
            obj = data

            for part in parts[:-1]:
                obj = obj[part]

            obj[parts[-1]] = value

            continue

        #
        # All modules
        #
        # modules.keyColor
        #

        if parts[0] == "modules":
            key = parts[1]

            for module in data.get("modules", []):

                if not isinstance(module, dict):
                    continue

                if key in module:
                    module[key] = value

            continue

        #
        # Specific module
        #
        # module.os.keyColor
        #

        if parts[0] == "module":
            module_type = parts[1]

            for module in data.get("modules", []):

                if not isinstance(module, dict):
                    continue

                if module.get("type") != module_type:
                    continue

                obj = module

                for part in parts[2:-1]:
                    obj = obj[part]

                obj[parts[-1]] = value

    write_file(
        output,
        json.dumps(data, indent=2) + "\n",
    )


def generate_wlogout_icons(source_dir, output_dir, color):
    output_dir.mkdir(parents=True, exist_ok=True)

    for source in source_dir.glob("*.png"):

        output = output_dir / f"{source.stem}-colored.png"

        subprocess.run(
            [
                "magick",
                str(source),
                "-alpha",
                "extract",
                "-background",
                color,
                "-alpha",
                "shape",
                str(output),
            ],
            check=True,
        )

    print(f"Generated: {output_dir}")


def generate_wlogout():
    generate_wlogout_icons(
        BASE_DIR / "wlogout" / "icons" / "original",
        BASE_DIR / "wlogout" / "icons",
        # OUTPUT_DIR / "wlogout",
        wlogout["buttons"],
    )


def generate_mpv():
    patch_config(
        BASE_DIR / "mpv" / "script-opts" / "modernz.conf",
        BASE_DIR / "mpv" / "script-opts" / "modernz.conf",
        mpv,
    )


def generate_zathura():
    patch_config(
        BASE_DIR / "zathura" / "zathurarc",
        BASE_DIR / "zathura" / "zathurarc",
        zathura,
        prefix="set ",
        separator=" ",
    )


def generate_clipse():
    patch_json_file(
        BASE_DIR / "clipse" / "clipse.json",
        BASE_DIR / "clipse" / "clipse.json",
        clipse,
    )


def generate_pytab():
    patch_json_file(
        BASE_DIR / "tridactyl" / "pytab" / "config.json",
        BASE_DIR / "tridactyl" / "pytab" / "config.json",
        # OUTPUT_DIR / "config.json",
        pytab,
    )


def generate_pyhist():
    patch_json_file(
        BASE_DIR / "tridactyl" / "pyhist" / "config.json",
        BASE_DIR / "tridactyl" / "pyhist" / "config.json",
        # OUTPUT_DIR / "config.json",
        pyhist,
    )


def generate_flameshot():
    patch_config(
        BASE_DIR / "flameshot" / "flameshot.ini",
        BASE_DIR / "flameshot" / "flameshot.ini",
        flameshot,
    )


def generate_btop():
    patch_config(
        BASE_DIR / "btop" / "themes" / "btop.theme",
        BASE_DIR / "btop" / "themes" / "btop.theme",
        btop,
        separator="=",
    )


def generate_yazi():
    patch_toml_file(
        BASE_DIR / "yazi" / "theme.toml",
        BASE_DIR / "yazi" / "theme.toml",
        yazi,
    )


def generate_wiremix():
    patch_toml_file(
        BASE_DIR / "wiremix" / "wiremix.toml",
        BASE_DIR / "wiremix" / "wiremix.toml",
        wiremix,
    )


def generate_surge():
    patch_toml_file(
        BASE_DIR / "surge" / "themes" / "surge.toml",
        BASE_DIR / "surge" / "themes" / "surge.toml",
        surge,
    )


def generate_traytui():
    patch_toml_file(
        BASE_DIR / "tray-tui" / "config.toml",
        BASE_DIR / "tray-tui" / "config.toml",
        traytui,
    )


def generate_wlkbptr():
    patch_sectioned_config(
        BASE_DIR / "wl-kbptr" / "config",
        BASE_DIR / "wl-kbptr" / "config",
        wlkbptr,
    )


def generate_git():
    patch_sectioned_config(
        Path.home() / ".gitconfig",
        Path.home() / ".gitconfig",
        # OUTPUT_DIR / "gitconfig",
        git,
        quote=True,
    )


def generate_wvkbd():
    patch_config(
        BASE_DIR / "wvkbd" / "config",
        BASE_DIR / "wvkbd" / "config",
        wvkbd,
        prefix="--",
        separator=" ",
        strip_hash=True,
    )


def generate_fzf():
    patch_config(
        BASE_DIR / "fzf" / "fzfrc",
        BASE_DIR / "fzf" / "fzfrc",
        fzf,
        prefix="--color=",
        separator=":",
    )


def generate_tlrc():

    def toml_hex(value):
        table = tomlkit.inline_table()
        table["hex"] = value
        return table

    patch_toml_file(
        BASE_DIR / "tlrc" / "config.toml",
        BASE_DIR / "tlrc" / "config.toml",
        tlrc,
        wrapper=toml_hex,
    )


def generate_gdu():
    patch_yaml_file(
        BASE_DIR / "gdu" / "gdu.yaml",
        BASE_DIR / "gdu" / "gdu.yaml",
        gdu,
    )


def generate_fastfetch():
    patch_fastfetch(
        BASE_DIR / "fastfetch" / "config.jsonc",
        BASE_DIR / "fastfetch" / "config.jsonc",
        # OUTPUT_DIR / "fastfetch.jsonc",
        fastfetch,
    )


# ============================================================
# Main
# ============================================================


def main():
    generate_kitty()
    generate_nvim()
    generate_hyprland()
    generate_hyprland_lua()
    generate_waybar()
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
    generate_clipse()
    generate_wiremix()
    generate_surge()
    generate_pytab()
    generate_pyhist()
    generate_peardesktop()
    generate_wlkbptr()
    generate_wvkbd()
    generate_fzf()
    generate_tlrc()
    generate_gdu()
    generate_fastfetch()
    generate_git()
    generate_wlogout()


if __name__ == "__main__":
    main()
