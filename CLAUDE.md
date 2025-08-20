# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of Windows PowerShell automation utilities for safe device removal, service management, and iCloud photo synchronization. Each tool is self-contained in its own directory with PowerShell scripts, batch file launchers, and scheduled task creators.

## Architecture

### Tool Structure Pattern
Each utility follows a consistent pattern:
- **Main script** (.ps1): Core PowerShell logic
- **Task creator** (Create-*.ps1): Registers Windows scheduled tasks for UAC-free execution
- **Batch launcher** (.bat): Desktop shortcut that triggers the scheduled task
- **README.md**: Tool-specific documentation

### Key Dependencies
- **External Tools Required**:
  - `C:\Tools\SysinternalsSuite\Sync64.exe` (for SafeUndock)
  - `C:\Tools\RemoveDrive\RemoveDrive.exe` (for SafeUndock)
  - `icloudpd.exe` (for iCloudDownloader, placed in tool directory)

### Common PowerShell Patterns
- **Service Management**: Robust retry logic with configurable attempts and wait times
- **Status Tracking**: Arrays to collect operation results for final reporting
- **Error Handling**: Silent error handling with `-ErrorAction SilentlyContinue`
- **Parametization**: Switch parameters for optional features (e.g., `-StopServices`, `-NoLog`)

## Tools

### SafeUndock
Safely removes external drives by flushing buffers and ejecting drives. Uses external tools (Sync64.exe, RemoveDrive.exe) to handle write-cached drives that appear as Local Disk (DriveType = 3).

**Key Features**:
- Optional service stopping with `-StopServices` parameter
- Configurable drive letters and services in script variables
- Balloon notifications via RemoveDrive.exe

### StopEAService / StopDependentServices
Service management utilities with shared retry logic pattern. StopDependentServices is the newer, more comprehensive version that handles both services and processes.

**Key Pattern**: Services depend on parent applications, so processes are stopped BEFORE services to avoid dependency failures.

### iCloudDownloader
Wrapper scripts around icloudpd.exe for syncing iCloud Photos and shared albums. Includes placeholders that need customization with actual Apple ID and target directories.

## Testing

Only StopEAService has tests using **Pester** framework:
- Located at: `StopEAService\Stop-EAService.Tests.ps1`
- Tests service existence, running state, stopping behavior, and retry logic
- Uses mocking to avoid actual service interactions

**Run tests**:
```powershell
# Navigate to StopEAService directory
Invoke-Pester .\Stop-EAService.Tests.ps1
```

## Common Development Tasks

### Testing Scripts
- Test PowerShell scripts manually before creating scheduled tasks
- For SafeUndock: Test with and without `-StopServices` parameter
- For StopDependentServices: Test with custom `-Services` and `-ProcessNames` parameters

### Adding New Services/Processes
- Update the default arrays in script parameters
- Update corresponding README documentation
- Follow the existing retry logic pattern for consistency

### Scheduled Task Management
- Run task creation scripts with elevated PowerShell
- Tasks are created under current user context (no SYSTEM account)
- Batch files provide UAC-free shortcuts to scheduled tasks

## File Path Conventions
- External tools: `C:\Tools\[ToolName]\`
- Log files: `.\Logs\` (relative to script location, configurable)
- iCloud binary: Place in same directory as batch files

## Error Handling Patterns
1. Check resource existence with `-ErrorAction SilentlyContinue`
2. Implement retry loops for operations that may take time
3. Collect results in arrays for comprehensive final reporting
4. Provide user feedback via Write-Output for both success and failure cases