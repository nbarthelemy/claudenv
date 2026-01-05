---
description: Update Claudenv infrastructure to latest version from GitHub.
allowed-tools: Bash, Read, Write, Edit, WebFetch, Glob
---

# /claudenv:update - Update Infrastructure

## Step 1: Check for Updates

Run `bash .claude/scripts/check-update.sh` to get version comparison as JSON.

**If error**: Show error message and stop.

**If no update** (`updateAvailable: false`):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Up to Date (v{current})
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
**STOP HERE** - do not proceed with any other steps.

**If update available** (`updateAvailable: true`):
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Update Available: v{current} → v{latest}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Changes: {changelog}

This will backup and update framework files.
Your customizations (hooks, permissions, Project Facts) are preserved.

Proceed with update?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Step 2: Create Backup (after user confirms)

```bash
BACKUP_DIR=".claude/backups/pre-update-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r .claude/settings.json .claude/version.json "$BACKUP_DIR/"
cp -r .claude/commands .claude/skills .claude/scripts .claude/rules "$BACKUP_DIR/" 2>/dev/null || true
[ -d .claude/agents ] && cp -r .claude/agents "$BACKUP_DIR/"
[ -f .claude/CLAUDE.md ] && cp .claude/CLAUDE.md "$BACKUP_DIR/"
echo "Backup: $BACKUP_DIR"
```

## Step 3: Download and Apply Updates

```bash
curl -sL https://github.com/nbarthelemy/claudenv/archive/refs/heads/main.tar.gz | tar -xz -C /tmp
```

Remove deprecated files, then copy framework files from manifest:

```bash
# Remove deprecated
cat /tmp/claudenv-main/dist/manifest.json | jq -r '.deprecated[]' 2>/dev/null | while read file; do
    rm -f ".claude/$file"
done

# Copy framework files
cat /tmp/claudenv-main/dist/manifest.json | jq -r '.files[]' | while read file; do
    mkdir -p ".claude/$(dirname "$file")"
    cp "/tmp/claudenv-main/dist/$file" ".claude/$file"
done

# Copy version and manifest
cp /tmp/claudenv-main/dist/version.json .claude/version.json
cp /tmp/claudenv-main/dist/manifest.json .claude/manifest.json

# Make scripts executable
chmod +x .claude/scripts/*.sh

# Cleanup
rm -rf /tmp/claudenv-main
```

## Step 4: Report Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Updated to v{latest}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Backup: {backup_dir}
Run /health:check to verify.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
