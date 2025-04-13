# filepath: c:\GitHub\haakonwibe\windows-scripts\StopEAService\Stop-EAService.Tests.ps1

BeforeAll {
    # Import the script to test
    . $PSScriptRoot\Stop-EAService.ps1
}

Describe "Stop-EAService" {
    BeforeAll {
        # Mock functions to avoid actual service interactions
        Mock Get-Service { 
            [PSCustomObject]@{ 
                Name = "EABackgroundService"
                Status = "Running" 
            }
        } -ParameterFilter { $Name -eq "EABackgroundService" }
        
        Mock Stop-Service {}
        Mock Start-Sleep {}
        Mock Write-Output {}
    }

    Context "When service exists and is running" {
        BeforeEach {
            # Mock Get-Service to return a running service first, then a stopped service on subsequent calls
            $script:callCount = 0
            Mock Get-Service {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    # First call - service exists
                    return [PSCustomObject]@{ 
                        Name = "EABackgroundService"
                        Status = "Running" 
                    }
                } else if ($script:callCount -eq 2) {
                    # Second call - service is running
                    return [PSCustomObject]@{ 
                        Name = "EABackgroundService"
                        Status = "Running" 
                    }
                } else {
                    # Subsequent calls - service is stopped
                    return [PSCustomObject]@{ 
                        Name = "EABackgroundService"
                        Status = "Stopped" 
                    }
                }
            } -ParameterFilter { $Name -eq "EABackgroundService" }
        }

        It "Should attempt to stop the service" {
            # Re-dot source to execute the script
            . $PSScriptRoot\Stop-EAService.ps1
            
            Should -Invoke Stop-Service -ParameterFilter { $Name -eq "EABackgroundService" -and $Force -eq $true } -Times 1
            Should -Invoke Write-Output -ParameterFilter { $Object -eq "Attempting to stop service 'EABackgroundService'..." } -Times 1
            Should -Invoke Write-Output -ParameterFilter { $Object -eq "Service 'EABackgroundService' successfully stopped." } -Times 1
        }
    }

    Context "When service exists but is not running" {
        BeforeEach {
            Mock Get-Service {
                return [PSCustomObject]@{ 
                    Name = "EABackgroundService"
                    Status = "Stopped" 
                }
            } -ParameterFilter { $Name -eq "EABackgroundService" }
        }

        It "Should report that the service is not running" {
            . $PSScriptRoot\Stop-EAService.ps1
            
            Should -Invoke Stop-Service -Times 0
            Should -Invoke Write-Output -ParameterFilter { $Object -eq "Service 'EABackgroundService' is not running." } -Times 1
        }
    }

    Context "When service does not exist" {
        BeforeEach {
            Mock Get-Service { return $null } -ParameterFilter { $Name -eq "EABackgroundService" }
        }

        It "Should report that the service was not found" {
            . $PSScriptRoot\Stop-EAService.ps1
            
            Should -Invoke Stop-Service -Times 0
            Should -Invoke Write-Output -ParameterFilter { $Object -eq "Service 'EABackgroundService' not found." } -Times 1
        }
    }

    Context "When service fails to stop after multiple attempts" {
        BeforeEach {
            $script:callCount = 0
            Mock Get-Service {
                $script:callCount++
                if ($script:callCount -eq 1) {
                    # First call - service exists check
                    return [PSCustomObject]@{ 
                        Name = "EABackgroundService"
                        Status = "Running" 
                    }
                } else {
                    # All subsequent calls - service remains running
                    return [PSCustomObject]@{ 
                        Name = "EABackgroundService"
                        Status = "Running" 
                    }
                }
            } -ParameterFilter { $Name -eq "EABackgroundService" }
        }

        It "Should make the correct number of attempts and report failure" {
            . $PSScriptRoot\Stop-EAService.ps1
            
            Should -Invoke Stop-Service -Times 1
            Should -Invoke Start-Sleep -Times 5
            Should -Invoke Write-Output -ParameterFilter { 
                $Object -like "Service 'EABackgroundService' is still in 'Running' state. Attempt * of 5..." 
            } -Times 5
            Should -Invoke Write-Output -ParameterFilter { 
                $Object -eq "Failed to stop service 'EABackgroundService' after 5 attempts." 
            } -Times 1
        }
    }
}