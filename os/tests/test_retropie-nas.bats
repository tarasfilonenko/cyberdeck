#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/retropie-nas.sh

setup() {
  FAKE_BIN=$(mktemp -d)
  FAKE_FSTAB=$(mktemp)
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_BIN/mount"
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_BIN/umount"
  printf '#!/bin/sh\nexit 1\n' > "$FAKE_BIN/mountpoint"
  chmod +x "$FAKE_BIN/mount" "$FAKE_BIN/umount" "$FAKE_BIN/mountpoint"
  export FAKE_BIN FAKE_FSTAB
  export PATH="$FAKE_BIN:$PATH"
  export FSTAB="$FAKE_FSTAB"
  export NAS_ROMS_SHARE="roms"
  mkdir -p /etc/cyberdeck
  printf 'NAS_HOST="nas.local"\nNAS_USER="testuser"\n' > /etc/cyberdeck/nas.conf
  printf 'username=testuser\npassword=testpass\n' > /etc/cyberdeck/nas.creds
}

teardown() {
  rm -f /etc/cyberdeck/nas.conf /etc/cyberdeck/nas.creds
  rm -f "$FAKE_FSTAB"
  rm -rf "$FAKE_BIN"
}

@test "retropie-nas: exits 1 if nas.conf missing" {
  rm -f /etc/cyberdeck/nas.conf
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"make deploy-nas"* ]]
}

@test "retropie-nas: exits 0 on successful mount" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "retropie-nas: adds fstab entry with host and share" {
  "$SCRIPT"
  grep -q "//nas.local/roms" "$FSTAB"
}

@test "retropie-nas: fstab entry uses _netdev" {
  "$SCRIPT"
  grep -q "_netdev" "$FSTAB"
}

@test "retropie-nas: fstab entry references credentials file" {
  "$SCRIPT"
  grep -q "credentials=/etc/cyberdeck/nas.creds" "$FSTAB"
}

@test "retropie-nas: skips if already configured" {
  echo "//nas.local/roms /home/cyberdeck/RetroPie/roms cifs credentials=/etc/cyberdeck/nas.creds,_netdev 0 0" >> "$FSTAB"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"already configured"* ]]
}

@test "retropie-nas: FORCE=1 replaces existing fstab entry" {
  echo "//old.local/oldroms /home/cyberdeck/RetroPie/roms cifs credentials=/etc/cyberdeck/nas.creds,_netdev 0 0" >> "$FSTAB"
  run env FORCE=1 NAS_ROMS_SHARE="roms" "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "//nas.local/roms" "$FSTAB"
  ! grep -q "old.local" "$FSTAB"
}
