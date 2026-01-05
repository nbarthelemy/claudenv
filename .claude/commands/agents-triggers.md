---
description: List all available agents with their trigger keywords and phrases.
allowed-tools: Read, Glob, Bash(*)
---

# /agents:triggers - Agent Discovery

Show all agents and what triggers them.

## Process

1. Find all SKILL.md files in `.claude/skills/`
2. Extract name and description from frontmatter
3. Parse TRIGGERS sections for keywords and phrases
4. Display in a scannable format

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 Available Agents
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tech-detection
  → tech stack, detect stack, analyze project, /claudenv

interview-agent
  → interview, specification, requirements, /interview

learning-agent
  → patterns, learnings, observations, /learn:review

loop-agent
  → loop, autonomous, iterate, "keep going until", /loop

lsp-agent
  → lsp, language server, go to definition, find references

meta-agent
  → create skill, create agent, unfamiliar technology

frontend-design
  → UI, UX, CSS, Tailwind, styling, "make it look better"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
7 agents available
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Extraction Commands

```bash
# Find all agents
find .claude/skills -name "SKILL.md" -type f

# Extract name from frontmatter
grep -A1 "^name:" .claude/skills/*/SKILL.md

# Extract TRIGGERS keywords (first line after TRIGGERS - Keywords:)
grep -A1 "TRIGGERS - Keywords:" .claude/skills/*/SKILL.md
```

## Instructions

For each agent found:
1. Read the SKILL.md file
2. Extract the `name` field from frontmatter
3. Find lines containing "TRIGGERS - Keywords:" and extract the first few keywords
4. Format as: `name` followed by arrow and top 4-6 trigger words

Keep output concise - show just enough triggers to understand what invokes each agent.
