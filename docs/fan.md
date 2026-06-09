# Fan control

## What it does

Enables temperature-controlled fan operation for the GeeekPi Armor Lite heatsink (PWM fan). The fan turns on at 55 °C and off once the CPU cools below ~45 °C (10 °C hysteresis built into the `gpio-fan` overlay).

The script appends one line to `/boot/firmware/config.txt`:

```
dtoverlay=gpio-fan,gpiopin=14,temp=55000
```

`temp` is in millidegrees Celsius — `55000` = 55 °C.

## Hardware wiring

The GeeekPi Armor Lite fan connector maps to the Pi 4 GPIO header:

| Wire | GPIO header pin | Signal |
|------|----------------|--------|
| Red | Pin 4 | 5 V |
| Black | Pin 6 | GND |
| Yellow/Blue | Pin 8 (GPIO14) | Fan signal |

No soldering or additional wiring is needed — the connector plugs directly onto the header.

## Verifying it worked

After rebooting, confirm the overlay loaded:

```bash
dtoverlay -l
```

You should see `gpio-fan` in the list.

To check the current CPU temperature:

```bash
vcgencmd measure_temp
```

The fan should spin up when temperature reaches 55 °C. You can trigger it temporarily by running a stress test:

```bash
sudo apt-get install -y stress
stress --cpu 4 --timeout 30
vcgencmd measure_temp
```

## Troubleshooting

**Fan never spins:** Confirm the connector is on the correct header pins (pin 4, 6, 8). Check that `dtoverlay=gpio-fan` is present in `/boot/firmware/config.txt` and the Pi has been rebooted.

**Fan runs constantly:** The overlay only controls on/off — it does not do variable speed. Constant running at boot before temperatures rise is normal for a few seconds while the overlay initialises.

**`dtoverlay -l` does not show gpio-fan:** The overlay failed to load. Check `/var/log/syslog` for dtoverlay errors and confirm `/boot/firmware/config.txt` contains the correct line.

## References

- [gpio-fan overlay — Raspberry Pi config.txt reference](https://www.raspberrypi.com/documentation/computers/config_txt.html#gpio-fan)
- [GeeekPi Armor Lite product page](https://wiki.52pi.com/index.php/P165T)
