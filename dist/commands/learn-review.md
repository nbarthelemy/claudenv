---
description: Display all pending observations and proposals from the learning system. Shows skills, hooks, commands, and agents that can be implemented.
allowed-tools: Read, Glob
---

# /learn:review - Review Pending Learnings

Display all pending observations and proposals from the learning agent.

## Process

1. Read and display pending items from:
   - `.claude/learning/pending-skills.md` (includes technology skills)
   - `.claude/learning/pending-commands.md`
   - `.claude/learning/pending-hooks.md`

2. Read recent observations from:
   - `.claude/learning/observations.md` (last 20 entries)

3. Format as actionable summary:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Learning Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Pending Skills ([N])
[List with implement commands - technology skills require approval]

## Pending Commands ([N])
[List with implement commands]

## Pending Hooks ([N])
[List with implement commands]

## Recent Observations ([N])
[Summary of recent patterns detected]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
To implement: /learn:implement [type] [name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Output Format

For each pending item, show:
- Name
- Type (skill/agent/command/hook)
- Occurrences count
- Brief evidence summary
- Implementation command

## Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Learning Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Pending Skills (3)

### Automation Skills
1. **prisma-operations** (3 occurrences)
   Schema changes, migrations, db operations
   → /learn:implement skill prisma-operations

2. **api-error-handling** (4 occurrences)
   Consistent error responses, logging
   → /learn:implement skill api-error-handling

### Technology Skills
3. **stripe-expert** (2 occurrences) ⚠️ Requires approval
   Payment integration, webhooks
   → /learn:implement skill stripe-expert

## Pending Commands (1)

1. **deploy-staging** (4 occurrences)
   Build and deploy to staging environment
   → /learn:implement command deploy-staging

## Pending Hooks (0)

No pending hooks.

## Recent Observations (5)

- TypeScript formatting pattern (5x) → auto-created hook
- Test file creation pattern (2x) → monitoring
- Import organization (3x) → pending skill
- ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
