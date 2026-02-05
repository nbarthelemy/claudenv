#!/bin/bash
# Test Suite: State Manager
# Tests for state-manager.sh (focus, decisions, blockers, handoff, thinking)

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
    mkdir -p "$TEST_DIR/.claude/state"
    mkdir -p "$TEST_DIR/.claude/memory"
    cp "$SCRIPTS/state-manager.sh" "$TEST_DIR/.claude/scripts/"
}

SM() {
    bash "$TEST_DIR/.claude/scripts/state-manager.sh" "$@"
}

# ============================================
# Init Tests
# ============================================

test_init_creates_state_file() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(SM init)
    assert_json_field "$result" '.error' "false" &&
    [ -f ".claude/state/session-state.json" ]
}

test_init_state_has_correct_structure() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.focus.locked' "false" &&
    assert_json_field "$state" '.focus.activePlan' "null" &&
    assert_json_field "$state" '.thinking.level' "medium"
}

# ============================================
# Focus Tests
# ============================================

test_set_focus() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"activePlan":"my-feature","currentTask":"Implement login","filesInScope":["src/auth.ts"]}' | SM set-focus)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.focus.activePlan' "my-feature" &&
    assert_json_field "$state" '.focus.currentTask' "Implement login"
}

test_lock_focus() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task"}' | SM set-focus >/dev/null
    local result=$(SM lock-focus)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.focus.locked' "true"
}

test_set_focus_while_locked_fails() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task"}' | SM set-focus >/dev/null
    SM lock-focus >/dev/null
    local result=$(echo '{"activePlan":"other","currentTask":"other task"}' | SM set-focus 2>&1) || true
    echo "$result" | grep -q "locked"
}

test_unlock_focus() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task"}' | SM set-focus >/dev/null
    SM lock-focus >/dev/null
    local result=$(SM unlock-focus)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.focus.locked' "false"
}

test_clear_focus() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task"}' | SM set-focus >/dev/null
    local result=$(SM clear-focus)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.focus.activePlan' "null"
}

test_clear_focus_moves_task_to_completed() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"My task"}' | SM set-focus >/dev/null
    SM clear-focus >/dev/null
    local state=$(cat .claude/state/session-state.json)
    echo "$state" | jq -e '.handoff.completedTasks | index("My task") != null' >/dev/null
}

# ============================================
# Decision Tests
# ============================================

test_add_decision() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"decision":"Use JWT for auth","reason":"Stateless, scalable"}' | SM add-decision)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.decisions[0].decision' "Use JWT for auth"
}

test_add_decision_creates_file() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"decision":"Use React","reason":"Team expertise"}' | SM add-decision >/dev/null
    [ -f ".claude/memory/decisions.md" ] &&
    grep -q "Use React" .claude/memory/decisions.md
}

test_add_multiple_decisions() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"decision":"Decision 1","reason":"Reason 1"}' | SM add-decision >/dev/null
    echo '{"decision":"Decision 2","reason":"Reason 2"}' | SM add-decision >/dev/null
    local state=$(cat .claude/state/session-state.json)
    local count=$(echo "$state" | jq '.decisions | length')
    [ "$count" -eq 2 ]
}

# ============================================
# Blocker Tests
# ============================================

test_add_blocker() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"issue":"API key expired","owner":"team"}' | SM add-blocker)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.blockers[0].issue' "API key expired"
}

test_clear_blocker() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"issue":"Blocker 1"}' | SM add-blocker >/dev/null
    echo '{"issue":"Blocker 2"}' | SM add-blocker >/dev/null
    SM clear-blocker 0 >/dev/null
    local state=$(cat .claude/state/session-state.json)
    local count=$(echo "$state" | jq '.blockers | length')
    [ "$count" -eq 1 ] &&
    assert_json_field "$state" '.blockers[0].issue' "Blocker 2"
}

# ============================================
# Handoff Tests
# ============================================

test_set_handoff() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"completedTasks":["task1"],"nextSteps":["task2"],"notes":"Continue with API"}' | SM set-handoff)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.handoff.notes' "Continue with API"
}

test_set_handoff_increments_session_count() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"notes":"session 1"}' | SM set-handoff >/dev/null
    echo '{"notes":"session 2"}' | SM set-handoff >/dev/null
    local state=$(cat .claude/state/session-state.json)
    local count=$(echo "$state" | jq '.metadata.sessionCount')
    [ "$count" -eq 2 ]
}

# ============================================
# Thinking Tests
# ============================================

test_set_thinking_valid_level() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"level":"high"}' | SM set-thinking)
    assert_json_field "$result" '.error' "false" &&
    local state=$(cat .claude/state/session-state.json)
    assert_json_field "$state" '.thinking.level' "high"
}

test_set_thinking_invalid_level() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(echo '{"level":"ultra"}' | SM set-thinking 2>&1) || true
    echo "$result" | grep -q "Invalid"
}

test_get_thinking() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"level":"max"}' | SM set-thinking >/dev/null
    local result=$(SM get-thinking)
    assert_json_field "$result" '.level' "max"
}

test_get_thinking_default() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(SM get-thinking)
    assert_json_field "$result" '.level' "medium"
}

# ============================================
# Get Tests
# ============================================

test_get_focus() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(SM get focus)
    echo "$result" | jq -e '.locked == false' >/dev/null
}

test_get_decisions() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(SM get decisions)
    echo "$result" | jq -e 'type == "array"' >/dev/null
}

test_get_unknown_field() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    SM get "invalid" 2>/dev/null && false || true
}

# ============================================
# Check Focus Tests
# ============================================

test_check_focus_no_lock() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(SM check-focus "src/app.ts")
    assert_json_field "$result" '.allowed' "true"
}

test_check_focus_locked_in_scope() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task","filesInScope":["src/app.ts"]}' | SM set-focus >/dev/null
    SM lock-focus >/dev/null
    local result=$(SM check-focus "src/app.ts")
    assert_json_field "$result" '.allowed' "true"
}

test_check_focus_locked_out_of_scope() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    echo '{"activePlan":"feat","currentTask":"task","filesInScope":["src/auth.ts"]}' | SM set-focus >/dev/null
    SM lock-focus >/dev/null
    local result=$(SM check-focus "src/other.ts")
    assert_json_field "$result" '.allowed' "false"
}

# ============================================
# Status Test
# ============================================

test_status_returns_full_state() {
    setup_test_project
    cd "$TEST_DIR"
    SM init >/dev/null
    local result=$(SM status)
    echo "$result" | jq -e '.focus' >/dev/null &&
    echo "$result" | jq -e '.decisions' >/dev/null &&
    echo "$result" | jq -e '.handoff' >/dev/null &&
    echo "$result" | jq -e '.thinking' >/dev/null
}

# ============================================
# Run Tests
# ============================================

run_test "test_init_creates_state_file" test_init_creates_state_file
run_test "test_init_state_has_correct_structure" test_init_state_has_correct_structure
run_test "test_set_focus" test_set_focus
run_test "test_lock_focus" test_lock_focus
run_test "test_set_focus_while_locked_fails" test_set_focus_while_locked_fails
run_test "test_unlock_focus" test_unlock_focus
run_test "test_clear_focus" test_clear_focus
run_test "test_clear_focus_moves_task_to_completed" test_clear_focus_moves_task_to_completed
run_test "test_add_decision" test_add_decision
run_test "test_add_decision_creates_file" test_add_decision_creates_file
run_test "test_add_multiple_decisions" test_add_multiple_decisions
run_test "test_add_blocker" test_add_blocker
run_test "test_clear_blocker" test_clear_blocker
run_test "test_set_handoff" test_set_handoff
run_test "test_set_handoff_increments_session_count" test_set_handoff_increments_session_count
run_test "test_set_thinking_valid_level" test_set_thinking_valid_level
run_test "test_set_thinking_invalid_level" test_set_thinking_invalid_level
run_test "test_get_thinking" test_get_thinking
run_test "test_get_thinking_default" test_get_thinking_default
run_test "test_get_focus" test_get_focus
run_test "test_get_decisions" test_get_decisions
run_test "test_get_unknown_field" test_get_unknown_field
run_test "test_check_focus_no_lock" test_check_focus_no_lock
run_test "test_check_focus_locked_in_scope" test_check_focus_locked_in_scope
run_test "test_check_focus_locked_out_of_scope" test_check_focus_locked_out_of_scope
run_test "test_status_returns_full_state" test_status_returns_full_state

echo ""
echo "# State Manager Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
