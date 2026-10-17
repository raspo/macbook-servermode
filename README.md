# macbook-servermode

Keeps your MacBook awake while it's plugged in, even with the lid closed. Unplug it and it goes back to sleeping like a normal laptop.

Handy for leaving coding agents or other long-running jobs working on a MacBook with the lid closed, without turning off sleep for good.

## How it works

A small background service checks every 5 seconds whether the Mac is plugged in:

- **Plugged in**: sleep is turned off (`pmset disablesleep 1`), so the Mac stays awake even with the lid closed.
- **Unplugged for more than 10 seconds**: sleep is turned back on (`pmset disablesleep 0`). If the lid is already closed, the Mac is put to sleep right away, because macOS won't do that by itself for a lid that was closed while sleep was off.

The 10-second wait means a loose cable or a quick unplug doesn't change anything. And before putting a closed Mac to sleep, the service makes sure nobody has touched the keyboard or trackpad for 10 seconds, just in case the lid sensor is wrong.

Why a background service? macOS has a single on/off switch for this setting, not one for battery and one for charger, so something has to flip it whenever you plug in or unplug.

## Install

```sh
git clone https://github.com/raspo/macbook-servermode.git
cd macbook-servermode
sudo ./install.sh
```

This copies two files:

- `/usr/local/sbin/servermode.sh`
- `/Library/LaunchDaemons/local.servermode.plist`

The service starts right away and every time the Mac boots.

## Uninstall

```sh
sudo ./uninstall.sh
```

This stops the service, deletes both files and turns sleep back on.

## Check that it's working

```sh
pmset -g | grep SleepDisabled                 # 1 when plugged in, 0 on battery
sudo launchctl print system/local.servermode  # is the service running?
log show --last 1d --predicate 'eventMessage BEGINSWITH "servermode:"'  # what it did today
```

## Settings

Change these at the top of `servermode.sh`, then run `sudo ./install.sh` again.

| Setting | Default | What it does |
| --- | --- | --- |
| `POLL_SECS` | `5` | How often (in seconds) to check whether the Mac is plugged in |
| `BATTERY_GRACE_SECS` | `10` | How long the Mac has to be unplugged before sleep is turned back on |
| `MIN_IDLE_SECS_BEFORE_FORCED_SLEEP` | `10` | How long the keyboard and trackpad must be untouched before a closed Mac is put to sleep |

Your screen still turns off as usual, based on your settings in System Settings. Only the Mac itself is kept awake.

## Good to know

- While sleep is off, macOS also won't sleep to cool down if it gets too hot. Use at your own risk.
- If you want to reach the Mac from another computer while the lid is closed, turn on what you need (for example, Remote Login for SSH) in System Settings > General > Sharing.
