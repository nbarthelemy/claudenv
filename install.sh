#!/bin/bash
# Claudenv Installer
# Usage: curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/install.sh | bash

set -e

REPO_URL="https://github.com/nbarthelemy/claudenv"
BRANCH="main"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Claudenv Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check if .claude already exists
if [ -d ".claude" ]; then
    echo ""
    echo "⚠️  .claude directory already exists"
    echo ""
    read -p "Backup and replace? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        BACKUP_DIR=".claude.backup.$(date +%Y%m%d_%H%M%S)"
        echo "📦 Backing up to $BACKUP_DIR"
        mv .claude "$BACKUP_DIR"
    else
        echo "❌ Installation cancelled"
        exit 1
    fi
fi

echo ""
echo "📥 Downloading Claudenv..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download and extract
if command -v curl &> /dev/null; then
    curl -sL "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
elif command -v wget &> /dev/null; then
    wget -qO- "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
else
    echo "❌ Error: curl or wget required"
    exit 1
fi

# Copy .claude directory
echo "📁 Installing .claude directory..."
cp -r "$TEMP_DIR"/claudenv-${BRANCH}/.claude .

# Make scripts executable
chmod +x .claude/scripts/*.sh 2>/dev/null || true

# Count what was installed
SKILLS=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Claudenv Installed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installed:"
echo "   - $SKILLS skills"
echo "   - $COMMANDS commands"
echo ""
echo "🚀 Next steps:"
echo "   1. Start Claude Code: claude"
echo "   2. Run bootstrap: /claudenv"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
