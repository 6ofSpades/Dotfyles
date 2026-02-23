#!/bin/bash

# The color you want to use
# Should be RGB with just the numbers, eg.: 32,20,38
COLOR="105,0,133"

# Replace this with the name of the colorscheme you're using
COLOR_SCHEME="BreezeDark.colors"

# sudo is needed cause its a system wide folder
echo 'Tweaking color scheme... - sudo is needed for editing system wide folder'
sudo sed -i "/^\[Colors:Selection\]/,/^$/ {
    s/^BackgroundAlternate=.*/BackgroundAlternate=${COLOR}/
    s/^BackgroundNormal=.*/BackgroundNormal=${COLOR}/
}" /usr/share/color-schemes/${COLOR_SCHEME}

echo 'Done.'
