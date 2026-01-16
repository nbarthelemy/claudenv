# Permission Matrix

> Full details: `.claude/references/permissions-guide.md`

## Bash Wildcards

`Bash(npm *)` - npm + anything | `Bash(* --help)` - any cmd + --help

## Always Allowed

**Files:** cat, ls, find, grep, head, tail, wc, sort, uniq, sed, awk, mkdir, rm, cp, mv, touch, chmod
**Navigation:** pwd, cd, which, type, file, stat, du, df, tree
**Tools:** bat, rg, fd, diff, tar, zip, unzip, curl, wget, jq, yq
**Git (local):** add, commit, checkout, branch, stash, status, log, diff, fetch, pull, merge, rebase

## Requires Approval

`git push` (any remote)

## Always Denied

- Destructive: `rm -rf /`, fork bombs, disk writes (`dd`, `mkfs`)
- System: `sudo *`, `shutdown`, `reboot`, `killall`
- Remote exec: `curl|sh`, `wget|bash`, `eval`
- Publish: `npm publish`, `cargo publish`, `twine upload`
- Hook bypass: `--no-verify`, `git commit -n`, `--no-gpg-sign`

## Git Hook Enforcement

**NEVER bypass git hooks.** When a pre-commit hook fails:
1. Read the error message
2. Fix the underlying issue (lint, format, types, tests)
3. Stage the fixes
4. Commit again WITHOUT `--no-verify`

The `--no-verify` flag is blocked by a PreToolUse hook. Fix issues, don't bypass them.

## Tech-Specific

Auto-added during `/ce:init` based on detected stack. See `command-mappings.json`.

## Override

In `.claude/settings.local.json`:
```json
{"permissions": {"allow": ["Bash(custom *)"], "deny": ["Bash(npm publish *)"]}}
```
