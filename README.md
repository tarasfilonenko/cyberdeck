# Cyberdeck

DIY cyberdeck built around a Raspberry Pi 4. This repo tracks everything: OS configuration, hardware designs, 3D models, and design decisions.

## Confirmed Hardware

- **SBC:** Raspberry Pi 4
- **Display:** GeeekPi 10.1" 1024×600 HDMI IPS (HDMI video + USB touch)
- **Hub:** USB-C hub as central module
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

## Quick Start

Suggested sequence for a fresh build:

### 1. Flash the SD card (on your Mac/Linux host)

```bash
make flash
```

Prompts for hostname, username, password, Wi-Fi (optional), and target device. Downloads Raspberry Pi OS, writes it, and injects SSH + credentials + hostname into the boot partition. Guards against accidentally writing to a drive larger than 128 GiB.

To use a pre-downloaded image:
```bash
IMAGE=/path/to/raspios.img make flash
```

### 2. Boot and connect

Insert the card, power on the Pi, then SSH in:

```bash
ssh <username>@<hostname>.local
```

### 3. Install cyberdeck software on the Pi

```bash
make deploy PI_HOST=<hostname or IP>
```

Pulls the latest scripts from GitHub and runs the full setup over SSH.

---

## Make targets

| Target | What it does |
|--------|-------------|
| `make flash` | Flash and configure an SD card (host-side, interactive) |
| `make deploy PI_HOST=<ip>` | Run setup on a live Pi over SSH |
| `make test` | Run all bats tests in Docker (starts Colima if needed) |
| `make test-deps` | Install Colima + Docker via Homebrew |

## OS Setup

See [os/README.md](os/README.md) for full setup instructions.

## Docs

- [Display](docs/display.md)
- [I2C](docs/i2c.md)
- [Boot config](docs/boot.md)

## Decisions

- [Display selection](docs/decisions/display-selection.md)
