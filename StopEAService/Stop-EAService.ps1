# Stop-EAService.ps1
$serviceName = "EABackgroundService"

if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    if ((Get-Service -Name $serviceName).Status -eq 'Running') {
        Stop-Service -Name $serviceName -Force
        Write-Output "Service '$serviceName' stopped."
    } else {
        Write-Output "Service '$serviceName' is not running."
    }
} else {
    Write-Output "Service '$serviceName' not found."
}
