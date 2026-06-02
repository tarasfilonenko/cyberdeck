# Meshtastic

Meshtastic is integrated via a USB node (not a HAT) to preserve all GPIO pins.

## Setup

Run `os/scripts/meshtastic.sh` or let `os/setup.sh` handle it.

The node appears at `/dev/meshtastic` once connected (udev symlink for the CP2102 USB-serial chip).

## Basic usage

```bash
# Check node info
meshtastic --port /dev/meshtastic --info

# Send a message
meshtastic --port /dev/meshtastic --sendtext "hello mesh"

# Listen for incoming messages
meshtastic --port /dev/meshtastic --listen
```

## Configuration

```bash
# Set node name
meshtastic --port /dev/meshtastic --set-owner "Cyberdeck"

# Set region (required before transmitting)
meshtastic --port /dev/meshtastic --set lora.region US
```

## Firmware updates

Use the [Meshtastic Web Flasher](https://flasher.meshtastic.org/) or the CLI:

```bash
meshtastic --port /dev/meshtastic --update
```

## References

- [Meshtastic docs](https://meshtastic.org/docs/)
- [Python CLI reference](https://meshtastic.org/docs/software/python/cli/)
