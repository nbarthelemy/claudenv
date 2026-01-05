---
description: Audit permissions configuration against detected tech stack and suggest optimizations.
allowed-tools: Read, Bash(*), Glob
---

# /claudenv:audit - Permission Audit

Analyze permission configuration and suggest optimizations based on detected tech stack.

## Process

1. Read `.claude/settings.json` for current permissions
2. Read `.claude/project-context.json` for detected technologies
3. Read `.claude/skills/tech-detection/command-mappings.json` for tech-to-permission mappings
4. Compare and identify:
   - Permissions for technologies not detected in project
   - Detected technologies missing permissions
   - Overly broad permissions that could be tightened
5. Generate report with suggestions

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Permission Audit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  Total permissions: [N]
  Core (always needed): [N]
  Tech-specific: [N]

Detected Stack:
  Languages: javascript, typescript
  Frameworks: nextjs
  Package Manager: npm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Suggestions:

⚠️  Unused Tech Permissions
   These permissions are allowed but the tech wasn't detected:

   Bash(python:*)     → No Python files found
   Bash(pip:*)        → No requirements.txt or pyproject.toml
   Bash(go:*)         → No go.mod found
   Bash(cargo:*)      → No Cargo.toml found

   Consider removing if not needed.

✓  Matching Permissions
   These correctly match your detected stack:

   Bash(npm:*)        → package.json detected
   Bash(node:*)       → JavaScript/TypeScript project
   Bash(next:*)       → Next.js framework detected

⚠️  Missing Permissions
   Tech detected but permissions not found:

   (none - all detected tech has permissions)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Run `/claudenv` to regenerate permissions based on current stack
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Analysis Logic

### Core Permissions (Always Needed)
These are universal and should always be present:
- File operations: cat, ls, find, grep, head, tail, etc.
- Git operations: git add, commit, status, etc.
- Basic tools: jq, curl, echo, etc.

### Tech-Specific Permissions
Map from command-mappings.json:
- If `python` detected → expect `Bash(python:*)`, `Bash(pip:*)`
- If `npm` detected → expect `Bash(npm:*)`, `Bash(npx:*)`
- etc.

### Detection Sources
Check for tech presence:
- `package.json` → Node.js ecosystem
- `requirements.txt` / `pyproject.toml` → Python
- `go.mod` → Go
- `Cargo.toml` → Rust
- `Gemfile` → Ruby
- etc.

## Commands for Analysis

```bash
# Count total permissions
jq '.permissions.allow | length' .claude/settings.json

# Get detected languages
jq '.languages' .claude/project-context.json

# Check for Python files
find . -name "*.py" -not -path "./node_modules/*" | head -1

# Check for Go files
find . -name "*.go" -not -path "./vendor/*" | head -1
```

## Instructions

1. First check if `project-context.json` exists
   - If not, suggest running `/claudenv` first
2. Compare detected tech with allowed permissions
3. Group findings into: Unused, Matching, Missing
4. Be helpful - explain why each suggestion matters
5. Keep output scannable - use consistent formatting
