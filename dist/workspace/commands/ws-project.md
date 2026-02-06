---
description: "Manage workspace projects"
allowed-tools: Bash
---

# /ws:project - Manage Projects

Manage projects within the workspace.

## Usage

```bash
/ws:project list              # List all projects
/ws:project add <name>        # Add a new project
/ws:project remove <name>     # Remove a project from workspace.yml
/ws:project info <name>       # Show project details
```

## List Projects

Run: `yq '.projects | keys | .[]' .workspace.yml`

Display as a table with:
- Project name
- Stack
- Platform
- Port

## Add Project

1. Check if project directory exists
2. Detect stack and platform
3. Assign next available port
4. Add to .workspace.yml
5. Run sync

## Remove Project

1. Remove from .workspace.yml (does NOT delete files)
2. Optionally remove synced files from project/.claude/

## Project Info

Show:
- Stack and platform configuration
- Port assignment
- Last sync time (from workspace/version.json)
- Sync status (up to date or needs sync)
