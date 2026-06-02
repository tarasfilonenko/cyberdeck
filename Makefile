.PHONY: test test-deps test-env flash deploy

PI_HOST ?= cyberdeck.local

# Install test environment (macOS via Homebrew)
test-deps:
	@command -v colima >/dev/null 2>&1 || brew install colima
	@command -v docker >/dev/null 2>&1 || brew install docker

# Start colima if not already running
test-env: test-deps
	@colima status 2>/dev/null | grep -q Running || colima start

# Build image and run all OS tests
test: test-env
	docker build -t cyberdeck-test -f os/tests/Dockerfile .
	docker run --rm cyberdeck-test bats os/tests/

# Flash and pre-configure a Raspberry Pi OS image onto an SD card or USB SSD
# Override the image:  IMAGE=/path/to.img make flash
flash:
	@chmod +x os/scripts/flash.sh && os/scripts/flash.sh

# Run setup on a real Pi over SSH (set PI_HOST=<hostname or IP>)
deploy:
	ssh $(PI_HOST) 'curl -fsSL https://raw.githubusercontent.com/tarasfilonenko/cyberdeck/main/os/scripts/install.sh | sudo bash'
