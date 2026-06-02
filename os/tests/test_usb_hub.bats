#!/usr/bin/env bats

SCRIPT=/cyberdeck/os/scripts/usb-hub.sh
CMDLINE=/boot/firmware/cmdline.txt
UDEV_DEST=/etc/udev/rules.d/99-cyberdeck.rules

setup() {
  echo "console=serial0,115200 console=tty1 root=PARTUUID=test rootfstype=ext4 rootwait" > "$CMDLINE"
  rm -f "$UDEV_DEST"
}

@test "usb-hub: installs udev rules file" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  [ -f "$UDEV_DEST" ]
}

@test "usb-hub: udev rules match source" {
  "$SCRIPT"
  diff /cyberdeck/os/config/99-cyberdeck.rules "$UDEV_DEST"
}

@test "usb-hub: appends usbcore.autosuspend=-1 to cmdline.txt" {
  run "$SCRIPT"
  [ "$status" -eq 0 ]
  grep -q "usbcore.autosuspend=-1" "$CMDLINE"
}

@test "usb-hub: idempotent — autosuspend not duplicated on second run" {
  "$SCRIPT"
  "$SCRIPT"
  [ "$(grep -o "usbcore.autosuspend=-1" "$CMDLINE" | wc -l)" -eq 1 ]
}

@test "usb-hub: idempotent — udev rules not modified if already correct" {
  "$SCRIPT"
  before=$(md5sum "$UDEV_DEST")
  "$SCRIPT"
  after=$(md5sum "$UDEV_DEST")
  [ "$before" = "$after" ]
}
