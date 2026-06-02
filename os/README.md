# OS Setup

Step-by-step guide to configure Raspberry Pi OS for the cyberdeck.

## Prerequisites

- Raspberry Pi 4 (any RAM variant)
- microSD card (16 GB minimum, 32 GB+ recommended) or USB SSD
- Another computer to flash the image

## 1. Flash Raspberry Pi OS

Download and install the **Raspberry Pi Imager**:  
https://www.raspberrypi.com/software/

In the Imager:
1. **Device:** Raspberry Pi 4
2. **OS:** Raspberry Pi OS (64-bit) — *Bookworm or later*
3. **Storage:** your SD card or SSD
4. Click the gear icon (⚙) to pre-configure:
   - Set hostname, username, and password
   - Enable SSH
   - Configure Wi-Fi if needed
5. Write the image

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
curl -fsSL https://raw.githubusercontent.com/tarasfilonenko/cyberdeck/main/os/install.sh | sudo bash
```

This clones the repo to `/opt/cyberdeck` and runs `setup.sh`. Safe to re-run — it pulls the latest changes if the repo is already present.

## 5. Reboot

```bash
sudo reboot
```

## What the setup script does

| Script | What it does |
|--------|-------------|
| `display.sh` | Sets HDMI output for GeeekPi 10.1" 1024×600 |
| `i2c.sh` | Enables I2C bus and installs `i2c-tools` |
| `usb-hub.sh` | Installs udev rules, disables USB autosuspend |

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
