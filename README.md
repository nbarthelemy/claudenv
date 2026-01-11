# Claudenv

> Complete Claude Code infrastructure for autonomous development

Claudenv is a cloneable framework that bootstraps comprehensive Claude Code infrastructure for any project. It provides:

- **Autonomous operation** with configurable permission levels
- **Autonomous loops** for persistent, iterative development (like Ralph Wiggum)
- **Tech stack detection** for 50+ languages, frameworks, and cloud platforms
- **Project specification interviews** to clarify architecture and requirements
- **Learning system** that observes patterns and suggests automations
- **Frontend design expertise** with anti-AI-slop design principles
- **Auto-LSP setup** with official Anthropic plugins + 25+ language servers
- **Self-extending** via meta-agent that creates new skills for unfamiliar tech
- **Subagent orchestration** for automatic parallel task execution with specialist agents

## Quick Start

### Option 1: Installer (Recommended)

```bash
# Run from your project directory
curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/bin/install | bash

# Start Claude and bootstrap
claude
> /ce:init
```

The installer:
- Creates `.claude/` with all framework files
- **Preserves your existing CLAUDE.md** (adds import, never overwrites)
- Preserves `settings.local.json` if present

### Option 2: Git Clone

```bash
# Clone the repo
git clone --depth 1 https://github.com/nbarthelemy/claudenv.git /tmp/claudenv

# Copy dist/ contents to .claude/
mkdir -p .claude
cp -r /tmp/claudenv/dist/* .claude/

# Clean up
rm -rf /tmp/claudenv

# Add framework import to your CLAUDE.md
echo -e "\n@rules/claudenv.md" >> .claude/CLAUDE.md
```

## Repository Structure

```
claudenv/
├── CLAUDE.md          # Dev instructions (NOT distributed to users)
├── README.md          # This file
├── bin/install        # User installer script
├── LICENSE
├── .claude/           # Symlinks for self-dogfooding
└── dist/              # Distributable content → user's .claude/
    ├── settings.json
    ├── version.json
    ├── rules/
    │   ├── claudenv/
    │   │   ├── core.md       # Core framework rules (always loaded)
    │   │   └── reference.md  # Detailed examples (on-demand)
    │   ├── permissions/
    │   │   └── core.md       # Permission matrix
    │   ├── error-recovery/
    │   │   ├── core.md       # Recovery protocol
    │   │   └── patterns.md   # Error patterns (on-demand)
    │   ├── triggers/
    │   │   └── reference.json # Skill/agent triggers
    │   ├── autonomy.md
    │   ├── coordination.md    # Multi-agent coordination
    │   ├── migration.md       # CLAUDE.md migration rules
    │   └── documentation.md
    ├── commands/              # 24 slash commands
    ├── skills/                # 10 auto-invoked skills
    ├── scripts/               # Automation scripts
    └── ...
```

When you install claudenv, the contents of `dist/` are copied to your project's `.claude/` directory.

### Token-Optimized Architecture

Framework rules use a **namespaced structure with conditional loading** to minimize context pollution:

- **Core Rules (~2.8k tokens):** Always loaded, essential for all operations
- **Conditional Rules (~5.1k tokens):** Loaded only when explicitly needed
- **Total Reduction:** 76% smaller than monolithic approach

**Conditional loading examples:**
- `migration.md` - Loaded by `/ce:init` before migrating files
- `coordination.md` - Loaded by `/ce:loop --track` for multi-agent work
- `error-recovery/patterns.md` - Loaded when encountering unfamiliar errors
- `triggers/reference.json` - Loaded by orchestrator for routing decisions

## What You Get

### Commands

| Command | Description |
|---------|-------------|
| `/ce:spec` | Full project setup: interview, tech detect, CLAUDE.md, TODO.md |
| `/ce:prime` | Load comprehensive project context (auto-runs at session start) |
| `/ce:feature <name>` | Plan a feature, save to `.claude/plans/` |
| `/ce:next` | Interactive feature workflow - pick, plan, execute with confirmations |
| `/ce:autopilot` | Fully autonomous feature completion from TODO.md |
| `/ce:execute <plan>` | Execute plan via `/ce:loop --plan` + `/ce:validate` |
| `/ce:validate` | Stack-aware validation: lint, type-check, test, build |
| `/ce:rca <issue>` | Root cause analysis for bugs |
| `/ce:backlog` | Send current or specified task to the backlog |
| `/ce:init` | Bootstrap infrastructure for current project |
| `/ce:admin` | Admin commands: status, update, audit, export, import, mcp |
| `/ce:interview` | Conduct project specification interview |
| `/ce:loop` | Autonomous loop: start, status, pause, resume, cancel, history |
| `/ce:loop --plan <file>` | Execute structured plan file (phases/tasks) |
| `/ce:lsp` | LSP management: install, status |
| `/ce:health` | Verify infrastructure integrity |
| `/ce:learn` | Learning system: review, implement |
| `/ce:reflect` | Consolidate learnings, update project knowledge |
| `/ce:reflect evolve` | Analyze failures and propose system improvements |
| `/ce:patterns` | Force pattern analysis |
| `/ce:triggers` | List skill and agent triggers |
| `/ce:backup` | Backup management: create, restore, list |
| `/ce:autonomy` | Autonomy control: pause, resume |
| `/ce:debug` | Debug tools: hooks, agent |
| `/ce:docs` | Documentation review and optimization |
| `/ce:shipit` | Release: version bump, commit, push |

### Skills (Auto-Invoked)

| Skill | Purpose |
|-------|---------|
| `tech-detection` | Detects project stack and configures permissions |
| `project-interview` | Conducts specification interviews |
| `pattern-observer` | Observes patterns, consolidates learnings, suggests automations |
| `meta-skill` | Creates new skills for unfamiliar technologies |
| `skill-creator` | Scaffolds and validates skill directories |
| `frontend-design` | Creates distinctive, production-grade UI |
| `autonomous-loop` | Manages iterative development loops |
| `lsp-setup` | Auto-detects and installs language servers |
| `orchestrator` | Orchestrates complex tasks with parallel subagent execution |
| `agent-creator` | Creates specialist subagents for detected technologies |

### Starter Agents

12 built-in specialist agents for parallel task execution:

| Category | Agents |
|----------|--------|
| **Code** | `frontend-developer`, `backend-architect`, `api-designer`, `devops-engineer` |
| **Analysis** | `code-reviewer`, `security-auditor`, `performance-analyst`, `accessibility-checker` |
| **Process** | `test-engineer`, `documentation-writer`, `release-manager`, `migration-specialist` |

### Detected Technologies

**Languages:** JavaScript, TypeScript, Python, Ruby, Go, Rust, PHP, Java, C#, Swift, Kotlin

**Frameworks:** Next.js, Nuxt, React, Vue, Angular, Svelte, Astro, Remix, Express, Fastify, NestJS, Django, Flask, FastAPI, Rails

**Cloud Platforms:** AWS, GCP, Azure, Heroku, Vercel, Netlify, Fly.io, Railway, DigitalOcean, Cloudflare, Supabase, Firebase

**Databases:** PostgreSQL, MySQL, MongoDB, Redis, SQLite, Prisma, Drizzle, TypeORM

## Installed Structure (Your Project)

After installation, your project's `.claude/` directory contains:

```
your-project/
└── .claude/
    ├── CLAUDE.md           # Your instructions + @rules/claudenv.md import
    ├── settings.json       # Permissions & hooks
    ├── version.json        # Framework version
    ├── rules/
    │   ├── claudenv.md     # Framework instructions (imported)
    │   ├── autonomy.md     # Autonomy definitions
    │   ├── permissions.md  # Permission matrix
    │   └── ...
    ├── commands/           # 24 slash commands
    ├── skills/             # 10 auto-invoked skills
    ├── agents/             # 12 specialist subagents
    ├── orchestration/      # Orchestration config
    ├── scripts/            # Automation scripts
    ├── templates/          # Generation templates
    ├── learning/           # Pattern observations
    ├── loop/               # Loop state & history
    ├── logs/               # Execution logs
    └── backups/            # Auto-backups
```

**Key point:** Your project instructions stay in `CLAUDE.md`. Framework instructions are imported via `@rules/claudenv.md`, so updates never overwrite your content.

## Autonomy Levels

### High (Default)

Claude operates with maximum independence:
- Full file read/write access
- Run any non-destructive command
- All local git operations
- Install dev dependencies
- Create skills and automations
- Auto-fix errors (3 retries)

### What Requires Approval

Even at high autonomy:
- Push to remote repositories
- Deploy to any environment
- Access secrets/credentials
- Modify CI/CD pipelines
- Database migrations on remote
- Publish packages

## How It Works

### 1. Bootstrap (`/ce:init`)

When you run `/ce:init`, the framework:
1. Runs tech detection script
2. Analyzes confidence level (HIGH/MEDIUM/LOW)
3. **Auto-runs `/ce:interview` if confidence is LOW**
4. Generates `project-context.json`
5. Updates `settings.json` with tech-specific permissions
6. Migrates existing CLAUDE.md (preserving all content)
7. Initializes learning system
8. Installs LSP servers (plugins first, then binaries)
9. **Validates all required files were created**
10. Runs health check

**Post-Init Validation:** The bootstrap verifies all required files, directories, and configurations exist before reporting success. Missing items are auto-created.

### 2. Interview (`/ce:interview`)

For new projects or unclear requirements:
1. Silently reads all existing documentation
2. Analyzes codebase for existing decisions
3. Asks targeted questions (one at a time)
4. Provides researched options with tradeoffs
5. Creates comprehensive `SPEC.md`
6. Updates project context

### 3. Learning & Reflection

The learning system continuously observes, captures corrections, and consolidates:

**Pattern Observer:**
1. Observes development patterns silently
2. Uses MERGE/REPLACE operations (not just ADD) to avoid bloat
3. Auto-creates skills/hooks at threshold (3 occurrences)
4. Proposes skills for new technologies (2 occurrences)

**Automatic Correction Capture:**
When you correct Claude about project details, facts are auto-captured:
```
User: "no, we use pnpm not npm"
Claude: 📝 Noted: Uses pnpm, not npm
```

Facts are stored in `## Project Facts` section of CLAUDE.md, categorized by:
- **Tooling** - Package managers, build tools, test runners
- **Structure** - File locations, directory conventions
- **Conventions** - Coding standards, naming conventions
- **Architecture** - Design patterns, system structure

**Session Reflection (`/ce:reflect`):**
```bash
/ce:reflect        # Quick reflection on current session
/ce:reflect deep   # Comprehensive review of all learnings
/ce:reflect prune  # Remove stale/obsolete entries
/ce:reflect facts  # Review and consolidate Project Facts
```

Core philosophy:
- "Merge over add — consolidate, don't accumulate"
- "Specific over vague — skip insights that aren't actionable"
- "Accurate over comprehensive — wrong info is worse than missing"

### 4. PIV Workflow (Prime-Implement-Validate)

A structured approach to feature development:

```
/ce:spec → /ce:prime → /ce:feature → /ce:execute → /ce:validate
         │                      │
         │                      └── calls /ce:loop --plan + /ce:validate
         │
         └── auto-runs at session start
```

**Workflow Options:**
- **Interactive**: `/ce:next` - Pick features, confirm each step
- **Autonomous**: `/ce:autopilot` - Complete all features without interaction

**`/ce:spec` - Project Setup:**
```bash
/ce:spec    # Full setup: interview → tech detect → CLAUDE.md → TODO.md
```
Creates prioritized TODO.md with plan file references:
- P0 (foundation) → P1 (core) → P2 (enhancements)
- Each feature links to `.claude/plans/{feature-slug}.md`

**`/ce:feature` - Feature Planning:**
```bash
/ce:feature "Add user authentication"
# Creates .claude/plans/add-user-authentication.md
```

**`/ce:execute` - Plan Execution:**
```bash
/ce:execute .claude/plans/add-user-authentication.md
# Runs /ce:loop --plan + /ce:validate, updates TODO.md
```

**`/ce:next` - Interactive Workflow:**
```bash
/ce:next              # Pick feature, create plan, execute with confirmation
/ce:next --list       # Show available features
/ce:next status       # Show progress
```

**`/ce:autopilot` - Fully Autonomous:**
```bash
/ce:autopilot                    # Complete all features
/ce:autopilot --max-features 3   # Limit to 3 features
/ce:autopilot --dry-run         # Show plan only
/ce:autopilot --pause-on-failure # Stop on first failure
```

Safety limits: 4h max time, $50 max cost, no git push, no deploy.

### 5. Autonomous Loops (`/ce:loop`)

For persistent, iterative development:

```bash
# Basic loop - iterate until condition met
/ce:loop "Fix all TypeScript errors" --until "Found 0 errors" --max 10

# Plan-based execution
/ce:loop --plan .claude/plans/feature.md --until "PLAN_COMPLETE" --max 30

# Test-driven development loop
/ce:loop "Implement user auth" --verify "npm test" --until-exit 0
```

**Plan Mode (`--plan`):**
```bash
/ce:loop --plan .claude/plans/feature.md --until "PLAN_COMPLETE"
/ce:loop --plan .claude/plans/feature.md --validate-after-phase
```

Executes structured plans with phases and tasks, outputs markers:
- `TASK_COMPLETE: {id}` - Task done
- `PHASE_COMPLETE: {name}` - Phase done
- `PLAN_COMPLETE` - All phases done

**Completion Conditions:**
- `--until "<text>"` - Exit when output contains phrase
- `--until-exit <code>` - Exit when verify command returns code

**Safety Limits:**
- `--max <n>` - Maximum iterations (default: 20)
- `--max-time <duration>` - Maximum time (default: 2h)
- `--max-cost <amount>` - Maximum estimated cost

**Loop Control:**
- `/ce:loop status` - Check progress
- `/ce:loop pause` - Pause with checkpoint
- `/ce:loop resume` - Resume from checkpoint
- `/ce:loop cancel` - Stop and archive
- `/ce:loop history` - View past loops

### 6. LSP Code Intelligence

Language servers are **automatically installed** during `/ce:init` and when new file types are detected.

**Installation Priority:**
1. **Official Anthropic Plugins** (preferred) - Pre-configured for Claude Code
2. **System Package Managers** (fallback) - npm, pip, brew, cargo, etc.

**Official Anthropic Plugins:**

| Language | Plugin |
|----------|--------|
| TypeScript/JS | `typescript-lsp@claude-plugins-official` |
| Python | `pyright-lsp@claude-plugins-official` |
| Go | `gopls-lsp@claude-plugins-official` |
| Rust | `rust-analyzer-lsp@claude-plugins-official` |
| C/C++ | `clangd-lsp@claude-plugins-official` |
| C# | `csharp-lsp@claude-plugins-official` |
| Java | `jdtls-lsp@claude-plugins-official` |
| PHP | `php-lsp@claude-plugins-official` |
| Ruby | `ruby-lsp@claude-plugins-official` |
| Lua | `lua-lsp@claude-plugins-official` |
| Swift | `swift-lsp@claude-plugins-official` |
| Kotlin | `kotlin-lsp@claude-plugins-official` |

**Additional Supported Languages:**
- Bash/Shell, YAML, JSON, HTML/CSS, Markdown
- Terraform, Svelte, Vue, GraphQL, Elixir, Scala, Zig

**LSP Operations:**
```
goToDefinition    - Jump to symbol definition
findReferences    - Find all usages
hover             - Get documentation/type info
documentSymbol    - List symbols in file
workspaceSymbol   - Search symbols across project
incomingCalls     - Find what calls this function
outgoingCalls     - Find what this function calls
```

**Commands:**
- `/ce:lsp` - Manually trigger LSP detection
- `/ce:lsp status` - Check installed servers

### 7. MCP Server Management

Claudenv can detect and install MCP (Model Context Protocol) servers referenced in your project settings.

**Available MCP Servers:**

| Server | Description |
|--------|-------------|
| `filesystem` | File system access |
| `github` | GitHub API access |
| `postgres` | PostgreSQL database |
| `sqlite` | SQLite database |
| `puppeteer` | Browser automation |
| `memory` | Persistent memory |
| `fetch` | HTTP requests |
| `slack` | Slack integration |

**Extension-Based Servers:**
- `ide` - VS Code extension (install "Claude Code" extension)
- `claude-in-chrome` - Chrome extension (install from claude.ai/chrome)

**Commands:**
- `/ce:admin mcp` - Auto-detect and install missing MCPs
- `/ce:admin mcp list` - List installed and referenced MCPs
- `/ce:admin mcp install <name>` - Install a specific MCP server

### 8. Subagent Orchestration

Claude automatically spawns specialist subagents for complex parallel tasks:

**How it works:**
1. **Task analysis** - Orchestrator analyzes incoming tasks
2. **Agent matching** - Uses hybrid triggers (keywords + complexity scoring)
3. **Parallel execution** - Spawns multiple specialists simultaneously
4. **Result synthesis** - Collects and combines outputs

**Built-in Agents:**
- **Code:** frontend-developer, backend-architect, api-designer, devops-engineer
- **Analysis:** code-reviewer, security-auditor, performance-analyst, accessibility-checker
- **Process:** test-engineer, documentation-writer, release-manager, migration-specialist

**Tech-Specific Agents:**
During `/ce:init`, the framework automatically creates specialist agents for your detected stack:
- React → `react-specialist`
- Django → `django-specialist`
- AWS → `aws-architect`
- Prisma → `prisma-specialist`
- And 50+ more technology mappings

**Trigger conditions:**
- Keywords: "comprehensive", "full review", "across codebase", "refactor all"
- Complexity: 5+ files, 2+ domains, 4+ estimated steps
- Explicit: User requests parallel execution

**Key constraint:** Subagents cannot spawn other subagents (flat hierarchy). The orchestrator is a SKILL running in main context, enabling it to spawn agents.

### 9. Self-Extension

When encountering unfamiliar technology:
1. Meta-agent researches documentation
2. Creates specialized skill with best practices
3. Adds appropriate permissions
4. Notifies user of creation

## Customization

### Local Overrides

Create `.claude/settings.local.json` for personal settings (gitignored):

```json
{
  "permissions": {
    "allow": ["Bash(custom-command *)"],
    "deny": []
  },
  "env": {
    "MY_API_KEY": "..."
  }
}
```

### Adding Skills

Create `.claude/skills/workspace/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: What this skill does. Include trigger keywords.
allowed-tools: Read, Write, Bash(*)
---

# My Skill

Instructions for this skill...
```

### Adding Commands

Create `.claude/commands/my-command.md`:

```markdown
---
description: What this command does
allowed-tools: Read, Write
---

# /my-command

Instructions for this command...
```

### Writing Hook Scripts

Hook scripts must be able to run from any subdirectory. Use this pattern for all hook scripts:

```bash
#!/bin/bash
# Your Hook Script

# Find project root by looking for .claude directory
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Change to project root or exit gracefully
PROJECT_ROOT=$(find_project_root)
if [ -z "$PROJECT_ROOT" ]; then
    exit 0
fi
cd "$PROJECT_ROOT" || exit 0

# Your script logic here...
```

**Why this is needed:** Hooks run from Claude Code's current working directory, which may be a subdirectory. This pattern ensures your script can always find `.claude/` regardless of where it's run from.

**Built-in scripts using this pattern:**
- `session-start.sh`
- `session-end.sh`
- `learning-observer.sh`

## Updating

To update an existing Claudenv installation to the latest version:

```bash
/ce:admin update
```

This fetches the latest fixes from GitHub while preserving your custom hooks and settings.

## Changelog

### v4.0.0
- **BREAKING:** All commands renamed to `/ce:*` namespace (e.g., `/loop` → `/ce:loop`)
- **Added:** Fresh context execution as default for `/ce:loop` (subagents per iteration)
- **Added:** Structured task format with `files`, `action`, `verify`, `done` fields
- **Added:** Atomic commits with `--commit-per-task` and `--commit-per-phase` flags
- **Added:** Codebase mapping via `/ce:map` with 6 parallel analyst agents
- **Added:** `/ce:blocker` command to mark tasks as blocked in TODO.md
- **Added:** Context budget tracking with quality threshold warnings
- **Added:** `/ce:phase` command for phase management (insert/remove/move tasks)
- **Added:** New scripts: `loop-context-packager.sh`, `map-codebase.sh`, `phase-manager.sh`, `task-commit.sh`

### v3.0.11
- **Changed:** Deprecated old monolithic rule files in favor of split structure
- **Removed:** `claudenv.md`, `error-recovery.md`, `permissions.md`, `trigger-reference.md` from memory files
- **Optimized:** Reduces memory file context by ~10k tokens

### v3.0.10
- **Fixed:** Duplicate framework files in monorepo/workspace setups
- **Changed:** Installer now detects parent `.claude/` and skips framework directories for subprojects
- **Added:** `cleanup-duplicate-skills.sh` script for cleaning existing installations

### v3.0.9
- **Changed:** Refactored rules to namespaced directory structure for better organization
- **Optimized:** 76% token reduction (11.6k → 2.8k core) via conditional loading architecture
- **Changed:** Split `claudenv.md` → `claudenv/core.md` + `claudenv/reference.md`
- **Changed:** Split `permissions.md` → `permissions/core.md` (removed redundant examples)
- **Changed:** Split `error-recovery.md` → `error-recovery/core.md` + `error-recovery/patterns.md`
- **Changed:** Converted `trigger-reference.md` → `triggers/reference.json` (loaded by orchestrator only)
- **Fixed:** Hook scripts now auto-locate project root (works from any subdirectory)
- **Fixed:** Session-end.sh, session-start.sh, learning-observer.sh working directory issues

### v3.0.8
- **Added:** `rules/documentation.md` - automatic doc updates with code changes

### v3.0.7
- **Added:** `bin/test` runner

### v3.0.6
- **Changed:** Move installer to `bin/install`, remove `install.sh`

### v3.0.5
- **Changed:** `/shipit` now runs tests before committing - tests must pass before release

### v3.0.4
- **Added:** Manifest validation tests (10 tests) to catch missing files in distribution

### v3.0.3
- **Added:** `.gitignore` for installed projects to ignore runtime state files
- **Fixed:** Added v3.0.0 scripts to manifest.json for proper installation

### v3.0.2
- **Fixed:** manifest.json path reference/README.md to references/README.md

### v3.0.1
- **Added:** Extract workspace package to standalone repo
- **Added:** Template variable substitution for generated files

### v3.0.0
- **Added:** Ultimate Autonomous Workflow for `/ce:autopilot`
- **Added:** Incremental validation system (task/phase/feature tiers)
- **Added:** Git feature isolation (branch per feature with automatic rollback)
- **Added:** Dependency graph for smart feature execution order
- **Added:** 7 new scripts: `dependency-graph.sh`, `git-isolation-manager.sh`, `incremental-validate.sh`, `get-affected-files.sh`, `validate-task.sh`, `validate-phase.sh`
- **Added:** Comprehensive test suite (74 tests, 100% action coverage)
- **Added:** Coverage analyzer (`tests/run-coverage.sh`)
- **Changed:** `/ce:autopilot` now supports `--isolate`, `--validate-after-task`, `--validate-after-phase` flags
- **Changed:** `/ce:loop` now supports `--validate-after-task` and `--validate-after-phase` flags

### v2.6.4
- **Added:** Comprehensive project analysis phase to `/docs` command
- **Added:** Framework vs project file distinction using manifest.json
- **Changed:** `/docs` now inventories all components before processing
- **Changed:** Project mode shows separate counts for framework and project files

### v2.6.3
- **Fixed:** `/docs` command now only updates framework files when run from claudenv repo
- **Fixed:** Deprecated colon syntax in claudenv.md and README.md

### v2.6.2
- **Added:** `/docs` command - Systematic documentation review and optimization
- **Added:** `/shipit` command - Version bump, commit, and push in one step

### v2.6.1
- **Added:** `/backlog` command - Send current or specified task to the backlog
- **Changed:** Standardized timestamp format to `YYYY-MM-DD HH:MM` across all generated files

### v2.6.0
- **Added:** `/ce:spec` command - Full project setup with prioritized TODO.md and plan file scaffolding
- **Added:** `/ce:autopilot` command - Fully autonomous feature completion with safety limits (4h max, $50 max)
- **Added:** `/ce:loop --plan` flag - Structured plan execution with phases/tasks and markers
- **Added:** `/reflect evolve` mode - Analyze failures and propose system improvements
- **Changed:** `/ce:execute` refactored to thin orchestrator (calls `/ce:loop --plan` + `/ce:validate`)
- **Changed:** `/ce:next` rewritten for interactive feature workflow with confirmations
- **Added:** Feature prioritization (P0/P1/P2) with plan file references in TODO.md
- **Added:** `autopilot-manager.sh` script for autopilot state management
- **Added:** Plan state tracking in `.claude/loop/plan-state.json`

### v2.5.0
- **Added:** PIV workflow: `/ce:prime`, `/ce:feature`, `/ce:execute`, `/ce:validate`, `/ce:rca` commands
- **Added:** `.claude/reference/` for curated docs, `.claude/plans/` and `.claude/rca/` for artifacts

### v2.3.13
- **Added:** `/ce:next` command for task planning and parallel execution
- **Added:** Subagent spawning for parallel track execution
- **Added:** TODO.md generation with priority grouping

### v2.3.12
- **Fixed:** Use absolute paths in hook commands for reliable execution

### v2.3.11
- **Fixed:** Graceful exit for hook scripts when not in project root

### v2.3.10
- **Fixed:** `apply-update.sh` counter variables lost in subshell (use for loop instead of pipe)

### v2.3.9
- **Fixed:** `apply-update.sh` shell compatibility (zsh) and empty file handling

### v2.3.8
- **Changed:** Consolidated subcommands into parent commands (e.g., `/ce:loop status` instead of `/loop:status`)
- **Added:** `triggers.json` for skills and agents auto-routing
- **Added:** `trigger-reference.md` rule for matching user requests

### v2.3.7
- **Fixed:** Installer now preserves custom content in existing installations
- **Added:** `infrastructure-*` commands to deprecated list

### v2.3.6
- **Changed:** Commands now use JSON-output pattern for inline formatting
- **Added:** Audit, debug, and backup scripts

### v2.3.5
- **Added:** `check-update.sh` and `apply-update.sh` for update command

### v2.3.4
- **Added:** Proposal-based skill/agent creation from patterns
- **Fixed:** Grep exit code handling in scripts

### v2.3.3
- **Added:** Manifest-based updates to remove deprecated files while preserving user content

### v2.3.2
- **Fixed:** `/claudenv:update` now stops immediately when versions match
- **Changed:** Version check uses cache buster instead of GitHub API

### v2.3.1
- **Added:** Automatic update check on session start
- **Added:** SessionStart, Stop, and PostToolUse hooks configured by default
- **Added:** Session summary on conversation end
- **Added:** Pattern observation on file writes for learning system
- **Changed:** Agents and skills now inherit model from parent (no hardcoded sonnet)

### v2.3.0
- **Added:** Subagent orchestration system for automatic parallel task execution
- **Added:** 12 built-in specialist agents (code, analysis, process categories)
- **Added:** `orchestrator` skill - spawns subagents based on hybrid triggers
- **Added:** `agent-creator` skill - creates tech-specific agents on demand
- **Added:** Tech-to-agent mappings for 50+ technologies (React, Django, AWS, Shopify, etc.)
- **Added:** `/ce:init` now creates specialist agents during bootstrap
- **Added:** `agents/` directory for subagent definitions
- **Added:** `orchestration/` config for trigger rules and settings
- **Changed:** `/learn:review` and `/learn:implement` now support agents
- **Changed:** Pattern observer detects agent opportunities at 2 occurrences

### v2.2.0
- **Added:** `/ce:reflect` command for session reflection and learning consolidation
- **Added:** Automatic correction capture - detects when user corrects Claude and saves to Project Facts
- **Added:** `## Project Facts` section in CLAUDE.md for authoritative project knowledge
- **Added:** `/ce:reflect facts` mode to review and consolidate captured corrections
- **Added:** MERGE/REPLACE/DELETE operations to pattern-observer (prevents bloat)
- **Changed:** Merged `pending-agents.md` into `pending-skills.md`
- **Changed:** Updated observations.md format with staleness tracking
- **Added:** Core philosophy: "Merge over add — consolidate, don't accumulate"

### v2.1.0
- **Changed:** Moved all distributable content to `dist/` directory
- **Added:** Symlinks in `.claude/` for self-dogfooding (claudenv uses its own framework)
- **Fixed:** `find` commands now use `-L` to follow symlinks
- **Changed:** `CLAUDE.md` at repo root is now dev-only instructions (not distributed)

### v2.0.0
- **Changed:** Framework instructions moved to `rules/claudenv.md`
- **Changed:** User's CLAUDE.md now imports framework via `@rules/claudenv.md`
- **Improved:** `install.sh` preserves existing CLAUDE.md content (never overwrites)

### v1.0.6
- **Added:** `skill-creator` skill from Anthropic's official skills repo
- **Added:** Scripts: `init_skill.py`, `quick_validate.py`, `package_skill.py`
- **Changed:** `meta-skill` now delegates to `skill-creator` for scaffolding

### v1.0.5
- **Changed:** Restructured skills to follow Agent Skills spec
- **Changed:** Supporting files moved to `references/` (markdown) and `assets/` (JSON)
- **Changed:** Updated internal path references

### v1.0.4
- **Changed:** Renamed skills to clearer names (removed "-agent" suffix)
- **Changed:** `/agents:triggers` → `/skills:triggers`
- **Fixed:** Skill descriptions for proper auto-invoke (<1024 chars)

### v1.0.3
- **Added:** `/skills:triggers` command for skill discoverability
- **Added:** `/claudenv:audit` command to audit permissions vs detected tech
- **Added:** Pre-commit hook to remind about README updates

### v1.0.2
- **Added:** `/claudenv:mcp` command for MCP server management
- **Added:** MCP auto-detection and installation support
- **Added:** Documentation for 8 official MCP servers

### v1.0.1
- **Fixed:** Permissions format now uses correct `Bash(command:*)` syntax
- **Added:** `/claudenv:update` command for easy updates
- **Changed:** Renamed `/infrastructure:*` commands to `/claudenv:*` namespace

### v1.0.0
- Initial release

## Requirements

- Claude Code CLI
- Bash shell
- Optional: `jq` for JSON parsing (falls back to Python)

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make changes in `dist/` (distributable content)
4. Test locally using symlinks in `.claude/`
5. Run `/health check` to validate
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE)

## Credits

Created by [@nbarthelemy](https://github.com/nbarthelemy)

Built for use with [Claude Code](https://claude.com/claude-code) by Anthropic.
