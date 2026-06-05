#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/vnc.sh

setup() {
  rm -f /var/lib/raspi-config/vnc
}

@test "vnc: exits 0" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "vnc: enables vnc via raspi-config" {
  "$SCRIPT"
  [ "$(cat /var/lib/raspi-config/vnc)" = "0" ]
}

@test "vnc: idempotent — skips if already enabled" {
  "$SCRIPT"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already enabled"* ]]
}
