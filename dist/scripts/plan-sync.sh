#!/bin/bash
# Plan Sync Script
# Manages synchronization between plan status and TODO.md
#
# Usage:
#   plan-sync.sh start <plan>      - Set plan to in_progress, update TODO to [~]
#   plan-sync.sh complete <plan>   - Set plan to completed, update TODO to [x]
#   plan-sync.sh block <plan> <reason> - Set plan to blocked, update TODO to [!]
#   plan-sync.sh sync              - Reconcile all plan/TODO statuses
#   plan-sync.sh status            - JSON output of current state

set -e

# Find project root
project_root="$PWD"
while [ "$project_root" != "/" ]; do
  if [ -d "$project_root/.claude" ]; then
    break
  fi
  project_root=$(dirname "$project_root")
done

plans_dir="$project_root/.claude/plans"
todo_file="$project_root/TODO.md"

# Ensure plans directory exists
mkdir -p "$plans_dir"

#=============================================================================
# Helper Functions
#=============================================================================

# Update plan status in a plan file
update_plan_status() {
  local plan_file="$1"
  local new_status="$2"

  if [ ! -f "$plan_file" ]; then
    echo "Error: Plan file not found: $plan_file" >&2
    exit 1
  fi

  # Update the status line
  sed -i.bak "s/^> Status:.*$/> Status: $new_status/" "$plan_file"
  rm -f "${plan_file}.bak"
}

# Get plan status from a plan file
get_plan_status() {
  local plan_file="$1"
  grep -E '^> Status:' "$plan_file" 2>/dev/null | head -1 | sed 's/> Status:[[:space:]]*//' | tr -d '[:space:]'
}

# Update TODO.md marker for a plan
update_todo_marker() {
  local plan_name="$1"
  local new_marker="$2"

  if [ ! -f "$todo_file" ]; then
    return 0
  fi

  # Look for the plan name in TODO.md and update its marker
  # Matches patterns like: - [ ] Plan: plan-name or - [ ] plan-name
  sed -i.bak -E "s/^(\\s*-\\s*)\\[[^]]*\\](\\s*.*$plan_name)/\\1[$new_marker]\\2/" "$todo_file"
  rm -f "${todo_file}.bak"
}

# Convert plan status to TODO marker
status_to_marker() {
  local status="$1"
  case "$status" in
    draft|ready) echo " " ;;
    in_progress) echo "~" ;;
    completed) echo "x" ;;
    blocked) echo "!" ;;
    *) echo " " ;;
  esac
}

# Resolve plan file path
resolve_plan_file() {
  local plan="$1"

  # If it's already a path
  if [[ "$plan" == *.md ]]; then
    if [[ "$plan" == /* ]]; then
      echo "$plan"
    else
      echo "$project_root/$plan"
    fi
    return
  fi

  # Otherwise, look in plans directory
  echo "$plans_dir/${plan}.md"
}

#=============================================================================
# Commands
#=============================================================================

cmd_start() {
  local plan="$1"
  local plan_file=$(resolve_plan_file "$plan")
  local plan_name=$(basename "$plan_file" .md)

  if [ ! -f "$plan_file" ]; then
    echo "Error: Plan not found: $plan_file" >&2
    exit 1
  fi

  update_plan_status "$plan_file" "in_progress"
  update_todo_marker "$plan_name" "~"

  echo "Started plan: $plan_name"
  echo "Status: in_progress"
}

cmd_complete() {
  local plan="$1"
  local plan_file=$(resolve_plan_file "$plan")
  local plan_name=$(basename "$plan_file" .md)

  if [ ! -f "$plan_file" ]; then
    echo "Error: Plan not found: $plan_file" >&2
    exit 1
  fi

  update_plan_status "$plan_file" "completed"
  update_todo_marker "$plan_name" "x"

  echo "Completed plan: $plan_name"
  echo "Status: completed"
}

cmd_block() {
  local plan="$1"
  local reason="${2:-No reason provided}"
  local plan_file=$(resolve_plan_file "$plan")
  local plan_name=$(basename "$plan_file" .md)

  if [ ! -f "$plan_file" ]; then
    echo "Error: Plan not found: $plan_file" >&2
    exit 1
  fi

  update_plan_status "$plan_file" "blocked"
  update_todo_marker "$plan_name" "!"

  # Add blocked reason to plan file if not already present
  if ! grep -q "^> Blocked:" "$plan_file"; then
    sed -i.bak "/^> Status:/a\\
> Blocked: $reason" "$plan_file"
    rm -f "${plan_file}.bak"
  else
    sed -i.bak "s/^> Blocked:.*$/> Blocked: $reason/" "$plan_file"
    rm -f "${plan_file}.bak"
  fi

  echo "Blocked plan: $plan_name"
  echo "Reason: $reason"
}

cmd_sync() {
  echo "Syncing plan statuses with TODO.md..."

  if [ ! -d "$plans_dir" ]; then
    echo "No plans directory found"
    exit 0
  fi

  local count=0
  for plan_file in "$plans_dir"/*.md; do
    [ -f "$plan_file" ] || continue
    local plan_name=$(basename "$plan_file" .md)
    local status=$(get_plan_status "$plan_file")
    local marker=$(status_to_marker "$status")

    update_todo_marker "$plan_name" "$marker"
    count=$((count + 1))
  done

  echo "Synced $count plans"
}

cmd_status() {
  # Output JSON status of all plans
  echo "{"
  echo "  \"project_root\": \"$project_root\","
  echo "  \"plans_dir\": \"$plans_dir\","
  echo "  \"todo_file\": \"$todo_file\","
  echo "  \"plans\": ["

  local first=true
  if [ -d "$plans_dir" ]; then
    for plan_file in "$plans_dir"/*.md; do
      [ -f "$plan_file" ] || continue
      local plan_name=$(basename "$plan_file" .md)
      local status=$(get_plan_status "$plan_file")
      local created=$(grep -E '^> Created:' "$plan_file" 2>/dev/null | head -1 | sed 's/> Created:[[:space:]]*//')

      if [ "$first" = true ]; then
        first=false
      else
        echo ","
      fi

      printf '    {"name": "%s", "status": "%s", "created": "%s", "file": "%s"}' \
        "$plan_name" "$status" "$created" "$plan_file"
    done
  fi

  echo ""
  echo "  ]"
  echo "}"
}

#=============================================================================
# Main
#=============================================================================

case "${1:-status}" in
  start)
    [ -z "$2" ] && { echo "Usage: plan-sync.sh start <plan>" >&2; exit 1; }
    cmd_start "$2"
    ;;
  complete)
    [ -z "$2" ] && { echo "Usage: plan-sync.sh complete <plan>" >&2; exit 1; }
    cmd_complete "$2"
    ;;
  block)
    [ -z "$2" ] && { echo "Usage: plan-sync.sh block <plan> [reason]" >&2; exit 1; }
    cmd_block "$2" "$3"
    ;;
  sync)
    cmd_sync
    ;;
  status)
    cmd_status
    ;;
  *)
    echo "Usage: plan-sync.sh <command> [args]"
    echo ""
    echo "Commands:"
    echo "  start <plan>           Set plan to in_progress"
    echo "  complete <plan>        Set plan to completed"
    echo "  block <plan> [reason]  Set plan to blocked"
    echo "  sync                   Reconcile all plan/TODO statuses"
    echo "  status                 JSON output of current state"
    exit 1
    ;;
esac
