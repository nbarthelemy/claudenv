#!/bin/bash
# Learning Observer Hook Script
# Triggered after file modifications and bash commands to capture patterns

LEARNING_DIR=".claude/learning"
OBSERVATIONS_FILE="$LEARNING_DIR/observations.md"
PATTERNS_FILE="$LEARNING_DIR/patterns.json"

# Ensure learning directory exists
mkdir -p "$LEARNING_DIR"

# Initialize patterns file if missing
if [ ! -f "$PATTERNS_FILE" ]; then
    echo '{"patterns":[],"last_analysis":"never"}' > "$PATTERNS_FILE"
fi

# Get current timestamp
TIMESTAMP=$(date -Iseconds)

# Determine context
CONTEXT=""
if [ "$1" = "--pre-commit" ]; then
    CONTEXT="pre-commit"
elif [ -n "$CLAUDE_TOOL_NAME" ]; then
    CONTEXT="$CLAUDE_TOOL_NAME"
else
    CONTEXT="unknown"
fi

# Log observation (lightweight - just append to file)
log_observation() {
    local type="$1"
    local detail="$2"

    # Create observations file if missing
    if [ ! -f "$OBSERVATIONS_FILE" ]; then
        cat > "$OBSERVATIONS_FILE" << 'EOF'
# Learning Observations

This file captures development patterns observed during sessions.
The learning-agent skill analyzes these to suggest automations.

---

## Observations Log

EOF
    fi

    # Append observation
    echo "- [$TIMESTAMP] **$type**: $detail" >> "$OBSERVATIONS_FILE"
}

# Capture file modification patterns
if [ "$CONTEXT" = "Write" ] || [ "$CONTEXT" = "Edit" ] || [ "$CONTEXT" = "MultiEdit" ]; then
    # Extract file extension pattern
    if [ -n "$CLAUDE_TOOL_INPUT" ]; then
        FILE_EXT="${CLAUDE_TOOL_INPUT##*.}"
        log_observation "file_modify" "Modified .$FILE_EXT file"
    fi
fi

# Capture bash command patterns
if [ "$CONTEXT" = "Bash" ]; then
    if [ -n "$CLAUDE_TOOL_INPUT" ]; then
        # Extract command name (first word)
        CMD_NAME=$(echo "$CLAUDE_TOOL_INPUT" | awk '{print $1}')
        log_observation "bash_cmd" "Ran: $CMD_NAME"
    fi
fi

# Pre-commit analysis trigger
if [ "$CONTEXT" = "pre-commit" ]; then
    log_observation "milestone" "Pre-commit checkpoint"

    # Count recent observations
    if [ -f "$OBSERVATIONS_FILE" ]; then
        OBS_COUNT=$(grep -c "^\- \[" "$OBSERVATIONS_FILE" 2>/dev/null || echo "0")

        # If significant activity, mark for analysis
        if [ "$OBS_COUNT" -gt 10 ]; then
            echo "$TIMESTAMP" > "$LEARNING_DIR/.needs_analysis"
        fi
    fi
fi

exit 0
