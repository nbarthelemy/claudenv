# Parallel Execution Rules

**On every prompt, evaluate opportunities to process tasks in parallel.**

## Prefer Subagents for Independent Work

When facing tasks that can be parallelized, **launch up to 15 subagents** using the Task tool to work concurrently. This maximizes throughput and keeps the main context focused.

## When to Use Subagents

**Always parallelize:**
- Searching multiple directories or file patterns
- Reading/analyzing multiple files independently
- Running independent validation checks (lint, type-check, test)
- Exploring different parts of a codebase
- Researching multiple topics simultaneously
- Applying similar changes across independent files

**Keep in main context:**
- Sequential operations with dependencies
- Tasks requiring conversation history
- User-facing decisions that need confirmation
- Operations that must see each other's results

## Execution Pattern

```
1. Identify independent subtasks
2. Launch subagents in parallel (single message, multiple Task calls)
3. Collect results
4. Synthesize and continue
```

## Example

Instead of:
```
Read file A → Read file B → Read file C → Analyze
```

Do:
```
Launch 3 subagents in parallel:
  - Agent 1: Read and summarize file A
  - Agent 2: Read and summarize file B
  - Agent 3: Read and summarize file C
Collect results → Synthesize
```

## Guidelines

- **Be aggressive** - when in doubt, parallelize
- **Batch similar work** - group related searches/reads into one agent
- **Use appropriate agent types** - Explore for codebase questions, Bash for commands
- **Trust agent results** - don't re-verify unless something seems wrong
- **Summarize for user** - agent output isn't visible to user, relay key findings
