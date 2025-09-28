# Setup Guide

## Quick Start

```powershell
# 1. Clone repository
git clone https://github.com/DMorford/The-Funky-Black-Box.git
cd The-Funky-Black-Box

# 2. Copy configuration files
Copy-Item _config/config.example.json _config/config.json
Copy-Item _config/.env.example _config/.env

# 3. Set environment variables
notepad _config/.env  # Edit environment variables

# 4. Validate setup
._config/Validate-Configuration.ps1

# 5. Initialize workspace
._scripts/new-project.ps1 -Name "YourProject" -Type "python" -Description "Your description"
```

## Detailed Setup Steps

### 1. Prerequisites

- Windows 10/11
- PowerShell 7+
- Git
- Visual Studio Code
- Node.js 18+ (for JavaScript/TypeScript projects)
- Python 3.9+ (for Python projects)

### 2. Initial Setup

1. **Clone Repository**
   ```powershell
   git clone https://github.com/DMorford/The-Funky-Black-Box.git
   cd The-Funky-Black-Box
   ```

2. **Create Configuration**
   ```powershell
   # Copy configuration templates
   Copy-Item _config/config.example.json _config/config.json
   Copy-Item _config/.env.example _config/.env
   
   # For Python projects
   Copy-Item _config/.env.python.example _config/.env.python
   
   # For JavaScript projects
   Copy-Item _config/.env.javascript.example _config/.env.javascript
   ```

3. **Configure Environment**
   - Edit `_config/.env`:
     ```ini
     DEVPROJECTS_ROOT=C:\path\to\DevProjects
     GITHUB_TOKEN=your_github_token
     NODE_ENV=development
     ```

4. **Run Validation**
   ```powershell
   ._config/Validate-Configuration.ps1
   ```

### 3. Security Setup

1. **Generate GitHub Token**
   - Visit: https://github.com/settings/tokens
   - Create token with required scopes
   - Add to `.env` file

2. **Configure Git**
   ```powershell
   git config user.name "Your Name"
   git config user.email "your.email@example.com"
   ```

3. **Install Pre-commit Hook**
   ```powershell
   Copy-Item .github/hooks/pre-commit .git/hooks/
   ```

### 4. Project Creation

1. **Create New Project**
   ```powershell
   ._scripts/new-project.ps1 -Name "YourProject" -Type "python" -Description "Your description"
   ```

2. **Initialize Project**
   ```powershell
   cd active/YourProject
   # For Python projects
   python -m venv .venv
   .venv/Scripts/Activate.ps1
   pip install -r requirements.txt
   
   # For JavaScript projects
   npm install
   ```

### 5. Validation and Testing

1. **Run Smoke Tests**
   ```powershell
   ._config/Test-Environment.ps1
   ```

2. **Verify Project Structure**
   ```powershell
   ._scripts/verify-project.ps1 -Name "YourProject"
   ```

## Directory Structure

```
DevProjects/
├── _config/               # Configuration files
├── _scripts/             # Automation scripts
├── _templates/           # Project templates
├── active/              # Active projects
├── archived/            # Completed projects
├── backups/             # Project backups
└── sandbox/             # Experimental work
```

## Configuration Files

1. **config.json**
   - Core configuration
   - Path definitions
   - Security settings

2. **.env Files**
   - `.env`: Core environment variables
   - `.env.python`: Python-specific settings
   - `.env.javascript`: JavaScript-specific settings

## Smoke Tests

Run quick validation:
```powershell
# Test configuration
Import-Module .\_config\ConfigurationModule.psm1
Test-Configuration

# Verify paths
Test-FunkyEnvironment

# Check security
._config/Test-SecuritySettings.ps1
```

## Common Issues

### 1. Path Issues
```powershell
# Fix paths in config.json
$env:DEVPROJECTS_ROOT = "C:\correct\path"
._config/Validate-Configuration.ps1
```

### 2. Permission Issues
```powershell
# Check folder permissions
._scripts/verify-permissions.ps1
```

### 3. Git Issues
```powershell
# Reset Git configuration
._scripts/reset-git-config.ps1
```

## Next Steps

1. Review [CONFIG.md](./_config/CONFIG.md) for configuration details
2. Review [SECURITY.md](./_config/SECURITY.md) for security practices
3. Review [CONTRIBUTING.md](./CONTRIBUTING.md) for development guidelines

## Support

- Open an issue on GitHub
- Check documentation in `/docs`
- Run diagnostic scripts in `/_scripts`

## Updates

1. **Update Configuration**
   ```powershell
   ._scripts/update-config.ps1
   ```

2. **Update Scripts**
   ```powershell
   ._scripts/update-scripts.ps1
   ```

3. **Update Documentation**
   ```powershell
   ._scripts/update-docs.ps1
   ```
