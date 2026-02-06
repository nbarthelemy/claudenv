#!/bin/bash
# Hook: PostToolUse for Write|Edit
# Purpose: Run ktlint on edited Kotlin files
# Matcher: Write|Edit
# Conditional: Only runs for .kt files in Android project directories

set -e

# Read tool input from stdin
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE" ]] && exit 0

# Only process .kt and .kts files
[[ "$FILE" != *.kt ]] && [[ "$FILE" != *.kts ]] && exit 0

# Skip test files (optional - remove if you want to lint tests)
# [[ "$FILE" == *Test.kt ]] && exit 0

# Check if file is in an Android project directory
# Customize these patterns for your project structure
if [[ "$FILE" != */src/main/* ]] && \
   [[ "$FILE" != */src/debug/* ]] && \
   [[ "$FILE" != */src/release/* ]] && \
   [[ "$FILE" != */ui/* ]] && \
   [[ "$FILE" != */viewmodel/* ]] && \
   [[ "$FILE" != */data/* ]] && \
   [[ "$FILE" != */domain/* ]] && \
   [[ "$FILE" != */di/* ]]; then
    exit 0
fi

# Run ktlint if available via Gradle
if [[ -f "gradlew" ]]; then
    # Check if ktlint task exists
    if ./gradlew tasks --all 2>/dev/null | grep -q "ktlintCheck"; then
        # Run ktlint on just this file pattern
        ./gradlew ktlintCheck --quiet 2>&1 | head -5 >&2 || true
    fi
fi

# Alternative: run ktlint directly if installed
if command -v ktlint &> /dev/null; then
    ktlint "$FILE" 2>&1 | head -5 >&2 || true
fi

exit 0
