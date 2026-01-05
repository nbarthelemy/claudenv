---
description: Implement a pending proposal from the learning system. Creates skills, hooks, commands, or agents based on observed patterns.
allowed-tools: Read, Write, Edit, Bash(*), Glob
---

# /learn:implement - Implement Learning Proposal

Implement a pending proposal from the learning system.

## Usage

```
/learn:implement [type] [name]
```

**Types:**
- `skill` - Create a new skill (technology skills invoke meta-agent)
- `command` - Create a new command
- `hook` - Create/update hook configuration

## Process

### For Skills

1. Read proposal from `.claude/learning/pending-skills.md`
2. Check skill type:
   - **Automation skills** (type: automation): Auto-create
   - **Technology skills** (type: technology): Requires user confirmation, invoke meta-agent
3. Create skill directory: `.claude/skills/[name]/`
4. Create `SKILL.md` with:
   - Appropriate triggers from observed patterns
   - Tools based on what was used
   - Instructions based on observed behavior
5. Update status in pending file
6. Notify: "✅ Created skill: [name]"

### For Commands

1. Read proposal from `.claude/learning/pending-commands.md`
2. Create command file: `.claude/commands/[name].md`
3. Include:
   - Description from observed usage
   - Steps based on observed sequences
   - Appropriate tool permissions
4. Update status in pending file
5. Notify: "✅ Created command: /[name]"

### For Hooks

1. Read proposal from `.claude/learning/pending-hooks.md`
2. Update `.claude/settings.json` hooks section
3. Update status in pending file
4. Notify: "✅ Created hook: [name]"

## Example

```
User: /learn:implement skill prisma-operations

Claude: Reading proposal for prisma-operations...

Creating skill at .claude/skills/prisma-operations/SKILL.md

Skill created with:
- Triggers: prisma, schema, migration, database
- Tools: Bash(prisma:*), Read, Write, Edit
- Based on 3 observed occurrences

✅ Created skill: prisma-operations

The skill will now auto-invoke when you work with Prisma.
```

## Validation

Before implementing, verify:
- [ ] Proposal exists in pending file
- [ ] Pattern has sufficient evidence
- [ ] No duplicate skill/command exists
- [ ] Tools requested are appropriate
