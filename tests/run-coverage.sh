#!/bin/bash
# Coverage Analyzer - Analyze bash script coverage by function/action testing
# Usage: run-coverage.sh [--verbose]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
COVERAGE_DIR="$REPO_ROOT/coverage"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

VERBOSE=false
[ "$1" = "--verbose" ] && VERBOSE=true

# Clean previous coverage
rm -rf "$COVERAGE_DIR"
mkdir -p "$COVERAGE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📊 Analyzing Test Coverage${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# First, run all tests to verify they pass
echo -e "${YELLOW}Step 1: Running tests...${NC}"
if ! bash "$SCRIPT_DIR/run-tests.sh" >/dev/null 2>&1; then
    echo -e "${RED}Tests failed! Fix tests before measuring coverage.${NC}"
    exit 1
fi
echo -e "${GREEN}All tests passed!${NC}"
echo ""

# Function to analyze a script
analyze_script() {
    local script="$1"
    local test_file="$2"
    local script_name=$(basename "$script")

    if [ ! -f "$script" ]; then
        return
    fi

    # Extract dispatcher actions from case statement (top-level only)
    # Look for pattern: case "$1" or case "${1:-}" followed by action) patterns
    local has_dispatcher=false
    if grep -qE 'case "\$\{?1[^"]*"' "$script" 2>/dev/null; then
        has_dispatcher=true
    fi

    local actions=""
    if [ "$has_dispatcher" = true ]; then
        # Extract actions after the case "$1" or case "${1:-}" line until esac
        actions=$(sed -n '/case "\$.*1.*" in/,/^esac/p' "$script" 2>/dev/null | grep -E '^\s+[a-z_]+\)' | sed 's/).*//' | tr -d ' \t' | sort -u)
    fi

    # Count total actions
    local total=$(echo "$actions" | grep -c . 2>/dev/null || echo 0)
    total=$(echo "$total" | tr -d '\n' | tr -d ' ')
    [ -z "$total" ] && total=0

    # For scripts without dispatcher, check if script itself is called in tests
    if [ "$total" -eq 0 ]; then
        # Check if script is called anywhere in test file
        if grep -qE "(bash.*$script_name|\\\$[A-Z_]+.*$script_name|$script_name)" "$test_file" 2>/dev/null; then
            printf "  %-35s ${GREEN}100%%${NC} (script called in tests)\n" "$script_name:"
            echo "1/1 (100%)" > "$COVERAGE_DIR/$script_name.coverage"
        else
            printf "  %-35s ${RED}  0%%${NC} (script not called in tests)\n" "$script_name:"
            echo "0/1 (0%)" > "$COVERAGE_DIR/$script_name.coverage"
        fi
        return
    fi

    # Count tested actions (check if action name appears in test file calls)
    local tested=0
    local tested_list=()
    local untested_list=()

    for action in $actions; do
        # Check if the action is called in test file
        if grep -qE "(bash.*\"?\\\$[A-Z_]+\"?\s+$action|$script_name\s+$action)" "$test_file" 2>/dev/null; then
            tested=$((tested + 1))
            tested_list+=("$action")
        else
            untested_list+=("$action")
        fi
    done

    # Calculate percentage
    local pct=0
    if [ "$total" -gt 0 ]; then
        pct=$((tested * 100 / total))
    fi

    # Color based on coverage
    local color=$RED
    if [ "$pct" -ge 80 ]; then
        color=$GREEN
    elif [ "$pct" -ge 60 ]; then
        color=$YELLOW
    fi

    printf "  %-35s ${color}%3d%%${NC} (%d/%d actions)\n" "$script_name:" "$pct" "$tested" "$total"

    if [ "$VERBOSE" = true ] && [ ${#untested_list[@]} -gt 0 ]; then
        echo "    Untested: ${untested_list[*]}"
    fi

    # Save to coverage dir
    echo "$tested/$total ($pct%)" > "$COVERAGE_DIR/$script_name.coverage"
}

# Analyze function definitions vs test calls
analyze_functions() {
    local script="$1"
    local test_file="$2"
    local script_name=$(basename "$script")

    if [ ! -f "$script" ]; then
        return
    fi

    # Extract function definitions
    local functions=$(grep -E '^[a-z_]+\(\)\s*\{' "$script" 2>/dev/null | sed 's/().*//' | sort -u)

    local total=$(echo "$functions" | grep -c . 2>/dev/null || echo 0)
    local tested=0

    for func in $functions; do
        # Check if function is tested (called in test or dispatcher)
        if grep -q "$func" "$test_file" 2>/dev/null; then
            tested=$((tested + 1))
        fi
    done

    local pct=0
    if [ "$total" -gt 0 ]; then
        pct=$((tested * 100 / total))
    fi

    echo "$tested/$total ($pct%)" > "$COVERAGE_DIR/${script_name}-functions.coverage"
}

echo -e "${YELLOW}Step 2: Analyzing action coverage...${NC}"
echo ""

echo "Action Coverage by Script:"
echo "─────────────────────────────────────────────"

TOTAL_TESTED=0
TOTAL_ACTIONS=0

# Script/test pairs (inline to avoid subshell issues with variable updates)
PAIRS="
autopilot-manager.sh:test-autopilot-integration.sh
git-isolation-manager.sh:test-git-isolation.sh
dependency-graph.sh:test-dependency-graph.sh
incremental-validate.sh:test-incremental-validate.sh
get-affected-files.sh:test-incremental-validate.sh
validate-task.sh:test-incremental-validate.sh
validate-phase.sh:test-incremental-validate.sh
"

for pair in $PAIRS; do
    script_name=$(echo "$pair" | cut -d: -f1)
    test_name=$(echo "$pair" | cut -d: -f2)
    script="$REPO_ROOT/dist/scripts/$script_name"
    test_file="$SCRIPT_DIR/$test_name"

    if [ -f "$script" ] && [ -f "$test_file" ]; then
        analyze_script "$script" "$test_file"

        # Read coverage for totals (skip N/A entries)
        cov_line=$(cat "$COVERAGE_DIR/$script_name.coverage" 2>/dev/null)
        if ! echo "$cov_line" | grep -q "N/A"; then
            cov=$(echo "$cov_line" | cut -d'/' -f1)
            tot=$(echo "$cov_line" | cut -d'/' -f2 | cut -d' ' -f1)
            [ -n "$cov" ] && [ -n "$tot" ] && {
                TOTAL_TESTED=$((TOTAL_TESTED + cov))
                TOTAL_ACTIONS=$((TOTAL_ACTIONS + tot))
            }
        fi
    fi
done

echo ""

# Calculate overall
OVERALL_PCT=0
if [ "$TOTAL_ACTIONS" -gt 0 ]; then
    OVERALL_PCT=$((TOTAL_TESTED * 100 / TOTAL_ACTIONS))
fi

# Count tests
TOTAL_TESTS=$(grep -hc "^run_test" "$SCRIPT_DIR"/test-*.sh 2>/dev/null | awk '{sum+=$1}END{print sum}')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}📈 Coverage Summary${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Color for overall
OVERALL_COLOR=$RED
if [ "$OVERALL_PCT" -ge 80 ]; then
    OVERALL_COLOR=$GREEN
elif [ "$OVERALL_PCT" -ge 60 ]; then
    OVERALL_COLOR=$YELLOW
fi

echo -e "Total Tests:      ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Actions Tested:   $TOTAL_TESTED/$TOTAL_ACTIONS"
echo -e "Action Coverage:  ${OVERALL_COLOR}${OVERALL_PCT}%${NC}"
echo ""

# Save summary
cat > "$COVERAGE_DIR/summary.json" << JSONEOF
{
  "totalTests": $TOTAL_TESTS,
  "actionsTested": $TOTAL_TESTED,
  "totalActions": $TOTAL_ACTIONS,
  "actionCoverage": $OVERALL_PCT
}
JSONEOF

echo "Coverage data saved to: $COVERAGE_DIR/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
