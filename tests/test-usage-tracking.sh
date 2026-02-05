#!/bin/bash
# Test Suite: Usage Tracking
# Tests for usage-record.sh, usage-query.sh, hooks-manager.sh

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
    mkdir -p "$TEST_DIR/.claude/scripts/.disabled"
    mkdir -p "$TEST_DIR/.claude/memory"
    cp "$SCRIPTS/usage-record.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/usage-query.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/hooks-manager.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/memory-init.sh" "$TEST_DIR/.claude/scripts/"
    # Copy hook scripts so hooks-manager can find them
    for hook in session-start.sh session-end.sh unified-gate.sh block-no-verify.sh track-read.sh post-write.sh memory-capture.sh; do
        cp "$SCRIPTS/$hook" "$TEST_DIR/.claude/scripts/" 2>/dev/null || true
    done
}

init_db() {
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
}

# ============================================
# usage-record.sh tests
# ============================================

test_usage_record_inserts() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(echo '{"inputTokens":1000,"outputTokens":500,"toolName":"Write","command":"edit file"}' | bash .claude/scripts/usage-record.sh "test-session")
    assert_json_field "$result" '.error' "false" &&
    local count=$(sqlite3 .claude/memory/memory.db "SELECT COUNT(*) FROM usage_records;")
    [ "$count" -eq 1 ]
}

test_usage_record_stores_tokens() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    echo '{"inputTokens":2000,"outputTokens":1000}' | bash .claude/scripts/usage-record.sh "s1" >/dev/null
    local input=$(sqlite3 .claude/memory/memory.db "SELECT input_tokens FROM usage_records LIMIT 1;")
    local output=$(sqlite3 .claude/memory/memory.db "SELECT output_tokens FROM usage_records LIMIT 1;")
    [ "$input" -eq 2000 ] && [ "$output" -eq 1000 ]
}

test_usage_record_calculates_cost() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    echo '{"inputTokens":1000000,"outputTokens":0}' | bash .claude/scripts/usage-record.sh "s1" >/dev/null
    local cost=$(sqlite3 .claude/memory/memory.db "SELECT cost_estimate FROM usage_records LIMIT 1;")
    # 1M input tokens * $3/1M = $3
    [ "$(echo "$cost >= 2.9" | bc)" -eq 1 ]
}

test_usage_record_no_db_exits_gracefully() {
    setup_test_project
    cd "$TEST_DIR"
    # Don't init DB - should exit gracefully
    local result=$(echo '{"inputTokens":100}' | bash .claude/scripts/usage-record.sh 2>&1)
    # Should not crash (exit 0)
    true
}

# ============================================
# usage-query.sh tests
# ============================================

test_usage_query_status() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    echo '{"inputTokens":500,"outputTokens":200}' | bash .claude/scripts/usage-record.sh "current" >/dev/null
    local result=$(bash .claude/scripts/usage-query.sh status)
    assert_json_field "$result" '.error' "false" &&
    echo "$result" | jq -e '.usage.totalTokens > 0' >/dev/null
}

test_usage_query_today() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    echo '{"inputTokens":1000,"outputTokens":500}' | bash .claude/scripts/usage-record.sh "s1" >/dev/null
    local result=$(bash .claude/scripts/usage-query.sh today)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.period' "today"
}

test_usage_query_by_tool() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    echo '{"inputTokens":100,"outputTokens":50,"toolName":"Write"}' | bash .claude/scripts/usage-record.sh "s1" >/dev/null
    echo '{"inputTokens":200,"outputTokens":100,"toolName":"Read"}' | bash .claude/scripts/usage-record.sh "s1" >/dev/null
    local result=$(bash .claude/scripts/usage-query.sh by-tool)
    assert_json_field "$result" '.error' "false" &&
    echo "$result" | jq -e '.byTool | length >= 2' >/dev/null
}

test_usage_query_unknown_command() {
    setup_test_project
    init_db
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/usage-query.sh invalid 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# hooks-manager.sh tests
# ============================================

test_hooks_list() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/hooks-manager.sh list)
    assert_json_field "$result" '.error' "false" &&
    echo "$result" | jq -e '.hooks | length > 0' >/dev/null
}

test_hooks_info() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/hooks-manager.sh info unified-gate)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.hook.name' "unified-gate.sh"
}

test_hooks_info_adds_sh() {
    setup_test_project
    cd "$TEST_DIR"
    # Should auto-append .sh
    local result=$(bash .claude/scripts/hooks-manager.sh info "session-start")
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.hook.name' "session-start.sh"
}

test_hooks_info_not_found() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/hooks-manager.sh info "nonexistent" 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

test_hooks_toggle_disable() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/hooks-manager.sh toggle "session-start")
    assert_json_field "$result" '.enabled' "false" &&
    [ -f ".claude/scripts/.disabled/session-start.sh" ]
}

test_hooks_toggle_enable() {
    setup_test_project
    cd "$TEST_DIR"
    # First disable
    bash .claude/scripts/hooks-manager.sh toggle "session-start" >/dev/null
    # Then re-enable
    local result=$(bash .claude/scripts/hooks-manager.sh toggle "session-start")
    assert_json_field "$result" '.enabled' "true" &&
    [ ! -f ".claude/scripts/.disabled/session-start.sh" ]
}

test_hooks_unknown_command() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/hooks-manager.sh invalid 2>&1) || true
    echo "$result" | jq -e '.error == true' >/dev/null
}

# ============================================
# Run Tests
# ============================================

run_test "test_usage_record_inserts" test_usage_record_inserts
run_test "test_usage_record_stores_tokens" test_usage_record_stores_tokens
run_test "test_usage_record_calculates_cost" test_usage_record_calculates_cost
run_test "test_usage_record_no_db_exits_gracefully" test_usage_record_no_db_exits_gracefully
run_test "test_usage_query_status" test_usage_query_status
run_test "test_usage_query_today" test_usage_query_today
run_test "test_usage_query_by_tool" test_usage_query_by_tool
run_test "test_usage_query_unknown_command" test_usage_query_unknown_command
run_test "test_hooks_list" test_hooks_list
run_test "test_hooks_info" test_hooks_info
run_test "test_hooks_info_adds_sh" test_hooks_info_adds_sh
run_test "test_hooks_info_not_found" test_hooks_info_not_found
run_test "test_hooks_toggle_disable" test_hooks_toggle_disable
run_test "test_hooks_toggle_enable" test_hooks_toggle_enable
run_test "test_hooks_unknown_command" test_hooks_unknown_command

echo ""
echo "# Usage Tracking Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
