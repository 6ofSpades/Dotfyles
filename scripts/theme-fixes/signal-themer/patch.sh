#!/bin/bash

# You need to have asar installaed
# If on Arch, sudo pacman -S asar
if ! command -v asar &>/dev/null; then
  echo "asar missing, install package asar first"
  read -rp "Install asar now? [y/n] " asar
  [[ "$asar" == "y" ]] && sudo pacman -S asar || exit 1
fi

SIGNAL_DIR="/usr/lib/signal-desktop/resources"
# If using the Flatpak version the Signal directory should be:
# SIGNAL_DIR="/var/lib/flatpak/app/org.signal.Signal/current/active/files/Signal/resources"

TEMP=$(mktemp -d)

# Extract signal into the temporary directory
echo "Extracting Signal..."
asar e "${SIGNAL_DIR}/app.asar" ${TEMP}

# Copy the theme file into the asar folder
echo "Applying theme..."
cp -rf theme.css "${TEMP}/stylesheets/theme.css"
cp -rf tray-icons/ "${TEMP}/images/"

# Add import for the theme to the start of manifest.css
# First check if the import is already there so we don't need to re-add it
if ! grep -q '@import "theme.css"' "${TEMP}/stylesheets/manifest.css"; then
  sed -i "1i @import \"theme.css\";" "${TEMP}/stylesheets/manifest.css"
fi

# Now for the transparency part
# Check if transparency is already applied
echo "Enabling transparency..."
if ! grep -q 'transparent: true' "${TEMP}/app/main.main.js"; then
  sed -i '/const windowOptions = {/,/}/ {/^[[:space:]]*backgroundColor,*/d}' "${TEMP}/app/main.main.js"
  sed -i '/const windowOptions = {/a \    transparent: true,\n    frame: false,\n    backgroundColor: "#00000000",' "${TEMP}/app/main.main.js"
  #sed -i '/const windowOptions = {/a \  transparent: true,\n  frame: false,\n  backgroundColor: "#00000000",' "${TEMP}/app/main.js"
else
  echo "Transparency already applied."
fi

# Pack the new theme into a new app.asar (needs sudo in order to write to /usr/lib)
echo "Repacking... (sudo is needed)"
sudo asar p ${TEMP} "${SIGNAL_DIR}/app.asar"

# Cleaning temp directory
rm -rf "$TEMP"

echo "Done."


