$taskName = "Stop EA Background Service"
$scriptPath = "C:\<Replace-Path>\Stop-EAService.ps1"

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Settings $settings -Description "Scheduled task to stop EA Background Service" -Force
# To run this script, save it as Create-Stop-EAService.ps1 and execute it in PowerShell as your intended user with administrative privileges.
