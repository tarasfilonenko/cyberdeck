# SSD Boot

Running the cyberdeck from an M.2 SATA SSD via USB enclosure rather than an SD card. This gives faster I/O, higher endurance, and removes the SD card from the build.

## Hardware

- M.2 2242 128 GB SATA III SSD
- USB 3.0 to M.2 NGFF SATA enclosure (ASM1153E chipset)

Connect the SSD to the enclosure and plug into one of the Pi's USB 3.0 (blue) ports.

## How it works

The Raspberry Pi 4 bootloader supports USB mass storage boot. `usb-boot.sh` does two things:

1. **Updates the EEPROM** (`rpi-eeprom-update -a`) to ensure USB boot support is available
2. **Sets boot order to USB-first** (`raspi-config nonint do_boot_order B2`) so the Pi tries the SSD before the SD card

The change takes effect on the next reboot.

## Setup sequence

You do not need to flash the SSD separately. `setup.sh` handles everything: it clones the running SD card to the SSD, so all configuration and data comes along automatically.

### 1. Connect the SSD

Plug the SSD (in its USB enclosure) into one of the Pi's USB 3.0 (blue) ports before running the bootstrap.

### 2. Run the bootstrap

```bash
make deploy PI_HOST=<hostname or IP>
```

`setup.sh` runs in order:
- `usb-boot.sh` — updates EEPROM, sets USB as primary boot device
- `clone-to-ssd.sh` — clones `/dev/mmcblk0` → `/dev/sda`, expands root filesystem

If no SSD is connected, `clone-to-ssd.sh` skips gracefully and prints a message. Connect the SSD and re-run `make deploy` to clone later.

### 3. Reboot and confirm

```bash
sudo reboot
```

The Pi boots from the SSD. Confirm:

```bash
findmnt / | grep -o 'sd[a-z]\|mmcblk[0-9]'
# expect: sda
```

### 4. Remove the SD card

```bash
sudo shutdown -h now
```

Remove the SD card. The Pi boots from the SSD only from this point on.

## Verifying the setup

**Check boot device:**
```bash
findmnt / | grep -o 'sd[a-z]\|mmcblk[0-9]'
# expect: sda (SSD), not mmcblk0 (SD card)
```

**Check boot order in EEPROM:**
```bash
vcgencmd bootloader_config | grep BOOT_ORDER
# expect: BOOT_ORDER=0xf14 or similar USB-first value
```

## Troubleshooting

**Pi still boots from SD card after reboot** — the EEPROM update may not have applied yet. Check with `sudo rpi-eeprom-update`; if an update is pending it will say so. Reboot once more.

**Pi won't boot after removing SD card** — the SSD may not be recognised. Re-insert the SD card, boot, check `lsblk` to confirm the SSD is visible as `sda`, and verify the boot order with `vcgencmd bootloader_config`.

**SSD not visible as `sda`** — check the USB enclosure connection. The ASM1153E chipset is natively supported; no driver install is needed on Bookworm.

## References

- [Raspberry Pi USB mass storage boot](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#usb-mass-storage-boot)
- [Raspberry Pi 4 bootloader configuration](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#raspberry-pi-4-bootloader-configuration)
- [rpi-eeprom-update documentation](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#updating-the-bootloader)
