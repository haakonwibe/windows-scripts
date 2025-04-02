# SafeUndock.ps1
# Safely flush write buffers and eject external drives before undocking

param(
    [switch]$StopServices
)

$syncExe = "C:\Tools\SysinternalsSuite\Sync64.exe"
$removeDriveExe = "C:\Tools\RemoveDrive\RemoveDrive.exe"
$drives = @("D:", "E:")
$servicesToStop = @("EABackgroundService")  # Customize this list as needed

# Optionally stop background services that may block safe removal
if ($StopServices) {
    foreach ($service in $servicesToStop) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            if ((Get-Service -Name $service).Status -eq 'Running') {
                Stop-Service -Name $service -Force
            }
        }
    }
}

# Flush write buffers for specified drives
foreach ($drive in $drives) {
    Start-Process -FilePath $syncExe -ArgumentList $drive -Wait
}

# Eject drives cleanly using RemoveDrive with balloon tip
foreach ($drive in $drives) {
    Start-Process -FilePath $removeDriveExe -ArgumentList "$drive -b" -Wait
}

# Optional: Show confirmation popup
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show("Drives flushed and safely removed. You can now disconnect from the dock.", "Safe Undock", 'OK', 'Information')
