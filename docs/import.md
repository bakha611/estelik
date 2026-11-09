# Getting the existing ~23 GB of photos & videos in

Pick the path that matches where the photos are now. You can combine them; Immich
de-duplicates by file checksum, so uploading the same photo twice is harmless.

## A. They're on the phone → phone app backup (simplest)
1. Do this **at home on Wi-Fi**, phone on the charger, with the LAN URL (see remote-access.md).
2. Immich app → cloud icon (Backup) → select albums (Recents / Camera covers everything).
3. Enable **Background backup** so new photos keep flowing automatically.
4. iPhone: if photos are "optimised" in iCloud, the app has to download originals first —
   expect it to be slow. Keep the app open for the first big run.

23 GB over home Wi-Fi is typically 30–90 minutes of transfer, then several hours of
background processing on the PC (thumbnails, video transcoding, face + object detection).

## B. They're in Google Photos → Google Takeout + immich-go (keeps dates & albums)
1. https://takeout.google.com → deselect all → select **Google Photos** → export as
   `.zip`, 10 GB parts.
2. Download the zips to the home PC. **Don't unzip.**
3. Get `immich-go` (https://github.com/simulot/immich-go/releases).
4. In Immich web: Account Settings → API Keys → create one.
5. Run (check `immich-go upload --help` for the current flags):
   ```bash
   immich-go upload from-google-photos \
     --server=http://localhost:2283 --api-key=YOUR_KEY \
     /path/to/takeout-*.zip
   ```
   Takeout puts dates in sidecar JSON files; immich-go reads them so "On this day" lands
   on the right day. A plain folder upload would lose those dates.

## C. They're in a folder on the home PC ← our case
`scripts/import.ps1` downloads immich-go v0.32.0 and uploads over `localhost`, so 23 GB
moves disk-to-disk with no Wi-Fi involved:
```powershell
.\scripts\import.ps1 -Folder "D:\path\to\photos" -ApiKey "..." -DryRun
.\scripts\import.ps1 -Folder "D:\path\to\photos" -ApiKey "..." [-FoldersAsAlbums]
```
Photos are **copied** into the library, so you briefly need ~46 GB free. Keep the
original folder until backups exist; after that it can go.
Or, to leave files where they are without copying: Admin → External Libraries
(mount the folder into the container first).

## After import
- Admin → Jobs: watch Thumbnails, Metadata, Smart Search, Face Detection finish.
- People tab: name the face clusters. This powers search like "mom at the beach".
- Memories ("On this day…") appear at the top of the timeline automatically once
  there's history with correct dates.
