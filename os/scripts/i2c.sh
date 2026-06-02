#!/usr/bin/env bash
# Enable I2C and install tools
set -euo pipefail

echo "==> Configuring I2C"

# Enable I2C via raspi-config non-interactively
sudo raspi-config nonint do_i2c 0

# Install i2c-tools if not present
if ! dpkg -s i2c-tools &>/dev/null; then
  sudo apt-get install -y i2c-tools
fi

# Load i2c-dev at boot
if ! grep -q "i2c-dev" /etc/modules; then
  echo "i2c-dev" | sudo tee -a /etc/modules
fi

echo "==> I2C enabled (use 'i2cdetect -y 1' to scan bus)"
