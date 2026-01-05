#!/bin/bash
# Session End Hook
# Runs when Claude finishes a session

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Session Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Git stats (if in a git repo)
if git rev-parse --git-dir > /dev/null 2>&1; then
    # Count commits since session start (approximate - last hour)
    RECENT_COMMITS=$(git rev-list --count --since="1 hour ago" HEAD 2>/dev/null || echo "0")
    echo "📝 Recent commits: $RECENT_COMMITS"

    # Files with uncommitted changes
    CHANGED=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CHANGED" -gt 0 ]; then
        echo "📁 Uncommitted changes: $CHANGED files"
    fi
fi

# Check for new pending learnings
PENDING_SKILLS=$(grep -c "^## " .claude/learning/pending-skills.md 2>/dev/null || echo "0")
PENDING_AGENTS=$(grep -c "^## " .claude/learning/pending-agents.md 2>/dev/null || echo "0")
PENDING_COMMANDS=$(grep -c "^## " .claude/learning/pending-commands.md 2>/dev/null || echo "0")
PENDING_HOOKS=$(grep -c "^## " .claude/learning/pending-hooks.md 2>/dev/null || echo "0")

TOTAL_PENDING=$((PENDING_SKILLS + PENDING_AGENTS + PENDING_COMMANDS + PENDING_HOOKS))

if [ "$TOTAL_PENDING" -gt 0 ]; then
    echo ""
    echo "💡 Learning suggestions pending:"
    [ "$PENDING_SKILLS" -gt 0 ] && echo "   - $PENDING_SKILLS skills"
    [ "$PENDING_AGENTS" -gt 0 ] && echo "   - $PENDING_AGENTS agents"
    [ "$PENDING_COMMANDS" -gt 0 ] && echo "   - $PENDING_COMMANDS commands"
    [ "$PENDING_HOOKS" -gt 0 ] && echo "   - $PENDING_HOOKS hooks"
    echo "   Run /learn:review to see details"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Log session end
echo "[$(date -Iseconds)] Session ended" >> .claude/logs/sessions.log 2>/dev/null || true
