#!/bin/bash

# Applications that are trusted to consume audio input.
# Add/remove applications as needed.
IGNORED_APPS=(
)

is_capturing=false
current_app=""

while IFS= read -r line; do

  # Start looking only inside Audio -> Streams
  if [[ "$line" == *"└─ Streams:"* ]]; then
    in_streams=true
    continue
  fi

  # Stop when we leave the Audio section
  if [[ "$in_streams" == true && "$line" == "Video" ]]; then
    break
  fi

  [[ "$in_streams" != true ]] && continue

  # A stream header looks like:
  #
  #     50. cava
  #    131. OBS
  #    170. OBS
  #
  if [[ "$line" =~ ^[[:space:]]+[0-9]+\.[[:space:]]+([^[:space:]]+) ]]; then
    current_app="${BASH_REMATCH[1]}"
    continue
  fi

  # We only care about active audio input connections.
  #
  # This deliberately does NOT check whether the connection is
  # capture_* or monitor_*.
  #
  # Any active connection using this stream as an input can count.
  if [[ "$line" =~ \<.*\[active\] ]]; then

    # Check whether this application's name is trusted.
    ignored=false

    for app in "${IGNORED_APPS[@]}"; do
      if [[ "$current_app" == "$app" ]]; then
        ignored=true
        break
      fi
    done

    # An active stream belonging to a non-ignored application
    # means something is consuming audio.
    if [[ "$ignored" == false ]]; then
      is_capturing=true
      break
    fi
  fi

done < <(wpctl status)

# If something is consuming audio, check the microphone volume/mute state.
if [ "$is_capturing" = true ]; then

  volume=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null)

  if [[ "$volume" == *"MUTED"* ]]; then
    echo "󰍭"
  else
    volume=${volume#Volume: }
    volume=$(echo "$volume * 100" | bc)
    volume=${volume%.*}

    echo "󰍬 $volume%"
  fi

fi
