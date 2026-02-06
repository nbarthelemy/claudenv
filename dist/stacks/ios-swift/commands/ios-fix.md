---
description: "Diagnose and fix iOS build errors"
allowed-tools:
  - Read
  - Edit
  - Bash
  - mcp__xcodebuildmcp__*
---

# /ios:fix - Fix iOS Build Errors

Diagnose build errors and apply fixes.

## Usage

```bash
/ios:fix                # Analyze and fix current build errors
/ios:fix --clean        # Clean, rebuild, then fix
```

## Process

1. **Clean build** to get fresh errors:
   ```
   mcp__xcodebuildmcp__clean
   mcp__xcodebuildmcp__build_sim_name_proj
   ```

2. **Parse errors** - Extract:
   - File path and line number
   - Error type (syntax, type, missing import, etc.)
   - Error message

3. **Categorize and prioritize**:
   - Missing imports → add import statements
   - Type mismatches → fix types or add conversions
   - Missing conformances → implement required protocols
   - Concurrency issues → add @MainActor, Sendable, etc.

4. **Apply fixes** one at a time

5. **Rebuild** to verify

6. **Repeat** until build succeeds

## Common Error Patterns

| Error | Fix |
|-------|-----|
| `Cannot find 'X' in scope` | Add import or fix typo |
| `Type 'X' does not conform to protocol 'Y'` | Implement missing requirements |
| `Cannot convert value of type 'X' to 'Y'` | Add explicit conversion |
| `Call to main actor-isolated function` | Add @MainActor or use Task { @MainActor in } |
| `Reference to captured var 'X' in concurrently-executing code` | Use let binding or actor |

## Limits

- Maximum 3 fix iterations
- If still failing after 3 attempts, report remaining errors and ask for guidance
