#!/usr/bin/env bash
# Install RetroPie on top of Raspberry Pi OS
# Reference: https://retropie.org.uk/docs/Manual-Installation/
set -euo pipefail

RETROPIE_SETUP_DIR="${RETROPIE_SETUP_DIR:-/opt/RetroPie-Setup}"
# RetroPie setup must run as the regular user, not root
REAL_USER="${SUDO_USER:-$(id -un)}"

if command -v emulationstation &>/dev/null && [[ "${FORCE:-}" != "1" ]]; then
  echo "==> RetroPie already installed — skipping (use FORCE=1 to reinstall)"
  exit 0
fi

echo "==> Installing RetroPie dependencies..."
for pkg in git dialog unzip xmlstarlet; do
  dpkg -s "$pkg" &>/dev/null || apt-get install -y "$pkg"
done

# Pre-add user to input group so setup doesn't prompt interactively
usermod -a -G input "$REAL_USER"

echo "==> Cloning RetroPie-Setup..."
if [[ ! -d "${RETROPIE_SETUP_DIR}" ]]; then
  git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git "${RETROPIE_SETUP_DIR}"
fi
chown -R "$REAL_USER" "${RETROPIE_SETUP_DIR}"

echo "==> Running RetroPie basic install (this takes several minutes)..."
export SUDO_USER="$REAL_USER"
cd "${RETROPIE_SETUP_DIR}" && bash retropie_packages.sh setup basic_install

echo "==> Adding desktop shortcut..."
DESKTOP_DIR="/home/${REAL_USER}/Desktop"
mkdir -p "$DESKTOP_DIR"
cat > "$DESKTOP_DIR/emulationstation.desktop" << 'EOF'
[Desktop Entry]
Name=EmulationStation
Comment=Launch RetroPie
Exec=emulationstation
Icon=/opt/retropie/supplementary/EmulationStation/resources/logo.svg
Terminal=false
Type=Application
Categories=Game;
EOF
chmod +x "$DESKTOP_DIR/emulationstation.desktop"
chown "$REAL_USER:$REAL_USER" "$DESKTOP_DIR/emulationstation.desktop"

echo "==> RetroPie installed — launch with: emulationstation"
