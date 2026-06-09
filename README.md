# Cyberdeck

DIY cyberdeck built around a Raspberry Pi 4. This repo tracks everything: OS configuration, hardware designs, 3D models, and design decisions.

## Confirmed Hardware

- **SBC:** Raspberry Pi 4
- **Display:** GeeekPi 10.1" 1024×600 HDMI IPS (HDMI video + USB touch)
- **Hub:** USB-C hub as central module
- **Storage:** M.2 2242 128 GB SATA III SSD + USB 3.0 M.2 NGFF enclosure (ASM1153E)
- **Cooling:** GeeekPi Armor Lite heatsink with PWM fan (GPIO14)
- **I2C:** Exposed externally for peripheral modules
- **GPIO:** Broken out for accessories
- **Mounting:** NATO rail for accessories

## Repo Structure

```
cyberdeck/
├── hardware/
│   ├── pcb/          # KiCad PCB projects
│   └── 3d-models/    # Fusion 360 / STL files
├── os/               # Raspberry Pi OS setup
│   ├── scripts/      # All runnable scripts (install, setup, components)
│   ├── config/       # Config files and udev rules
│   └── tests/        # Docker-based bats tests
├── firmware/         # Firmware configs for embedded components
└── docs/
    ├── decisions/    # ADR-style design decision records
    └── *.md          # Per-subsystem documentation
```

## Setup

See [os/README.md](os/README.md) for the full setup guide — flashing the SD card, running the bootstrap, and switching to SSD boot.


## Docs

- [Display](docs/display.md)
- [I2C](docs/i2c.md)
- [Boot config](docs/boot.md)
- [SSD boot](docs/ssd.md)
- [Backup](docs/backup.md)
- [Fan control](docs/fan.md)

## Decisions

- [Display selection](docs/decisions/display-selection.md)
