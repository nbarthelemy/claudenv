---
description: "Run Android unit and instrumented tests"
allowed-tools:
  - Bash
---

# /android:test - Run Android Tests

Run unit tests and optionally instrumented tests.

## Usage

```bash
/android:test               # Run all unit tests
/android:test instrumented  # Run instrumented tests on device/emulator
/android:test <TestClass>   # Run specific test class
```

## Commands

```bash
# All unit tests
./gradlew test

# Debug unit tests only
./gradlew testDebugUnitTest

# Instrumented tests (requires device/emulator)
./gradlew connectedAndroidTest

# Specific test class
./gradlew test --tests "com.example.MyTest"

# Test with coverage
./gradlew testDebugUnitTest jacocoTestReport
```

## Test Output

Report results as:
- Total tests run
- Passed/Failed count
- Failed test details with file:line
- Coverage percentage if available

## On Failure

1. Show failing test name and assertion
2. Show relevant code context
3. Explain why the test might be failing
4. Suggest fixes
