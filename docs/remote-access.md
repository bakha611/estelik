# Reaching estelik from your phone and Mac

The server lives on the home PC at port `2283`. On home Wi-Fi everything can reach it
directly at `http://<pc-lan-ip>:2283`. To reach it from anywhere else (mobile data, AITU,
a café) **without opening ports on the router**, we use **Tailscale**: a private
encrypted network between your own devices. Free for personal use.

```
 iPhone/Android ─┐                         ┌─ home PC (Immich, port 2283)
                 ├── Tailscale (WireGuard) ┤
 MacBook ────────┘                         └─ disk with library/
```

## 1. Home PC
- Linux: `curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up`
- Windows: install from https://tailscale.com/download/windows and sign in.
- In the admin console (https://login.tailscale.com/admin/machines) rename the PC to `estelik`
  and **disable key expiry** for it, so it never silently drops off.
- Turn on **MagicDNS** (Admin → DNS). The PC is then reachable as `http://estelik:2283`.

## 2. Phone
1. Install the **Tailscale** app, sign in with the same account. Leave it on.
2. Install the **Immich** app (App Store / Google Play).
3. Server URL: `http://estelik:2283` → log in with your account.

## 3. Mac
1. Install Tailscale (Mac App Store), same account.
2. Open `http://estelik:2283` in the browser — that's the full Google Photos-style UI.
3. Optional: Safari → File → *Add to Dock* to make it feel like an app.

## Two URLs, one app (faster at home)
In the Immich mobile app: Settings → Networking → **Automatic URL switching**.
- Local Wi-Fi name → `http://192.168.x.x:2283` (full LAN speed for the big backup)
- External → `http://estelik:2283` (via Tailscale)

## Hardening checklist
- [ ] Do **not** port-forward 2283 on the router; Tailscale is the only door.
- [ ] Strong admin password; separate user accounts for family members.
- [ ] Fixed LAN IP for the PC (DHCP reservation on the router).
- [ ] PC set to never sleep (or Wake-on-LAN) — a sleeping PC = no photos.
