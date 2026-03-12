# Run Windows build using Flutter via a path WITHOUT spaces (directory junction).
# Fixes "Building native assets failed" when user folder has a space (e.g. "Mohamed Bayoumy").
#
# First time: run in PowerShell AS ADMINISTRATOR to create the junction:
#   New-Item -ItemType Junction -Path "D:\fvm_versions" -Target "C:\Users\Mohamed Bayoumy\fvm\versions" -Force
#
# Then run this script from the project root: .\scripts\run_windows_via_junction.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$flutterViaJunction = "D:\fvm_versions\3.41.2\bin"

if (-not (Test-Path "$flutterViaJunction\flutter.bat")) {
    Write-Host "Junction not found or Flutter not at $flutterViaJunction" -ForegroundColor Red
    Write-Host "Run once as Administrator:" -ForegroundColor Yellow
    Write-Host '  New-Item -ItemType Junction -Path "D:\fvm_versions" -Target "C:\Users\Mohamed Bayoumy\fvm\versions" -Force' -ForegroundColor Cyan
    exit 1
}

Set-Location $projectRoot
$env:PATH = "$flutterViaJunction;$env:PATH"

Write-Host "Using Flutter from D:\fvm_versions\3.41.2 (path without spaces)..." -ForegroundColor Cyan
flutter clean
if (Test-Path "build") { Remove-Item -Recurse -Force build }
flutter pub get
flutter run -d windows
