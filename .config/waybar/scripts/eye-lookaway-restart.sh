#!/usr/bin/env bash

# Trigger reset instantly
echo reset >/tmp/eye-lookaway-pipe
notify-send -u "normal" -a "Eye health" "Timer reset!" "20 minutes to work ;)!"
