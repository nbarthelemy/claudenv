#!/bin/bash
# Health Check Script
# Validates Claudenv infrastructure integrity

PASSED=0
WARNINGS=0
ERRORS=0

pass() { echo "✅ $1"; PASSED=$((PASSED + 1)); }
warn() { echo "⚠️  $1"; WARNINGS=$((WARNINGS + 1)); }
fail() { echo "❌ $1"; ERRORS=$((ERRORS + 1)); }

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏥 Health Check Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Settings Validation
echo "## Settings"

if [ -f ".claude/settings.json" ]; then
    if jq empty .claude/settings.json 2>/dev/null; then
        pass "settings.json valid"

        # Check permissions
        if jq -e '.permissions' .claude/settings.json >/dev/null 2>&1; then
            pass "Permissions configured"
        else
            warn "No permissions configured"
        fi

        # Check hooks
        if jq -e '.hooks' .claude/settings.json >/dev/null 2>&1; then
            pass "Hooks configured"
        else
            warn "No hooks configured"
        fi
    else
        fail "settings.json invalid JSON"
    fi
else
    fail "settings.json missing"
fi
echo ""

# Skill Validation
echo "## Skills"

SKILL_DIRS=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
SKILL_COUNT=0
SKILL_ERRORS=0

if [ -n "$SKILL_DIRS" ]; then
    while IFS= read -r skill_dir; do
        [ -z "$skill_dir" ] && continue
        skill_name=$(basename "$skill_dir")
        SKILL_COUNT=$((SKILL_COUNT + 1))

        if [ -f "$skill_dir/SKILL.md" ]; then
            # Check for frontmatter
            if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
                # Check for required fields
                if grep -q "^name:" "$skill_dir/SKILL.md" && grep -q "^description:" "$skill_dir/SKILL.md"; then
                    pass "$skill_name - valid"
                else
                    warn "$skill_name - missing frontmatter fields"
                fi
            else
                warn "$skill_name - no frontmatter"
            fi
        else
            fail "$skill_name - missing SKILL.md"
            SKILL_ERRORS=$((SKILL_ERRORS + 1))
        fi
    done <<< "$SKILL_DIRS"

    [ "$SKILL_COUNT" -eq 0 ] && echo "   No skills found"
else
    echo "   No skills directory"
fi
echo ""

# Command Validation
echo "## Commands"

CMD_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
CMD_ERRORS=0

if [ "$CMD_COUNT" -gt 0 ]; then
    # Just do a quick validation
    EMPTY_CMDS=$(find .claude/commands -name "*.md" -empty 2>/dev/null | wc -l | tr -d ' ')

    if [ "$EMPTY_CMDS" -eq 0 ]; then
        pass "All $CMD_COUNT commands valid"
    else
        warn "$EMPTY_CMDS commands are empty"
    fi
else
    warn "No commands found"
fi
echo ""

# Hook/Script Validation
echo "## Scripts"

SCRIPT_COUNT=$(find .claude/scripts -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
NON_EXEC=0

if [ "$SCRIPT_COUNT" -gt 0 ]; then
    while IFS= read -r script; do
        [ -z "$script" ] && continue
        script_name=$(basename "$script")

        if [ -x "$script" ]; then
            pass "$script_name executable"
        else
            warn "$script_name not executable"
            NON_EXEC=$((NON_EXEC + 1))
        fi
    done < <(find .claude/scripts -name "*.sh" 2>/dev/null)

    if [ "$NON_EXEC" -gt 0 ]; then
        echo ""
        echo "   Fix: chmod +x .claude/scripts/*.sh"
    fi
else
    echo "   No scripts found"
fi
echo ""

# Learning Files
echo "## Learning"

LEARNING_FILES=(
    ".claude/learning/observations.md"
    ".claude/learning/pending-skills.md"
    ".claude/learning/pending-agents.md"
    ".claude/learning/pending-commands.md"
    ".claude/learning/pending-hooks.md"
    ".claude/learning/patterns.json"
)

LEARNING_MISSING=0
for lf in "${LEARNING_FILES[@]}"; do
    if [ ! -f "$lf" ]; then
        LEARNING_MISSING=$((LEARNING_MISSING + 1))
    fi
done

if [ "$LEARNING_MISSING" -eq 0 ]; then
    pass "All learning files present"
else
    warn "$LEARNING_MISSING learning files missing"
fi
echo ""

# Project Context
echo "## Project Context"

if [ -f ".claude/project-context.json" ]; then
    if jq empty .claude/project-context.json 2>/dev/null; then
        pass "project-context.json valid"
    else
        fail "project-context.json invalid JSON"
    fi
else
    warn "project-context.json missing (run /claudenv)"
fi
echo ""

# Version
echo "## Version"

if [ -f ".claude/version.json" ]; then
    if jq empty .claude/version.json 2>/dev/null; then
        VERSION=$(jq -r '.infrastructureVersion // "unknown"' .claude/version.json)
        pass "version.json valid (v$VERSION)"
    else
        fail "version.json invalid JSON"
    fi
else
    warn "version.json missing"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo "🎉 All checks passed!"
elif [ "$ERRORS" -eq 0 ]; then
    echo "Summary: $PASSED passed, $WARNINGS warnings"
else
    echo "Summary: $PASSED passed, $WARNINGS warnings, $ERRORS errors"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit with error code if there are errors
[ "$ERRORS" -gt 0 ] && exit 1
exit 0
