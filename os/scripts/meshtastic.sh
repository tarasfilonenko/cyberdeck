#!/usr/bin/env bash
# Set up Meshtastic USB node integration
set -euo pipefail

echo "==> Configuring Meshtastic"

# Install meshtastic CLI
if ! command -v meshtastic &>/dev/null; then
  sudo pip3 install meshtastic --break-system-packages
fi

# Add current user to dialout group for serial port access
if ! groups "$USER" | grep -q dialout; then
  sudo usermod -aG dialout "$USER"
  echo "    Added $USER to dialout group (re-login to apply)"
fi

# Install udev rule so Meshtastic node gets a stable device path at /dev/meshtastic
RULE='SUBSYSTEM=="tty", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", SYMLINK+="meshtastic", MODE="0666"'
RULE_FILE=/etc/udev/rules.d/99-meshtastic.rules

if ! grep -qF "$RULE" "$RULE_FILE" 2>/dev/null; then
  echo "$RULE" | sudo tee "$RULE_FILE"
  sudo udevadm control --reload-rules
  sudo udevadm trigger
fi

echo "==> Meshtastic configured (device will appear at /dev/meshtastic when connected)"
