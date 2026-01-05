---
description: Verify Claudenv infrastructure integrity. Validates settings, skills, hooks, and learning files.
allowed-tools: Bash
---

# /health:check - Verify Infrastructure Integrity

Run the health check script to validate all infrastructure components:

```bash
bash .claude/scripts/health-check.sh
```

Validates: settings.json, skills, commands, scripts, learning files, project context, and version.

Returns exit code 1 if errors are found, 0 otherwise.
