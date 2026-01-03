---
description: Restore infrastructure from a previous backup.
allowed-tools: Bash(*), Read
---

# /backup:restore [id] - Restore From Backup

Restore the `.claude/` infrastructure from a previous backup.

## Usage

```
/backup:restore [backup-id]
```

Without ID, lists available backups.

## Process

### List Backups (no ID provided)

```bash
echo "Available backups:"
ls -la .claude/backups/ | grep -E "^d"
```

### Restore (ID provided)

1. **Verify backup exists**
2. **Create safety backup of current state**
3. **Confirm with user** (destructive operation)
4. **Restore selected backup**
5. **Verify restoration**

## Commands

```bash
BACKUP_ID="$1"
BACKUP_DIR=".claude/backups/$BACKUP_ID"

# Verify exists
if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup not found: $BACKUP_ID"
  exit 1
fi

# Safety backup
SAFETY_BACKUP=".claude/backups/pre-restore-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SAFETY_BACKUP"
rsync -av --exclude='logs' --exclude='backups' .claude/ "$SAFETY_BACKUP/"

# Restore (preserve logs, backups, local settings)
rsync -av --exclude='logs' --exclude='backups' \
  "$BACKUP_DIR/" .claude/
```

## Output

### List Mode

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Available Backups
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. pre-refactor-20260103-100000
   Created: 2026-01-03 10:00:00
   Files: 45

2. backup-20260102-150000
   Created: 2026-01-02 15:00:00
   Files: 42

To restore: /backup:restore [id]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Restore Mode

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Restore Backup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  This will overwrite current infrastructure.

Backup: [id]
Created: [date]
Files: [N]

Safety backup created at:
.claude/backups/pre-restore-[timestamp]/

Proceed with restore? (Requires confirmation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
