#!/usr/bin/env bash

TMP_FILE="/tmp/eye-lookaway-tmp"
WORK_DURATION=$((20 * 60)) # 20 minutes
BREAK_DURATION=30          # 30 seconds
time_left=$WORK_DURATION
mode="work"

jq -nc '{"text": "󱎴 20:00", "tooltip": "initializing counter", "class": "work"}'

# ensure tmp file exists
: >"$TMP_FILE"

# Background reader that waits for reset signals
# We'll feed its output into a named pipe
mkfifo /tmp/eye-lookaway-pipe 2>/dev/null || true
(tail -f "$TMP_FILE" >/tmp/eye-lookaway-pipe) &

while true; do
	# use read with timeout to wait 1s or react faster if file gets new data
	if timeout 1 cat /tmp/eye-lookaway-pipe >/dev/null 2>&1; then
		# reset event triggered
		time_left=$WORK_DURATION
		mode="work"
	fi

	# display formatted time
	mins=$((time_left / 60))
	secs=$((time_left % 60))
	printf -v text "%02d:%02d" "$mins" "$secs"

	if [[ $mode == "work" ]]; then
		tooltip="Time until eye break"
		class="work"
		icon="󱎴 "
	else
		tooltip="Look away for 20 seconds!"
		class="break"
		icon="󱣿 "
	fi

	# output JSON for Waybar
	jq -nc --arg text "$icon$text" \
		--arg tooltip "$tooltip" \
		--arg class "$class" \
		'{"text":$text, "tooltip":$tooltip, "class":$class}'

	# countdown logic
	((time_left--))
	if ((time_left <= 0)); then
		if [[ $mode == "work" ]]; then
			mode="break"
			time_left=$BREAK_DURATION
			notify-send -u "normal" -a "Eye health" "Time to rest!" "Take a break looking at something 6 meters away right now!"
		else
			mode="work"
			time_left=$WORK_DURATION
			notify-send -u "normal" -a "Eye health" "Back to work!" "You can continue with your hard work ;)!"
		fi
	fi
done
