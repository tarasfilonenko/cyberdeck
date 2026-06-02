# Cyberdeck

DIY cyberdeck built around a Raspberry Pi 4. This repo tracks everything: OS configuration, hardware designs, 3D models, firmware configs, and design decisions.

## Hardware

- **SBC:** Raspberry Pi 4
- **Display:** GeeekPi 10.1" 1024×600 HDMI IPS (HDMI video + USB touch)
- **Hub:** USB-C hub as central module
- **I2C:** Exposed externally for peripheral modules
- **GPIO:** Broken out for accessories
- **Mounting:** NATO rail for accessories
- **Wireless:** Meshtastic via USB node (preserves GPIO)

## Repo Structure

```
cyberdeck/
├── hardware/
│   ├── pcb/          # KiCad PCB projects
│   └── 3d-models/    # Fusion 360 / STL files
├── os/               # Raspberry Pi OS setup
│   ├── setup.sh      # Main bootstrap script
│   ├── scripts/      # Idempotent configuration scripts
│   └── config/       # Config files and udev rules
├── firmware/         # Firmware configs (Meshtastic, MCUs, etc.)
└── docs/
    ├── decisions/    # ADR-style design decision records
    └── *.md          # Per-subsystem documentation
```

## Getting Started

```bash
git clone https://github.com/tarasfilonenko/cyberdeck
cd cyberdeck/os
sudo ./setup.sh
```

## Docs

- [Display](docs/display.md)
- [I2C](docs/i2c.md)
- [Meshtastic](docs/meshtastic.md)
- [Boot config](docs/boot.md)

## Decisions

- [Display selection](docs/decisions/display-selection.md)
- [Meshtastic: USB vs HAT](docs/decisions/meshtastic-usb-vs-hat.md)
