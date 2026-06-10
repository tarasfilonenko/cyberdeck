FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    bats \
    cifs-utils \
    ddcutil \
    dialog \
    smbclient \
    e2fsprogs \
    git \
    i2c-tools \
    parted \
    unzip \
    xmlstarlet \
    && rm -rf /var/lib/apt/lists/*

# Fake sudo — scripts run as root in the container so this just passes through
# Handle -u <user> flag by skipping it (already root)
RUN printf '#!/bin/sh\nif [ "$1" = "-u" ]; then shift 2; fi\nexec "$@"\n' > /usr/local/bin/sudo && chmod +x /usr/local/bin/sudo

# raspi-config is Pi-specific; fake do_i2c and do_boot_order
RUN printf '#!/bin/sh\n\
if [ "$1" = "nonint" ] && [ "$2" = "do_i2c" ]; then\n\
  grep -q "dtparam=i2c_arm=on" /boot/firmware/config.txt 2>/dev/null || \\\n\
    echo "dtparam=i2c_arm=on" >> /boot/firmware/config.txt\n\
fi\n\
if [ "$1" = "nonint" ] && [ "$2" = "do_boot_order" ]; then\n\
  mkdir -p /var/lib/raspi-config\n\
  echo "BOOT_ORDER=$3" > /var/lib/raspi-config/boot-order\n\
fi\n\
if [ "$1" = "nonint" ] && [ "$2" = "do_vnc" ]; then\n\
  mkdir -p /var/lib/raspi-config\n\
  echo "0" > /var/lib/raspi-config/vnc\n\
fi\n\
if [ "$1" = "nonint" ] && [ "$2" = "get_vnc" ]; then\n\
  cat /var/lib/raspi-config/vnc 2>/dev/null || echo "1"\n\
fi\n\
if [ "$1" = "nonint" ] && [ "$2" = "do_wayland" ]; then\n\
  mkdir -p /var/lib/raspi-config\n\
  echo "$3" > /var/lib/raspi-config/wayland\n\
fi\n\
echo "raspi-config $*"\n' > /usr/local/bin/raspi-config && chmod +x /usr/local/bin/raspi-config

# rpi-eeprom-update is Pi-specific; fake it as a no-op
RUN printf '#!/bin/sh\necho "rpi-eeprom-update $*"\n' \
    > /usr/local/bin/rpi-eeprom-update && chmod +x /usr/local/bin/rpi-eeprom-update

# udevadm — no udev daemon in containers; fake it
RUN printf '#!/bin/sh\necho "udevadm $*"\n' > /usr/local/bin/udevadm && chmod +x /usr/local/bin/udevadm

# Raspberry Pi boot directory structure
RUN mkdir -p /boot/firmware /etc/udev/rules.d

COPY . /cyberdeck
RUN chmod +x /cyberdeck/os/scripts/*.sh
WORKDIR /cyberdeck
