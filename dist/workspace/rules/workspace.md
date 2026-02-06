# {org_name} Workspace Rules

> Generated for project: {project}

## Architecture

```
{org}/
├── .workspace.yml         # Project registry and config
├── .claude/               # Installed framework (claudenv + workspace)
├── bin/                   # Wrapper scripts (sync, dev, upgrade)
├── packages/              # Shared packages ({package_prefix}/*)
└── {project}/             # This project
```

## Shared Packages

Import shared packages:

```typescript
import { something } from "{package_prefix}/package-name";
```

**Rules:**
- Before implementing any common functionality, check if a `{package_prefix}/*` package exists
- **NEVER install external packages directly in projects** - if a package is needed (e.g., `next-auth`, `stripe`, `drizzle-orm`), it should be a dependency of the relevant `{package_prefix}/*` package, not the project itself
- Projects should only have `{package_prefix}/*` packages and project-specific dependencies in their `package.json`
- If an external package is missing, add it to the appropriate shared package and rebuild

## Development

### Commands

```bash
bin/dev {project}      # Start this project's dev server
bin/sync {project}     # Re-sync framework files
bin/rebuild {project}  # Regenerate code, preserve .claude/ knowledge
bin/sync all           # Sync all projects
```

### Conventions

| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-profile.tsx` |
| Components | PascalCase | `UserProfile` |
| Functions | camelCase | `getUserProfile` |
| Constants | SCREAMING_SNAKE | `MAX_RETRY_COUNT` |
| DB tables | snake_case | `user_profiles` |

### Git

- Branch from `main`
- PR titles: `feat:`, `fix:`, `refactor:`, `docs:`, `chore:`
- Squash merge to main

### Environment

- `.env.local` for local secrets (never commit)
- `.env.example` for documentation
- Production secrets in platform secret manager

## Cross-Project Changes

1. Modify `packages/` first (if shared code)
2. Test in {project}
3. Verify build passes
4. Run `bin/sync all` to distribute

## Memory System

Each project maintains its own memory database (`.claude/memory/memory.db`) that persists across sessions and workspace syncs.

**Project-level:** Observations, decisions, patterns specific to this project
**Workspace-level:** Use `/ws:recall` for cross-project memory search

```bash
/ce:recall search "auth"    # Search this project's memory
/ws:recall search "auth"    # Search all projects in workspace
```

Memory is NOT synced between projects - each project maintains isolated knowledge.

## Autonomy

**Do Without Asking:**
- Edit files, run tests, install dev deps, local git ops

**Ask First:**
- Push to remote, deploy, production DB changes, modify shared packages
