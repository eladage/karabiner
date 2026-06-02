#!/bin/bash
# Trigger: write command to daemon's pipe and exit immediately.
# This takes <1ms — no osascript, no device checks.
echo "$1" > /tmp/ua_volume_pipe 2>/dev/null &
