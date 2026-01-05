# Claudenv Development

Instructions for developing and maintaining the claudenv framework.

## Project Structure

This repo's root directory IS the distributable `.claude/` content:

```
claudenv/              # ← Users clone this INTO their .claude/
├── .claude/           # Dev instructions (excluded from distribution)
│   └── CLAUDE.md      # This file
├── rules/
│   └── claudenv.md    # Framework instructions (imported by users)
├── settings.json      # Default permissions
├── commands/          # Slash commands
├── skills/            # Auto-invoked skills
├── scripts/           # Shell automation
└── ...
```

## Development Guidelines

### Adding Skills

1. Create directory: `skills/<name>/`
2. Create `SKILL.md` with frontmatter (name, description, allowed-tools)
3. Add `references/` for supporting docs
4. Add `assets/` for JSON data files
5. Description must be <1024 chars for auto-invoke

### Adding Commands

1. Create `commands/<name>.md`
2. Add frontmatter: description, allowed-tools
3. Test with `/name` in Claude Code

### Testing Changes

```bash
# Test in a fresh directory
mkdir /tmp/test-project && cd /tmp/test-project
git clone /path/to/claudenv .claude
rm -rf .claude/.git .claude/.claude .claude/README.md
# Run Claude Code and test /claudenv
```

### Release Process

1. Update `version.json` with new version and changelog
2. Update `README.md` changelog section
3. Commit with descriptive message
4. Push to main
5. Users update via `/claudenv:update` or fresh install

## Key Files

| File | Purpose |
|------|---------|
| `rules/claudenv.md` | Main framework instructions |
| `settings.json` | Default permissions matrix |
| `scripts/detect-stack.sh` | Tech detection (50+ technologies) |
| `scripts/install.sh` | Smart installer |
| `skills/skill-creator/` | Scaffolds new skills |

## Do Without Asking

- Edit any file in this repo
- Run tests and validation scripts
- Update documentation
- Git operations (commit, branch, etc.)

## Ask First

- Push to remote
- Major architectural changes
- Breaking changes to user-facing APIs
