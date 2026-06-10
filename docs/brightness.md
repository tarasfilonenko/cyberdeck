# Display brightness control

**Display:** GeeekPi 10.1" HDMI IPS  
**Method:** DDC/CI (Display Data Channel / Command Interface) via `ddcutil`

DDC/CI communicates with the display over the HDMI cable using an embedded I2C channel, so the Pi can read and set display settings — including brightness — without any special cable or GPIO wiring.

## Prerequisites

`i2c.sh` must have been run first — it loads the `i2c-dev` kernel module that `ddcutil` uses to reach the HDMI DDC bus.

## Setup

```bash
make deploy-brightness PI_HOST=<hostname or IP>
```

Or on the Pi directly:

```bash
sudo /opt/cyberdeck/os/scripts/brightness.sh
```

The script:
1. Installs `ddcutil`
2. Adds the invoking user to the `i2c` group for non-root access (log out and back in to apply)

## Usage

```bash
# Confirm the display is detected on the DDC bus
ddcutil detect

# Read current brightness (VCP feature code 10)
ddcutil getvcp 10

# Set brightness to 60% (range 0–100)
ddcutil setvcp 10 60
```

## Troubleshooting

- **`ddcutil detect` finds no display** — confirm `i2c-dev` is loaded (`lsmod | grep i2c_dev`) and that the HDMI cable is in port 0 (closest to USB-C power). Try `sudo ddcutil detect` to rule out permission issues.
- **Permission denied on `/dev/i2c-*`** — ensure you are in the `i2c` group (`id`) and have logged out and back in since running the setup script.
- **`No display found on I2C bus`** — some HDMI cables do not carry the DDC wire. Try a different cable.
