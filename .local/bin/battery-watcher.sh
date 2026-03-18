#!/usr/bin/env bash

NOTIFIED_CRITICAL=0
NOTIFIED_LOW=0
NOTIFIED_FULL=0

LAST_PERC="101"
PERC=""
LAST_STATUS="0"
STATUS=""

LAST_LINE=""

upower -m | while read -r line; do
  # skip upower spamming signals
  [ "$line" = "$LAST_LINE" ] && continue

  # get current state
  BATTERY_PATH=$(upower -e | grep 'battery')
  PERC=$(upower -i "$BATTERY_PATH" | grep "percentage" | awk "{print \$2}" | tr -d '%')
  STATUS=$(upower -i "$BATTERY_PATH" | grep "state" | awk "{print \$2}")

  # skip if upower failed
  [ -z "$PERC" ] && continue
  # also if we are on the same spot, in battery
  [ "$LAST_PERC" = "$PERC" ] && [ "$LAST_STATUS" = "$STATUS" ] && continue

  if [ "$STATUS" = "discharging" ]; then
    NOTIFIED_FULL=0 # we're no longer full

    # notifications
    if [ "$PERC" -le 20 ] && [ $NOTIFIED_LOW -eq 0 ]; then
      powerprofilesctl set power-saver
      notify-send -a "Battery watcher" -u "critical" -i "battery-low" "Low battery" "Battery at 20%, plug in the charger"
      NOTIFIED_LOW=1
    elif [ "$PERC" -le 10 ] && [ $NOTIFIED_CRITICAL -eq 0 ]; then
      powerprofilesctl set power-saver
      notify-send -a "Battery watcher" -u "critical" -i "battery-caution" "Critical battery" "Battery at 10%, shutting down in 60 seconds"
      NOTIFIED_CRITICAL=1
      # this skedules shutdown
      shutdown +1
    fi
  elif [ "$STATUS" = "charging" ]; then
    # this cancels shutdown
    if [ "$NOTIFIED_CRITICAL" -eq 1 ]; then
      notify-send -a "Battery watcher" -u "low" -i "battery-charging" "Charging battery" "You connected the charger before the shutdown, good job!"
      shutdown -c
    fi

    NOTIFIED_CRITICAL=0
    NOTIFIED_LOW=0

    if [ "$PERC" -ge 80 ] && [ $NOTIFIED_FULL -eq 0 ]; then
      notify-send -a "Battery watcher" -u "critical" -i "battery-full" "Full battery" "Battery at 80%, good work :)"
      NOTIFIED_FULL=1
    fi
  fi

  LAST_PERC=$PERC
  LAST_STATUS=$STATUS
  LAST_LINE=$line

done
