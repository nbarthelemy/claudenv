---
description: Run quality checks for Android Kotlin project
allowed-tools:
  - Bash
---

# /android:check - Android Kotlin Quality Validation

Run comprehensive quality checks for the Android project.

## Commands

Execute these commands in order:

```bash
# 1. Lint check
./gradlew lint

# 2. Kotlin linting (if ktlint configured)
./gradlew ktlintCheck

# 3. Unit tests
./gradlew test

# 4. Build validation
./gradlew assembleDebug
```

## Success Criteria

All commands must pass (exit code 0).

## On Failure

1. Show the specific error output
2. Identify the affected files
3. Suggest fixes based on error type
