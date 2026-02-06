---
description: "Run workspace test suite"
allowed-tools: Bash
---

# /ws:test - Run Workspace Tests

Run the siquora workspace test suite.

## Usage

```bash
/ws:test                    # Run all tests
/ws:test structure          # Run only structure tests
/ws:test sync               # Run only sync tests
/ws:test stacks             # Run only stack tests
/ws:test platforms          # Run only platform tests
/ws:test content            # Run only content tests
```

## Process

```bash
bash .claude/tests/run-tests.sh [filter]
```

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Siquora Workspace Test Suite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✓ Test description (passed)
  ✗ Test description (failed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Tests run:    N
  Passed:       N
  Failed:       N

  All tests passed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Test Categories

| Category | Tests |
|----------|-------|
| structure | Workspace directories, manifest, stack/platform definitions |
| stacks | Stack agents, skills, commands, templates |
| platforms | Platform agents, commands, rules |
| content | Agent frontmatter, skill format, command format |
| sync | Sync script, project validation, idempotency |
