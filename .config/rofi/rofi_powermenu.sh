#!/usr/bin/env bash
set -euo pipefail

ROFI_POWERMENU_THEME="${ROFI_THEME:-$HOME/.config/rofi/config-powermenu.rasi}"
ROFI_CONFIRM_THEME="$HOME/.config/rofi/config-confirm.rasi"
curr_wallpaper="$(tr -d '\r\n' </tmp/curr_wallpaper)"

options=$'⏻\n\n󰤄\n󰒲\n\n󰈆'
choice="$(printf '%s\n' "$options" | rofi -dmenu -i -p "Power" -theme "$ROFI_POWERMENU_THEME" -theme-str "inputbar { background-image: url(\"$curr_wallpaper\", width); }") "

confirm() {
  printf "No\nSí\n" | rofi -dmenu -i -p "¿Seguro?" -theme "$ROFI_CONFIRM_THEME"
}

case "$choice" in
⏻*)
  [[ "$(confirm)" == "Sí" ]] && systemctl poweroff
  ;;
*)
  [[ "$(confirm)" == "Sí" ]] && systemctl reboot
  ;;
󰤄*)
  [[ "$(confirm)" == "Sí" ]] && systemctl suspend
  ;;
󰒲*)
  [[ "$(confirm)" == "Sí" ]] && systemctl hibernate
  ;;
*)
  # Cambia esto según tu lockscreen:
  # Wayland/Hyprland: swaylock
  # X11: i3lock / betterlockscreen
  if command -v swaylock >/dev/null; then
    swaylock
  elif command -v i3lock >/dev/null; then
    i3lock
  elif command -v betterlockscreen >/dev/null; then
    betterlockscreen -l
  elif command -v hyprlock >/dev/null; then
    hyprlock
  else
    rofi -e "No encuentro lockscreen (swaylock/i3lock/betterlockscreen/hyprlock)."
  fi
  ;;
󰈆*)
  [[ "$(confirm)" == "Sí" ]] || exit 0
  # Detecta sesión
  if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null; then
    hyprctl dispatch exit
  elif [ -n "${SWAYSOCK:-}" ] && command -v swaymsg >/dev/null; then
    swaymsg exit
  elif command -v i3-msg >/dev/null; then
    i3-msg exit
  elif command -v loginctl >/dev/null; then
    loginctl terminate-user "$USER"
  else
    rofi -e "No sé cómo cerrar sesión en tu WM/DE."
  fi
  ;;
*)
  exit 0
  ;;
esac
