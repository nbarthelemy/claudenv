# bin/upgrade

Check for and apply workspace updates.

## Synopsis

```bash
bin/upgrade [options]
```

## Description

The `upgrade` command checks for updates to the workspace infrastructure and can apply them to all projects.

## Options

| Option | Description |
|--------|-------------|
| `--apply` | Apply updates to all projects |
| `--check` | Check for updates only (default) |

## Examples

### Check for Updates

```bash
bin/upgrade
```

Shows available updates without applying them:

```
Checking for workspace updates...

Current version: 1.2.0
Latest version:  1.3.0

Updates available:
  - New Next.js 15 templates
  - Updated GCP deployment rules
  - Bug fixes in dev server management

Run 'bin/upgrade --apply' to update all projects.
```

### Apply Updates

```bash
bin/upgrade --apply
```

Applies updates and re-syncs all projects:

```
Applying workspace updates...

Updating workspace infrastructure...
✓ Updated claudenv base
✓ Updated stack templates
✓ Updated platform rules

Syncing all projects...
  ✓ brandcmd
  ✓ cmdstack
  ✓ menory
  ✓ monivore
  ✓ myapp

All projects updated to version 1.3.0
```

## What Gets Updated

### Workspace Infrastructure

- `.claude/scripts/` - Core scripts
- `.claude/rules/` - Framework rules
- `.claude/templates/` - Project templates
- `.claude/stacks/` - Stack-specific files
- `.claude/platforms/` - Platform-specific files

### Project Files

After infrastructure update, runs `bin/sync all` to distribute:

- Updated rules
- New templates
- Fixed scripts
- Caddy configurations

## Version Tracking

Versions are tracked in:

| File | Purpose |
|------|---------|
| `.claude/version.json` | Workspace infrastructure version |
| `{project}/.claude/workspace/version.json` | Per-project sync version |

## Update Sources

Updates come from the claudenv framework repository, merged with workspace-specific customizations.

## Safe Updates

The upgrade process:

1. **Backs up** current configuration
2. **Downloads** new versions
3. **Merges** with local customizations
4. **Syncs** to all projects
5. **Validates** the update

If anything fails, the backup can be restored:

```bash
bin/upgrade --restore
```

## When to Upgrade

- After major framework releases
- When new features are announced
- To get bug fixes
- Before starting new projects

## Dependencies

- `curl` or `wget` - For downloading updates
- `jq` - For version parsing
- `yq` - For YAML manipulation

## See Also

- [bin/sync](./bin-sync.md) - Manual sync without upgrade
- [Claudenv Framework](../.claude/rules/claudenv/core.md)
