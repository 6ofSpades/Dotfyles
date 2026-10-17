#!/bin/bash

# Check active screen sharing/capturing streams via PipeWire properties with state verification
if pw-dump 2>/dev/null | jq -e '
  [ .[] | select(.type == "PipeWire:Interface:Node") | 
    select(.info.state == "running") | .info.props | 
    select(
      (.["media.class"]? // "" | ascii_downcase | test("video|screencast|capture")) or
      (.["media.role"]? // "" | ascii_downcase | test("screencast|video")) or
      (.["stream.is-screenshare"]? == "true") or
      (.["pipewire.stream.is-desktop"]? == "true")
    )
  ] | length > 0
' >/dev/null; then
  echo " "
fi
