---
description: Update Claudenv infrastructure to latest version from GitHub.
allowed-tools: Bash, Read, Write, Edit, WebFetch, Glob
---

# /claudenv:update - Update Infrastructure

Quick update of Claudenv infrastructure to get latest fixes and improvements.

## Process

### Step 1: Check Current Version

```bash
cat .claude/version.json 2>/dev/null || echo '{"infrastructureVersion": "0.0.0"}'
```

### Step 2: Fetch Latest Core Files

Fetch these files from the source repo and update locally:

**Critical files to update:**
1. `.claude/settings.json` - Merge permissions (keep user additions, update format)
2. `.claude/skills/tech-detection/command-mappings.json` - Replace entirely
3. `.claude/rules/permissions.md` - Replace entirely
4. `.claude/commands/claudenv.md` - Replace entirely

**Fetch from GitHub:**
```
https://raw.githubusercontent.com/nbarthelemy/claudenv/main/.claude/settings.json
https://raw.githubusercontent.com/nbarthelemy/claudenv/main/.claude/skills/tech-detection/command-mappings.json
https://raw.githubusercontent.com/nbarthelemy/claudenv/main/.claude/rules/permissions.md
```

### Step 3: Merge Settings Intelligently

When updating `settings.json`:

1. Read current local settings
2. Fetch latest settings from repo
3. **Merge strategy:**
   - Take ALL permissions from latest (they use correct format)
   - Add any user-added permissions that aren't duplicates
   - Keep user's custom hooks
   - Keep user's custom env vars

```javascript
// Pseudocode for merge
newSettings = {
  permissions: {
    allow: [...latestPermissions.allow, ...userCustomPermissions],
    deny: [...latestPermissions.deny]
  },
  hooks: localSettings.hooks,  // Preserve user hooks
  env: { ...latestEnv, ...localSettings.env }  // Merge env
}
```

### Step 4: Update Version

Update `.claude/version.json` with new version and timestamp.

### Step 5: Regenerate Project Permissions

Run tech detection to add project-specific permissions:

```bash
bash .claude/scripts/detect-stack.sh
```

Then merge detected tech permissions into settings.json.

### Step 6: Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Updated from: [old version]
Updated to:   [new version]

Files updated:
  ✅ settings.json (permissions format fixed)
  ✅ command-mappings.json
  ✅ permissions.md

Your customizations preserved:
  ✅ Hooks
  ✅ Custom permissions
  ✅ Environment variables

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Quick Mode

If user runs `/claudenv update --quick` or just wants the permissions fix:

1. Only update `settings.json` and `command-mappings.json`
2. Skip version checks
3. Skip tech re-detection

## Error Handling

If fetch fails:
1. Check network connectivity
2. Suggest manual update: "Copy latest from https://github.com/nbarthelemy/claudenv"
3. Don't modify local files if fetch fails
