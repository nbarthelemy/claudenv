#!/bin/bash
# Hook: PreToolUse for Write|Edit
# Purpose: Block edits to sensitive Android project files
# Matcher: Write|Edit
# Returns: Exit 2 to block, Exit 0 to allow

set -e

# Read tool input from stdin
INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Exit early if no file path
[[ -z "$FILE" ]] && exit 0

# Only check Kotlin, Gradle, and config files
if [[ "$FILE" != *.kt ]] && \
   [[ "$FILE" != *.kts ]] && \
   [[ "$FILE" != *.properties ]] && \
   [[ "$FILE" != *.xml ]] && \
   [[ "$FILE" != *.json ]]; then
    exit 0
fi

# Protected file patterns for Android projects
PROTECTED_PATTERNS=(
    "Secrets.kt"
    "ApiKeys.kt"
    "Credentials.kt"
    "google-services.json"
    "local.properties"
    "keystore.properties"
    "signing.properties"
    "release.keystore"
    "debug.keystore"
    ".jks"
    "gradle.properties"
    "gradle-wrapper.properties"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
    if [[ "$FILE" == *"$pattern"* ]]; then
        echo "🛡️ Protected Android file: $FILE" >&2
        echo "   This file contains sensitive configuration." >&2
        echo "   Edit manually if changes are needed." >&2
        exit 2  # Block the operation
    fi
done

exit 0  # Allow the operation
