#!/bin/bash
# Claudenv Init Command
# Initialize .claude/ in the current directory with framework files.
#
# Refactored from bin/install. Supports both fresh install and update.
#
# Usage: claudenv init [--force]

REPO_URL="https://github.com/nbarthelemy/claudenv"
BRANCH="main"
TARGET=".claude"

cmd_init() {
  local force=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --force|-f) force=true; shift ;;
      --help|-h)
        echo "Usage: claudenv init [--force]"
        echo ""
        echo "Initialize .claude/ in the current directory."
        echo ""
        echo "Options:"
        echo "  --force, -f   Overwrite existing installation without prompting"
        exit 0
        ;;
      *) print_error "Unknown option: $1"; exit 1 ;;
    esac
  done

  # Check for workspace setup (parent .claude with claudenv)
  local WORKSPACE_ROOT=""
  local IS_SUBPROJECT=false
  local check_dir="$PWD"
  while [ "$check_dir" != "/" ]; do
    local parent_dir
    parent_dir=$(dirname "$check_dir")
    if [ -f "$parent_dir/.claude/version.json" ]; then
      WORKSPACE_ROOT="$parent_dir/.claude"
      IS_SUBPROJECT=true
      break
    fi
    check_dir="$parent_dir"
  done

  # Resolve dist directory
  local DIST=""
  local LOCAL_INSTALL=false

  if DIST=$(get_dist_dir 2>/dev/null); then
    LOCAL_INSTALL=true
  fi

  print_header "Claudenv Installer"

  # Report workspace detection
  if [ "$IS_SUBPROJECT" = true ]; then
    echo ""
    print_info "Workspace detected: $WORKSPACE_ROOT"
    print_info "Installing subproject config (inherits core skills from workspace)"
  fi

  # Check for existing .claude directory
  local EXISTING_CLAUDE_MD=""
  local IS_UPDATE=false
  if [ -d "$TARGET" ]; then
    IS_UPDATE=true
    echo ""
    print_info "Found existing .claude directory"

    # Preserve existing CLAUDE.md content
    if [ -f "$TARGET/CLAUDE.md" ]; then
      EXISTING_CLAUDE_MD=$(cat "$TARGET/CLAUDE.md")
      print_item "Will preserve your CLAUDE.md content"
    fi

    # Backup existing settings.local.json
    if [ -f "$TARGET/settings.local.json" ]; then
      cp "$TARGET/settings.local.json" /tmp/claudenv-settings-local.json.bak
      print_item "Will preserve settings.local.json"
    fi

    print_item "Will preserve custom skills, commands, and agents"

    if [ "$force" != true ]; then
      echo ""
      read -p "Update claudenv infrastructure? (y/N): " CONFIRM
      if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        exit 1
      fi
    fi
  fi

  # Download if not local install
  if [ "$LOCAL_INSTALL" = false ]; then
    echo ""
    print_info "Downloading Claudenv..."

    local TEMP_DIR
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    if command -v curl &> /dev/null; then
      curl -sL "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
    elif command -v wget &> /dev/null; then
      wget -qO- "${REPO_URL}/archive/refs/heads/${BRANCH}.tar.gz" | tar -xz -C "$TEMP_DIR"
    else
      print_error "curl or wget required"
      exit 1
    fi

    DIST="$TEMP_DIR/claudenv-${BRANCH}/dist"
  fi

  # Verify manifest exists
  if [ ! -f "$DIST/manifest.json" ]; then
    print_error "Missing manifest.json"
    exit 1
  fi

  # Create .claude directory if it doesn't exist
  mkdir -p "$TARGET"

  print_info "Installing claudenv framework..."

  # If updating, remove deprecated files first
  if [ "$IS_UPDATE" = true ] && [ -f "$TARGET/manifest.json" ]; then
    local removed
    removed=$(manifest_cleanup "$TARGET" "$DIST/manifest.json")
    if [ "$removed" -gt 0 ] 2>/dev/null; then
      print_item "Removed $removed deprecated files"
    fi
  fi

  # Framework directories that should only exist at workspace root
  local FRAMEWORK_DIRS="skills commands rules scripts templates agents orchestration"

  # Copy framework files using manifest
  if command -v jq &> /dev/null; then
    while IFS= read -r file; do
      if [ -f "$DIST/$file" ]; then
        # Skip framework directories for subprojects
        if [ "$IS_SUBPROJECT" = true ]; then
          local skip=false
          for dir in $FRAMEWORK_DIRS; do
            if [[ "$file" == ${dir}/* ]]; then
              skip=true
              break
            fi
          done
          if [ "$skip" = true ]; then
            continue
          fi
        fi
        mkdir -p "$TARGET/$(dirname "$file")"
        cp "$DIST/$file" "$TARGET/$file"
      fi
    done < <(jq -r '.files[]' "$DIST/manifest.json" 2>/dev/null)
  else
    # Fallback: copy all files but merge directories
    print_warning "Install jq for better custom content preservation"
    for dir in commands skills rules scripts templates learning agents orchestration; do
      if [ "$IS_SUBPROJECT" = true ]; then
        local skip=false
        for fdir in $FRAMEWORK_DIRS; do
          if [ "$dir" = "$fdir" ]; then
            skip=true
            break
          fi
        done
        if [ "$skip" = true ]; then
          continue
        fi
      fi
      if [ -d "$DIST/$dir" ]; then
        mkdir -p "$TARGET/$dir"
        cp -r "$DIST/$dir"/* "$TARGET/$dir"/ 2>/dev/null || true
      fi
    done
  fi

  # Copy config files
  cp "$DIST/settings.json" "$TARGET/settings.json"
  cp "$DIST/version.json" "$TARGET/version.json"
  cp "$DIST/manifest.json" "$TARGET/manifest.json"
  [ -f "$DIST/settings.local.json.template" ] && cp "$DIST/settings.local.json.template" "$TARGET/settings.local.json.template"

  # Restore settings.local.json
  if [ -f /tmp/claudenv-settings-local.json.bak ]; then
    mv /tmp/claudenv-settings-local.json.bak "$TARGET/settings.local.json"
  fi

  # Create empty directories for user data
  mkdir -p "$TARGET"/{logs,backups,loop,plans,rca,references,memory,state}

  # Make scripts executable
  chmod +x "$TARGET/scripts/"*.sh 2>/dev/null || true
  chmod +x "$TARGET/scripts/"*.js 2>/dev/null || true

  # Migration: v4.x → v5.x (unified hooks)
  if [ "$IS_UPDATE" = true ]; then
    if [ -f "$TARGET/scripts/code-gate.sh" ] && [ -f "$TARGET/scripts/unified-gate.sh" ]; then
      print_item "Migrating hooks: 3-hook → unified-gate"
      rm -f "$TARGET/scripts/code-gate.sh"
      rm -f "$TARGET/scripts/focus-enforce.sh"
      rm -f "$TARGET/scripts/read-before-write.sh"
      rm -f "$TARGET/scripts/tdd-enforce.sh"
      rm -f "$TARGET/scripts/todo-coordinator.sh"
      rm -f "$TARGET/scripts/decision-reminder.sh"
      rm -f "$TARGET/scripts/learning-observer.sh"
    fi
    rm -f "$TARGET/rules/parallel-execution.md"
    rm -f "$TARGET/rules/error-recovery/core.md"
    rm -f "$TARGET/rules/documentation.md"
  fi

  # Handle CLAUDE.md - preserve user content, add claudenv import
  if [ -n "$EXISTING_CLAUDE_MD" ]; then
    if echo "$EXISTING_CLAUDE_MD" | grep -qE "@rules/claudenv(.md|/core.md)"; then
      echo "$EXISTING_CLAUDE_MD" > "$TARGET/CLAUDE.md"
    else
      cat > "$TARGET/CLAUDE.md" << EOF
$EXISTING_CLAUDE_MD

## Claudenv Framework

@rules/claudenv/core.md
EOF
    fi
    print_success "Preserved your CLAUDE.md, added framework import"
  else
    cat > "$TARGET/CLAUDE.md" << 'EOF'
# Project Instructions

<!-- Add your project-specific instructions here -->

## Claudenv Framework

@rules/claudenv/core.md
EOF
    print_success "Created CLAUDE.md with framework import"
  fi

  # Create TODO.md if it doesn't exist
  if [ ! -f "$TARGET/TODO.md" ] && [ ! -f "./TODO.md" ]; then
    cp "$DIST/TODO.md" "$TARGET/TODO.md" 2>/dev/null || true
    print_success "Created TODO.md"
  fi

  # Count what was installed
  local LOCAL_SKILLS COMMANDS AGENTS
  LOCAL_SKILLS=$(find "$TARGET/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
  COMMANDS=$(find "$TARGET/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
  AGENTS=$(find "$TARGET/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

  print_header "Claudenv Installed!"
  echo ""
  if [ "$IS_SUBPROJECT" = true ]; then
    local WORKSPACE_SKILLS
    WORKSPACE_SKILLS=$(find "$WORKSPACE_ROOT/skills" -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
    print_item "Subproject config installed"
    print_item "Inherits $WORKSPACE_SKILLS skills from workspace root"
    print_item "$LOCAL_SKILLS local skills"
  else
    print_item "$LOCAL_SKILLS skills"
  fi
  print_item "$COMMANDS commands"
  print_item "$AGENTS agents"
  echo ""
  echo "Next steps:"
  echo "  1. Start Claude Code: claude"
  echo "  2. Run bootstrap: /ce:init"
  echo ""

  # Check for optional dependencies
  echo "Optional dependencies:"

  local VSS_AVAILABLE=false
  for path in /opt/homebrew/lib/vss0.dylib /usr/local/lib/vss0.dylib /usr/lib/sqlite3/vss0.so; do
    if [ -f "$path" ]; then
      VSS_AVAILABLE=true
      break
    fi
  done
  if [ "$VSS_AVAILABLE" = true ]; then
    print_success "sqlite-vss (semantic search)"
  else
    print_item "○ sqlite-vss (semantic search) - brew install sqlite-vss"
  fi

  if npm list @xenova/transformers &>/dev/null 2>&1 || [ -d "node_modules/@xenova/transformers" ]; then
    print_success "@xenova/transformers (embeddings)"
  else
    print_item "○ @xenova/transformers (embeddings) - npm i @xenova/transformers"
  fi

  echo ""
}
