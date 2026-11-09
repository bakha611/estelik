# Home PC (Windows 11) as the estelik host

The PC is now the "cloud". These settings keep it reachable 24/7.

## Install once
1. **Docker Desktop**: https://docs.docker.com/desktop/setup/install/windows-install/
   keep *Use WSL 2* ticked. Reboot, start Docker Desktop once, accept the terms.
2. **Git for Windows** (or download the repo as a ZIP from GitHub).
3. **NVIDIA only:** update to the latest Game Ready / Studio driver. Nothing else needed;
   Docker Desktop passes the GPU through WSL2. Test with
   `docker run --rm --gpus all nvidia/cuda:12.6.3-base-ubuntu24.04 nvidia-smi`.
4. Run, in PowerShell **as Administrator** (so it can open the firewall port):
   ```powershell
   git clone https://github.com/bakha611/estelik.git
   cd estelik
   .\scripts\setup.ps1
   ```

## Keep it alive
| Setting | Where | Why |
|---|---|---|
| Docker Desktop → *Start when you sign in* | Docker Desktop → Settings → General | containers restart themselves after reboot |
| Sleep: **Never** (plugged in) | Settings → System → Power | a sleeping PC = no backups from the phone |
| Automatic sign-in after reboot | `netplwiz`, or Settings → Accounts → Sign-in options | Docker Desktop only runs once a user is signed in; Windows Update reboots otherwise leave it dead |
| Active hours | Settings → Windows Update → Advanced | fewer surprise reboots |
| Tailscale → *Run unattended* | Tailscale tray icon → Settings | Tailscale stays up even when nobody's signed in |
| Fixed LAN IP | router admin page → DHCP reservation | the phone's home-Wi-Fi URL never changes |

## Resource use
- Idle: ~1.5–2 GB RAM. During the first import + ML: CPU/GPU busy for a few hours.
- Docker Desktop gives WSL2 half the RAM by default. To cap it, create
  `%UserProfile%\.wslconfig` with:
  ```ini
  [wsl2]
  memory=6GB
  ```
  then `wsl --shutdown` and restart Docker Desktop.

## Where things live
- Photos/videos + nightly DB dumps: the library folder you chose (e.g. `D:\estelik\library`)
- Database: Docker volume `immich_pgdata` (inside WSL2 on C:)
- Config: `estelik\server\.env` (not in git; contains the DB password)

## Useful commands (run in `estelik\server`)
```powershell
docker compose ps                      # are all 4 containers "healthy"?
docker compose logs -f immich-server   # live logs
docker compose restart                 # turn it off and on again
```
