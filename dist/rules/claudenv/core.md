# Claudenv Framework (Core)

> Essential rules for autonomous development

## Quick Reference

| Command | Purpose |
|---------|---------|
| `/spec` | Full setup: interview + tech detect + CLAUDE.md + TODO.md |
| `/prime` | Load project context (auto-runs at session start) |
| `/feature <name>` | Plan feature → `.claude/plans/` |
| `/next` | Interactive: pick, plan, execute with confirmations |
| `/autopilot` | Autonomous: complete all TODO.md features |
| `/execute <plan>` | Execute plan via `/loop --plan` + `/validate` |
| `/validate` | Stack-aware validation (lint, type-check, test, build) |
| `/rca <issue>` | Root cause analysis for bugs |
| `/claudenv` | Bootstrap infrastructure |
| `/loop` | Autonomous iterative development |
| `/lsp` | Auto-detect/install LSP servers |

**Conventions:**
- Timestamps: `YYYY-MM-DD HH:MM` (24-hour local)
- File naming: kebab-case

---

## PIV Workflow (Prime-Implement-Validate)

```
/spec → /prime → /feature → /execute → /validate
         │                      │
         └── auto at start      └── calls /loop --plan + /validate
```

**Workflow modes:**
- `/next` - Interactive with confirmations
- `/autopilot` - Fully autonomous (4h max, $50 max cost)

### Key Commands

**`/spec`** - Project initialization:
1. Run `/interview` for deep questioning
2. Detect tech stack
3. Refine CLAUDE.md with project rules
4. Extract features from SPEC.md → TODO.md

**`/prime`** - Load context (auto-runs at session start):
- Project structure & tech stack
- Documentation (CLAUDE.md, SPEC.md, README)
- Reference materials (`.claude/references/`)
- Git state & active work

**`/feature`** - Create implementation plan:
- Outputs to `.claude/plans/{slug}.md`
- Contains: overview, phases, tasks, testing, acceptance criteria

**`/execute`** - Thin orchestrator:
1. Calls `/loop --plan <file>` to execute
2. Runs `/validate` after completion
3. Updates TODO.md on success

**`/validate`** - Stack-aware validation:
- Auto-detects: lint, type-check, test, build
- Flags: `--fix`, `--quick`

**`/rca`** - Root cause analysis:
- Creates `.claude/rca/{slug}.md`
- Contains: summary, root cause, impact, fix strategy, testing

---

## Orchestration

### Built-in Agents

| Category | Agents |
|----------|--------|
| **Code** | frontend-developer, backend-architect, api-designer, devops-engineer |
| **Analysis** | code-reviewer, security-auditor, performance-analyst, accessibility-checker |
| **Process** | test-engineer, documentation-writer, release-manager, migration-specialist |

### Triggers

Agents auto-spawn for:
- **Keywords:** "comprehensive", "full review", "across codebase", "refactor all"
- **Complexity:** 5+ files, 2+ domains, 4+ steps
- **Explicit:** User requests parallel execution

**Tech-specific agents** created during `/claudenv` for detected stack (React → react-specialist, etc.)

**Constraint:** Subagents cannot spawn subagents (flat hierarchy)

---

## Autonomous Loop

```bash
/loop "task" --until "condition" --max 20
/loop status | pause | resume | cancel
```

**Completion options:**
- `--until "<text>"` - Exit when output contains phrase
- `--until-exit <code>` - Exit on specific exit code
- `--until-regex "<pattern>"` - Exit on regex match

**Safety limits:**
- `--max <n>` - Max iterations (default: 20)
- `--max-time <duration>` - Max time (default: 2h)
- `--max-cost <amount>` - Max estimated cost

---

## LSP Code Intelligence

Language servers **auto-install** during `/claudenv` and when new languages detected.

**Commands:** `/lsp` (install), `/lsp status` (check)

**Operations:** goToDefinition, findReferences, hover, documentSymbol, workspaceSymbol

LSP preferred over grep for code navigation.

---

## Reference Documentation

Store best practices in `.claude/references/` - loaded by `/prime`:
- Framework patterns (e.g., `react-best-practices.md`)
- Project conventions (e.g., `testing-strategy.md`)
- Anti-patterns to avoid

---

## Workflow

1. **Receive task** → Route to skill if specialized
2. **Execute** → Use tools freely, auto-fix errors (3 retries)
3. **Complete** → Capture learnings
4. **Report** → Brief summary

---

## Documentation Access

**UNFETTERED access** to documentation. When encountering unfamiliar tech:
1. Search for official docs
2. Scrape relevant pages
3. Create specialized skill if needed
4. Proceed with implementation

Never ask permission to consult documentation.

---

## Conditional Rules

When specific scenarios arise, load additional rules:

- **Migration scenarios** → Read `@rules/migration.md` before running `/claudenv`
- **Multi-agent coordination** → Read `@rules/coordination.md` before `/loop` with multiple terminals
- **Orchestration decisions** → Orchestrator skill reads `@rules/triggers/reference.json`
- **Error patterns** → Read `@rules/error-recovery/patterns.md` when encountering unfamiliar errors
- **Detailed examples** → Read `@rules/claudenv/reference.md` when needed

---

## Core Rules

@rules/autonomy.md
@rules/permissions/core.md
@rules/error-recovery/core.md
@rules/documentation.md
