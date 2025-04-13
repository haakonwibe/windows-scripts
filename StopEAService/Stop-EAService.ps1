# Stop-EAService.ps1
$serviceName = "EABackgroundService"

if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    if ((Get-Service -Name $serviceName).Status -eq 'Running') {
        Write-Output "Attempting to stop service '$serviceName'..."
        Stop-Service -Name $serviceName -Force
        
        # Wait and check if the service has actually stopped
        $attempts = 0
        $maxAttempts = 5
        $waitTimeSeconds = 2
        
        do {
            Start-Sleep -Seconds $waitTimeSeconds
            $serviceStatus = (Get-Service -Name $serviceName).Status
            $attempts++
            
            if ($serviceStatus -eq 'Stopped') {
                Write-Output "Service '$serviceName' successfully stopped."
                break
            } else {
                Write-Output "Service '$serviceName' is still in '$serviceStatus' state. Attempt $attempts of $maxAttempts..."
            }
        } while ($attempts -lt $maxAttempts -and $serviceStatus -ne 'Stopped')
        
        if ($serviceStatus -ne 'Stopped') {
            Write-Output "Failed to stop service '$serviceName' after $maxAttempts attempts."
        }
    } else {
        Write-Output "Service '$serviceName' is not running."
    }
} else {
    Write-Output "Service '$serviceName' not found."
}
