---
description: "Diagnose and fix Android build errors"
allowed-tools:
  - Read
  - Edit
  - Bash
---

# /android:fix - Fix Android Build Errors

Diagnose build errors and apply fixes.

## Usage

```bash
/android:fix                # Analyze and fix current build errors
/android:fix --clean        # Clean, rebuild, then fix
```

## Process

1. **Clean build** to get fresh errors:
   ```bash
   ./gradlew clean
   ./gradlew assembleDebug 2>&1
   ```

2. **Parse errors** - Extract:
   - File path and line number
   - Error type (syntax, type, missing import, etc.)
   - Error message

3. **Categorize and prioritize**:
   - Missing imports → add import statements
   - Type mismatches → fix types or add conversions
   - Missing dependencies → add to build.gradle.kts
   - Compose errors → fix @Composable usage
   - Hilt errors → fix injection annotations

4. **Apply fixes** one at a time

5. **Rebuild** to verify

6. **Repeat** until build succeeds

## Common Error Patterns

| Error | Fix |
|-------|-----|
| `Unresolved reference: X` | Add import or dependency |
| `Type mismatch: inferred type is X but Y was expected` | Fix types or add cast |
| `@Composable invocations can only happen from...` | Move call to @Composable function |
| `Cannot create instance of class ViewModel` | Add @HiltViewModel and @Inject constructor |
| `Missing Hilt binding` | Add @Provides or @Binds in Module |
| `Suspend function 'X' should be called only from a coroutine` | Use coroutine scope or suspend |

## Gradle-Specific Fixes

```bash
# Clear Gradle cache
./gradlew cleanBuildCache

# Refresh dependencies
./gradlew --refresh-dependencies

# Invalidate caches
rm -rf ~/.gradle/caches/
```

## Limits

- Maximum 3 fix iterations
- If still failing after 3 attempts, report remaining errors and ask for guidance
