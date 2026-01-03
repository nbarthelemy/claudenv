---
description: Bootstrap Claude Code infrastructure for current project. Detects tech stack, generates permissions, migrates CLAUDE.md, and initializes all systems.
allowed-tools: Bash(*), Write, Edit, Read, Glob, Grep, WebSearch, WebFetch
---

# /claudenv - Infrastructure Bootstrap

You are initializing the Claudenv infrastructure for this project.

## Current Project State

!ls -la
!find . -name "CLAUDE.md" -o -name "claude.md" 2>/dev/null | head -10

## Bootstrap Process

Execute these steps in order:

### Step 1: Detect Tech Stack

Run the tech detection to understand this project:

```bash
.claude/scripts/detect-stack.sh
```

Analyze the output and determine:
- Primary language(s)
- Framework(s)
- Package manager
- Test runner
- Database/ORM
- Deployment targets
- Detection confidence (HIGH/MEDIUM/LOW)

### Step 2: Confidence Check

If detection confidence is LOW or the project appears new/empty:
- Recommend running `/interview` before continuing
- Ask user if they want to proceed with interview or continue with defaults

If detection confidence is HIGH or MEDIUM:
- Continue with bootstrap

### Step 3: Generate project-context.json

Create `.claude/project-context.json` with detected information:

```json
{
  "detected": {
    "languages": ["detected languages"],
    "frameworks": ["detected frameworks"],
    "packageManager": "detected or null",
    "testRunner": "detected or null",
    "database": "detected or null",
    "orm": "detected or null",
    "isMonorepo": false,
    "hasCICD": false,
    "cicdPlatform": null,
    "isContainerized": false,
    "isServerless": false,
    "serverlessPlatform": null,
    "deploymentTargets": [],
    "detectionConfidence": "high|medium|low",
    "needsInterview": false
  },
  "filePatterns": {
    "source": ["detected globs"],
    "test": ["detected globs"],
    "config": ["detected globs"]
  },
  "detectedAt": "ISO_DATE"
}
```

### Step 4: Update settings.json

Based on detected tech stack, merge appropriate permissions into `.claude/settings.json`.

Use the command mappings from `.claude/skills/tech-detection/command-mappings.json` to determine which commands to add.

### Step 5: Migrate CLAUDE.md

Check for existing CLAUDE.md files:
- If found at root: Migrate to `.claude/CLAUDE.md` preserving ALL content
- If found in `.claude/`: Merge new sections with existing
- If multiple found: Consolidate all with clear markers

Follow the rules in `.claude/rules/migration.md` exactly.

### Step 6: Initialize Learning System

Ensure all learning files exist:
- `.claude/learning/observations.md`
- `.claude/learning/pending-agents.md`
- `.claude/learning/pending-skills.md`
- `.claude/learning/pending-commands.md`
- `.claude/learning/pending-hooks.md`

### Step 7: Validate & Report

Run the health check to verify everything is set up correctly:

```bash
.claude/scripts/validate.sh
```

### Final Report

Provide a summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Claudenv Initialized
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📦 Detected Stack:
   - Languages: [list]
   - Frameworks: [list]
   - Package Manager: [name]

🔧 Configured:
   - [N] permissions added
   - CLAUDE.md [migrated/created]
   - Hooks [enabled/disabled]

📚 Available Commands:
   /interview         - Clarify requirements
   /infrastructure:status - System overview
   /health:check      - Verify integrity
   /learn:review      - Review suggestions

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Error Handling

If any step fails:
1. Log the error to `.claude/logs/errors.log`
2. Attempt recovery (up to 3 times)
3. If still failing, inform user and suggest manual steps
