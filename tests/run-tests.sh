#!/bin/bash
# Test Runner - Run all tests with TAP output
# Usage: run-tests.sh [test-file...]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_DIR="$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# TAP output
tap_header() {
    echo "TAP version 14"
}

tap_plan() {
    echo "1..$1"
}

tap_ok() {
    local test_num=$1
    local test_name=$2
    echo "ok $test_num - $test_name"
    ((PASSED++))
}

tap_not_ok() {
    local test_num=$1
    local test_name=$2
    local reason="${3:-}"
    echo "not ok $test_num - $test_name"
    if [ -n "$reason" ]; then
        echo "  ---"
        echo "  message: '$reason'"
        echo "  ..."
    fi
    ((FAILED++))
}

tap_skip() {
    local test_num=$1
    local test_name=$2
    local reason="${3:-skipped}"
    echo "ok $test_num - $test_name # SKIP $reason"
    ((SKIPPED++))
}

# Run a single test file
run_test_file() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .sh)

    echo ""
    echo "# Running: $test_name"
    echo "# ========================================"

    if [ ! -f "$test_file" ]; then
        echo "# ERROR: Test file not found: $test_file"
        return 1
    fi

    if [ ! -x "$test_file" ]; then
        chmod +x "$test_file"
    fi

    # Run the test file and capture output
    local output
    local exit_code=0
    output=$("$test_file" 2>&1) || exit_code=$?

    echo "$output"

    return $exit_code
}

# Count tests in a file
count_tests() {
    local test_file="$1"
    grep -c "^test_" "$test_file" 2>/dev/null || echo "0"
}

# Main
main() {
    local test_files=()

    if [ $# -gt 0 ]; then
        # Run specific test files
        for arg in "$@"; do
            if [ -f "$TEST_DIR/$arg" ]; then
                test_files+=("$TEST_DIR/$arg")
            elif [ -f "$arg" ]; then
                test_files+=("$arg")
            else
                echo "# Warning: Test file not found: $arg"
            fi
        done
    else
        # Run all test files
        for f in "$TEST_DIR"/test-*.sh; do
            [ -f "$f" ] && test_files+=("$f")
        done
    fi

    if [ ${#test_files[@]} -eq 0 ]; then
        echo "No test files found"
        exit 1
    fi

    tap_header

    # Count total tests
    for test_file in "${test_files[@]}"; do
        local count=$(count_tests "$test_file")
        TOTAL=$((TOTAL + count))
    done

    tap_plan "$TOTAL"

    # Run each test file
    local test_num=0
    for test_file in "${test_files[@]}"; do
        run_test_file "$test_file"
    done

    # Summary
    echo ""
    echo "# ========================================"
    echo "# Summary"
    echo "# ========================================"
    echo "# Tests: $TOTAL"
    echo -e "# ${GREEN}Passed: $PASSED${NC}"
    if [ $FAILED -gt 0 ]; then
        echo -e "# ${RED}Failed: $FAILED${NC}"
    else
        echo "# Failed: $FAILED"
    fi
    if [ $SKIPPED -gt 0 ]; then
        echo -e "# ${YELLOW}Skipped: $SKIPPED${NC}"
    else
        echo "# Skipped: $SKIPPED"
    fi
    echo "# ========================================"

    # Exit code
    if [ $FAILED -gt 0 ]; then
        exit 1
    fi
    exit 0
}

main "$@"
