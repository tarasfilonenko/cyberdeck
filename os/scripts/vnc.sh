#!/usr/bin/env bash
# Enable RealVNC server on port 5900
# wayvnc ships enabled by default on newer Raspberry Pi OS but only works with
# Wayland compositors. This build runs X11 + openbox, so disable wayvnc to
# prevent it from stealing port 5900 before RealVNC can bind.
# Reference: https://www.raspberrypi.com/documentation/computers/remote-access.html#vnc
set -euo pipefail

# Disable wayvnc if present — conflicts with RealVNC on X11 setups
if systemctl is-enabled wayvnc &>/dev/null; then
  echo "==> Disabling wayvnc (conflicts with RealVNC on X11)..."
  sudo systemctl disable --now wayvnc
fi

VNC_STATE=$(sudo raspi-config nonint get_vnc 2>/dev/null || true)
if echo "$VNC_STATE" | grep -q "^0"; then
  echo "==> VNC already enabled — skipping"
  exit 0
fi

echo "==> Enabling VNC..."
sudo raspi-config nonint do_vnc 0
echo "==> VNC enabled — connect on port 5900"
