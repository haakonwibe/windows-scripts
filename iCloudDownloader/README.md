# iCloudDownloader (Public)

📥 Sync your iCloud Photos and shared albums to local folders using [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader).

This is a **sanitized public version** of a private sync setup. Replace the placeholders with your own email and target directories before use.

---

## 🧑‍🔧 Quick Setup

1. Download or clone this repo
2. Place `icloudpd.exe` in the same folder
3. Edit the `.bat` files with your Apple ID and desired download paths
4. (Optional) Run the PowerShell scripts to register scheduled weekly sync tasks

---

## 📥 Requirements

- [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader)
  - Use the precompiled Windows `.exe` version if you're not using Python
  - Rename the file to `icloudpd.exe` and place it alongside the `.bat` files
- Windows 10 or 11
- PowerShell 5.1+
- Optional: Admin rights to create scheduled tasks

---

## 📦 What It Does

Downloads and syncs:

- 📁 Your main iCloud Photos library to a local folder
- 📁 Shared iCloud albums to a separate folder

---

## 🗂 Folder Structure

```
iCloudDownloader/
├── Download-iCloudPhotos.bat              # Syncs main library (edit username)
├── Download-iCloudShared.bat              # Syncs shared library (edit username + library ID)
├── Download-iCloudMenu.bat                # Optional menu-based launcher
├── Create-Download-iCloudPhotosTask.ps1   # Registers a scheduled task for photo sync
├── Create-Download-iCloudSharedTask.ps1   # Registers a scheduled task for shared sync
├── README.md                              # This file
```

---

## 💻 Example Commands

Edit `Download-iCloudPhotos.bat`:
```bat
icloudpd.exe --username your@email.com --directory D:\YourPhotosFolder\
```

Edit `Download-iCloudShared.bat`:
```bat	  
icloudpd.exe --username your@email.com --library YourSharedLibraryID --directory D:\YourSharedFolder\
```

## 🔁 Scheduled Sync (Optional)

Register weekly scheduled tasks using PowerShell:
```powershell
.\Create-Download-iCloudPhotosTask.ps1
.\Create-Download-iCloudSharedTask.ps1
```

These create tasks under the current user's context. Be sure to update any file paths or email addresses before use.

## 🐞 Troubleshooting
- ❗ First run may prompt for 2FA and generate a cookies file — keep this in the same folder
- 📂 Ensure the destination folders exist before syncing
- 🔐 Use full/absolute paths in .bat files when running scheduled tasks
- 🧪 Test .bat files manually to confirm they run before scheduling