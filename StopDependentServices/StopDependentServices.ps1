<#
.SYNOPSIS
    Stops services and applications that might interfere with safely removing external drives.
.DESCRIPTION
    This script attempts to stop multiple services and applications that could potentially block
    the safe removal of external drives. It includes retry logic, status reporting, and logging.
    
    IMPORTANT: Processes are stopped BEFORE services, as many services depend on their
    parent applications and may fail to stop if the application is still running.
.PARAMETER Services
    Array of service names to stop. Defaults include game services that may use external drives.
.PARAMETER ProcessNames
    Array of process names to stop. Defaults include game applications.
.PARAMETER MaxAttempts
    Maximum number of attempts to stop each service or process. Default is 5.
.PARAMETER WaitTimeSeconds
    Time to wait between stop attempts in seconds. Default is 2.
.PARAMETER LogFolder
    Path to the folder where logs will be stored. Default is 'Logs' subfolder.
.PARAMETER NoLog
    If specified, disables logging to file.
.EXAMPLE
    .\StopDependentServices.ps1
    Stops default services and applications that might interfere with drive removal.
.EXAMPLE
    .\StopDependentServices.ps1 -Services "EABackgroundService" -ProcessNames "Origin"
    Stops only the specified service and process.
.EXAMPLE
    .\StopDependentServices.ps1 -LogFolder "C:\CustomLogs"
    Uses a custom folder for log files.
.EXAMPLE
    .\StopDependentServices.ps1 -NoLog
    Runs without creating log files.
#>

param(
    [string[]]$Services = @(
        "EABackgroundService", 
        "EpicGamesLauncher", 
        "EpicOnlineServices", 
        "Steam Client Service", 
        "Battle.net Update Agent"
    ),
    [string[]]$ProcessNames = @(
        "EADesktop",
        "Origin",
        "EpicGamesLauncher", 
        "Steam", 
        "Battle.net"
    ),
    [int]$MaxAttempts = 5,
    [int]$WaitTimeSeconds = 2,
    [string]$LogFolder = (Join-Path -Path $PSScriptRoot -ChildPath "Logs"),
    [switch]$NoLog
)

# Set up logging
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logFile = $null

if (-not $NoLog) {
    # Create logs directory if it doesn't exist
    if (-not (Test-Path -Path $LogFolder)) {
        New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
        Write-Output "Created log directory: $LogFolder"
    }
    
    $logFile = Join-Path -Path $LogFolder -ChildPath "StopDependentServices_$timestamp.log"
    # Start the log file with a header
    "==== StopDependentServices Log ($timestamp) ====" | Out-File -FilePath $logFile
    "Processes to stop: $($ProcessNames -join ', ')" | Out-File -FilePath $logFile -Append
    "Services to stop: $($Services -join ', ')" | Out-File -FilePath $logFile -Append
    "--------------------------------------------------" | Out-File -FilePath $logFile -Append
}

# Function to write to console and log file
function Write-Log {
    param([string]$Message)
    
    Write-Output $Message
    if (-not $NoLog -and $null -ne $logFile) {
        $Message | Out-File -FilePath $logFile -Append
    }
}

# Track results for reporting
$serviceResults = @()
$processResults = @()

# Function to wait for process termination with retry
function Wait-ForProcessTermination {
    param(
        [string]$ProcessName,
        [int]$MaxAttempts,
        [int]$WaitTimeSeconds
    )
    
    $attempts = 0
    
    do {
        Start-Sleep -Seconds $WaitTimeSeconds
        $processStillRunning = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
        $attempts++
        
        if (-not $processStillRunning) {
            Write-Log "Process '$ProcessName' successfully terminated."
            return $true
        } else {
            Write-Log "Process '$ProcessName' is still running. Attempt $attempts of $MaxAttempts..."
        }
    } while ($attempts -lt $MaxAttempts -and $processStillRunning)
    
    if ($processStillRunning) {
        Write-Log "Failed to terminate process '$ProcessName' after $MaxAttempts attempts."
        return $false
    }
    
    return $true
}

# PART 1: Stop Processes FIRST
Write-Log "`n===== STOPPING APPLICATIONS (FIRST) =====`n"

foreach ($processName in $ProcessNames) {
    $processResult = [PSCustomObject]@{
        ProcessName = $processName
        InitialState = "Unknown"
        FinalState = "Unknown"
        Success = $false
        Message = ""
    }
    
    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue
    
    if ($processes) {
        $processCount = $processes.Count
        $processResult.InitialState = "Running ($processCount instances)"
        
        Write-Log "Attempting to stop process '$processName' ($processCount instances found)..."
        try {
            $processes | Stop-Process -Force -ErrorAction Stop
            
            # Wait and check if the process has actually stopped
            $success = Wait-ForProcessTermination -ProcessName $processName -MaxAttempts $MaxAttempts -WaitTimeSeconds $WaitTimeSeconds
            
            if ($success) {
                $processResult.FinalState = "Terminated"
                $processResult.Success = $true
                $processResult.Message = "Successfully terminated all instances."
            } else {
                $processResult.FinalState = "Still Running"
                $processResult.Message = "Failed to terminate after $MaxAttempts attempts."
            }
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-Log "Error stopping process '$processName': $errorMsg"
            
            # Check if it's still running despite the error
            $stillRunning = Get-Process -Name $processName -ErrorAction SilentlyContinue
            if ($stillRunning) {
                $processResult.FinalState = "Still Running"
                $processResult.Message = "Error: $errorMsg"
            } else {
                $processResult.FinalState = "Terminated"
                $processResult.Success = $true
                $processResult.Message = "Terminated despite error: $errorMsg"
            }
        }
    } else {
        Write-Log "Process '$processName' is not running."
        $processResult.InitialState = "Not Running"
        $processResult.FinalState = "Not Running"
        $processResult.Success = $true
        $processResult.Message = "Process was not running."
    }
    
    $processResults += $processResult
}

# Add a slight delay before attempting to stop services
# This gives any process shutdown operations time to complete
Write-Log "`nWaiting 2 seconds for processes to fully terminate before stopping services..."
Start-Sleep -Seconds 2

# PART 2: Stop Services AFTER processes
Write-Log "`n===== STOPPING SERVICES (AFTER APPLICATIONS) =====`n"

foreach ($serviceName in $Services) {
    $serviceResult = [PSCustomObject]@{
        ServiceName = $serviceName
        InitialStatus = "Unknown"
        FinalStatus = "Unknown"
        Success = $false
        Message = ""
    }
    
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        $serviceStatus = (Get-Service -Name $serviceName).Status
        $serviceResult.InitialStatus = $serviceStatus
        
        if ($serviceStatus -eq 'Running') {
            Write-Log "Attempting to stop service '$serviceName'..."
            try {
                Stop-Service -Name $serviceName -Force -ErrorAction Stop
                
                # Wait and check if the service has actually stopped
                $attempts = 0
                
                do {
                    Start-Sleep -Seconds $WaitTimeSeconds
                    $serviceStatus = (Get-Service -Name $serviceName).Status
                    $attempts++
                    
                    if ($serviceStatus -eq 'Stopped') {
                        Write-Log "Service '$serviceName' successfully stopped."
                        $serviceResult.FinalStatus = "Stopped"
                        $serviceResult.Success = $true
                        $serviceResult.Message = "Successfully stopped after $attempts attempt(s)."
                        break
                    } else {
                        Write-Log "Service '$serviceName' is still in '$serviceStatus' state. Attempt $attempts of $MaxAttempts..."
                    }
                } while ($attempts -lt $MaxAttempts -and $serviceStatus -ne 'Stopped')
                
                if ($serviceStatus -ne 'Stopped') {
                    Write-Log "Failed to stop service '$serviceName' after $MaxAttempts attempts."
                    $serviceResult.FinalStatus = $serviceStatus
                    $serviceResult.Message = "Failed to stop after $MaxAttempts attempts."
                }
            }
            catch {
                $errorMsg = $_.Exception.Message
                Write-Log "Error stopping service '$serviceName': $errorMsg"
                $serviceResult.FinalStatus = (Get-Service -Name $serviceName).Status
                $serviceResult.Message = "Error: $errorMsg"
            }
        } else {
            Write-Log "Service '$serviceName' is already $serviceStatus."
            $serviceResult.FinalStatus = $serviceStatus
            $serviceResult.Success = $true
            $serviceResult.Message = "Service was already $serviceStatus."
        }
    } else {
        Write-Log "Service '$serviceName' not found."
        $serviceResult.InitialStatus = "Not Found"
        $serviceResult.FinalStatus = "Not Found"
        $serviceResult.Message = "Service does not exist."
    }
    
    $serviceResults += $serviceResult
}

# Generate summary tables
$processTable = $processResults | Format-Table -Property ProcessName, InitialState, FinalState, Success, Message -AutoSize | Out-String
$serviceTable = $serviceResults | Format-Table -Property ServiceName, InitialStatus, FinalStatus, Success, Message -AutoSize | Out-String

# Display summary tables - processes first, then services (matching execution order)
Write-Log "`nApplication Stop Summary:"
Write-Log "-----------------------"
Write-Log $processTable

Write-Log "`nService Stop Summary:"
Write-Log "--------------------"
Write-Log $serviceTable

# Add log file path to output if logging is enabled
if (-not $NoLog -and $null -ne $logFile) {
    Write-Output "`nLog file created: $logFile"
}

# Return combined results object for potential further processing
return @{
    Processes = $processResults
    Services = $serviceResults
    AllSuccessful = ($serviceResults | Where-Object { -not $_.Success }).Count -eq 0 -and 
                   ($processResults | Where-Object { -not $_.Success }).Count -eq 0
    LogFile = if (-not $NoLog) { $logFile } else { $null }
}