#!/usr/bin/env bash
# Mount NAS ROM library to ~/RetroPie/roms via fstab (_netdev mounts after network is up)
# Reference: https://wiki.debian.org/MountWindowsSharesPermanently
set -euo pipefail

CONFIG="/etc/cyberdeck/nas.conf"
CREDS="/etc/cyberdeck/nas.creds"
FSTAB="${FSTAB:-/etc/fstab}"
MOUNT_POINT="/home/cyberdeck/RetroPie/roms"
REAL_USER="${SUDO_USER:-$(id -un)}"

if [[ ! -f "$CONFIG" ]]; then
  echo "==> NAS not configured — run 'make deploy-nas' first"
  exit 1
fi

# shellcheck source=/dev/null
source "$CONFIG"

if grep -qF "$MOUNT_POINT" "$FSTAB" && [[ "${FORCE:-}" != "1" ]]; then
  echo "==> RetroPie NAS mount already configured — skipping (use FORCE=1 to reconfigure)"
  exit 0
fi

NAS_ROMS_SHARE="${NAS_ROMS_SHARE:-}"
[[ -n "$NAS_ROMS_SHARE" ]] || read -r -p "NAS ROMs share name (e.g. roms): " NAS_ROMS_SHARE

dpkg -s cifs-utils &>/dev/null || apt-get install -y cifs-utils

mkdir -p "$MOUNT_POINT"
chown "${REAL_USER}:${REAL_USER}" "$MOUNT_POINT"

# Remove existing entry for this mount point before (re)adding
if grep -qF "$MOUNT_POINT" "$FSTAB"; then
  mountpoint -q "$MOUNT_POINT" && umount "$MOUNT_POINT" || true
  grep -vF "$MOUNT_POINT" "$FSTAB" > /tmp/fstab.tmp
  mv /tmp/fstab.tmp "$FSTAB"
fi

echo "//${NAS_HOST}/${NAS_ROMS_SHARE} ${MOUNT_POINT} cifs credentials=${CREDS},uid=${REAL_USER},gid=${REAL_USER},_netdev 0 0" >> "$FSTAB"

echo "==> Testing mount..."
mount "$MOUNT_POINT"

echo "==> RetroPie NAS ROMs mounted — //${NAS_HOST}/${NAS_ROMS_SHARE} → ${MOUNT_POINT}"
