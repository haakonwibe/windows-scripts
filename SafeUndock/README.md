# SafeUndock

Safely disconnect from your docking station by flushing external drive buffers and cleanly ejecting external hard drives — all with a single click.

This script is ideal for users who:
- Use write-caching (buffering) for performance on external drives
- Have drives mounted as `DriveType = 3` (Local Disk) instead of removable
- Want to avoid data corruption when undocking

## ⚙️ What It Does
- Optionally stops user-defined services (e.g. `EABackgroundService`) using `-StopServices` flag
- Flushes write buffers using `Sync64.exe` (Sysinternals)
- Ejects USB drives using `RemoveDrive.exe` (by Uwe Sieber)
- Displays a Windows balloon tip and optional popup message when it’s safe to disconnect

## 🛠 Files Included
```
SafeUndock/
├── SafeUndock.ps1              # Main PowerShell script (runs the logic)
├── Create-SafeUndock.ps1       # Registers the scheduled task (customizable with -StopServices)
├── SafeUndock.bat              # Desktop shortcut launcher (calls the task)
├── README.md                   # This file
```

## 📦 Requirements
- Windows 10 or 11
- `Sync64.exe` from Sysinternals Suite (placed in `C:\Tools\SysinternalsSuite`)
- `RemoveDrive.exe` (placed in `C:\Tools\RemoveDrive`)
- Administrator privileges to register the task

## 🚀 Setup
1. **Register the task** (run once with elevated PowerShell):
   ```powershell
   .\Create-SafeUndock.ps1
   ```
   > You can toggle whether the script runs with the `-StopServices` parameter by setting the `$includeStopServices` variable at the top of `Create-SafeUndock.ps1`.

2. **Create a desktop shortcut** to `SafeUndock.bat`.
   - Optional: Assign a custom icon

3. **Run it anytime** by double-clicking the shortcut — no UAC prompt!

4. **Optional:** Modify the `SafeUndock.ps1` script to add/remove services in the `$servicesToStop` array. Use the `-StopServices` switch to activate this behavior.

## 🔍 Why RemoveDrive.exe?
Drives with write-caching enabled appear as `DriveType = 3` (Local Disk), and cannot be ejected using built-in PowerShell or WMI methods.

`RemoveDrive.exe` handles these cases reliably by:
- Flushing open handles
- Calling Windows APIs to safely remove the hardware
- Showing a native balloon notification

## 📄 License
MIT — free to use, modify, and share.

---

Made for convenience. Built for peace of mind. 🧠💾
