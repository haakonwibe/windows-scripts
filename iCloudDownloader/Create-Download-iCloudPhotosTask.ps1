# Create-Download-iCloudPhotosTask.ps1
# Registers a weekly scheduled task to sync iCloud Photos

$taskName = "Download iCloud Photos"
$description = "Weekly sync of main iCloud Photos library"
$batFile = "C:\Path\To\Download-iCloudPhotos.bat"  # Update this path

$action = New-ScheduledTaskAction -Execute $batFile
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 4:00am
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 30)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Description $description -Force
