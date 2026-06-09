#!/usr/bin/env bash
# Enable temperature-controlled fan for GeeekPi Armor Lite heatsink
# Fan signal wire connects to GPIO14 (header pin 8)
# Reference: https://www.raspberrypi.com/documentation/computers/config_txt.html#gpio-fan
set -euo pipefail

CONFIG=/boot/firmware/config.txt

echo "==> Configuring fan (GeeekPi Armor Lite)"

# Remove any existing gpio-fan lines (raspi-config may have added its own)
# then write the single canonical entry — collapses duplicates on re-run
sudo sed -i '/dtoverlay=gpio-fan/d' "$CONFIG"
echo "dtoverlay=gpio-fan,gpiopin=14,temp=60000" | sudo tee -a "$CONFIG" > /dev/null

echo "==> Fan configured — turns on at 60°C (reboot to apply)"
