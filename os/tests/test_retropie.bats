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

@test "retropie: runs retropie_packages.sh setup basic_install" {
  SETUP_DIR=$(mktemp -d)
  # Fake retropie_packages.sh that also creates the emulationstation binary
  printf '#!/bin/sh\necho "retropie_packages $*"\nprintf "#!/bin/sh\n" > /usr/local/bin/emulationstation\nchmod +x /usr/local/bin/emulationstation\n' \
    > "${SETUP_DIR}/retropie_packages.sh"
  chmod +x "${SETUP_DIR}/retropie_packages.sh"
  run env RETROPIE_SETUP_DIR="${SETUP_DIR}" "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"setup"* ]]
  [[ "$output" == *"basic_install"* ]]
  rm -rf "${SETUP_DIR}"
}
