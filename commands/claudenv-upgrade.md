---
description: Check for and apply Claudenv infrastructure updates.
allowed-tools: Bash(*), Read, Write, WebFetch
---

# /claudenv:upgrade - Upgrade Infrastructure

Check for updates to the Claudenv framework and apply them.

## Process

1. Read current version from `.claude/version.json`
2. Check for latest version (from source repo)
3. Show what would change
4. Confirm with user
5. Create backup
6. Apply updates
7. Re-run tech detection
8. Update settings
9. Report results

## Version Check

```bash
# Current version
CURRENT=$(cat .claude/version.json | jq -r '.infrastructureVersion')

# Latest version (from GitHub)
LATEST=$(curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/.claude/version.json | jq -r '.infrastructureVersion')

echo "Current: $CURRENT"
echo "Latest: $LATEST"
```

## Output

### Update Available

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Infrastructure Upgrade
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: 1.0.0
Latest version: 1.1.0

## Changes in 1.1.0

- New: Added /debug:performance command
- New: AWS ECS detection
- Fixed: TypeScript formatting hook
- Improved: Interview questions

## Files to Update

~ commands/claudenv.md
~ skills/tech-detection/SKILL.md
+ commands/debug-performance.md
~ scripts/detect-stack.sh

## Upgrade?

This will:
1. Create backup at .claude/backups/pre-upgrade-[timestamp]
2. Update changed files
3. Preserve project-specific settings
4. Re-detect tech stack

Proceed? (Requires confirmation)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Already Up to Date

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Infrastructure Up to Date
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current version: 1.0.0
Latest version: 1.0.0

No updates available.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### After Upgrade

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Upgrade Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Previous version: 1.0.0
New version: 1.1.0

Updated:
- [N] commands
- [N] skills
- [N] scripts

Backup at: .claude/backups/pre-upgrade-[timestamp]

Run /health:check to verify integrity.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
