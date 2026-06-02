#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/clone-to-ssd.sh

@test "clone-to-ssd: exits 0 when no SSD connected after prompt" {
  run bash -c "echo '' | env SSD_DEV=/dev/nonexistent '$SCRIPT'"
  [ "$status" -eq 0 ]
}

@test "clone-to-ssd: prints skip message when SSD still absent after prompt" {
  run bash -c "echo '' | env SSD_DEV=/dev/nonexistent '$SCRIPT'"
  [[ "$output" == *"skipping"* ]]
}

@test "clone-to-ssd: exits 0 when already running from SSD" {
  # Point SSD_DEV at whatever the actual root device is so the check triggers
  ROOT_DEV=$(findmnt -n -o SOURCE / 2>/dev/null | sed 's/[0-9]*$//')
  run env SSD_DEV="${ROOT_DEV}" "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already running from SSD"* ]]
}
