#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/retropie.sh
FAKE_ES=/usr/local/bin/emulationstation

teardown() {
  rm -f "$FAKE_ES"
}

@test "retropie: exits 0 when already installed" {
  printf '#!/bin/sh\n' > "$FAKE_ES" && chmod +x "$FAKE_ES"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
}

@test "retropie: prints skip message when already installed" {
  printf '#!/bin/sh\n' > "$FAKE_ES" && chmod +x "$FAKE_ES"
  run "$SCRIPT"
  [[ "$output" == *"already installed"* ]]
}

@test "retropie: runs retropie_setup.sh basic_install" {
  SETUP_DIR=$(mktemp -d)
  printf '#!/bin/sh\necho "retropie_setup $*"\n' > "${SETUP_DIR}/retropie_setup.sh"
  chmod +x "${SETUP_DIR}/retropie_setup.sh"
  run env RETROPIE_SETUP_DIR="${SETUP_DIR}" "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"basic_install"* ]]
  rm -rf "${SETUP_DIR}"
}
