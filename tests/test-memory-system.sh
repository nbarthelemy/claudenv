#!/bin/bash
# Test Suite: Memory System
# Tests for memory-init.sh, memory-capture.sh, memory-status.sh, memory-search.sh, memory-get.sh

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

# Helpers
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

assert_contains() {
    echo "$1" | grep -q "$2"
}

setup_test_project() {
    rm -rf "$TEST_DIR"/.claude "$TEST_DIR"/*
    mkdir -p "$TEST_DIR/.claude/scripts"
    mkdir -p "$TEST_DIR/.claude/memory"
    mkdir -p "$TEST_DIR/.claude/state"
    # Copy scripts
    cp "$SCRIPTS/memory-init.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/memory-capture.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/memory-status.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/memory-search.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/memory-get.sh" "$TEST_DIR/.claude/scripts/"
}

# ============================================
# Test Cases
# ============================================

test_memory_init_creates_database() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/memory-init.sh)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.message' "Memory database initialized" &&
    [ -f ".claude/memory/memory.db" ]
}

test_memory_init_idempotent() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-init.sh)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.message' "Database already exists"
}

test_memory_init_force_recreate() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-init.sh --force)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.message' "Memory database initialized"
}

test_memory_init_creates_tables() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local tables=$(sqlite3 .claude/memory/memory.db ".tables")
    echo "$tables" | grep -q "observations" &&
    echo "$tables" | grep -q "sessions" &&
    echo "$tables" | grep -q "observations_fts" &&
    echo "$tables" | grep -q "usage_records" &&
    echo "$tables" | grep -q "loop_runs" &&
    echo "$tables" | grep -q "loop_iterations" &&
    echo "$tables" | grep -q "schema_version"
}

test_memory_init_creates_path_files() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    [ -f ".claude/memory/.vec_path" ] &&
    [ -f ".claude/memory/.sqlite3_path" ]
}

test_memory_status_uninitialized() {
    setup_test_project
    cd "$TEST_DIR"
    rm -f .claude/memory/memory.db
    local result=$(bash .claude/scripts/memory-status.sh)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.initialized' "false"
}

test_memory_status_initialized() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-status.sh)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.initialized' "true" &&
    assert_json_field "$result" '.counts.observations' "0" &&
    assert_json_field "$result" '.counts.sessions' "0"
}

test_memory_status_counts_observations() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    # Insert test observations
    sqlite3 .claude/memory/memory.db "INSERT INTO observations (session_id, timestamp, tool_name, summary, importance, created_at) VALUES ('s1', '2026-01-01', 'Write', 'Test summary 1', 2, '2026-01-01');"
    sqlite3 .claude/memory/memory.db "INSERT INTO observations (session_id, timestamp, tool_name, summary, importance, created_at) VALUES ('s1', '2026-01-01', 'Edit', 'Test summary 2', 3, '2026-01-01');"
    local result=$(bash .claude/scripts/memory-status.sh)
    assert_json_field "$result" '.counts.observations' "2" &&
    assert_json_field "$result" '.importance.high' "1" &&
    assert_json_field "$result" '.importance.medium' "1"
}

test_memory_status_counts_pending() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    echo '{"tool_name":"Write","summary":"test"}' > .claude/memory/.pending-observations.jsonl
    echo '{"tool_name":"Edit","summary":"test2"}' >> .claude/memory/.pending-observations.jsonl
    local result=$(bash .claude/scripts/memory-status.sh)
    assert_json_field "$result" '.pending.observations' "2"
}

test_memory_capture_creates_pending() {
    setup_test_project
    cd "$TEST_DIR"
    mkdir -p .claude/memory
    echo '{"tool_name":"Write","tool_input":{"file_path":"src/app.ts","content":"hello"},"tool_response":{"success":true}}' \
        | bash .claude/scripts/memory-capture.sh
    [ -f ".claude/memory/.pending-observations.jsonl" ] &&
    local line=$(cat .claude/memory/.pending-observations.jsonl)
    echo "$line" | jq -e '.tool_name == "Write"' >/dev/null
}

test_memory_capture_importance_write() {
    setup_test_project
    cd "$TEST_DIR"
    mkdir -p .claude/memory
    echo '{"tool_name":"Write","tool_input":{"file_path":"src/app.ts","content":"hello"},"tool_response":{"success":true}}' \
        | bash .claude/scripts/memory-capture.sh
    local line=$(cat .claude/memory/.pending-observations.jsonl)
    echo "$line" | jq -e '.importance == 2' >/dev/null
}

test_memory_capture_importance_git_commit() {
    setup_test_project
    cd "$TEST_DIR"
    mkdir -p .claude/memory
    echo '{"tool_name":"Bash","tool_input":{"command":"git commit -m '\''test'\''"},"tool_response":{"output":"committed"}}' \
        | bash .claude/scripts/memory-capture.sh
    local line=$(cat .claude/memory/.pending-observations.jsonl)
    echo "$line" | jq -e '.importance == 3' >/dev/null
}

test_memory_capture_silent_outside_project() {
    local tmp=$(mktemp -d)
    cd "$tmp"
    # Should exit silently without error
    echo '{"tool_name":"Write","tool_input":{"file_path":"test.ts"},"tool_response":{"success":true}}' \
        | bash "$SCRIPTS/memory-capture.sh"
    local result=$?
    rm -rf "$tmp"
    [ $result -eq 0 ]
}

test_memory_search_no_query() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-search.sh 2>&1) || true
    assert_json_field "$result" '.error' "true"
}

test_memory_search_no_database() {
    setup_test_project
    cd "$TEST_DIR"
    local result=$(bash .claude/scripts/memory-search.sh "test" 2>&1) || true
    assert_json_field "$result" '.error' "true"
}

test_memory_search_keyword_mode() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    sqlite3 .claude/memory/memory.db "INSERT INTO observations (session_id, timestamp, tool_name, summary, keywords, importance, created_at) VALUES ('s1', '2026-01-01', 'Write', 'Fixed authentication bug in login flow', 'auth login bug fix', 2, '2026-01-01');"
    local result=$(bash .claude/scripts/memory-search.sh "authentication" --keyword)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.mode' "keyword"
}

test_memory_search_hybrid_default() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    sqlite3 .claude/memory/memory.db "INSERT INTO observations (session_id, timestamp, tool_name, summary, keywords, importance, created_at) VALUES ('s1', '2026-01-01', 'Write', 'Added user profile page', 'user profile page', 1, '2026-01-01');"
    local result=$(bash .claude/scripts/memory-search.sh "user profile")
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.mode' "hybrid"
}

test_memory_get_missing_id() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-get.sh 2>&1) || true
    assert_json_field "$result" '.error' "true" &&
    assert_contains "$result" "No observation ID"
}

test_memory_get_invalid_id() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-get.sh "abc" 2>&1) || true
    assert_json_field "$result" '.error' "true" &&
    assert_contains "$result" "Invalid observation ID"
}

test_memory_get_not_found() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    local result=$(bash .claude/scripts/memory-get.sh 999 2>&1) || true
    assert_json_field "$result" '.error' "true" &&
    assert_contains "$result" "not found"
}

test_memory_get_existing() {
    setup_test_project
    cd "$TEST_DIR"
    bash .claude/scripts/memory-init.sh >/dev/null
    sqlite3 .claude/memory/memory.db "INSERT INTO observations (session_id, timestamp, tool_name, summary, importance, created_at) VALUES ('s1', '2026-01-01', 'Write', 'Test observation', 2, '2026-01-01');"
    local result=$(bash .claude/scripts/memory-get.sh 1)
    assert_json_field "$result" '.error' "false" &&
    assert_json_field "$result" '.observation.summary' "Test observation" &&
    assert_json_field "$result" '.observation.importance' "2"
}

# ============================================
# Run Tests
# ============================================

run_test "test_memory_init_creates_database" test_memory_init_creates_database
run_test "test_memory_init_idempotent" test_memory_init_idempotent
run_test "test_memory_init_force_recreate" test_memory_init_force_recreate
run_test "test_memory_init_creates_tables" test_memory_init_creates_tables
run_test "test_memory_init_creates_path_files" test_memory_init_creates_path_files
run_test "test_memory_status_uninitialized" test_memory_status_uninitialized
run_test "test_memory_status_initialized" test_memory_status_initialized
run_test "test_memory_status_counts_observations" test_memory_status_counts_observations
run_test "test_memory_status_counts_pending" test_memory_status_counts_pending
run_test "test_memory_capture_creates_pending" test_memory_capture_creates_pending
run_test "test_memory_capture_importance_write" test_memory_capture_importance_write
run_test "test_memory_capture_importance_git_commit" test_memory_capture_importance_git_commit
run_test "test_memory_capture_silent_outside_project" test_memory_capture_silent_outside_project
run_test "test_memory_search_no_query" test_memory_search_no_query
run_test "test_memory_search_no_database" test_memory_search_no_database
run_test "test_memory_search_keyword_mode" test_memory_search_keyword_mode
run_test "test_memory_search_hybrid_default" test_memory_search_hybrid_default
run_test "test_memory_get_missing_id" test_memory_get_missing_id
run_test "test_memory_get_invalid_id" test_memory_get_invalid_id
run_test "test_memory_get_not_found" test_memory_get_not_found
run_test "test_memory_get_existing" test_memory_get_existing

echo ""
echo "# Memory System Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
