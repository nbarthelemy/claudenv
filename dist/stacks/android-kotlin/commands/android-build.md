---
description: "Build Android project for debug or release"
allowed-tools:
  - Bash
---

# /android:build - Build Android Project

Build the Android project using Gradle.

## Usage

```bash
/android:build              # Build debug (default)
/android:build release      # Build release
/android:build clean        # Clean then build
/android:build bundle       # Build app bundle (AAB)
```

## Commands

```bash
# Debug build
./gradlew assembleDebug

# Release build
./gradlew assembleRelease

# Clean build
./gradlew clean assembleDebug

# App bundle for Play Store
./gradlew bundleRelease

# Build specific module
./gradlew :app:assembleDebug
```

## Build Variants

```bash
# List available variants
./gradlew tasks --group=build

# Build specific flavor
./gradlew assembleFreeDebug
./gradlew assemblePaidRelease
```

## On Failure

1. Show build errors with file locations
2. Identify the root cause (missing dependency, type error, etc.)
3. Suggest specific fixes
4. Re-run build after fixes
