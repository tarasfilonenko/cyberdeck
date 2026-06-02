#!/usr/bin/env bash
# USB hub power and autosuspend configuration
set -euo pipefail

RULES_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/99-cyberdeck.rules"
RULES_DEST=/etc/udev/rules.d/99-cyberdeck.rules

echo "==> Configuring USB hub"

# Install udev rules
if [[ ! -f "$RULES_DEST" ]] || ! diff -q "$RULES_SRC" "$RULES_DEST" &>/dev/null; then
  sudo cp "$RULES_SRC" "$RULES_DEST"
  sudo udevadm control --reload-rules
  sudo udevadm trigger
fi

# Disable USB autosuspend globally (prevents hub from powering down accessories)
CMDLINE=/boot/firmware/cmdline.txt
if ! grep -q "usbcore.autosuspend=-1" "$CMDLINE"; then
  sudo sed -i 's/$/ usbcore.autosuspend=-1/' "$CMDLINE"
fi

echo "==> USB hub configured"
