#!/bin/bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo: sudo $0" >&2; exit 1; }
cd "$(dirname "$0")"

LABEL=local.servermode
BIN=/usr/local/sbin/servermode.sh
PLIST=/Library/LaunchDaemons/$LABEL.plist

mkdir -p "$(dirname "$BIN")"
install -o root -g wheel -m 755 servermode.sh "$BIN"
install -o root -g wheel -m 644 "$LABEL.plist" "$PLIST"
xattr -c "$BIN" "$PLIST"

launchctl bootout "system/$LABEL" 2>/dev/null || true
launchctl bootstrap system "$PLIST"
sleep 2

if pgrep -f "$BIN" >/dev/null; then echo "servermode is running"; else echo "ERROR: servermode is not running" >&2; exit 1; fi
echo "Power source:  $(pmset -g ps | head -1 | sed "s/.*'\(.*\)'.*/\1/")"
echo "SleepDisabled: $(pmset -g | awk '/SleepDisabled/ {print $2}')"
