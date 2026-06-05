#!/usr/bin/env bash
# Enable RealVNC server on port 5900
# Reference: https://www.raspberrypi.com/documentation/computers/remote-access.html#vnc
set -euo pipefail

if sudo raspi-config nonint get_vnc 2>/dev/null | grep -q "^0$"; then
  echo "==> VNC already enabled — skipping"
  exit 0
fi

echo "==> Enabling VNC..."
sudo raspi-config nonint do_vnc 0
echo "==> VNC enabled — connect on port 5900"
