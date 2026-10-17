#!/usr/bin/env bash
# privacy dots for Waybar
# mic:  green, cam: orange, location: blue

set -euo pipefail

# Dependencies: pipewire (pw-dump), jq, dbus-send (dbus)
JQ_BIN="${JQ:-jq}"
PW_DUMP_CMD="${PW_DUMP:-pw-dump}"
DBUS_SEND="${DBUS_SEND:-dbus-send}"

cam=0
loc=0

# mic & camera
if command -v "$PW_DUMP_CMD" >/dev/null 2>&1 && command -v "$JQ_BIN" >/dev/null 2>&1; then
  dump="$($PW_DUMP_CMD 2>/dev/null || true)"

  cam="$(
    printf '%s' "$dump" |
      $JQ_BIN -r '
      [ .[] 
        | select(.type=="PipeWire:Interface:Node")
        | select(.info.props."media.class"=="Video/Source")
        | select((.info.state=="running") or (.state=="running"))
      ] | (if length>0 then 1 else 0 end)
    ' 2>/dev/null || echo 0
  )"

fi

# location
# add location here

dot() {
  printf '●'
}

text="$(dot "$1")"
tooltip="Cam: $([[ $cam -eq 1 ]] && echo on || echo off) | Location: $([[ $loc -eq 1 ]] && echo on || echo off)"

[[ $1 -eq 1 ]] && class="on" || class="off"

#printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$classes"

text_escaped="${text//#/\\u0023}"
tooltip_escaped="${tooltip//#/\\u0023}"

jq -c -n --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" \
  '{text:$text, tooltip:$tooltip, class:$class}'
