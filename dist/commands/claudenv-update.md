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

**If already up to date (versions match): STOP HERE**

Output this message and do nothing else:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Up to Date
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: X.X.X
Latest version: X.X.X

No updates available.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**IMPORTANT:** Do NOT fetch additional files, do NOT compare file contents, do NOT do anything else. Just output the message above and stop.

---

**If update available (versions differ), show changelog and confirm:**

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
cp -r .claude/commands .claude/skills .claude/scripts .claude/rules "$BACKUP_DIR/"
[ -d .claude/agents ] && cp -r .claude/agents "$BACKUP_DIR/"
[ -d .claude/orchestration ] && cp -r .claude/orchestration "$BACKUP_DIR/"
[ -f .claude/CLAUDE.md ] && cp .claude/CLAUDE.md "$BACKUP_DIR/"
```

### Step 4: Fetch and Apply Updates (Manifest-Based)

**IMPORTANT**: Use manifest-based sync to preserve user-created skills/agents while removing deleted framework files.

```bash
# Download latest
curl -sL https://github.com/nbarthelemy/claudenv/archive/refs/heads/main.tar.gz | tar -xz -C /tmp
```

#### Step 4a: Remove Deprecated and Deleted Framework Files

Read the NEW manifest from downloaded archive and remove:
1. All files listed in `deprecated` array
2. Files that exist locally but are no longer in the new manifest

```bash
# The manifest is at: /tmp/claudenv-main/dist/manifest.json
# It contains:
#   - "files": array of all framework-managed files
#   - "deprecated": array of files to explicitly delete

# Remove deprecated files first
cat /tmp/claudenv-main/dist/manifest.json | jq -r '.deprecated[]' | while read file; do
    rm -f ".claude/$file"
done
```

**CRITICAL**: You must read the manifest and delete ONLY files listed in `deprecated`. Do NOT delete entire directories as that would remove user-created content.

#### Step 4b: Copy Framework Files

Copy each file listed in the manifest's `files` array, creating directories as needed:

```bash
cat /tmp/claudenv-main/dist/manifest.json | jq -r '.files[]' | while read file; do
    mkdir -p ".claude/$(dirname "$file")"
    cp "/tmp/claudenv-main/dist/$file" ".claude/$file"
done

# Also copy these top-level files
cp /tmp/claudenv-main/dist/version.json .claude/version.json
cp /tmp/claudenv-main/dist/manifest.json .claude/manifest.json

# Copy settings.local.json.template if user doesn't have local settings
[ ! -f .claude/settings.local.json ] && [ -f /tmp/claudenv-main/dist/settings.local.json.template ] && \
    cp /tmp/claudenv-main/dist/settings.local.json.template .claude/settings.local.json.template

# Cleanup temp files
rm -rf /tmp/claudenv-main
```

**What This Preserves:**
- User-created skills in `.claude/skills/`
- User-created agents in `.claude/agents/`
- User-created commands in `.claude/commands/`
- All files in `.claude/backups/`, `.claude/logs/`, `.claude/loop/`
- User's `observations.json` and other learning data

**What Gets Updated:**
- All framework files listed in `manifest.json`
- Deprecated files get removed

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
  ✅ [N] agents
  ✅ Rules & templates

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
