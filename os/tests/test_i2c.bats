#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/i2c.sh
MODULES=/etc/modules
CONFIG=/boot/firmware/config.txt

setup() {
  > "$CONFIG"
  # Start with a clean modules file (no i2c-dev)
  grep -v "i2c-dev" "$MODULES" > "$MODULES.tmp" 2>/dev/null && mv "$MODULES.tmp" "$MODULES" || true
}

@test "i2c: adds i2c-dev to /etc/modules" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "i2c-dev" "$MODULES"
}

@test "i2c: idempotent — i2c-dev not duplicated on second run" {
  "$SCRIPT"
  "$SCRIPT"
  [ "$(grep -c "^i2c-dev$" "$MODULES")" -eq 1 ]
}

@test "i2c: raspi-config writes i2c dtparam to config.txt" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "dtparam=i2c_arm=on" "$CONFIG"
}
