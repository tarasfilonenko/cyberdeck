#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/display.sh
CONFIG=/boot/firmware/config.txt

setup() {
  > "$CONFIG"
}

@test "display: appends hdmi_force_hotplug" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "hdmi_force_hotplug=1" "$CONFIG"
}

@test "display: appends hdmi_cvt, hdmi_group, hdmi_mode" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "hdmi_cvt=1024 600 60 6 0 0 0" "$CONFIG"
  grep -q "hdmi_group=2" "$CONFIG"
  grep -q "hdmi_mode=87" "$CONFIG"
}

@test "display: idempotent — no duplicate lines on second run" {
  "$SCRIPT"
  "$SCRIPT"
  [ "$(grep -c "hdmi_force_hotplug=1" "$CONFIG")" -eq 1 ]
  [ "$(grep -c "hdmi_group=2" "$CONFIG")" -eq 1 ]
}

@test "display: does not modify config when settings already present" {
  printf 'hdmi_force_hotplug=1\nhdmi_cvt=1024 600 60 6 0 0 0\nhdmi_group=2\nhdmi_mode=87\n' > "$CONFIG"
  before=$(md5sum "$CONFIG")
  "$SCRIPT"
  after=$(md5sum "$CONFIG")
  [ "$before" = "$after" ]
}
