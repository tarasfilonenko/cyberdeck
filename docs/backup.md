# NAS Integration

Planned integration with a local NAS for game storage and backups.

## Architecture

```
nas.sh               — configure NAS connection once (prompts, tests, saves credentials)
  ├── backup.sh      — rsync key directories to NAS
  └── retropie-nas.sh — mount ROM library from NAS
```

Run order:
1. `make deploy-nas` — sets up shared NAS config
2. `make deploy-backup` and/or `make deploy-retropie-nas` independently after

## nas.sh (shared NAS setup)

Prompts for NAS details (or accepts as env vars: `NAS_HOST`, `NAS_SHARE`, `NAS_USER`, `NAS_PASS`):
- Installs `cifs-utils`
- Tests the connection by mounting temporarily
- Saves config to `/etc/cyberdeck/nas.conf`
- Saves credentials to `/etc/cyberdeck/nas.creds` (mode 600)

Idempotent — skips if already configured. Use `FORCE=1` to reconfigure.

## backup.sh

Reads `/etc/cyberdeck/nas.conf` (requires `make deploy-nas` first).

Backs up:

| Path | Contents |
|------|----------|
| `/home/cyberdeck/` | Personal files and dotfiles |
| `/home/cyberdeck/RetroPie/` | Save files, BIOS |
| `/opt/retropie/configs/` | Per-emulator configs and save states |

OS configuration does **not** need to be backed up — `make deploy` recreates it from the repo.

Automated via systemd timer or cron (daily).

## retropie-nas.sh

Reads `/etc/cyberdeck/nas.conf` (requires `make deploy-nas` first).

Mounts the NAS ROM library to `/home/cyberdeck/RetroPie/roms/` via fstab with `_netdev` so it auto-mounts on boot after network is up:

```
//<NAS_HOST>/<SHARE>/roms /home/cyberdeck/RetroPie/roms cifs credentials=/etc/cyberdeck/nas.creds,uid=cyberdeck,gid=cyberdeck,_netdev 0 0
```

ROMs stay on the NAS — no SSD space used, accessible from any device on the network.

## Restore flow

1. Flash SD, run `make deploy` — reinstalls all OS config
2. Run `make deploy-retropie` — reinstalls RetroPie
3. Run `make deploy-nas` — reconnects to NAS
4. Run `make deploy-retropie-nas` — ROMs available immediately
5. Run `make deploy-backup` and restore from latest backup snapshot

## Not yet implemented

- `nas.sh`
- `backup.sh`
- `retropie-nas.sh`
- Backup retention policy
