# Development Domain Rules

## CRITICAL: Use .dev Domains, Not localhost

In this workspace, Caddy provides `.dev` domain routing. **ALWAYS** use the project's `.dev` domain:

| Project | Correct URL | WRONG |
|---------|-------------|-------|
| cmdstack | `https://cmdstack.dev` | `http://localhost:3003` |
| brandcmd | `https://brandcmd.dev` | `http://localhost:3002` |
| menory | `https://menory.dev` | `http://localhost:3004` |
| monivore | `https://monivore.dev` | `http://localhost:3005` |
| scrimble | `https://scrimble.dev` | `http://localhost:3006` |
| vinote | `https://vinote.dev` | `http://localhost:3007` |

## Dev Server Management

### MANDATORY: Use bin/dev

**NEVER** run dev server commands directly:
```bash
# WRONG - NEVER do this
npm run dev
pnpm dev
yarn dev
next dev
```

**ALWAYS** use bin/dev from the workspace:
```bash
# CORRECT - use bin/dev
bin/dev start               # Start ALL servers
bin/dev start <project>     # Start a specific project
bin/dev stop                # Stop all servers
bin/dev stop <project>      # Stop a specific project
bin/dev restart             # Restart all servers
bin/dev restart <project>   # Restart a specific project
bin/dev status              # Check all servers
bin/dev check               # JSON status for scripts
```

### Before Starting Any Server

1. **Check if already running** - don't restart needlessly:
   ```bash
   bin/dev check | jq '.servers[] | select(.project=="PROJECT")'
   ```

2. **If not running**, start with bin/dev:
   ```bash
   bin/dev start <project>
   ```

3. **If restart needed**, use graceful restart:
   ```bash
   bin/dev restart <project>
   ```

### Why This Matters

Multiple Claude instances may work on different projects simultaneously. Direct `npm run dev` commands:
- Cause port conflicts
- Kill other instances' servers
- Break browser tests
- Waste time on restarts

bin/dev coordinates across instances by checking ports before acting.

## Browser Testing

When using browser automation (MCP tools):
1. **Always use** `https://project.dev` URLs
2. **Never use** `localhost:port` URLs
3. If connection fails, the server isn't running - ask user to start it

## Debugging Connection Issues

If `https://project.dev` fails:
1. Check Caddy is running: `pgrep caddy`
2. Check project server is running: `lsof -i :PORT`
3. Check /etc/hosts has the domain: `grep project.dev /etc/hosts`

Do NOT restart servers to "fix" the issue - diagnose first.
