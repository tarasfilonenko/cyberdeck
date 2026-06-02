# OS Setup

Step-by-step guide to configure Raspberry Pi OS for the cyberdeck.

## Prerequisites

- Raspberry Pi 4 (any RAM variant)
- microSD card (16 GB minimum, 32 GB+ recommended) or USB SSD
- Another computer to flash the image

## 1. Flash Raspberry Pi OS

Run the automated flash script from this repo (insert your SD card or USB SSD first):

```bash
make flash
```

The script will prompt for hostname, username, password, Wi-Fi (optional), and target device. It checks that rpi-imager is available (offers to install via Homebrew), rejects devices larger than 128 GiB to guard against wiping an HDD, downloads the Raspberry Pi OS 64-bit image, flashes it, and injects first-boot configuration into the boot partition.

To use a pre-downloaded image:

```bash
IMAGE=/path/to/raspios.img make flash
```

Alternatively, use the **Raspberry Pi Imager** GUI manually:  
https://www.raspberrypi.com/software/

> The default config path changed in Bookworm: it is now `/boot/firmware/` instead of `/boot/`.  
> Reference: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#updating-the-bootloader

## 2. Boot and connect

Insert the SD card, connect power, and SSH in:

```bash
ssh <username>@<hostname>.local
```

Or connect a keyboard and the HDMI display directly.

## 3. Update the system

```bash
sudo apt-get update && sudo apt-get full-upgrade -y
```

Reference: https://www.raspberrypi.com/documentation/computers/os.html#updating-and-upgrading-raspberry-pi-os

## 4. Run the bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/tarasfilonenko/cyberdeck/main/os/scripts/install.sh | sudo bash
```

This clones the repo to `/opt/cyberdeck` and runs `setup.sh`. Safe to re-run — it pulls the latest changes if the repo is already present.

## 5. Reboot

```bash
sudo reboot
```

## What the setup script does

| Script | Runs on | What it does |
|--------|---------|-------------|
| `flash.sh` | Host (Mac/Linux) | Downloads Raspberry Pi OS, flashes SD card, injects first-boot config |
| `display.sh` | Pi | Sets HDMI output for GeeekPi 10.1" 1024×600 |
| `i2c.sh` | Pi | Enables I2C bus and installs `i2c-tools` |
| `usb-hub.sh` | Pi | Installs udev rules, disables USB autosuspend |

All scripts are idempotent — safe to run multiple times.

## Verifying the setup

**Display:** screen should show the desktop at 1024×600 after reboot.

**I2C:**
```bash
i2cdetect -y 1
```

**USB touch:** connect the USB cable from the display — it registers as a HID device automatically.

## References

- [Raspberry Pi OS documentation](https://www.raspberrypi.com/documentation/computers/os.html)
- [config.txt reference](https://www.raspberrypi.com/documentation/computers/config_txt.html)
- [raspi-config reference](https://www.raspberrypi.com/documentation/computers/configuration.html)
- [udev rules guide](https://wiki.debian.org/udev)
