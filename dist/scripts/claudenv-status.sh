#!/bin/bash
# Claudenv Status Script
# Displays comprehensive infrastructure status in a single output

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏗️  Claudenv Infrastructure Status"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Project Context
echo "## Project Context"
echo ""

if [ -f ".claude/project-context.json" ]; then
    LANGS=$(jq -r '.languages // [] | join(", ")' .claude/project-context.json 2>/dev/null)
    FRAMEWORKS=$(jq -r '.frameworks // [] | join(", ")' .claude/project-context.json 2>/dev/null)
    PKG_MGR=$(jq -r '.packageManager // "unknown"' .claude/project-context.json 2>/dev/null)
    CLOUD=$(jq -r '.cloudPlatforms // [] | join(", ")' .claude/project-context.json 2>/dev/null)

    echo "📦 Detected Stack:"
    [ -n "$LANGS" ] && [ "$LANGS" != "null" ] && echo "   Languages: $LANGS"
    [ -n "$FRAMEWORKS" ] && [ "$FRAMEWORKS" != "null" ] && echo "   Frameworks: $FRAMEWORKS"
    [ -n "$PKG_MGR" ] && [ "$PKG_MGR" != "null" ] && [ "$PKG_MGR" != "unknown" ] && echo "   Package Manager: $PKG_MGR"
    [ -n "$CLOUD" ] && [ "$CLOUD" != "null" ] && echo "   Cloud: $CLOUD"
else
    echo "📦 Detected Stack: Not detected"
    echo "   Run /claudenv to detect"
fi
echo ""

# Specification
if [ -f ".claude/SPEC.md" ]; then
    SPEC_DATE=$(stat -f "%Sm" -t "%Y-%m-%d" .claude/SPEC.md 2>/dev/null || stat -c "%y" .claude/SPEC.md 2>/dev/null | cut -d' ' -f1)
    echo "📋 Specification: Found"
    echo "   Last updated: $SPEC_DATE"
else
    echo "📋 Specification: Not found"
    echo "   Run /interview to create"
fi
echo ""

# Infrastructure Components
echo "## Infrastructure Components"
echo ""

# Skills
SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
echo "🤖 Skills: $SKILL_COUNT active"
if [ "$SKILL_COUNT" -gt 0 ]; then
    find .claude/skills -name "SKILL.md" -exec dirname {} \; 2>/dev/null | xargs -I {} basename {} | sort | sed 's/^/   - /'
fi
echo ""

# Agents
AGENT_COUNT=$(find .claude/agents -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "🕵️ Agents: $AGENT_COUNT available"
if [ "$AGENT_COUNT" -gt 0 ] && [ "$AGENT_COUNT" -lt 20 ]; then
    find .claude/agents -name "*.md" 2>/dev/null | xargs -I {} basename {} .md | sort | sed 's/^/   - /'
fi
echo ""

# Commands
CMD_COUNT=$(find .claude/commands -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
echo "📝 Commands: $CMD_COUNT available"
echo ""

# Hooks
echo "🪝 Hooks:"
if [ -f ".claude/settings.json" ]; then
    SESSION_START=$(jq -r '.hooks.SessionStart // empty' .claude/settings.json 2>/dev/null)
    POST_TOOL=$(jq -r '.hooks.PostToolUse // empty' .claude/settings.json 2>/dev/null)
    STOP=$(jq -r '.hooks.Stop // empty' .claude/settings.json 2>/dev/null)

    [ -n "$SESSION_START" ] && echo "   - SessionStart: active" || echo "   - SessionStart: inactive"
    [ -n "$POST_TOOL" ] && echo "   - PostToolUse: active" || echo "   - PostToolUse: inactive"
    [ -n "$STOP" ] && echo "   - Stop: active" || echo "   - Stop: inactive"
else
    echo "   No settings.json found"
fi
echo ""

# Learning
echo "📚 Learning:"
OBS_COUNT=$(grep -c "^## " .claude/learning/observations.md 2>/dev/null) || OBS_COUNT=0
PENDING_SKILLS=$(grep -c "^### " .claude/learning/pending-skills.md 2>/dev/null) || PENDING_SKILLS=0
PENDING_AGENTS=$(grep -c "^### " .claude/learning/pending-agents.md 2>/dev/null) || PENDING_AGENTS=0
PENDING_CMDS=$(grep -c "^### " .claude/learning/pending-commands.md 2>/dev/null) || PENDING_CMDS=0
PENDING_HOOKS=$(grep -c "^### " .claude/learning/pending-hooks.md 2>/dev/null) || PENDING_HOOKS=0

echo "   - Observations: $OBS_COUNT logged"
echo "   - Pending skills: $PENDING_SKILLS"
echo "   - Pending agents: $PENDING_AGENTS"
echo "   - Pending commands: $PENDING_CMDS"
echo "   - Pending hooks: $PENDING_HOOKS"
echo ""

# Permissions Summary
echo "## Permissions Summary"
echo ""
if [ -f ".claude/settings.json" ]; then
    ALLOW_COUNT=$(jq -r '.permissions.allow // [] | length' .claude/settings.json 2>/dev/null)
    DENY_COUNT=$(jq -r '.permissions.deny // [] | length' .claude/settings.json 2>/dev/null)
    BASH_COUNT=$(jq -r '[.permissions.allow // [] | .[] | select(startswith("Bash("))] | length' .claude/settings.json 2>/dev/null)

    echo "✅ Allowed: $ALLOW_COUNT tool patterns"
    echo "❌ Denied: $DENY_COUNT patterns"
    echo "🔧 Bash commands: $BASH_COUNT allowed"
else
    echo "⚠️  No settings.json found"
fi
echo ""

# Health Quick Check
echo "## Health"
echo ""

# Settings valid
if [ -f ".claude/settings.json" ] && jq empty .claude/settings.json 2>/dev/null; then
    echo "✅ Settings valid"
else
    echo "❌ Settings invalid or missing"
fi

# Skills have SKILL.md
SKILL_DIRS=$(find .claude/skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
SKILL_FILES=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILL_DIRS" -eq "$SKILL_FILES" ] || [ "$SKILL_DIRS" -eq 0 ]; then
    echo "✅ All skills have SKILL.md"
else
    echo "⚠️  Some skills missing SKILL.md"
fi

# Scripts executable
NON_EXEC=$(find .claude/scripts -name "*.sh" ! -perm -u+x 2>/dev/null | wc -l | tr -d ' ')
if [ "$NON_EXEC" -eq 0 ]; then
    echo "✅ All scripts executable"
else
    echo "⚠️  $NON_EXEC scripts not executable"
fi

# Learning files exist
LEARNING_OK=true
[ ! -f ".claude/learning/observations.md" ] && LEARNING_OK=false
[ ! -f ".claude/learning/pending-skills.md" ] && LEARNING_OK=false
if [ "$LEARNING_OK" = true ]; then
    echo "✅ Learning files exist"
else
    echo "⚠️  Some learning files missing"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Version
if [ -f ".claude/version.json" ]; then
    VERSION=$(jq -r '.infrastructureVersion // "unknown"' .claude/version.json 2>/dev/null)
    echo "Version: $VERSION"
else
    echo "Version: unknown"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
