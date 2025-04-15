# Stop Dependent Services

A PowerShell utility to stop services and applications that might interfere with safely removing external drives.

## Overview

When working with external drives, certain background services and applications can keep files locked, preventing safe removal. This script automatically identifies and stops these processes to ensure data integrity when disconnecting external drives.

## Features

- Stops specified Windows services that may be using external drives
- Terminates applications that might be locking files on external drives
- Includes robust retry logic to ensure services and processes are truly stopped
- Provides detailed status reporting with success/failure indicators
- Creates timestamped logs for troubleshooting and auditing

## Usage

### Basic Usage

```powershell
.\StopDependentServices.ps1
```
This will stop all default gaming-related services and applications that commonly interfere with external drive removal.

### Custom Services and Processes

```powershell
.\StopDependentServices.ps1 -Services "EABackgroundService","Steam Client Service" -ProcessNames "Origin","Steam"
```
Use this to specify only particular services or applications to stop.

### Custom Log Location

```powershell
.\StopDependentServices.ps1 -LogFolder "C:\CustomLogs"
```
You can specify where log files should be stored.

### Disable Logging

```powershell
.\StopDependentServices.ps1 -NoLog
```

### Default Targets
The script by default targets these services:

- EABackgroundService
- EpicGamesLauncher
- EpicOnlineServices
- Steam Client Service
- Battle.net Update Agent

And these applications:

- EADesktop / Origin
- Epic Games Launcher
- Steam
- Battle.net


## Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| Services | Array of service names to stop | Common gaming services |
| ProcessNames | Array of process names to stop | Common gaming applications |
| MaxAttempts | Maximum attempts to stop each service/process | 5 |
| WaitTimeSeconds | Seconds to wait between attempts | 2 |
| LogFolder | Path where logs will be stored | ./Logs |
| NoLog | Switch to disable logging | False |

## Notes

- The script requires administrator privileges to stop many system services
- Some services may restart automatically due to dependencies or system policies
- Services marked as "Not Found" may be named differently on your system

## Related Scripts

- [StopEAService](../StopEAService/README.md) - For stopping only EA-related services
- [SafeUndock](../SafeUndock/README.md) - For safely undoc