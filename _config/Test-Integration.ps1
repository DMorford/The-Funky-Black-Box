# Test-Integration.ps1
# Integration tests for The Funky Black Box framework

[CmdletBinding()]
param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$VerbosePreference = $(if ($Verbose) { 'Continue' } else { 'SilentlyContinue' })

# Import configuration
Import-Module "$PSScriptRoot/ConfigurationModule.psm1" -Force

function Test-ProjectCreationAndBackup {
    Write-Host "🧪 Testing project creation and backup workflow..." -ForegroundColor Cyan
    
    try {
        # 1. Create test project
        $testProjectName = "test_integration_$(Get-Date -Format 'yyyyMMddHHmmss')"
        & "$PSScriptRoot/../_scripts/new-project.ps1" -Name $testProjectName -Type "python" -Description "Integration test project"
        
        if (-not $?) { throw "Project creation failed" }
        
        # 2. Update project status
        & "$PSScriptRoot/../_scripts/update-status.ps1" -ProjectName $testProjectName -Status "active" -Note "Integration testing"
        
        if (-not $?) { throw "Status update failed" }
        
        # 3. Create backup
        & "$PSScriptRoot/../_scripts/backup-all.ps1" -CompressOnly
        
        if (-not $?) { throw "Backup failed" }
        
        Write-Host "✅ Integration test passed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Integration test failed: $_" -ForegroundColor Red
        return $false
    }
    finally {
        # Cleanup
        $testProjectPath = Join-Path (Get-FunkyConfig).Paths.Active $testProjectName
        if (Test-Path $testProjectPath) {
            Remove-Item -Path $testProjectPath -Recurse -Force
        }
    }
}

function Test-SecurityValidations {
    Write-Host "🧪 Testing security validations..." -ForegroundColor Cyan
    
    try {
        # 1. Test environment variables
        $originalRoot = $env:DEVPROJECTS_ROOT
        Remove-Item env:DEVPROJECTS_ROOT -ErrorAction SilentlyContinue
        
        $failed = $false
        try {
            Initialize-FunkyConfig
            $failed = $true
        }
        catch {
            # Expected to fail
        }
        
        if ($failed) {
            throw "Security validation should have failed without DEVPROJECTS_ROOT"
        }
        
        # Restore environment
        $env:DEVPROJECTS_ROOT = $originalRoot
        
        # 2. Test path traversal protection
        $config = Get-FunkyConfig
        $result = Test-PathSecurity "../../dangerous/path"
        if ($result) {
            throw "Path traversal validation should have failed"
        }
        
        Write-Host "✅ Security validation tests passed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Security validation tests failed: $_" -ForegroundColor Red
        return $false
    }
}

function Test-ConfigurationSystem {
    Write-Host "🧪 Testing configuration system..." -ForegroundColor Cyan
    
    try {
        # 1. Test configuration loading
        $config = Get-FunkyConfig
        
        # 2. Verify typed properties
        if (-not ($config.Paths -is [FunkyPaths])) {
            throw "Paths not properly typed"
        }
        
        if (-not ($config.Security -is [FunkySecurity])) {
            throw "Security not properly typed"
        }
        
        # 3. Test path resolution
        $templatesPath = $config.Paths.Templates
        if (-not (Test-Path $templatesPath)) {
            throw "Templates path not properly resolved: $templatesPath"
        }
        
        Write-Host "✅ Configuration system tests passed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Configuration system tests failed: $_" -ForegroundColor Red
        return $false
    }
}

# Run all integration tests
$results = @(
    (Test-ProjectCreationAndBackup),
    (Test-SecurityValidations),
    (Test-ConfigurationSystem)
)

# Summary
$passCount = ($results | Where-Object { $_ -eq $true }).Count
$totalCount = $results.Count

Write-Host "`n📊 Integration Test Summary" -ForegroundColor Cyan
Write-Host "Passed: $passCount/$totalCount" -ForegroundColor $(if ($passCount -eq $totalCount) { 'Green' } else { 'Red' })

exit $(if ($passCount -eq $totalCount) { 0 } else { 1 })
