#!/usr/bin/env bash
# Install RetroPie on top of Raspberry Pi OS
# Reference: https://retropie.org.uk/docs/Manual-Installation/
set -euo pipefail

RETROPIE_SETUP_DIR="${RETROPIE_SETUP_DIR:-/opt/RetroPie-Setup}"

if [[ -d /opt/retropie ]]; then
  echo "==> RetroPie already installed — skipping"
  exit 0
fi

echo "==> Installing RetroPie dependencies..."
for pkg in git dialog unzip xmlstarlet; do
  dpkg -s "$pkg" &>/dev/null || sudo apt-get install -y "$pkg"
done

echo "==> Cloning RetroPie-Setup..."
if [[ ! -d "${RETROPIE_SETUP_DIR}" ]]; then
  sudo git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git "${RETROPIE_SETUP_DIR}"
fi

echo "==> Running RetroPie basic install (this takes several minutes)..."
sudo bash "${RETROPIE_SETUP_DIR}/retropie_setup.sh" basic_install

echo "==> RetroPie installed — launch with: emulationstation"
