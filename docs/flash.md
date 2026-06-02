# Flash script

`os/scripts/flash.sh` — downloads, writes, and pre-configures Raspberry Pi OS on an SD card or USB SSD.

## What it does

1. Checks for `rpi-imager` and offers to install it via Homebrew (optional — flashing uses `dd`)
2. Prompts for hostname, username, password, Wi-Fi SSID and password (Wi-Fi is optional)
3. Rejects target devices larger than 128 GiB to guard against wiping an HDD
4. Downloads the Raspberry Pi OS 64-bit (Bookworm) image if not already cached in `$TMPDIR/cyberdeck-flash/`
5. Flashes the image with `dd`
6. Mounts the boot partition and injects:
   - `ssh` — empty file; `sshswitch.service` enables SSH on first boot
   - `userconf.txt` — `username:sha512hash`; `userconfig.service` creates the user on first boot
   - `firstrun.sh` — sets hostname and optionally writes a NetworkManager Wi-Fi keyfile; triggered by `systemd.run` in `cmdline.txt`

## Usage

```bash
make flash
```

Or directly:

```bash
os/scripts/flash.sh
```

To skip the download and use an existing image:

```bash
IMAGE=/path/to/raspios-bookworm-arm64.img make flash
```

To use a different image URL:

```bash
IMAGE_URL=https://... make flash
```

## Verifying it worked

After `make flash` completes, before removing the card you can inspect the boot partition on macOS:

```bash
ls /Volumes/bootfs/
# expect: ssh  userconf.txt  firstrun.sh  cmdline.txt  config.txt  ...

cat /Volumes/bootfs/userconf.txt
# expect: <username>:$6$...

grep systemd.run /Volumes/bootfs/cmdline.txt
# expect: ... systemd.run=/boot/firmware/firstrun.sh ...
```

On Linux, mount the first partition manually:

```bash
sudo mount /dev/sdb1 /mnt/boot
ls /mnt/boot/
```

## Troubleshooting

**"Could not determine size"** — the device path is wrong or the device is not connected.

**"Exceeds 128 GiB guard"** — you selected the wrong device, or you are intentionally using a large card. To proceed with a larger card, update `MAX_DEVICE_BYTES` in `flash.sh`.

**"Cannot hash password"** — macOS system `openssl` (LibreSSL) lacks the `-6` flag. Install OpenSSL via Homebrew:
```bash
brew install openssl
```

**Boot partition not found after write (macOS)** — macOS sometimes takes a moment to mount the partitions. Re-run `diskutil mountDisk /dev/diskN` manually, then re-run just the inject step:
```bash
os/scripts/flash.sh inject /Volumes/bootfs cyberdeck pi '<hash>' [ssid] [pass]
```

## Testing

The `inject` subcommand is tested directly without a real device:

```bash
make test-flash
```

This runs `os/tests/test_flash.bats` in Docker, which creates a temporary directory, calls `flash.sh inject`, and verifies all injected files.

## References

- [Raspberry Pi OS first boot customisation](https://www.raspberrypi.com/documentation/computers/configuration.html)
- [rpi-imager source](https://github.com/raspberrypi/rpi-imager) — reference for `firstrun.sh` structure
- [NetworkManager keyfile format](https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html)
