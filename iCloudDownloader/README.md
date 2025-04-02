# iCloudDownloader (Public)

📥 Sync your iCloud Photos and shared albums to local folders using [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader).

This is a **sanitized public version** of a private sync setup. Replace the placeholders with your own email and target directories before use.

## 📦 What It Does
- Downloads:
  - 📁 Main iCloud Photos library to a local folder
  - 📁 Shared iCloud albums to a separate folder

## 🛠 Folder Structure
```
iCloudDownloader/
├── Download-iCloudPhotos.bat              # Syncs main library (edit username)
├── Download-iCloudShared.bat              # Syncs shared library (edit username + library ID)
├── Download-iCloudMenu.bat                # Optional menu-based launcher
├── Create-Download-iCloudPhotosTask.ps1   # Registers a scheduled task for photo sync
├── Create-Download-iCloudSharedTask.ps1   # Registers a scheduled task for shared sync
├── README.md                              # This file
```

## 🧑‍💻 Example Commands
Edit `Download-iCloudPhotos.bat`:
```bat
icloudpd.exe --username your@email.com --directory D:\YourPhotosFolder\
```

Edit `Download-iCloudShared.bat`:
```bat
icloudpd.exe --username your@email.com --library YourSharedLibraryID --directory D:\YourSharedFolder\
```

## 🔁 Scheduled Sync (Optional)
To automatically sync weekly, register scheduled tasks using the PowerShell scripts:

```powershell
.\Create-Download-iCloudPhotosTask.ps1
.\Create-Download-iCloudSharedTask.ps1
```

These scripts create weekly tasks that run with the current user's privileges. Be sure to update any file paths or usernames before running.

## 🛡 Notes
- You must have [icloudpd](https://github.com/icloud-photos-downloader/icloud_photos_downloader) downloaded and renamed as `icloudpd.exe`
- Place it alongside the `.bat` files, or update the paths accordingly
- You may be prompted for 2FA on first run

## 📄 License
MIT — feel free to adapt and extend.