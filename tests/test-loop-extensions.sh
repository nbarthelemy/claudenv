#!/bin/bash
# Test Suite: Loop Extensions
# Tests for loop-record.sh, loop-query.sh

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
    mkdir -p "$TEST_DIR/.claude/memory"
    cp "$SCRIPTS/loop-record.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/loop-query.sh" "$TEST_DIR/.claude/scripts/" 2>/dev/null || true
    cp "$SCRIPTS/memory-init.sh" "$TEST_DIR/.claude/scripts/"
}

init_db() {
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
}

LR() {
    bash "$TEST_DIR/.claude/scripts/loop-record.sh" "$@"
}

# ============================================
# loop-record.sh start tests
# ============================================

test_loop_start() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR start "Fix all TypeScript errors")
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.status' "running" &&
    echo "$result" | jq -e '.loopId > 0' >/dev/null
}

test_loop_start_with_options() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR start "Fix errors" 10 "Found 0 errors")
    assert_json_field "$result" '.error' "false" &&
    local loop_id=$(echo "$result" | jq -r '.loopId')
    local max=$(sqlite3 .claude/memory/memory.db "SELECT max_iterations FROM loop_runs WHERE id = $loop_id;")
    local until=$(sqlite3 .claude/memory/memory.db "SELECT until_condition FROM loop_runs WHERE id = $loop_id;")
    [ "$max" -eq 10 ] && [ "$until" = "Found 0 errors" ]
}

test_loop_start_requires_task() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR start 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

test_loop_start_no_db() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(LR start "task" 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# loop-record.sh iteration tests
# ============================================

test_loop_iteration() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    local result=$(LR iteration "$loop_id" "Ran linter" "Found 3 errors")
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.iteration' "1"
}

test_loop_multiple_iterations() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    LR iteration "$loop_id" "Iteration 1" "result 1" >/dev/null
    LR iteration "$loop_id" "Iteration 2" "result 2" >/dev/null
    local result=$(LR iteration "$loop_id" "Iteration 3" "result 3")
    assert_json_field "$result" '.iteration' "3" &&
    local count=$(sqlite3 .claude/memory/memory.db "SELECT iterations FROM loop_runs WHERE id = $loop_id;")
    [ "$count" -eq 3 ]
}

test_loop_iteration_requires_args() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR iteration 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# loop-record.sh complete/fail tests
# ============================================

test_loop_complete() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    local result=$(LR complete "$loop_id" "All fixed")
    assert_json_field "$result" '.error' "false" &&
    local status=$(sqlite3 .claude/memory/memory.db "SELECT status FROM loop_runs WHERE id = $loop_id;")
    [ "$status" = "completed" ]
}

test_loop_complete_sets_ended_at() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    LR complete "$loop_id" >/dev/null
    local ended=$(sqlite3 .claude/memory/memory.db "SELECT ended_at FROM loop_runs WHERE id = $loop_id;")
    [ -n "$ended" ] && [ "$ended" != "" ]
}

test_loop_fail() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    local result=$(LR fail "$loop_id" "Max iterations reached")
    assert_json_field "$result" '.error' "false" &&
    local status=$(sqlite3 .claude/memory/memory.db "SELECT status FROM loop_runs WHERE id = $loop_id;")
    local error=$(sqlite3 .claude/memory/memory.db "SELECT error_message FROM loop_runs WHERE id = $loop_id;")
    [ "$status" = "failed" ] && [ "$error" = "Max iterations reached" ]
}

# ============================================
# loop-record.sh get tests
# ============================================

test_loop_get() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local start_result=$(LR start "Fix errors" 20 "Found 0")
    local loop_id=$(echo "$start_result" | jq -r '.loopId')
    LR iteration "$loop_id" "action1" "result1" >/dev/null
    local result=$(LR get "$loop_id")
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.loop.task' "Fix errors" &&
    assert_json_field "$result" '.loop.status' "running" &&
    echo "$result" | jq -e '.iterations | length == 1' >/dev/null
}

test_loop_get_requires_id() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR get 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# Unknown action
# ============================================

test_loop_unknown_action() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(LR invalid 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# Run Tests
# ============================================

run_test "test_loop_start" test_loop_start
run_test "test_loop_start_with_options" test_loop_start_with_options
run_test "test_loop_start_requires_task" test_loop_start_requires_task
run_test "test_loop_start_no_db" test_loop_start_no_db
run_test "test_loop_iteration" test_loop_iteration
run_test "test_loop_multiple_iterations" test_loop_multiple_iterations
run_test "test_loop_iteration_requires_args" test_loop_iteration_requires_args
run_test "test_loop_complete" test_loop_complete
run_test "test_loop_complete_sets_ended_at" test_loop_complete_sets_ended_at
run_test "test_loop_fail" test_loop_fail
run_test "test_loop_get" test_loop_get
run_test "test_loop_get_requires_id" test_loop_get_requires_id
run_test "test_loop_unknown_action" test_loop_unknown_action

echo ""
echo "# Loop Extension Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
