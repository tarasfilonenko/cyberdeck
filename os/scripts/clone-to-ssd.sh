#!/usr/bin/env bash
set -euo pipefail

# Clone the running SD card to the SSD and expand the root filesystem.
# Skips automatically if no SSD is connected or if already running from SSD.
# References:
#   https://www.raspberrypi.com/documentation/computers/os.html

SSD_DEV="${SSD_DEV:-/dev/sda}"
SD_DEV="${SD_DEV:-/dev/mmcblk0}"

# Already running from SSD — nothing to do
ROOT_DEV=$(findmnt -n -o SOURCE / 2>/dev/null | sed 's/[0-9]*$//')
if [[ "${ROOT_DEV}" == "${SSD_DEV}" ]]; then
  echo "==> Already running from SSD — skipping clone"
  exit 0
fi

# No SSD connected — prompt if interactive, skip silently if not
if [[ ! -b "${SSD_DEV}" ]]; then
  echo "==> No SSD detected at ${SSD_DEV}"
  if [[ -t 0 ]]; then
    read -r -p "    Connect the SSD via USB enclosure and press Enter to continue (Ctrl+C to skip): "
  fi
  if [[ ! -b "${SSD_DEV}" ]]; then
    echo "==> SSD still not detected — skipping clone"
    exit 0
  fi
fi

echo "==> Cloning ${SD_DEV} to ${SSD_DEV} (this takes several minutes)..."
sudo dd if="${SD_DEV}" of="${SSD_DEV}" bs=4M status=progress
sync

echo "==> Expanding root filesystem to fill SSD..."
sudo raspi-config nonint do_expand_rootfs

echo "==> Clone complete — reboot to start from SSD, then remove the SD card"
