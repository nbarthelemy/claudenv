#!/bin/bash
# Hook: PreToolUse for Write|Edit
# Purpose: Block edits to sensitive iOS project files
# Matcher: Write|Edit
# Returns: Exit 2 to block, Exit 0 to allow

set -e

# Read tool input from stdin
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE" ]] && exit 0

# Only check .swift and iOS config files
if [[ "$FILE" != *.swift ]] && \
   [[ "$FILE" != *.plist ]] && \
   [[ "$FILE" != *.xcconfig ]]; then
    exit 0
fi

# Protected file patterns for iOS projects
PROTECTED_PATTERNS=(
    "Secrets.swift"
    "APIKeys.swift"
    "Credentials.swift"
    "GoogleService-Info.plist"
    "Info.plist"
    ".xcconfig"
    "Podfile.lock"
    "Package.resolved"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$FILE" == *"$pattern"* ]]; then
        echo "🛡️ Protected iOS file: $FILE" >&2
        echo "   This file contains sensitive configuration." >&2
        echo "   Edit manually if changes are needed." >&2
        exit 2  # Block the operation
    fi
done

exit 0  # Allow the operation
