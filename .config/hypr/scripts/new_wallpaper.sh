#!/usr/bin/env bash

if ! pgrep -x "hyprpaper" >/dev/null; then
  hyprctl dispatch exec hyprpaper
  sleep 1
fi

WALLPAPER_DIR="$HOME/Pictures/wallpapers/"
CURRENT_WALL=$(cat /tmp/curr_wallpaper)

# Get a random wallpaper that is not the current one
WALLPAPER=""
if [ "$1" ]; then
  WALLPAPER="$WALLPAPER_DIR$1"
else
  WALLPAPER=$(find "$WALLPAPER_DIR" -type f ! -name "$(basename "$CURRENT_WALL")" | shuf -n 1)
fi

# Change wallpaper if hyprpaper is running
hyprctl hyprpaper wallpaper ",$WALLPAPER,cover"

# Store the previous wallpaper manually
echo "$WALLPAPER" >/tmp/curr_wallpaper
