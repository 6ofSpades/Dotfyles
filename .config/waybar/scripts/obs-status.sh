#!/bin/bash

# Check if OBS process is even running first
if ! pgrep -x obs >/dev/null; then
  # Hide module completely when OBS is closed
  echo '{"text": "", "class": "disconnected"}'
  exit 0
fi

# Query recording status using obs-cmd
# (Ensure obs-cmd is configured or matches your websocket port/password)
STATUS=$(obs-cmd recording status 2>/dev/null)

if echo "$STATUS" | grep -q "Active: true" && echo "$STATUS" | grep -q "Paused: false"; then
  # Actively recording
  echo '{"text": "  REC", "class": "recording"}'
elif echo "$STATUS" | grep -q "Paused: true"; then
  echo '{"text": "  REC", "class": "paused"}'
else
  # OBS is open, but idle
  echo '{"text": "  REC", "class": "idle"}'
fi
