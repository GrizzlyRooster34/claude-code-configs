#!/bin/bash
# Merge Review Agent Installation Script
# For Claude Code instances on Termux/Android

set -e

echo "🤖 Installing Merge Review Agent for Claude Code..."

# Check if we're in Termux
if [[ ! -d "/data/data/com.termux" ]]; then
    echo "❌ This installer is designed for Termux on Android"
    exit 1
fi

# Install system dependencies
echo "📦 Installing system dependencies..."
pkg update -y
pkg install -y nodejs git openssh cronie

# Create agent directory
AGENT_DIR="$HOME/agents/merge-review"
echo "📁 Setting up agent directory: $AGENT_DIR"
mkdir -p "$AGENT_DIR"

# Copy agent files
echo "📋 Copying agent files..."
cp -r src/ package.json tsconfig.json .env.example "$AGENT_DIR/"
cd "$AGENT_DIR"

# Install npm dependencies
echo "📦 Installing npm dependencies..."
npm install

# Set up environment template
if [[ ! -f ".env" ]]; then
    cp .env.example .env
    echo "⚙️ Created .env template - please configure your GitHub token"
fi

# Build TypeScript
echo "🔨 Building TypeScript..."
npx tsc

# Start cron daemon if not running
if ! pgrep crond > /dev/null; then
    echo "⏰ Starting cron daemon..."
    crond
fi

echo "✅ Merge Review Agent installed successfully!"
echo ""
echo "Next steps:"
echo "1. Edit $AGENT_DIR/.env with your GitHub token"
echo "2. Test: cd $AGENT_DIR && node dist/merge-review-agent.js"
echo "3. Schedule: (crontab -l 2>/dev/null; echo '*/10 * * * * cd $AGENT_DIR && node dist/merge-review-agent.js >> agent.log 2>&1') | crontab -"
echo ""
echo "Monitor logs: tail -f $AGENT_DIR/agent.log"
