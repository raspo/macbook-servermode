#!/bin/bash
set -u
[ "$(id -u)" -eq 0 ] || { echo "Run with sudo: sudo $0" >&2; exit 1; }

LABEL=local.servermode

launchctl bootout "system/$LABEL" 2>/dev/null
rm -f "/Library/LaunchDaemons/$LABEL.plist" /usr/local/sbin/servermode.sh
pmset -a disablesleep 0

echo "servermode removed"
echo "SleepDisabled: $(pmset -g | awk '/SleepDisabled/ {print $2}')"
