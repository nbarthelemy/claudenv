#!/bin/bash
# Decision Reminder - PostToolUse hook
# Prompts for decision recording after significant changes

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
cd "$PROJECT_ROOT" || exit 0

STATE_DIR=".claude/state"
EDIT_TRACKER="$STATE_DIR/.edits-this-session"
DECISION_PROMPT_SHOWN="$STATE_DIR/.decision-prompt-shown"

mkdir -p "$STATE_DIR"

# Read tool input from stdin
INPUT=$(cat)

# Extract file path from Write/Edit tool
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Normalize path
if [[ "$FILE_PATH" = /* ]]; then
    NORMALIZED="${FILE_PATH#$PROJECT_ROOT/}"
else
    NORMALIZED="$FILE_PATH"
fi

# Track the edit
echo "$NORMALIZED" >> "$EDIT_TRACKER"

# Count unique files edited this session
EDIT_COUNT=$(sort -u "$EDIT_TRACKER" 2>/dev/null | wc -l | tr -d ' ')

# Check for critical file patterns
CRITICAL_PATTERNS=(
    "package.json"
    "requirements.txt"
    "Cargo.toml"
    "go.mod"
    "pyproject.toml"
    "tsconfig.json"
    ".env*"
    "docker-compose*"
    "Dockerfile"
    "*.config.js"
    "*.config.ts"
    ".claude/settings*.json"
    "schema.prisma"
    "migrations/*"
)

IS_CRITICAL=false
for pattern in "${CRITICAL_PATTERNS[@]}"; do
    if [[ "$NORMALIZED" == $pattern ]]; then
        IS_CRITICAL=true
        break
    fi
done

# Decide if we should prompt
SHOULD_PROMPT=false

# Prompt after 5+ files OR any critical file
if [ "$EDIT_COUNT" -ge 5 ] || [ "$IS_CRITICAL" = true ]; then
    # Check if we already prompted this session (avoid spamming)
    if [ -f "$DECISION_PROMPT_SHOWN" ]; then
        LAST_PROMPT_COUNT=$(cat "$DECISION_PROMPT_SHOWN")
        # Only re-prompt every 5 additional edits
        if [ $((EDIT_COUNT - LAST_PROMPT_COUNT)) -ge 5 ]; then
            SHOULD_PROMPT=true
        fi
    else
        SHOULD_PROMPT=true
    fi
fi

# Show reminder if needed
if [ "$SHOULD_PROMPT" = true ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 Decision Recording Reminder"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [ "$IS_CRITICAL" = true ]; then
        echo "Critical file modified: $NORMALIZED"
    else
        echo "Significant changes made ($EDIT_COUNT files)"
    fi
    echo ""
    echo "Consider recording key decisions:"
    echo "   /ce:focus decision \"why this approach\""
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Mark that we showed the prompt
    echo "$EDIT_COUNT" > "$DECISION_PROMPT_SHOWN"
fi

exit 0
