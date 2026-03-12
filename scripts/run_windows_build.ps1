# Run Windows build using FVM from a path WITHOUT spaces to fix "Building native assets failed".
# Use this if your user folder has a space (e.g. "Mohamed Bayoumy").
# First time: set FVM_CACHE_PATH in Windows Environment Variables to D:\fvm (see WINDOWS_BUILD_FIX.md).

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

if (-not $env:FVM_CACHE_PATH) {
    Write-Host "Setting FVM_CACHE_PATH for this session to D:\fvm (no spaces)..." -ForegroundColor Yellow
    $env:FVM_CACHE_PATH = "D:\fvm"
}

Set-Location $projectRoot

Write-Host "Installing/using Flutter 3.41.2 via FVM (path without spaces)..." -ForegroundColor Cyan
fvm install 3.41.2
fvm use 3.41.2

Write-Host "Cleaning and building for Windows..." -ForegroundColor Cyan
fvm flutter clean
if (Test-Path "build") { Remove-Item -Recurse -Force build }
fvm flutter pub get
fvm flutter run -d windows
