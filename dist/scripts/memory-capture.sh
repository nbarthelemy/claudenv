#!/bin/bash
# Memory Capture Hook
# Queues tool observations to pending file for later processing
# Called by PostToolUse hook - must be fast and non-blocking
# Usage: memory-capture.sh (reads JSON from stdin)

# Find project root
find_project_root() {
    local dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.claude" ]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

PROJECT_ROOT=$(find_project_root)
if [ -z "$PROJECT_ROOT" ]; then
    exit 0  # Silently exit if not in a project
fi
cd "$PROJECT_ROOT" || exit 0

MEMORY_DIR=".claude/memory"
PENDING_FILE="$MEMORY_DIR/.pending-observations.jsonl"
SESSION_FILE=".claude/state/session-state.json"

# Ensure memory directory exists
mkdir -p "$MEMORY_DIR"

# Read hook data from stdin (Claude Code pipes JSON to hooks)
HOOK_DATA=$(cat)

# Parse tool information from stdin JSON
TOOL_NAME=""
TOOL_INPUT=""
TOOL_OUTPUT=""
FILE_PATH=""

if [ -n "$HOOK_DATA" ] && command -v jq &> /dev/null; then
    TOOL_NAME=$(echo "$HOOK_DATA" | jq -r '.tool_name // empty' 2>/dev/null)
    TOOL_INPUT=$(echo "$HOOK_DATA" | jq -r '.tool_input // empty' 2>/dev/null | head -c 1000)
    TOOL_OUTPUT=$(echo "$HOOK_DATA" | jq -r '.tool_response // empty' 2>/dev/null | head -c 2000)
    FILE_PATH=$(echo "$HOOK_DATA" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
fi

# Exit if no tool information
if [ -z "$TOOL_NAME" ]; then
    exit 0
fi

# Determine importance based on tool type
case "$TOOL_NAME" in
    Write|Edit|MultiEdit)
        IMPORTANCE=2
        ;;
    Bash)
        # Check for significant commands
        if echo "$TOOL_INPUT" | grep -qE '(git commit|npm publish|deploy|migration)'; then
            IMPORTANCE=3
        else
            IMPORTANCE=1
        fi
        ;;
    Read|Glob|Grep)
        IMPORTANCE=1
        ;;
    *)
        IMPORTANCE=1
        ;;
esac

# Get session ID
SESSION_ID="unknown"
if [ -f "$SESSION_FILE" ] && command -v jq &> /dev/null; then
    SESSION_ID=$(jq -r '.metadata.sessionId // "unknown"' "$SESSION_FILE" 2>/dev/null)
fi

# Get current timestamp
TIMESTAMP=$(date -Iseconds)

# Build files_involved array
if [ -n "$FILE_PATH" ]; then
    FILES_INVOLVED=$(jq -nc --arg fp "$FILE_PATH" '[$fp]')
else
    FILES_INVOLVED="[]"
fi

# Build output JSON with jq for proper escaping
jq -nc \
    --arg sid "$SESSION_ID" \
    --arg ts "$TIMESTAMP" \
    --arg tn "$TOOL_NAME" \
    --arg ti "${TOOL_INPUT:0:1000}" \
    --arg to "${TOOL_OUTPUT:0:2000}" \
    --argjson fi "$FILES_INVOLVED" \
    --argjson imp "$IMPORTANCE" \
    '{session_id:$sid,timestamp:$ts,tool_name:$tn,tool_input:$ti,tool_output:$to,files_involved:$fi,importance:$imp}' \
    >> "$PENDING_FILE"

exit 0
