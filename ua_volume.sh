#!/bin/bash
#
# Two-phase volume control:
#
# Phase 1 (up/down): Append direction to events file and exit immediately.
#   This takes <1ms, so Karabiner never drops events.
#
# Phase 2 (work): A single background worker drains the events file in a
#   loop, waiting for the knob to settle, then applies the net change as
#   one `set volume to` call. Only one worker runs at a time (flock -n).
#

EVENTS_FILE="/tmp/ua_volume_events"
LOCK="/tmp/ua_volume_worker.lock"
STATE="/tmp/ua_volume_db"
LOG="/tmp/ua_volume.log"
STEP=1.0

case "$1" in
    up|down)
        # Phase 1: record event and exit fast
        if [ "$1" = "up" ]; then
            echo "1" >> "$EVENTS_FILE"
        else
            echo "-1" >> "$EVENTS_FILE"
        fi
        echo "$(date '+%H:%M:%S.%N') EVENT $1" >> "$LOG"

        # Try to start a worker in the background (non-blocking)
        /opt/homebrew/bin/flock -n "$LOCK" "$0" work &
        ;;

    work)
        # Phase 2: we hold the lock — drain events until knob settles
        while true; do
            TOTAL=0

            # Accumulate events until no new ones arrive within the window
            while true; do
                sleep 0.08

                mv "$EVENTS_FILE" "${EVENTS_FILE}.batch" 2>/dev/null
                if [ -f "${EVENTS_FILE}.batch" ]; then
                    BATCH=$(awk '{s+=$1} END {print s+0}' "${EVENTS_FILE}.batch")
                    rm -f "${EVENTS_FILE}.batch"
                    TOTAL=$((TOTAL + BATCH))
                else
                    break
                fi
            done

            if [ "$TOTAL" -eq 0 ]; then
                break
            fi

            echo "$(date '+%H:%M:%S.%N') BATCH total=$TOTAL" >> "$LOG"

            DEVICE=$(/opt/homebrew/bin/SwitchAudioSource -c 2>/dev/null)
            if [[ "$DEVICE" == *"Universal Audio"* ]]; then
                CURRENT=$(cat "$STATE" 2>/dev/null)
                : "${CURRENT:=-20.0}"
                NEW=$(awk "BEGIN {v = $CURRENT + $TOTAL * $STEP; if (v > 0) v = 0; if (v < -96) v = -96; printf \"%.1f\", v}")
                echo "$NEW" > "$STATE"
                echo "$(date '+%H:%M:%S.%N') SET_VOLUME $CURRENT -> $NEW (delta=$TOTAL)" >> "$LOG"
                /usr/bin/osascript -e "tell application \"UA Companion\" to set volume to $NEW"
            else
                DELTA=$(awk "BEGIN {printf \"%.2f\", $TOTAL * 6.25}")
                /usr/bin/osascript -e "set volume output volume (output volume of (get volume settings) + $DELTA)"
            fi

            # Loop back to catch any events that arrived during processing
        done

        echo "$(date '+%H:%M:%S.%N') WORKER_EXIT" >> "$LOG"
        ;;
esac
