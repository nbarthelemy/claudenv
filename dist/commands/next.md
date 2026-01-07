---
description: Analyze codebase, create TODO.md with prioritized tasks, and generate /loop commands
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion
---

# /next - Development Task Planning

Analyze the project, determine next steps, create/update `.claude/TODO.md`, and generate executable `/loop` commands.

## Process

### 1. Gather Context

Read and analyze (silently):
- `.claude/SPEC.md` - Project specification
- `.claude/CLAUDE.md` - Project instructions
- `.claude/project-context.json` - Tech stack
- `.claude/TODO.md` - Existing tasks (if present)
- `README.md` - Project overview
- `git log --oneline -20` - Recent commits
- `git status` - Uncommitted work
- `git diff --stat HEAD~5` - Recent changes

### 2. Discover Work Items

Search for incomplete work:
```bash
# TODOs and FIXMEs
grep -rn "TODO\|FIXME\|XXX\|HACK" --include="*.{ts,tsx,js,jsx,py,go,rs,rb}" . 2>/dev/null | head -50

# Incomplete implementations
grep -rn "not implemented\|throw new Error\|pass  #\|unimplemented!" --include="*.{ts,tsx,js,jsx,py,go,rs,rb}" . 2>/dev/null | head -20
```

Analyze for:
- **Incomplete features** - Started but not finished
- **Missing tests** - Code without test coverage
- **Technical debt** - Areas needing refactoring
- **Blocked items** - Dependencies not yet resolved
- **Next logical steps** - Based on recent work

### 3. Present & Confirm

Use AskUserQuestion to present findings:

**Question 1: Scope**
"I found {n} potential work items. What's the focus for this session?"
- Current feature completion
- Bug fixes / technical debt
- New feature development
- Testing / quality
- Other (specify)

**Question 2: Priorities**
Present top 5-10 items, ask user to confirm/reorder/remove.

**Question 3: Parallelization**
"Which of these can be worked on independently?"
- Show items that don't conflict (different files/modules)
- Confirm parallel tracks

### 4. Write TODO.md

Create/update `.claude/TODO.md`:

```markdown
# Development TODO

> Updated: {timestamp}
> Focus: {session_focus}

## Active Tracks

### Track A: {name} [PARALLEL]
> {description} | Est: {n} iterations

- [ ] P1: {task_description}
  - Files: `path/to/file.ts`
  - Verify: `{test_command}`
- [ ] P2: {task_description}

### Track B: {name} [PARALLEL]
> {description} | Est: {n} iterations

- [ ] P1: {task_description}
- [ ] P2: {task_description}

### Sequential: {name} [BLOCKING]
> Must complete before parallel tracks

- [ ] P0: {blocking_task}
  - Blocks: Track A, Track B
- [ ] P1: {next_task}
  - Depends: above

## Backlog
- [ ] P3: {future_item}

## Completed
- [x] {date}: {item}
```

### 5. Present Options & Execute

Show the TODO.md summary, then interview about execution:

**Question 1 (if blocking tasks exist):**
"There are blocking tasks that should run first. Start with these?"
- Yes, run blocking tasks first
- Skip to parallel tracks

**Question 2 (if multiple parallel tracks identified):**
"I found {n} tracks that can run in parallel:
- Track A: {description} ({n} tasks)
- Track B: {description} ({n} tasks)

Run these in parallel? (requires 2 terminals)"
- Yes, run in parallel
- No, run sequentially
- Pick one track only

**Question 3 (if parallel declined or single track):**
"Which track to start?"
- {Track A name}
- {Track B name}
- {Other task}
- Just show commands (don't run)

### 6. Execute Loop

After user selects, **immediately invoke the /loop command** using the Skill tool:

```
Skill: loop
Args: "{task_description}" --until "{condition}" --max {n}
```

For parallel tracks, output the second command for the user to run in another terminal:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Starting: {selected_track}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Running Track A in this terminal...

To run Track B in parallel, open another terminal and run:
/loop "Track B: {description}" --until "TRACK_B_COMPLETE" --max 15

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Subcommands

### /next status
Show TODO.md progress summary without re-analyzing.

### /next refresh
Re-analyze and update TODO.md, skip confirmation for unchanged items.

### /next complete {task}
Mark a task complete, move to Completed section with timestamp.

## Loop Integration

Generated `/loop` commands should:
- Use `--verify` with actual test commands when available
- Use `--until` with detectable completion markers
- Set reasonable `--max` based on task complexity (5-20)
- Include `--max-time` for long-running tasks

## Markers

When completing tasks, output these markers for loop detection:
- `TRACK_A_COMPLETE` - Track A finished
- `TRACK_B_COMPLETE` - Track B finished
- `ALL_TASKS_COMPLETE` - Everything done
- `BLOCKED: {reason}` - Cannot proceed, needs input
