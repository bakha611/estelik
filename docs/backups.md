# Don't lose everything when the PC's disk dies

Self-hosting means **you** are now Google's redundancy. A single disk is not a backup.

Target: **3-2-1** — 3 copies, 2 different media, 1 off-site.

| Copy | Where | How |
|------|-------|-----|
| 1 | PC disk (`UPLOAD_LOCATION`) | Immich itself |
| 2 | External USB HDD | weekly `rsync`/`restic` of `library/` (includes DB dumps in `library/backups`) |
| 3 | Off-site | restic to a cheap bucket (Backblaze B2 ≈ $6/TB/mo) or a drive kept at family's place |

Immich writes nightly database dumps to `library/backups/` automatically
(Admin → Settings → Backup). Back up the whole `library/` folder and you have
both the files and the database.

Restore drill: once, actually restore to another folder and open it. Untested backups
are wishes.
