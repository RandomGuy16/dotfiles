#!/usr/bin/env bash
hyprctl keyword monitor "eDP-1,preferred,auto,1"
hyprctl keyword monitor "HDMI-A-1,preferred,1920x0,1"
notify-send -a "Hyprctl monitor" "Display mode" "Extend"
