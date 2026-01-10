#!/bin/bash
# Test Suite: Autopilot Integration
# End-to-end integration tests for the enhanced autopilot system

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AUTOPILOT="$REPO_ROOT/dist/scripts/autopilot-manager.sh"
DEP_GRAPH="$REPO_ROOT/dist/scripts/dependency-graph.sh"
GIT_ISOLATION="$REPO_ROOT/dist/scripts/git-isolation-manager.sh"

# Test setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Initialize test repo with all scripts
setup_test_repo() {
    cd "$TEST_DIR"
    rm -rf .git
    git init -q

    # Create directory structure
    mkdir -p .claude/loop/history
    mkdir -p .claude/loop/failures
    mkdir -p .claude/scripts
    mkdir -p .claude/plans

    # Copy scripts
    cp "$AUTOPILOT" .claude/scripts/ 2>/dev/null || true
    cp "$DEP_GRAPH" .claude/scripts/ 2>/dev/null || true
    cp "$GIT_ISOLATION" .claude/scripts/ 2>/dev/null || true

    # Create initial file and commit
    echo "test" > test.txt
    git add .
    git commit -q -m "init"
}

# Create TODO.md for testing (commits it so git stash doesn't remove it)
create_test_todo() {
    local content="$1"
    echo "$content" > "$TEST_DIR/.claude/TODO.md"
    # Commit TODO.md so it won't be stashed as untracked
    cd "$TEST_DIR"
    git add .claude/TODO.md
    git commit -q -m "Add TODO.md"
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

assert_json_field() {
    local json="$1"
    local field="$2"
    local expected="$3"
    local actual=$(echo "$json" | jq -r "$field" 2>/dev/null)
    assert_equals "$expected" "$actual"
}

# Run a test
run_test() {
    local test_name="$1"
    local test_func="$2"

    TEST_NUM=$((TEST_NUM + 1))

    # Clean up state between tests
    rm -f "$TEST_DIR/.claude/loop/autopilot-state.json" 2>/dev/null || true

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

test_autopilot_init() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Setup**: Initialize
- [ ] **Config**: Configure
"

    cd "$TEST_DIR"
    local result=$(bash "$AUTOPILOT" init 2>/dev/null)

    assert_contains "$result" '"totalFeatures"' &&
    [ -f ".claude/loop/autopilot-state.json" ]
}

test_autopilot_init_with_isolation() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Setup**: Initialize
"

    cd "$TEST_DIR"
    # Init with isolation enabled (positional args)
    local result=$(bash "$AUTOPILOT" init null 4h '$50' false false true 2>/dev/null)

    assert_contains "$result" '"isolate": true'
}

test_autopilot_next_feature() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **First**: First feature
- [ ] **Second**: Second feature
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" next_feature 2>/dev/null)

    assert_contains "$result" '"feature"'
}

test_autopilot_start_feature() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test Feature**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" start_feature "Test Feature" 2>/dev/null)

    assert_contains "$result" "AUTOPILOT_FEATURE_START"
}

test_autopilot_complete_feature() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test Feature**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test Feature" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" complete "Test Feature" 5 2>/dev/null)

    assert_contains "$result" "AUTOPILOT_FEATURE_COMPLETE"
}

test_autopilot_failed_feature() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test Feature**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test Feature" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" failed "Test Feature" "Test error" 2>/dev/null)

    assert_contains "$result" "AUTOPILOT_FEATURE_FAILED"
}

test_autopilot_status() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test feature
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" status 2>/dev/null)

    assert_contains "$result" '"active": true' &&
    assert_contains "$result" '"currentFeature"'
}

test_autopilot_check_limits() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init 1 >/dev/null 2>&1  # max 1 feature
    bash "$AUTOPILOT" start_feature "Test" >/dev/null 2>&1
    bash "$AUTOPILOT" complete "Test" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" check 2>/dev/null)

    # Should report max_features reached or all_complete
    assert_equals "max_features" "$result" || assert_equals "all_complete" "$result"
}

test_autopilot_graph_visualization() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **A**: Feature A

## P1
- [ ] **B**: Feature B
  -> depends: A
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" graph 2>/dev/null)

    assert_contains "$result" "Feature Dependency Graph" || assert_contains "$result" "Dependency graph"
}

test_autopilot_ready_features() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **A**: Feature A
- [ ] **B**: Feature B
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" ready_features 5 2>/dev/null)

    assert_contains "$result" "A" || assert_contains "$result" "lineNumber"
}

test_autopilot_pause_resume() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    bash "$AUTOPILOT" pause "test_reason" >/dev/null 2>&1
    local status=$(bash "$AUTOPILOT" status 2>/dev/null)

    assert_contains "$status" '"status": "paused"' &&

    bash "$AUTOPILOT" resume >/dev/null 2>&1
    status=$(bash "$AUTOPILOT" status 2>/dev/null)
    assert_contains "$status" '"status": "running"'
}

test_autopilot_cancel() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" cancel "test_cancel" 2>/dev/null)

    assert_contains "$result" '"status": "cancelled"' &&
    [ ! -f ".claude/loop/autopilot-state.json" ]  # Should be archived
}

test_autopilot_history() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" cancel >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" history 2>/dev/null)

    # Should be an array (even if empty)
    echo "$result" | jq -e '. | type == "array"' >/dev/null
}

test_autopilot_no_todo() {
    setup_test_repo
    rm -f "$TEST_DIR/.claude/TODO.md"

    cd "$TEST_DIR"
    local result=$(bash "$AUTOPILOT" init 2>/dev/null) || true

    assert_contains "$result" '"error": true'
}

test_autopilot_next_respects_deps() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" next_feature 2>/dev/null)

    # Should return Database (not API, which is blocked)
    assert_contains "$result" "Database" || assert_contains "$result" '"fromDepGraph": true'
}

test_autopilot_blocked_on_failure() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Database" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" failed "Database" "Test failure" 2>/dev/null)

    # Should mention blocked features
    assert_contains "$result" "AUTOPILOT_FEATURE_FAILED" || assert_contains "$result" "blocked"
}

test_autopilot_skipped_feature() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test Feature**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test Feature" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" skipped "Test Feature" "Not needed" 2>/dev/null)

    assert_contains "$result" "AUTOPILOT_FEATURE_SKIPPED"
}

test_autopilot_finish() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [x] **Done**: Already complete
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" finish 2>/dev/null)

    assert_contains "$result" "AUTOPILOT_COMPLETE"
}

test_autopilot_state() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    # state should return raw JSON state
    local result=$(bash "$AUTOPILOT" state 2>/dev/null)

    assert_json_field "$result" '.status' "running"
}

test_autopilot_report() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test" >/dev/null 2>&1
    bash "$AUTOPILOT" complete "Test" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" report 2>/dev/null)

    # Report should contain summary info
    assert_contains "$result" "completed" || assert_contains "$result" "features"
}

test_autopilot_active() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" active 2>/dev/null)

    assert_equals "true" "$result"
}

test_autopilot_restore_baseline() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1
    bash "$AUTOPILOT" start_feature "Test" >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" restore_baseline 2>/dev/null)

    assert_contains "$result" '"success": true' || assert_contains "$result" "restored"
}

test_autopilot_chain() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **A**: Feature A

## P1
- [ ] **B**: Feature B
  -> depends: A

- [ ] **C**: Feature C
  -> depends: B
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    local result=$(bash "$AUTOPILOT" chain "C" 2>/dev/null)

    # Should include A and B in chain
    assert_contains "$result" '"A"' && assert_contains "$result" '"B"'
}

test_autopilot_blocked_check() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    # API should not be blocked yet (Database just pending, not failed)
    local result=$(bash "$AUTOPILOT" blocked "API" 2>/dev/null)

    assert_equals "false" "$result"
}

test_autopilot_validate() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    # validate should run incremental validation (or return info about it)
    local result=$(bash "$AUTOPILOT" validate task 2>/dev/null) || true

    # Should return JSON with validation info or error if no validate script
    [ -n "$result" ] || [ $? -eq 0 ]
}

test_autopilot_archive() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Test**: Test
"

    cd "$TEST_DIR"
    bash "$AUTOPILOT" init >/dev/null 2>&1

    # Archive the current state
    local result=$(bash "$AUTOPILOT" archive 2>/dev/null)

    # Should confirm archived and file should exist in history
    assert_equals "archived" "$result" &&
    [ -n "$(ls .claude/loop/history/*.json 2>/dev/null)" ]
}

# ============================================
# Run Tests
# ============================================

run_test "test_autopilot_init" test_autopilot_init
run_test "test_autopilot_init_with_isolation" test_autopilot_init_with_isolation
run_test "test_autopilot_next_feature" test_autopilot_next_feature
run_test "test_autopilot_start_feature" test_autopilot_start_feature
run_test "test_autopilot_complete_feature" test_autopilot_complete_feature
run_test "test_autopilot_failed_feature" test_autopilot_failed_feature
run_test "test_autopilot_status" test_autopilot_status
run_test "test_autopilot_check_limits" test_autopilot_check_limits
run_test "test_autopilot_graph_visualization" test_autopilot_graph_visualization
run_test "test_autopilot_ready_features" test_autopilot_ready_features
run_test "test_autopilot_pause_resume" test_autopilot_pause_resume
run_test "test_autopilot_cancel" test_autopilot_cancel
run_test "test_autopilot_history" test_autopilot_history
run_test "test_autopilot_no_todo" test_autopilot_no_todo
run_test "test_autopilot_next_respects_deps" test_autopilot_next_respects_deps
run_test "test_autopilot_blocked_on_failure" test_autopilot_blocked_on_failure
run_test "test_autopilot_skipped_feature" test_autopilot_skipped_feature
run_test "test_autopilot_finish" test_autopilot_finish
run_test "test_autopilot_state" test_autopilot_state
run_test "test_autopilot_report" test_autopilot_report
run_test "test_autopilot_active" test_autopilot_active
run_test "test_autopilot_restore_baseline" test_autopilot_restore_baseline
run_test "test_autopilot_chain" test_autopilot_chain
run_test "test_autopilot_blocked_check" test_autopilot_blocked_check
run_test "test_autopilot_validate" test_autopilot_validate
run_test "test_autopilot_archive" test_autopilot_archive

echo ""
echo "# Autopilot Integration Tests: $PASSED passed, $FAILED failed"
