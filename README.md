# estelik

> *естелік* (Kazakh) — a keepsake, a memento.

Our own Google Photos: every photo and video from the phone, stored on the home PC,
reachable from the phone and the Mac anywhere, with **"On this day…" memories**, face
recognition, map, and smart search ("dog on snow"). No subscription; storage is
capped only by the PC's disk.

Built on [Immich](https://immich.app) (pinned to **v3.3.6**), plus Tailscale for
secure access from outside the house.

## Architecture

```
            ┌──────────── home PC (Docker) ─────────────┐
 phone ──┐  │ immich-server :2283  ← web UI + API       │
         ├──┤ immich-machine-learning (faces, CLIP)     │
 Mac ────┘  │ postgres + valkey                         │
 (Tailscale)│ library/ → photos, videos, DB dumps       │
            └───────────────────────────────────────────┘
```

## Quick start (home PC)

The host is the **home PC on Windows 11** (Docker Desktop + WSL2). It stays home and
always on; phone, Mac and laptop are just clients. Needs 8 GB+ RAM and a disk with room
for the 23 GB now plus growth (~2× headroom).

PowerShell **as Administrator**:

```powershell
git clone https://github.com/bakha611/estelik.git
cd estelik
.\scripts\setup.ps1          # asks which disk, detects an NVIDIA GPU, opens port 2283, starts Immich
```

Open `http://localhost:2283`, create the admin account, make an API key
(Account Settings → API Keys), then pull in the existing folder:

```powershell
.\scripts\import.ps1 -Folder "D:\path\to\photos" -ApiKey "..." -DryRun   # look first
.\scripts\import.ps1 -Folder "D:\path\to\photos" -ApiKey "..."           # then for real
```

Then:

1. [Keep the PC alive 24/7](docs/windows-host.md) — sleep, auto sign-in, Docker autostart
2. [Remote access: phone + Mac via Tailscale](docs/remote-access.md)
3. [Backups](docs/backups.md) — do this before deleting the original folder

Linux host instead? `./scripts/setup.sh /path/to/library` does the same.

## Roadmap

- [x] Phase 0 — repo, pinned Immich stack, setup scripts, docs
- [ ] Phase 1 — server running on home PC, 23 GB folder imported, Tailscale up, phone auto-backup on
- [ ] Phase 2 — automated off-site backup (restic) + restore test
- [ ] Phase 3 — our own extras on top of the Immich API:
  - daily "On this day" digest pushed to Telegram
  - "1 second every day" yearly video auto-compiled from the timeline
  - duplicate / blurry-shot cleaner
  - Kazakh/Russian place names in map view
- [ ] Phase 4 — GPU acceleration for ML/transcoding if the PC has one (`server/hwaccel.*.yml`)

## Updating

```bash
cd server
# bump IMMICH_VERSION in .env after reading https://github.com/immich-app/immich/releases
docker compose pull && docker compose up -d
```
