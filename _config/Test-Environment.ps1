# Test-Environment.ps1
# Quick smoke tests for The Funky Black Box environment

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Verbose
)

$ErrorActionPreference = 'Stop'
$VerbosePreference = $(if ($Verbose) { 'Continue' } else { 'SilentlyContinue' })

# Import configuration module
Import-Module "$PSScriptRoot/ConfigurationModule.psm1" -Force

function Test-ModuleImport {
    try {
        Write-Verbose "Testing module import..."
        Initialize-FunkyConfig
        $config = Get-FunkyConfig
        if ($config.Paths -and $config.Security) {
            Write-Host "✅ Module import successful" -ForegroundColor Green
            return $true
        }
        Write-Host "❌ Module import failed - invalid configuration" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "❌ Module import failed: $_" -ForegroundColor Red
        return $false
    }
}

function Test-Paths {
    try {
        Write-Verbose "Testing paths..."
        $config = Get-FunkyConfig
        $failures = @()

        foreach ($pathProp in $config.Paths.PSObject.Properties) {
            $path = $pathProp.Value
            if (-not (Test-Path $path)) {
                $failures += "Path not found: $path"
            }
        }

        if ($failures.Count -eq 0) {
            Write-Host "✅ All paths valid" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ Path validation failed:" -ForegroundColor Red
            $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            return $false
        }
    }
    catch {
        Write-Host "❌ Path testing failed: $_" -ForegroundColor Red
        return $false
    }
}

function Test-SecuritySettings {
    try {
        Write-Verbose "Testing security settings..."
        $config = Get-FunkyConfig
        $failures = @()

        # Check environment variables
        foreach ($envVar in $config.Security.RequiredEnvVars) {
            if (-not [Environment]::GetEnvironmentVariable($envVar)) {
                $failures += "Missing environment variable: $envVar"
            }
        }

        # Check allowed project types
        if ($config.Security.AllowedProjectTypes.Count -eq 0) {
            $failures += "No allowed project types defined"
        }

        # Check backup settings
        if ($config.Security.BackupRetentionDays -lt 1) {
            $failures += "Invalid backup retention days"
        }

        if ($failures.Count -eq 0) {
            Write-Host "✅ Security settings valid" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ Security validation failed:" -ForegroundColor Red
            $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            return $false
        }
    }
    catch {
        Write-Host "❌ Security testing failed: $_" -ForegroundColor Red
        return $false
    }
}

function Test-Scripts {
    try {
        Write-Verbose "Testing script access..."
        $config = Get-FunkyConfig
        $scriptPath = $config.Paths.Scripts
        $requiredScripts = @(
            'new-project.ps1',
            'update-status.ps1',
            'backup-all.ps1'
        )

        $failures = @()
        foreach ($script in $requiredScripts) {
            $path = Join-Path $scriptPath $script
            if (-not (Test-Path $path)) {
                $failures += "Required script not found: $script"
            }
        }

        if ($failures.Count -eq 0) {
            Write-Host "✅ All required scripts present" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ Script validation failed:" -ForegroundColor Red
            $failures | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
            return $false
        }
    }
    catch {
        Write-Host "❌ Script testing failed: $_" -ForegroundColor Red
        return $false
    }
}

# Run all tests
Write-Host "🔍 Running smoke tests..." -ForegroundColor Cyan
$results = @(
    (Test-ModuleImport),
    (Test-Paths),
    (Test-SecuritySettings),
    (Test-Scripts)
)

# Summary
$passCount = ($results | Where-Object { $_ -eq $true }).Count
$totalCount = $results.Count

Write-Host "`n📊 Test Summary" -ForegroundColor Cyan
Write-Host "Passed: $passCount/$totalCount" -ForegroundColor $(if ($passCount -eq $totalCount) { 'Green' } else { 'Red' })

# Exit with status
exit $(if ($passCount -eq $totalCount) { 0 } else { 1 })
