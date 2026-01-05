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

## Quick Start

### Option 1: Git Clone

```bash
# Clone the framework
git clone https://github.com/nbarthelemy/claudenv.git

# Copy to your project
cp -r claudenv/.claude /path/to/your/project/

# Navigate to your project
cd /path/to/your/project

# Start Claude and run bootstrap
claude
> /claudenv
```

### Option 2: Curl One-Liner

```bash
curl -sL https://raw.githubusercontent.com/nbarthelemy/claudenv/main/install.sh | bash
```

## What You Get

### Commands

| Command | Description |
|---------|-------------|
| `/claudenv` | Bootstrap infrastructure for current project |
| `/interview` | Conduct project specification interview |
| `/loop` | Start autonomous iterative development loop |
| `/loop:status` | Check current loop progress |
| `/loop:pause` | Pause active loop |
| `/loop:resume` | Resume paused loop |
| `/loop:cancel` | Stop and cancel active loop |
| `/loop:history` | View past loop runs |
| `/lsp` | Auto-detect and install LSP servers |
| `/lsp:status` | Check LSP server status |
| `/claudenv:status` | Show system overview |
| `/claudenv:update` | Quick update to latest version |
| `/claudenv:upgrade` | Full upgrade with changelog |
| `/claudenv:export` | Export for sharing |
| `/claudenv:import` | Import from export |
| `/claudenv:mcp` | Detect and install MCP servers |
| `/claudenv:audit` | Audit permissions vs detected tech |
| `/agents:triggers` | List agents with trigger keywords |
| `/health:check` | Verify infrastructure integrity |
| `/learn:review` | Review pending automation proposals |
| `/learn:implement` | Implement a learning proposal |
| `/analyze-patterns` | Force pattern analysis |
| `/backup:create` | Create infrastructure backup |
| `/backup:restore` | Restore from backup |
| `/autonomy:pause` | Temporarily reduce autonomy |
| `/autonomy:resume` | Restore autonomy level |
| `/debug:agent` | Debug a specific skill |
| `/debug:hooks` | Debug hook configuration |

### Skills (Auto-Invoked)

| Skill | Purpose |
|-------|---------|
| `tech-detection` | Detects project stack and configures permissions |
| `interview-agent` | Conducts comprehensive specification interviews |
| `learning-agent` | Observes patterns and suggests automations |
| `meta-agent` | Creates new skills for unfamiliar technologies |
| `frontend-design` | Creates distinctive, production-grade UI with anti-AI-slop aesthetics |
| `loop-agent` | Manages autonomous iterative development loops |
| `lsp-agent` | Auto-detects and installs language servers for code intelligence |

### Detected Technologies

**Languages:** JavaScript, TypeScript, Python, Ruby, Go, Rust, PHP, Java, C#, Swift, Kotlin

**Frameworks:** Next.js, Nuxt, React, Vue, Angular, Svelte, Astro, Remix, Express, Fastify, NestJS, Django, Flask, FastAPI, Rails

**Cloud Platforms:** AWS, GCP, Azure, Heroku, Vercel, Netlify, Fly.io, Railway, DigitalOcean, Cloudflare, Supabase, Firebase

**Databases:** PostgreSQL, MySQL, MongoDB, Redis, SQLite, Prisma, Drizzle, TypeORM

## Directory Structure

```
.claude/
├── CLAUDE.md           # Framework instructions & autonomy rules
├── settings.json       # Permissions & hooks configuration
├── version.json        # Framework version
├── commands/           # Slash commands (28 included)
├── skills/             # Auto-invoked skills (7 included)
│   ├── tech-detection/
│   ├── interview-agent/
│   ├── learning-agent/
│   ├── meta-agent/
│   ├── frontend-design/
│   ├── loop-agent/
│   └── lsp-agent/
├── rules/              # Modular instruction sets
├── scripts/            # Shell scripts for hooks
├── templates/          # Templates for generation
├── learning/           # Pattern observations
├── loop/               # Autonomous loop state & history
├── logs/               # Execution logs (gitignored)
└── backups/            # Infrastructure backups (gitignored)
```

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

### 1. Bootstrap (`/claudenv`)

When you run `/claudenv`, the framework:
1. Runs tech detection script
2. Analyzes confidence level (HIGH/MEDIUM/LOW)
3. **Auto-runs `/interview` if confidence is LOW**
4. Generates `project-context.json`
5. Updates `settings.json` with tech-specific permissions
6. Migrates existing CLAUDE.md (preserving all content)
7. Initializes learning system
8. Installs LSP servers (plugins first, then binaries)
9. **Validates all required files were created**
10. Runs health check

**Post-Init Validation:** The bootstrap verifies all required files, directories, and configurations exist before reporting success. Missing items are auto-created.

### 2. Interview (`/interview`)

For new projects or unclear requirements:
1. Silently reads all existing documentation
2. Analyzes codebase for existing decisions
3. Asks targeted questions (one at a time)
4. Provides researched options with tradeoffs
5. Creates comprehensive `SPEC.md`
6. Updates project context

### 3. Learning

The learning agent continuously:
1. Observes development patterns
2. Detects repeated manual steps
3. Auto-creates skills/hooks at threshold (3 occurrences)
4. Proposes agents for new technologies (2 occurrences)

### 4. Autonomous Loops (`/loop`)

For persistent, iterative development:

```bash
# Basic loop - iterate until condition met
/loop "Fix all TypeScript errors" --until "Found 0 errors" --max 10

# Test-driven development loop
/loop "Implement user auth" --mode tdd --verify "npm test" --until-exit 0

# Overnight build with limits
/loop "Build complete API" --until "COMPLETE" --max 50 --max-time 8h --max-cost $20
```

**Completion Conditions:**
- `--until "<text>"` - Exit when output contains exact phrase
- `--until-exit <code>` - Exit when verification command returns code
- `--until-regex "<pattern>"` - Exit when output matches regex

**Safety Limits:**
- `--max <n>` - Maximum iterations (default: 20)
- `--max-time <duration>` - Maximum time (default: 2h)
- `--max-cost <amount>` - Maximum estimated cost

**Loop Modes:**
- `--mode standard` - Basic iteration (default)
- `--mode tdd` - Test-driven development
- `--mode refine` - Quality refinement

**Loop Control:**
- `/loop:status` - Check progress
- `/loop:pause` - Pause with checkpoint
- `/loop:resume` - Resume from checkpoint
- `/loop:cancel` - Stop and archive
- `/loop:history` - View past loops

### 5. LSP Code Intelligence

Language servers are **automatically installed** during `/claudenv` and when new file types are detected.

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
- `/lsp` - Manually trigger LSP detection
- `/lsp:status` - Check installed servers

### 6. MCP Server Management

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
- `/claudenv:mcp` - Auto-detect and install missing MCPs
- `/claudenv:mcp list` - List installed and referenced MCPs
- `/claudenv:mcp install <name>` - Install a specific MCP server

### 7. Self-Extension

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
    "allow": ["Bash(custom-command:*)"],
    "deny": []
  },
  "env": {
    "MY_API_KEY": "..."
  }
}
```

### Adding Skills

Create `.claude/skills/my-skill/SKILL.md`:

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

## Updating

To update an existing Claudenv installation to the latest version:

```bash
/claudenv:update
```

This fetches the latest fixes from GitHub while preserving your custom hooks and settings.

## Changelog

### v1.0.3
- **Added:** `/agents:triggers` command for agent discoverability
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
3. Make your changes
4. Test with `/health:check`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE)

## Credits

Created by [@nbarthelemy](https://github.com/nbarthelemy)

Built for use with [Claude Code](https://claude.com/claude-code) by Anthropic.
