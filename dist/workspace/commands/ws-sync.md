---
description: "Sync workspace files to projects and push changes"
allowed-tools: Bash, Read
---

# /ws:sync - Sync Workspace Files

Distribute framework files to projects, commit, and push.

## Usage

```bash
/ws:sync                    # Sync all projects
/ws:sync <project>          # Sync specific project
/ws:sync --no-push          # Sync without pushing
/ws:sync --status           # Show sync status
```

## Process

### 1. Sync Files

```bash
# From workspace root
bash .claude/scripts/sync-project.sh <project|all>
```

### 2. Commit & Push Each Project

For each synced project with a `.git` directory:

```bash
cd <project>
git add .claude/
git diff --cached --quiet || git commit -m "Sync workspace framework updates

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
git push
```

Only commits if there are staged changes. Only stages `.claude/` to avoid bundling unrelated work.

## What Gets Synced

Sync layers (in order):
1. **claudenv base** - Core commands, skills, scripts
2. **workspace common** - Shared workspace rules
3. **stack-specific** - Stack agents, templates, rules
4. **platform-specific** - Platform commands, rules

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Workspace Sync
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ cmdstack  (142 files, pushed)
  ✓ scrimble  (142 files, pushed)
  ✓ monivore  (142 files, pushed)
  ✓ menory    (142 files, pushed)
  ✓ vinote    (142 files, pushed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
