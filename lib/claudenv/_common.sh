#!/bin/bash
# Claudenv Common Utilities
# Shared functions for all claudenv CLI commands.
#
# Provides: colors, logging, workspace/root detection, YAML reading, dist resolution.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Logging
print_header() {
  echo ""
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${BLUE}  $1${NC}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
  echo -e "  ${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "  ${RED}✗${NC} $1"
}

print_warning() {
  echo -e "  ${YELLOW}⚠${NC} $1"
}

print_info() {
  echo -e "  ${CYAN}→${NC} $1"
}

print_item() {
  echo -e "    $1"
}

# Find workspace root by walking up looking for stack-workspace.yml or .workspace.yml
find_workspace_root() {
  local dir="${1:-$PWD}"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/stack-workspace.yml" ]; then
      echo "$dir"
      return 0
    fi
    if [ -f "$dir/.workspace.yml" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Find claudenv root by walking up looking for .claude/version.json
find_claudenv_root() {
  local dir="${1:-$PWD}"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.claude/version.json" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

# Resolve dist directory — local repo checkout or downloaded
get_dist_dir() {
  # Check relative to the CLI script location (running from cloned repo)
  local cli_dir="${CLAUDENV_SCRIPT_DIR:-}"
  if [ -n "$cli_dir" ] && [ -d "$cli_dir/../dist" ]; then
    echo "$(cd "$cli_dir/../dist" && pwd)"
    return 0
  fi

  # Check LIB_DIR parent
  if [ -n "${LIB_DIR:-}" ] && [ -d "$(dirname "$LIB_DIR")/dist" ]; then
    echo "$(cd "$(dirname "$LIB_DIR")/../dist" && pwd)"
    return 0
  fi

  return 1
}

# Lightweight YAML value reader with yq fallback
# Usage: read_yaml_value <file> <key> [default]
read_yaml_value() {
  local file="$1"
  local key="$2"
  local default="${3:-}"

  if command -v yq &> /dev/null; then
    local value
    value=$(yq ".$key // \"\"" "$file" 2>/dev/null)
    if [ -n "$value" ] && [ "$value" != "null" ]; then
      echo "$value"
      return
    fi
  fi

  # Fallback: simple grep/awk for top-level keys
  local value
  value=$(awk -F': ' '/^'"$key"':/ {print $2; exit}' "$file" 2>/dev/null | tr -d '"'"'" | xargs)
  if [ -z "$value" ] && [ -n "$default" ]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Read nested organization YAML values
# Usage: read_org_yaml <file> <key> [default]
read_org_yaml() {
  local file="$1"
  local key="$2"
  local default="${3:-}"

  if command -v yq &> /dev/null; then
    local value
    value=$(yq ".organization.$key // \"\"" "$file" 2>/dev/null)
    if [ -n "$value" ] && [ "$value" != "null" ]; then
      echo "$value"
      return
    fi
  fi

  local value
  value=$(awk '
    /^organization:/ {found=1; next}
    found && /^[a-z]/ {found=0}
    found && /'"$key"':/ {
      sub(/.*'"$key"':[ \t]*/, "")
      sub(/[ \t]*#.*/, "")
      gsub(/^["'"'"']|["'"'"']$/, "")
      print
      exit
    }
  ' "$file")

  if [ -z "$value" ] && [ -n "$default" ]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Read project-specific YAML value from workspace config
# Usage: read_project_yaml <file> <project> <key> [default]
read_project_yaml() {
  local file="$1"
  local project="$2"
  local key="$3"
  local default="${4:-}"

  if command -v yq &> /dev/null; then
    local value
    value=$(yq ".projects.$project.$key // \"\"" "$file" 2>/dev/null)
    if [ -n "$value" ] && [ "$value" != "null" ]; then
      echo "$value"
      return
    fi
  fi

  local value
  value=$(awk '
    /^projects:/ {in_projects=1; next}
    in_projects && /^[a-z]/ && !/^  / {in_projects=0}
    in_projects && /^  '"$project"':/ {in_project=1; next}
    in_project && /^  [a-z]/ && !/^    / {in_project=0}
    in_project && /'"$key"':/ {gsub(/.*: */, ""); gsub(/^["'"'"']|["'"'"']$/, ""); print; exit}
  ' "$file")

  if [ -z "$value" ] && [ -n "$default" ]; then
    echo "$default"
  else
    echo "$value"
  fi
}

# Read project services array from workspace config
# Usage: read_project_services <file> <project>
read_project_services() {
  local file="$1"
  local project="$2"

  if command -v yq &> /dev/null; then
    yq ".projects.$project.services // [] | .[]" "$file" 2>/dev/null | tr '\n' ' '
    return
  fi

  awk '
    /^projects:/ {in_projects=1; next}
    in_projects && /^[a-z]/ && !/^  / {in_projects=0}
    in_projects && /^  '"$project"':/ {in_project=1; next}
    in_project && /^  [a-z]/ && !/^    / {in_project=0}
    in_project && /services:/ {in_services=1; next}
    in_services && /^      -/ {gsub(/^[ \t]*- */, ""); printf "%s ", $0; next}
    in_services && /^    [a-z]/ {in_services=0}
  ' "$file"
}
