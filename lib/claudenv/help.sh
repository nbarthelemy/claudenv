#!/bin/bash
# Claudenv Help System
# Displays usage information for the claudenv CLI.

show_help() {
  echo ""
  echo -e "${BOLD}claudenv${NC} — Claude Code framework CLI"
  echo ""
  echo -e "${CYAN}Usage:${NC}"
  echo "  claudenv <command> [options]"
  echo ""
  echo -e "${CYAN}Commands:${NC}"
  echo "  init                         Initialize .claude/ in current directory"
  echo "  update                       Update framework files to latest version"
  echo "  workspace init               Initialize multi-project workspace"
  echo "  workspace sync [project|all] Sync framework files to projects"
  echo "  workspace add-stack <name>   Add a technology stack"
  echo "  workspace add-platform <name> Add a cloud platform"
  echo "  version                      Show version"
  echo ""
  echo -e "${CYAN}Examples:${NC}"
  echo "  claudenv init                         # Bootstrap .claude/ in current project"
  echo "  claudenv init --force                 # Overwrite existing installation"
  echo "  claudenv update                       # Update to latest version"
  echo "  claudenv update --dry-run             # Preview changes without applying"
  echo "  claudenv workspace init --org myorg   # Create workspace"
  echo "  claudenv workspace sync all           # Sync all projects"
  echo "  claudenv workspace add-stack web-nextjs"
  echo ""
  echo -e "${CYAN}Documentation:${NC}"
  echo "  https://github.com/nbarthelemy/claudenv"
  echo ""
}

show_workspace_help() {
  echo ""
  echo -e "${BOLD}claudenv workspace${NC} — Multi-project workspace management"
  echo ""
  echo -e "${CYAN}Usage:${NC}"
  echo "  claudenv workspace <subcommand> [options]"
  echo ""
  echo -e "${CYAN}Subcommands:${NC}"
  echo "  init                    Initialize a new workspace"
  echo "  sync [project|all]      Sync framework files to projects"
  echo "  add-stack <name>        Add a technology stack"
  echo "  add-platform <name>     Add a cloud platform"
  echo ""
  echo -e "${CYAN}Options for 'init':${NC}"
  echo "  --org <name>            Organization name"
  echo "  --stack <name>          Default stack (default: web-nextjs)"
  echo "  --platform <name>       Default platform (default: gcp)"
  echo ""
  echo -e "${CYAN}Options for 'sync':${NC}"
  echo "  --dry-run               Preview changes without applying"
  echo ""
  echo -e "${CYAN}Options for 'add-stack' / 'add-platform':${NC}"
  echo "  --list                  Show available options"
  echo ""
  echo -e "${CYAN}Available stacks:${NC}"
  local dist_dir
  if dist_dir=$(get_dist_dir 2>/dev/null); then
    if [ -d "$dist_dir/stacks" ]; then
      for stack in "$dist_dir/stacks"/*/; do
        [ -d "$stack" ] && echo "  $(basename "$stack")"
      done
    fi
  else
    echo "  web-nextjs, ios-swift, android-kotlin, shopify-app, shopify-theme, watchos-swift"
  fi
  echo ""
  echo -e "${CYAN}Available platforms:${NC}"
  if [ -n "${dist_dir:-}" ] && [ -d "$dist_dir/platforms" ]; then
    for platform in "$dist_dir/platforms"/*/; do
      [ -d "$platform" ] && echo "  $(basename "$platform")"
    done
  else
    echo "  gcp, shopify"
  fi
  echo ""
}
