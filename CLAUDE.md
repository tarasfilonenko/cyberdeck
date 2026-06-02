# CLAUDE.md — Repo conventions

## Core rule: confirmed only

Only add content for hardware or software that is confirmed to be part of the build (purchased, in hand, or explicitly decided). Do not add placeholder sections, speculative integrations, or "planned" components. If something is being considered but not confirmed, it does not belong in scripts, docs, or config files.

## Adding hardware

1. Hardware must be confirmed (physically owned or explicitly decided) before any script, config, or doc is written for it.
2. For any non-trivial hardware choice, create a decision record in `docs/decisions/` documenting what alternatives were considered and why this one was chosen.
3. Update the **Confirmed Hardware** section in `README.md`.

## Adding OS scripts

Each script in `os/scripts/` must:

- Be **idempotent** — safe to run multiple times without side effects
- Have corresponding bats tests in `os/tests/` — add or update tests when the script changes
- Have a corresponding doc in `docs/` explaining what it does, how to verify it worked, and how to troubleshoot
- Reference the upstream source or documentation it is based on (link in script comments or the corresponding doc)
- Be listed in `os/scripts/setup.sh` and in the table in `os/README.md`

## Adding docs

- Per-subsystem docs go in `docs/`
- Design decisions go in `docs/decisions/` as ADR-style records (context, options, decision, rationale, consequences)
- `os/README.md` is the human-facing setup guide — keep it step-by-step with source links

## Confirmed hardware (source of truth)

| Component | Notes |
|-----------|-------|
| Raspberry Pi 4 | SBC |
| GeeekPi 10.1" 1024×600 HDMI IPS | Display — HDMI video + USB touch |
| USB-C hub | Central module |

## What does not belong here

- Unconfirmed or "might add later" components
- Generic tutorials not specific to this build
- Duplicated content (if a doc exists, extend it rather than create a parallel one)
