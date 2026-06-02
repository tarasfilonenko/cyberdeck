FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    bats \
    git \
    i2c-tools \
    && rm -rf /var/lib/apt/lists/*

# Fake sudo — scripts run as root in the container so this just passes through
RUN printf '#!/bin/sh\nexec "$@"\n' > /usr/local/bin/sudo && chmod +x /usr/local/bin/sudo

# raspi-config is Pi-specific; fake do_i2c by writing the dtparam line
RUN printf '#!/bin/sh\n\
if [ "$1" = "nonint" ] && [ "$2" = "do_i2c" ]; then\n\
  grep -q "dtparam=i2c_arm=on" /boot/firmware/config.txt 2>/dev/null || \\\n\
    echo "dtparam=i2c_arm=on" >> /boot/firmware/config.txt\n\
fi\n\
echo "raspi-config $*"\n' > /usr/local/bin/raspi-config && chmod +x /usr/local/bin/raspi-config

# udevadm — no udev daemon in containers; fake it
RUN printf '#!/bin/sh\necho "udevadm $*"\n' > /usr/local/bin/udevadm && chmod +x /usr/local/bin/udevadm

# Raspberry Pi boot directory structure
RUN mkdir -p /boot/firmware /etc/udev/rules.d

COPY . /cyberdeck
WORKDIR /cyberdeck
