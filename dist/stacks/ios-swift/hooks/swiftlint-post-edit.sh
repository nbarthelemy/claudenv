#!/bin/bash
# Hook: PostToolUse for Write|Edit
# Purpose: Run SwiftLint on edited Swift files
# Matcher: Write|Edit
# Conditional: Only runs for .swift files in iOS project directories

set -e

# Read tool input from stdin
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE" ]] && exit 0

# Only process .swift files
[[ "$FILE" != *.swift ]] && exit 0

# Skip test files (optional - remove if you want to lint tests)
# [[ "$FILE" == *Tests*.swift ]] && exit 0

# Check if file is in an iOS project directory
# Customize these patterns for your project structure
if [[ "$FILE" != */App/* ]] && \
   [[ "$FILE" != */Features/* ]] && \
   [[ "$FILE" != */Core/* ]] && \
   [[ "$FILE" != */Sources/* ]] && \
   [[ "$FILE" != */Models/* ]] && \
   [[ "$FILE" != */Views/* ]] && \
   [[ "$FILE" != */ViewModels/* ]] && \
   [[ "$FILE" != */Services/* ]]; then
    exit 0
fi

# Run SwiftLint if available and config exists
if command -v swiftlint &> /dev/null; then
    if [[ -f ".swiftlint.yml" ]] || [[ -f ".swiftlint.yaml" ]]; then
        # Lint only the edited file, show max 5 issues
        swiftlint lint --path "$FILE" --quiet 2>&1 | head -5 >&2 || true
    fi
fi

# Run swift-format check if available
if command -v swift-format &> /dev/null; then
    swift-format lint "$FILE" 2>&1 | head -3 >&2 || true
fi

exit 0
