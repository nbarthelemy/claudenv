# Claudenv Framework (Reference)

> Detailed examples, edge cases, and advanced features

This file is loaded on-demand when you need detailed context. Core rules are in `claudenv-core.md`.

---

## Directory Structure (Detailed)

```
.claude/
├── CLAUDE.md           # Project instructions + @rules/claudenv.md
├── settings.json       # Permissions & hooks
├── SPEC.md             # Project specification (generated)
├── project-context.json # Detected tech stack
├── commands/           # Slash commands
├── skills/             # Auto-invoked capabilities
│   └── triggers.json   # Skill trigger configuration
├── agents/             # Specialist subagents for orchestration
│   └── triggers.json   # Agent trigger configuration
├── orchestration/      # Orchestration config (triggers, limits)
├── rules/              # Modular instruction sets
├── scripts/            # Shell scripts for hooks
├── templates/          # Templates for generation
├── references/         # Curated best practices docs (read by /ce:prime)
├── plans/              # Feature implementation plans (/feature output)
├── rca/                # Root cause analysis documents (/rca output)
├── learning/           # Pattern observations
├── loop/               # Autonomous loop state & history
├── lsp-config.json     # Installed LSP servers (generated)
├── logs/               # Execution logs
└── backups/            # Auto-backups
```

---

## PIV Workflow Examples

### Example 1: New Feature Implementation

```bash
# User starts a new session
# /ce:prime runs automatically and loads context

User: "Add user authentication with JWT"

Claude:
1. Runs /ce:feature "Add user authentication with JWT"
2. Creates .claude/plans/add-user-authentication-with-jwt.md
3. Presents plan for approval
4. On approval: /ce:execute .claude/plans/add-user-authentication-with-jwt.md
5. This calls: /ce:loop --plan <file>
6. After completion: /ce:validate runs automatically
7. Updates TODO.md to mark as complete
```

### Example 2: Interactive Multi-Feature

```bash
/next

# Shows TODO.md features:
# [ ] Add login form
# [ ] Add password reset
# [ ] Add 2FA

# User selects: Add login form
# Creates plan if not exists
# Confirms before execution
# Executes with /ce:loop --plan
# Validates
# Asks: "Continue to next?" → User confirms
# Repeats for remaining features
```

### Example 3: Fully Autonomous

```bash
/autopilot

# Processes all features in TODO.md without interaction
# Safety limits: 4h max, $50 max cost
# No git push, no deploy
# Stops on first failure if --pause-on-failure
```

---

## Reference Documentation (Detailed)

### Purpose

Reference docs provide stack-specific guidance that `/ce:prime` loads at session start.

### Suggested Files by Stack

| Stack | Suggested Files | Content |
|-------|----------------|---------|
| **React** | react-best-practices.md | Hooks patterns, state management, performance |
| | state-management.md | Context vs Redux vs Zustand |
| **FastAPI** | fastapi-best-practices.md | Dependency injection, async patterns |
| | pydantic-patterns.md | Model validation, custom validators |
| **Next.js** | nextjs-best-practices.md | App router, SSR vs SSG, data fetching |
| | routing-patterns.md | Dynamic routes, middleware, layouts |
| **Go** | go-conventions.md | Package structure, error handling |
| | error-handling.md | Error wrapping, custom errors |
| **Testing** | testing-strategy.md | Unit vs integration vs e2e |
| | e2e-patterns.md | Playwright/Cypress patterns |

### Creating Reference Docs

Each doc should include:

1. **Key principles** - What matters most for this tech
2. **Common patterns with examples** - Copy-paste ready code
3. **Anti-patterns to avoid** - What NOT to do
4. **Project-specific conventions** - Team decisions

**Example structure:**

```markdown
# React Best Practices

## Key Principles
- Use hooks for state management
- Keep components small and focused
- Prefer composition over inheritance

## Common Patterns

### Custom Hooks
```typescript
// ✓ Good: Custom hook for data fetching
function useUser(id: string) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchUser(id).then(setUser).finally(() => setLoading(false))
  }, [id])

  return { user, loading }
}
```

## Anti-patterns
- ✗ Don't use index as key in lists
- ✗ Don't mutate state directly
- ✗ Don't use useEffect for derived state
```

---

## Skill Architecture (Claude Code 2.1+)

### Forked Context

Heavy-analysis skills run in isolated contexts to prevent main context pollution:

```yaml
---
name: orchestrator
context: fork
allowed-tools:
  - Read
  - Task
---
```

**Skills using forked context:**
- `orchestrator` - Multi-agent coordination (reads trigger-reference.json)
- `pattern-observer` - Background pattern analysis
- `tech-detection` - Project stack analysis (reads command-mappings.json)
- `meta-skill` - Technology research and skill creation
- `agent-creator` - Specialist agent generation

### Agent Delegation

Skills can delegate to specific agent types:

```yaml
---
name: frontend-design
agent: frontend-developer
---
```

### YAML-Style Tool Lists

Cleaner frontmatter with YAML lists:

```yaml
allowed-tools:
  - Read
  - Write
  - Bash(npm *)
  - Bash(npx *)
```

### Skill Hooks

Skills define their own hooks:

```yaml
hooks:
  Stop:
    - command: bash .claude/scripts/cleanup.sh
```

### One-Time Hooks

Session startup hooks run once per session:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "",
      "once": true,
      "hooks": [{"type": "command", "command": "bash .claude/scripts/session-start.sh"}]
    }]
  }
}
```

### Agent Disabling

Disable specific agents via permissions:

```json
{
  "permissions": {
    "deny": ["Task(security-auditor)"]
  }
}
```

---

## Automatic Correction Capture

### Detection Patterns

Claude watches for:
- "no, we use X not Y"
- "actually it's X"
- "remember that..."
- "don't forget..."
- "in this project, we..."

### Storage Format

Corrections saved to `## Project Facts` in CLAUDE.md:

```markdown
## Project Facts

### Tooling
- Uses pnpm, not npm (corrected 2026-01-05)

### Structure
- Tests are in __tests__/ folders (corrected 2026-01-05)

### Conventions
- Always use const, never let (corrected 2026-01-05)
```

### Behavior

- **Auto-capture:** Immediate - no threshold
- **Notify:** Brief message "📝 Noted: [fact]"
- **Categorize:** Tooling/Structure/Conventions/Architecture
- **Consolidate:** `/reflect facts` merges duplicates

---

## LSP Operations (Detailed)

**Supported Languages:** TypeScript, Python, Go, Rust, Ruby, PHP, Java, C/C++, C#, Lua, Bash, YAML, JSON, HTML/CSS, Markdown, Terraform, Svelte, Vue, GraphQL

**Operations:**

| Operation | Purpose | Example |
|-----------|---------|---------|
| goToDefinition | Find where symbol is defined | Jump from usage to function definition |
| findReferences | Find all usages | Find everywhere a function is called |
| hover | Get docs/type info | See function signature on hover |
| documentSymbol | List all symbols in file | Get all functions/classes in file |
| workspaceSymbol | Search symbols across workspace | Find function by name across project |
| goToImplementation | Find implementations | Jump from interface to implementation |
| incomingCalls | Find callers | See what calls this function |
| outgoingCalls | Find callees | See what this function calls |

**When to use LSP vs grep:**
- Use LSP for code navigation (definitions, references, implementations)
- Use grep for text search (comments, strings, patterns)
- LSP understands code semantically; grep is text-based
