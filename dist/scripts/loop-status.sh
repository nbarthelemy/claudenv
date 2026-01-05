#!/bin/bash
# Loop Status Script
# Displays current autonomous loop status

STATE_FILE=".claude/loop/state.json"

# Check for active loop
if [ ! -f "$STATE_FILE" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 LOOP STATUS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "No active loop found."
    echo ""
    echo "Start one with:"
    echo "  /loop \"<task>\" --until \"<condition>\" --max 10"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
fi

# Read state
PROMPT=$(jq -r '.prompt // "unknown"' "$STATE_FILE" 2>/dev/null)
STATUS=$(jq -r '.status // "unknown"' "$STATE_FILE" 2>/dev/null)
CURRENT=$(jq -r '.current_iteration // 0' "$STATE_FILE" 2>/dev/null)
MAX=$(jq -r '.max_iterations // 20' "$STATE_FILE" 2>/dev/null)
START_TIME=$(jq -r '.start_time // ""' "$STATE_FILE" 2>/dev/null)
CONDITION_TYPE=$(jq -r '.condition.type // "unknown"' "$STATE_FILE" 2>/dev/null)
CONDITION_TARGET=$(jq -r '.condition.target // ""' "$STATE_FILE" 2>/dev/null)
CONDITION_MET=$(jq -r '.condition_met // false' "$STATE_FILE" 2>/dev/null)
MAX_TIME=$(jq -r '.max_time // "2h"' "$STATE_FILE" 2>/dev/null)
MAX_COST=$(jq -r '.max_cost // "not set"' "$STATE_FILE" 2>/dev/null)
LAST_CHECKPOINT=$(jq -r '.last_checkpoint // ""' "$STATE_FILE" 2>/dev/null)
FILES_MODIFIED=$(jq -r '.files_modified // 0' "$STATE_FILE" 2>/dev/null)
EST_COST=$(jq -r '.estimated_cost // "unknown"' "$STATE_FILE" 2>/dev/null)

# Calculate elapsed time
if [ -n "$START_TIME" ]; then
    START_EPOCH=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${START_TIME%%.*}" "+%s" 2>/dev/null || echo "0")
    NOW_EPOCH=$(date "+%s")
    if [ "$START_EPOCH" -gt 0 ]; then
        ELAPSED_SECS=$((NOW_EPOCH - START_EPOCH))
        ELAPSED_MINS=$((ELAPSED_SECS / 60))
        ELAPSED_HRS=$((ELAPSED_MINS / 60))
        ELAPSED_MINS=$((ELAPSED_MINS % 60))
        ELAPSED="${ELAPSED_HRS}h ${ELAPSED_MINS}m"
    else
        ELAPSED="unknown"
    fi
else
    ELAPSED="unknown"
fi

# Calculate remaining iterations
REMAINING=$((MAX - CURRENT))

# Status emoji
case "$STATUS" in
    running) STATUS_EMOJI="🟢" ;;
    paused)  STATUS_EMOJI="⏸️" ;;
    complete) STATUS_EMOJI="✅" ;;
    failed)  STATUS_EMOJI="❌" ;;
    *)       STATUS_EMOJI="❓" ;;
esac

# Progress bar
if [ "$MAX" -gt 0 ]; then
    PCT=$((CURRENT * 100 / MAX))
    FILLED=$((PCT / 5))
    EMPTY=$((20 - FILLED))
    PROGRESS_BAR=$(printf '█%.0s' $(seq 1 $FILLED 2>/dev/null) 2>/dev/null || echo "")
    PROGRESS_BAR="${PROGRESS_BAR}$(printf '░%.0s' $(seq 1 $EMPTY 2>/dev/null) 2>/dev/null || echo "")"
else
    PCT=0
    PROGRESS_BAR="░░░░░░░░░░░░░░░░░░░░"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 LOOP STATUS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Task: $PROMPT"
echo "$STATUS_EMOJI Status: $STATUS"
echo ""
echo "📊 Progress:"
echo "   Iteration: $CURRENT/$MAX"
echo "   [$PROGRESS_BAR] $PCT%"
echo "   Elapsed: $ELAPSED"
[ "$EST_COST" != "unknown" ] && [ "$EST_COST" != "null" ] && echo "   Est. Cost: $EST_COST"
echo ""
echo "🎯 Completion Condition:"
echo "   Type: $CONDITION_TYPE"
[ -n "$CONDITION_TARGET" ] && [ "$CONDITION_TARGET" != "null" ] && echo "   Target: $CONDITION_TARGET"
[ "$CONDITION_MET" = "true" ] && echo "   Met: yes" || echo "   Met: no"
echo ""
echo "🛡️ Safety Limits:"
echo "   Max Iterations: $MAX ($REMAINING remaining)"
echo "   Max Time: $MAX_TIME"
[ "$MAX_COST" != "not set" ] && [ "$MAX_COST" != "null" ] && echo "   Max Cost: $MAX_COST"
echo ""
echo "📁 Recent Activity:"
[ -n "$LAST_CHECKPOINT" ] && [ "$LAST_CHECKPOINT" != "null" ] && echo "   Last checkpoint: $LAST_CHECKPOINT"
echo "   Files modified: $FILES_MODIFIED"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Commands:"
echo "  /loop:pause   - Pause the loop"
echo "  /loop:resume  - Resume paused loop"
echo "  /loop:cancel  - Stop and cancel"
echo "  /loop:history - View past loops"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
