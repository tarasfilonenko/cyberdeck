# Backup

Planned backup setup using rsync to a local NAS.

## What to back up

| Path | Contents |
|------|----------|
| `/home/cyberdeck/` | Personal files and dotfiles |
| `/home/cyberdeck/RetroPie/` | ROMs, save files, BIOS |
| `/opt/retropie/configs/` | Per-emulator configs and save states |

OS configuration does **not** need to be backed up — `make deploy` recreates it from the repo.

## Planned setup

`os/scripts/backup.sh` will:

1. Prompt for NAS details (or accept as env vars: `NAS_HOST`, `NAS_SHARE`, `NAS_USER`, `NAS_PASS`)
2. Install `cifs-utils` if needed
3. Mount the share as a connection test
4. Save credentials to `/etc/cyberdeck/nas-backup.creds` (mode 600)
5. Save config to `/etc/cyberdeck/backup.conf`

Run via `make deploy-backup`.

## Restore flow

1. Flash a fresh SD card and run `make deploy` — reinstalls all OS config
2. Run `make deploy-retropie` — reinstalls RetroPie
3. Mount the NAS share and rsync data back:

```bash
mount -t cifs //<NAS_HOST>/<NAS_SHARE> /mnt/nas-backup -o credentials=/etc/cyberdeck/nas-backup.creds
rsync -av /mnt/nas-backup/home/ /home/cyberdeck/
rsync -av /mnt/nas-backup/retropie-configs/ /opt/retropie/configs/
```

## Not yet implemented

- `backup.sh` script
- rsync automation (cron or systemd timer)
- Retention policy
