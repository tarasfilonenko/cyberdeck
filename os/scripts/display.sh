#!/usr/bin/env bash
# Configure GeeekPi 10.1" 1024x600 HDMI IPS display
set -euo pipefail

CONFIG=/boot/firmware/config.txt

echo "==> Configuring display"

# Ensure HDMI output is forced on even with no monitor detected
if ! grep -q "hdmi_force_hotplug=1" "$CONFIG"; then
  echo "hdmi_force_hotplug=1" | sudo tee -a "$CONFIG"
fi

# Set resolution to 1024x600
if ! grep -q "hdmi_cvt=1024 600" "$CONFIG"; then
  cat <<'EOF' | sudo tee -a "$CONFIG"
hdmi_cvt=1024 600 60 6 0 0 0
hdmi_group=2
hdmi_mode=87
EOF
fi

# USB touch: no driver setup needed — kernel handles it automatically
echo "==> Display configured (reboot to apply)"
