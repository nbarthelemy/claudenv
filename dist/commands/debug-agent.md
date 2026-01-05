---
description: Debug a specific skill/agent - check configuration, triggers, permissions, and recent invocations.
allowed-tools: Read, Glob, Grep
---

# /debug:agent [name] - Debug Skill/Agent

Debug a specific skill or agent to identify configuration issues.

## Usage

```
/debug:agent [skill-name]
```

Example: `/debug:agent interview-agent`

## Checks Performed

### 1. File Existence

- Check if `.claude/skills/[name]/SKILL.md` exists
- List all files in skill directory

### 2. Frontmatter Validation

Verify SKILL.md has:
- `name` - matches directory name
- `description` - contains trigger keywords
- `allowed-tools` - valid tool list
- `model` (optional) - valid model name

### 3. Trigger Analysis

- Extract keywords from description
- Show what phrases would activate this skill
- Check for conflicts with other skills

### 4. Permission Check

- Verify tools in `allowed-tools` are permitted in settings.json
- Flag any tools that would be blocked

### 5. Recent Activity

- Check `.claude/logs/` for recent invocations
- Show last 5 uses of this skill

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 Debug: [skill-name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Configuration

📁 Location: .claude/skills/[name]/
📄 Files: SKILL.md, [other files]

## Frontmatter

name: [value] ✅
description: [value] ✅
allowed-tools: [list] ✅
model: [value] ✅

## Triggers

This skill activates on:
- "[keyword 1]"
- "[keyword 2]"
- "[keyword 3]"

## Permissions

✅ Read - allowed
✅ Write - allowed
✅ Bash(*) - allowed
⚠️  WebFetch - requires approval

## Recent Invocations

[Date] - [Task summary]
[Date] - [Task summary]
[Date] - [Task summary]

## Issues Found

[✅ No issues / ⚠️ Warnings / ❌ Errors]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
