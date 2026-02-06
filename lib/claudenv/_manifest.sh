#!/bin/bash
# Claudenv Manifest Utilities
# Functions for reading, comparing, and applying manifest-based file updates.
#
# Manifests are JSON files that track which files belong to claudenv
# and which have been deprecated across versions.

# Read file list from manifest
# Usage: manifest_files <manifest_path>
manifest_files() {
  local manifest="$1"
  if command -v jq &> /dev/null; then
    jq -r '.files[]' "$manifest" 2>/dev/null
  else
    # Fallback: crude JSON array parsing
    grep '"' "$manifest" | grep -v '^\s*[{}[\]]' | grep -v ':' | tr -d '", ' | grep -v '^$'
  fi
}

# Read deprecated files from manifest
# Usage: manifest_deprecated <manifest_path>
manifest_deprecated() {
  local manifest="$1"
  if command -v jq &> /dev/null; then
    jq -r '.deprecated[]' "$manifest" 2>/dev/null
  fi
}

# Read version from manifest
# Usage: manifest_version <manifest_path>
manifest_version() {
  local manifest="$1"
  if command -v jq &> /dev/null; then
    jq -r '.version // "unknown"' "$manifest" 2>/dev/null
  else
    grep '"version"' "$manifest" | head -1 | sed 's/.*: *"//' | sed 's/".*//'
  fi
}

# Compute files to add (in new but not old)
# Usage: manifest_diff_added <old_manifest> <new_manifest>
manifest_diff_added() {
  local old_manifest="$1"
  local new_manifest="$2"

  if ! command -v jq &> /dev/null; then
    print_warning "jq required for manifest diffing"
    return 1
  fi

  comm -13 \
    <(manifest_files "$old_manifest" | sort) \
    <(manifest_files "$new_manifest" | sort)
}

# Compute files to remove (in old but not new, and in deprecated)
# Usage: manifest_diff_removed <old_manifest> <new_manifest>
manifest_diff_removed() {
  local old_manifest="$1"
  local new_manifest="$2"

  manifest_deprecated "$new_manifest"
}

# Compute files to update (in both old and new)
# Usage: manifest_diff_updated <old_manifest> <new_manifest>
manifest_diff_updated() {
  local old_manifest="$1"
  local new_manifest="$2"

  if ! command -v jq &> /dev/null; then
    print_warning "jq required for manifest diffing"
    return 1
  fi

  comm -12 \
    <(manifest_files "$old_manifest" | sort) \
    <(manifest_files "$new_manifest" | sort)
}

# Apply manifest: copy files from source to target
# Usage: manifest_apply <source_dir> <target_dir> <manifest_path> [--dry-run]
manifest_apply() {
  local source_dir="$1"
  local target_dir="$2"
  local manifest="$3"
  local dry_run="${4:-}"
  local count=0

  while IFS= read -r file; do
    if [ -f "$source_dir/$file" ]; then
      if [ "$dry_run" = "--dry-run" ]; then
        echo "  Would copy: $file"
      else
        mkdir -p "$target_dir/$(dirname "$file")"
        cp "$source_dir/$file" "$target_dir/$file"
      fi
      count=$((count + 1))
    fi
  done < <(manifest_files "$manifest")

  echo "$count"
}

# Remove deprecated files from target
# Usage: manifest_cleanup <target_dir> <manifest_path> [--dry-run]
manifest_cleanup() {
  local target_dir="$1"
  local manifest="$2"
  local dry_run="${3:-}"
  local count=0

  while IFS= read -r file; do
    if [ -f "$target_dir/$file" ]; then
      if [ "$dry_run" = "--dry-run" ]; then
        echo "  Would remove: $file"
      else
        rm -f "$target_dir/$file"
      fi
      count=$((count + 1))
    fi
  done < <(manifest_deprecated "$manifest")

  echo "$count"
}
