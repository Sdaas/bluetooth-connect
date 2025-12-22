#!/bin/bash

# Default list of devices to connect to.
# Override this list with your list of devices that you want to connect to
# For example:
# TARGET_DEVICES=("My Keyboard" "My Mouse" "My Headphones")
TARGET_DEVICES=("keyboard" "mouse")

# Emojis and colors
CHECK_MARK="✅"
X_MARK="❌"
RIGHT_ARROW="➡️"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# --- Helper functions ---

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- Main script ---

# Check for dependencies
if ! command_exists blueutil || ! command_exists jq; then
  echo -e "${RED}${X_MARK} Error: blueutil and/or jq are not installed.${NC}"
  echo -e "Please install them to use this script."
  echo -e "  brew install blueutil jq"
  exit 1
fi

# Parse command-line options
DEBUG=0
if [[ "$1" =~ ^(-d|--debug)$ ]]; then
  DEBUG=1
elif [[ "$1" =~ ^(--help)$ ]]; then
  echo "Usage: $(basename "$0") [-d|--debug|--help]"
  echo
  echo "This script connects to specified Bluetooth devices."
  echo
  echo "Options:"
  echo "  -d, --debug    Enable debug mode. Prints a list of all paired devices and their status."
  echo "      --help     Display this help message and exit."
  echo
  echo "Configuration:"
  echo "  The list of target devices can be edited in the TARGET_DEVICES array within the script."
  exit 0
elif [[ -n "$1" ]]; then
    echo "Error: Unknown option '$1'"
    echo "Usage: $(basename "$0") [-d|--debug|--help]"
    exit 1
fi


# Get all paired devices in JSON format
PAIRED_DEVICES_JSON=$(blueutil --paired --format json)

# Debug mode: Print all paired devices and their status
if [[ $DEBUG -eq 1 ]]; then
  echo -e "--- Paired Devices ---"
  echo "$PAIRED_DEVICES_JSON" | jq -r '.[] | "Name: \(.name), ID: \(.address), Connected: \(.connected)"'
  echo -e "----------------------\n"
fi

echo "--- Connection Status ---"

# Loop through target devices
for device_name in "${TARGET_DEVICES[@]}"; do
  echo -e "${RIGHT_ARROW} Checking for device: ${device_name}"

  # Find the device in the paired devices list
  DEVICE_JSON=$(echo "$PAIRED_DEVICES_JSON" | jq --arg name "$device_name" '.[] | select(.name | ascii_downcase | contains($name | ascii_downcase))')


  if [[ -z "$DEVICE_JSON" ]]; then
    echo -e "  ${RED}${X_MARK} Device not found in paired list.${NC}"
    continue
  fi

  DEVICE_ID=$(echo "$DEVICE_JSON" | jq -r '.address')
  IS_CONNECTED=$(echo "$DEVICE_JSON" | jq -r '.connected')

  if [[ "$IS_CONNECTED" == "true" ]]; then
    echo -e "  ${GREEN}${CHECK_MARK} Already connected.${NC}"
  else
    echo "  Attempting to connect..."
    # Attempt to connect and wait for the connection
    blueutil --connect "$DEVICE_ID" --wait-connect "$DEVICE_ID" 1 >/dev/null
    
    # Verify the connection status again
    FINAL_STATUS_JSON=$(blueutil --info "$DEVICE_ID" --format json)
    if [[ $(echo "$FINAL_STATUS_JSON" | jq -r '.connected') == "true" ]]; then
        echo -e "  ${GREEN}${CHECK_MARK} Connection successful.${NC}"
    else
        echo -e "  ${RED}${X_MARK} Connection failed.${NC}"
    fi
  fi
  echo "" # Newline for readability
done

echo "-----------------------"
