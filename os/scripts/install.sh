#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/tarasfilonenko/cyberdeck"
INSTALL_DIR="/opt/cyberdeck"

echo "==> Cyberdeck bootstrap"

if ! command -v git &>/dev/null; then
  apt-get install -y git
fi

[[ -d "$INSTALL_DIR/.git" ]] || git clone "$REPO_URL" "$INSTALL_DIR"
git -C "$INSTALL_DIR" fetch origin
git -C "$INSTALL_DIR" reset --hard origin/main

chmod +x "$INSTALL_DIR"/os/scripts/*.sh

echo "==> Version: $(git -C "$INSTALL_DIR" rev-parse --short HEAD)"

if [[ "${SYNC_ONLY:-}" == "1" ]]; then
  echo "==> Sync complete"
  exit 0
fi

exec "$INSTALL_DIR/os/scripts/setup.sh"
