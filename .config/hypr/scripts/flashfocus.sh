#!/usr/bin/env bash

# Flashfocus plugin seems like it was abandoned
# None of the forks seem to work for me
# I can't live without that plugin
# Hopefully this will work for kinda replacing it T-T

# Flashfocus: safely flash a window's opacity.
# Overlapping flashes preserve the original opacity.

address="${1:-}"
flash_opacity="0.65"
flash_duration="0.1"

[[ "$address" =~ ^0x[[:xdigit:]]+$ ]] || exit 1

state_dir="${XDG_RUNTIME_DIR:-/tmp}/flashfocus-$UID"
mkdir -p "$state_dir" || exit 1
chmod 700 "$state_dir"

state_file="$state_dir/$address.state"
lock_file="$state_dir/$address.lock"

# Serialize state changes for this particular window.
exec 9>"$lock_file" || exit 1
flock -x 9 || exit 1

# Don't operate on a window that has already closed.
if ! hyprctl clients -j |
  jq -e --arg address "$address" \
    '.[] | select(.address == $address)' >/dev/null; then
  rm -f "$state_file"
  exit 0
fi

# If another flash is running, preserve its original opacity.
# Otherwise, read the current opacity before applying the flash.
if [[ -f "$state_file" ]]; then
  IFS= read -r original_opacity <"$state_file"
else
  original_opacity=$(hyprctl getprop "address:$address" opacity 2>/dev/null) ||
    exit 0
  original_opacity="${original_opacity//[[:space:]]/}"
fi

# Validate the saved value.
[[ "$original_opacity" =~ ^[0-9]*\.?[0-9]+$ ]] || exit 0

# This invocation becomes the only one allowed to restore opacity.
token="$$-$RANDOM-$(date +%s%N)"
tmp_file="$state_file.tmp.$token"

printf '%s\n%s\n' "$original_opacity" "$token" >"$tmp_file" ||
  exit 1
mv -f "$tmp_file" "$state_file" || exit 1

# Flash the window.
hyprctl dispatch \
  "hl.dsp.window.set_prop({ window = 'address:$address', prop = 'opacity', value = '$flash_opacity' })"

# Allow another invocation to take over while we wait.
flock -u 9
sleep "$flash_duration"
flock -x 9 || exit 1

# Read the current state.
if [[ ! -f "$state_file" ]]; then
  exit 0
fi

IFS= read -r saved_opacity <"$state_file"
IFS= read -r saved_token < <(tail -n 1 "$state_file")

# A newer flash owns this window now. Leave restoration to it.
if [[ "$saved_token" != "$token" ]]; then
  exit 0
fi

# Only the latest flash may restore the original opacity.
if hyprctl clients -j |
  jq -e --arg address "$address" \
    '.[] | select(.address == $address)' >/dev/null; then

  hyprctl dispatch \
    "hl.dsp.window.set_prop({ window = 'address:$address', prop = 'opacity', value = '$saved_opacity' })"
fi

rm -f "$state_file"
