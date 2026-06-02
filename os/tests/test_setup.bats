#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/setup.sh

setup() {
  > /boot/firmware/config.txt
  echo "console=serial0,115200 rootwait" > /boot/firmware/cmdline.txt
  rm -f /etc/udev/rules.d/99-cyberdeck.rules
  rm -f /var/lib/raspi-config/boot-order
  grep -v "i2c-dev" /etc/modules > /etc/modules.tmp 2>/dev/null && mv /etc/modules.tmp /etc/modules || true
}

@test "setup: exits 0" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "setup: display, i2c, usb-hub, and usb-boot all applied" {
  "$SCRIPT"
  grep -q "hdmi_force_hotplug=1" /boot/firmware/config.txt
  grep -q "i2c-dev" /etc/modules
  [ -f /etc/udev/rules.d/99-cyberdeck.rules ]
  grep -q "B2" /var/lib/raspi-config/boot-order
}
