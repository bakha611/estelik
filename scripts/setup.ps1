# One-shot setup for the estelik server on Windows (Docker Desktop with WSL2 backend).
# Usage (PowerShell):  .\scripts\setup.ps1 -Library "D:/estelik/library"
param([string]$Library = "")
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..\server")

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "Install Docker Desktop first: https://docs.docker.com/desktop/setup/install/windows-install/"
}

if (-not (Test-Path .env)) {
  $chars = [char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
  $pw = -join (1..32 | ForEach-Object { $chars | Get-Random })
  $env = Get-Content .env.example
  $env = $env -replace '^DB_PASSWORD=.*', "DB_PASSWORD=$pw"
  if ($Library) { $env = $env -replace '^UPLOAD_LOCATION=.*', "UPLOAD_LOCATION=$Library" }
  Set-Content -Path .env -Value $env -Encoding ascii
  Write-Host "Created server\.env with a random DB password."
}

docker compose pull
docker compose up -d
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.PrefixOrigin -eq 'Dhcp' } | Select-Object -First 1).IPAddress
Write-Host "`nestelik is starting. Open http://$($ip):2283 and create the admin account."
