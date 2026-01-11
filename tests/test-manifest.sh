#!/bin/bash
# Test Suite: Manifest Validation
# Ensures manifest.json is complete and accurate

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
MANIFEST="$REPO_ROOT/dist/manifest.json"

# Test counter
TEST_NUM=0
PASSED=0
FAILED=0

# Test assertion helpers
assert_in_manifest() {
    local file="$1"
    if jq -e --arg f "$file" '.files | index($f)' "$MANIFEST" >/dev/null 2>&1; then
        return 0
    else
        echo "  Missing from manifest: $file"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    if [ -f "$REPO_ROOT/dist/$file" ]; then
        return 0
    else
        echo "  File not found: dist/$file"
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

test_manifest_exists() {
    [ -f "$MANIFEST" ]
}

test_manifest_valid_json() {
    jq . "$MANIFEST" >/dev/null 2>&1
}

test_all_scripts_in_manifest() {
    local missing=0
    for script in "$REPO_ROOT"/dist/scripts/*.sh; do
        local name="scripts/$(basename "$script")"
        if ! jq -e --arg f "$name" '.files | index($f)' "$MANIFEST" >/dev/null 2>&1; then
            echo "  Missing: $name"
            missing=$((missing + 1))
        fi
    done
    [ $missing -eq 0 ]
}

test_all_commands_in_manifest() {
    local missing=0
    for cmd in "$REPO_ROOT"/dist/commands/*.md; do
        local name="commands/$(basename "$cmd")"
        if ! jq -e --arg f "$name" '.files | index($f)' "$MANIFEST" >/dev/null 2>&1; then
            echo "  Missing: $name"
            missing=$((missing + 1))
        fi
    done
    [ $missing -eq 0 ]
}

test_all_rules_in_manifest() {
    local missing=0
    for rule in "$REPO_ROOT"/dist/rules/*.md; do
        local name="rules/$(basename "$rule")"
        if ! jq -e --arg f "$name" '.files | index($f)' "$MANIFEST" >/dev/null 2>&1; then
            echo "  Missing: $name"
            missing=$((missing + 1))
        fi
    done
    [ $missing -eq 0 ]
}

test_all_agents_in_manifest() {
    local missing=0
    for agent in "$REPO_ROOT"/dist/agents/*.md "$REPO_ROOT"/dist/agents/*.json; do
        [ -f "$agent" ] || continue
        local name="agents/$(basename "$agent")"
        if ! jq -e --arg f "$name" '.files | index($f)' "$MANIFEST" >/dev/null 2>&1; then
            echo "  Missing: $name"
            missing=$((missing + 1))
        fi
    done
    [ $missing -eq 0 ]
}

test_all_manifest_files_exist() {
    local missing=0
    for file in $(jq -r '.files[]' "$MANIFEST"); do
        if [ ! -f "$REPO_ROOT/dist/$file" ]; then
            echo "  Not found: dist/$file"
            missing=$((missing + 1))
        fi
    done
    [ $missing -eq 0 ]
}

test_no_duplicate_entries() {
    local total=$(jq '.files | length' "$MANIFEST")
    local unique=$(jq '.files | unique | length' "$MANIFEST")
    if [ "$total" -eq "$unique" ]; then
        return 0
    else
        echo "  Found $((total - unique)) duplicate entries"
        return 1
    fi
}

test_version_matches() {
    local manifest_version=$(jq -r '.version' "$MANIFEST")
    local version_json=$(jq -r '.infrastructureVersion' "$REPO_ROOT/dist/version.json")
    if [ "$manifest_version" = "$version_json" ]; then
        return 0
    else
        echo "  manifest.json: $manifest_version"
        echo "  version.json: $version_json"
        return 1
    fi
}

test_gitignore_in_manifest() {
    assert_in_manifest ".gitignore"
}

# ============================================
# Run Tests
# ============================================

run_test "manifest_exists" test_manifest_exists
run_test "manifest_valid_json" test_manifest_valid_json
run_test "all_scripts_in_manifest" test_all_scripts_in_manifest
run_test "all_commands_in_manifest" test_all_commands_in_manifest
run_test "all_rules_in_manifest" test_all_rules_in_manifest
run_test "all_agents_in_manifest" test_all_agents_in_manifest
run_test "all_manifest_files_exist" test_all_manifest_files_exist
run_test "no_duplicate_entries" test_no_duplicate_entries
run_test "version_matches" test_version_matches
run_test "gitignore_in_manifest" test_gitignore_in_manifest

echo ""
echo "# Manifest Tests: $PASSED passed, $FAILED failed"

[ $FAILED -eq 0 ] || exit 1
