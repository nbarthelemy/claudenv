#!/bin/bash
# Read-Before-Write Enforcement
# Blocks edits to files that haven't been read in this session
#
# Exit codes:
#   0 = Allow (file was read, or exempt)
#   2 = Block with message (file not read)

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
STATE_DIR="$PROJECT_ROOT/.claude/state"
READ_FILE="$STATE_DIR/.files-read"

# Check if disabled
[ -f "$PROJECT_ROOT/.claude/read-before-write-disabled" ] && exit 0

# Read tool input from stdin
INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Normalize path
if [[ "$FILE_PATH" = /* ]]; then
    NORMALIZED="${FILE_PATH#$PROJECT_ROOT/}"
else
    NORMALIZED="$FILE_PATH"
fi

# Always allow new files (don't exist yet)
FULL_PATH="$PROJECT_ROOT/$NORMALIZED"
[ ! -f "$FULL_PATH" ] && exit 0

# Always allow .claude/ files
[[ "$NORMALIZED" == .claude/* ]] && exit 0

# Always allow test files
[[ "$NORMALIZED" == *.test.* ]] && exit 0
[[ "$NORMALIZED" == *.spec.* ]] && exit 0
[[ "$NORMALIZED" == test_* ]] && exit 0
[[ "$NORMALIZED" == *_test.* ]] && exit 0

# Always allow config files
[[ "$NORMALIZED" == *.config.* ]] && exit 0
[[ "$NORMALIZED" == *.json ]] && exit 0
[[ "$NORMALIZED" == *.yaml ]] && exit 0
[[ "$NORMALIZED" == *.yml ]] && exit 0
[[ "$NORMALIZED" == *.toml ]] && exit 0
[[ "$NORMALIZED" == *.md ]] && exit 0

# Always allow type definition files
[[ "$NORMALIZED" == *.d.ts ]] && exit 0
[[ "$NORMALIZED" == */types.ts ]] && exit 0
[[ "$NORMALIZED" == */types/*.ts ]] && exit 0

# Check if file was read
if [ -f "$READ_FILE" ] && grep -Fxq "$NORMALIZED" "$READ_FILE" 2>/dev/null; then
    exit 0  # File was read, allow
fi

# File not read - block
cat << EOF

READ BEFORE WRITE: Read the file first!

  Attempting to edit: $NORMALIZED

  You haven't read this file in the current session.
  Reading files before editing prevents speculation and ensures
  you understand the existing code structure.

  Options:
    1. Read the file first (recommended)
    2. Disable enforcement: touch .claude/read-before-write-disabled

EOF
exit 2
