#!/bin/bash
# Phase Manager Script - Manage phases and tasks in plans and TODO.md
# Usage: phase-manager.sh <action> [args]

set -e

# Always resolve paths relative to repo root
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

# Find TODO.md
find_todo() {
    if [ -f "$REPO_ROOT/.claude/TODO.md" ]; then
        echo "$REPO_ROOT/.claude/TODO.md"
    elif [ -f "$REPO_ROOT/TODO.md" ]; then
        echo "$REPO_ROOT/TODO.md"
    else
        echo ""
    fi
}

# Get status of phases and tasks
get_status() {
    local file="${1:-$(find_todo)}"

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"error": true, "message": "TODO.md not found"}'
        return 1
    fi

    # Count phases (## P0, ## P1, ## P2, etc.)
    local p0_count=$(grep -c "^## P0\|^\- \[.\]" "$file" 2>/dev/null | head -1 || echo "0")
    local p1_count=$(grep -c "^## P1" "$file" 2>/dev/null || echo "0")
    local p2_count=$(grep -c "^## P2" "$file" 2>/dev/null || echo "0")

    # Count tasks by status
    local pending=$(grep -c "\- \[ \]" "$file" 2>/dev/null || echo "0")
    local in_progress=$(grep -c "\- \[~\]" "$file" 2>/dev/null || echo "0")
    local blocked=$(grep -c "\- \[!\]" "$file" 2>/dev/null || echo "0")
    local completed=$(grep -c "\- \[x\]" "$file" 2>/dev/null || echo "0")

    local total=$((pending + in_progress + blocked + completed))

    cat << JSONEOF
{
  "file": "$file",
  "tasks": {
    "total": $total,
    "pending": $pending,
    "inProgress": $in_progress,
    "blocked": $blocked,
    "completed": $completed
  },
  "progress": $([ "$total" -gt 0 ] && echo "$((completed * 100 / total))" || echo "0")
}
JSONEOF
}

# List all tasks
list_tasks() {
    local file="${1:-$(find_todo)}"

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"error": true, "message": "TODO.md not found"}'
        return 1
    fi

    # Extract tasks with their status
    grep -n "\- \[.\]" "$file" | while read -r line; do
        local line_num=$(echo "$line" | cut -d: -f1)
        local content=$(echo "$line" | cut -d: -f2-)
        local status="pending"

        if echo "$content" | grep -q "\[x\]"; then
            status="completed"
        elif echo "$content" | grep -q "\[~\]"; then
            status="in_progress"
        elif echo "$content" | grep -q "\[!\]"; then
            status="blocked"
        fi

        # Extract task name (text after checkbox)
        local name=$(echo "$content" | sed 's/.*\] //' | sed 's/ *→.*//' | head -c 80)

        echo "{\"line\": $line_num, \"status\": \"$status\", \"name\": $(echo "$name" | jq -Rs .)}"
    done | jq -s '{"tasks": .}'
}

# Insert a task after another task
insert_task() {
    local file="${1:-$(find_todo)}"
    local task_name="$2"
    local after_task="$3"

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"error": true, "message": "TODO.md not found"}'
        return 1
    fi

    if [ -z "$task_name" ]; then
        echo '{"error": true, "message": "Task name required"}'
        return 1
    fi

    # Find line number of after_task
    local after_line=0
    if [ -n "$after_task" ]; then
        after_line=$(grep -n "$after_task" "$file" | head -1 | cut -d: -f1)
    fi

    if [ "$after_line" -gt 0 ]; then
        # Insert after the specified task
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "${after_line}a\\
- [ ] $task_name
" "$file"
        else
            sed -i "${after_line}a\\- [ ] $task_name" "$file"
        fi
        echo "{\"inserted\": true, \"task\": $(echo "$task_name" | jq -Rs .), \"afterLine\": $after_line}"
    else
        echo '{"error": true, "message": "Could not find insertion point"}'
        return 1
    fi
}

# Remove a task by name
remove_task() {
    local file="${1:-$(find_todo)}"
    local task_pattern="$2"

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"error": true, "message": "TODO.md not found"}'
        return 1
    fi

    if [ -z "$task_pattern" ]; then
        echo '{"error": true, "message": "Task pattern required"}'
        return 1
    fi

    # Find and remove the task line
    local line_num=$(grep -n "$task_pattern" "$file" | head -1 | cut -d: -f1)

    if [ -n "$line_num" ] && [ "$line_num" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "${line_num}d" "$file"
        else
            sed -i "${line_num}d" "$file"
        fi
        echo "{\"removed\": true, \"pattern\": $(echo "$task_pattern" | jq -Rs .), \"line\": $line_num}"
    else
        echo '{"error": true, "message": "Task not found"}'
        return 1
    fi
}

# Move a task to a different section
move_task() {
    local file="${1:-$(find_todo)}"
    local task_pattern="$2"
    local to_section="$3"

    if [ -z "$file" ] || [ ! -f "$file" ]; then
        echo '{"error": true, "message": "TODO.md not found"}'
        return 1
    fi

    if [ -z "$task_pattern" ] || [ -z "$to_section" ]; then
        echo '{"error": true, "message": "Task pattern and target section required"}'
        return 1
    fi

    # Find the task line
    local task_line=$(grep -n "$task_pattern" "$file" | head -1)
    local line_num=$(echo "$task_line" | cut -d: -f1)
    local task_content=$(echo "$task_line" | cut -d: -f2-)

    if [ -z "$line_num" ]; then
        echo '{"error": true, "message": "Task not found"}'
        return 1
    fi

    # Find the target section
    local section_line=$(grep -n "^## $to_section" "$file" | head -1 | cut -d: -f1)

    if [ -z "$section_line" ]; then
        echo '{"error": true, "message": "Section not found: '"$to_section"'"}'
        return 1
    fi

    # Remove from original location
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "${line_num}d" "$file"
    else
        sed -i "${line_num}d" "$file"
    fi

    # Adjust section line if we removed above it
    if [ "$line_num" -lt "$section_line" ]; then
        section_line=$((section_line - 1))
    fi

    # Insert after section header (find next line after section that starts with -)
    local insert_line=$((section_line + 1))

    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "${insert_line}i\\
$task_content
" "$file"
    else
        sed -i "${insert_line}i\\$task_content" "$file"
    fi

    echo "{\"moved\": true, \"task\": $(echo "$task_pattern" | jq -Rs .), \"to\": \"$to_section\"}"
}

# Main dispatcher
case "${1:-status}" in
    status)
        shift
        get_status "$@"
        ;;
    list)
        shift
        list_tasks "$@"
        ;;
    insert)
        shift
        insert_task "" "$1" "$2"
        ;;
    remove)
        shift
        remove_task "" "$1"
        ;;
    move)
        shift
        move_task "" "$1" "$2"
        ;;
    --help|-h)
        echo "Usage: phase-manager.sh <action> [args]"
        echo ""
        echo "Actions:"
        echo "  status              Show phase/task counts"
        echo "  list                List all tasks with status"
        echo "  insert <task> <after>  Insert task after another"
        echo "  remove <pattern>    Remove task by pattern"
        echo "  move <pattern> <section>  Move task to section"
        ;;
    *)
        get_status "$@"
        ;;
esac
