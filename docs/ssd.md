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

You do not need to flash the SSD separately. The simplest path is to clone the running SD card to the SSD while the Pi is booted — all configuration, setup, and data comes along for free.

### 1. Enable USB boot

Boot from the SD card and run the bootstrap (if you haven't already):

```bash
make deploy PI_HOST=<hostname or IP>
```

`setup.sh` includes `usb-boot.sh`, which stages the EEPROM update and sets USB as the primary boot device. A reboot is required to activate the EEPROM change — but do the clone first.

### 2. Clone SD card to SSD

With the SSD connected via the USB enclosure:

```bash
sudo dd if=/dev/mmcblk0 of=/dev/sda bs=4M status=progress
sync
```

This copies the full SD card — OS, config, everything — to the SSD. Since the SSD (128 GB) is larger than the SD card, expand the root filesystem to use the remaining space:

```bash
sudo raspi-config nonint do_expand_rootfs
```

### 3. Reboot from SSD

```bash
sudo reboot
```

The Pi now tries USB first. With the SSD plugged in, it boots from the clone. Confirm:

```bash
findmnt / | grep -o 'sd[a-z]\|mmcblk[0-9]'
# expect: sda
```

### 4. Remove the SD card

Once confirmed running from SSD:

```bash
sudo shutdown -h now
```

Remove the SD card, power on — boots from SSD only.

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
