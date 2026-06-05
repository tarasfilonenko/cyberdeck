#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/nas.sh

setup() {
  FAKE_BIN=$(mktemp -d)
  # Default: smbclient succeeds (valid credentials)
  printf '#!/bin/sh\nexit 0\n' > "$FAKE_BIN/smbclient"
  chmod +x "$FAKE_BIN/smbclient"
  export FAKE_BIN
  export PATH="$FAKE_BIN:$PATH"
  # Avoid prompts
  export NAS_HOST="nas.local"
  export NAS_USER="testuser"
  export NAS_PASS="testpass"
  rm -f /etc/cyberdeck/nas.conf /etc/cyberdeck/nas.creds
}

teardown() {
  rm -f /etc/cyberdeck/nas.conf /etc/cyberdeck/nas.creds
  rm -rf "$FAKE_BIN"
}

@test "nas: exits 0 when already configured" {
  mkdir -p /etc/cyberdeck
  printf 'NAS_HOST="nas.local"\nNAS_USER="testuser"\n' > /etc/cyberdeck/nas.conf
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "nas: prints skip message when already configured" {
  mkdir -p /etc/cyberdeck
  printf 'NAS_HOST="nas.local"\nNAS_USER="testuser"\n' > /etc/cyberdeck/nas.conf
  run "$SCRIPT"
  [[ "$output" == *"already configured"* ]]
}

@test "nas: exits 0 on valid credentials" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "nas: saves host to config file" {
  "$SCRIPT"
  grep -q 'NAS_HOST="nas.local"' /etc/cyberdeck/nas.conf
}

@test "nas: saves credentials file" {
  "$SCRIPT"
  grep -q "username=testuser" /etc/cyberdeck/nas.creds
  grep -q "password=testpass" /etc/cyberdeck/nas.creds
}

@test "nas: credentials file is mode 600" {
  "$SCRIPT"
  [ "$(stat -c %a /etc/cyberdeck/nas.creds)" = "600" ]
}

@test "nas: exits 1 on failed authentication" {
  printf '#!/bin/sh\nexit 1\n' > "$FAKE_BIN/smbclient"
  chmod +x "$FAKE_BIN/smbclient"
  run "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Authentication failed"* ]]
}

@test "nas: FORCE=1 reconfigures even when already configured" {
  mkdir -p /etc/cyberdeck
  printf 'NAS_HOST="old.local"\nNAS_USER="olduser"\n' > /etc/cyberdeck/nas.conf
  run env FORCE=1 "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q 'NAS_HOST="nas.local"' /etc/cyberdeck/nas.conf
}
