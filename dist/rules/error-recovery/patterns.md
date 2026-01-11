# Common Error Patterns

> Detailed examples for specific error scenarios. Load on-demand when encountering unfamiliar errors.

## Command Not Found

1. Check if tool is installed: `which <tool>` or `type <tool>`
2. Check alternative names: `python3` vs `python`, `pip3` vs `pip`
3. Suggest installation if missing

## Permission Denied

1. Check file permissions: `ls -la <file>`
2. Check if running in correct directory
3. Check if file is locked by another process

## Module/Package Not Found

1. Check if in correct virtual environment
2. Check if package is installed: `pip list | grep <package>`
3. Try installing: `pip install <package>` (dev deps only)

## Git Errors

1. Check current branch: `git branch`
2. Check for uncommitted changes: `git status`
3. Check for conflicts: `git diff`

## Build/Compile Errors

1. Read the full error message
2. Check line numbers and file references
3. Run linter/type-checker for more context
4. Check recent changes that might have caused the issue

## Logging Errors

All errors should be logged to `.claude/logs/errors.log`:

```
[TIMESTAMP] ERROR in <context>
Command: <command>
Output: <output>
Attempt: <1|2|3>
Resolution: <what was tried>
Status: <resolved|escalated>
```
