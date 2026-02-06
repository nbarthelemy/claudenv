#!/bin/bash
# Claudenv Workspace Add Commands
# Add stacks and platforms to the workspace.
#
# Usage:
#   claudenv workspace add-stack <name> [--list]
#   claudenv workspace add-platform <name> [--list]

cmd_add_stack() {
  local name=""
  local list_only=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      --list|-l) list_only=true; shift ;;
      --help|-h)
        echo "Usage: claudenv workspace add-stack <name>"
        echo ""
        echo "Add a technology stack's agents, skills, and rules."
        echo ""
        echo "Options:"
        echo "  --list   Show available stacks"
        exit 0
        ;;
      -*) print_error "Unknown option: $1"; exit 1 ;;
      *) name="$1"; shift ;;
    esac
  done

  local dist_dir
  if ! dist_dir=$(get_dist_dir 2>/dev/null); then
    print_error "Could not locate claudenv dist directory"
    exit 1
  fi

  if [ "$list_only" = true ] || [ -z "$name" ]; then
    echo ""
    echo -e "${BOLD}Available stacks:${NC}"
    echo ""
    for stack_dir in "$dist_dir/stacks"/*/; do
      [ -d "$stack_dir" ] || continue
      local stack_name
      stack_name=$(basename "$stack_dir")
      local desc=""
      if [ -f "$stack_dir/stack.yml" ]; then
        desc=$(read_yaml_value "$stack_dir/stack.yml" "description" "")
      fi
      if [ -n "$desc" ]; then
        echo -e "  ${CYAN}$stack_name${NC} — $desc"
      else
        echo -e "  ${CYAN}$stack_name${NC}"
      fi
    done
    echo ""
    if [ -z "$name" ] && [ "$list_only" != true ]; then
      print_error "Stack name is required"
      exit 1
    fi
    return 0
  fi

  # Validate
  if [ ! -d "$dist_dir/stacks/$name" ]; then
    print_error "Unknown stack: $name"
    echo "  Run 'claudenv workspace add-stack --list' to see available stacks"
    exit 1
  fi

  # Check workspace exists
  if [ ! -f "stack-workspace.yml" ] && [ ! -f ".workspace.yml" ]; then
    print_error "Not in a workspace. Run 'claudenv workspace init' first."
    exit 1
  fi

  print_header "Adding Stack: $name"

  # Copy stack to .claude/stacks/
  mkdir -p ".claude/stacks/$name"
  cp -r "$dist_dir/stacks/$name/"* ".claude/stacks/$name/"

  # Count what was added
  local agents commands skills rules templates references
  agents=$(find ".claude/stacks/$name/agents" -type f 2>/dev/null | wc -l | tr -d ' ')
  commands=$(find ".claude/stacks/$name/commands" -type f 2>/dev/null | wc -l | tr -d ' ')
  skills=$(find ".claude/stacks/$name/skills" -type d -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
  rules=$(find ".claude/stacks/$name/rules" -type f 2>/dev/null | wc -l | tr -d ' ')
  templates=$(find ".claude/stacks/$name/templates" -type f 2>/dev/null | wc -l | tr -d ' ')
  references=$(find ".claude/stacks/$name/references" -type f 2>/dev/null | wc -l | tr -d ' ')

  echo ""
  print_success "Stack '$name' added to .claude/stacks/$name/"
  echo ""
  [ "$agents" -gt 0 ] 2>/dev/null && print_item "$agents agents"
  [ "$commands" -gt 0 ] 2>/dev/null && print_item "$commands commands"
  [ "$skills" -gt 0 ] 2>/dev/null && print_item "$skills skills"
  [ "$rules" -gt 0 ] 2>/dev/null && print_item "$rules rules"
  [ "$templates" -gt 0 ] 2>/dev/null && print_item "$templates templates"
  [ "$references" -gt 0 ] 2>/dev/null && print_item "$references references"
  echo ""
  echo "  Sync to projects: claudenv workspace sync all"
  echo ""
}

cmd_add_platform() {
  local name=""
  local list_only=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      --list|-l) list_only=true; shift ;;
      --help|-h)
        echo "Usage: claudenv workspace add-platform <name>"
        echo ""
        echo "Add a cloud platform's agents, commands, and rules."
        echo ""
        echo "Options:"
        echo "  --list   Show available platforms"
        exit 0
        ;;
      -*) print_error "Unknown option: $1"; exit 1 ;;
      *) name="$1"; shift ;;
    esac
  done

  local dist_dir
  if ! dist_dir=$(get_dist_dir 2>/dev/null); then
    print_error "Could not locate claudenv dist directory"
    exit 1
  fi

  if [ "$list_only" = true ] || [ -z "$name" ]; then
    echo ""
    echo -e "${BOLD}Available platforms:${NC}"
    echo ""
    for platform_dir in "$dist_dir/platforms"/*/; do
      [ -d "$platform_dir" ] || continue
      local platform_name
      platform_name=$(basename "$platform_dir")
      local desc=""
      if [ -f "$platform_dir/platform.yml" ]; then
        desc=$(read_yaml_value "$platform_dir/platform.yml" "description" "")
      fi
      if [ -n "$desc" ]; then
        echo -e "  ${CYAN}$platform_name${NC} — $desc"
      else
        echo -e "  ${CYAN}$platform_name${NC}"
      fi
    done
    echo ""
    if [ -z "$name" ] && [ "$list_only" != true ]; then
      print_error "Platform name is required"
      exit 1
    fi
    return 0
  fi

  # Validate
  if [ ! -d "$dist_dir/platforms/$name" ]; then
    print_error "Unknown platform: $name"
    echo "  Run 'claudenv workspace add-platform --list' to see available platforms"
    exit 1
  fi

  # Check workspace exists
  if [ ! -f "stack-workspace.yml" ] && [ ! -f ".workspace.yml" ]; then
    print_error "Not in a workspace. Run 'claudenv workspace init' first."
    exit 1
  fi

  print_header "Adding Platform: $name"

  # Copy platform to .claude/platforms/
  mkdir -p ".claude/platforms/$name"
  cp -r "$dist_dir/platforms/$name/"* ".claude/platforms/$name/"

  local agents commands rules skills references
  agents=$(find ".claude/platforms/$name/agents" -type f 2>/dev/null | wc -l | tr -d ' ')
  commands=$(find ".claude/platforms/$name/commands" -type f 2>/dev/null | wc -l | tr -d ' ')
  rules=$(find ".claude/platforms/$name/rules" -type f 2>/dev/null | wc -l | tr -d ' ')
  skills=$(find ".claude/platforms/$name/skills" -type d -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
  references=$(find ".claude/platforms/$name/references" -type f 2>/dev/null | wc -l | tr -d ' ')

  echo ""
  print_success "Platform '$name' added to .claude/platforms/$name/"
  echo ""
  [ "$agents" -gt 0 ] 2>/dev/null && print_item "$agents agents"
  [ "$commands" -gt 0 ] 2>/dev/null && print_item "$commands commands"
  [ "$rules" -gt 0 ] 2>/dev/null && print_item "$rules rules"
  [ "$skills" -gt 0 ] 2>/dev/null && print_item "$skills skills"
  [ "$references" -gt 0 ] 2>/dev/null && print_item "$references references"
  echo ""
  echo "  Sync to projects: claudenv workspace sync all"
  echo ""
}
