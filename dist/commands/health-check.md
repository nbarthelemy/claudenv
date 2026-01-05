---
description: Verify Claudenv infrastructure integrity. Validates settings, skills, hooks, and learning files.
allowed-tools: Read, Glob, Bash(*)
---

# /health:check - Verify Infrastructure Integrity

Run comprehensive health checks on the Claudenv infrastructure.

## Checks Performed

### 1. Settings Validation

- [ ] `.claude/settings.json` exists
- [ ] Settings is valid JSON
- [ ] Permissions structure is correct
- [ ] Hooks structure is correct (if present)

### 2. Skill Validation

For each skill in `.claude/skills/`:
- [ ] Has `SKILL.md` file
- [ ] SKILL.md has valid frontmatter (name, description, allowed-tools)
- [ ] Tools listed are appropriate

### 3. Command Validation

For each command in `.claude/commands/`:
- [ ] Has valid frontmatter (description)
- [ ] File is not empty

### 4. Hook Validation

- [ ] Shell scripts in `.claude/scripts/` are executable
- [ ] Hook commands reference existing scripts

### 5. Learning Files

- [ ] `.claude/learning/observations.md` exists
- [ ] `.claude/learning/pending-skills.md` exists
- [ ] `.claude/learning/pending-commands.md` exists
- [ ] `.claude/learning/pending-hooks.md` exists

### 6. Project Context

- [ ] `.claude/project-context.json` exists (warn if not)
- [ ] Context is valid JSON

### 7. Version

- [ ] `.claude/version.json` exists
- [ ] Version is valid JSON

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏥 Health Check Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Settings
✅ settings.json valid
✅ Permissions configured
✅ Hooks configured

## Skills ([N] total)
✅ tech-detection - valid
✅ interview-agent - valid
✅ learning-agent - valid
✅ meta-agent - valid

## Commands ([N] total)
✅ All commands valid

## Hooks
✅ session-start.sh executable
✅ session-end.sh executable
⚠️  pre-commit.sh not executable (run: chmod +x)

## Learning
✅ All learning files present

## Project Context
⚠️  project-context.json missing (run /claudenv)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Summary: [N] passed, [N] warnings, [N] errors
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Auto-Fix Options

For fixable issues, offer:
- Make scripts executable: `chmod +x .claude/scripts/*.sh`
- Create missing learning files
- Initialize project-context.json
