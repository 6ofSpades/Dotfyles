#!/usr/bin/env python3
import html
import json
import subprocess
import time

# --- CONFIGURATION ---

TEXT_WHEN_STOPPED = "MPRIS"

SCROLL_TEXT_LENGTH = 45
SCROLL_GAP = "   "
REFRESH_INTERVAL = 0.2
PLAYERCTL_PATH = "/usr/bin/playerctl"

# Text between title and artist.
SEPARATOR = "  "

# Pango formatting for each metadata field.
#
# {} will be replaced with the safely escaped text.
TITLE_MARKUP = "<i>{}</i>"
ARTIST_MARKUP = "<span alpha='70%'>{}</span>"


def run_playerctl(args):
    try:
        res = subprocess.run(
            [PLAYERCTL_PATH] + args,
            capture_output=True,
            text=True,
            timeout=1,
        )
        return res.stdout.strip() if res.returncode == 0 else ""
    except Exception:
        return ""


def get_state():
    status = run_playerctl(["status"]).lower()

    if not status:
        return "stopped", "", ""

    title = run_playerctl(["metadata", "--format", "{{title}}"])
    artist = run_playerctl(["metadata", "--format", "{{artist}}"])

    return status, title, artist


def get_song_parts(title, artist):
    """
    Return the plain-text representation of the song and the
    positions occupied by the title and artist.

    Example:

        title  = "Song"
        artist = "Artist"

        plain = "Song |  Artist"
    """

    plain_song = f"{title}{SEPARATOR}{artist}"

    title_start = 0
    title_end = len(title)

    artist_start = len(title) + len(SEPARATOR)
    artist_end = artist_start + len(artist)

    return (
        plain_song,
        title_start,
        title_end,
        artist_start,
        artist_end,
    )


def format_window(title, artist, start):
    (
        plain_song,
        title_start,
        title_end,
        artist_start,
        artist_end,
    ) = get_song_parts(title, artist)

    cycle = plain_song + SCROLL_GAP

    # Make the source long enough to contain any possible
    # SCROLL_TEXT_LENGTH-sized window.
    repetitions = (SCROLL_TEXT_LENGTH // len(cycle)) + 2
    padded_song = cycle * repetitions

    window = padded_song[start : start + SCROLL_TEXT_LENGTH]

    result = []

    for i, char in enumerate(window):
        position = start + i
        song_position = position % len(cycle)

        if song_position >= len(plain_song):
            result.append(" ")
            continue

        if title_start <= song_position < title_end:
            result.append(TITLE_MARKUP.format(html.escape(char)))

        elif artist_start <= song_position < artist_end:
            result.append(ARTIST_MARKUP.format(html.escape(char)))

        else:
            result.append(html.escape(char))

    return "".join(result)


def format_static_song(title, artist):
    """
    Format the complete song for the paused state.

    Metadata is escaped BEFORE being inserted into the Pango
    templates, so song metadata can never inject its own markup.
    """

    safe_title = html.escape(title)
    safe_artist = html.escape(artist)

    return (
        TITLE_MARKUP.format(safe_title)
        + html.escape(SEPARATOR)
        + ARTIST_MARKUP.format(safe_artist)
    )


if __name__ == "__main__":
    current_song = None
    scroll_position = 0
    last_status = None

    while True:
        status, title, artist = get_state()

        if not title:
            display_text = html.escape(TEXT_WHEN_STOPPED.ljust(SCROLL_TEXT_LENGTH))

            class_name = "stopped"

            current_song = None
            scroll_position = 0

        else:
            class_name = status

            # This is the ONLY place where the plain song
            # representation is constructed for comparison.
            song = f"{title}{SEPARATOR}{artist}"

            # Song changed -> restart scrolling.
            if song != current_song:
                current_song = song
                scroll_position = 0

            if status == "playing":

                # Just resumed -> restart scrolling.
                if last_status != "playing":
                    scroll_position = 0

                display_text = format_window(
                    title,
                    artist,
                    scroll_position,
                )

                scroll_position += 1

                # Restart after reaching the end.
                if scroll_position >= len(song) + len(SCROLL_GAP):
                    scroll_position = 0

            else:
                # Paused -> show the complete formatted song.
                display_text = format_static_song(title, artist)

                # Resume from the beginning.
                scroll_position = 0

        last_status = status

        out_data = {
            "text": display_text,
            "class": [class_name],
        }

        print(json.dumps(out_data))
        time.sleep(REFRESH_INTERVAL)
