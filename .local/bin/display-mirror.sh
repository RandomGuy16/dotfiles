#!/usr/bin/env bash
hyprctl keyword monitor "eDP-1,1920x1080@60,auto,1"
hyprctl keyword monitor "HDMI-A-1,1920x1080@60,auto,1,mirror,eDP-1"

notify-send -a "Hyprctl monitor" "Display mode" "Mirror"
