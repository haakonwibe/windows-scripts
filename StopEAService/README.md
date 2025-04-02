# StopEAService

This utility provides a safe and consistent way to stop the `EABackgroundService`, which is known to block safe removal of USB drives on some systems.

Ideal for users who:
- Encounter issues ejecting USB drives while EA applications are running
- Want a one-click shortcut to stop the service before undocking or unplugging

## ⚙️ What It Does
- Stops the `EABackgroundService` if it is running
- Can be triggered from a desktop shortcut using a scheduled task

## 🛠 Files Included
```
StopEAService/
├── Stop-EAService.ps1            # PowerShell script to stop the EA service
├── Create-Stop-EAService.ps1     # Registers the scheduled task
├── StopEAService.bat             # Shortcut launcher that runs the task
├── README.md                     # This file
```

## 🚀 Setup
1. **Register the task** (once, elevated PowerShell):
   ```powershell
   .\Create-Stop-EAService.ps1
   ```

2. **Create a desktop shortcut** to `StopEAService.bat`
   - Optional: Assign a custom icon

3. **Run the task** anytime by double-clicking the shortcut

## 🧠 Notes
- This script is intended for machines where EA Background Service is regularly running in the background.
- If you're unsure whether this applies to you, check `services.msc` for `EABackgroundService`.

## 📄 License
MIT — free to use, modify, and share.

---

A simple tool to keep USB drive removal safe and frustration-free. 🛡️💡

