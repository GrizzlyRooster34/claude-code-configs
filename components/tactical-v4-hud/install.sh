#!/bin/bash
# Tactical V4 HUD Statusline Installation Script
# For Claude Code instances on Termux/Android

set -e

echo "⚡ Installing Tactical V4 HUD Statusline..."

# Check if we're in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo "❌ This installer is optimized for Termux on Android"
    echo "   Will attempt installation anyway..."
fi

# Create Claude config directory
CLAUDE_DIR="$HOME/.claude"
echo "📁 Setting up Claude config directory: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR"

# Install the statusline
echo "📋 Installing tactical statusline HUD..."
cp enhanced-tactical-hud-statusline.sh "$CLAUDE_DIR/usage-statusline.sh"
chmod +x "$CLAUDE_DIR/usage-statusline.sh"

# Check for jq (recommended but not required)
if command -v jq >/dev/null 2>&1; then
    echo "✅ jq detected - enhanced JSON parsing available"
else
    echo "⚠️  jq not found - install with: pkg install jq (recommended)"
fi

# Set default palette if not already set
if [ -z "$SEVEN_PALETTE" ]; then
    echo "🎨 Setting default tactical color palette"
    echo 'export SEVEN_PALETTE=tactical' >> "$HOME/.bashrc"
fi

echo ""
echo "✅ Tactical V4 HUD Statusline installed successfully!"
echo ""
echo "Features:"
echo "  🎯 Model recognition with tactical aliases"
echo "  📊 Context tracking and token usage parsing"
echo "  ⏱️  5-hour operational window management"
echo "  🔄 Git integration with upstream tracking"
echo "  🎨 Multiple color palettes (tactical/neon/highcontrast)"
echo ""
echo "Configuration:"
echo "  • Statusline: $CLAUDE_DIR/usage-statusline.sh"
echo "  • Palette: export SEVEN_PALETTE=tactical|neon|highcontrast"
echo "  • Manual anchor: export CLAUDE_FIRST_MSG=<epoch_timestamp>"
echo ""
echo "Test with: echo '{}' | ~/.claude/usage-statusline.sh"
