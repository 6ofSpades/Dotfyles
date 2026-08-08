#!/usr/bin/env python3

# yay -Sy python-blessed wl-clipboard

import json
import re
import socket
import subprocess
import sys
from pathlib import Path

from blessed import Terminal

term = Terminal()

SORT_NAMES = ["index", "recent", "state", "title"]
TITLE_WIDTH = 60

DEFAULT_COLORS = {
    "normal": "normal",
    "active": "red_bold",
    "discarded": "bright_black",
    "cursor_bg": "on_blue",
    "border": "bright_black",
    "footer": "bright_black",
    "prompt": "cyan",
    "pin_marker": "yellow",
}

DEFAULT_SYMBOLS = {
    "pinned": "\U0001f4cc",  # pin emoji; set to "" to disable, or swap for e.g. "*"
}

# Control-character keybinds. Values are parsed from either "C-<letter>"
# notation (e.g. "C-w" for Ctrl+W) or a raw \uXXXX escape for keys that
# aren't a simple Ctrl+letter chord.
DEFAULT_KEYBINDS = {
    "down": "\x0a",  # Ctrl+J
    "up": "\x0b",  # Ctrl+K
    "close": "\x18",  # Ctrl+X
    "discard": "\x04",  # Ctrl+D
    "pin": "\x10",  # Ctrl+P
    "sort": "\x13",  # Ctrl+S
    "center": "\x1a",  # Ctrl+Z
    "delete_word": "\x08",  # Ctrl+Backspace on kitty (same byte as Ctrl+H)
    "copy": "\x03",  # Ctrl+C -- safe to reuse since raw mode disables SIGINT
}

CONFIG_DIR = Path.home() / ".config" / "tridactyl" / "pytab"
CONFIG_PATH = CONFIG_DIR / "config.json"
STATE_DIR = Path.home() / ".cache" / "pytab"
STATE_PATH = STATE_DIR / "state.json"

search_query = ""


def send_action_to_browser(action, tab_id):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("127.0.0.1", 9999))
        s.sendall(f"{action} {tab_id}".encode("utf-8"))
        s.close()
    except Exception:
        pass


def copy_to_clipboard(text):
    try:
        subprocess.run(["wl-copy"], input=text.encode("utf-8"), check=True, timeout=1)
        return True
    except Exception:
        return False


def parse_keybind_value(value):
    """Accepts 'C-<letter>' (e.g. 'C-w') or a raw \\uXXXX escape. Returns
    a single control character, or None if the value can't be parsed."""
    if not isinstance(value, str):
        return None
    m = re.fullmatch(r"[Cc]-([A-Za-z])", value)
    if m:
        return chr(ord(m.group(1).upper()) - 0x40)
    m = re.fullmatch(r"\\u([0-9a-fA-F]{4})", value)
    if m:
        return chr(int(m.group(1), 16))
    if len(value) == 1 and ord(value) < 0x20:
        return value
    return None


def keybind_display(ch):
    """Inverse of parse_keybind_value, for writing the starter config."""
    code = ord(ch)
    if code < 0x20 and code != 0:
        return "C-" + chr(code + 0x40).lower()
    return f"\\u{code:04x}"


def load_config():
    """Loads ~/.config/pytab/config.json, merging with defaults. Never
    raises: any problem with the file just falls back to defaults, since
    a broken config should never break your daily-driver tab switcher.
    Auto-creates a starter file on first run so there's something to edit."""
    colors = dict(DEFAULT_COLORS)
    symbols = dict(DEFAULT_SYMBOLS)
    keybinds = dict(DEFAULT_KEYBINDS)
    try:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH, "r") as f:
                user_cfg = json.load(f)
            if isinstance(user_cfg.get("colors"), dict):
                colors.update(user_cfg["colors"])
            if isinstance(user_cfg.get("symbols"), dict):
                for name, sym in user_cfg["symbols"].items():
                    if name in DEFAULT_SYMBOLS and isinstance(sym, str):
                        symbols[name] = sym
            if isinstance(user_cfg.get("keybinds"), dict):
                for name, raw in user_cfg["keybinds"].items():
                    if name not in DEFAULT_KEYBINDS:
                        continue
                    parsed = parse_keybind_value(raw)
                    if parsed:
                        keybinds[name] = parsed
        else:
            with open(CONFIG_PATH, "w") as f:
                json.dump(
                    {
                        "colors": DEFAULT_COLORS,
                        "symbols": DEFAULT_SYMBOLS,
                        "keybinds": {
                            k: keybind_display(v) for k, v in DEFAULT_KEYBINDS.items()
                        },
                    },
                    f,
                    indent=2,
                    ensure_ascii=False,
                )
    except Exception:
        pass
    return colors, symbols, keybinds


def load_sort_state():
    try:
        with open(STATE_PATH, "r") as f:
            data = json.load(f)
        mode = int(data.get("sort_mode", 0))
        if 0 <= mode < len(SORT_NAMES):
            return mode
    except Exception:
        pass
    return 0


def save_sort_state(mode):
    try:
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        with open(STATE_PATH, "w") as f:
            json.dump({"sort_mode": mode}, f)
    except Exception:
        pass


def resolve_sort_arg(arg):
    if arg is None:
        return None
    arg = arg.strip().lower()
    if arg.isdigit():
        idx = int(arg)
        return idx if 0 <= idx < len(SORT_NAMES) else None
    return SORT_NAMES.index(arg) if arg in SORT_NAMES else None


def load_tabs(arg):
    """Accepts either a raw JSON string (new, faster path) or a file path
    (old path, still supported)."""
    try:
        return json.loads(arg)
    except Exception:
        pass
    try:
        with open(arg, "r") as f:
            return json.load(f)
    except Exception:
        return []


def sort_tabs(tabs, mode):
    if mode == 0:  # index, pinned first (mirrors browser's own tab strip)
        return sorted(tabs, key=lambda t: (not t["pinned"], t["index"]))
    elif mode == 1:  # most recent, no pin priority
        return sorted(tabs, key=lambda t: -t.get("lastAccessed", 0))
    elif mode == 2:  # load state, pinned first
        return sorted(tabs, key=lambda t: (not t["pinned"], t["discarded"]))
    elif mode == 3:  # title, no pin priority (surfaces duplicates together)
        return sorted(tabs, key=lambda t: t["title"].lower())
    return tabs


def fuzzy_score(query, text):
    if not query:
        return 0
    text = text.lower()
    qi = 0
    score = 0
    last_match = -1
    for ti, ch in enumerate(text):
        if qi < len(query) and ch == query[qi]:
            score += 3 if last_match == ti - 1 else 1
            last_match = ti
            qi += 1
            if qi == len(query):
                break
    return score if qi == len(query) else None


def index_score(query, index_str):
    """Only kicks in for purely-numeric queries, so typing the displayed
    index number reliably jumps to that tab instead of competing evenly
    with ordinary title/url fuzzy matches (which could coincidentally
    contain the same digits). The fixed scores here (200-1000) are chosen
    to dwarf typical fuzzy_score output, so an index match always wins."""
    if not query.isdigit():
        return None
    if index_str == query:
        return 1000
    if index_str.startswith(query):
        return 500
    if query in index_str:
        return 200
    return None


def filter_and_sort(raw_tabs, sort_mode):
    q = search_query.lower()
    if not q:
        return sort_tabs(raw_tabs, sort_mode)

    scored = []
    for t in raw_tabs:
        candidates = [
            s
            for s in (
                fuzzy_score(q, t["title"]),
                fuzzy_score(q, t["url"]),
                index_score(q, str(t["index"] + 1)),
            )
            if s is not None
        ]
        if candidates:
            scored.append((max(candidates), t))
    scored.sort(key=lambda pair: (-pair[0], not pair[1]["pinned"]))
    return [t for _, t in scored]


def state_key(tab):
    """Drives the row's main foreground color. Pinned status is shown via
    a marker symbol instead (see build_row), so a tab that's both pinned
    and discarded still reads clearly as discarded."""
    if tab.get("active"):
        return "active"
    if tab["discarded"]:
        return "discarded"
    return "normal"


def parse_hex_color(value):
    if not isinstance(value, str):
        return None
    s = value.strip()
    if s.startswith("#"):
        s = s[1:]
    if len(s) == 3:
        s = "".join(c * 2 for c in s)
    if len(s) != 6:
        return None
    try:
        return tuple(int(s[i : i + 2], 16) for i in (0, 2, 4))
    except ValueError:
        return None


def color_fn(colors, name, bg=False):
    """Resolves a config color entry to a callable formatter. Accepts
    either a blessed capability name ("red_bold", "on_blue", ...) or a
    hex color ("#ff8800"). Falls back to a no-op wrapper if the value is
    invalid or resolves to something non-callable (e.g. term.normal is a
    plain reset string, not a formatter)."""
    value = colors.get(name, "normal")
    rgb = parse_hex_color(value)
    if rgb:
        try:
            fn = term.on_color_rgb(*rgb) if bg else term.color_rgb(*rgb)
            if callable(fn):
                return fn
        except Exception:
            pass
        return lambda s: s
    fn = getattr(term, value, None)
    return fn if callable(fn) else (lambda s: s)


def fit_width(s, width):
    """Pads or truncates s to exactly `width` visual columns, using
    term.length() so wide characters (like the pin emoji) are measured
    correctly instead of by raw character count."""
    if width <= 0:
        return ""
    vlen = term.length(s)
    if vlen == width:
        return s
    if vlen < width:
        return s + " " * (width - vlen)
    ell = ".."
    target = max(0, width - term.length(ell))
    while s and term.length(s) > target:
        s = s[:-1]
    return s + ell


def ctrl_label(ch):
    return "^" + chr(ord(ch) + 0x40).lower()


def build_footer(keybinds, width):
    footer = (
        f"{ctrl_label(keybinds['down'])}/{ctrl_label(keybinds['up'])} move  "
        f"enter switch  {ctrl_label(keybinds['pin'])} pin  "
        f"{ctrl_label(keybinds['discard'])} discard  {ctrl_label(keybinds['close'])} close  "
        f"{ctrl_label(keybinds['sort'])} sort  {ctrl_label(keybinds['center'])} center  "
        f"{ctrl_label(keybinds['copy'])} copy url  "
        f"esc quit"
    )
    return footer[: width - 1]


def build_title_cell(colors, symbols, tab):
    """Returns the colored TITLE_WIDTH-wide cell contents. Pinned tabs get
    a marker glyph (colored independently via 'pin_marker') instead of a
    different row color, so pin status and discard status never compete
    for the same visual channel."""
    marker = symbols.get("pinned", "") if tab["pinned"] else ""
    marker_display = f"{marker} " if marker else ""
    marker_w = term.length(marker_display)
    body_w = max(0, TITLE_WIDTH - marker_w)
    body = fit_width(tab["title"], body_w)

    fg_fn = color_fn(colors, state_key(tab))
    if not marker:
        return fg_fn(body)
    marker_fn = color_fn(colors, "pin_marker")
    return marker_fn(marker_display) + fg_fn(body)


def build_row(colors, symbols, tab, is_cursor, width):
    index_part = f" {tab['index'] + 1:<3} "
    fg_fn = color_fn(colors, state_key(tab))

    if is_cursor:
        # Single fg+bg wrap around the whole line -- the marker is shown
        # as plain text here (no separate marker color) since nesting a
        # third color under a shared background reliably breaks in
        # terminal escape sequences (each inner reset clears the outer
        # background too). The selection highlight already makes this
        # row obvious, so losing the marker's own color here is a minor,
        # deliberate trade-off.
        marker = symbols.get("pinned", "") if tab["pinned"] else ""
        marker_display = f"{marker} " if marker else ""
        body_w = max(0, TITLE_WIDTH - term.length(marker_display))
        title_inner = marker_display + fit_width(tab["title"], body_w)
        title_part = f" {title_inner} "
        prefix_len = len(index_part) + 1 + TITLE_WIDTH + 2 + 1
        available = max(0, (width - 1) - prefix_len)
        url_part = fit_width(tab["url"], available)
        bg_fn = color_fn(colors, "cursor_bg", bg=True)
        line_str = f"{index_part}│{title_part}│ {url_part}"
        return bg_fn(fg_fn(line_str))

    border_fn = color_fn(colors, "border")
    title_cell = build_title_cell(colors, symbols, tab)
    prefix_len = len(index_part) + 1 + TITLE_WIDTH + 2 + 1
    available = max(0, (width - 1) - prefix_len)
    url_part = fit_width(tab["url"], available)
    return (
        fg_fn(index_part)
        + border_fn("│")
        + " "
        + title_cell
        + " "
        + border_fn("│")
        + fg_fn(f" {url_part}")
    )


def delete_last_word(s):
    s = s.rstrip(" ")
    idx = s.rfind(" ")
    return s[: idx + 1] if idx != -1 else ""


def main():
    global search_query

    colors, symbols, keybinds = load_config()

    tabs_arg = sys.argv[1] if len(sys.argv) > 1 else "[]"
    raw_tabs = load_tabs(tabs_arg)

    forced_sort = resolve_sort_arg(sys.argv[2]) if len(sys.argv) > 2 else None
    sort_mode = forced_sort if forced_sort is not None else load_sort_state()

    sorted_init = sort_tabs(raw_tabs, sort_mode)
    cursor_idx = 0
    for idx, tab in enumerate(sorted_init):
        if tab.get("active"):
            cursor_idx = idx
            break

    scroll_top = 0
    flash_text = None

    with term.raw(), term.hidden_cursor():
        while True:
            width = term.width
            height = term.height
            max_visible_rows = max(1, height - 7)

            sorted_list = filter_and_sort(raw_tabs, sort_mode)

            if cursor_idx >= len(sorted_list):
                cursor_idx = max(0, len(sorted_list) - 1)
            if cursor_idx < scroll_top:
                scroll_top = cursor_idx
            elif cursor_idx >= scroll_top + max_visible_rows:
                scroll_top = cursor_idx - max_visible_rows + 1

            border_fn = color_fn(colors, "border")
            footer_fn = color_fn(colors, "footer")
            prompt_fn = color_fn(colors, "prompt")

            output = [term.clear]

            find_prefix = prompt_fn("TABS => ") + term.normal + search_query + "█"
            output.append(term.move_yx(1, 3) + find_prefix)

            sort_label = f"sort: {SORT_NAMES[sort_mode]}"
            sort_col = width - len(sort_label) - 2
            if sort_col > term.length(find_prefix) + 4:
                output.append(term.move_yx(1, sort_col) + border_fn(sort_label))

            output.append(term.move_yx(2, 0) + border_fn("─" * width))
            output.append(
                term.move_yx(3, 1)
                + term.normal
                + f"{'ID':<4}"
                + border_fn(f"{'│':<2}")
                + term.normal
                + f"{'Title':<{TITLE_WIDTH + 1}}"
                + border_fn(f"{'│':<2}")
                + term.normal
                + f"{'URL'}"
            )
            output.append(term.move_yx(4, 0) + border_fn("─" * width))

            for i in range(max_visible_rows):
                list_idx = scroll_top + i
                if list_idx >= len(sorted_list):
                    break
                row = i + 5
                is_cursor = list_idx == cursor_idx
                output.append(
                    term.move_yx(row, 0)
                    + build_row(
                        colors, symbols, sorted_list[list_idx], is_cursor, width
                    )
                )

            output.append(term.move_yx(height - 2, 0) + border_fn("─" * width))
            footer_content = flash_text if flash_text else build_footer(keybinds, width)
            output.append(
                term.move_yx(height - 1, 0) + footer_fn(footer_content[: width - 1])
            )
            flash_text = None  # only shown for the frame right after it's set

            print("".join(output), end="", flush=True)

            val = term.inkey(esc_delay=0)

            if val.name == "KEY_ESCAPE":
                send_action_to_browser("exit", 0)
                break
            elif val == "\x7f" or val.name == "KEY_DELETE":
                # Plain Backspace/Delete. NOTE: don't check val.name ==
                # "KEY_BACKSPACE" here -- on kitty, Ctrl+Backspace sends
                # \x08 but blessed still reports it with that same name,
                # so name alone can't tell the two apart. Matching the
                # exact byte instead lets Ctrl+Backspace fall through to
                # the delete_word check below.
                search_query = search_query[:-1]
                cursor_idx = 0
                continue

            if val == keybinds["delete_word"]:
                search_query = delete_last_word(search_query)
                cursor_idx = 0
                continue
            elif val == keybinds["down"]:
                if cursor_idx < len(sorted_list) - 1:
                    cursor_idx += 1
                continue
            elif val == keybinds["up"]:
                if cursor_idx > 0:
                    cursor_idx -= 1
                continue
            elif val == keybinds["close"]:
                if sorted_list:
                    tid = sorted_list[cursor_idx]["id"]
                    send_action_to_browser("close", tid)
                    raw_tabs = [t for t in raw_tabs if t["id"] != tid]
                continue
            elif val == keybinds["discard"]:
                if sorted_list:
                    tid = sorted_list[cursor_idx]["id"]
                    send_action_to_browser("discard", tid)
                    for t in raw_tabs:
                        if t["id"] == tid:
                            t["discarded"] = True
                continue
            elif val == keybinds["pin"]:
                if sorted_list:
                    tid = sorted_list[cursor_idx]["id"]
                    send_action_to_browser("toggle-pin", tid)
                    for t in raw_tabs:
                        if t["id"] == tid:
                            t["pinned"] = not t["pinned"]
                continue
            elif val == keybinds["sort"]:
                sort_mode = (sort_mode + 1) % len(SORT_NAMES)
                save_sort_state(sort_mode)
                continue
            elif val == keybinds["center"]:
                scroll_top = cursor_idx - max_visible_rows // 2
                scroll_top = max(
                    0, min(scroll_top, max(0, len(sorted_list) - max_visible_rows))
                )
                continue
            elif val == keybinds["copy"]:
                if sorted_list:
                    url = sorted_list[cursor_idx]["url"]
                    ok = copy_to_clipboard(url)
                    flash_text = (
                        f"copied: {url}"
                        if ok
                        else "copy failed -- is wl-copy installed?"
                    )
                continue
            elif val.name == "KEY_ENTER" or val in ["\r", "\n"]:
                if sorted_list:
                    send_action_to_browser("switch", sorted_list[cursor_idx]["id"])
                    break
                continue

            if not val.is_sequence and len(val) == 1 and 32 <= ord(val) <= 126:
                search_query += val
                cursor_idx = 0


if __name__ == "__main__":
    main()
