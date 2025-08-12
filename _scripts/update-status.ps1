# Project Status Update Script
# Updates the PROJECT_STATUS.md dashboard

param(
    [Parameter()]
    [string]$ProjectName,
    
    [Parameter()]
    [ValidateSet("planning", "active", "maintenance", "production", "archived")]
    [string]$Status,
    
    [Parameter()]
    [string]$Note
)

$ErrorActionPreference = "Stop"

$BasePath = "C:\Users\morfo\DevProjects"
$StatusFile = Join-Path $BasePath "PROJECT_STATUS.md"

function Show-ProjectStatus {
    Write-Host "`nCurrent Project Status:" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    $content = Get-Content $StatusFile -Raw
    
    # Extract and display active projects
    if ($content -match "## 🚀 Active Development(.*?)##") {
        $activeSection = $Matches[1]
        $lines = $activeSection -split "`n"
        foreach ($line in $lines) {
            if ($line -match "\| \*\*(.*?)\*\*") {
                $project = $Matches[1]
                if ($line -match "🟢") { $status = "Production" }
                elseif ($line -match "🔴") { $status = "Active" }
                elseif ($line -match "🟡") { $status = "Maintenance" }
                else { $status = "Unknown" }
                
                Write-Host "  - $project [$status]" -ForegroundColor Yellow
            }
        }
    }
}

function Update-ProjectStatus {
    param(
        [string]$Project,
        [string]$NewStatus,
        [string]$UpdateNote
    )
    
    $content = Get-Content $StatusFile -Raw
    $today = Get-Date -Format "yyyy-MM-dd"
    
    # Update the status emoji based on new status
    $statusEmoji = switch ($NewStatus) {
        "production" { "🟢 Production" }
        "active" { "🔴 Active" }
        "maintenance" { "🟡 Maintenance" }
        "planning" { "📝 Planning" }
        "archived" { "⚫ Archived" }
    }
    
    # Find and update the project line
    $pattern = "(\| \*\*$Project\*\* \|).*?(\|.*?\|.*?\|.*?\|.*?\|.*?\|).*?(\|)"
    
    if ($content -match $pattern) {
        Write-Host "Updating $Project to $statusEmoji" -ForegroundColor Green
        
        # Update status and last updated date
        $content = $content -replace "(\| \*\*$Project\*\* \|).*?(\|)", "`$1 $statusEmoji `$2"
        $content = $content -replace "(\| \*\*$Project\*\*.*\|.*\|.*\|.*\|.*\|.*\|.*\|).*?(\|)", "`$1 $today `$2"
        
        if ($UpdateNote) {
            # Update the current sprint/notes field
            $content = $content -replace "(\| \*\*$Project\*\*.*\|.*\|.*\|.*\|.*\|).*?(\|)", "`$1 $UpdateNote `$2"
        }
        
        Set-Content -Path $StatusFile -Value $content
        Write-Host "Status updated successfully!" -ForegroundColor Green
    }
    else {
        Write-Host "Project '$Project' not found in status file!" -ForegroundColor Red
    }
}

function Update-Metrics {
    Write-Host "`nUpdating metrics..." -ForegroundColor Yellow
    
    $content = Get-Content $StatusFile -Raw
    
    # Count git commits in the last week (if in a git repo)
    try {
        $commits = (git log --oneline --since="1 week ago" 2>$null | Measure-Object).Count
        $content = $content -replace "(\| Commits \|).*?(\|)", "`$1 $commits `$2"
    }
    catch {
        # Not in a git repo or git not available
    }
    
    # Update timestamp
    $today = Get-Date -Format "yyyy-MM-dd"
    $content = $content -replace "(> Last Updated:).*?(\|)", "`$1 $today `$2"
    
    Set-Content -Path $StatusFile -Value $content
    Write-Host "Metrics updated!" -ForegroundColor Green
}

# Main execution
if (-not $ProjectName) {
    # Interactive mode
    Show-ProjectStatus
    
    Write-Host "`nWhat would you like to do?" -ForegroundColor Cyan
    Write-Host "1. Update a project status" -ForegroundColor White
    Write-Host "2. Update metrics" -ForegroundColor White
    Write-Host "3. View full status file" -ForegroundColor White
    Write-Host "4. Exit" -ForegroundColor White
    
    $choice = Read-Host "Enter choice (1-4)"
    
    switch ($choice) {
        "1" {
            $ProjectName = Read-Host "Enter project name"
            Write-Host "Select new status:" -ForegroundColor Cyan
            Write-Host "1. Planning" -ForegroundColor White
            Write-Host "2. Active" -ForegroundColor White
            Write-Host "3. Maintenance" -ForegroundColor White
            Write-Host "4. Production" -ForegroundColor White
            Write-Host "5. Archived" -ForegroundColor White
            
            $statusChoice = Read-Host "Enter choice (1-5)"
            $Status = @("planning", "active", "maintenance", "production", "archived")[$statusChoice - 1]
            
            $Note = Read-Host "Enter update note (optional)"
            
            Update-ProjectStatus -Project $ProjectName -NewStatus $Status -UpdateNote $Note
        }
        "2" {
            Update-Metrics
        }
        "3" {
            Get-Content $StatusFile | more
        }
        "4" {
            exit
        }
    }
}
else {
    # Command-line mode
    Update-ProjectStatus -Project $ProjectName -NewStatus $Status -UpdateNote $Note
}

Write-Host "`nDone!" -ForegroundColor Green