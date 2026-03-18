#!/usr/bin/env bash
hyprctl keyword monitor "eDP-1,disable"
hyprctl keyword monitor "HDMI-A-1,preferred,auto,1"
notify-send -a "Hyprctl monitor" "Display mode" "External"
