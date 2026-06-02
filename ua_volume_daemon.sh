#!/bin/zsh
#
# Persistent daemon for UA Companion volume control.
#
# 1. Monitors the default audio output device every 2 seconds.
#    Sets the Karabiner variable "ua_connected" so Karabiner only
#    intercepts volume keys when UA is the active device.
#
# 2. Reads volume/mute commands from a named pipe (FIFO).
#    Batches rapid events (80ms window) and builds a single osascript
#    call with N increase/decrease commands — no state tracking needed.
#

PIPE="/tmp/ua_volume_pipe"
LOG="/tmp/ua_volume.log"
KCLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"
SWITCH="/opt/homebrew/bin/SwitchAudioSource"

# --- Setup FIFO ---
[ -p "$PIPE" ] || mkfifo "$PIPE"
exec 3<> "$PIPE"  # open read-write to prevent blocking

# --- Audio device monitor (background) ---
LAST_UA_STATE=""
update_device() {
    local device=$("$SWITCH" -c 2>/dev/null)
    local is_ua=0
    [[ "$device" == *"Universal Audio"* ]] && is_ua=1

    if [ "$is_ua" != "$LAST_UA_STATE" ]; then
        "$KCLI" --set-variables "{\"ua_connected\":$is_ua}" 2>/dev/null
        LAST_UA_STATE="$is_ua"
        echo "$(date '+%H:%M:%S') DEVICE_CHANGE ua_connected=$is_ua ($device)" >> "$LOG"
    fi
}

update_device
(
    while true; do
        sleep 2
        update_device
    done
) &
MONITOR_PID=$!
trap "kill $MONITOR_PID 2>/dev/null; exit" INT TERM

# --- Main loop: read commands from FIFO ---
while true; do
    # Block until a command arrives
    read -r CMD <&3 || continue

    case "$CMD" in
        mute)
            if [ -f "/tmp/ua_companion_muted" ]; then
                /usr/bin/osascript -e 'tell application "UA Companion" to unmute'
                rm -f "/tmp/ua_companion_muted"
            else
                /usr/bin/osascript -e 'tell application "UA Companion" to mute'
                touch "/tmp/ua_companion_muted"
            fi
            echo "$(date '+%H:%M:%S.%N') MUTE_TOGGLE" >> "$LOG"
            continue
            ;;
    esac

    TOTAL=0
    case "$CMD" in
        up)   TOTAL=1 ;;
        down) TOTAL=-1 ;;
        *)    continue ;;
    esac

    # Drain additional events that arrived within 80ms batching window
    while read -r -t 0.08 CMD <&3; do
        case "$CMD" in
            up)   TOTAL=$((TOTAL + 1)) ;;
            down) TOTAL=$((TOTAL - 1)) ;;
        esac
    done

    [ "$TOTAL" -eq 0 ] && continue

    # Build a single AppleScript with N increase/decrease calls
    if [ "$TOTAL" -gt 0 ]; then
        VERB="increase volume"
        COUNT=$TOTAL
    else
        VERB="decrease volume"
        COUNT=$(( -TOTAL ))
    fi

    SCRIPT="tell application \"UA Companion\""
    for i in $(seq 1 $COUNT); do
        SCRIPT="$SCRIPT
    $VERB"
    done
    SCRIPT="$SCRIPT
end tell"

    echo "$(date '+%H:%M:%S.%N') VOLUME delta=$TOTAL ($COUNT x $VERB)" >> "$LOG"
    /usr/bin/osascript -e "$SCRIPT"
done
