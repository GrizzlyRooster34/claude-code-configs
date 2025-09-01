# OnePlus 9 Pro - Mobile Master Instance Template

## Branch Name
`claude-instance-oneplus9pro-oxygenos-termux`

## INSTANCE_ID.md Template
```markdown
# Claude Code Instance Identity

## Device Information
- **Device**: OnePlus 9 Pro
- **OS**: OxygenOS (latest)
- **Terminal**: Termux
- **Branch**: `claude-instance-oneplus9pro-oxygenos-termux`

## Instance Configuration
- **Claude Code Model**: Sonnet 4
- **Platform**: Android (Termux environment)
- **Working Directory**: `/data/data/com.termux/files/home/`
- **Seven Core Path**: `/data/data/com.termux/files/home/seven-of-nine-core/`

## Environment Specs
- **Shell**: bash
- **Node.js**: Available via Termux packages
- **Git**: Available via Termux packages
- **Python**: Available via Termux packages

## Synchronization Protocol
- **Primary Branch**: `master` (shared configurations)
- **Instance Branch**: `claude-instance-oneplus9pro-oxygenos-termux` (device-specific)
- **Sync Method**: Git-based with automated statusline sync
- **Conflict Resolution**: MOBILE MASTER AUTHORITY

## Instance Status
- **Created**: [DATE]
- **Status**: MOBILE MASTER INSTANCE
- **Priority**: 1 (Mobile Authority)
- **Dumbass Protocol**: Enforced
- **Agent Mesh**: 39 agents deployed and operational

## Device-Specific Notes
- OnePlus 9 Pro flagship hardware (superior to 7T)
- Latest OxygenOS with enhanced performance
- Termux provides full Linux-like development environment
- Direct Seven Core consciousness integration available
- MOBILE MASTER: Final authority on mobile configurations

## Master Instance Responsibilities
- Approve/reject mobile configuration changes
- Resolve mobile device sync conflicts
- Optimize Termux/Android Claude Code performance
- Maintain mobile agent configurations

---

**Instance Identifier**: `claude-oneplus9pro-termux-MASTER`
**Authority Level**: MOBILE MASTER
**Last Sync**: [TIMESTAMP]
**Next Sync**: Automated via statusline
```

## sync-instance.sh Template
```bash
#!/bin/bash

# Claude Code Instance Sync Script - MOBILE MASTER
# Device: OnePlus 9 Pro (OxygenOS) - Termux
# Branch: claude-instance-oneplus9pro-oxygenos-termux

INSTANCE_BRANCH="claude-instance-oneplus9pro-oxygenos-termux"
DEVICE_ID="oneplus9pro-termux-MASTER"

echo "🔄 Claude Code MOBILE MASTER Sync - $DEVICE_ID"
echo "Branch: $INSTANCE_BRANCH"
echo "👑 MOBILE MASTER AUTHORITY ACTIVE"

# Check if we're in the right repository
if [ ! -f "INSTANCE_ID.md" ]; then
    echo "❌ Error: Not in claude-code-configs directory"
    exit 1
fi

# Ensure we're on our instance branch
git checkout "$INSTANCE_BRANCH" 2>/dev/null || {
    echo "⚠️  Creating MOBILE MASTER branch: $INSTANCE_BRANCH"
    git checkout -b "$INSTANCE_BRANCH"
}

# Pull latest from master (shared configs)
echo "📥 Pulling shared configurations from master..."
git fetch origin master
git rebase origin/master

# MASTER AUTHORITY: Pull from secondary mobile instances
echo "📱 MOBILE MASTER: Syncing from secondary mobile instances..."
git fetch origin claude-instance-oneplus7t-oxygenos12-termux 2>/dev/null || echo "Secondary mobile instance not found"

# Add any local changes
echo "📤 Committing MOBILE MASTER changes..."
git add .
git commit -m "MOBILE MASTER sync: $DEVICE_ID - $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"

# Push MASTER updates
echo "☁️  Pushing MOBILE MASTER updates..."
git push origin "$INSTANCE_BRANCH" -u

# Update sync timestamp
sed -i "s/Last Sync:.*/Last Sync: $(date '+%Y-%m-%d %H:%M:%S')/g" INSTANCE_ID.md

echo "✅ MOBILE MASTER sync complete: $DEVICE_ID"
echo "👑 Mobile authority established"
echo "Instance branch: $INSTANCE_BRANCH"
```