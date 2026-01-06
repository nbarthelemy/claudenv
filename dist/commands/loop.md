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

## Actions

### Start Loop
1. Parse task and options from args
2. Require completion condition (--until or --until-exit)
3. Create `.claude/loop/state.json` with status "running"
4. Begin iteration cycle: execute → verify → check condition → repeat
5. On completion, display summary and archive to history

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
