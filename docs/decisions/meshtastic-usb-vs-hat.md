# ADR: Meshtastic — USB Node vs HAT

**Date:** 2026-06-02  
**Status:** Decided

## Decision

Use a **USB Meshtastic node** rather than a GPIO HAT.

## Context

Meshtastic can be integrated with a Raspberry Pi either as a HAT (SPI/UART over GPIO) or as a standalone node connected via USB serial.

## Options considered

| Option | Pros | Cons |
|--------|------|------|
| USB node (e.g. T-Beam, LILYGO T3S3) | GPIO fully preserved, node is self-contained, can be detached and used standalone, firmware updates easy via web flasher | Uses one USB port, slightly higher latency than direct SPI |
| GPIO HAT | No USB port used | Consumes all or most GPIO, HAT is not reusable, harder to update firmware |

## Rationale

- GPIO pins are a limited resource on this build — they're exposed externally for module accessories
- A USB node can be unplugged and used standalone in the field
- The Meshtastic Python CLI communicates over serial transparently — no difference in software integration
- Firmware updates are simpler without needing to put the Pi into bootloader mode

## Consequences

- One USB-A port on the hub is reserved for the Meshtastic node
- A udev rule gives the node a stable `/dev/meshtastic` path regardless of enumeration order
- `dialout` group membership required for the Pi user

## References

- [Meshtastic supported hardware](https://meshtastic.org/docs/hardware/devices/)
- [Meshtastic Python CLI](https://meshtastic.org/docs/software/python/cli/)
