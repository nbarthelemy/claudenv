---
name: loop:status
description: Show current autonomous loop status
---

# Loop Status

Display the current status of any active or paused loop.

## Check for Active Loop

```bash
if [ ! -f ".claude/loop/state.json" ]; then
  echo "No active loop found."
  echo "Start one with: /loop \"<prompt>\" --until \"<condition>\""
  exit 0
fi
```

## Read State

Load `.claude/loop/state.json` and display:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 LOOP STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Task: {prompt}
🔢 Status: {status} (running/paused/complete/failed)

📊 Progress:
   Iteration: {current}/{max}
   Elapsed: {elapsed_time}
   Est. Cost: {estimated_cost}

🎯 Completion Condition:
   Type: {type}
   Target: {condition}
   Met: {yes/no}

🛡️ Safety Limits:
   Max Iterations: {max} ({remaining} remaining)
   Max Time: {max_time} ({time_remaining} remaining)
   Max Cost: {max_cost or "not set"}

📁 Recent Activity:
   Last checkpoint: {last_checkpoint_time}
   Files modified: {count}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Commands:
  /loop:pause   - Pause the loop
  /loop:cancel  - Stop and cancel
  /loop:history - View all past loops
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Show Last Iteration Details

If loop is running or paused, also show:

```
📝 Last Iteration ({N}):
   {summary of what was accomplished}

   Files touched:
   - {file1}
   - {file2}
```

## Progress Visualization

```
Progress: [████████░░░░░░░░░░░░] 40% (8/20 iterations)
Time:     [██████████████░░░░░░] 70% (1h 24m / 2h)
```
