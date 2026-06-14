#!/bin/bash

# 1. Spawn hyprlock in the background
hyprlock &

# 2. Wait for hyprlock to finish rendering its UI
sleep 0.5

# 3. Take the full screen capture and alert the user
TIME=$(date +%Y-%m-%d_%H:%M:%S)
DIR="$HOME/Pictures/Screenshots"

grimblast copysave screen "$DIR/$TIME.png"
notify-send "Screenshot saved" "$TIME.png" -t 5000 -i "$DIR/$TIME.png"
