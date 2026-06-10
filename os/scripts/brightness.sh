#!/usr/bin/env bash
# Set up DDC/CI brightness control for the GeeekPi 10.1" HDMI IPS display
# ddcutil talks to the display over the HDMI DDC channel (I2C)
# Requires i2c.sh to have been run first (i2c-dev module)
# Reference: https://www.ddcutil.com/
set -euo pipefail

echo "==> Setting up display brightness control (ddcutil)"

if ! dpkg -s ddcutil &>/dev/null; then
  sudo apt-get install -y ddcutil
fi

# Add the invoking user to the i2c group for non-root DDC access
if [ -n "${SUDO_USER:-}" ]; then
  if id -nG "$SUDO_USER" | grep -qw "i2c"; then
    echo "==> $SUDO_USER already in i2c group"
  else
    sudo usermod -aG i2c "$SUDO_USER"
    echo "==> Added $SUDO_USER to i2c group (log out and back in to apply)"
  fi
fi

echo "==> Brightness control ready"
echo "    Detect display:   ddcutil detect"
echo "    Get brightness:   ddcutil getvcp 10"
echo "    Set brightness:   ddcutil setvcp 10 <0-100>"
