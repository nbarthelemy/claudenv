---
description: "Run iOS unit and UI tests"
allowed-tools:
  - Bash
  - mcp__xcodebuildmcp__*
---

# /ios:test - Run iOS Tests

Run unit tests and optionally UI tests for the iOS project.

## Usage

```bash
/ios:test               # Run all unit tests
/ios:test ui            # Run UI tests
/ios:test <TestClass>   # Run specific test class
```

## With XcodeBuildMCP (Preferred)

```
mcp__xcodebuildmcp__test_sim_name_proj    # Run tests on simulator
mcp__xcodebuildmcp__swift_package_test    # Swift Package tests
```

## Without MCP (Fallback)

```bash
# Run all tests
xcodebuild test \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test class
xcodebuild test \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:<Target>/<TestClass>

# Swift Package tests
swift test
```

## Test Output

Report results as:
- Total tests run
- Passed/Failed count
- Failed test details with file:line
- Code coverage if available

## On Failure

1. Show failing test name and assertion
2. Show relevant code context
3. Explain why the test might be failing
4. Suggest fixes
