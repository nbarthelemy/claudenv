---
description: List all available skills with their trigger keywords and phrases.
allowed-tools: Read, Glob, Bash(*)
---

# /skills:triggers - Skill Discovery

Show all skills and what triggers them.

## Process

1. Find all SKILL.md files in `.claude/skills/`
2. Extract name and description from frontmatter
3. Display in a scannable format

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Available Skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tech-detection
  → tech stack, analyze project, bootstrap, /claudenv

project-interview
  → interview, specification, requirements, /interview

pattern-observer
  → patterns, learnings, automations, /learn:review

autonomous-loop
  → loop, iterate, "keep going until", /loop

lsp-setup
  → lsp, language server, go to definition

meta-skill
  → create skill, unfamiliar technology, extend

frontend-design
  → UI, CSS, Tailwind, "make it look better"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
7 skills available
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Instructions

For each skill found:
1. Read the SKILL.md file
2. Extract the `name` field from frontmatter
3. Extract key trigger words from description
4. Format as: `name` followed by arrow and top 4-6 trigger words

Keep output concise - show just enough triggers to understand what invokes each skill.
