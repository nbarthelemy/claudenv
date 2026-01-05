#!/bin/bash
# Claudenv Installer
# Usage: curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/install.sh | bash

set -e

REPO_URL="https://github.com/nbarthelemy/claudenv"
BRANCH="main"
TARGET=".claude"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claudenv Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check for existing .claude directory
EXISTING_CLAUDE_MD=""
if [ -d "$TARGET" ]; then
    echo ""
    echo "Found existing .claude directory"

    # Preserve existing CLAUDE.md content
    if [ -f "$TARGET/CLAUDE.md" ]; then
        EXISTING_CLAUDE_MD=$(cat "$TARGET/CLAUDE.md")
        echo "  - Will preserve your CLAUDE.md content"
    fi

    # Backup existing settings.local.json
    if [ -f "$TARGET/settings.local.json" ]; then
        cp "$TARGET/settings.local.json" /tmp/claudenv-settings-local.json.bak
        echo "  - Will preserve settings.local.json"
    fi

    echo ""
    read -p "Update claudenv infrastructure? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
    fi
fi

echo ""
echo "Downloading Claudenv..."

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Download and extract
if command -v curl &> /dev/null; then
    curl -sL "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
elif command -v wget &> /dev/null; then
    wget -qO- "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
else
    echo "Error: curl or wget required"
    exit 1
fi

EXTRACTED="$TEMP_DIR/claudenv-${BRANCH}"

# Create .claude directory if it doesn't exist
mkdir -p "$TARGET"

# Copy distributable files from dist/ directory
echo "Installing claudenv framework..."

DIST="$EXTRACTED/dist"

# Copy directories
for dir in commands skills rules scripts templates learning; do
    if [ -d "$DIST/$dir" ]; then
        rm -rf "$TARGET/$dir"
        cp -r "$DIST/$dir" "$TARGET/$dir"
    fi
done

# Copy config files
cp "$DIST/settings.json" "$TARGET/settings.json"
cp "$DIST/version.json" "$TARGET/version.json"
[ -f "$DIST/settings.local.json.template" ] && cp "$DIST/settings.local.json.template" "$TARGET/settings.local.json.template"

# Restore settings.local.json if it was backed up
if [ -f /tmp/claudenv-settings-local.json.bak ]; then
    mv /tmp/claudenv-settings-local.json.bak "$TARGET/settings.local.json"
fi

# Create empty directories for user data
mkdir -p "$TARGET/logs"
mkdir -p "$TARGET/backups"
mkdir -p "$TARGET/loop"

# Make scripts executable
chmod +x "$TARGET/scripts/"*.sh 2>/dev/null || true

# Handle CLAUDE.md - preserve user content, add claudenv import
if [ -n "$EXISTING_CLAUDE_MD" ]; then
    # Check if already has claudenv import
    if echo "$EXISTING_CLAUDE_MD" | grep -q "@rules/claudenv.md"; then
        # Already has import, just restore the file
        echo "$EXISTING_CLAUDE_MD" > "$TARGET/CLAUDE.md"
    else
        # Add claudenv import to existing content
        cat > "$TARGET/CLAUDE.md" << EOF
$EXISTING_CLAUDE_MD

## Claudenv Framework

@rules/claudenv.md
EOF
    fi
    echo "  - Preserved your CLAUDE.md, added framework import"
else
    # Create new CLAUDE.md with import
    cat > "$TARGET/CLAUDE.md" << 'EOF'
# Project Instructions

<!-- Add your project-specific instructions here -->

## Claudenv Framework

@rules/claudenv.md
EOF
    echo "  - Created CLAUDE.md with framework import"
fi

# Count what was installed
SKILLS=$(find "$TARGET/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
COMMANDS=$(find "$TARGET/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claudenv Installed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  $SKILLS skills"
echo "  $COMMANDS commands"
echo ""
echo "Next steps:"
echo "  1. Start Claude Code: claude"
echo "  2. Run bootstrap: /claudenv"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
