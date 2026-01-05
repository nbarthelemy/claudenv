#!/bin/bash
# Auto-Create Skill Script
# Creates a skill automatically when a directory pattern reaches threshold
# Called by session-end.sh when thresholds are detected

SKILLS_DIR=".claude/skills"
PATTERNS_FILE=".claude/learning/patterns.json"
THRESHOLDS_FILE=".claude/learning/.thresholds_reached"
CREATED_FILE=".claude/learning/.skills_created"

# Ensure directories exist
mkdir -p "$SKILLS_DIR"
touch "$CREATED_FILE"

# Convert directory path to skill name
# e.g., "src/api" -> "api-operations"
# e.g., "src/components/forms" -> "forms-components"
dir_to_skill_name() {
    local dir="$1"
    local base=$(basename "$dir")
    local parent=$(basename "$(dirname "$dir")")

    # Create a meaningful name
    if [ "$parent" = "." ] || [ "$parent" = "src" ]; then
        echo "${base}-operations"
    else
        echo "${base}-${parent}"
    fi
}

# Create a skill from a directory pattern
create_skill_from_pattern() {
    local dir_path="$1"
    local skill_name=$(dir_to_skill_name "$dir_path")

    # Check if already created
    if grep -q "^$skill_name$" "$CREATED_FILE" 2>/dev/null; then
        return 0
    fi

    # Check if skill already exists
    if [ -d "$SKILLS_DIR/$skill_name" ]; then
        echo "$skill_name" >> "$CREATED_FILE"
        return 0
    fi

    # Get pattern data
    local files=$(jq -r --arg dir "$dir_path" '.directory_patterns[$dir].files | join(", ")' "$PATTERNS_FILE" 2>/dev/null)
    local count=$(jq -r --arg dir "$dir_path" '.directory_patterns[$dir].count' "$PATTERNS_FILE" 2>/dev/null)
    local first_seen=$(jq -r --arg dir "$dir_path" '.directory_patterns[$dir].first_seen' "$PATTERNS_FILE" 2>/dev/null)

    # Determine file type
    local file_ext=""
    if echo "$files" | grep -q "\.ts"; then
        file_ext="TypeScript"
    elif echo "$files" | grep -q "\.py"; then
        file_ext="Python"
    elif echo "$files" | grep -q "\.go"; then
        file_ext="Go"
    elif echo "$files" | grep -q "\.js"; then
        file_ext="JavaScript"
    else
        file_ext="code"
    fi

    # Create skill directory
    mkdir -p "$SKILLS_DIR/$skill_name"

    # Get base names for keywords
    local dir_basename=$(basename "$dir_path")
    local dir_parent=$(basename "$(dirname "$dir_path")")

    # Format files list
    local files_list=$(echo "$files" | tr ',' '\n' | sed 's/^ */- /' | grep -v '^- $')

    # Generate SKILL.md
    cat > "$SKILLS_DIR/$skill_name/SKILL.md" << SKILLEOF
---
name: $skill_name
description: Auto-generated skill for $dir_path operations. Handles $file_ext files in this directory. Use when working with $dir_basename functionality.
allowed-tools: Read, Write, Edit, Glob, Grep
---

# $skill_name Skill

> Auto-created from observed patterns ($count edits to $dir_path)

## Overview

This skill was automatically created because you frequently edit files in \`$dir_path\`.

## When to Activate

- Working with files in \`$dir_path\`
- Keywords: $dir_basename, $dir_parent

## Files Managed

The following files are typically edited together:
$files_list

## Common Operations

Based on observed patterns, common operations in this directory include:
- Creating new $file_ext files
- Editing existing functionality
- Maintaining consistency across related files

## Best Practices

1. Follow existing patterns in the directory
2. Maintain consistent naming conventions
3. Update related files together

---

*First observed: $first_seen*
*Pattern count: $count edits*
SKILLEOF

    # Mark as created
    echo "$skill_name" >> "$CREATED_FILE"

    echo "✅ Auto-created skill: $skill_name"
    echo "   Directory: $dir_path"
    echo "   Files: $files"
}

# Main: process all triggered patterns
if [ -f "$THRESHOLDS_FILE" ] && [ -s "$THRESHOLDS_FILE" ]; then
    echo ""
    echo "🔧 Auto-creating skills from detected patterns..."
    echo ""

    while IFS= read -r dir_path; do
        [ -n "$dir_path" ] && create_skill_from_pattern "$dir_path"
    done < "$THRESHOLDS_FILE"

    # Clear processed thresholds
    > "$THRESHOLDS_FILE"
fi
