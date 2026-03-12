# Fix: "Building native assets failed" on Windows

## Cause

The error happens when **Flutter is installed in a path that contains a space** (e.g. `C:\Users\Mohamed Bayoumy\fvm\...`). The Dart native assets build step fails on Windows when paths have spaces.

---

## Quick fix (no reinstall): use a directory junction

This uses your **existing** FVM install via a path without spaces. Run in **PowerShell as Administrator** once:

```powershell
# Create junction so the same Flutter is reachable as D:\fvm_versions\3.41.2 (no space)
New-Item -ItemType Junction -Path "D:\fvm_versions" -Target "C:\Users\Mohamed Bayoumy\fvm\versions" -Force
```

Then **every time** you want to build for Windows, run Flutter from the junction path so the build sees no space:

```powershell
cd D:\iNote\eatic_offline
$env:PATH = "D:\fvm_versions\3.41.2\bin;$env:PATH"
flutter clean
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
flutter pub get
flutter run -d windows
```

Or use the script: **`.\scripts\run_windows_via_junction.ps1`** (see below).

---

## Solution: Use FVM with a path that has no spaces (clean setup)

Do this **once**:

### 1. Set FVM cache to a path without spaces

**Option A – System environment variable (recommended)**

1. Press `Win + R`, type `sysdm.cpl`, Enter.
2. **Advanced** tab → **Environment Variables**.
3. Under **User variables** (or **System variables**), click **New**:
   - Name: `FVM_CACHE_PATH`
   - Value: `D:\fvm`
4. OK to save. **Close and reopen** your terminal/IDE so the variable is applied.

**Option B – Current PowerShell session only**

```powershell
$env:FVM_CACHE_PATH = "D:\fvm"
```

### 2. Install Flutter in the new location

In a **new** terminal (so it sees `FVM_CACHE_PATH`):

```powershell
cd D:\iNote\eatic_offline
fvm install 3.41.2
fvm use 3.41.2
```

This installs Flutter under `D:\fvm\versions\3.41.2` (no spaces).

### 3. Clean and build

```powershell
fvm flutter clean
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
fvm flutter pub get
fvm flutter run -d windows
```

From now on, use `fvm flutter` (or your IDE’s Flutter that points to FVM) so the build uses `D:\fvm\...` and the "Building native assets failed" error should stop.

---

## If you don’t want to change FVM path

- Move or clone the **project** to a path without spaces (e.g. `D:\dev\eatic_offline`) and build from there, **or**
- Run the build from **Developer Command Prompt for VS 2022** and ensure Flutter/Dart are on a path without spaces.

## Get more details if it still fails

```powershell
fvm flutter run -d windows -v
```

Search the output for **"Building native assets failed"** and check the lines **above** it for the real error message.
