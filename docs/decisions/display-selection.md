# ADR: Display Selection

**Date:** 2026-06-02  
**Status:** Decided

## Decision

Use the **GeeekPi 10.1" 1024×600 HDMI IPS** display.

## Context

The cyberdeck needs a screen that balances portability, resolution, and ease of integration with a Raspberry Pi 4.

## Options considered

| Option | Pros | Cons |
|--------|------|------|
| GeeekPi 10.1" HDMI IPS | Standard HDMI + USB touch, no driver needed, good viewing angles | 1024×600 is not full HD |
| Official 7" Raspberry Pi DSI | DSI connector, no HDMI needed | Occupies DSI port, smaller, lower brightness |
| HDMI 1080p display | Full HD | Physically larger, overkill for portable use |
| SPI/parallel display | Low cost | Slow refresh, complex setup |

## Rationale

- HDMI connection is plug-and-play — no custom overlays or SPI bit-banging
- USB touch requires zero driver work on modern kernels
- 10.1" at 1024×600 is readable and fits the form factor
- Keeps DSI port free for future use

## Consequences

- `hdmi_cvt` must be set manually — the display does not advertise EDID over HDMI reliably
- USB hub needs one port reserved for touch

## References

- [GeeekPi product page](https://wiki.geekworm.com/10.1_INCH_HDMI_1024x600_IPS_LCD)
- [RPi config.txt display options](https://www.raspberrypi.com/documentation/computers/config_txt.html#hdmi-mode)
