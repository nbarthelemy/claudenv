#!/bin/bash
# TDD Enforcement Hook
# Blocks writes to implementation files unless corresponding tests exist
#
# Called by PreToolUse hook with JSON input containing tool_input.file_path
# Exit 0 = allow, Exit 2 = block with message

set -e

# Read JSON input from stdin
input=$(cat)

# Extract file path from tool input
file_path=$(echo "$input" | jq -r '.tool_input.file_path // .tool_input.files[0].file_path // empty' 2>/dev/null)

if [ -z "$file_path" ]; then
  # No file path found, allow the operation
  exit 0
fi

# Get absolute path
if [[ "$file_path" != /* ]]; then
  file_path="$(pwd)/$file_path"
fi

# Normalize path
file_path=$(cd "$(dirname "$file_path")" 2>/dev/null && pwd)/$(basename "$file_path") 2>/dev/null || echo "$file_path"

#=============================================================================
# CHECK: Is TDD disabled for this project?
#=============================================================================

# Find project root
project_root="$PWD"
while [ "$project_root" != "/" ]; do
  if [ -d "$project_root/.claude" ]; then
    break
  fi
  project_root=$(dirname "$project_root")
done

# TDD is ENABLED by default. Check if explicitly disabled.
tdd_disabled=false
if [ -f "$project_root/.claude/tdd-disabled" ]; then
  tdd_disabled=true
elif [ -f "$project_root/.claude/settings.local.json" ]; then
  if jq -e '.tdd.enabled == false' "$project_root/.claude/settings.local.json" 2>/dev/null | grep -q true; then
    tdd_disabled=true
  fi
fi

# If TDD is disabled, allow all operations
if [ "$tdd_disabled" = "true" ]; then
  exit 0
fi

#=============================================================================
# CHECK: Is this a test file? (always allowed)
#=============================================================================

filename=$(basename "$file_path")
dirname_path=$(dirname "$file_path")

is_test_file() {
  local f="$1"
  local name=$(basename "$f")
  local dir=$(dirname "$f")

  # Test file patterns
  [[ "$name" == *.test.* ]] && return 0
  [[ "$name" == *.spec.* ]] && return 0
  [[ "$name" == test_* ]] && return 0
  [[ "$name" == *_test.* ]] && return 0

  # Test directories
  [[ "$dir" == */__tests__/* ]] && return 0
  [[ "$dir" == */tests/* ]] && return 0
  [[ "$dir" == */test/* ]] && return 0
  [[ "$dir" == */__mocks__/* ]] && return 0

  return 1
}

if is_test_file "$file_path"; then
  # Test files are always allowed
  exit 0
fi

#=============================================================================
# CHECK: Is this a non-testable file? (configs, types, etc.)
#=============================================================================

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
  [[ "$name" == index.ts ]] && return 0  # Re-exports typically

  # Non-testable directories
  [[ "$dir" == */config/* ]] && return 0
  [[ "$dir" == */types/* ]] && return 0
  [[ "$dir" == */public/* ]] && return 0
  [[ "$dir" == */assets/* ]] && return 0
  [[ "$dir" == */styles/* ]] && return 0
  [[ "$dir" == */.claude/* ]] && return 0
  [[ "$dir" == */migrations/* ]] && return 0
  [[ "$dir" == */drizzle/* ]] && return 0
  [[ "$dir" == */prisma/* ]] && return 0

  return 1
}

if is_exempt_file "$file_path"; then
  exit 0
fi

#=============================================================================
# CHECK: Does a corresponding test file exist?
#=============================================================================

find_test_file() {
  local impl_file="$1"
  local base_name=$(basename "$impl_file")
  local dir_name=$(dirname "$impl_file")
  local ext="${base_name##*.}"
  local name_no_ext="${base_name%.*}"

  # Possible test file locations
  local test_patterns=(
    "$dir_name/$name_no_ext.test.$ext"
    "$dir_name/$name_no_ext.spec.$ext"
    "$dir_name/__tests__/$name_no_ext.test.$ext"
    "$dir_name/__tests__/$name_no_ext.spec.$ext"
  )

  # Also check parallel test directories
  # src/services/user.ts -> tests/services/user.test.ts
  if [[ "$dir_name" == */src/* ]]; then
    local rel_path="${dir_name#*/src/}"
    test_patterns+=(
      "$project_root/tests/$rel_path/$name_no_ext.test.$ext"
      "$project_root/tests/$rel_path/$name_no_ext.spec.$ext"
      "$project_root/__tests__/$rel_path/$name_no_ext.test.$ext"
    )
  fi

  # Python patterns
  if [[ "$ext" == "py" ]]; then
    test_patterns+=(
      "$dir_name/test_$base_name"
      "$dir_name/${name_no_ext}_test.py"
      "$project_root/tests/test_$base_name"
    )
  fi

  # Go patterns
  if [[ "$ext" == "go" ]]; then
    test_patterns+=(
      "$dir_name/${name_no_ext}_test.go"
    )
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

if [ -n "$test_file" ]; then
  # Test exists, allow implementation
  exit 0
fi

#=============================================================================
# BLOCK: No test file found
#=============================================================================

# Generate suggested test file path
base_name=$(basename "$file_path")
ext="${base_name##*.}"
name_no_ext="${base_name%.*}"
suggested_test="$name_no_ext.test.$ext"

echo "TDD ENFORCEMENT: Write the test first!"
echo ""
echo "  Implementation file: $file_path"
echo "  No corresponding test file found."
echo ""
echo "  Create a test file first, e.g.:"
echo "    $(dirname "$file_path")/$suggested_test"
echo ""
echo "  Or use /tdd skill to guide the workflow."

# Exit code 2 = block with message shown to user
exit 2
