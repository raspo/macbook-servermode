#!/bin/bash
PATH=/usr/bin:/bin:/usr/sbin:/sbin

POLL_SECS=5
BATTERY_GRACE_SECS=10
MIN_IDLE_SECS_BEFORE_FORCED_SLEEP=10

on_ac_power()    { pmset -g ps | head -1 | grep -q "'AC Power'"; }
sleep_disabled() { [ "$(pmset -g | awk '/SleepDisabled/ {print $2; exit}')" = 1 ]; }
lid_closed()     { ioreg -r -k AppleClamshellState -d 1 | grep -q '"AppleClamshellState" = Yes'; }
idle_secs()      { ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}'; }
log()            { logger "servermode: $*"; }

disable_sleep() { sleep_disabled || { pmset -a disablesleep 1; log "AC power: sleep disabled"; }; }
enable_sleep()  { sleep_disabled && { pmset -a disablesleep 0; log "battery: sleep enabled"; }; }

on_battery_since=0
lid_check_pending=0

while :; do
  now=$(date +%s)
  if on_ac_power; then
    on_battery_since=0
    lid_check_pending=0
    disable_sleep
  else
    if [ "$on_battery_since" -eq 0 ]; then
      on_battery_since=$now
      lid_check_pending=1
    fi
    if [ $((now - on_battery_since)) -ge "$BATTERY_GRACE_SECS" ]; then
      enable_sleep
      if [ "$lid_check_pending" = 1 ]; then
        if ! lid_closed; then
          lid_check_pending=0
        elif [ "$(idle_secs)" -ge "$MIN_IDLE_SECS_BEFORE_FORCED_SLEEP" ]; then
          lid_check_pending=0
          log "battery with lid closed: sleeping now"
          sleep 2
          pmset sleepnow
        fi
      fi
    fi
  fi
  sleep "$POLL_SECS"
done
