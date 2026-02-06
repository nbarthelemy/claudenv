# bin/dev

Manage development servers for workspace projects.

## Synopsis

```bash
bin/dev [command] [project]
```

## Description

The `dev` command manages Next.js development servers with Caddy HTTPS proxy:

- Start/stop individual or all projects
- Graceful restarts without port conflicts
- Status monitoring with JSON output
- Automatic port detection from `.workspace.yml`

## Commands

| Command | Description |
|---------|-------------|
| `start [project]` | Start all servers, or a specific project |
| `stop [project]` | Stop all servers, or a specific project |
| `restart [project]` | Restart all servers, or a specific project |
| `status` | Show human-readable server status |
| `check` | JSON status output (for scripts/Claude) |
| `help` | Show usage information |

## Examples

### Start All Projects

```bash
bin/dev start
```

Starts development servers for all projects in `.workspace.yml`:

```
Starting all dev servers...

Starting cmdstack on port 3003...
Started cmdstack (PID: 12345)
  → https://cmdstack.dev

Starting menory on port 3004...
Started menory (PID: 12346)
  → https://menory.dev

All servers started
```

### Start Specific Project

```bash
bin/dev start myapp
```

### Stop All Projects

```bash
bin/dev stop
```

### Stop Specific Project

```bash
bin/dev stop myapp
```

### Restart a Project

```bash
bin/dev restart myapp
```

Gracefully stops and restarts without affecting Caddy:

```
Restarting myapp...
Stopping myapp (PID: 12345)...
Stopped myapp
Starting myapp on port 3008...
Started myapp (PID: 12350)
Restart complete
  → https://myapp.dev
```

### Check Status

```bash
bin/dev status
```

Human-readable output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Dev Server Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ● Caddy proxy running

  ● cmdstack → https://cmdstack.dev
      port 3003, PID 12345
  ● menory → https://menory.dev
      port 3004, PID 12346
  ○ myapp (not running)
      https://myapp.dev → localhost:3008

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### JSON Status (for Scripts)

```bash
bin/dev check
```

Machine-readable JSON:

```json
{
  "caddy": true,
  "servers": [
    {"project": "cmdstack", "port": 3003, "domain": "https://cmdstack.dev", "running": true, "pid": "12345", "stack": "nextjs"},
    {"project": "menory", "port": 3004, "domain": "https://menory.dev", "running": true, "pid": "12346", "stack": "nextjs"},
    {"project": "myapp", "port": 3008, "domain": "https://myapp.dev", "running": false, "pid": "", "stack": "nextjs"}
  ]
}
```

## How It Works

### Port Assignment

Ports are read from `.workspace.yml`:

```yaml
projects:
  cmdstack:
    port: 3003
  menory:
    port: 3004
  myapp:
    port: 3008
```

### Package Manager Detection

Automatically detects and uses the correct package manager:

1. `pnpm-lock.yaml` → pnpm
2. `yarn.lock` → yarn
3. `bun.lockb` → bun
4. Default → npm

### Monorepo Support

For projects with `apps/web/` structure, runs the dev server from `apps/web`:

```bash
cd myapp/apps/web && PORT=3008 pnpm run dev
```

### Caddy Integration

Each project has a `.caddy` file that Caddy uses for reverse proxy:

```
myapp.dev {
    reverse_proxy localhost:3008
}
```

The root `.caddy` imports all project configs:

```
import cmdstack/.caddy
import menory/.caddy
import myapp/.caddy
```

### Process Management

- PIDs stored in `.claude/pids/{project}.pid`
- Logs stored in `.claude/logs/{project}.log`
- Stale PID files cleaned automatically

## Idempotent Operations

### Start

- Checks if port is in use before starting
- Updates PID file if process already running
- Returns success without restarting

```bash
bin/dev start myapp
# myapp already running on port 3008 (PID: 12345)
#   → https://myapp.dev
```

### Stop

- Gracefully kills process by PID
- Cleans up stale PID files
- Safe to call multiple times

### Restart

- Waits for port release (up to 5 seconds)
- Warns if port still in use
- Does not affect Caddy

## Shopify Theme Projects

Projects with `stack: shopify-theme` are skipped:

```
Skipping aurora (shopify-theme - uses Shopify CLI)
```

These projects use the Shopify CLI (`shopify theme dev`) instead.

## Troubleshooting

### Port Already in Use

If a port is in use by another process:

```bash
# Find what's using the port
lsof -i :3008

# Kill the process
kill <PID>

# Or let bin/dev handle it
bin/dev restart myapp
```

### Caddy Not Running

```
○ Caddy proxy NOT running
  Run: caddy run --config .caddy
```

Start Caddy manually or via brew services:

```bash
# Foreground
caddy run --config .caddy

# Background
caddy start --config .caddy
```

### View Logs

```bash
tail -f .claude/logs/myapp.log
```

## Files

| Path | Purpose |
|------|---------|
| `.workspace.yml` | Project registry with ports |
| `.caddy` | Root Caddy configuration |
| `{project}/.caddy` | Project Caddy configuration |
| `.claude/pids/{project}.pid` | Process ID files |
| `.claude/logs/{project}.log` | Development server logs |

## Important Notes

### Never Run npm/pnpm dev Directly

```bash
# WRONG - causes conflicts
cd myapp && pnpm dev

# CORRECT - uses workspace coordination
bin/dev start myapp
```

Direct commands:
- Cause port conflicts with other projects
- Don't update PID tracking
- May conflict with other Claude instances

### Access via .dev Domains

Always use HTTPS `.dev` domains, not localhost:

```bash
# CORRECT
open https://myapp.dev

# WRONG
open http://localhost:3008
```

## See Also

- [bin/create](./bin-create.md) - Create projects
- [bin/delete](./bin-delete.md) - Remove projects
- [Development Domain Rules](../.claude/rules/dev-domains.md)
