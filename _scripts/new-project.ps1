# New Project Creation Script
# Creates a new project with proper structure and templates

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("python", "javascript", "typescript", "generic")]
    [string]$Type,
    
    [Parameter()]
    [ValidateSet("active", "sandbox", "archived")]
    [string]$Category = "active",
    
    [Parameter()]
    [string]$Description = "New project"
)

$ErrorActionPreference = "Stop"

# Define base paths
$BasePath = "C:\Users\morfo\DevProjects"
$ProjectPath = Join-Path $BasePath $Category $Name
$TemplatesPath = Join-Path $BasePath "_templates"

Write-Host "Creating new $Type project: $Name" -ForegroundColor Green

# Create project directory
if (Test-Path $ProjectPath) {
    Write-Host "Project directory already exists!" -ForegroundColor Red
    exit 1
}

New-Item -ItemType Directory -Path $ProjectPath -Force | Out-Null
Write-Host "Created project directory: $ProjectPath" -ForegroundColor Yellow

# Create standard project structure
$folders = @(
    "src",
    "tests",
    "docs",
    "scripts",
    ".github\workflows"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path (Join-Path $ProjectPath $folder) -Force | Out-Null
}

# Copy appropriate .gitignore
$gitignoreSource = Join-Path $TemplatesPath $Type ".gitignore"
if (Test-Path $gitignoreSource) {
    Copy-Item $gitignoreSource (Join-Path $ProjectPath ".gitignore")
} else {
    # Use python gitignore as default
    Copy-Item (Join-Path $TemplatesPath "python" ".gitignore") (Join-Path $ProjectPath ".gitignore")
}

# Copy README template
$readmeTemplate = Get-Content (Join-Path $TemplatesPath "documentation" "PROJECT_README_TEMPLATE.md") -Raw
$readmeContent = $readmeTemplate -replace "Project Name", $Name
$readmeContent = $readmeContent -replace "Brief description.*", $Description
Set-Content -Path (Join-Path $ProjectPath "README.md") -Value $readmeContent

# Create project-specific files based on type
switch ($Type) {
    "python" {
        # Create requirements.txt
        @"
# Core dependencies
pytest>=7.0.0
black>=22.0.0
flake8>=4.0.0
pylint>=2.0.0
pytest-cov>=3.0.0

# Add project-specific dependencies below
"@ | Set-Content (Join-Path $ProjectPath "requirements.txt")

        # Create setup.py
        @"
from setuptools import setup, find_packages

setup(
    name='$Name',
    version='0.1.0',
    packages=find_packages(where='src'),
    package_dir={'': 'src'},
    python_requires='>=3.9',
)
"@ | Set-Content (Join-Path $ProjectPath "setup.py")

        # Create __init__.py
        New-Item -ItemType File -Path (Join-Path $ProjectPath "src" "__init__.py") -Force | Out-Null
    }
    
    "javascript" {
        # Create package.json
        $packageJson = @{
            name = $Name.ToLower()
            version = "0.1.0"
            description = $Description
            main = "src/index.js"
            scripts = @{
                test = "jest"
                lint = "eslint src/"
                format = "prettier --write src/"
            }
            keywords = @()
            author = ""
            license = "MIT"
            devDependencies = @{
                jest = "^29.0.0"
                eslint = "^8.0.0"
                prettier = "^2.0.0"
            }
        }
        $packageJson | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ProjectPath "package.json")
        
        # Create index.js
        "// Main entry point for $Name" | Set-Content (Join-Path $ProjectPath "src" "index.js")
    }
    
    "typescript" {
        # Create package.json
        $packageJson = @{
            name = $Name.ToLower()
            version = "0.1.0"
            description = $Description
            main = "dist/index.js"
            scripts = @{
                build = "tsc"
                test = "jest"
                lint = "eslint src/"
                format = "prettier --write src/"
            }
            keywords = @()
            author = ""
            license = "MIT"
            devDependencies = @{
                typescript = "^5.0.0"
                "@types/node" = "^20.0.0"
                jest = "^29.0.0"
                "@types/jest" = "^29.0.0"
                "ts-jest" = "^29.0.0"
                eslint = "^8.0.0"
                prettier = "^2.0.0"
            }
        }
        $packageJson | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ProjectPath "package.json")
        
        # Create tsconfig.json
        $tsConfig = @{
            compilerOptions = @{
                target = "ES2022"
                module = "commonjs"
                lib = @("ES2022")
                outDir = "./dist"
                rootDir = "./src"
                strict = $true
                esModuleInterop = $true
                skipLibCheck = $true
                forceConsistentCasingInFileNames = $true
            }
            include = @("src/**/*")
            exclude = @("node_modules", "dist")
        }
        $tsConfig | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ProjectPath "tsconfig.json")
        
        # Create index.ts
        "// Main entry point for $Name" | Set-Content (Join-Path $ProjectPath "src" "index.ts")
    }
}

# Initialize git repository
Set-Location $ProjectPath
git init
git add .
git commit -m "Initial commit: $Name project setup"

# Update PROJECT_STATUS.md
$statusFile = Join-Path $BasePath "PROJECT_STATUS.md"
$statusContent = Get-Content $statusFile -Raw

# Add new project to planning phase
$today = Get-Date -Format "yyyy-MM-dd"
$newEntry = "| **$Name** | 📝 Planning | MEDIUM | $Type | $Description | $today | Requirements gathering | Just created |"

# Find the planning table and add the new entry
$statusContent = $statusContent -replace "(## 📋 Planning Phase.*?\|.*?\|.*?\|.*?\|.*?\|.*?\|.*?\|.*?\|[\r\n]+)", "`$1$newEntry`r`n"

Set-Content -Path $statusFile -Value $statusContent

Write-Host "`nProject created successfully!" -ForegroundColor Green
Write-Host "Location: $ProjectPath" -ForegroundColor Cyan
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. cd `"$ProjectPath`"" -ForegroundColor White
Write-Host "2. Update the README.md with project details" -ForegroundColor White
Write-Host "3. Install dependencies (pip install -r requirements.txt or npm install)" -ForegroundColor White
Write-Host "4. Start coding!" -ForegroundColor White