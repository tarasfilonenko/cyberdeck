#!/usr/bin/env bash
# Install emulators via RetroPie-Setup. Each emulator is installed independently
# so a single network failure does not block the rest.
# Reference: https://retropie.org.uk/docs/Supported-Systems/
set -euo pipefail

RETROPIE_SETUP_DIR="${RETROPIE_SETUP_DIR:-/opt/RetroPie-Setup}"
REAL_USER="${SUDO_USER:-$(id -un)}"

if [[ ! -d "${RETROPIE_SETUP_DIR}" ]]; then
  echo "==> RetroPie-Setup not found — run make deploy-retropie first"
  exit 1
fi

declare -A EMULATORS=(
  [lr-nestopia]="NES"
  [lr-snes9x]="SNES"
  [lr-genesis-plus-gx]="Mega Drive"
  [lr-mgba]="GBA"
  [lr-mupen64plus-next]="N64"
  [lr-mame2003-plus]="Arcade"
  [lr-dosbox-pure]="DOS"
  [lr-fmsx]="MSX"
)

export SUDO_USER="$REAL_USER"
cd "${RETROPIE_SETUP_DIR}"

FAILED=()
for pkg in "${!EMULATORS[@]}"; do
  echo "==> Installing ${EMULATORS[$pkg]} (${pkg})..."
  if bash retropie_packages.sh "$pkg" install; then
    echo "  ok  ${EMULATORS[$pkg]}"
  else
    echo "  FAIL  ${EMULATORS[$pkg]} — skipping"
    FAILED+=("$pkg")
  fi
done

echo ""
if [[ ${#FAILED[@]} -eq 0 ]]; then
  echo "==> All emulators installed"
else
  echo "==> Installed with failures — the following can be retried individually:"
  for pkg in "${FAILED[@]}"; do
    echo "    sudo bash ${RETROPIE_SETUP_DIR}/retropie_packages.sh ${pkg} install"
  done
fi
