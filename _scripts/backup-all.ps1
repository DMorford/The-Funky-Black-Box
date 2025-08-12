# Backup All Projects Script
# Creates timestamped backups of all active projects

param(
    [Parameter()]
    [string]$BackupPath = "C:\Users\morfo\DevProjects\backups",
    
    [Parameter()]
    [switch]$IncludeArchived,
    
    [Parameter()]
    [switch]$CompressOnly
)

$ErrorActionPreference = "Stop"

$BasePath = "C:\Users\morfo\DevProjects"
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BackupFolder = Join-Path $BackupPath "backup_$Timestamp"

Write-Host "DevProjects Backup Utility" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host "Backup timestamp: $Timestamp" -ForegroundColor Yellow

# Create backup directory
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
}

if (-not $CompressOnly) {
    New-Item -ItemType Directory -Path $BackupFolder -Force | Out-Null
}

# Define folders to backup
$FoldersToBackup = @("active", "sandbox")
if ($IncludeArchived) {
    $FoldersToBackup += "archived"
}

$TotalProjects = 0
$BackedUpProjects = 0
$FailedProjects = @()

foreach ($folder in $FoldersToBackup) {
    $folderPath = Join-Path $BasePath $folder
    
    if (-not (Test-Path $folderPath)) {
        Write-Host "Folder '$folder' not found, skipping..." -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`nBacking up $folder projects..." -ForegroundColor Green
    
    $projects = Get-ChildItem -Path $folderPath -Directory
    
    foreach ($project in $projects) {
        $TotalProjects++
        Write-Host "  - Backing up $($project.Name)..." -NoNewline
        
        try {
            if ($CompressOnly) {
                # Create compressed backup directly
                $zipPath = Join-Path $BackupPath "$($project.Name)_$Timestamp.zip"
                Compress-Archive -Path $project.FullName -DestinationPath $zipPath -Force
            }
            else {
                # Copy to backup folder
                $destPath = Join-Path $BackupFolder $folder $project.Name
                
                # Use robocopy for efficient copying (Windows)
                $robocopyArgs = @(
                    $project.FullName,
                    $destPath,
                    "/E",  # Copy subdirectories including empty ones
                    "/XD", "node_modules", ".git", "__pycache__", "venv", "env",  # Exclude directories
                    "/XF", "*.pyc", "*.pyo", "*.log", "*.tmp",  # Exclude file types
                    "/NFL", "/NDL", "/NJH", "/NJS", "/NC", "/NS", "/NP"  # Quiet output
                )
                
                $result = robocopy @robocopyArgs
                
                if ($LASTEXITCODE -ge 8) {
                    throw "Robocopy failed with exit code $LASTEXITCODE"
                }
            }
            
            $BackedUpProjects++
            Write-Host " Done!" -ForegroundColor Green
        }
        catch {
            $FailedProjects += $project.Name
            Write-Host " Failed!" -ForegroundColor Red
            Write-Host "    Error: $_" -ForegroundColor Red
        }
    }
}

# Create a summary file
$summaryPath = if ($CompressOnly) {
    Join-Path $BackupPath "backup_summary_$Timestamp.txt"
} else {
    Join-Path $BackupFolder "BACKUP_SUMMARY.txt"
}

$summary = @"
DevProjects Backup Summary
==========================
Timestamp: $Timestamp
Total Projects: $TotalProjects
Successfully Backed Up: $BackedUpProjects
Failed: $($FailedProjects.Count)

Backup Configuration:
- Include Archived: $IncludeArchived
- Compress Only: $CompressOnly
- Backup Location: $(if ($CompressOnly) { $BackupPath } else { $BackupFolder })

Projects Backed Up:
-------------------
"@

# Add project list to summary
foreach ($folder in $FoldersToBackup) {
    $folderPath = Join-Path $BasePath $folder
    if (Test-Path $folderPath) {
        $projects = Get-ChildItem -Path $folderPath -Directory
        $summary += "`n$($folder.ToUpper()):`n"
        foreach ($project in $projects) {
            $status = if ($FailedProjects -contains $project.Name) { "[FAILED]" } else { "[OK]" }
            $summary += "  - $($project.Name) $status`n"
        }
    }
}

if ($FailedProjects.Count -gt 0) {
    $summary += "`nFailed Projects:`n"
    foreach ($failed in $FailedProjects) {
        $summary += "  - $failed`n"
    }
}

$summary += "`n`nBackup completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

Set-Content -Path $summaryPath -Value $summary

# Optionally compress the entire backup
if (-not $CompressOnly -and $BackedUpProjects -gt 0) {
    Write-Host "`nCompressing backup..." -ForegroundColor Yellow
    $zipPath = Join-Path $BackupPath "DevProjects_Backup_$Timestamp.zip"
    
    try {
        Compress-Archive -Path $BackupFolder -DestinationPath $zipPath -Force
        Write-Host "Compressed backup created: $zipPath" -ForegroundColor Green
        
        # Ask if user wants to delete uncompressed backup
        $delete = Read-Host "Delete uncompressed backup folder? (y/n)"
        if ($delete -eq 'y') {
            Remove-Item -Path $BackupFolder -Recurse -Force
            Write-Host "Uncompressed backup deleted." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Failed to create compressed backup: $_" -ForegroundColor Red
    }
}

# Display summary
Write-Host "`n================================" -ForegroundColor Cyan
Write-Host "Backup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host "Total Projects: $TotalProjects" -ForegroundColor White
Write-Host "Successfully Backed Up: $BackedUpProjects" -ForegroundColor Green
if ($FailedProjects.Count -gt 0) {
    Write-Host "Failed: $($FailedProjects.Count)" -ForegroundColor Red
}
Write-Host "Backup Location: $(if ($CompressOnly) { $BackupPath } else { $BackupFolder })" -ForegroundColor Yellow
Write-Host "Summary saved to: $summaryPath" -ForegroundColor Yellow

# Clean up old backups (keep last 5)
Write-Host "`nCleaning up old backups..." -ForegroundColor Yellow
$backups = Get-ChildItem -Path $BackupPath -Filter "*.zip" | Sort-Object CreationTime -Descending
if ($backups.Count -gt 5) {
    $toDelete = $backups | Select-Object -Skip 5
    foreach ($oldBackup in $toDelete) {
        Remove-Item $oldBackup.FullName -Force
        Write-Host "  Deleted old backup: $($oldBackup.Name)" -ForegroundColor Yellow
    }
}

Write-Host "`nBackup process completed!" -ForegroundColor Green