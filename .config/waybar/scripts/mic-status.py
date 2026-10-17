#!/usr/bin/env python3

import json
import re
import subprocess

# applications that are trusted to consume audio
# application names are matched case-insensitively.
# you can write them in any case, but lowercase is jsut easier -_-
IGNORED_APPS = {
    "cava",
    "wiremix",
    "wiremix-capture",
    "audio_ducking_detector",
}


def get_wpctl_status():
    result = subprocess.run(
        ["wpctl", "status"],
        capture_output=True,
        text=True,
        check=True,
    )

    return result.stdout


def get_untrusted_audio_apps():
    output = get_wpctl_status()

    in_audio = False
    in_streams = False
    current_app = None

    detected_apps = set()

    for line in output.splitlines():

        stripped = line.strip()

        # Enter Audio section
        if stripped == "Audio":
            in_audio = True
            continue

        # Stop before Video section
        if in_audio and stripped == "Video":
            break

        if not in_audio:
            continue

        # Enter Streams section
        if stripped == "└─ Streams:":
            in_streams = True
            continue

        if not in_streams:
            continue

        # --------------------------------------------------
        # CONNECTION
        # --------------------------------------------------

        connection = re.match(
            r"^\s+\d+\.\s+(input_|output_|monitor_)",
            line,
        )

        if connection:
            # Only active connections
            if "[active]" not in line:
                continue

            # Only audio flowing INTO the stream
            if "<" not in line:
                continue

            # Ignore trusted applications
            if current_app_normalized in IGNORED_APPS:
                continue

            # Remember the application
            detected_apps.add(current_app)

            continue

        # --------------------------------------------------
        # STREAM HEADER
        # --------------------------------------------------

        stream = re.match(
            r"^\s+\d+\.\s+(.+?)\s*$",
            line,
        )

        if stream:
            current_app = stream.group(1)
            current_app_normalized = current_app.lower()

    return detected_apps


def get_default_source_volume():
    result = subprocess.run(
        ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"],
        capture_output=True,
        text=True,
        check=True,
    )

    output = result.stdout

    # Microphone muted
    if "MUTED" in output:
        return "󰍭"

    # Extract volume
    match = re.search(r"Volume:\s+([0-9.]+)", output)

    if not match:
        return ""

    volume = float(match.group(1)) * 100
    volume = round(volume)

    return f"󰍬 {volume}%"


def main():
    detected_apps = get_untrusted_audio_apps()

    # Nothing consuming an audio source
    if not detected_apps:
        return

    text = get_default_source_volume()

    # Sort so the tooltip doesn't randomly change order
    apps = sorted(detected_apps)

    tooltip = "Audio being consumed by:\n" + "\n".join(f"• {app}" for app in apps)

    output = {
        "text": text,
        "tooltip": tooltip,
        "class": "active",
    }

    print(json.dumps(output))


if __name__ == "__main__":
    main()
