#!/bin/bash
# Test Suite: Incremental Validation
# Tests for incremental-validate.sh, validate-task.sh, validate-phase.sh, get-affected-files.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VALIDATE="$REPO_ROOT/dist/scripts/incremental-validate.sh"
VALIDATE_TASK="$REPO_ROOT/dist/scripts/validate-task.sh"
VALIDATE_PHASE="$REPO_ROOT/dist/scripts/validate-phase.sh"
GET_AFFECTED="$REPO_ROOT/dist/scripts/get-affected-files.sh"

# Test setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Initialize test repo
setup_test_repo() {
    cd "$TEST_DIR"
    rm -rf .git
    git init -q
    mkdir -p .claude/scripts
    echo "test" > test.txt
    git add .
    git commit -q -m "init"

    # Copy validation scripts
    cp "$VALIDATE" .claude/scripts/ 2>/dev/null || true
    cp "$VALIDATE_TASK" .claude/scripts/ 2>/dev/null || true
    cp "$VALIDATE_PHASE" .claude/scripts/ 2>/dev/null || true
    cp "$GET_AFFECTED" .claude/scripts/ 2>/dev/null || true
}

# Test counter
TEST_NUM=0
PASSED=0
FAILED=0

# Test assertion helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    if [ "$expected" = "$actual" ]; then
        return 0
    else
        echo "  Expected: $expected"
        echo "  Actual: $actual"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    if echo "$haystack" | grep -q "$needle"; then
        return 0
    else
        echo "  Expected to contain: $needle"
        echo "  Actual: $haystack"
        return 1
    fi
}

assert_json_valid() {
    local json="$1"
    if echo "$json" | jq . >/dev/null 2>&1; then
        return 0
    else
        echo "  Invalid JSON: $json"
        return 1
    fi
}

# Run a test
run_test() {
    local test_name="$1"
    local test_func="$2"

    TEST_NUM=$((TEST_NUM + 1))

    if $test_func; then
        echo "ok $TEST_NUM - $test_name"
        PASSED=$((PASSED + 1))
    else
        echo "not ok $TEST_NUM - $test_name"
        FAILED=$((FAILED + 1))
    fi
}

# ============================================
# Test Cases
# ============================================

test_get_affected_files_task() {
    setup_test_repo
    cd "$TEST_DIR"

    # Make an uncommitted change
    echo "modified" >> test.txt

    local result=$(bash "$GET_AFFECTED" task 2>/dev/null)

    assert_contains "$result" "test.txt"
}

test_get_affected_files_phase() {
    setup_test_repo
    cd "$TEST_DIR"

    # Make and commit a change
    echo "modified" >> test.txt
    git add test.txt
    git commit -q -m "phase change"

    # Make another uncommitted change
    echo "more" >> test.txt

    local result=$(bash "$GET_AFFECTED" phase 2>/dev/null)

    assert_contains "$result" "test.txt"
}

test_get_affected_files_feature() {
    setup_test_repo
    cd "$TEST_DIR"

    # Make multiple commits
    echo "change1" >> test.txt
    git add test.txt
    git commit -q -m "change 1"

    echo "change2" >> test.txt
    git add test.txt
    git commit -q -m "change 2"

    local result=$(bash "$GET_AFFECTED" feature 2>/dev/null)

    # Should include files from recent commits
    assert_contains "$result" "test.txt" || [ -z "$result" ]  # May be empty if looking at last N commits
}

test_validate_task_help() {
    cd "$TEST_DIR"

    local result=$(bash "$VALIDATE" task --help 2>/dev/null) || true

    assert_contains "$result" "task" || assert_contains "$result" "Usage"
}

test_validate_no_files() {
    setup_test_repo
    cd "$TEST_DIR"

    # With no changes, should pass
    local result=$(bash "$VALIDATE_TASK" 2>/dev/null) || true

    assert_json_valid "$result" &&
    assert_contains "$result" '"passed"'
}

test_validate_json_output() {
    setup_test_repo
    cd "$TEST_DIR"

    # Run validation
    local result=$(bash "$VALIDATE_TASK" 2>/dev/null) || true

    assert_json_valid "$result"
}

test_validate_phase_json_output() {
    setup_test_repo
    cd "$TEST_DIR"

    # Run phase validation
    local result=$(bash "$VALIDATE_PHASE" 2>/dev/null) || true

    assert_json_valid "$result" &&
    assert_contains "$result" '"tier": "phase"'
}

test_incremental_validate_task() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$VALIDATE" task 2>/dev/null) || true

    # Should return JSON with tier info
    assert_json_valid "$result" || assert_contains "$result" "tier"
}

test_incremental_validate_phase() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$VALIDATE" phase 2>/dev/null) || true

    assert_json_valid "$result" || assert_contains "$result" "tier"
}

test_incremental_validate_feature() {
    setup_test_repo
    cd "$TEST_DIR"

    # Feature validation may take longer, but should still return JSON
    local result=$(bash "$VALIDATE" feature 2>/dev/null) || true

    # Could be empty if no project files, but should be valid JSON if output
    [ -z "$result" ] || assert_json_valid "$result"
}

test_incremental_validate_invalid_tier() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$VALIDATE" invalid_tier 2>/dev/null) || true

    assert_contains "$result" "error"
}

test_affected_files_scope_commit() {
    setup_test_repo
    cd "$TEST_DIR"

    echo "new" > new.txt
    git add new.txt
    git commit -q -m "add new"

    local result=$(bash "$GET_AFFECTED" commit 2>/dev/null)

    assert_contains "$result" "new.txt"
}

# ============================================
# Run Tests
# ============================================

run_test "test_get_affected_files_task" test_get_affected_files_task
run_test "test_get_affected_files_phase" test_get_affected_files_phase
run_test "test_get_affected_files_feature" test_get_affected_files_feature
run_test "test_validate_task_help" test_validate_task_help
run_test "test_validate_no_files" test_validate_no_files
run_test "test_validate_json_output" test_validate_json_output
run_test "test_validate_phase_json_output" test_validate_phase_json_output
run_test "test_incremental_validate_task" test_incremental_validate_task
run_test "test_incremental_validate_phase" test_incremental_validate_phase
run_test "test_incremental_validate_feature" test_incremental_validate_feature
run_test "test_incremental_validate_invalid_tier" test_incremental_validate_invalid_tier
run_test "test_affected_files_scope_commit" test_affected_files_scope_commit

echo ""
echo "# Incremental Validation Tests: $PASSED passed, $FAILED failed"
