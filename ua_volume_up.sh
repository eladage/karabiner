#!/bin/bash
LOCK_FILE="/tmp/ua_volume.lock"

exec 9>"$LOCK_FILE"
if ! /opt/homebrew/bin/flock -n 9; then
    exit 0
fi

DEVICE=$(/opt/homebrew/bin/SwitchAudioSource -c 2>/dev/null)
if echo "$DEVICE" | grep -q "Universal Audio"; then
    /usr/bin/osascript -e 'tell application "UA Companion" to increase volume'
else
    /usr/bin/osascript -e 'set volume output volume (output volume of (get volume settings) + 6.25)'
fi
