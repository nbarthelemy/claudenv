#!/bin/bash
# Focus Enforcement Hook
# Blocks edits outside current focus scope when focus is locked
#
# Exit codes:
#   0 = Allow (no focus lock, or file in scope)
#   2 = Block with message (file outside locked focus)

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

PROJECT_ROOT=$(find_project_root) || exit 0
STATE_FILE="$PROJECT_ROOT/.claude/state/session-state.json"

# If no state file, allow everything
[ ! -f "$STATE_FILE" ] && exit 0

# Check if jq is available
command -v jq &> /dev/null || exit 0

# Read tool input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

# If no file path, allow (not a file operation)
[ -z "$FILE_PATH" ] && exit 0

# Get focus state
FOCUS_LOCKED=$(jq -r '.focus.locked' "$STATE_FILE" 2>/dev/null)
ACTIVE_PLAN=$(jq -r '.focus.activePlan // empty' "$STATE_FILE" 2>/dev/null)
CURRENT_TASK=$(jq -r '.focus.currentTask // empty' "$STATE_FILE" 2>/dev/null)

# If focus not locked, allow everything
[ "$FOCUS_LOCKED" != "true" ] && exit 0

# If no active plan, allow everything (shouldn't happen if locked, but safety)
[ -z "$ACTIVE_PLAN" ] && exit 0

# Get files in scope
FILES_IN_SCOPE=$(jq -r '.focus.filesInScope[]' "$STATE_FILE" 2>/dev/null)

# If no files specified in scope, allow all (focus is on plan, not specific files)
[ -z "$FILES_IN_SCOPE" ] && exit 0

# Normalize file path (remove project root prefix if absolute)
NORMALIZED_PATH="$FILE_PATH"
if [[ "$FILE_PATH" = /* ]]; then
    NORMALIZED_PATH="${FILE_PATH#$PROJECT_ROOT/}"
fi

# Always allow .claude/ files (infrastructure)
if [[ "$NORMALIZED_PATH" == .claude/* ]]; then
    exit 0
fi

# Always allow test files
if [[ "$NORMALIZED_PATH" == *.test.* ]] || [[ "$NORMALIZED_PATH" == *.spec.* ]] || [[ "$NORMALIZED_PATH" == test_* ]] || [[ "$NORMALIZED_PATH" == *_test.* ]]; then
    exit 0
fi

# Check if file is in scope
for scope_file in $FILES_IN_SCOPE; do
    # Exact match
    if [ "$NORMALIZED_PATH" = "$scope_file" ]; then
        exit 0
    fi
    # Directory match (file is under a scoped directory)
    if [[ "$NORMALIZED_PATH" == ${scope_file}/* ]]; then
        exit 0
    fi
    # Pattern match (scope_file contains wildcards)
    if [[ "$scope_file" == *"*"* ]] && [[ "$NORMALIZED_PATH" == $scope_file ]]; then
        exit 0
    fi
done

# File is outside focus scope - block
cat << EOF

FOCUS LOCK: File outside current scope!

  Editing: $NORMALIZED_PATH

  Current focus: $CURRENT_TASK
  Plan: $ACTIVE_PLAN

  Files in scope:
$(echo "$FILES_IN_SCOPE" | while read f; do echo "    • $f"; done)

  Options:
    1. Edit a file in scope instead
    2. Unlock focus: /ce:focus unlock
    3. Add file to scope: Update plan's files: field
    4. Complete current task: /ce:focus clear

EOF
exit 2
