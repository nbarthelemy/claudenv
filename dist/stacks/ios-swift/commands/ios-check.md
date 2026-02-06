---
description: Run quality checks for iOS Swift project
allowed-tools:
  - Bash
---

# /ios:check - iOS Swift Quality Validation

Run comprehensive quality checks for the iOS project.

## Commands

Execute these commands in order:

```bash
# 1. SwiftLint (if installed)
swiftlint lint --strict

# 2. Build for all platforms
xcodebuild -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 16' build

# 3. Run tests
xcodebuild test -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 16'
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
