#!/bin/bash
# Learn Review Script
# Consolidates all pending file reads into a single output

LEARNING_DIR=".claude/learning"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Learning Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Count pending items
PENDING_SKILLS=$(grep -c "^### " "$LEARNING_DIR/pending-skills.md" 2>/dev/null) || PENDING_SKILLS=0
PENDING_AGENTS=$(grep -c "^### " "$LEARNING_DIR/pending-agents.md" 2>/dev/null) || PENDING_AGENTS=0
PENDING_COMMANDS=$(grep -c "^### " "$LEARNING_DIR/pending-commands.md" 2>/dev/null) || PENDING_COMMANDS=0
PENDING_HOOKS=$(grep -c "^### " "$LEARNING_DIR/pending-hooks.md" 2>/dev/null) || PENDING_HOOKS=0

# Skills
echo "## Pending Skills ($PENDING_SKILLS)"
echo ""
if [ "$PENDING_SKILLS" -gt 0 ]; then
    # Extract skill entries
    awk '/^### /{found=1} found{print} /^---$/{found=0}' "$LEARNING_DIR/pending-skills.md" 2>/dev/null | head -100
else
    echo "No pending skill proposals."
fi
echo ""

# Agents
echo "## Pending Agents ($PENDING_AGENTS)"
echo ""
if [ "$PENDING_AGENTS" -gt 0 ]; then
    awk '/^### /{found=1} found{print} /^---$/{found=0}' "$LEARNING_DIR/pending-agents.md" 2>/dev/null | head -100
else
    echo "No pending agent proposals."
fi
echo ""

# Commands
echo "## Pending Commands ($PENDING_COMMANDS)"
echo ""
if [ "$PENDING_COMMANDS" -gt 0 ]; then
    awk '/^### /{found=1} found{print} /^---$/{found=0}' "$LEARNING_DIR/pending-commands.md" 2>/dev/null | head -100
else
    echo "No pending command proposals."
fi
echo ""

# Hooks
echo "## Pending Hooks ($PENDING_HOOKS)"
echo ""
if [ "$PENDING_HOOKS" -gt 0 ]; then
    awk '/^### /{found=1} found{print} /^---$/{found=0}' "$LEARNING_DIR/pending-hooks.md" 2>/dev/null | head -100
else
    echo "No pending hook proposals."
fi
echo ""

# Observations summary
echo "## Recent Observations"
echo ""
if [ -f "$LEARNING_DIR/observations.md" ]; then
    OBS_COUNT=$(grep -c "^## " "$LEARNING_DIR/observations.md" 2>/dev/null) || OBS_COUNT=0
    if [ "$OBS_COUNT" -gt 1 ]; then
        echo "($OBS_COUNT entries in observations.md)"
        # Show last 5 session entries
        grep -A2 "^## Session" "$LEARNING_DIR/observations.md" 2>/dev/null | tail -15
    else
        echo "No patterns observed yet."
    fi
else
    echo "No observations file found."
fi
echo ""

# Pattern tracking status
if [ -f "$LEARNING_DIR/patterns.json" ]; then
    DIR_PATTERNS=$(jq '.directory_patterns | length' "$LEARNING_DIR/patterns.json" 2>/dev/null) || DIR_PATTERNS=0
    EXT_PATTERNS=$(jq '.extension_patterns | length' "$LEARNING_DIR/patterns.json" 2>/dev/null) || EXT_PATTERNS=0

    if [ "$DIR_PATTERNS" -gt 0 ] || [ "$EXT_PATTERNS" -gt 0 ]; then
        echo "## Pattern Tracking"
        echo ""
        echo "Directories tracked: $DIR_PATTERNS"
        echo "Extensions tracked: $EXT_PATTERNS"
        echo ""
        echo "Thresholds: Skills=3 edits, Agents=5 edits"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PENDING_SKILLS + PENDING_AGENTS + PENDING_COMMANDS + PENDING_HOOKS))
if [ "$TOTAL" -gt 0 ]; then
    echo "To implement: /learn:implement <name>"
else
    echo "No pending proposals. Patterns are tracked as you work."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
