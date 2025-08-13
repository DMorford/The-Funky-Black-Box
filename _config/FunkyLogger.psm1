# FunkyLogger.psm1
# Logging module for The Funky Black Box framework

$script:LogFile = $null
$script:LogLevel = "Info"

function Initialize-FunkyLogger {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$LogPath,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$LogLevel = "Info"
    )
    
    # Import configuration if not explicitly provided
    if (-not $LogPath) {
        Import-Module "$PSScriptRoot/ConfigurationModule.psm1" -Force
        $config = Get-FunkyConfig
        $LogPath = Join-Path $config.Paths.Root "logs" "funkybox.log"
    }
    
    # Create logs directory if it doesn't exist
    $logsDir = Split-Path $LogPath -Parent
    if (-not (Test-Path $logsDir)) {
        New-Item -ItemType Directory -Path $logsDir -Force | Out-Null
    }
    
    $script:LogFile = $LogPath
    $script:LogLevel = $LogLevel
}

function Write-FunkyLog {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Debug", "Info", "Warning", "Error")]
        [string]$Level = "Info",
        
        [Parameter(Mandatory=$false)]
        [string]$Component = "General"
    )
    
    if (-not $script:LogFile) {
        Initialize-FunkyLogger
    }
    
    # Check if we should log this level
    $levels = @{
        "Debug" = 0
        "Info" = 1
        "Warning" = 2
        "Error" = 3
    }
    
    if ($levels[$Level] -lt $levels[$script:LogLevel]) {
        return
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [$Component] $Message"
    
    # Write to log file
    Add-Content -Path $script:LogFile -Value $logEntry
    
    # Also write to console with appropriate color
    $color = switch ($Level) {
        "Debug" { "Gray" }
        "Info" { "White" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }
    
    Write-Host $logEntry -ForegroundColor $color
}

function Get-FunkyLogs {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [int]$Last = 50,
        
        [Parameter(Mandatory=$false)]
        [string]$Level,
        
        [Parameter(Mandatory=$false)]
        [string]$Component,
        
        [Parameter(Mandatory=$false)]
        [datetime]$Since
    )
    
    if (-not $script:LogFile) {
        Initialize-FunkyLogger
    }
    
    $logs = Get-Content $script:LogFile
    
    # Filter by level
    if ($Level) {
        $logs = $logs | Where-Object { $_ -match "\[$Level\]" }
    }
    
    # Filter by component
    if ($Component) {
        $logs = $logs | Where-Object { $_ -match "\[$Component\]" }
    }
    
    # Filter by date
    if ($Since) {
        $logs = $logs | Where-Object {
            if ($_ -match "\[(.*?)\]") {
                $logDate = [datetime]::ParseExact($Matches[1], "yyyy-MM-dd HH:mm:ss", $null)
                $logDate -ge $Since
            }
        }
    }
    
    # Return last N entries
    return $logs | Select-Object -Last $Last
}

# Export functions
Export-ModuleMember -Function Initialize-FunkyLogger, Write-FunkyLog, Get-FunkyLogs
