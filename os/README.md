# OS Setup

Step-by-step guide to configure Raspberry Pi OS for the cyberdeck.

## Prerequisites

- Raspberry Pi 4 (any RAM variant)
- microSD card (16 GB recommended — cloning to SSD copies the entire card regardless of used space, so larger cards mean longer clone times)
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

> **The first boot always happens from the SD card.** The setup script will configure USB boot and clone to the SSD — after the first reboot the Pi runs from the SSD and the SD card can be removed.

Insert the SD card (SSD connected via USB enclosure), connect power, and SSH in:

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
make deploy PI_HOST=<hostname or IP>
```

Or run the curl bootstrap directly on the Pi:

```bash
curl -fsSL https://raw.githubusercontent.com/tarasfilonenko/cyberdeck/main/os/scripts/install.sh | sudo bash
```

This clones the repo to `/opt/cyberdeck` and runs `setup.sh`, which:
- Configures the display, I2C, and USB hub
- Updates the EEPROM and sets USB as the primary boot device
- Clones the SD card to the SSD and expands the root filesystem (if SSD is connected)

Safe to re-run — idempotent at every step.

## 5. Reboot and switch to SSD

```bash
sudo reboot
```

The Pi reboots from the SSD. Confirm everything is configured correctly:

```bash
make verify PI_HOST=<hostname or IP> PI_USER=<username>
```

Once all checks pass, shut down and remove the SD card:

```bash
ssh <username>@<hostname>.local 'sudo shutdown -h now'
```

The Pi will boot from the SSD only from this point on. See [docs/ssd.md](../docs/ssd.md) for details and troubleshooting.

## What the setup script does

**Core setup scripts** — run automatically by `make deploy`:

| Script | What it does |
|--------|-------------|
| `display.sh` | Sets HDMI output for GeeekPi 10.1" 1024×600 |
| `i2c.sh` | Enables I2C bus and installs `i2c-tools` |
| `usb-hub.sh` | Installs udev rules, disables USB autosuspend |
| `usb-boot.sh` | Updates EEPROM and sets USB as primary boot device |
| `fan.sh` | Enables temperature-controlled fan for GeeekPi Armor Lite heatsink (GPIO14, on at 60 °C) |
| `clone-to-ssd.sh` | Clones SD card to SSD and expands root filesystem (skips if no SSD connected or already on SSD) |

**Optional software scripts** — run on demand via `make deploy-<script>`:

| Script | What it does |
|--------|-------------|
| `retropie.sh` | Installs RetroPie core: EmulationStation + RetroArch (run before `retropie-emulators.sh`) |
| `retropie-emulators.sh` | Installs emulators: NES, SNES, Mega Drive, GBA, N64, Arcade, DOS, MSX — each failure is non-fatal |
| `vnc.sh` | Enables RealVNC server on port 5900 |
| `nas.sh` | Configures shared NAS host and credentials — required before `backup.sh` and `retropie-nas.sh` |

All scripts are idempotent — safe to run multiple times.

## Verifying the setup

**Display:** screen should show the desktop at 1024×600 after reboot.

**I2C:**
```bash
i2cdetect -y 1
```

**USB touch:** connect the USB cable from the display — it registers as a HID device automatically.

## Make targets

Run from the repo root or the `os/` directory — the root `Makefile` forwards all targets to `os/Makefile`.

| Target | What it does |
|--------|-------------|
| `make deploy PI_HOST=<ip> PI_USER=<user>` | Full initial setup: clones repo to `/opt/cyberdeck` and runs all scripts (default user: `cyberdeck`) |
| `make sync PI_HOST=<ip>` | Pull latest scripts from GitHub onto the Pi (run before `deploy-<script>` targets) |
| `make deploy-<script> PI_HOST=<ip>` | Sync and run a single script on the Pi — e.g. `make deploy-vnc` or `make deploy-retropie` |
| `make force-deploy-<script> PI_HOST=<ip>` | Same as above but passes `FORCE=1` — re-runs even if already installed (only applies to scripts that support it, e.g. `retropie.sh`) |
| `make verify PI_HOST=<ip>` | Check setup on a live Pi — prints ok/FAIL for each component |
| `make test` | Run all bats tests in Docker (starts Colima if needed) |
| `make test-deps` | Install Colima + Docker via Homebrew |

## References

- [Raspberry Pi OS documentation](https://www.raspberrypi.com/documentation/computers/os.html)
- [config.txt reference](https://www.raspberrypi.com/documentation/computers/config_txt.html)
- [raspi-config reference](https://www.raspberrypi.com/documentation/computers/configuration.html)
- [udev rules guide](https://wiki.debian.org/udev)
