#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/fan.sh
CONFIG=/boot/firmware/config.txt

setup() {
  > "$CONFIG"
}

@test "fan: appends gpio-fan overlay to config.txt" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "dtoverlay=gpio-fan,gpiopin=14,temp=60000" "$CONFIG"
}

@test "fan: idempotent — exactly one gpio-fan entry after multiple runs" {
  "$SCRIPT"
  "$SCRIPT"
  [ "$(grep -c "dtoverlay=gpio-fan" "$CONFIG")" -eq 1 ]
}

@test "fan: removes duplicate entry written by raspi-config" {
  printf 'dtoverlay=gpio-fan,gpiopin=14,temp=60000\n' > "$CONFIG"
  echo "dtoverlay=gpio-fan,gpiopin=14,temp=55000" >> "$CONFIG"
  "$SCRIPT"
  [ "$(grep -c "dtoverlay=gpio-fan" "$CONFIG")" -eq 1 ]
  grep -q "temp=60000" "$CONFIG"
}

@test "fan: overwrites wrong temperature value" {
  echo "dtoverlay=gpio-fan,gpiopin=14,temp=55000" > "$CONFIG"
  "$SCRIPT"
  grep -q "temp=60000" "$CONFIG"
  ! grep -q "temp=55000" "$CONFIG"
}
