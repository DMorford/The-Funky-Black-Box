# Validate-Configuration.ps1
# Validates the entire Funky Black Box configuration setup

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$ConfigRoot = "$PSScriptRoot"
)

# Import configuration module
Import-Module "$ConfigRoot\ConfigurationModule.psm1" -Force

function Test-PathSecurity {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    # Check for valid characters and potential directory traversal
    $invalidChars = [IO.Path]::GetInvalidPathChars()
    if ($Path -match "[$invalidChars]" -or $Path -match "\.\." -or $Path -match "^[/\\]") {
        return $false
    }
    return $true
}

function Test-ConfigurationFiles {
    $issues = @()

    # Check main configuration
    if (-not (Test-Path "$ConfigRoot\config.json")) {
        $issues += "Missing main configuration file: config.json"
    }

    # Check environment templates
    $envTemplates = @(
        '.env.example'
        '.env.python.example'
        '.env.javascript.example'
    )

    foreach ($template in $envTemplates) {
        if (-not (Test-Path "$ConfigRoot\$template")) {
            $issues += "Missing environment template: $template"
        }
    }

    return $issues
}

function Test-ConfigurationContent {
    try {
        # Initialize configuration
        Initialize-FunkyConfig

        # Get configuration
        $config = Get-FunkyConfig

        $issues = @()

        # Check workspace paths
        foreach ($pathType in $config.workspace.paths.PSObject.Properties) {
            if (-not (Test-PathSecurity $pathType.Value)) {
                $issues += "Invalid path in configuration: $($pathType.Name) = $($pathType.Value)"
            }
        }

        # Check security settings
        if (-not $config.security.requiredEnvVars -or $config.security.requiredEnvVars.Count -eq 0) {
            $issues += "No required environment variables specified in security configuration"
        }

        if (-not $config.security.allowedProjectTypes -or $config.security.allowedProjectTypes.Count -eq 0) {
            $issues += "No allowed project types specified in security configuration"
        }

        # Check Git configuration
        if (-not $config.git.defaultBranch) {
            $issues += "Default Git branch not specified"
        }

        if (-not $config.git.requiredFiles -or $config.git.requiredFiles.Count -eq 0) {
            $issues += "No required Git files specified"
        }

        return $issues
    }
    catch {
        return @("Configuration validation failed: $_")
    }
}

# Run all validation checks
Write-Host "🔍 Validating Funky Black Box configuration..." -ForegroundColor Cyan

$allIssues = @()
$allIssues += Test-ConfigurationFiles
$allIssues += Test-ConfigurationContent

if ($allIssues.Count -eq 0) {
    Write-Host "✅ Configuration validation successful!" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "❌ Configuration validation failed!" -ForegroundColor Red
    Write-Host "Found $($allIssues.Count) issue(s):" -ForegroundColor Yellow
    $allIssues | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
    exit 1
}
