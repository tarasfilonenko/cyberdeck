#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/brightness.sh

@test "brightness: exits 0" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "brightness: ddcutil is available after run" {
  "$SCRIPT"
  dpkg -s ddcutil &>/dev/null
}

@test "brightness: idempotent — exits 0 on second run" {
  "$SCRIPT"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "brightness: adds SUDO_USER to i2c group" {
  groupadd -f i2c
  useradd -M testuser 2>/dev/null || true

  SUDO_USER=testuser run "$SCRIPT"
  [ "$status" -eq 0 ]
  id -nG testuser | grep -qw "i2c"
}

@test "brightness: skips usermod when SUDO_USER already in i2c group" {
  groupadd -f i2c
  useradd -M testuser2 2>/dev/null || true
  usermod -aG i2c testuser2

  SUDO_USER=testuser2 run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already in i2c group"* ]]
}
