#!/bin/bash
# Claudenv Update Command
# Update framework files to the latest version via manifest-based differential.
#
# Usage: claudenv update [--dry-run] [--check]

REPO_URL="https://github.com/nbarthelemy/claudenv"
BRANCH="main"
TARGET=".claude"

cmd_update() {
  local dry_run=false
  local check_only=false

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run) dry_run=true; shift ;;
      --check) check_only=true; shift ;;
      --help|-h)
        echo "Usage: claudenv update [--dry-run] [--check]"
        echo ""
        echo "Update framework files to the latest version."
        echo ""
        echo "Options:"
        echo "  --dry-run   Preview changes without applying"
        echo "  --check     Check if update is available (no changes)"
        exit 0
        ;;
      *) print_error "Unknown option: $1"; exit 1 ;;
    esac
  done

  # Verify existing installation
  if [ ! -d "$TARGET" ] || [ ! -f "$TARGET/manifest.json" ]; then
    print_error "No claudenv installation found. Run 'claudenv init' first."
    exit 1
  fi

  # Read current version
  local current_version
  current_version=$(manifest_version "$TARGET/manifest.json")

  # Resolve source dist directory
  local DIST=""
  local LOCAL_INSTALL=false

  if DIST=$(get_dist_dir 2>/dev/null); then
    LOCAL_INSTALL=true
  fi

  # Download if not local
  local TEMP_DIR=""
  if [ "$LOCAL_INSTALL" = false ]; then
    print_info "Checking for updates..."

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

  if [ ! -f "$DIST/manifest.json" ]; then
    print_error "Missing manifest.json in update source"
    exit 1
  fi

  # Read new version
  local new_version
  new_version=$(manifest_version "$DIST/manifest.json")

  # Check-only mode
  if [ "$check_only" = true ]; then
    if [ "$current_version" = "$new_version" ]; then
      print_success "Already up to date (v$current_version)"
    else
      print_info "Update available: v$current_version → v$new_version"
    fi
    return 0
  fi

  print_header "Claudenv Update"
  echo ""
  echo "  Current: v$current_version"
  echo "  Latest:  v$new_version"

  if [ "$current_version" = "$new_version" ] && [ "$LOCAL_INSTALL" = false ]; then
    echo ""
    print_success "Already up to date"
    return 0
  fi

  echo ""

  # Compute diff
  if command -v jq &> /dev/null; then
    local added updated removed

    # Files to add (new files not in current)
    added=$(manifest_diff_added "$TARGET/manifest.json" "$DIST/manifest.json" 2>/dev/null | wc -l | tr -d ' ')
    # Files to update (exist in both)
    updated=$(manifest_diff_updated "$TARGET/manifest.json" "$DIST/manifest.json" 2>/dev/null | wc -l | tr -d ' ')
    # Files to remove (deprecated)
    removed=$(manifest_diff_removed "$TARGET/manifest.json" "$DIST/manifest.json" 2>/dev/null | wc -l | tr -d ' ')

    echo "  Changes:"
    [ "$added" -gt 0 ] 2>/dev/null && echo -e "    ${GREEN}+ $added new files${NC}"
    [ "$updated" -gt 0 ] 2>/dev/null && echo -e "    ${CYAN}~ $updated updated files${NC}"
    [ "$removed" -gt 0 ] 2>/dev/null && echo -e "    ${RED}- $removed deprecated files${NC}"
    echo ""
  fi

  if [ "$dry_run" = true ]; then
    print_info "Dry run — no changes applied"
    echo ""

    if command -v jq &> /dev/null; then
      echo "  New files:"
      manifest_diff_added "$TARGET/manifest.json" "$DIST/manifest.json" 2>/dev/null | while read -r f; do
        echo -e "    ${GREEN}+ $f${NC}"
      done

      echo ""
      echo "  Deprecated files:"
      manifest_diff_removed "$TARGET/manifest.json" "$DIST/manifest.json" 2>/dev/null | while read -r f; do
        if [ -f "$TARGET/$f" ]; then
          echo -e "    ${RED}- $f${NC}"
        fi
      done
    fi
    return 0
  fi

  # Preserve user content
  local EXISTING_CLAUDE_MD=""
  if [ -f "$TARGET/CLAUDE.md" ]; then
    EXISTING_CLAUDE_MD=$(cat "$TARGET/CLAUDE.md")
  fi
  if [ -f "$TARGET/settings.local.json" ]; then
    cp "$TARGET/settings.local.json" /tmp/claudenv-settings-local.json.bak
  fi

  # Remove deprecated files
  local cleanup_count
  cleanup_count=$(manifest_cleanup "$TARGET" "$DIST/manifest.json")
  if [ "$cleanup_count" -gt 0 ] 2>/dev/null; then
    print_success "Removed $cleanup_count deprecated files"
  fi

  # Check for workspace (subproject) mode
  local IS_SUBPROJECT=false
  local check_dir="$PWD"
  while [ "$check_dir" != "/" ]; do
    local parent_dir
    parent_dir=$(dirname "$check_dir")
    if [ -f "$parent_dir/.claude/version.json" ]; then
      IS_SUBPROJECT=true
      break
    fi
    check_dir="$parent_dir"
  done

  local FRAMEWORK_DIRS="skills commands rules scripts templates agents orchestration"

  # Copy updated files
  local file_count=0
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
      file_count=$((file_count + 1))
    fi
  done < <(manifest_files "$DIST/manifest.json")

  # Update config files
  cp "$DIST/settings.json" "$TARGET/settings.json"
  cp "$DIST/version.json" "$TARGET/version.json"
  cp "$DIST/manifest.json" "$TARGET/manifest.json"

  # Restore user settings
  if [ -f /tmp/claudenv-settings-local.json.bak ]; then
    mv /tmp/claudenv-settings-local.json.bak "$TARGET/settings.local.json"
  fi

  # Restore CLAUDE.md
  if [ -n "$EXISTING_CLAUDE_MD" ]; then
    echo "$EXISTING_CLAUDE_MD" > "$TARGET/CLAUDE.md"
  fi

  # Make scripts executable
  chmod +x "$TARGET/scripts/"*.sh 2>/dev/null || true
  chmod +x "$TARGET/scripts/"*.js 2>/dev/null || true

  # Run migrations
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

  print_success "Updated $file_count files"
  echo ""
  print_header "Update Complete"
  echo ""
  echo "  v$current_version → v$new_version"
  echo ""
}
