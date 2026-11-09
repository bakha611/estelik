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

Requirements: Docker + Compose v2, 4 GB+ RAM (6–8 GB comfortable), a disk with room
for 23 GB today plus growth (~2× headroom recommended).

```bash
git clone https://github.com/bakha611/estelik.git && cd estelik
./scripts/setup.sh /mnt/data/estelik/library      # Linux
# .\scripts\setup.ps1 -Library "D:/estelik/library"   # Windows (Docker Desktop)
```

Open `http://<pc-ip>:2283`, create the admin account, then:

1. [Remote access: phone + Mac via Tailscale](docs/remote-access.md)
2. [Import the existing ~23 GB](docs/import.md)
3. [Backups](docs/backups.md) — do this before deleting anything from Google/iCloud

## Roadmap

- [x] Phase 0 — repo, pinned Immich stack, setup scripts, docs
- [ ] Phase 1 — server running on home PC, Tailscale up, phone backup of 23 GB done
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
