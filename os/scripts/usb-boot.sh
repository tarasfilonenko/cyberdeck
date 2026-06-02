#!/usr/bin/env bash
set -euo pipefail

# Configure Raspberry Pi 4 bootloader to boot from USB storage (SSD via enclosure).
# Updates EEPROM to latest firmware and sets USB as primary boot device.
# A reboot is required after this script to activate the EEPROM change.
# References:
#   https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#usb-mass-storage-boot
#   https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-4-bootloader-configuration

echo "==> Updating EEPROM bootloader..."
sudo rpi-eeprom-update -a

echo "==> Setting USB boot order..."
sudo raspi-config nonint do_boot_order B2

echo "==> USB boot configured (reboot required to activate)"
