#!/bin/bash
# Unified Code Gate
# Combines TDD enforcement + Plan enforcement with clear messaging
#
# Called by PreToolUse hook with JSON input containing tool_input.file_path
# Exit 0 = allow, Exit 2 = block with message

set -e

# Read JSON input from stdin
input=$(cat)

# Extract file path from tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.files[0].file_path // empty' 2>/dev/null)

if [ -z "$file_path" ]; then
  exit 0
fi

# Get absolute path
if [[ "$file_path" != /* ]]; then
  file_path="$(pwd)/$file_path"
fi

# Normalize path (only if directory exists)
dir_path=$(dirname "$file_path")
if [ -d "$dir_path" ]; then
  file_path="$(cd "$dir_path" && pwd)/$(basename "$file_path")"
fi

#=============================================================================
# Find project root
#=============================================================================

project_root="$PWD"
while [ "$project_root" != "/" ]; do
  if [ -d "$project_root/.claude" ]; then
    break
  fi
  project_root=$(dirname "$project_root")
done

if [ ! -d "$project_root/.claude" ]; then
  exit 0
fi

#=============================================================================
# Check for bypass markers
#=============================================================================

# Quick-fix bypass (one-time)
if [ -f "$project_root/.claude/quick-fix" ]; then
  exit 0
fi

# Full disable markers
tdd_disabled=false
plans_disabled=false

if [ -f "$project_root/.claude/tdd-disabled" ]; then
  tdd_disabled=true
fi

if [ -f "$project_root/.claude/plans-disabled" ]; then
  plans_disabled=true
fi

if [ -f "$project_root/.claude/settings.local.json" ]; then
  if jq -e '.tdd.enabled == false' "$project_root/.claude/settings.local.json" 2>/dev/null | grep -q true; then
    tdd_disabled=true
  fi
  if jq -e '.plans.enabled == false' "$project_root/.claude/settings.local.json" 2>/dev/null | grep -q true; then
    plans_disabled=true
  fi
fi

# If both disabled, allow everything
if [ "$tdd_disabled" = "true" ] && [ "$plans_disabled" = "true" ]; then
  exit 0
fi

#=============================================================================
# File classification
#=============================================================================

filename=$(basename "$file_path")
dirname_path=$(dirname "$file_path")

# Test file detection
is_test_file() {
  local f="$1"
  local name=$(basename "$f")
  local dir=$(dirname "$f")

  [[ "$name" == *.test.* ]] && return 0
  [[ "$name" == *.spec.* ]] && return 0
  [[ "$name" == test_* ]] && return 0
  [[ "$name" == *_test.* ]] && return 0
  [[ "$dir" == */__tests__/* ]] && return 0
  [[ "$dir" == */tests/* ]] && return 0
  [[ "$dir" == */test/* ]] && return 0
  [[ "$dir" == */__mocks__/* ]] && return 0

  return 1
}

# Exempt file detection (configs, types, docs, framework)
is_exempt_file() {
  local f="$1"
  local name=$(basename "$f")
  local dir=$(dirname "$f")

  # Config files
  [[ "$name" == *.config.* ]] && return 0
  [[ "$name" == *.d.ts ]] && return 0
  [[ "$name" == tsconfig.json ]] && return 0
  [[ "$name" == package.json ]] && return 0
  [[ "$name" == *.lock ]] && return 0
  [[ "$name" == *.yaml ]] && return 0
  [[ "$name" == *.yml ]] && return 0
  [[ "$name" == *.md ]] && return 0
  [[ "$name" == *.json ]] && return 0
  [[ "$name" == .* ]] && return 0

  # Type-only files
  [[ "$name" == types.ts ]] && return 0
  [[ "$name" == types.tsx ]] && return 0
  [[ "$name" == constants.ts ]] && return 0
  [[ "$name" == index.ts ]] && return 0

  # Non-testable directories
  [[ "$dir" == */config/* ]] && return 0
  [[ "$dir" == */types/* ]] && return 0
  [[ "$dir" == */public/* ]] && return 0
  [[ "$dir" == */assets/* ]] && return 0
  [[ "$dir" == */styles/* ]] && return 0
  [[ "$dir" == */.claude/* ]] && return 0
  [[ "$dir" == */scripts/* ]] && return 0
  [[ "$dir" == */migrations/* ]] && return 0
  [[ "$dir" == */drizzle/* ]] && return 0
  [[ "$dir" == */prisma/* ]] && return 0

  return 1
}

# Test files always allowed
if is_test_file "$file_path"; then
  exit 0
fi

# Exempt files always allowed
if is_exempt_file "$file_path"; then
  exit 0
fi

#=============================================================================
# Small file exemption (new files under 50 lines don't need plans)
#=============================================================================

if [ -f "$file_path" ]; then
  line_count=$(wc -l < "$file_path" 2>/dev/null | tr -d ' ')
  if [ "$line_count" -lt 50 ] 2>/dev/null; then
    # Small existing file - exempt from plan requirement (TDD still applies)
    plans_disabled=true
  fi
else
  # New file - will check if it's part of an active plan below
  :
fi

#=============================================================================
# Check requirements
#=============================================================================

needs_test=false
needs_plan=false
test_file=""
active_plan=""

# --- TDD Check ---
if [ "$tdd_disabled" != "true" ]; then
  find_test_file() {
    local impl_file="$1"
    local base_name=$(basename "$impl_file")
    local dir_name=$(dirname "$impl_file")
    local ext="${base_name##*.}"
    local name_no_ext="${base_name%.*}"

    local test_patterns=(
      "$dir_name/$name_no_ext.test.$ext"
      "$dir_name/$name_no_ext.spec.$ext"
      "$dir_name/__tests__/$name_no_ext.test.$ext"
      "$dir_name/__tests__/$name_no_ext.spec.$ext"
    )

    if [[ "$dir_name" == */src/* ]]; then
      local rel_path="${dir_name#*/src/}"
      test_patterns+=(
        "$project_root/tests/$rel_path/$name_no_ext.test.$ext"
        "$project_root/tests/$rel_path/$name_no_ext.spec.$ext"
        "$project_root/__tests__/$rel_path/$name_no_ext.test.$ext"
      )
    fi

    if [[ "$ext" == "py" ]]; then
      test_patterns+=(
        "$dir_name/test_$base_name"
        "$dir_name/${name_no_ext}_test.py"
        "$project_root/tests/test_$base_name"
      )
    fi

    if [[ "$ext" == "go" ]]; then
      test_patterns+=("$dir_name/${name_no_ext}_test.go")
    fi

    for pattern in "${test_patterns[@]}"; do
      if [ -f "$pattern" ]; then
        echo "$pattern"
        return 0
      fi
    done
    return 1
  }

  test_file=$(find_test_file "$file_path" 2>/dev/null || true)
  if [ -z "$test_file" ]; then
    needs_test=true
  fi
fi

# --- Plan Check ---
if [ "$plans_disabled" != "true" ]; then
  plans_dir="$project_root/.claude/plans"
  rel_path="${file_path#$project_root/}"

  # Check for active (in_progress) plan
  if [ -d "$plans_dir" ]; then
    for plan_file in "$plans_dir"/*.md; do
      [ -f "$plan_file" ] || continue
      status=$(grep -E '^> Status:' "$plan_file" 2>/dev/null | head -1 | sed 's/> Status:[[:space:]]*//' | tr -d '[:space:]')

      if [ "$status" = "in_progress" ]; then
        active_plan=$(basename "$plan_file" .md)
        break
      fi
    done
  fi

  # If no active plan, check if file is in a ready plan (smart matching)
  if [ -z "$active_plan" ] && [ -d "$plans_dir" ]; then
    for plan_file in "$plans_dir"/*.md; do
      [ -f "$plan_file" ] || continue
      status=$(grep -E '^> Status:' "$plan_file" 2>/dev/null | head -1 | sed 's/> Status:[[:space:]]*//' | tr -d '[:space:]')

      if [ "$status" = "ready" ]; then
        # Smart matching: check files: fields in tasks
        # Pattern: - files: `path/to/file.ts` or - files: `path/a.ts`, `path/b.ts`
        if grep -E "^\s*-\s*files:.*\`[^\`]*$(basename "$file_path")[^\`]*\`" "$plan_file" >/dev/null 2>&1; then
          active_plan=$(basename "$plan_file" .md)
          break
        fi
        # Also check for exact path match
        if grep -E "^\s*-\s*files:.*\`$rel_path\`" "$plan_file" >/dev/null 2>&1; then
          active_plan=$(basename "$plan_file" .md)
          break
        fi
      fi
    done
  fi

  if [ -z "$active_plan" ]; then
    needs_plan=true
  fi
fi

#=============================================================================
# If all checks pass, allow
#=============================================================================

if [ "$needs_test" = "false" ] && [ "$needs_plan" = "false" ]; then
  exit 0
fi

#=============================================================================
# Block with unified message
#=============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚫 CODE GATE: Requirements not met"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  File: $file_path"
echo ""

if [ "$needs_test" = "true" ] && [ "$needs_plan" = "true" ]; then
  echo "  Missing: ❌ Test file AND ❌ Plan"
  echo ""
  echo "  This file needs both TDD and a plan."
elif [ "$needs_test" = "true" ]; then
  echo "  Missing: ❌ Test file"
  echo ""
  echo "  TDD is enabled. Write the test first."
elif [ "$needs_plan" = "true" ]; then
  echo "  Missing: ❌ Plan"
  echo ""
  echo "  Plan enforcement is enabled."
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Options:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$needs_test" = "true" ]; then
  base_name=$(basename "$file_path")
  ext="${base_name##*.}"
  name_no_ext="${base_name%.*}"
  suggested_test="$(dirname "$file_path")/$name_no_ext.test.$ext"
  echo ""
  echo "  📝 Create test file:"
  echo "     $suggested_test"
fi

if [ "$needs_plan" = "true" ]; then
  echo ""
  echo "  📋 Create a plan:"
  echo "     /ce:feature \"Brief description\""
  echo ""
  echo "  ⚡ Quick plan (lightweight):"
  echo "     /ce:quick-plan \"Brief description\""

  # List existing plans
  if [ -d "$plans_dir" ]; then
    existing=""
    for plan_file in "$plans_dir"/*.md; do
      [ -f "$plan_file" ] || continue
      plan_name=$(basename "$plan_file" .md)
      status=$(grep -E '^> Status:' "$plan_file" 2>/dev/null | head -1 | sed 's/> Status:[[:space:]]*//' | tr -d '[:space:]')
      if [ "$status" = "ready" ] || [ "$status" = "draft" ]; then
        existing="$existing\n     • $plan_name ($status)"
      fi
    done
    if [ -n "$existing" ]; then
      echo ""
      echo "  📂 Or execute existing plan:"
      echo "     /ce:execute .claude/plans/<name>.md"
      echo ""
      echo "  Available plans:"
      echo -e "$existing"
    fi
  fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Bypass (use sparingly):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  🔧 One-time: touch .claude/quick-fix"

if [ "$needs_test" = "true" ] && [ "$needs_plan" = "true" ]; then
  echo "  🔕 Disable TDD: touch .claude/tdd-disabled"
  echo "  🔕 Disable plans: touch .claude/plans-disabled"
elif [ "$needs_test" = "true" ]; then
  echo "  🔕 Disable TDD: touch .claude/tdd-disabled"
else
  echo "  🔕 Disable plans: touch .claude/plans-disabled"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit 2
