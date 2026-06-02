#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/usb-boot.sh
BOOT_ORDER_FILE=/var/lib/raspi-config/boot-order

setup() {
  rm -f "${BOOT_ORDER_FILE}"
}

@test "usb-boot: exits 0" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "usb-boot: configures USB boot order" {
  "$SCRIPT"
  grep -q "B2" "${BOOT_ORDER_FILE}"
}

@test "usb-boot: idempotent — safe to run twice" {
  "$SCRIPT"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "B2" "${BOOT_ORDER_FILE}"
}
