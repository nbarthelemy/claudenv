---
description: Cross-project memory search across workspace
allowed-tools: Bash
---

# /ws:recall - Workspace Memory

Search memories across all projects in the workspace.

## Usage

```
/ws:recall                      # Show stats
/ws:recall search <query>       # Search all projects
/ws:recall search <query> --stack web-nextjs  # Filter by stack
```

## Actions

### Stats (default)

Run `bash .claude/scripts/workspace-memory.sh stats` to get workspace-wide stats.

**Display as:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 Workspace Memory
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Projects: {projects}
Total Observations: {totalObservations}
Total Sessions: {totalSessions}

By Project:
  {project.name}: {project.observations} observations

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Search

Run `bash .claude/scripts/workspace-memory.sh search "<query>" [--stack <stack>] --limit 20`

**Display results as:**
```
Found {count} results for "{query}":

1. [{project}] {summary} ({timestamp})
   Importance: {importance}

2. ...
```

## Stack Filtering

Filter results by stack type:
- `web-nextjs` - Next.js web apps
- `shopify-app` - Shopify apps
- `shopify-theme` - Shopify themes
- `ios-swift` - iOS apps
- `android-kotlin` - Android apps

## Notes

- Each project maintains its own memory.db
- Cross-project search aggregates results from all projects
- Memory is preserved during workspace sync operations
