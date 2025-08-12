# DevProjects - Unified Development Environment

## Overview
This is the central hub for all development projects, organized for collaborative work between AI assistants and human developers.

## Project Structure

```
DevProjects/
├── README.md                      # This file - main documentation
├── PROJECT_STATUS.md              # Project tracking dashboard
├── .github/                       # GitHub templates and workflows
│   ├── workflows/                 # CI/CD workflows
│   ├── ISSUE_TEMPLATE/           # Issue templates
│   └── PULL_REQUEST_TEMPLATE.md  # PR template
├── _templates/                    # Project templates
│   ├── python/                   # Python project template
│   ├── javascript/               # JavaScript project template
│   └── documentation/            # Documentation templates
├── _scripts/                      # Automation scripts
│   ├── new-project.ps1          # Create new project
│   ├── update-status.ps1        # Update project status
│   └── backup-all.ps1           # Backup all projects
├── active/                        # Active development projects
│   ├── Looksy/                  # Vision AI project
│   ├── PyTorch-RTX5070/         # PyTorch optimization
│   ├── StreamDeck-Rescue/       # Stream Deck tools
│   └── OBS-Rescue/              # OBS automation
├── archived/                      # Completed/archived projects
└── sandbox/                       # Experimental work
```

## Quick Commands

### Create New Project
```powershell
.\_scripts\new-project.ps1 -Name "ProjectName" -Type "python"
```

### Update Project Status
```powershell
.\_scripts\update-status.ps1
```

### View All Projects
```powershell
cat PROJECT_STATUS.md
```

## Collaboration Guidelines

### For AI Assistants
- Always check PROJECT_STATUS.md before starting work
- Update status after significant changes
- Follow project-specific README files
- Use standardized commit messages

### For Human Developers
- Review AI-generated code before merging
- Maintain project documentation
- Set clear goals in project READMEs
- Use issue tracking for task management

## Project Categories

### 🔴 Active Projects
Currently under development with regular commits

### 🟡 Maintenance Projects
Stable but receiving updates and fixes

### 🟢 Production Projects
Deployed and running in production

### ⚫ Archived Projects
Completed or deprecated projects

## Development Standards

### Git Workflow
- Main branch: `main` (production-ready)
- Development: `develop` (integration)
- Features: `feature/description`
- Fixes: `fix/description`

### Commit Messages
```
type(scope): description

- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code refactoring
- test: Testing
- chore: Maintenance
```

### Code Quality
- All projects include linting configuration
- Tests required for new features
- Documentation for public APIs
- Security scanning on commits

## Tools & Technologies

### Required
- Git
- Visual Studio Code or preferred IDE
- Python 3.11+
- Node.js 20+

### Recommended
- Claude Code (AI assistant)
- GitHub CLI
- Docker Desktop
- Windows Terminal

## Getting Started

1. Clone this repository
2. Install required tools
3. Run setup script: `.\_scripts\setup-environment.ps1`
4. Check PROJECT_STATUS.md for available projects
5. Start contributing!

## Support

- Documentation: Check project-specific docs
- Issues: Use GitHub Issues
- AI Help: Claude Code can assist with most tasks

---
Last Updated: 2025-01-12