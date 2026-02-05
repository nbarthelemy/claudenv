#!/bin/bash
# Test Suite: Hook Scripts
# Tests for unified-gate.sh, block-no-verify.sh, track-read.sh, post-write.sh

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

setup_test_project() {
    rm -rf "$TEST_DIR"/.claude "$TEST_DIR"/*
    mkdir -p "$TEST_DIR/.claude/scripts"
    mkdir -p "$TEST_DIR/.claude/state"
    mkdir -p "$TEST_DIR/.claude/plans"
    mkdir -p "$TEST_DIR/.claude/learning"
    cp "$SCRIPTS/unified-gate.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/block-no-verify.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/track-read.sh" "$TEST_DIR/.claude/scripts/"
    cp "$SCRIPTS/post-write.sh" "$TEST_DIR/.claude/scripts/"
}

# ============================================
# block-no-verify.sh tests
# ============================================

test_block_no_verify_blocks_flag() {
    setup_test_project
    cd "$TEST_DIR"
    local exit_code=0
    echo '{"tool_input":{"command":"git commit --no-verify -m test"}}' | bash .claude/scripts/block-no-verify.sh >/dev/null 2>&1 || exit_code=$?
    [ $exit_code -eq 2 ]
}

test_block_no_verify_blocks_n_flag() {
    setup_test_project
    cd "$TEST_DIR"
    local exit_code=0
    echo '{"tool_input":{"command":"git commit -n -m test"}}' | bash .claude/scripts/block-no-verify.sh >/dev/null 2>&1 || exit_code=$?
    [ $exit_code -eq 2 ]
}

test_block_no_verify_allows_normal_commit() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"command":"git commit -m \"test message\""}}' | bash .claude/scripts/block-no-verify.sh
}

test_block_no_verify_allows_non_git() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"command":"npm install lodash"}}' | bash .claude/scripts/block-no-verify.sh
}

test_block_no_verify_allows_empty_command() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{}' | bash .claude/scripts/block-no-verify.sh
}

test_block_no_verify_blocks_no_gpg_sign() {
    setup_test_project
    cd "$TEST_DIR"
    local exit_code=0
    echo '{"tool_input":{"command":"git commit --no-gpg-sign -m test"}}' | bash .claude/scripts/block-no-verify.sh >/dev/null 2>&1 || exit_code=$?
    [ $exit_code -eq 2 ]
}

test_block_no_verify_allows_n_in_log() {
    setup_test_project
    cd "$TEST_DIR"
    # git log -n 5 should NOT be blocked (it's not git commit -n)
    echo '{"tool_input":{"command":"git log -n 5"}}' | bash .claude/scripts/block-no-verify.sh
}

# ============================================
# track-read.sh tests
# ============================================

test_track_read_records_file() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/track-read.sh
    grep -q "src/app.ts" .claude/state/.files-read
}

test_track_read_normalizes_absolute_path() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/index.ts"}}' | bash .claude/scripts/track-read.sh
    grep -q "src/index.ts" .claude/state/.files-read
}

test_track_read_deduplicates() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/track-read.sh
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/track-read.sh
    local count=$(grep -c "src/app.ts" .claude/state/.files-read)
    [ "$count" -eq 1 ]
}

test_track_read_ignores_empty_path() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{}}' | bash .claude/scripts/track-read.sh
    # File may or may not exist, but should be empty or non-existent
    if [ -f .claude/state/.files-read ]; then
        [ ! -s .claude/state/.files-read ]
    else
        true
    fi
}

# ============================================
# unified-gate.sh tests
# ============================================

test_unified_gate_allows_no_file_path() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_test_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.test.ts"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_spec_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.spec.ts"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_config_files() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"tsconfig.json"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_markdown() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"README.md"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_dotfiles() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":".gitignore"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_allows_claude_dir() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":".claude/settings.json"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_quick_fix_bypass() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/quick-fix
    mkdir -p src
    echo "existing" > src/app.ts
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_tdd_disabled_bypass() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/tdd-disabled
    touch .claude/plans-disabled
    mkdir -p src
    echo "existing" > src/app.ts
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/app.ts"}}' | bash .claude/scripts/unified-gate.sh
}

test_unified_gate_small_file_exemption() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/tdd-disabled
    mkdir -p src
    # Create a file with fewer than 50 lines (exempt from plan requirement)
    for i in $(seq 1 10); do echo "line $i"; done > src/small.ts
    echo '{"tool_input":{"file_path":"'"$TEST_DIR"'/src/small.ts"}}' | bash .claude/scripts/unified-gate.sh
}

# ============================================
# post-write.sh tests
# ============================================

test_post_write_deletes_quick_fix() {
    setup_test_project
    cd "$TEST_DIR"
    touch .claude/quick-fix
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/post-write.sh
    [ ! -f ".claude/quick-fix" ]
}

test_post_write_creates_patterns_file() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/post-write.sh
    [ -f ".claude/learning/patterns.json" ] &&
    jq -e '.version == 1' .claude/learning/patterns.json >/dev/null
}

test_post_write_tracks_file_pattern() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/post-write.sh 2>/dev/null || true
    [ -f ".claude/learning/patterns.json" ] &&
    local count=$(jq -r '.file_patterns["src/app.ts"].count // 0' .claude/learning/patterns.json)
    [ "$count" -eq 1 ]
}

test_post_write_increments_pattern_count() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/post-write.sh 2>/dev/null || true
    echo '{"tool_input":{"file_path":"src/app.ts"}}' | bash .claude/scripts/post-write.sh 2>/dev/null || true
    local count=$(jq -r '.file_patterns["src/app.ts"].count // 0' .claude/learning/patterns.json)
    [ "$count" -eq 2 ]
}

test_post_write_tracks_edits() {
    setup_test_project
    cd "$TEST_DIR"
    echo '{"tool_input":{"file_path":"src/foo.ts"}}' | bash .claude/scripts/post-write.sh
    [ -f ".claude/state/.edits-this-session" ] &&
    grep -q "src/foo.ts" .claude/state/.edits-this-session
}

# ============================================
# Run Tests
# ============================================

run_test "test_block_no_verify_blocks_flag" test_block_no_verify_blocks_flag
run_test "test_block_no_verify_blocks_n_flag" test_block_no_verify_blocks_n_flag
run_test "test_block_no_verify_allows_normal_commit" test_block_no_verify_allows_normal_commit
run_test "test_block_no_verify_allows_non_git" test_block_no_verify_allows_non_git
run_test "test_block_no_verify_allows_empty_command" test_block_no_verify_allows_empty_command
run_test "test_block_no_verify_blocks_no_gpg_sign" test_block_no_verify_blocks_no_gpg_sign
run_test "test_block_no_verify_allows_n_in_log" test_block_no_verify_allows_n_in_log
run_test "test_track_read_records_file" test_track_read_records_file
run_test "test_track_read_normalizes_absolute_path" test_track_read_normalizes_absolute_path
run_test "test_track_read_deduplicates" test_track_read_deduplicates
run_test "test_track_read_ignores_empty_path" test_track_read_ignores_empty_path
run_test "test_unified_gate_allows_no_file_path" test_unified_gate_allows_no_file_path
run_test "test_unified_gate_allows_test_files" test_unified_gate_allows_test_files
run_test "test_unified_gate_allows_spec_files" test_unified_gate_allows_spec_files
run_test "test_unified_gate_allows_config_files" test_unified_gate_allows_config_files
run_test "test_unified_gate_allows_markdown" test_unified_gate_allows_markdown
run_test "test_unified_gate_allows_dotfiles" test_unified_gate_allows_dotfiles
run_test "test_unified_gate_allows_claude_dir" test_unified_gate_allows_claude_dir
run_test "test_unified_gate_quick_fix_bypass" test_unified_gate_quick_fix_bypass
run_test "test_unified_gate_tdd_disabled_bypass" test_unified_gate_tdd_disabled_bypass
run_test "test_unified_gate_small_file_exemption" test_unified_gate_small_file_exemption
run_test "test_post_write_deletes_quick_fix" test_post_write_deletes_quick_fix
run_test "test_post_write_creates_patterns_file" test_post_write_creates_patterns_file
run_test "test_post_write_tracks_file_pattern" test_post_write_tracks_file_pattern
run_test "test_post_write_increments_pattern_count" test_post_write_increments_pattern_count
run_test "test_post_write_tracks_edits" test_post_write_tracks_edits

echo ""
echo "# Hook Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
