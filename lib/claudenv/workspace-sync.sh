#!/bin/bash
# Claudenv Workspace Sync Command
# Sync framework files to workspace projects using a 4-layer architecture.
#
# Ported from workspace's sync-project.sh (670 lines).
#
# Sync layers (in order):
#   1. Claudenv base (inherited from workspace root, not synced — Claude Code loads automatically)
#   2. Workspace common files (rules, references, settings)
#   3. Stack-specific files (agents, commands, templates, references, skills)
#   4. Platform-specific files (agents, commands, rules, references, skills)
#
# Usage: claudenv workspace sync [project|all] [--dry-run]

# Counters
SYNCED=0
COUNT_AGENTS=0
COUNT_COMMANDS=0
COUNT_RULES=0
COUNT_SCRIPTS=0
COUNT_SKILLS=0
COUNT_TEMPLATES=0
COUNT_REFERENCES=0
COUNT_OTHER=0

CURRENT_PROJECT=""
DRY_RUN=""

inc_count() {
  case "$1" in
    agents) COUNT_AGENTS=$((COUNT_AGENTS + 1)) ;;
    commands) COUNT_COMMANDS=$((COUNT_COMMANDS + 1)) ;;
    rules) COUNT_RULES=$((COUNT_RULES + 1)) ;;
    scripts) COUNT_SCRIPTS=$((COUNT_SCRIPTS + 1)) ;;
    skills) COUNT_SKILLS=$((COUNT_SKILLS + 1)) ;;
    templates) COUNT_TEMPLATES=$((COUNT_TEMPLATES + 1)) ;;
    references) COUNT_REFERENCES=$((COUNT_REFERENCES + 1)) ;;
    *) COUNT_OTHER=$((COUNT_OTHER + 1)) ;;
  esac
}

substitute_vars() {
  local file="$1"
  local ext="${file##*.}"

  case "$ext" in
    md|yml|yaml|json|txt|template)
      [ -n "$PACKAGE_PREFIX" ] && sed -i '' "s|{package_prefix}|$PACKAGE_PREFIX|g" "$file" 2>/dev/null || true
      [ -n "$ORG_NAME" ] && sed -i '' "s|{org}|$ORG_NAME|g" "$file" 2>/dev/null || true
      [ -n "$ORG_NAME" ] && sed -i '' "s|{org_name}|$ORG_NAME|g" "$file" 2>/dev/null || true
      [ -n "$GITHUB_ORG" ] && sed -i '' "s|{github}|$GITHUB_ORG|g" "$file" 2>/dev/null || true
      [ -n "$DOMAIN_SUFFIX" ] && sed -i '' "s|{domain_suffix}|$DOMAIN_SUFFIX|g" "$file" 2>/dev/null || true
      [ -n "$DEV_DOMAIN_SUFFIX" ] && sed -i '' "s|{dev_domain_suffix}|$DEV_DOMAIN_SUFFIX|g" "$file" 2>/dev/null || true
      sed -i '' "s|{project}|$CURRENT_PROJECT|g" "$file" 2>/dev/null || true
      ;;
  esac
}

sync_file() {
  local src="$1"
  local dest="$2"
  local category="$3"

  [ -f "$src" ] || return 1

  if [ "$DRY_RUN" = "--dry-run" ]; then
    SYNCED=$((SYNCED + 1))
    inc_count "$category"
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  substitute_vars "$dest"
  SYNCED=$((SYNCED + 1))
  inc_count "$category"
}

sync_dir() {
  local src="$1"
  local dest="$2"
  local category="$3"

  [ -d "$src" ] || return 1

  if [ "$DRY_RUN" = "--dry-run" ]; then
    local count
    count=$(find "$src" -type f | wc -l | tr -d ' ')
    SYNCED=$((SYNCED + count))
    return 0
  fi

  mkdir -p "$dest"

  # Remove files from dest that don't exist in src
  if [ -d "$dest" ]; then
    find "$dest" -type f | while read -r dest_file; do
      local rel_path="${dest_file#$dest/}"
      if [ ! -f "$src/$rel_path" ]; then
        rm -f "$dest_file"
      fi
    done
    find "$dest" -type d -empty -delete 2>/dev/null || true
  fi

  cp -r "$src/"* "$dest/" 2>/dev/null || true

  find "$dest" -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) | while read -r file; do
    substitute_vars "$file"
  done

  local count
  count=$(find "$src" -type f | wc -l | tr -d ' ')
  SYNCED=$((SYNCED + count))
  inc_count "$category"
}

sync_project() {
  local project_name="$1"
  local workspace_root="$2"
  local workspace_claude="$workspace_root/.claude"
  local workspace_config="$workspace_root/stack-workspace.yml"
  [ ! -f "$workspace_config" ] && workspace_config="$workspace_root/.workspace.yml"

  local project_dir="$workspace_root/$project_name"
  local project_claude="$project_dir/.claude"
  CURRENT_PROJECT="$project_name"

  if [ ! -d "$project_dir" ]; then
    print_error "Project '$project_name' not found"
    return 1
  fi

  # Read project config
  local stack platform
  stack=$(read_project_yaml "$workspace_config" "$project_name" "stack" "web-nextjs")
  platform=$(read_project_yaml "$workspace_config" "$project_name" "platform" "gcp")
  [ "$stack" = "null" ] && stack="web-nextjs"
  [ "$platform" = "null" ] && platform="gcp"

  local stack_dir="$workspace_claude/stacks/$stack"
  local platform_dir="$workspace_claude/platforms/$platform"

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Syncing: $project_name"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  Stack:    $stack"
  echo "  Platform: $platform"

  # Initialize .claude if needed
  if [ ! -d "$project_claude" ]; then
    echo ""
    print_info "Initializing .claude/..."
    if [ "$DRY_RUN" != "--dry-run" ]; then
      mkdir -p "$project_claude"/{agents,commands,rules,scripts,skills,templates,references,workspace}
    fi
  fi

  # Reset counters
  SYNCED=0
  COUNT_AGENTS=0
  COUNT_COMMANDS=0
  COUNT_RULES=0
  COUNT_SCRIPTS=0
  COUNT_SKILLS=0
  COUNT_TEMPLATES=0
  COUNT_REFERENCES=0
  COUNT_OTHER=0

  # ========================================================================
  # Layer 1: Claudenv base — SKIPPED (Inheritance Model)
  # ========================================================================
  echo ""
  echo "  Claudenv base: inherited from workspace root"

  # ========================================================================
  # Layer 2: Workspace common files
  # ========================================================================
  echo ""
  echo "  Syncing workspace files..."

  # Copy workspace settings.json if project doesn't have one
  if [ ! -f "$project_claude/settings.json" ] && [ -f "$workspace_claude/settings.json" ]; then
    if [ "$DRY_RUN" != "--dry-run" ]; then
      cp "$workspace_claude/settings.json" "$project_claude/settings.json"
    fi
  fi

  # Update hook paths to point to workspace scripts
  if [ -f "$project_claude/settings.json" ] && [ "$DRY_RUN" != "--dry-run" ]; then
    sed -i.bak "s|bash .claude/scripts/|bash $workspace_claude/scripts/|g" "$project_claude/settings.json"
    sed -i.bak "s|bash $project_dir/.claude/scripts/|bash $workspace_claude/scripts/|g" "$project_claude/settings.json"
    rm -f "$project_claude/settings.json.bak"
  fi

  # Sync workspace-specific rules
  if [ -f "$workspace_claude/rules/workspace.md" ]; then
    sync_file "$workspace_claude/rules/workspace.md" "$project_claude/workspace/workspace.md" "rules"
  fi

  # Sync workspace-level references
  if [ -d "$workspace_claude/references/setup" ]; then
    sync_dir "$workspace_claude/references/setup" "$project_claude/references/setup" "references"
  fi

  # ========================================================================
  # Layer 3: Stack-specific files
  # ========================================================================
  if [ -d "$stack_dir" ]; then
    echo ""
    echo "  Syncing stack: $stack"

    [ -d "$stack_dir/agents" ] && sync_dir "$stack_dir/agents" "$project_claude/agents" "agents"
    [ -d "$stack_dir/commands" ] && sync_dir "$stack_dir/commands" "$project_claude/commands" "commands"
    [ -d "$stack_dir/templates" ] && sync_dir "$stack_dir/templates" "$project_claude/templates" "templates"
    [ -d "$stack_dir/references" ] && sync_dir "$stack_dir/references" "$project_claude/references" "references"

    # Sync stack skills (namespaced)
    if [ -d "$stack_dir/skills" ]; then
      for skill in "$stack_dir/skills"/*/; do
        [ -d "$skill" ] || continue
        local skill_name
        skill_name=$(basename "$skill")
        sync_dir "$skill" "$project_claude/skills/$stack/$skill_name" "skills"
      done
    fi
  fi

  # ========================================================================
  # Layer 4: Platform-specific files
  # ========================================================================
  if [ -d "$platform_dir" ]; then
    echo ""
    echo "  Syncing platform: $platform"

    [ -d "$platform_dir/agents" ] && sync_dir "$platform_dir/agents" "$project_claude/agents" "agents"
    [ -d "$platform_dir/commands" ] && sync_dir "$platform_dir/commands" "$project_claude/commands" "commands"
    [ -d "$platform_dir/rules" ] && sync_dir "$platform_dir/rules" "$project_claude/rules" "rules"
    [ -d "$platform_dir/references" ] && sync_dir "$platform_dir/references" "$project_claude/references" "references"

    if [ -d "$platform_dir/skills" ]; then
      for skill in "$platform_dir/skills"/*/; do
        [ -d "$skill" ] || continue
        local skill_name
        skill_name=$(basename "$skill")
        sync_dir "$skill" "$project_claude/skills/$platform/$skill_name" "skills"
      done
    fi
  fi

  # ========================================================================
  # Layer 5: Service-specific files
  # ========================================================================
  local services
  services=$(read_project_services "$workspace_config" "$project_name")
  if [ -n "$services" ]; then
    echo ""
    echo "  Syncing services: $services"

    for service in $services; do
      local service_dir="$workspace_claude/services/$service"
      if [ -d "$service_dir" ]; then
        [ -d "$service_dir/rules" ] && sync_dir "$service_dir/rules" "$project_claude/rules" "rules"
        [ -d "$service_dir/references" ] && sync_dir "$service_dir/references" "$project_claude/references/setup" "references"

        if [ -d "$service_dir/skills" ]; then
          for skill in "$service_dir/skills"/*/; do
            [ -d "$skill" ] || continue
            local skill_name
            skill_name=$(basename "$skill")
            sync_dir "$skill" "$project_claude/skills/$service/$skill_name" "skills"
          done
        fi
      fi
    done
  fi

  # ========================================================================
  # Post-sync: version tracking, .caddy, hooks
  # ========================================================================
  if [ "$DRY_RUN" != "--dry-run" ]; then
    mkdir -p "$project_claude/workspace"
    local ws_version
    ws_version=$(jq -r '.version // "unknown"' "$workspace_claude/workspace/manifest.json" 2>/dev/null || echo "unknown")
    cat > "$project_claude/workspace/version.json" << VERSIONEOF
{
  "workspace": "$ws_version",
  "base": "$(jq -r '.infrastructureVersion // .version // "unknown"' "$workspace_claude/version.json" 2>/dev/null || echo "unknown")",
  "stack": "$stack",
  "platform": "$platform",
  "services": "$(echo $services | xargs)",
  "syncedAt": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
VERSIONEOF

    chmod +x "$project_claude/scripts/"*.sh 2>/dev/null || true

    # Generate .caddy file (skip shopify-theme)
    if [ "$stack" != "shopify-theme" ]; then
      local domain_suffix="${DEV_DOMAIN_SUFFIX#.}"
      local port
      port=$(read_project_yaml "$workspace_config" "$project_name" "port" "3000")
      [ "$port" = "null" ] && port="3000"

      cat > "$project_dir/.caddy" << CADDYEOF
# $project_name Development Server
# Auto-generated by workspace sync
$project_name.$domain_suffix {
    reverse_proxy localhost:$port
}
CADDYEOF
    fi
  fi

  # Summary
  echo ""
  echo "  ────────────────────────────────────────────"
  echo "  Synced $SYNCED items:"
  [ $COUNT_COMMANDS -gt 0 ] && echo "    Commands:   $COUNT_COMMANDS"
  [ $COUNT_SKILLS -gt 0 ] && echo "    Skills:     $COUNT_SKILLS"
  [ $COUNT_AGENTS -gt 0 ] && echo "    Agents:     $COUNT_AGENTS"
  [ $COUNT_RULES -gt 0 ] && echo "    Rules:      $COUNT_RULES"
  [ $COUNT_SCRIPTS -gt 0 ] && echo "    Scripts:    $COUNT_SCRIPTS"
  [ $COUNT_TEMPLATES -gt 0 ] && echo "    Templates:  $COUNT_TEMPLATES"
  [ $COUNT_REFERENCES -gt 0 ] && echo "    References: $COUNT_REFERENCES"
  [ $COUNT_OTHER -gt 0 ] && echo "    Other:      $COUNT_OTHER"
}

cmd_workspace_sync() {
  local target=""
  DRY_RUN=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --dry-run) DRY_RUN="--dry-run"; shift ;;
      --help|-h)
        echo "Usage: claudenv workspace sync [project|all] [--dry-run]"
        echo ""
        echo "Sync framework files to workspace projects."
        echo ""
        echo "Arguments:"
        echo "  project     Sync a specific project"
        echo "  all         Sync all projects"
        echo ""
        echo "Options:"
        echo "  --dry-run   Preview changes without applying"
        exit 0
        ;;
      -*) print_error "Unknown option: $1"; exit 1 ;;
      *) target="$1"; shift ;;
    esac
  done

  # Find workspace root
  local workspace_root
  if [ -f "stack-workspace.yml" ]; then
    workspace_root="$(pwd)"
  elif [ -f ".workspace.yml" ]; then
    workspace_root="$(pwd)"
  elif workspace_root=$(find_workspace_root 2>/dev/null); then
    : # found
  else
    print_error "Not in a workspace. Run 'claudenv workspace init' first."
    exit 1
  fi

  local workspace_config="$workspace_root/stack-workspace.yml"
  [ ! -f "$workspace_config" ] && workspace_config="$workspace_root/.workspace.yml"

  # Read organization config
  ORG_NAME=$(read_org_yaml "$workspace_config" "name" "")
  GITHUB_ORG=$(read_org_yaml "$workspace_config" "github" "")
  DOMAIN_SUFFIX=$(read_org_yaml "$workspace_config" "domain_suffix" ".ai")
  DEV_DOMAIN_SUFFIX=$(read_org_yaml "$workspace_config" "dev_domain_suffix" ".dev")
  [ -n "$ORG_NAME" ] && PACKAGE_PREFIX="@$ORG_NAME"

  if [ -z "$target" ]; then
    echo "Usage: claudenv workspace sync [project|all] [--dry-run]"
    echo ""
    echo "Projects:"
    if command -v yq &> /dev/null; then
      yq '.projects | keys | .[]' "$workspace_config" 2>/dev/null | while read -r project; do
        echo "  - $project"
      done
    else
      grep -E "^  [a-z].*:$" "$workspace_config" 2>/dev/null | sed 's/:$//' | while read -r project; do
        echo " $project"
      done
    fi
    exit 1
  fi

  if [ "$target" = "all" ]; then
    local projects
    if command -v yq &> /dev/null; then
      projects=$(yq '.projects | keys | .[]' "$workspace_config" 2>/dev/null)
    else
      projects=$(grep -E "^  [a-z].*:$" "$workspace_config" 2>/dev/null | sed 's/^ *//' | sed 's/:$//')
    fi

    for project in $projects; do
      sync_project "$project" "$workspace_root"
    done

    # Generate root .caddy file
    if [ "$DRY_RUN" != "--dry-run" ]; then
      echo ""
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
      echo "  Generating Caddy configuration..."
      echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

      local domain_suffix="${DEV_DOMAIN_SUFFIX#.}"
      cat > "$workspace_root/.caddy" << ROOTCADDYEOF
# ${ORG_NAME:-Workspace} Development Caddy Config
# Auto-generated by workspace sync
{
    local_certs
    default_bind 127.0.0.1
}

ROOTCADDYEOF

      for project in $projects; do
        local proj_stack
        proj_stack=$(read_project_yaml "$workspace_config" "$project" "stack" "")
        if [ -d "$workspace_root/$project" ] && [ "$proj_stack" != "shopify-theme" ]; then
          echo "import $project/.caddy" >> "$workspace_root/.caddy"
        fi
      done

      echo "" >> "$workspace_root/.caddy"
      print_success "Generated .caddy files"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "All projects synced!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  else
    sync_project "$target" "$workspace_root"
  fi
}
