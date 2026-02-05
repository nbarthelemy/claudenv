#!/bin/bash
# Test Suite: Plan Enforcement
# Tests for plan-enforce.sh, plans-list.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS="$REPO_ROOT/dist/scripts"

# Test setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Test counter
TEST_NUM=0
PASSED=0
FAILED=0

run_test() {
    local test_name="$1"
    local test_func="$2"
    TEST_NUM=$((TEST_NUM + 1))
    if $test_func 2>/dev/null; then
        echo "ok $TEST_NUM - $test_name"
        PASSED=$((PASSED + 1))
    else
        echo "not ok $TEST_NUM - $test_name"
        FAILED=$((FAILED + 1))
    fi
}

assert_json_field() {
    local json="$1"
    local field="$2"
    local expected="$3"
    local actual=$(echo "$json" | jq -r "$field")
    [ "$expected" = "$actual" ]
}

setup_test_project() {
    rm -rf "$TEST_DIR"/.claude "$TEST_DIR"/*
    mkdir -p "$TEST_DIR/.claude/scripts"
    mkdir -p "$TEST_DIR/.claude/plans"
    cp "$SCRIPTS/plan-enforce.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/plans-list.sh" "$TEST_DIR/.claude/scripts/"
}

create_plan() {
    local name="$1"
    local status="$2"
    local files="${3:-}"
    cat > "$TEST_DIR/.claude/plans/$name.md" << EOF
# $name

> Status: $status
> Created: 2026-01-01

## Tasks
- files: \`$files\`
- action: implement
EOF
}

# ============================================
# plan-enforce.sh tests
# ============================================

test_plan_enforce_allows_when_disabled() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/plans-disabled
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_quick_fix() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/quick-fix
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_test_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.test.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_spec_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.spec.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_config_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"tsconfig.json"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_markdown() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"README.md"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_dotfiles() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":".env.local"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_claude_dir() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":".claude/state/foo.json"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_test_dir() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"tests/test_app.py"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_in_progress_plan() {
    setup_test_project
    cd "$TEST_DIR"
    create_plan "my-feature" "in_progress" "src/app.ts"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_allows_ready_plan_matching_file() {
    setup_test_project
    cd "$TEST_DIR"
    create_plan "my-feature" "ready" "src/app.ts"
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_blocks_no_plan() {
    setup_test_project
    cd "$TEST_DIR"
    mkdir -p src
    echo "code" > src/app.ts
    local exit_code=0
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh >/dev/null 2>&1 || exit_code=$?
    [ $exit_code -eq 2 ]
}

test_plan_enforce_allows_empty_input() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{}}' | bash .claude/scripts/plan-enforce.sh
}

test_plan_enforce_settings_local_disable() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"plans":{"enabled":false}}' > .claude/settings.local.json
    mkdir -p src
    echo "code" > src/app.ts
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/app.ts"}}' | bash .claude/scripts/plan-enforce.sh
}

# ============================================
# plans-list.sh tests
# ============================================

test_plans_list_empty() {
    setup_test_project
    cd "$TEST_DIR"
    rm -f .claude/plans/*.md
    local result=$(bash .claude/scripts/plans-list.sh)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.draft' "[]" &&
    assert_json_field "$result" '.ready' "[]" &&
    assert_json_field "$result" '.in_progress' "[]" &&
    assert_json_field "$result" '.completed' "[]"
}

test_plans_list_groups_by_status() {
    setup_test_project
    cd "$TEST_DIR"
    create_plan "feat-a" "draft"
    create_plan "feat-b" "ready"
    create_plan "feat-c" "in_progress"
    create_plan "feat-d" "completed"
    local result=$(bash .claude/scripts/plans-list.sh)
    assert_json_field "$result" '.error' "false" &&
    [ "$(echo "$result" | jq '.draft | length')" -eq 1 ] &&
    [ "$(echo "$result" | jq '.ready | length')" -eq 1 ] &&
    [ "$(echo "$result" | jq '.in_progress | length')" -eq 1 ] &&
    [ "$(echo "$result" | jq '.completed | length')" -eq 1 ]
}

test_plans_list_includes_plan_names() {
    setup_test_project
    cd "$TEST_DIR"
    create_plan "user-auth" "ready"
    local result=$(bash .claude/scripts/plans-list.sh)
    echo "$result" | jq -e '.ready[0].name == "user-auth"' >/dev/null
}

test_plans_list_defaults_to_draft() {
    setup_test_project
    cd "$TEST_DIR"
    # Create plan without status line
    cat > .claude/plans/no-status.md << 'EOF'
# No Status Plan

Just a plan without a status line.
EOF
    local result=$(bash .claude/scripts/plans-list.sh)
    [ "$(echo "$result" | jq '.draft | length')" -eq 1 ]
}

# ============================================
# Run Tests
# ============================================

run_test "test_plan_enforce_allows_when_disabled" test_plan_enforce_allows_when_disabled
run_test "test_plan_enforce_allows_quick_fix" test_plan_enforce_allows_quick_fix
run_test "test_plan_enforce_allows_test_files" test_plan_enforce_allows_test_files
run_test "test_plan_enforce_allows_spec_files" test_plan_enforce_allows_spec_files
run_test "test_plan_enforce_allows_config_files" test_plan_enforce_allows_config_files
run_test "test_plan_enforce_allows_markdown" test_plan_enforce_allows_markdown
run_test "test_plan_enforce_allows_dotfiles" test_plan_enforce_allows_dotfiles
run_test "test_plan_enforce_allows_claude_dir" test_plan_enforce_allows_claude_dir
run_test "test_plan_enforce_allows_test_dir" test_plan_enforce_allows_test_dir
run_test "test_plan_enforce_allows_in_progress_plan" test_plan_enforce_allows_in_progress_plan
run_test "test_plan_enforce_allows_ready_plan_matching_file" test_plan_enforce_allows_ready_plan_matching_file
run_test "test_plan_enforce_blocks_no_plan" test_plan_enforce_blocks_no_plan
run_test "test_plan_enforce_allows_empty_input" test_plan_enforce_allows_empty_input
run_test "test_plan_enforce_settings_local_disable" test_plan_enforce_settings_local_disable
run_test "test_plans_list_empty" test_plans_list_empty
run_test "test_plans_list_groups_by_status" test_plans_list_groups_by_status
run_test "test_plans_list_includes_plan_names" test_plans_list_includes_plan_names
run_test "test_plans_list_defaults_to_draft" test_plans_list_defaults_to_draft

echo ""
echo "# Plan Enforcement Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
