# Configuration Guide

## Overview

The Funky Black Box uses a typed configuration system for managing project settings, paths, and security policies. This document explains all configuration keys and their purposes.

## Core Configuration Structure

```json
{
    "workspace": {
        "basePath": "${DEVPROJECTS_ROOT}",
        "paths": {
            "templates": "${DEVPROJECTS_ROOT}/_templates",
            "scripts": "${DEVPROJECTS_ROOT}/_scripts",
            "config": "${DEVPROJECTS_ROOT}/_config",
            "active": "${DEVPROJECTS_ROOT}/active",
            "archived": "${DEVPROJECTS_ROOT}/archived",
            "backups": "${DEVPROJECTS_ROOT}/backups",
            "sandbox": "${DEVPROJECTS_ROOT}/sandbox"
        }
    },
    "security": {
        "allowedProjectTypes": ["python", "javascript", "typescript"],
        "requiredEnvVars": [
            "DEVPROJECTS_ROOT",
            "GITHUB_TOKEN",
            "NODE_ENV"
        ],
        "backupRetentionDays": 30,
        "maxBackupSize": "1GB",
        "allowedExtensions": [
            ".py", ".js", ".ts", ".json", ".md", ".yml", ".yaml",
            ".txt", ".env", ".example", ".template"
        ]
    },
    "git": {
        "defaultBranch": "main",
        "requiredFiles": [
            ".gitignore",
            "README.md",
            "CONTRIBUTING.md"
        ]
    }
}
```

## Configuration Keys Explained

### Workspace Settings

| Key | Description | Default | Required |
|-----|-------------|---------|----------|
| `workspace.basePath` | Root directory for all projects | `${DEVPROJECTS_ROOT}` | Yes |
| `workspace.paths.templates` | Project templates location | `${DEVPROJECTS_ROOT}/_templates` | Yes |
| `workspace.paths.scripts` | Automation scripts location | `${DEVPROJECTS_ROOT}/_scripts` | Yes |
| `workspace.paths.config` | Configuration files location | `${DEVPROJECTS_ROOT}/_config` | Yes |
| `workspace.paths.active` | Active projects directory | `${DEVPROJECTS_ROOT}/active` | Yes |
| `workspace.paths.archived` | Archived projects directory | `${DEVPROJECTS_ROOT}/archived` | Yes |
| `workspace.paths.backups` | Backup files location | `${DEVPROJECTS_ROOT}/backups` | Yes |
| `workspace.paths.sandbox` | Experimental projects directory | `${DEVPROJECTS_ROOT}/sandbox` | Yes |

### Security Settings

| Key | Description | Default | Required |
|-----|-------------|---------|----------|
| `security.allowedProjectTypes` | List of allowed project types | `["python", "javascript", "typescript"]` | Yes |
| `security.requiredEnvVars` | Required environment variables | See example | Yes |
| `security.backupRetentionDays` | Days to keep backups | 30 | Yes |
| `security.maxBackupSize` | Maximum backup size | "1GB" | Yes |
| `security.allowedExtensions` | Allowed file extensions | See example | Yes |

### Git Settings

| Key | Description | Default | Required |
|-----|-------------|---------|----------|
| `git.defaultBranch` | Default Git branch name | "main" | Yes |
| `git.requiredFiles` | Required files in each project | See example | Yes |

## Environment Variables

### Core Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DEVPROJECTS_ROOT` | Root directory path | Yes |
| `GITHUB_TOKEN` | GitHub authentication token | Yes |
| `NODE_ENV` | Environment (development/production) | Yes |

### Project-Specific Variables

See `.env.*.example` files in `_config` directory for project-specific variables.

## Type Definitions

The configuration is strongly typed using PowerShell classes:

```powershell
# FunkyPaths class
[FunkyPaths]$config.Paths
    .Root
    .Templates
    .Scripts
    .Config
    .Active
    .Archived
    .Backups
    .Sandbox

# FunkySecurity class
[FunkySecurity]$config.Security
    .AllowedProjectTypes
    .RequiredEnvVars
    .BackupRetentionDays
    .MaxBackupSize
    .AllowedExtensions
```

## Usage Examples

### PowerShell Scripts

```powershell
# Import configuration
Import-Module "$PSScriptRoot/../_config/ConfigurationModule.psm1"
Initialize-FunkyConfig

# Get typed configuration
$config = Get-FunkyConfig

# Access paths safely
$templatesPath = $config.Paths.Templates
$scriptsPath = $config.Paths.Scripts

# Check security settings
$allowedTypes = $config.Security.AllowedProjectTypes
$maxSize = $config.Security.MaxBackupSize
```

## Validation

Run the validation script to check configuration:

```powershell
.\_config\Validate-Configuration.ps1
```

## Best Practices

1. Never commit `config.json` - use `config.example.json`
2. Never commit `.env` files - use `.env.*.example`
3. Always validate configuration before running scripts
4. Use environment variables for sensitive data
5. Keep paths relative to `DEVPROJECTS_ROOT`

## Troubleshooting

### Common Issues

1. **Missing Configuration**
   - Copy `config.example.json` to `config.json`
   - Run validation script

2. **Invalid Paths**
   - Ensure `DEVPROJECTS_ROOT` is set
   - Check path formatting

3. **Security Violations**
   - Review allowed extensions
   - Check file permissions
   - Validate environment variables
