# Workspace Bin Commands

Reference documentation for workspace management commands.

## Commands

| Command | Description | Documentation |
|---------|-------------|---------------|
| `bin/dev` | Manage development servers | @references/bin/dev.md |
| `bin/sync` | Sync Claude infrastructure | @references/bin/sync.md |
| `bin/upgrade` | Check and apply updates | @references/bin/upgrade.md |

## Project Creation

Project and package creation has moved to the **stack CLI**:

```bash
npx @siquora/stack create              # Interactive
npx @siquora/stack create myapp        # Named project
npx @siquora/stack create --stack ios  # With stack
```

See [@siquora/stack](../../../packages/stack) for full documentation.

## Quick Reference

### Manage Dev Servers

```bash
bin/dev start [project]    # Start servers
bin/dev stop [project]     # Stop servers
bin/dev restart [project]  # Restart servers
bin/dev status             # Show status
bin/dev check              # JSON status
```

### Sync Infrastructure

```bash
bin/sync myapp    # Sync one project
bin/sync all      # Sync all projects
```

## When to Use

- **npx @siquora/stack create** - Starting a new project or shared package
- **bin/dev** - Daily development server management
- **bin/sync** - After workspace updates or manual .claude changes
- **bin/upgrade** - Periodically to get framework updates
