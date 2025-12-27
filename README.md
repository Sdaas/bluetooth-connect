# bluetooth-connect

Small macOS utility that uses the `blueutil` command-line tool to automatically
connect to a list of Bluetooth devices (by default a keyboard and mouse).

## What this repo contains

- `connect.sh` - Main shell script. It gathers paired devices via `blueutil --format json`,
  searches the paired list for the target device names, and attempts to connect any that are
  disconnected. Supports a debug mode and uses colored output and emojis for status.
- `blueutil.txt` - Short copy of the `blueutil` help / usage notes included for convenience.
- `spec.txt` - Requirements and behavior specification used to design the script.

## Prerequisites

- macOS (this script relies on `blueutil`, a macOS Bluetooth CLI).
- Homebrew (recommended) to install dependencies: `blueutil` and `jq`.

Install dependencies with Homebrew:

```bash
brew install blueutil jq
```

See `blueutil.txt` for details on how it works.

## Usage

By default, the script is set to connect to a Bluetooth keyboard and mouse. Edit the `TARGET_DEVICES` 
array at the top of `connect.sh` to customize which devices the script should attempt to connect to. 

Run the script:

```bash
./connect.sh
```

Enable debug mode to print all paired devices and their connection state:

```bash
./connect.sh -d
# or
./connect.sh --debug
```

The script behavior summary:

- Lists paired devices in JSON via `blueutil --paired --format json`.
- For each target name it searches paired device names (case-insensitive, substring match).
- If a device is disconnected it attempts `blueutil --connect <ADDR>` and waits to confirm.
- Prints colored, emoji-enhanced status for success/failure.

## Testing checklist

1. Run `blueutil --paired --format json` to see paired devices.
2. Optionally disconnect a device with `blueutil --disconnect <ADDR>`.
3. Run `./connect.sh` and confirm the script reports connection successes.
4. Confirm state with `blueutil --info <ADDR> --format json` or `blueutil --is-connected <ADDR>`.

## Notes and tips

- Matching is substring, case-insensitive. Use unique substrings for reliable matching.
- If `blueutil` returns empty favourites/recent lists on macOS 12+, prefer addressing devices
  by name/address shown in the `--paired` output.
- If you want the script to be available system-wide, place it in a folder on your `PATH`
  and mark it executable (`chmod +x connect.sh`).

## Files

- `connect.sh` — script to connect devices.
- `blueutil.txt` — included blueutil usage help.
- `spec.txt` — original feature specification.

