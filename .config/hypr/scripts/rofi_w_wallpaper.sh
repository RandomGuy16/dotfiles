#!/usr/bin/env bash

curr_wallpaper="$(tr -d '\r\n' </tmp/curr_wallpaper)"

rofi -show "$1" -theme "/home/aroon/.config/rofi/config-drun.rasi" -theme-str "inputbar { background-image: url(\"$curr_wallpaper\", width); }"
