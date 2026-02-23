import subprocess
import time
import json
import sys
import html

# Customization settings (easy to modify)
GLYPH_FONT_FAMILY="Symbols Nerd Font Mono" # Set to your desired symbols font
# Those are glyphs that will be always visible at left side of module.
GLYPHS = {
    "paused": " ",
    "playing": " ",
    "stopped": " "
}
DEFAULT_GLYPH = " "  # Glyph when status is unknown or default
TEXT_WHEN_STOPPED = "               MPRIS"  # Text to display when nothing is playing
SCROLL_TEXT_LENGTH = 55  # Length of the song title part (excludes glyph and space)
FORCE_SCROLL = True # Set to True if you want all songs to scroll regardless of length
REFRESH_INTERVAL = 0.5  # How often the script updates (in seconds)
PLAYERCTL_PATH = "/usr/bin/playerctl" # Path to playerctl, use which playerctl to find yours.

# Function to get player status using playerctl
def get_player_status():
    try:
        result = subprocess.run([PLAYERCTL_PATH, 'status'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        status = result.stdout.decode('utf-8').strip().lower()
        if result.returncode != 0 or not status:
            return "stopped"  # Default to stopped if no status
        return status
    except Exception as e:
        return "stopped"

# Function to get currently playing song using playerctl
def get_current_song():
    try:
        result = subprocess.run(
            [PLAYERCTL_PATH, 'metadata', '--format', '  {{title}}   {{artist}}'],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        song_info = result.stdout.decode('utf-8').strip()
        if result.returncode != 0 or not song_info:
            return None
        return song_info
    except Exception as e:
        return None

# Function to generate scrolling text with fixed length
def scroll_text(text, length=SCROLL_TEXT_LENGTH):
    text = text.ljust(length)  # Ensure the text is padded to the desired length
    scrolling_text = text + ' ' + text[:length]  # Add space and repeat start for scrolling effect
    
    for i in range(len(scrolling_text) - length):
        yield scrolling_text[i:i + length]  # Use a generator to yield scrolling parts


if __name__ == "__main__":
    scroll_generator = None
    current_song = None
    last_status = None
    last_text_frame = ""

    while True:
        output = {}

        try:
            # Get the player status and song title
            status = get_player_status()
            song = get_current_song()

            # Get the glyph based on player status
            glyph = GLYPHS.get(status, DEFAULT_GLYPH)

            # Detect song change → reset scrolling
            if song != current_song:
                scroll_generator = None
                current_song = song

            if song:
                if len(song) > SCROLL_TEXT_LENGTH or FORCE_SCROLL:
                    # Only scroll when playing
                    if scroll_generator is None:
                        scroll_generator = scroll_text(song)

                    if status == "playing":
                        try:
                            last_text_frame = next(scroll_generator)
                        except StopIteration:
                            scroll_generator = scroll_text(song)
                            last_text_frame = next(scroll_generator)
                    # if paused/stopped, keep last_text_frame as is
                    song_text = last_text_frame
                    if status == 'paused':
                        song_text = current_song
                else:
                    song_text = song.ljust(SCROLL_TEXT_LENGTH)
                    scroll_generator = None
            else:
                song_text = TEXT_WHEN_STOPPED.ljust(SCROLL_TEXT_LENGTH)
                scroll_generator = None

            escaped_song_text = html.escape(song_text)
            output["text"] = f"<span font_family='{GLYPH_FONT_FAMILY}'>{glyph}</span> {escaped_song_text}"

        except Exception as e:
            output["text"] = f" Error: {str(e)}".ljust(SCROLL_TEXT_LENGTH + 2)

        print(json.dumps(output), end='\n')
        time.sleep(REFRESH_INTERVAL)

