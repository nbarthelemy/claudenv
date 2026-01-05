---
description: Update Claudenv infrastructure to latest version from GitHub.
allowed-tools: Bash, Read, Write, Edit, WebFetch, Glob
---

# /claudenv:update - Update Infrastructure

Update Claudenv infrastructure to the latest version.

## Process

### Step 1: Check Versions

```bash
# Current version
CURRENT=$(cat .claude/version.json | jq -r '.infrastructureVersion')

# Latest version (from GitHub)
LATEST=$(curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/dist/version.json | jq -r '.infrastructureVersion')

echo "Current: $CURRENT"
echo "Latest: $LATEST"
```

### Step 2: Compare and Report

**If already up to date:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Up to Date
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: 2.2.0
Latest version: 2.2.0

No updates available.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**If update available, show changelog and confirm:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Claudenv Update Available
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: 2.1.0
Latest version: 2.2.0

## Changes in 2.2.0

- Add /reflect command for session reflection
- Add automatic correction capture
- Add Project Facts section in CLAUDE.md

## This Will:

1. Create backup at .claude/backups/pre-update-[timestamp]
2. Update all framework files
3. Preserve your customizations:
   - Hooks
   - Custom permissions
   - Environment variables
   - Project Facts
   - CLAUDE.md content
4. Re-detect tech stack

Proceed? (Requires confirmation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 3: Create Backup

```bash
BACKUP_DIR=".claude/backups/pre-update-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r .claude/settings.json .claude/version.json "$BACKUP_DIR/"
cp -r .claude/commands .claude/skills .claude/scripts "$BACKUP_DIR/"
[ -f .claude/CLAUDE.md ] && cp .claude/CLAUDE.md "$BACKUP_DIR/"
```

### Step 4: Fetch and Apply Updates

```bash
# Download latest
curl -sL https://github.com/nbarthelemy/claudenv/archive/refs/heads/main.tar.gz | tar -xz -C /tmp

# Update directories
for dir in commands skills rules scripts templates learning; do
    rm -rf ".claude/$dir"
    cp -r "/tmp/claudenv-main/dist/$dir" ".claude/$dir"
done

# Update version
cp "/tmp/claudenv-main/dist/version.json" ".claude/version.json"

# Cleanup
rm -rf /tmp/claudenv-main
```

### Step 5: Merge Settings

Preserve user customizations when updating settings.json:

1. Read current local settings
2. Read latest settings from downloaded files
3. **Merge strategy:**
   - Take ALL permissions from latest (correct format)
   - Add user's custom permissions (not duplicates)
   - Keep user's hooks entirely
   - Keep user's env vars

```javascript
// Pseudocode
newSettings = {
  permissions: {
    allow: [...latestPermissions.allow, ...userCustomPermissions],
    deny: [...latestPermissions.deny]
  },
  hooks: localSettings.hooks,  // Preserve entirely
  env: { ...latestEnv, ...localSettings.env }
}
```

### Step 6: Preserve CLAUDE.md

If `.claude/CLAUDE.md` exists:
1. Read current content
2. Check for `## Project Facts` section
3. Preserve Project Facts and any user content
4. Ensure `@rules/claudenv.md` import exists

### Step 7: Re-detect Tech Stack

```bash
bash .claude/scripts/detect-stack.sh
```

Merge detected tech permissions into settings.json.

### Step 8: Make Scripts Executable

```bash
chmod +x .claude/scripts/*.sh
```

### Step 9: Report Results

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Previous version: 2.1.0
New version: 2.2.0

Updated:
  ✅ [N] commands
  ✅ [N] skills
  ✅ [N] scripts

Preserved:
  ✅ Hooks
  ✅ Custom permissions
  ✅ Environment variables
  ✅ Project Facts
  ✅ CLAUDE.md content

Backup at: .claude/backups/pre-update-[timestamp]

Run /health:check to verify integrity.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

If fetch fails:
1. Check network connectivity
2. Don't modify local files
3. Suggest: "Download manually from https://github.com/nbarthelemy/claudenv"

If backup fails:
1. Abort update
2. Report error
3. Don't modify any files

## Rollback

If something goes wrong after update:

```bash
# Find latest backup
ls -la .claude/backups/

# Restore from backup
cp -r .claude/backups/pre-update-[timestamp]/* .claude/
```
