# Windows 11 AMD Laptop - Desktop Master Instance Template

## Branch Name
`claude-instance-amdlaptop-win11-powershell`

## INSTANCE_ID.md Template
```markdown
# Claude Code Instance Identity

## Device Information
- **Device**: AMD Laptop
- **OS**: Windows 11
- **Terminal**: PowerShell
- **Branch**: `claude-instance-amdlaptop-win11-powershell`

## Instance Configuration
- **Claude Code Model**: Sonnet 4
- **Platform**: Windows 11 (Native)
- **Working Directory**: `C:\Users\[username]\`
- **Seven Core Path**: `C:\Users\[username]\seven-of-nine-core\`

## Environment Specs
- **Shell**: PowerShell 7.x
- **Node.js**: Available via winget/chocolatey
- **Git**: Git for Windows
- **Python**: Available via Microsoft Store/winget

## Synchronization Protocol
- **Primary Branch**: `master` (shared configurations)
- **Instance Branch**: `claude-instance-amdlaptop-win11-powershell` (device-specific)
- **Sync Method**: Git-based with automated PowerShell sync
- **Conflict Resolution**: DESKTOP MASTER AUTHORITY

## Instance Status
- **Created**: [DATE]
- **Status**: DESKTOP/LAPTOP MASTER INSTANCE
- **Priority**: 1 (Desktop Authority)
- **Dumbass Protocol**: Enforced
- **Agent Mesh**: 39 agents deployed and operational

## Device-Specific Notes
- AMD processor optimized for development workloads
- Windows 11 with full development toolchain
- PowerShell provides robust scripting environment
- Native Windows Claude Code integration
- DESKTOP MASTER: Final authority on desktop/laptop configurations

## Master Instance Responsibilities
- Approve/reject desktop/laptop configuration changes
- Resolve desktop device sync conflicts
- Optimize Windows Claude Code performance
- Maintain desktop agent configurations
- Authority over PowerShell/Windows-specific setups

---

**Instance Identifier**: `claude-amdlaptop-win11-MASTER`
**Authority Level**: DESKTOP/LAPTOP MASTER
**Last Sync**: [TIMESTAMP]
**Next Sync**: Automated via PowerShell profile
```

## sync-instance.ps1 Template (PowerShell)
```powershell
#!/usr/bin/env pwsh

# Claude Code Instance Sync Script - DESKTOP MASTER
# Device: AMD Laptop (Windows 11) - PowerShell
# Branch: claude-instance-amdlaptop-win11-powershell

$INSTANCE_BRANCH = "claude-instance-amdlaptop-win11-powershell"
$DEVICE_ID = "amdlaptop-win11-MASTER"

Write-Host "🔄 Claude Code DESKTOP MASTER Sync - $DEVICE_ID" -ForegroundColor Cyan
Write-Host "Branch: $INSTANCE_BRANCH" -ForegroundColor Green
Write-Host "👑 DESKTOP MASTER AUTHORITY ACTIVE" -ForegroundColor Yellow

# Check if we're in the right repository
if (-not (Test-Path "INSTANCE_ID.md")) {
    Write-Host "❌ Error: Not in claude-code-configs directory" -ForegroundColor Red
    exit 1
}

# Ensure we're on our instance branch
git checkout $INSTANCE_BRANCH 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Creating DESKTOP MASTER branch: $INSTANCE_BRANCH" -ForegroundColor Yellow
    git checkout -b $INSTANCE_BRANCH
}

# Pull latest from master (shared configs)
Write-Host "📥 Pulling shared configurations from master..." -ForegroundColor Blue
git fetch origin master
git rebase origin/master

# MASTER AUTHORITY: Pull from secondary desktop instances
Write-Host "💻 DESKTOP MASTER: Syncing from secondary desktop instances..." -ForegroundColor Magenta
git fetch origin --all 2>$null

# Add any local changes
Write-Host "📤 Committing DESKTOP MASTER changes..." -ForegroundColor Blue
git add .
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
git commit -m "DESKTOP MASTER sync: $DEVICE_ID - $timestamp"
if ($LASTEXITCODE -ne 0) {
    Write-Host "No changes to commit" -ForegroundColor Gray
}

# Push MASTER updates
Write-Host "☁️  Pushing DESKTOP MASTER updates..." -ForegroundColor Blue
git push origin $INSTANCE_BRANCH -u

# Update sync timestamp
$content = Get-Content "INSTANCE_ID.md" -Raw
$updated = $content -replace "Last Sync:.*", "Last Sync: $timestamp"
Set-Content "INSTANCE_ID.md" -Value $updated

Write-Host "✅ DESKTOP MASTER sync complete: $DEVICE_ID" -ForegroundColor Green
Write-Host "👑 Desktop authority established" -ForegroundColor Yellow
Write-Host "Instance branch: $INSTANCE_BRANCH" -ForegroundColor Cyan
```

## Windows PowerShell Profile Integration
Add to PowerShell profile (`$PROFILE`):
```powershell
# Auto-sync Claude Code instance configurations
$CLAUDE_CONFIGS_DIR = "$HOME\claude-code-configs"
if (Test-Path $CLAUDE_CONFIGS_DIR) {
    Start-Job -ScriptBlock {
        Set-Location $using:CLAUDE_CONFIGS_DIR
        .\sync-instance.ps1
    } | Out-Null
}
```