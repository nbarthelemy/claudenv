---
description: "Autonomous loop: /loop <task>, /loop status|pause|resume|cancel|history"
allowed-tools: Bash, Read, Write, Edit
---

# /loop - Autonomous Development Loop

## Usage

```
/loop "<task>" [options]    Start loop
/loop status                Show progress
/loop pause                 Pause loop
/loop resume                Resume loop
/loop cancel                Stop loop
/loop history [id]          View past loops
```

## Options

| Flag | Description |
|------|-------------|
| `--until "<text>"` | Exit when output contains phrase |
| `--until-exit <N>` | Exit when verify returns code |
| `--verify "<cmd>"` | Run after each iteration |
| `--max <N>` | Max iterations (default: 20) |
| `--max-time <dur>` | Max time (default: 2h) |
| `--track "<name>"` | Track name for coordination |
| `--agent-id "<id>"` | Agent ID (auto-generated if not provided) |

## Actions

### Start Loop
1. Parse task and options from args
2. Require completion condition (--until or --until-exit)
3. **Coordination setup** (if --track provided):
   - Generate agent ID: `agent-{hostname}-{timestamp}`
   - Register: `bash .claude/scripts/todo-coordinator.sh register "$AGENT_ID" "$TRACK"`
   - Check for active agents on same track (warn if conflict)
4. Create `.claude/loop/state.json` with status "running"
5. Begin iteration cycle:
   - **If coordinated**: Check available tasks, claim next unclaimed
   - Execute task
   - Verify completion
   - **If coordinated**: Mark task complete, claim next
   - Check exit condition → repeat or exit
6. **On completion**:
   - Deregister: `bash .claude/scripts/todo-coordinator.sh deregister "$AGENT_ID"`
   - Display summary and archive to history

### Status
Run: `bash .claude/scripts/loop-status.sh`
Show: iteration progress, elapsed time, completion condition

### Pause
Update state.json: `"status": "paused"`
Save checkpoint for resumption

### Resume
Verify state is "paused", update to "running"
Continue from last checkpoint

### Cancel
Archive state to `.claude/loop/history/{id}.json`
Clean up active loop files

### History
List all loops in `.claude/loop/history/`
With ID: show detailed loop info

## State File

`.claude/loop/state.json`:
```json
{"id":"loop_YYYYMMDD_HHMMSS","status":"running","prompt":"...","iterations":{"current":0,"max":20},"completion":{"type":"exact","condition":"...","met":false}}
```

## Example

```
/loop "Fix all TypeScript errors" --until "Found 0 errors" --max 10
/loop status
/loop pause
/loop resume
```

## Multi-Agent Coordination

When using `--track`, loops coordinate with other agents via shared state.

### Coordinated Example

```bash
# Terminal 1
/loop "Complete frontend tasks" --track "Track A" --until "TRACK_A_COMPLETE" --max 15

# Terminal 2
/loop "Complete API tasks" --track "Track B" --until "TRACK_B_COMPLETE" --max 15
```

### Coordination Protocol

1. **Register** on start - announce presence to other agents
2. **Claim** tasks before working - prevents conflicts
3. **Complete** tasks when done - updates shared TODO.md
4. **Heartbeat** periodically - allows stale agent detection
5. **Deregister** on exit - releases unclaimed tasks

### Check Coordination Status

```bash
bash .claude/scripts/todo-coordinator.sh status
```

Output:
```json
{
  "activeAgents": 2,
  "tasksInProgress": 3,
  "tasksCompleted": 5,
  "agents": {...},
  "tasks": {...}
}
```

### Shared State

All coordination data is stored in `.claude/loop/coordination.json` and can be safely read by any terminal to understand the current state.
