# Test-GitHooks.ps1
# Validates Git hooks setup and functionality

[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Verify
)

$ErrorActionPreference = "Stop"

# Import configuration
Import-Module "$PSScriptRoot/ConfigurationModule.psm1" -Force
Initialize-FunkyConfig
$config = Get-FunkyConfig

function Install-GitHooks {
    Write-Host "🔧 Installing Git hooks..." -ForegroundColor Cyan
    
    try {
        $hooksPath = Join-Path $config.Paths.Root ".git" "hooks"
        $templatePath = Join-Path $config.Paths.Root ".github" "hooks"
        
        # Create hooks directory if it doesn't exist
        if (-not (Test-Path $hooksPath)) {
            New-Item -ItemType Directory -Path $hooksPath -Force | Out-Null
        }
        
        # Install pre-commit hook
        $preCommitTarget = Join-Path $hooksPath "pre-commit"
        $preCommitSource = Join-Path $templatePath "pre-commit"
        
        Copy-Item -Path $preCommitSource -Destination $preCommitTarget -Force
        
        # Make hook executable
        if ($IsLinux -or $IsMacOS) {
            chmod +x $preCommitTarget
        }
        
        Write-Host "✅ Git hooks installed successfully" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Failed to install Git hooks: $_" -ForegroundColor Red
        return $false
    }
}

function Test-HookExecution {
    Write-Host "🧪 Testing Git hooks..." -ForegroundColor Cyan
    
    try {
        # Create test file with hardcoded path
        $testFile = Join-Path $config.Paths.Root "test_hook.txt"
        Set-Content -Path $testFile -Value "C:\hardcoded\path" -Force
        
        # Try to commit (should fail)
        $failed = $false
        try {
            git add $testFile
            git commit -m "test commit"
            $failed = $true
        }
        catch {
            # Expected to fail
        }
        
        if ($failed) {
            throw "Pre-commit hook should have prevented commit with hardcoded path"
        }
        
        # Cleanup
        Remove-Item $testFile -Force
        git reset --hard HEAD
        
        Write-Host "✅ Git hooks test passed" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Git hooks test failed: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution
if ($Install) {
    Install-GitHooks
}

if ($Verify) {
    Test-HookExecution
}
