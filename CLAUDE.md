# Claudenv Development

Instructions for developing and maintaining the claudenv framework.

## Project Structure

```
claudenv/
├── CLAUDE.md              # This file (dev instructions, NOT distributed)
├── README.md              # Repo documentation
├── install.sh             # User installer
├── LICENSE
│
├── .claude/               # Symlinks for self-dogfooding
│   ├── settings.json → ../dist/settings.json
│   ├── commands → ../dist/commands
│   └── ...
│
└── dist/                  # Distributable content (copied to user's .claude/)
    ├── settings.json
    ├── version.json
    ├── commands/
    ├── skills/
    ├── rules/
    │   └── claudenv.md    # Framework instructions (users import this)
    ├── scripts/
    └── ...
```

## Development Guidelines

### Adding Skills

1. Create directory: `dist/skills/<name>/`
2. Create `SKILL.md` with frontmatter (name, description, allowed-tools)
3. Add `references/` for supporting docs
4. Add `assets/` for JSON data files
5. Description must be <1024 chars for auto-invoke

### Adding Commands

1. Create `dist/commands/<name>.md`
2. Add frontmatter: description, allowed-tools
3. Test with `/name` in Claude Code

### Testing Changes

```bash
# Use install.sh in a test project
mkdir /tmp/test-project && cd /tmp/test-project
/path/to/claudenv/install.sh
# Run Claude Code and test /claudenv
```

### Release Process

1. Update `dist/version.json` with new version and changelog
2. Update `README.md` changelog section
3. Commit with descriptive message
4. Push to main
5. Users update via `/claudenv:update` or fresh install

## Key Files

| File | Purpose |
|------|---------|
| `dist/rules/claudenv.md` | Main framework instructions |
| `dist/settings.json` | Default permissions matrix |
| `dist/scripts/detect-stack.sh` | Tech detection (50+ technologies) |
| `install.sh` | Smart installer |
| `dist/skills/skill-creator/` | Scaffolds new skills |

## Do Without Asking

- Edit any file in this repo
- Run tests and validation scripts
- Update documentation
- Git operations (commit, branch, etc.)

## Ask First

- Push to remote
- Major architectural changes
- Breaking changes to user-facing APIs

## Project Facts

> Auto-captured from user corrections. Authoritative project knowledge.
> Review with `/reflect`. This section is created automatically when corrections are detected.

### Tooling

- Uses bash scripts for automation, not Python (corrected 2026-01-05)
- Skills use SKILL.md not skill.md (case-sensitive) (corrected 2026-01-05)

### Structure

<!-- File locations, directory conventions, organization patterns -->

### Conventions

<!-- Coding standards, naming conventions, style preferences -->

### Architecture

- Distributable content lives in dist/, symlinks in .claude/ for self-dogfooding (corrected 2026-01-05)

---

## Claudenv Framework

@rules/claudenv.md
