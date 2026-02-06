#!/bin/bash
# Claudenv Workspace Init Command
# Initialize a multi-project workspace with stacks and platforms.
#
# Ported from workspace's bin/init.
#
# Usage: claudenv workspace init [--org <name>] [--stack <name>] [--platform <name>]

cmd_workspace_init() {
  local org_name=""
  local default_stack="web-nextjs"
  local default_platform="gcp"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --org) org_name="$2"; shift 2 ;;
      --stack) default_stack="$2"; shift 2 ;;
      --platform) default_platform="$2"; shift 2 ;;
      --help|-h)
        echo "Usage: claudenv workspace init [options]"
        echo ""
        echo "Initialize a multi-project workspace."
        echo ""
        echo "Options:"
        echo "  --org <name>        Organization name (default: directory name)"
        echo "  --stack <name>      Default stack (default: web-nextjs)"
        echo "  --platform <name>   Default platform (default: gcp)"
        exit 0
        ;;
      *) print_error "Unknown option: $1"; exit 1 ;;
    esac
  done

  # Default org name to current directory
  if [ -z "$org_name" ]; then
    org_name=$(basename "$PWD")
  fi

  # Check if already initialized
  if [ -f "stack-workspace.yml" ] || [ -f ".workspace.yml" ]; then
    print_error "Workspace already initialized (stack-workspace.yml exists)"
    echo "  Use 'claudenv workspace sync' to update projects"
    exit 1
  fi

  local dist_dir
  if ! dist_dir=$(get_dist_dir 2>/dev/null); then
    print_error "Could not locate claudenv dist directory"
    exit 1
  fi

  # Validate stack
  if [ ! -d "$dist_dir/stacks/$default_stack" ]; then
    print_error "Unknown stack: $default_stack"
    echo "  Available stacks:"
    for s in "$dist_dir/stacks"/*/; do
      [ -d "$s" ] && echo "    $(basename "$s")"
    done
    exit 1
  fi

  # Validate platform
  if [ ! -d "$dist_dir/platforms/$default_platform" ]; then
    print_error "Unknown platform: $default_platform"
    echo "  Available platforms:"
    for p in "$dist_dir/platforms"/*/; do
      [ -d "$p" ] && echo "    $(basename "$p")"
    done
    exit 1
  fi

  print_header "Initializing Workspace: $org_name"

  # Create stack-workspace.yml
  cat > "stack-workspace.yml" << EOF
organization:
  name: $org_name
  github: $org_name
  domain_suffix: ".ai"
  dev_domain_suffix: ".dev"

defaults:
  stack: $default_stack
  platform: $default_platform

ports:
  start: 3000
  reserved:
    - 3001

plugins:
  directory: plugins
  prefix: "@$org_name"

projects: {}
EOF
  print_success "Created stack-workspace.yml"

  # Initialize .claude/ directory structure
  mkdir -p ".claude"/{stacks,platforms,services,logs,pids,state}
  print_success "Created .claude/ directory structure"

  # Copy selected stack
  if [ -d "$dist_dir/stacks/$default_stack" ]; then
    mkdir -p ".claude/stacks/$default_stack"
    cp -r "$dist_dir/stacks/$default_stack/"* ".claude/stacks/$default_stack/"
    print_success "Added stack: $default_stack"
  fi

  # Copy selected platform
  if [ -d "$dist_dir/platforms/$default_platform" ]; then
    mkdir -p ".claude/platforms/$default_platform"
    cp -r "$dist_dir/platforms/$default_platform/"* ".claude/platforms/$default_platform/"
    print_success "Added platform: $default_platform"
  fi

  # Copy workspace-level assets
  if [ -d "$dist_dir/workspace" ]; then
    [ -d "$dist_dir/workspace/commands" ] && cp -r "$dist_dir/workspace/commands/"* ".claude/commands/" 2>/dev/null || true
    [ -d "$dist_dir/workspace/rules" ] && mkdir -p ".claude/rules" && cp -r "$dist_dir/workspace/rules/"* ".claude/rules/" 2>/dev/null || true
    [ -d "$dist_dir/workspace/skills" ] && mkdir -p ".claude/skills/workspace" && cp -r "$dist_dir/workspace/skills/"* ".claude/skills/workspace/" 2>/dev/null || true
    [ -d "$dist_dir/workspace/references" ] && mkdir -p ".claude/references" && cp -r "$dist_dir/workspace/references/"* ".claude/references/" 2>/dev/null || true
    print_success "Added workspace rules, commands, and skills"
  fi

  # Copy services
  if [ -d "$dist_dir/services" ]; then
    cp -r "$dist_dir/services/"* ".claude/services/" 2>/dev/null || true
    print_success "Added service integrations"
  fi

  # Create bin/ wrapper scripts
  mkdir -p "bin"

  cat > "bin/stack" << 'BINEOF'
#!/bin/bash
exec stack "$@"
BINEOF
  chmod +x "bin/stack"

  cat > "bin/sync" << 'BINEOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec claudenv workspace sync "$@"
BINEOF
  chmod +x "bin/sync"

  print_success "Created bin/ wrapper scripts"

  # Create .gitignore if it doesn't exist
  if [ ! -f ".gitignore" ]; then
    cat > ".gitignore" << 'EOF'
node_modules/
dist/
.next/
*.log
.env.local
.claude/logs/
.claude/pids/
.claude/state/
.claude/backups/
.claude/loop/
EOF
    print_success "Created .gitignore"
  fi

  # Run claudenv init to install base framework
  print_info "Installing claudenv base framework..."
  source "$LIB_DIR/init.sh"
  cmd_init --force

  echo ""
  print_header "Workspace Ready!"
  echo ""
  echo "  Organization: $org_name"
  echo "  Default stack: $default_stack"
  echo "  Default platform: $default_platform"
  echo ""
  echo "Next steps:"
  echo "  1. Create a project:    stack new my-app"
  echo "  2. Set up local HTTPS:  stack setup"
  echo "  3. Start development:   stack dev my-app"
  echo ""
}
