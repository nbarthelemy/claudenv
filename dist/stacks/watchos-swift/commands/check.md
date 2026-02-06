---
description: Run quality checks for watchOS Swift project
allowed-tools:
  - Bash
---

# /check - watchOS Swift Quality Validation

Run comprehensive quality checks for the watchOS project.

## Commands

Execute these commands in order:

```bash
# 1. SwiftLint (if installed)
swiftlint lint --strict

# 2. Build for watchOS Simulator
xcodebuild -scheme YourScheme -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' build

# 3. Run tests
xcodebuild test -scheme YourScheme -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)'
```

## Alternative (Swift Package)

```bash
# Build
swift build

# Test
swift test
```

## Success Criteria

All commands must pass (exit code 0).

## On Failure

1. Show the specific error output
2. Identify the affected files
3. Suggest fixes based on error type
