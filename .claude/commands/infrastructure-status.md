---
description: Display full Claudenv infrastructure status overview including detected stack, skills, commands, hooks, and pending proposals.
allowed-tools: Read, Glob, Bash(*)
---

# /infrastructure:status - System Overview

Display comprehensive status of the Claudenv infrastructure.

## Process

1. Read `.claude/project-context.json` for detected tech
2. Read `.claude/SPEC.md` for specification status
3. Count and list agents/skills
4. Count and list commands
5. Check hook status
6. Summarize pending proposals
7. Verify settings validity

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏗️  Claudenv Infrastructure Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Project Context

📦 **Detected Stack:**
   Languages: [list]
   Frameworks: [list]
   Package Manager: [name]
   Cloud Platforms: [list]
   Detection Confidence: [HIGH/MEDIUM/LOW]

📋 **Specification:** [Complete/Incomplete/Missing]
   Last updated: [date]

## Infrastructure Components

🤖 **Skills:** [N] active
   - tech-detection
   - interview-agent
   - learning-agent
   - meta-agent
   - [project-specific skills...]

📝 **Commands:** [N] available
   /claudenv, /interview, /infrastructure:status, ...

🪝 **Hooks:** [Enabled/Disabled]
   - SessionStart: [active/inactive]
   - PostToolUse: [active/inactive]
   - Stop: [active/inactive]

📚 **Learning:**
   - Observations: [N] logged
   - Pending skills: [N]
   - Pending agents: [N]
   - Pending commands: [N]
   - Pending hooks: [N]

## Permissions Summary

✅ Allowed: [N] tool patterns
❌ Denied: [N] patterns
🔧 Bash commands: [N] allowed

## Health

[✅/⚠️/❌] Settings valid
[✅/⚠️/❌] All skills have SKILL.md
[✅/⚠️/❌] Hooks executable
[✅/⚠️/❌] Learning files exist

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Version: [from version.json]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Commands to Gather Data

```bash
# Count skills
find .claude/skills -name "SKILL.md" | wc -l

# Count commands
find .claude/commands -name "*.md" | wc -l

# Check settings
cat .claude/settings.json | jq '.hooks'

# Count observations
grep -c "^## " .claude/learning/observations.md
```
