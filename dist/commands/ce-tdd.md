---
name: /ce:tdd
description: Test-Driven Development workflow
invokes: ce:tdd
---

# /ce:tdd

Test-Driven Development workflow enforcement and guidance.

## Usage

```bash
/ce:tdd                    # Show TDD status
/ce:tdd enable             # Enable TDD enforcement
/ce:tdd disable            # Disable TDD enforcement
/ce:tdd <feature>          # Start TDD workflow for feature
```

## Examples

```bash
/ce:tdd enable                      # Turn on hook blocking
/ce:tdd "user authentication"       # Start TDD for auth feature
/ce:tdd disable                     # Turn off hook blocking
```

## What It Does

- **enable**: Creates `.claude/tdd-enabled` marker, activating PreToolUse hook
- **disable**: Removes marker, allowing writes without test requirement
- **status**: Shows if TDD is enabled and test coverage
- **<feature>**: Guides you through red-green-refactor cycle

## TDD Workflow

1. **RED**: Write a failing test first
2. **GREEN**: Write minimal code to pass
3. **REFACTOR**: Clean up while tests stay green
