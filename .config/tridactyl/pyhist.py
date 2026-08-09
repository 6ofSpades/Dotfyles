#!/usr/bin/env python3

# yay -Sy python-blessed wl-clipboard

import json
import re
import socket
import subprocess
import sys
import time
from pathlib import Path

from blessed import Terminal

term = Terminal()

SORT_NAMES = ["recent", "visits", "title", "url"]
TITLE_WIDTH = 60
VISITS_WIDTH = 6
LASTVISIT_WIDTH = 16  # "2026/08/08 15:00" is exactly 16 chars

DEFAULT_COLORS = {
    "normal": "normal",
    "cursor_bg": "on_blue",
    "border": "bright_black",
    "footer": "bright_black",
    "prompt": "cyan",
    "visits_high": "yellow",
}

# Visit count at or above this gets colored with "visits_high" -- purely
# cosmetic, set to a huge number in config to effectively disable it.
FREQUENT_THRESHOLD = 25

# How long to wait after the last keystroke before actually re-filtering.
# Filtering the full history is the expensive part, not echoing typed
# characters, so typing fast used to visibly queue up. Set to 0 in
# config to filter on every keystroke like before.
DEBOUNCE_SECONDS = 0.3

# Control-character keybinds. Values are parsed from either "C-<letter>"
# notation (e.g. "C-o" for Ctrl+O) or a raw \uXXXX escape for keys that
# aren't a simple Ctrl+letter chord. Enter itself is not configurable
# here (same as pytab) since it's read via KEY_ENTER / \r / \n.
DEFAULT_KEYBINDS = {
    "down": "\x0a",  # Ctrl+J
    "up": "\x0b",  # Ctrl+K
    "open_new": "\x0f",  # Ctrl+O -- open in a new tab
    "delete": "\x04",  # Ctrl+D -- delete from history
    "sort": "\x13",  # Ctrl+S
    "center": "\x1a",  # Ctrl+Z
    "delete_word": "\x08",  # Ctrl+Backspace on kitty (same byte as Ctrl+H)
    "copy": "\x03",  # Ctrl+C -- safe to reuse since raw mode disables SIGINT
}

CONFIG_DIR = Path.home() / ".config" / "tridactyl" / "pyhist"
CONFIG_PATH = CONFIG_DIR / "config.json"
STATE_DIR = Path.home() / ".cache" / "pyhist"
STATE_PATH = STATE_DIR / "state.json"

search_query = ""


def send_action_to_browser(action, url):
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect(("127.0.0.1", 9998))
        s.sendall(json.dumps({"action": action, "url": url}).encode("utf-8"))
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
    """Accepts 'C-<letter>' (e.g. 'C-o') or a raw \\uXXXX escape. Returns
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
    """Loads ~/.config/tridactyl/pyhist/config.json, merging with
    defaults. Never raises: any problem with the file just falls back to
    defaults. Auto-creates a starter file on first run."""
    colors = dict(DEFAULT_COLORS)
    keybinds = dict(DEFAULT_KEYBINDS)
    threshold = FREQUENT_THRESHOLD
    debounce = DEBOUNCE_SECONDS
    try:
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)
        if CONFIG_PATH.exists():
            with open(CONFIG_PATH, "r") as f:
                user_cfg = json.load(f)
            if isinstance(user_cfg.get("colors"), dict):
                colors.update(user_cfg["colors"])
            if isinstance(user_cfg.get("keybinds"), dict):
                for name, raw in user_cfg["keybinds"].items():
                    if name not in DEFAULT_KEYBINDS:
                        continue
                    parsed = parse_keybind_value(raw)
                    if parsed:
                        keybinds[name] = parsed
            if isinstance(user_cfg.get("frequent_threshold"), int):
                threshold = user_cfg["frequent_threshold"]
            if isinstance(user_cfg.get("debounce_seconds"), (int, float)):
                debounce = max(0.0, float(user_cfg["debounce_seconds"]))
        else:
            with open(CONFIG_PATH, "w") as f:
                json.dump(
                    {
                        "colors": DEFAULT_COLORS,
                        "keybinds": {
                            k: keybind_display(v) for k, v in DEFAULT_KEYBINDS.items()
                        },
                        "frequent_threshold": FREQUENT_THRESHOLD,
                        "debounce_seconds": DEBOUNCE_SECONDS,
                    },
                    f,
                    indent=2,
                    ensure_ascii=False,
                )
    except Exception:
        pass
    return colors, keybinds, threshold, debounce


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


def load_history(arg):
    """Accepts either a raw JSON string (from the extension) or a file
    path, same dual-path convenience as pytab's load_tabs."""
    try:
        return json.loads(arg)
    except Exception:
        pass
    try:
        with open(arg, "r") as f:
            return json.load(f)
    except Exception:
        return []


def sort_tabs(items, mode):
    if mode == 0:  # recent
        return sorted(items, key=lambda t: -t.get("lastVisitTime", 0))
    elif mode == 1:  # visits
        return sorted(
            items, key=lambda t: (-t.get("visitCount", 0), -t.get("lastVisitTime", 0))
        )
    elif mode == 2:  # title
        return sorted(items, key=lambda t: (t.get("title") or "").lower())
    elif mode == 3:  # url
        return sorted(items, key=lambda t: (t.get("url") or "").lower())
    return items


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
    """Numeric queries jump straight to the displayed row number, same
    rationale as pytab: fixed scores dwarf fuzzy_score so an index match
    always wins over a coincidental digit match in a title/url."""
    if not query.isdigit():
        return None
    if index_str == query:
        return 1000
    if index_str.startswith(query):
        return 500
    if query in index_str:
        return 200
    return None


def filter_and_sort(raw_items, sort_mode, display_index, query):
    q = query.lower()
    if not q:
        return sort_tabs(raw_items, sort_mode)

    scored = []
    for t in raw_items:
        idx = display_index.get(id(t), 0)
        candidates = [
            s
            for s in (
                fuzzy_score(q, t.get("title") or ""),
                fuzzy_score(q, t.get("url") or ""),
                index_score(q, str(idx)),
            )
            if s is not None
        ]
        if candidates:
            scored.append((max(candidates), t))
    scored.sort(key=lambda pair: (-pair[0], -pair[1].get("lastVisitTime", 0)))
    return [t for _, t in scored]


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
    either a blessed capability name or a hex color. Falls back to a
    no-op wrapper if the value is invalid or non-callable."""
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
    """Pads or truncates s to exactly `width` visual columns."""
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


def format_last_visit(ms):
    if not ms:
        return "?"
    return time.strftime("%Y/%m/%d %H:%M", time.localtime(ms / 1000.0))


def ctrl_label(ch):
    return "^" + chr(ord(ch) + 0x40).lower()


def build_footer(keybinds, width):
    footer = (
        f"{ctrl_label(keybinds['down'])}/{ctrl_label(keybinds['up'])} move  "
        f"enter open  {ctrl_label(keybinds['open_new'])} new tab  "
        f"{ctrl_label(keybinds['delete'])} delete  {ctrl_label(keybinds['sort'])} sort  "
        f"{ctrl_label(keybinds['center'])} center  {ctrl_label(keybinds['copy'])} copy url  "
        f"esc quit"
    )
    return footer[: width - 1]


def build_row(colors, threshold, item, display_idx, is_cursor, width):
    index_part = f" {display_idx:<6} "
    title = fit_width(item.get("title") or item.get("url") or "", TITLE_WIDTH)
    visits = item.get("visitCount", 0)
    visits_str = fit_width(str(visits), VISITS_WIDTH)
    last_str = fit_width(format_last_visit(item.get("lastVisitTime")), LASTVISIT_WIDTH)

    # Measure the real plain-text prefix instead of hand-computing its
    # length -- a hardcoded arithmetic formula silently drifted out of
    # sync with the actual concatenation below whenever a column width
    # changed, overshooting the terminal width and losing both the tail
    # of the URL and its ".." marker off the edge of the screen.
    plain_prefix = f"{index_part}│ {title} │ {visits_str} │ {last_str} │ "
    available = max(0, (width - 1) - term.length(plain_prefix))
    url_part = fit_width(item.get("url") or "", available)

    fg_fn = color_fn(colors, "normal")

    if is_cursor:
        # Single fg+bg wrap around the whole line, same reasoning as
        # pytab: nesting a second color under a shared background breaks
        # reliably in terminal escape sequences.
        bg_fn = color_fn(colors, "cursor_bg", bg=True)
        return bg_fn(fg_fn(plain_prefix + url_part))

    border_fn = color_fn(colors, "border")
    visits_fn = color_fn(colors, "visits_high") if visits >= threshold else fg_fn
    return (
        fg_fn(index_part)
        + border_fn("│")
        + fg_fn(f" {title} ")
        + border_fn("│")
        + visits_fn(f" {visits_str} ")
        + border_fn("│")
        + fg_fn(f" {last_str} ")
        + border_fn("│")
        + fg_fn(f" {url_part}")
    )


def delete_last_word(s):
    s = s.rstrip(" ")
    idx = s.rfind(" ")
    return s[: idx + 1] if idx != -1 else ""


def main():
    global search_query

    colors, keybinds, threshold, debounce_seconds = load_config()

    hist_arg = sys.argv[1] if len(sys.argv) > 1 else "[]"
    raw_items = load_history(hist_arg)

    forced_sort = resolve_sort_arg(sys.argv[2]) if len(sys.argv) > 2 else None
    sort_mode = forced_sort if forced_sort is not None else load_sort_state()

    cursor_idx = 0
    scroll_top = 0
    flash_text = None

    # Cache of the last computed (base_sorted, display_index, sorted_list),
    # keyed on everything that can actually change the result. Without
    # this, every single keypress -- including pure cursor movement like
    # up/down, which never touches search_query -- was re-running a full
    # sort and fuzzy-filter over the entire history on every redraw. That's
    # fine at a few hundred entries but visibly laggy at tens of thousands.
    # id(raw_items) changes automatically whenever delete rebuilds the
    # list, so a delete still correctly invalidates the cache.
    cache_key = None
    base_sorted = []
    display_index = {}
    sorted_list = []

    # filter_query is what's actually used for filtering; search_query is
    # what's shown in the search box and updates instantly on every key.
    # filter_query only catches up once debounce_seconds have passed since
    # the last keystroke, so a fast typist sees their text appear smoothly
    # instead of the box lagging behind an expensive re-filter on every
    # single character.
    filter_query = search_query
    last_key_time = 0.0

    with term.raw(), term.hidden_cursor():
        while True:
            width = term.width
            height = term.height
            max_visible_rows = max(1, height - 7)

            now = time.time()
            if (
                filter_query != search_query
                and (now - last_key_time) >= debounce_seconds
            ):
                filter_query = search_query

            current_key = (sort_mode, filter_query, id(raw_items))
            if current_key != cache_key:
                # display_index maps each item's identity to its position
                # in the current sort order (mode-dependent, independent
                # of search filtering) so numeric search jumps stay sensible.
                base_sorted = sort_tabs(raw_items, sort_mode)
                display_index = {id(t): i + 1 for i, t in enumerate(base_sorted)}
                sorted_list = filter_and_sort(
                    raw_items, sort_mode, display_index, filter_query
                )
                cache_key = current_key

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

            find_prefix = prompt_fn("HIST => ") + term.normal + search_query + "█"
            output.append(term.move_yx(1, 3) + find_prefix)

            sort_label = f"sort: {SORT_NAMES[sort_mode]}"
            sort_col = width - len(sort_label) - 2
            if sort_col > term.length(find_prefix) + 4:
                output.append(term.move_yx(1, sort_col) + border_fn(sort_label))

            output.append(term.move_yx(2, 0) + border_fn("─" * width))
            output.append(
                term.move_yx(3, 1)
                + term.normal
                + f"{'ID':<7}"
                + border_fn(f"{'│':<2}")
                + term.normal
                + f"{'Title':<{TITLE_WIDTH + 1}}"
                + border_fn(f"{'│':<2}")
                + term.normal
                + f"{'Visits':<{VISITS_WIDTH + 1}}"
                + border_fn(f"{'│':<2}")
                + term.normal
                + f"{'Last Visit':<{LASTVISIT_WIDTH + 1}}"
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
                item = sorted_list[list_idx]
                is_cursor = list_idx == cursor_idx
                output.append(
                    term.move_yx(row, 0)
                    + build_row(
                        colors,
                        threshold,
                        item,
                        display_index.get(id(item), list_idx + 1),
                        is_cursor,
                        width,
                    )
                )

            output.append(term.move_yx(height - 2, 0) + border_fn("─" * width))
            footer_content = flash_text if flash_text else build_footer(keybinds, width)
            output.append(
                term.move_yx(height - 1, 0) + footer_fn(footer_content[: width - 1])
            )
            flash_text = None

            print("".join(output), end="", flush=True)

            val = term.inkey(timeout=0.05, esc_delay=0)

            if not val:
                # Timeout tick, no key pressed -- loop back up so the
                # debounce check above gets another chance to fire once
                # the user has paused.
                continue

            if val.name == "KEY_ESCAPE":
                send_action_to_browser("exit", "")
                break
            elif val == "\x7f" or val.name == "KEY_DELETE":
                search_query = search_query[:-1]
                last_key_time = now
                cursor_idx = 0
                continue

            if val == keybinds["delete_word"]:
                search_query = delete_last_word(search_query)
                last_key_time = now
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
            elif val == keybinds["delete"]:
                if sorted_list:
                    url = sorted_list[cursor_idx]["url"]
                    send_action_to_browser("delete", url)
                    raw_items = [t for t in raw_items if t.get("url") != url]
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
            elif val == keybinds["open_new"]:
                if sorted_list:
                    send_action_to_browser("open-new", sorted_list[cursor_idx]["url"])
                    break
                continue
            elif val.name == "KEY_ENTER" or val in ["\r", "\n"]:
                if sorted_list:
                    send_action_to_browser("open", sorted_list[cursor_idx]["url"])
                    break
                continue

            if not val.is_sequence and len(val) == 1 and 32 <= ord(val) <= 126:
                search_query += val
                last_key_time = now
                cursor_idx = 0


if __name__ == "__main__":
    main()
