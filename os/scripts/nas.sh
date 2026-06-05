#!/usr/bin/env bash
# Configure shared NAS connection (host + credentials).
# Downstream scripts (backup.sh, retropie-nas.sh) use this config for their own shares.
# Reference: https://wiki.debian.org/MountWindowsSharesPermanently
set -euo pipefail

CONFIG="/etc/cyberdeck/nas.conf"
CREDS="/etc/cyberdeck/nas.creds"

if [[ -f "$CONFIG" ]] && [[ "${FORCE:-}" != "1" ]]; then
  echo "==> NAS already configured — skipping (use FORCE=1 to reconfigure)"
  # shellcheck source=/dev/null
  source "$CONFIG"
  echo "    Host: ${NAS_HOST}"
  exit 0
fi

# Accept env vars or prompt
NAS_HOST="${NAS_HOST:-}"
NAS_USER="${NAS_USER:-}"
NAS_PASS="${NAS_PASS:-}"
NAS_TEST_SHARE="${NAS_TEST_SHARE:-}"

[[ -n "$NAS_HOST" ]]       || read -r -p "NAS hostname or IP: " NAS_HOST
[[ -n "$NAS_USER" ]]       || read -r -p "Username: " NAS_USER
[[ -n "$NAS_PASS" ]]       || { read -r -s -p "Password: " NAS_PASS; echo; }
[[ -n "$NAS_TEST_SHARE" ]] || read -r -p "Share name to test connection (e.g. backup): " NAS_TEST_SHARE

dpkg -s cifs-utils &>/dev/null || apt-get install -y cifs-utils

echo "==> Testing connection to //${NAS_HOST}/${NAS_TEST_SHARE}..."
TEST_MOUNT=$(mktemp -d)
if mount -t cifs "//${NAS_HOST}/${NAS_TEST_SHARE}" "$TEST_MOUNT" \
    -o "username=${NAS_USER},password=${NAS_PASS}" 2>/dev/null; then
  umount "$TEST_MOUNT"
  rmdir "$TEST_MOUNT"
  echo "==> Connection successful"
else
  rmdir "$TEST_MOUNT"
  echo "==> Connection failed — check hostname, share name, and credentials"
  exit 1
fi

mkdir -p "$(dirname "$CONFIG")"

printf 'NAS_HOST="%s"\nNAS_USER="%s"\n' "$NAS_HOST" "$NAS_USER" > "$CONFIG"

printf 'username=%s\npassword=%s\n' "$NAS_USER" "$NAS_PASS" > "$CREDS"
chmod 600 "$CREDS"

echo "==> NAS configured — host: ${NAS_HOST}, credentials saved"
