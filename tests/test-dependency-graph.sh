#!/bin/bash
# Test Suite: Dependency Graph
# Tests for dependency-graph.sh functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEP_GRAPH="$REPO_ROOT/dist/scripts/dependency-graph.sh"

# Test setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Initialize test repo
setup_test_repo() {
    cd "$TEST_DIR"
    git init -q
    mkdir -p .claude/loop
    git add .
    git commit -q --allow-empty -m "init"
}

# Create TODO.md for testing
create_test_todo() {
    local content="$1"
    echo "$content" > "$TEST_DIR/.claude/TODO.md"
}

# Test counter
TEST_NUM=0
PASSED=0
FAILED=0

# Test assertion helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="$3"
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
    local actual=$(echo "$json" | jq -r "$field")
    assert_equals "$expected" "$actual" "JSON field $field"
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

test_build_graph_simple() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Setup**: Initialize project
- [ ] **Config**: Add configuration
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" build 2>/dev/null)

    assert_json_field "$result" '.features | length' "2" &&
    assert_json_field "$result" '.features[0].name' "Setup" &&
    assert_json_field "$result" '.features[0].status' "pending"
}

test_build_graph_with_deps() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" build 2>/dev/null)

    assert_json_field "$result" '.features | length' "2" &&
    assert_contains "$result" '"from": "Database"' &&
    assert_contains "$result" '"to": "API"'
}

test_next_feature_no_deps() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **First**: First feature
- [ ] **Second**: Second feature
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" next 2>/dev/null)

    assert_json_field "$result" '.name' "First"
}

test_next_feature_respects_deps() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [x] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" next 2>/dev/null)

    # API should be next since Database is completed
    assert_json_field "$result" '.name' "API"
}

test_next_feature_skips_blocked() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" next 2>/dev/null)

    # Should return Database since API is blocked
    assert_json_field "$result" '.name' "Database"
}

test_all_complete() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [x] **Setup**: Done
- [x] **Config**: Done
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" next 2>/dev/null)

    assert_equals "ALL_COMPLETE" "$result"
}

test_blocked_status() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Database**: Create schema

## P1
- [ ] **API**: Build endpoints
  -> depends: Database
- [ ] **Frontend**: Build UI
  -> depends: API
"

    cd "$TEST_DIR"

    # Frontend should be blocked (transitively)
    local result=$(bash "$DEP_GRAPH" blocked "Frontend" 2>/dev/null)
    # Note: blocked checks if deps are failed, not just incomplete
    # So this should return false since nothing has failed yet
    assert_equals "false" "$result"
}

test_update_status() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Setup**: Initialize
"

    cd "$TEST_DIR"
    bash "$DEP_GRAPH" build >/dev/null 2>&1
    local result=$(bash "$DEP_GRAPH" update "Setup" "completed" 2>/dev/null)

    assert_contains "$result" '"success": true'
}

test_chain_simple() {
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
    local result=$(bash "$DEP_GRAPH" chain "C" 2>/dev/null)

    assert_contains "$result" '"A"' &&
    assert_contains "$result" '"B"'
}

test_visualize_output() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **Setup**: Initialize
- [x] **Done**: Completed
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" visualize 2>/dev/null)

    assert_contains "$result" "Feature Dependency Graph" &&
    assert_contains "$result" "Setup" &&
    assert_contains "$result" "Done"
}

test_ready_features() {
    setup_test_repo
    create_test_todo "# TODO

## P0
- [ ] **A**: Feature A
- [ ] **B**: Feature B
- [ ] **C**: Feature C
  -> depends: A
"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" ready 2 2>/dev/null)

    # Should return A and B (both ready), not C (blocked)
    assert_contains "$result" '"name": "A"' &&
    assert_contains "$result" '"name": "B"'
}

test_missing_todo() {
    setup_test_repo
    rm -f "$TEST_DIR/.claude/TODO.md"

    cd "$TEST_DIR"
    local result=$(bash "$DEP_GRAPH" build 2>/dev/null) || true

    assert_contains "$result" '"error": true'
}

# ============================================
# Run Tests
# ============================================

run_test "test_build_graph_simple" test_build_graph_simple
run_test "test_build_graph_with_deps" test_build_graph_with_deps
run_test "test_next_feature_no_deps" test_next_feature_no_deps
run_test "test_next_feature_respects_deps" test_next_feature_respects_deps
run_test "test_next_feature_skips_blocked" test_next_feature_skips_blocked
run_test "test_all_complete" test_all_complete
run_test "test_blocked_status" test_blocked_status
run_test "test_update_status" test_update_status
run_test "test_chain_simple" test_chain_simple
run_test "test_visualize_output" test_visualize_output
run_test "test_ready_features" test_ready_features
run_test "test_missing_todo" test_missing_todo

echo ""
echo "# Dependency Graph Tests: $PASSED passed, $FAILED failed"
