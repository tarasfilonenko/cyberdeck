#!/usr/bin/env bash
set -euo pipefail

# Automates Raspberry Pi OS image flashing and first-boot configuration.
#
# Subcommands:
#   flash (default)  — interactive: prompt, download, write, inject config
#   inject           — non-interactive: inject config files into a boot dir (used by tests)
#
# Override the image with:  IMAGE=/path/to.img make flash
# Override the URL with:    IMAGE_URL=https://... make flash
#
# References:
#   https://www.raspberrypi.com/documentation/computers/configuration.html
#   https://github.com/raspberrypi/rpi-imager

: "${IMAGE_URL:=https://downloads.raspberrypi.com/raspios_arm64/images/raspios_arm64-2024-11-19/2024-11-19-raspios-bookworm-arm64.img.xz}"
CACHE_DIR="${TMPDIR:-/tmp}/cyberdeck-flash"

# 128 GiB — rejects HDDs; covers SD cards up to 128 GB and small USB SSDs
MAX_DEVICE_BYTES=$(( 128 * 1024 * 1024 * 1024 ))

die() { echo "ERROR: $*" >&2; exit 1; }

# ── rpi-imager (optional) ─────────────────────────────────────────────────────

check_imager() {
  if command -v rpi-imager >/dev/null 2>&1; then
    return
  fi
  echo "rpi-imager is not installed (this script flashes with dd — rpi-imager is optional)."
  if [[ "$(uname)" == "Darwin" ]]; then
    read -r -p "Install via Homebrew? [y/N] " ans
    [[ "${ans,,}" == "y" ]] && brew install --cask raspberry-pi-imager
  fi
}

# ── storage size guard ────────────────────────────────────────────────────────

check_device_size() {
  local device="$1"
  local size_bytes

  if [[ "$(uname)" == "Darwin" ]]; then
    size_bytes=$(diskutil info "${device}" 2>/dev/null \
      | grep -E 'Disk Size|Total Size' \
      | grep -oE '\([0-9,]+ Bytes\)' \
      | tr -d '(,) Bytes' \
      | head -1)
  else
    size_bytes=$(lsblk -bdno SIZE "${device}" 2>/dev/null || true)
  fi

  [[ -n "${size_bytes}" ]] || die "Could not determine size of ${device}."

  if (( size_bytes > MAX_DEVICE_BYTES )); then
    local gib=$(( size_bytes / 1024 / 1024 / 1024 ))
    die "${device} is ${gib} GiB — exceeds the 128 GiB guard. This prevents accidentally wiping an HDD. To use a larger card, update MAX_DEVICE_BYTES in flash.sh."
  fi
}

# ── password hashing ──────────────────────────────────────────────────────────

hash_password() {
  local pass="$1"
  # macOS ships LibreSSL which lacks -6; try Homebrew OpenSSL first
  for bin in /opt/homebrew/opt/openssl/bin/openssl /usr/local/opt/openssl/bin/openssl openssl; do
    command -v "${bin}" >/dev/null 2>&1 || continue
    result=$("${bin}" passwd -6 "${pass}" 2>/dev/null) && { echo "${result}"; return; }
  done
  # Python3 fallback (crypt available pre-3.13)
  python3 -c "import crypt; print(crypt.crypt('${pass}', crypt.mksalt(crypt.METHOD_SHA512)))" \
    2>/dev/null && return
  die "Cannot hash password. Install OpenSSL via Homebrew: brew install openssl"
}

# ── inject subcommand ─────────────────────────────────────────────────────────
#
# Usage: flash.sh inject <boot_dir> <hostname> <username> <pass_hash> [wifi_ssid [wifi_pass]]
#
# Writes first-boot configuration files into a boot partition directory.
# Called by cmd_flash after mounting, and directly by os/tests/test_flash.bats.

cmd_inject() {
  local boot_dir="${1:?boot_dir required}"
  local hostname="${2:?hostname required}"
  local username="${3:?username required}"
  local pass_hash="${4:?pass_hash required}"
  local wifi_ssid="${5:-}"
  local wifi_pass="${6:-}"

  # SSH: sshswitch.service enables SSH when it finds this file on first boot
  touch "${boot_dir}/ssh"

  # User credentials: userconfig.service reads username:sha512hash on first boot
  printf '%s:%s\n' "${username}" "${pass_hash}" > "${boot_dir}/userconf.txt"

  # firstrun.sh: sets hostname + optional Wi-Fi, triggered via systemd.run
  local firstrun="${boot_dir}/firstrun.sh"
  {
    echo '#!/bin/bash'
    echo 'set +e'
    echo ''
    echo 'CURRENT_HOSTNAME=$(cat /etc/hostname | tr -d " \t\n\r")'
    echo "echo ${hostname} > /etc/hostname"
    echo "sed -i \"s/127.0.1.1.*\${CURRENT_HOSTNAME}/127.0.1.1\t${hostname}/g\" /etc/hosts"
    echo ''
  } > "${firstrun}"

  if [[ -n "${wifi_ssid}" ]]; then
    # Bookworm uses NetworkManager; inject a keyfile via firstrun.sh
    cat >> "${firstrun}" << ENDOFWIFI
mkdir -p /etc/NetworkManager/system-connections
cat > "/etc/NetworkManager/system-connections/${wifi_ssid}.nmconnection" << 'NMEOF'
[connection]
id=${wifi_ssid}
type=wifi
autoconnect=true

[wifi]
ssid=${wifi_ssid}
mode=infrastructure

[wifi-security]
key-mgmt=wpa-psk
psk=${wifi_pass}

[ipv4]
method=auto

[ipv6]
method=auto
NMEOF
chmod 600 "/etc/NetworkManager/system-connections/${wifi_ssid}.nmconnection"
rfkill unblock wifi 2>/dev/null || true

ENDOFWIFI
  fi

  {
    echo 'rm -f /boot/firmware/firstrun.sh'
    echo "sed -i 's| systemd\.run[^ ]*||g' /boot/firmware/cmdline.txt"
  } >> "${firstrun}"
  chmod +x "${firstrun}"

  # cmdline.txt: register firstrun.sh — strip any existing entry first (idempotent)
  local cmdline="${boot_dir}/cmdline.txt"
  touch "${cmdline}"
  local existing
  existing=$(sed 's| systemd\.run[^ ]*||g' "${cmdline}" | sed 's|[[:space:]]*$||')
  local prefix=""
  [[ -n "${existing}" ]] && prefix="${existing} "
  printf '%ssystemd.run=/boot/firmware/firstrun.sh systemd.run_success_action=reboot systemd.unit=kernel-command-line.target\n' \
    "${prefix}" > "${cmdline}"
}

# ── flash subcommand ──────────────────────────────────────────────────────────

cmd_flash() {
  check_imager

  read -r -p "Hostname [cyberdeck]: "           hostname; hostname="${hostname:-cyberdeck}"
  read -r -p "Username [pi]: "                  username; username="${username:-pi}"
  read -r -s -p "Password: "                    password; echo
  [[ -z "${password}" ]] && die "Password cannot be empty"

  read -r -p "Wi-Fi SSID (blank to skip): "     wifi_ssid
  local wifi_pass=""
  if [[ -n "${wifi_ssid}" ]]; then
    read -r -s -p "Wi-Fi password: "            wifi_pass; echo
  fi

  read -r -p "Device (e.g. /dev/disk2 on macOS, /dev/sdb on Linux): " device
  [[ -z "${device}" ]] && die "Device cannot be empty"
  [[ -e "${device}" ]] || die "Device not found: ${device}"

  check_device_size "${device}"

  local pass_hash
  pass_hash=$(hash_password "${password}")

  local img="${IMAGE:-}"
  if [[ -z "${img}" ]]; then
    mkdir -p "${CACHE_DIR}"
    local img_xz="${CACHE_DIR}/raspios-bookworm-arm64.img.xz"
    img="${CACHE_DIR}/raspios-bookworm-arm64.img"
    if [[ ! -f "${img}" ]]; then
      echo "==> Downloading Raspberry Pi OS..."
      curl -L --progress-bar -o "${img_xz}" "${IMAGE_URL}"
      echo "==> Extracting..."
      xz -d "${img_xz}"
    else
      echo "==> Using cached image: ${img}"
    fi
  fi

  echo ""
  echo "  Image:    ${img}"
  echo "  Device:   ${device}"
  echo "  Hostname: ${hostname}"
  echo "  Username: ${username}"
  echo ""
  echo "WARNING: all data on ${device} will be erased."
  read -r -p "Continue? [y/N] " confirm
  [[ "${confirm,,}" == "y" ]] || die "Aborted."

  local boot_dir
  if [[ "$(uname)" == "Darwin" ]]; then
    diskutil unmountDisk "${device}"
    sudo dd if="${img}" of="${device}" bs=4m
    sync
    sleep 2
    diskutil mountDisk "${device}"
    boot_dir=$(diskutil info "${device}s1" 2>/dev/null | awk '/Mount Point/ {print $NF}')
    [[ -d "${boot_dir}" ]] || die "Could not find boot partition mount point after writing"
  else
    sudo dd if="${img}" of="${device}" bs=4M status=progress
    sync
    sudo partprobe "${device}" 2>/dev/null || true
    boot_dir="${CACHE_DIR}/boot"
    sudo mkdir -p "${boot_dir}"
    local boot_part="${device}1"
    [[ -b "${boot_part}" ]] || boot_part="${device}p1"
    sudo mount "${boot_part}" "${boot_dir}"
  fi

  echo "==> Injecting first-boot configuration..."
  cmd_inject "${boot_dir}" "${hostname}" "${username}" "${pass_hash}" "${wifi_ssid}" "${wifi_pass}"

  if [[ "$(uname)" == "Darwin" ]]; then
    diskutil unmountDisk "${device}"
  else
    sudo umount "${boot_dir}"
  fi

  echo "==> Done. Eject the card, insert into your Pi, and power on."
}

# ── entrypoint ────────────────────────────────────────────────────────────────

case "${1:-flash}" in
  inject) shift; cmd_inject "$@" ;;
  flash)  cmd_flash ;;
  *)      die "Unknown subcommand: ${1} (use 'flash' or 'inject')" ;;
esac
