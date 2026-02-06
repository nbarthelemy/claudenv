---
description: "Coordinate framework upgrades across all siquora projects"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, WebSearch, AskUserQuestion
---

# /ws:upgrade - Framework Upgrade Coordinator

Coordinate framework and dependency upgrades across all siquora projects.

## Usage

```bash
/ws:upgrade                     # Check for available upgrades
/ws:upgrade <package>           # Upgrade specific package across all projects
/ws:upgrade --status            # Show current versions across projects
```

## Process

### 1. Status Check

First, gather current state:

```bash
# Check versions in each project
for project in cmdstack scrimble monivore menory vinote; do
  echo "=== $project ==="
  cat "$project/package.json" | jq '{
    next: .dependencies.next,
    react: .dependencies.react,
    drizzle: .devDependencies["drizzle-orm"],
    typescript: .devDependencies.typescript
  }'
done

# Check @siquora/packages versions
cat packages/package.json | jq '.version'
```

### 2. Propose Upgrade

When upgrading, follow this order:

1. **@siquora packages** - Upgrade shared packages first
2. **Test in one project** - Usually cmdstack (most complex)
3. **Verify tests pass** - Run build, typecheck, lint
4. **Roll out to others** - Update remaining projects

### 3. Update Workspace Rules

After successful upgrade:

1. Edit `siquora/.claude/rules/siquora.md` → Framework Versions table
2. Update version number
3. Run `/ws:sync` to distribute

### 4. Upgrade Commands

```bash
# Upgrade Next.js across all projects
for project in cmdstack scrimble monivore menory vinote; do
  cd "$project"
  pnpm up next@latest
  pnpm up @next/eslint-plugin-next@latest
  cd ..
done

# Upgrade Drizzle
for project in cmdstack scrimble monivore menory vinote; do
  cd "$project"
  pnpm up drizzle-orm@latest drizzle-kit@latest
  pnpm --filter @*/web db:generate
  cd ..
done

# Upgrade TypeScript
for project in cmdstack scrimble monivore menory vinote; do
  cd "$project"
  pnpm up typescript@latest
  cd ..
done
```

## Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Framework Version Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Canonical (from siquora.md):
  Next.js: 15.x
  React: 19.x
  TypeScript: 5.7.x
  Drizzle: 0.38.x

Current Versions:
  cmdstack:  next@15.1.0  react@19.0.0  drizzle@0.38.0  ✓
  scrimble:  next@15.1.0  react@19.0.0  drizzle@0.38.0  ✓
  monivore:  next@15.0.3  react@19.0.0  drizzle@0.37.0  ⚠ outdated
  menory:    next@15.1.0  react@19.0.0  drizzle@0.38.0  ✓
  vinote:    next@15.1.0  react@19.0.0  drizzle@0.38.0  ✓

Available Updates:
  next: 15.1.0 → 15.2.0
  drizzle: 0.38.0 → 0.39.0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Safety Rules

1. **Never upgrade in production** - Only dev/local
2. **Test before rolling out** - One project first
3. **Update siquora.md** - Keep canonical versions current
4. **Commit per project** - Don't batch upgrade commits
5. **Check @siquora/packages compatibility** - Shared packages may need updates first
