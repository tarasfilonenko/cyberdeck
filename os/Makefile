.PHONY: test test-deps test-env deploy sync verify

PI_HOST ?= cyberdeck.local
PI_USER ?= cyberdeck

# Install test environment (macOS via Homebrew)
test-deps:
	@command -v colima >/dev/null 2>&1 || brew install colima
	@command -v docker >/dev/null 2>&1 || brew install docker

# Start colima if not already running
test-env: test-deps
	@colima status 2>/dev/null | grep -q Running || colima start

# Build image and run all OS tests
# Build context is .. (repo root) so the container gets the full repo at /cyberdeck
test: test-env
	docker build -t cyberdeck-test -f tests/Dockerfile ..
	docker run --rm cyberdeck-test bats os/tests/

# Full initial setup: clones repo to /opt/cyberdeck and runs all scripts
COMMIT       := $(shell git rev-parse HEAD)
COMMIT_SHORT := $(shell git rev-parse --short HEAD)

deploy:
	@echo "==> Deploying $(COMMIT_SHORT)"
	ssh -t $(PI_USER)@$(PI_HOST) 'curl -fsSL https://raw.githubusercontent.com/tarasfilonenko/cyberdeck/$(COMMIT)/os/scripts/install.sh | sudo bash'

# Pull latest scripts from GitHub onto the Pi
sync:
	ssh $(PI_USER)@$(PI_HOST) 'cd /opt/cyberdeck && git fetch origin && git reset --hard origin/$(COMMIT) && chmod +x os/scripts/*.sh'

# Run a single script — syncs first to ensure latest version is on the Pi
deploy-%: sync
	ssh -t $(PI_USER)@$(PI_HOST) 'sudo /opt/cyberdeck/os/scripts/$*.sh'

# Verify setup on a live Pi
verify:
	ssh $(PI_USER)@$(PI_HOST) 'bash /opt/cyberdeck/os/scripts/verify.sh'
