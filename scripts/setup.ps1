# estelik server setup for Windows 11 (Docker Desktop, WSL2 backend).
#
# Usage (PowerShell, from the repo folder):
#   .\scripts\setup.ps1                                  # asks where to keep the library
#   .\scripts\setup.ps1 -Library "D:\estelik\library"    # or say it up front
#   .\scripts\setup.ps1 -NoGpu                           # ignore an NVIDIA card
#
# If scripts are blocked:  Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
param(
  [string]$Library = "",
  [switch]$NoGpu
)
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\server")

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# --- 1. Docker ---------------------------------------------------------------
Step "Checking Docker Desktop"
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  throw "Docker Desktop is not installed. Get it from https://docs.docker.com/desktop/setup/install/windows-install/ (keep 'Use WSL 2' ticked), reboot, start it once, then rerun this script."
}
docker info *> $null
if ($LASTEXITCODE -ne 0) { throw "Docker Desktop is installed but not running. Start it (whale icon in the tray turns steady) and rerun." }

# --- 2. Library location -----------------------------------------------------
if (-not (Test-Path .env)) {
  if (-not $Library) {
    Step "Disks on this PC (free space)"
    Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free } |
      Select-Object Name, @{n='Free (GB)';e={[math]::Round($_.Free/1GB)}}, @{n='Used (GB)';e={[math]::Round($_.Used/1GB)}} |
      Format-Table -AutoSize | Out-Host
    $default = if (Test-Path "D:\") { "D:\estelik\library" } else { "C:\estelik\library" }
    $Library = Read-Host "Where should photos live? Pick the biggest disk [$default]"
    if (-not $Library) { $Library = $default }
  }
  New-Item -ItemType Directory -Force -Path $Library | Out-Null
  $libFwd = (Resolve-Path $Library).Path -replace '\\', '/'

  # --- 3. GPU ----------------------------------------------------------------
  $files = "docker-compose.yml;docker-compose.windows.yml"
  $gpu = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -match 'NVIDIA' } | Select-Object -First 1
  if ($gpu -and -not $NoGpu) {
    Write-Host "Found $($gpu.Name) -> face recognition and video transcoding will use it." -ForegroundColor Green
    $files += ";docker-compose.nvidia.yml"
  } else {
    Write-Host "No NVIDIA GPU in use -> everything runs on the CPU (fine, just slower on the first import)."
  }

  # --- 4. .env ---------------------------------------------------------------
  $chars = [char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  $pw = -join (1..32 | ForEach-Object { $chars | Get-Random })
  $lines = Get-Content .env.example
  $lines = $lines -replace '^DB_PASSWORD=.*', "DB_PASSWORD=$pw"
  $lines = $lines -replace '^UPLOAD_LOCATION=.*', "UPLOAD_LOCATION=$libFwd"
  $lines = $lines -replace '^# COMPOSE_FILE=docker-compose\.yml$', "COMPOSE_FILE=$files"
  Set-Content -Path .env -Value $lines -Encoding ascii
  Write-Host "Wrote server\.env (library: $libFwd)"
} else {
  Write-Host "server\.env already exists - keeping it. Delete it to start over (only before the first real import!)."
}

# --- 5. Firewall: let phone/Mac on home Wi-Fi reach port 2283 ----------------
Step "Opening port 2283 on the private network"
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (Get-NetFirewallRule -DisplayName "estelik (Immich 2283)" -ErrorAction SilentlyContinue) {
  Write-Host "Firewall rule already there."
} elseif ($isAdmin) {
  New-NetFirewallRule -DisplayName "estelik (Immich 2283)" -Direction Inbound -Protocol TCP -LocalPort 2283 -Action Allow -Profile Private | Out-Null
  Write-Host "Added firewall rule (private networks only)."
} else {
  Write-Host "Not running as Administrator - skipped. If the phone can't reach the PC on Wi-Fi, rerun this script as Administrator." -ForegroundColor Yellow
}

# --- 6. Start ----------------------------------------------------------------
Step "Downloading and starting Immich (first time: a few GB, be patient)"
docker compose pull
if ($LASTEXITCODE -ne 0) { throw "docker compose pull failed - see the error above." }
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw "docker compose up failed - see the error above." }

Step "Waiting for the server to answer"
$ok = $false
foreach ($i in 1..60) {
  try { if ((Invoke-RestMethod http://localhost:2283/api/server/ping -TimeoutSec 3).res -eq 'pong') { $ok = $true; break } } catch {}
  Start-Sleep 5
}
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq 'Dhcp' } | Select-Object -First 1).IPAddress
if ($ok) {
  Write-Host "`nestelik is up." -ForegroundColor Green
  Write-Host "  On this PC:     http://localhost:2283"
  Write-Host "  On home Wi-Fi:  http://$($ip):2283"
  Write-Host "Next: open it, create the admin account, then run .\scripts\import.ps1"
} else {
  Write-Host "Server didn't answer within 5 minutes. Check: docker compose logs immich-server" -ForegroundColor Yellow
}
