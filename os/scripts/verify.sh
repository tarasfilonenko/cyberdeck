#!/usr/bin/env bash
# Run on the Pi to verify setup — prints ok/FAIL for each check
set -euo pipefail

FAILED=0
ok()   { printf "  ok    %s\n" "$1"; }
fail() { printf "  FAIL  %s\n" "$1"; FAILED=1; }

echo "==> Verifying cyberdeck setup"

# Boot device
ROOT_DEV=$(findmnt -n -o SOURCE / | sed 's/[0-9]*$//')
if [[ "$ROOT_DEV" == /dev/sd* ]]; then
  ok "boot device: SSD (${ROOT_DEV})"
else
  fail "boot device: still on SD card (${ROOT_DEV}) — reboot required"
fi

# Display
grep -q "hdmi_force_hotplug=1" /boot/firmware/config.txt \
  && ok "display: hdmi_force_hotplug set" \
  || fail "display: hdmi_force_hotplug missing"

grep -q "hdmi_cvt=" /boot/firmware/config.txt \
  && ok "display: hdmi_cvt set" \
  || fail "display: hdmi_cvt missing"

# I2C
grep -q "i2c-dev" /etc/modules \
  && ok "i2c: i2c-dev in /etc/modules" \
  || fail "i2c: i2c-dev missing from /etc/modules"

grep -q "dtparam=i2c_arm=on" /boot/firmware/config.txt \
  && ok "i2c: dtparam=i2c_arm=on set" \
  || fail "i2c: dtparam=i2c_arm=on missing"

# USB hub
[[ -f /etc/udev/rules.d/99-cyberdeck.rules ]] \
  && ok "usb-hub: udev rules installed" \
  || fail "usb-hub: udev rules missing"

grep -q "usbcore.autosuspend=-1" /boot/firmware/cmdline.txt \
  && ok "usb-hub: autosuspend disabled" \
  || fail "usb-hub: autosuspend not disabled"

# USB boot order (EEPROM)
if vcgencmd bootloader_config 2>/dev/null | grep -q "BOOT_ORDER=0xf[0-9a-f]*[14]"; then
  ok "usb-boot: USB boot order set in EEPROM"
else
  fail "usb-boot: USB boot order not set (reboot may be pending)"
fi

# Storage
ROOT_SIZE=$(df -h / | awk 'NR==2 {print $2}')
ROOT_USED=$(df -h / | awk 'NR==2 {print $3}')
ok "storage: ${ROOT_USED} used of ${ROOT_SIZE} on /"

echo ""
if [[ "$FAILED" -eq 0 ]]; then
  echo "==> All checks passed"
else
  echo "==> Some checks failed"
  exit 1
fi
