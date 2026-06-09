#!/usr/bin/env bash
# Enable temperature-controlled fan for GeeekPi Armor Lite heatsink
# Fan signal wire connects to GPIO14 (header pin 8)
# Reference: https://www.raspberrypi.com/documentation/computers/config_txt.html#gpio-fan
set -euo pipefail

CONFIG=/boot/firmware/config.txt

echo "==> Configuring fan (GeeekPi Armor Lite)"

if ! grep -q "dtoverlay=gpio-fan" "$CONFIG"; then
  cat <<'EOF' | sudo tee -a "$CONFIG"
dtoverlay=gpio-fan,gpiopin=14,temp=55000
EOF
fi

echo "==> Fan configured — turns on at 55°C (reboot to apply)"
