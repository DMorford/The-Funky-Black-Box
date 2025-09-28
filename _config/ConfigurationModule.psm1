# ConfigurationModule.psm1
# Central configuration management for The Funky Black Box framework

$script:CONFIG = $null
$script:ENV_VARS = @{}

function Initialize-FunkyConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot\config.json",
        [Parameter(Mandatory=$false)]
        [string]$EnvPath = "$PSScriptRoot\.env"
    )

    # Load environment variables
    if (Test-Path $EnvPath) {
        Get-Content $EnvPath | ForEach-Object {
            if ($_ -match '^([^=]+)=(.*)$') {
                $script:ENV_VARS[$Matches[1]] = $Matches[2]
                [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2])
            }
        }
    }

    # Ensure DEVPROJECTS_ROOT is set
    if (-not $ENV:DEVPROJECTS_ROOT) {
        throw "DEVPROJECTS_ROOT environment variable is not set!"
    }

    # Load and validate configuration
    if (Test-Path $ConfigPath) {
        $script:CONFIG = Get-Content $ConfigPath | ConvertFrom-Json

        # Resolve environment variables in paths
        $script:CONFIG.workspace.paths.PSObject.Properties | ForEach-Object {
            $_.Value = [Environment]::ExpandEnvironmentVariables($_.Value)
        }
    }
    else {
        throw "Configuration file not found at: $ConfigPath"
    }

    # Validate required environment variables
    foreach ($envVar in $script:CONFIG.security.requiredEnvVars) {
        if (-not [Environment]::GetEnvironmentVariable($envVar)) {
            Write-Warning "Required environment variable not set: $envVar"
        }
    }
}

function Get-FunkyConfig {
    [CmdletBinding()]
    param()
    
    if (-not $script:CONFIG) {
        throw "Configuration not initialized! Call Initialize-FunkyConfig first."
    }
    return $script:CONFIG
}

function Get-FunkyPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('templates', 'scripts', 'config', 'active', 'archived', 'backups', 'sandbox')]
        [string]$PathType
    )

    if (-not $script:CONFIG) {
        throw "Configuration not initialized! Call Initialize-FunkyConfig first."
    }

    $path = $script:CONFIG.workspace.paths.$PathType
    if (-not $path) {
        throw "Path type '$PathType' not found in configuration"
    }

    # Sanitize and validate path
    $path = [System.IO.Path]::GetFullPath($path)
    if (-not (Test-Path $path -IsValid)) {
        throw "Invalid path: $path"
    }

    return $path
}

function Test-FunkyEnvironment {
    [CmdletBinding()]
    param()

    $issues = @()

    # Check required environment variables
    foreach ($envVar in $script:CONFIG.security.requiredEnvVars) {
        if (-not [Environment]::GetEnvironmentVariable($envVar)) {
            $issues += "Missing environment variable: $envVar"
        }
    }

    # Check required directories exist
    foreach ($pathType in $script:CONFIG.workspace.paths.PSObject.Properties.Name) {
        $path = $script:CONFIG.workspace.paths.$pathType
        if (-not (Test-Path $path)) {
            $issues += "Missing directory: $path"
        }
    }

    # Check required files
    foreach ($file in $script:CONFIG.git.requiredFiles) {
        $filePath = Join-Path $ENV:DEVPROJECTS_ROOT $file
        if (-not (Test-Path $filePath)) {
            $issues += "Missing required file: $file"
        }
    }

    return $issues
}

# Export functions
Export-ModuleMember -Function Initialize-FunkyConfig, Get-FunkyConfig, Get-FunkyPath, Test-FunkyEnvironment
