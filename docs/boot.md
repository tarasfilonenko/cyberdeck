# Boot Configuration

All boot config lives in `/boot/firmware/config.txt` (Raspberry Pi OS Bookworm+).

A reference snippet of cyberdeck-specific additions is in `os/config/config.txt`.

## Key settings

| Setting | Value | Reason |
|---------|-------|--------|
| `hdmi_force_hotplug` | 1 | Force HDMI output even with no EDID |
| `hdmi_group` | 2 | CEA → DMT mode (required for custom resolution) |
| `hdmi_mode` | 87 | Custom CVT mode |
| `hdmi_cvt` | 1024 600 60 6 0 0 0 | 1024×600 @ 60Hz |
| `gpu_mem` | 128 | Enough for desktop compositing |
| `dtparam=i2c_arm` | on | Enable I2C bus 1 |

## cmdline.txt

`usbcore.autosuspend=-1` is appended to prevent USB hub from suspending connected accessories.

## Updating config

```bash
sudo nano /boot/firmware/config.txt
sudo reboot
```
