#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/tarasfilonenko/cyberdeck"
INSTALL_DIR="/opt/cyberdeck"

echo "==> Cyberdeck bootstrap"

if ! command -v git &>/dev/null; then
  apt-get install -y git
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "==> Repo already cloned, pulling latest"
  git -C "$INSTALL_DIR" pull
else
  echo "==> Cloning $REPO_URL to $INSTALL_DIR"
  git clone "$REPO_URL" "$INSTALL_DIR"
fi

exec "$INSTALL_DIR/os/scripts/setup.sh"
