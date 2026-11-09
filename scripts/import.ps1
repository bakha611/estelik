# Import an existing folder of photos/videos into estelik (runs on the home PC).
#
# 1. In Immich (http://localhost:2283): profile picture -> Account Settings -> API Keys -> New API Key.
# 2. Dry run first (uploads nothing, prints what it found):
#      .\scripts\import.ps1 -Folder "E:\Photos" -ApiKey "xxxx" -DryRun
# 3. Real run:
#      .\scripts\import.ps1 -Folder "E:\Photos" -ApiKey "xxxx"
#    Add -FoldersAsAlbums to turn each subfolder into an Immich album.
#
# Safe to re-run: files already in Immich are skipped (matched by checksum).
# The original folder is only READ, never modified - keep it until your backups are set up.
param(
  [Parameter(Mandatory)] [string]$Folder,
  [Parameter(Mandatory)] [string]$ApiKey,
  [string]$Server = "http://localhost:2283",
  [switch]$FoldersAsAlbums,
  [switch]$DryRun
)
$ErrorActionPreference = "Stop"
$ImmichGoVersion = "v0.32.0"

if (-not (Test-Path $Folder)) { throw "Folder not found: $Folder" }

$tools = Join-Path $PSScriptRoot "..\tools"
$exe = Join-Path $tools "immich-go.exe"
if (-not (Test-Path $exe)) {
  Write-Host "Downloading immich-go $ImmichGoVersion ..."
  New-Item -ItemType Directory -Force -Path $tools | Out-Null
  $zip = Join-Path $tools "immich-go.zip"
  Invoke-WebRequest "https://github.com/simulot/immich-go/releases/download/$ImmichGoVersion/immich-go_Windows_x86_64.zip" -OutFile $zip
  Expand-Archive $zip -DestinationPath $tools -Force
  Remove-Item $zip
}

$size = (Get-ChildItem $Folder -Recurse -File | Measure-Object Length -Sum)
Write-Host ("Folder: {0}  -  {1:N0} files, {2:N1} GB" -f $Folder, $size.Count, ($size.Sum / 1GB))

$uploadArgs = @(
  "upload", "from-folder",
  "--server=$Server", "--api-key=$ApiKey",
  "--recursive",
  "--date-from-name",          # WhatsApp/Telegram images often lack EXIF: take the date from IMG-20210314-WA0001.jpg
  "--on-errors=continue",      # one broken file shouldn't stop 23 GB
  "--folder-as-album=$(if ($FoldersAsAlbums) { 'FOLDER' } else { 'NONE' })"
)
if ($DryRun) { $uploadArgs += "--dry-run" }
$uploadArgs += $Folder

& $exe @uploadArgs
if ($LASTEXITCODE -ne 0) { throw "immich-go exited with code $LASTEXITCODE" }

if (-not $DryRun) {
  Write-Host "`nUpload done. Immich now builds thumbnails, transcodes videos and runs face/object"
  Write-Host "detection in the background - watch Administration -> Job Queues. Hours, not minutes."
}
