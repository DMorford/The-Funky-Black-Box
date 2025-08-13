# ConfigTypes.ps1
# Type definitions for Funky Black Box configuration

class FunkyPaths {
    [string]$Root
    [string]$Templates
    [string]$Scripts
    [string]$Config
    [string]$Active
    [string]$Archived
    [string]$Backups
    [string]$Sandbox

    FunkyPaths([PSObject]$paths) {
        $this.Root = $paths.basePath
        $this.Templates = $paths.templates
        $this.Scripts = $paths.scripts
        $this.Config = $paths.config
        $this.Active = $paths.active
        $this.Archived = $paths.archived
        $this.Backups = $paths.backups
        $this.Sandbox = $paths.sandbox
    }
}

class FunkySecurity {
    [string[]]$AllowedProjectTypes
    [string[]]$RequiredEnvVars
    [int]$BackupRetentionDays
    [string]$MaxBackupSize
    [string[]]$AllowedExtensions

    FunkySecurity([PSObject]$security) {
        $this.AllowedProjectTypes = $security.allowedProjectTypes
        $this.RequiredEnvVars = $security.requiredEnvVars
        $this.BackupRetentionDays = $security.backupRetentionDays
        $this.MaxBackupSize = $security.maxBackupSize
        $this.AllowedExtensions = $security.allowedExtensions
    }
}

class FunkyConfiguration {
    [FunkyPaths]$Paths
    [FunkySecurity]$Security
    [hashtable]$Git

    FunkyConfiguration([PSObject]$config) {
        $this.Paths = [FunkyPaths]::new($config.workspace.paths)
        $this.Security = [FunkySecurity]::new($config.security)
        $this.Git = @{
            DefaultBranch = $config.git.defaultBranch
            RequiredFiles = $config.git.requiredFiles
        }
    }
}
