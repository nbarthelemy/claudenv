---
description: Debug hook configuration and execution. Lists all hooks, checks scripts, and shows recent executions.
allowed-tools: Read, Bash(*)
---

# /debug:hooks - Debug Hook Configuration

Debug the hook system to identify configuration issues.

## Checks Performed

### 1. Hook Configuration

Read hooks from `.claude/settings.json`:
- List all configured hook events
- Show matchers and commands

### 2. Script Validation

For each hook script in `.claude/scripts/`:
- Check file exists
- Check executable permission
- Validate shebang line
- Test-run with `--help` or dry-run if supported

### 3. Recent Executions

Check `.claude/logs/hook-executions.log`:
- Last 10 hook executions
- Any failures or errors

### 4. Environment

Check hook environment variables are available

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🪝 Hook Debug
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configured Hooks

### SessionStart
✅ .claude/scripts/session-start.sh
   - Executable: Yes
   - Last run: [date]

### PostToolUse (Write|Edit)
✅ Format command
   - Pattern: Write|Edit
   - Command: echo "..."

### Stop
✅ .claude/scripts/session-end.sh
   - Executable: Yes
   - Last run: [date]

## Script Status

| Script | Exists | Executable | Last Modified |
|--------|--------|------------|---------------|
| session-start.sh | ✅ | ✅ | [date] |
| session-end.sh | ✅ | ✅ | [date] |
| pre-commit.sh | ✅ | ❌ | [date] |

## Recent Executions

[Time] SessionStart - ✅ Success
[Time] PostToolUse - ✅ Success
[Time] Stop - ✅ Success

## Issues Found

⚠️  pre-commit.sh is not executable
   Fix: chmod +x .claude/scripts/pre-commit.sh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Test Hook

To test a specific hook:
```bash
.claude/scripts/[hook-name].sh
```
