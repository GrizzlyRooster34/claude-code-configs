#!/bin/bash

# Claude Code Configuration Installer
# Installs all configurations from this repository

echo "Installing Claude Code configurations..."

# Create necessary directories
mkdir -p ~/.claude/agents
mkdir -p ~/.claude/output-styles

# Install agents
echo "Installing agents..."
cp -r agents/* ~/.claude/agents/

# Install settings
echo "Installing settings..."
cp settings.json ~/.claude/ 2>/dev/null || echo "No settings.json found"
cp settings.local.json ~/.claude/ 2>/dev/null || echo "No settings.local.json found"

# Install statusline
echo "Installing statusline script..."
cp usage-statusline.sh ~/.claude/
chmod +x ~/.claude/usage-statusline.sh

# Install output styles
echo "Installing output styles..."
cp -r output-styles/* ~/.claude/output-styles/ 2>/dev/null || echo "No output styles to install"

# Install commands and orchestration
echo "Installing commands and orchestration..."
mkdir -p ~/.claude/commands ~/.claude/orchestration
cp -r commands/* ~/.claude/commands/ 2>/dev/null || echo "No commands to install"
cp -r orchestration/* ~/.claude/orchestration/ 2>/dev/null || echo "No orchestration configs to install"

echo "Installation complete!"
echo "39 agents and associated configurations have been installed."
echo ""
echo "To verify installation:"
echo "  ls ~/.claude/agents/ | wc -l"
echo ""
echo "Your Claude Code instance is now configured with the seven-of-nine-core agent mesh."