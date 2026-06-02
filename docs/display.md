# Display

**Model:** GeeekPi 10.1" 1024×600 HDMI IPS  
**Connection:** HDMI (video) + USB-A (touch)

## Setup

Run `os/scripts/display.sh` or let `os/setup.sh` handle it.

The script appends to `/boot/firmware/config.txt`:

```
hdmi_force_hotplug=1
hdmi_cvt=1024 600 60 6 0 0 0
hdmi_group=2
hdmi_mode=87
```

Reboot after applying.

## Touch

The USB touch controller is a standard HID device — no driver needed. Plug in the USB cable and it works. If touch is inverted or offset, calibrate with `xinput_calibrator`.

## Troubleshooting

- **No signal:** confirm `hdmi_force_hotplug=1` is set and HDMI cable is in port 0 (closest to USB-C power).
- **Wrong resolution:** verify `hdmi_mode=87` and `hdmi_cvt` line match exactly — extra spaces break parsing.
- **Touch not recognized:** check `lsusb` for the touch controller and verify the HID udev rule in `os/config/99-cyberdeck.rules`.
