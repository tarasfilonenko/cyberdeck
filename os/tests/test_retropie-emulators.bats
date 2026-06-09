#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/retropie-emulators.sh

setup() {
  SETUP_DIR=$(mktemp -d)
  printf '#!/bin/sh\necho "retropie_packages $*"\n' > "${SETUP_DIR}/retropie_packages.sh"
  chmod +x "${SETUP_DIR}/retropie_packages.sh"
  export SETUP_DIR
  export RETROPIE_SETUP_DIR="$SETUP_DIR"
}

teardown() {
  rm -rf "$SETUP_DIR"
}

@test "retropie-emulators: exits 1 when retropie not installed" {
  run env RETROPIE_SETUP_DIR="/nonexistent" "$SCRIPT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"deploy-retropie first"* ]]
}

@test "retropie-emulators: installs all expected emulators" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"lr-nestopia"* ]]
  [[ "$output" == *"lr-snes9x"* ]]
  [[ "$output" == *"lr-mgba"* ]]
  [[ "$output" == *"lr-mupen64plus-next"* ]]
  [[ "$output" == *"lr-dosbox-pure"* ]]
  [[ "$output" == *"lr-fmsx"* ]]
}

@test "retropie-emulators: reports success when all emulators install" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"All emulators installed"* ]]
}

@test "retropie-emulators: continues and reports failures without exiting" {
  printf '#!/bin/sh\nif [ "$1" = "lr-snes9x" ]; then exit 1; fi\necho "retropie_packages $*"\n' \
    > "${SETUP_DIR}/retropie_packages.sh"
  chmod +x "${SETUP_DIR}/retropie_packages.sh"
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"FAIL"* ]]
  [[ "$output" == *"lr-snes9x"* ]]
  [[ "$output" == *"retried individually"* ]]
}
