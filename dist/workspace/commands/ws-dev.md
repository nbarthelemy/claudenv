---
description: "Manage development servers"
allowed-tools: Bash
---

# /ws:dev - Development Server Management

Start, stop, and manage development servers for workspace projects.

## Usage

```bash
/ws:dev <project>        # Start dev server for project
/ws:dev stop             # Stop all dev servers
/ws:dev stop <name>      # Stop specific project
/ws:dev restart <name>   # Restart specific project (graceful)
/ws:dev status           # Show running servers
/ws:dev check            # JSON status for scripts
```

## Implementation

Run: `bash .claude/scripts/dev-server.sh <args>`

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Dev Server Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ● cmdstack (port 3000, PID 12345)
  ● scrimble (port 3002, PID 12346)
  ○ monivore (stopped)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Notes

- Servers run in background with logs at `.claude/logs/<project>.log`
- PIDs tracked in `.claude/pids/<project>.pid`
- Port numbers from .workspace.yml
