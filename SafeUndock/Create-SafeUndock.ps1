# Create-SafeUndock.ps1
# Registers the Safe Undock scheduled task with optional parameters

$taskName = "Safe Undock"
$taskDescription = "Flushes write buffers and ejects drives before undocking."
$scriptPath = "C:\Path\To\Folder\SafeUndock\SafeUndock.ps1"
$includeStopServices = $true  # Set to $false to exclude the -StopServices parameter

# Build argument list
$arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
if ($includeStopServices) {
    $arguments += " -StopServices"
}

$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $arguments
$principal = New-ScheduledTaskPrincipal -UserId "$env:USERNAME" -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 60)

Register-ScheduledTask -TaskName $taskName -Action $action -Principal $principal -Settings $settings -Description $taskDescription -Force
