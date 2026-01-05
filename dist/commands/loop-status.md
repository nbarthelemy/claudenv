---
name: loop:status
description: Show current autonomous loop status
allowed-tools: Bash
---

# /loop:status - Loop Status

Run the loop status script to display current loop state:

```bash
bash .claude/scripts/loop-status.sh
```

Shows: task, status, progress, completion condition, safety limits, and recent activity.

Related commands:
- `/loop:pause` - Pause active loop
- `/loop:resume` - Resume paused loop
- `/loop:cancel` - Stop and cancel loop
- `/loop:history` - View past loops
