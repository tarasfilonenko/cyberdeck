#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Cyberdeck OS bootstrap"

"$SCRIPT_DIR/display.sh"
"$SCRIPT_DIR/i2c.sh"
"$SCRIPT_DIR/usb-hub.sh"
"$SCRIPT_DIR/usb-boot.sh"
"$SCRIPT_DIR/fan.sh"
"$SCRIPT_DIR/clone-to-ssd.sh"

echo "==> Done. Reboot recommended."
