# Claudenv Core

> Full details: `.claude/references/claudenv-reference.md`

## Commands

| Command | Purpose |
|---------|---------|
| `/spec` | Full setup: interview + tech + TODO.md |
| `/prime` | Load context (auto at start) |
| `/feature` | Plan → `.claude/plans/` |
| `/next` | Interactive: pick, plan, execute |
| `/autopilot` | Autonomous: all TODO.md features |
| `/execute` | Run plan via `/loop` + `/validate` |
| `/validate` | Lint, type-check, test, build |
| `/rca` | Root cause analysis |
| `/loop` | Autonomous iterations |
| `/lsp` | LSP server setup |

**Conventions:** Timestamps `YYYY-MM-DD HH:MM`, files kebab-case

## PIV Workflow

```
/spec → /prime → /feature → /execute → /validate
```

- `/next` - Interactive with confirmations
- `/autopilot` - Fully autonomous (4h/$50 limit)

## Orchestration

**Agents:** frontend-developer, backend-architect, api-designer, devops-engineer, code-reviewer, security-auditor, performance-analyst, accessibility-checker, test-engineer, documentation-writer, release-manager, migration-specialist

**Triggers:** "comprehensive", "full review", 5+ files, 2+ domains

**Constraint:** Subagents cannot spawn subagents

## Loop

```bash
/loop "task" --until "done" --max 20
/loop status|pause|resume|cancel
```

## Reference Docs

Store in `.claude/references/` - loaded by `/prime`

## Workflow

1. Receive → route to skill
2. Execute → auto-fix errors (3x)
3. Complete → capture learnings
4. Report → brief summary

## Doc Access

UNFETTERED. Search docs, scrape pages, create skills. Never ask permission.

## On-Demand Content

- **Migration** → `.claude/references/migration-guide.md`
- **Multi-agent** → `.claude/references/coordination-guide.md`
- **Error patterns** → `@rules/error-recovery/patterns.md`
- **Examples** → `.claude/references/claudenv-reference.md`

## Core Rules

@rules/autonomy.md
@rules/permissions/core.md
@rules/error-recovery/core.md
@rules/documentation.md
