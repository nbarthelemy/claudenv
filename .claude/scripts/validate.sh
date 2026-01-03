#!/bin/bash
# Infrastructure Validation Script
# Used by /health:check command

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏥 Running Health Checks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PASSED=0
WARNINGS=0
ERRORS=0

# Function to check and report
check() {
    local name="$1"
    local condition="$2"

    if eval "$condition"; then
        echo "✅ $name"
        PASSED=$((PASSED + 1))
    else
        echo "❌ $name"
        ERRORS=$((ERRORS + 1))
    fi
}

warn() {
    local name="$1"
    local condition="$2"

    if eval "$condition"; then
        echo "✅ $name"
        PASSED=$((PASSED + 1))
    else
        echo "⚠️  $name"
        WARNINGS=$((WARNINGS + 1))
    fi
}

echo ""
echo "## Core Files"

check "settings.json exists" "[ -f '.claude/settings.json' ]"
check "settings.json is valid JSON" "cat .claude/settings.json | python3 -m json.tool > /dev/null 2>&1 || jq . .claude/settings.json > /dev/null 2>&1"
check "CLAUDE.md exists" "[ -f '.claude/CLAUDE.md' ]"
check "version.json exists" "[ -f '.claude/version.json' ]"

echo ""
echo "## Skills"

SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
echo "   Found: $SKILL_COUNT skills"

for skill_dir in .claude/skills/*/; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        if [ -f "${skill_dir}SKILL.md" ]; then
            # Check frontmatter
            if head -1 "${skill_dir}SKILL.md" | grep -q "^---"; then
                echo "   ✅ $skill_name"
                PASSED=$((PASSED + 1))
            else
                echo "   ⚠️  $skill_name - missing frontmatter"
                WARNINGS=$((WARNINGS + 1))
            fi
        else
            echo "   ❌ $skill_name - missing SKILL.md"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""
echo "## Commands"

CMD_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "   Found: $CMD_COUNT commands"
check "Commands directory not empty" "[ $CMD_COUNT -gt 0 ]"

echo ""
echo "## Scripts"

for script in .claude/scripts/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        if [ -x "$script" ]; then
            echo "   ✅ $script_name (executable)"
            PASSED=$((PASSED + 1))
        else
            echo "   ⚠️  $script_name (not executable)"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

echo ""
echo "## Learning Files"

warn "observations.md exists" "[ -f '.claude/learning/observations.md' ]"
warn "pending-skills.md exists" "[ -f '.claude/learning/pending-skills.md' ]"
warn "pending-agents.md exists" "[ -f '.claude/learning/pending-agents.md' ]"
warn "pending-commands.md exists" "[ -f '.claude/learning/pending-commands.md' ]"
warn "pending-hooks.md exists" "[ -f '.claude/learning/pending-hooks.md' ]"

echo ""
echo "## Project Context"

warn "project-context.json exists" "[ -f '.claude/project-context.json' ]"
if [ -f ".claude/project-context.json" ]; then
    warn "project-context.json is valid JSON" "cat .claude/project-context.json | python3 -m json.tool > /dev/null 2>&1 || jq . .claude/project-context.json > /dev/null 2>&1"
fi

warn "SPEC.md exists" "[ -f '.claude/SPEC.md' ]"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Summary: $PASSED passed, $WARNINGS warnings, $ERRORS errors"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Suggest fixes
if [ $WARNINGS -gt 0 ] || [ $ERRORS -gt 0 ]; then
    echo ""
    echo "Suggested fixes:"

    # Check for non-executable scripts
    for script in .claude/scripts/*.sh; do
        if [ -f "$script" ] && [ ! -x "$script" ]; then
            echo "  chmod +x $script"
        fi
    done

    # Check for missing project context
    if [ ! -f ".claude/project-context.json" ]; then
        echo "  Run /claudenv to initialize project context"
    fi

    # Check for missing SPEC
    if [ ! -f ".claude/SPEC.md" ]; then
        echo "  Run /interview to create project specification"
    fi
fi

# Exit with error if critical issues
if [ $ERRORS -gt 0 ]; then
    exit 1
fi

exit 0
