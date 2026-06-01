#!/bin/bash
MUTE_STATE_FILE="/tmp/ua_companion_muted"

if [ -f "$MUTE_STATE_FILE" ]; then
    /usr/bin/osascript -e 'tell application "UA Companion" to unmute'
    rm "$MUTE_STATE_FILE"
else
    /usr/bin/osascript -e 'tell application "UA Companion" to mute'
    touch "$MUTE_STATE_FILE"
fi
