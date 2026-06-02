#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Cyberdeck OS bootstrap"

"$SCRIPT_DIR/scripts/display.sh"
"$SCRIPT_DIR/scripts/i2c.sh"
"$SCRIPT_DIR/scripts/usb-hub.sh"

echo "==> Done. Reboot recommended."
