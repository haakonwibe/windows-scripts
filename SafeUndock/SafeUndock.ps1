# SafeUndock.ps1
# Safely flush write buffers and eject external drives before undocking

param(
    [switch]$StopServices
)

$syncExe = "C:\Tools\SysinternalsSuite\Sync64.exe"
$removeDriveExe = "C:\Tools\RemoveDrive\RemoveDrive.exe"
$drives = @("D:", "E:")
$servicesToStop = @("EABackgroundService")  # Customize this list as needed

# Track results for final message
$serviceResults = @()
$driveResults = @()

# Optionally stop background services that may block safe removal
if ($StopServices) {
    foreach ($service in $servicesToStop) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            if ((Get-Service -Name $service).Status -eq 'Running') {
                Write-Output "Attempting to stop service '$service'..."
                Stop-Service -Name $service -Force
                
                # Wait and check if the service has actually stopped
                $attempts = 0
                $maxAttempts = 5
                $waitTimeSeconds = 2
                
                do {
                    Start-Sleep -Seconds $waitTimeSeconds
                    $serviceStatus = (Get-Service -Name $service).Status
                    $attempts++
                    
                    if ($serviceStatus -eq 'Stopped') {
                        Write-Output "Service '$service' successfully stopped."
                        $serviceResults += "✓ Service '$service' successfully stopped."
                        break
                    } else {
                        Write-Output "Service '$service' is still in '$serviceStatus' state. Attempt $attempts of $maxAttempts..."
                    }
                } while ($attempts -lt $maxAttempts -and $serviceStatus -ne 'Stopped')
                
                if ($serviceStatus -ne 'Stopped') {
                    Write-Output "Failed to stop service '$service' after $maxAttempts attempts."
                    $serviceResults += "✗ Failed to stop service '$service'."
                }
            } else {
                Write-Output "Service '$service' is not running."
                $serviceResults += "- Service '$service' was already stopped."
            }
        } else {
            Write-Output "Service '$service' not found."
            $serviceResults += "! Service '$service' not found."
        }
    }
}

# Flush write buffers for specified drives
foreach ($drive in $drives) {
    # Check if drive exists before attempting to sync
    if (Test-Path -Path $drive) {
        Write-Output "Flushing write buffers for drive $drive..."
        $syncProcess = Start-Process -FilePath $syncExe -ArgumentList $drive -Wait -PassThru
        if ($syncProcess.ExitCode -eq 0) {
            $driveResults += "✓ Write buffers flushed for drive $drive."
        } else {
            $driveResults += "! Error flushing buffers for drive $drive."
        }
    } else {
        Write-Output "Drive $drive not found, skipping sync."
        $driveResults += "- Drive $drive not found, skipping."
    }
}

# Eject drives cleanly using RemoveDrive with balloon tip
foreach ($drive in $drives) {
    # Check if drive exists before attempting to eject
    if (Test-Path -Path $drive) {
        Write-Output "Ejecting drive $drive..."
        $ejectionProcess = Start-Process -FilePath $removeDriveExe -ArgumentList "$drive -b" -Wait -PassThru
        if ($ejectionProcess.ExitCode -eq 0) {
            $driveResults += "✓ Drive $drive safely ejected."
        } else {
            $driveResults += "✗ Failed to eject drive $drive."
        }
    } else {
        Write-Output "Drive $drive not found, skipping ejection."
    }
}

# Build detailed result message
$resultMessage = "Safe Undock Results:`n`n"

if ($StopServices -and $serviceResults.Count -gt 0) {
    $resultMessage += "SERVICES:`n"
    $resultMessage += ($serviceResults -join "`n") + "`n`n"
}

if ($driveResults.Count -gt 0) {
    $resultMessage += "DRIVES:`n"
    $resultMessage += ($driveResults -join "`n") + "`n`n"
}

# Optional: Show confirmation popup
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show($resultMessage, "Safe Undock", 'OK', 'Information')
