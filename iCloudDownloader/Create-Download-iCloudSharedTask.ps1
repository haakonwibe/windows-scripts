# Create-Download-iCloudSharedTask.ps1
# Registers a weekly scheduled task to sync shared iCloud albums

$taskName = "Download iCloud Shared Library"
$description = "Weekly sync of shared iCloud Photos library"
$batFile = "C:\Path\To\Download-iCloudShared.bat"  # Update this path

$action = New-ScheduledTaskAction -Execute $batFile
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4:30am
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $description -Force
