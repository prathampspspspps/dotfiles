#!/bin/bash
# Wrapper script that ensures clean process detachment for the spectrum daemon.
# Args: <log-path> <daemon-script> <device> <bars> <smoothing> <sensitivity> <output-path>

set +e
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

LOG="$1"
DAEMON="$2"
DEVICE="$3"
BARS="$4"
SMOOTH="$5"
SENS="$6"
OUTPUT="$7"

exec >>"$LOG" 2>&1

echo "=== launcher $(date '+%F %T %Z') device=$DEVICE bars=$BARS ==="

# Match only python invocations of the daemon — not our wrapper script,
# which has the daemon path as a positional arg.
pkill -f '^python3? .*spectrum-daemon\.py' >/dev/null 2>&1 || true
rm -f "$OUTPUT" "$OUTPUT.port"
sleep 0.2

exec python3 "$DAEMON" \
    --daemonize \
    --log "$LOG" \
    --device "$DEVICE" \
    --bars "$BARS" \
    --smoothing "$SMOOTH" \
    --sensitivity "$SENS" \
    --output "$OUTPUT"
