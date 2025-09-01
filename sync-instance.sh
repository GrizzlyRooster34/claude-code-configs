#!/bin/bash

# Claude Code Instance Sync Script
# Device: OnePlus 7T (OxygenOS 12) - Termux
# Branch: claude-instance-oneplus7t-oxygenos12-termux

INSTANCE_BRANCH="claude-instance-oneplus7t-oxygenos12-termux"
DEVICE_ID="oneplus7t-termux-001"

echo "🔄 Claude Code Instance Sync - $DEVICE_ID"
echo "Branch: $INSTANCE_BRANCH"

# Check if we're in the right repository
if [ ! -f "INSTANCE_ID.md" ]; then
    echo "❌ Error: Not in claude-code-configs directory"
    exit 1
fi

# Ensure we're on our instance branch
git checkout "$INSTANCE_BRANCH" 2>/dev/null || {
    echo "⚠️  Creating instance branch: $INSTANCE_BRANCH"
    git checkout -b "$INSTANCE_BRANCH"
}

# Pull latest from master (shared configs)
echo "📥 Pulling shared configurations from master..."
git fetch origin master
git rebase origin/master

# Add any local changes
echo "📤 Committing local instance changes..."
git add .
git commit -m "Instance sync: $DEVICE_ID - $(date '+%Y-%m-%d %H:%M:%S')" || echo "No changes to commit"

# Push instance updates
echo "☁️  Pushing instance updates..."
git push origin "$INSTANCE_BRANCH" -u

# Update sync timestamp in INSTANCE_ID.md
sed -i "s/Last Sync:.*/Last Sync: $(date '+%Y-%m-%d %H:%M:%S')/g" INSTANCE_ID.md

echo "✅ Sync complete for $DEVICE_ID"
echo "Instance branch: $INSTANCE_BRANCH"
echo "Repository: https://github.com/GrizzlyRooster34/claude-code-configs"