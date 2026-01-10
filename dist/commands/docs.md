---
description: "Update documentation: sync counts, fix syntax, optimize size"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
---

# /docs - Documentation Updater

Systematically review and optimize documentation files one at a time.

## Process

Process each documentation file sequentially. For each file:

1. **Read** the file and count lines
2. **Check** for issues (see rules below)
3. **Edit** to fix issues found
4. **Report** what changed

## Files to Process (in order)

1. `dist/rules/autonomy.md`
2. `dist/rules/permissions.md`
3. `dist/rules/error-recovery.md`
4. `dist/rules/coordination.md`
5. `dist/rules/migration.md`
6. `dist/rules/trigger-reference.md` (regenerate from triggers.json)
7. `dist/rules/claudenv.md`
8. `README.md`

## Optimization Rules

### 1. Size Limits

| File Type | Warning | Max |
|-----------|---------|-----|
| Rule files | 200 lines | 300 lines |
| README.md | 700 lines | 800 lines |

If over warning threshold: Remove redundant content.
If over max: Suggest splitting.

### 2. Syntax Consistency

Fix deprecated colon syntax → space syntax:
- `/cmd:action` → `/cmd action`
- `Bash(npm:*)` → `Bash(npm *)`

### 3. Accuracy

**For README.md**, verify and update:
- Command count in "# XX slash commands" matches `ls dist/commands/*.md | wc -l`
- Skills count matches `ls -d dist/skills/*/ | wc -l`
- Commands table lists all commands in `dist/commands/`

**For trigger-reference.md**, regenerate sections:
- Read `dist/skills/triggers.json` and format as skill triggers
- Read `dist/agents/triggers.json` and format as agent triggers

### 4. Redundancy Elimination

Remove content that is:
- Duplicated verbatim in another file
- Examples that don't add value
- Overly verbose explanations

### 5. Self-Contained

Each rule file should:
- State its purpose in the first paragraph
- Not require reading other files to understand basics
- Use `@rules/filename.md` for detailed cross-references

## Output Format

After processing each file, report:

```
Processing: {filename}
  Lines: {before} → {after} ({change})
  {list of changes made, each prefixed with ✓}
```

At the end:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📄 Documentation Update Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary: {n} files processed, {m} updated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## trigger-reference.md Regeneration

When processing trigger-reference.md:

1. Read `dist/skills/triggers.json`
2. Read `dist/agents/triggers.json`
3. Generate markdown with this structure:

```markdown
# Trigger Reference

> Auto-generated from triggers.json - DO NOT EDIT MANUALLY

## Skill Triggers

### {skill-name}
**Keywords:** {comma-separated keywords or "none"}
**Phrases:** {comma-separated phrases in quotes}

## Agent Triggers

### {agent-name}
**Keywords:** {comma-separated keywords}
**Phrases:** {comma-separated phrases in quotes}
**File patterns:** {comma-separated patterns, if present}

## Matching Rules

1. **Case-insensitive** - match regardless of capitalization
2. **Partial match** - trigger phrase can be part of larger request
3. **Multiple matches** - if multiple skills/agents match, prefer the most specific
4. **Skills vs Agents** - Skills run in main context; Agents run as subagents via Task tool

## Invocation

- **Skills**: Use the `Skill` tool with the skill name
- **Agents**: Use the `Task` tool with `subagent_type` matching the agent name
```
