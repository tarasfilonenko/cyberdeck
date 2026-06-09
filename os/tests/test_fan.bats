#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/fan.sh
CONFIG=/boot/firmware/config.txt

setup() {
  > "$CONFIG"
}

@test "fan: appends gpio-fan overlay to config.txt" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "dtoverlay=gpio-fan,gpiopin=14,temp=55000" "$CONFIG"
}

@test "fan: idempotent — overlay not duplicated on second run" {
  "$SCRIPT"
  "$SCRIPT"
  [ "$(grep -c "dtoverlay=gpio-fan" "$CONFIG")" -eq 1 ]
}

@test "fan: does not modify config when overlay already present" {
  echo "dtoverlay=gpio-fan,gpiopin=14,temp=55000" > "$CONFIG"
  before=$(md5sum "$CONFIG")
  "$SCRIPT"
  after=$(md5sum "$CONFIG")
  [ "$before" = "$after" ]
}
