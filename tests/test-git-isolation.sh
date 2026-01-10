#!/bin/bash
# Test Suite: Git Isolation
# Tests for git-isolation-manager.sh functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_ISOLATION="$REPO_ROOT/dist/scripts/git-isolation-manager.sh"

# Test setup
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

# Initialize test repo
setup_test_repo() {
    cd "$TEST_DIR"
    rm -rf .git
    git init -q
    mkdir -p .claude/loop
    echo "test" > test.txt
    git add .
    git commit -q -m "init"
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

assert_branch_exists() {
    local branch="$1"
    if git rev-parse --verify "$branch" &>/dev/null; then
        return 0
    else
        echo "  Branch not found: $branch"
        return 1
    fi
}

assert_branch_not_exists() {
    local branch="$1"
    if ! git rev-parse --verify "$branch" &>/dev/null; then
        return 0
    else
        echo "  Branch exists but shouldn't: $branch"
        return 1
    fi
}

assert_on_branch() {
    local expected="$1"
    local actual=$(git rev-parse --abbrev-ref HEAD)
    assert_equals "$expected" "$actual"
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

test_preflight_clean_repo() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$GIT_ISOLATION" preflight 2>/dev/null)

    assert_contains "$result" '"gitReady": true'
}

test_preflight_uncommitted_changes() {
    setup_test_repo
    cd "$TEST_DIR"
    echo "modified" >> test.txt

    local result=$(bash "$GIT_ISOLATION" preflight 2>/dev/null) || true

    # Should fail without --stash-uncommitted
    assert_contains "$result" '"gitReady": false'
}

test_preflight_stash_uncommitted() {
    setup_test_repo
    cd "$TEST_DIR"
    echo "modified" >> test.txt

    local result=$(bash "$GIT_ISOLATION" preflight --stash-uncommitted 2>/dev/null)

    assert_contains "$result" '"gitReady": true' &&
    assert_contains "$result" '"stashId"'
}

test_preflight_not_git_repo() {
    local non_git_dir=$(mktemp -d)
    cd "$non_git_dir"

    local result=$(bash "$GIT_ISOLATION" preflight 2>/dev/null) || true

    assert_contains "$result" '"gitReady": false'

    rm -rf "$non_git_dir"
}

test_create_branch() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$GIT_ISOLATION" create "Test Feature" 2>/dev/null)

    assert_contains "$result" '"success": true' &&
    assert_contains "$result" '"featureBranch": "autopilot/test-feature"' &&
    assert_branch_exists "autopilot/test-feature" &&
    assert_on_branch "autopilot/test-feature"
}

test_create_branch_collision() {
    setup_test_repo
    cd "$TEST_DIR"

    # Create first branch
    bash "$GIT_ISOLATION" create "Test Feature" >/dev/null 2>&1
    git checkout master 2>/dev/null || git checkout main 2>/dev/null

    # Create second branch with same name
    local result=$(bash "$GIT_ISOLATION" create "Test Feature" 2>/dev/null)

    # Should create autopilot/test-feature-2
    assert_contains "$result" '"featureBranch": "autopilot/test-feature-2"'
}

test_rollback_deletes_branch() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Create and switch to feature branch
    bash "$GIT_ISOLATION" create "Rollback Test" >/dev/null 2>&1
    echo "change" >> test.txt
    git add test.txt
    git commit -q -m "feature change"

    local result=$(bash "$GIT_ISOLATION" rollback "autopilot/rollback-test" "$base_branch" 2>/dev/null)

    assert_contains "$result" '"success": true' &&
    assert_contains "$result" '"rolledBack": true' &&
    assert_branch_not_exists "autopilot/rollback-test" &&
    assert_on_branch "$base_branch"
}

test_rollback_saves_diff() {
    setup_test_repo
    cd "$TEST_DIR"
    mkdir -p .claude/loop/failures

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Create feature branch with changes
    bash "$GIT_ISOLATION" create "Diff Test" >/dev/null 2>&1
    echo "change" >> test.txt
    git add test.txt
    git commit -q -m "feature change"

    local result=$(bash "$GIT_ISOLATION" rollback "autopilot/diff-test" "$base_branch" 2>/dev/null)

    assert_contains "$result" '"failureDiff"' &&
    [ -n "$(ls .claude/loop/failures/*.diff 2>/dev/null)" ]
}

test_complete_keep() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    bash "$GIT_ISOLATION" create "Keep Test" >/dev/null 2>&1
    echo "change" >> test.txt
    git add test.txt
    git commit -q -m "feature change"

    local result=$(bash "$GIT_ISOLATION" complete "autopilot/keep-test" "$base_branch" --keep 2>/dev/null)

    assert_contains "$result" '"action": "kept"' &&
    assert_branch_exists "autopilot/keep-test" &&
    assert_on_branch "$base_branch"
}

test_complete_merge() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    bash "$GIT_ISOLATION" create "Merge Test" >/dev/null 2>&1
    echo "change" >> test.txt
    git add test.txt
    git commit -q -m "feature change"

    local result=$(bash "$GIT_ISOLATION" complete "autopilot/merge-test" "$base_branch" --merge 2>/dev/null)

    assert_contains "$result" '"action": "merged"' &&
    assert_branch_not_exists "autopilot/merge-test" &&
    assert_on_branch "$base_branch"
}

test_status() {
    setup_test_repo
    cd "$TEST_DIR"

    bash "$GIT_ISOLATION" create "Status Test" >/dev/null 2>&1

    local result=$(bash "$GIT_ISOLATION" status 2>/dev/null)

    assert_contains "$result" '"onFeatureBranch": true' &&
    assert_contains "$result" '"currentBranch": "autopilot/status-test"'
}

test_list_branches() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    bash "$GIT_ISOLATION" create "List Test 1" >/dev/null 2>&1
    git checkout "$base_branch" 2>/dev/null
    bash "$GIT_ISOLATION" create "List Test 2" >/dev/null 2>&1

    local result=$(bash "$GIT_ISOLATION" list 2>/dev/null)

    assert_contains "$result" '"autopilot/list-test-1"' &&
    assert_contains "$result" '"autopilot/list-test-2"'
}

test_cleanup_branches() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    bash "$GIT_ISOLATION" create "Cleanup Test" >/dev/null 2>&1
    git checkout "$base_branch" 2>/dev/null

    local result=$(bash "$GIT_ISOLATION" cleanup --force 2>/dev/null)

    assert_contains "$result" '"autopilot/cleanup-test"' &&
    assert_branch_not_exists "autopilot/cleanup-test"
}

test_restore_baseline() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Create a state file with baseline info
    mkdir -p .claude/loop
    cat > .claude/loop/autopilot-state.json << STATEEOF
{
  "gitIsolation": {
    "enabled": true,
    "baselineBranch": "$base_branch",
    "stashId": null
  }
}
STATEEOF

    # Create and switch to feature branch
    bash "$GIT_ISOLATION" create "Restore Test" >/dev/null 2>&1
    assert_on_branch "autopilot/restore-test"

    local result=$(bash "$GIT_ISOLATION" restore_baseline 2>/dev/null)

    assert_contains "$result" '"success": true' &&
    assert_on_branch "$base_branch"
}

test_restore_baseline_with_stash() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Make uncommitted changes and preflight with stash
    echo "modified" >> test.txt
    local preflight=$(bash "$GIT_ISOLATION" preflight --stash-uncommitted 2>/dev/null)
    local stash_id=$(echo "$preflight" | jq -r '.stashId // empty' 2>/dev/null)

    # Create state file with stash info
    mkdir -p .claude/loop
    cat > .claude/loop/autopilot-state.json << STATEEOF
{
  "gitIsolation": {
    "enabled": true,
    "baselineBranch": "$base_branch",
    "stashId": "$stash_id"
  }
}
STATEEOF

    # Create and switch to feature branch
    bash "$GIT_ISOLATION" create "Stash Test" >/dev/null 2>&1

    local result=$(bash "$GIT_ISOLATION" restore_baseline --apply-stash 2>/dev/null)

    assert_contains "$result" '"success": true' &&
    assert_on_branch "$base_branch"
}

test_complete_squash() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)
    local initial_count=$(git rev-list --count HEAD)

    bash "$GIT_ISOLATION" create "Squash Test" >/dev/null 2>&1

    # Make multiple commits
    echo "change1" >> test.txt
    git add test.txt
    git commit -q -m "change 1"

    echo "change2" >> test.txt
    git add test.txt
    git commit -q -m "change 2"

    local result=$(bash "$GIT_ISOLATION" complete "autopilot/squash-test" "$base_branch" --squash 2>/dev/null)

    assert_contains "$result" '"action": "squashed"' &&
    assert_branch_not_exists "autopilot/squash-test" &&
    assert_on_branch "$base_branch"
}

test_cleanup_unmerged() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Create branch with unmerged changes
    bash "$GIT_ISOLATION" create "Unmerged Test" >/dev/null 2>&1
    echo "unmerged change" >> test.txt
    git add test.txt
    git commit -q -m "unmerged commit"
    git checkout "$base_branch" 2>/dev/null

    # Cleanup without --force should fail to delete unmerged branch
    local result=$(bash "$GIT_ISOLATION" cleanup 2>/dev/null)

    # Branch should still exist (failed to delete)
    assert_branch_exists "autopilot/unmerged-test" &&
    assert_contains "$result" '"failed"'
}

test_create_empty_name() {
    setup_test_repo
    cd "$TEST_DIR"

    # Empty name should return error
    local result=$(bash "$GIT_ISOLATION" create "" 2>/dev/null) || true

    assert_contains "$result" '"error": true'
}

test_rollback_idempotent() {
    setup_test_repo
    cd "$TEST_DIR"

    local base_branch=$(git rev-parse --abbrev-ref HEAD)

    # Rollback of nonexistent branch should still succeed (idempotent operation)
    # This is expected behavior - rollback is safe to run even if branch doesn't exist
    local result=$(bash "$GIT_ISOLATION" rollback "autopilot/nonexistent" "$base_branch" 2>/dev/null) || true

    assert_contains "$result" '"success": true'
}

test_status_not_on_feature() {
    setup_test_repo
    cd "$TEST_DIR"

    local result=$(bash "$GIT_ISOLATION" status 2>/dev/null)

    assert_contains "$result" '"onFeatureBranch": false'
}

# ============================================
# Run Tests
# ============================================

run_test "test_preflight_clean_repo" test_preflight_clean_repo
run_test "test_preflight_uncommitted_changes" test_preflight_uncommitted_changes
run_test "test_preflight_stash_uncommitted" test_preflight_stash_uncommitted
run_test "test_preflight_not_git_repo" test_preflight_not_git_repo
run_test "test_create_branch" test_create_branch
run_test "test_create_branch_collision" test_create_branch_collision
run_test "test_rollback_deletes_branch" test_rollback_deletes_branch
run_test "test_rollback_saves_diff" test_rollback_saves_diff
run_test "test_complete_keep" test_complete_keep
run_test "test_complete_merge" test_complete_merge
run_test "test_status" test_status
run_test "test_list_branches" test_list_branches
run_test "test_cleanup_branches" test_cleanup_branches
run_test "test_restore_baseline" test_restore_baseline
run_test "test_restore_baseline_with_stash" test_restore_baseline_with_stash
run_test "test_complete_squash" test_complete_squash
run_test "test_cleanup_unmerged" test_cleanup_unmerged
run_test "test_create_empty_name" test_create_empty_name
run_test "test_rollback_idempotent" test_rollback_idempotent
run_test "test_status_not_on_feature" test_status_not_on_feature

echo ""
echo "# Git Isolation Tests: $PASSED passed, $FAILED failed"
