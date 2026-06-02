# I2C

I2C bus 1 (pins GPIO 2/3) is exposed externally for peripheral modules.

## Setup

Run `os/scripts/i2c.sh` or let `os/setup.sh` handle it.

## Scanning the bus

```bash
i2cdetect -y 1
```

## Common addresses

| Address | Device |
|---------|--------|
| 0x3C    | SSD1306 OLED display |
| 0x48    | ADS1115 ADC |
| 0x68    | MPU-6050 IMU |
| 0x76    | BME280 env sensor |

## Adding a peripheral

1. Wire SDA → GPIO 2 (pin 3), SCL → GPIO 3 (pin 5), GND, 3.3V
2. Run `i2cdetect -y 1` to confirm address
3. Install the appropriate Python library (`pip3 install adafruit-circuitpython-<device>`)
