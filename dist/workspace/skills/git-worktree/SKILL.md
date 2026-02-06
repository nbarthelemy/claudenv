---
name: git-worktree
description: Git worktree management for isolated feature development. Use when starting new features, needing isolated development environments, working on multiple features simultaneously, or enabling parallel agent work. Creates isolated workspaces sharing the same repository.
allowed-tools:
  - Read
  - Write
  - Bash(git *, npm *, pnpm *, yarn *, bun *, pip *, cargo *, ls, mkdir, rm -rf)
  - Glob
  - Grep
---

# Git Worktree Skill

You are a workspace isolation specialist. Your role is to create and manage git worktrees for isolated feature development.

## What Are Git Worktrees?

Git worktrees create **isolated workspaces sharing the same repository**. This allows:

- Working on multiple branches simultaneously
- Parallel agent work without file conflicts
- Isolated feature development
- Quick context switching without stashing

```
main-repo/                    # Main working directory (main branch)
.worktrees/
├── feature-auth/            # Worktree 1 (feature/auth branch)
├── feature-dashboard/       # Worktree 2 (feature/dashboard branch)
└── bugfix-login/           # Worktree 3 (bugfix/login branch)
```

All worktrees share the same `.git` history but have completely isolated file systems.

## Autonomy Level: Full

- Create worktrees without asking
- Run setup commands automatically
- Verify environment is ready
- Clean up completed worktrees

---

## When to Use Worktrees

### Good Use Cases

| Scenario | Why Worktrees Help |
|----------|-------------------|
| New feature development | Isolated from main, easy to discard |
| Parallel agent work | Agents don't conflict on files |
| Long-running experiments | Keep main clean while experimenting |
| Hotfix while feature in progress | Don't stash, just switch worktrees |
| Comparing implementations | Side-by-side in different directories |

### When NOT to Use

| Scenario | Better Alternative |
|----------|-------------------|
| Quick single-file fix | Just commit to current branch |
| Learning/exploring | Use main, don't need isolation |
| Already in a worktree | Finish current work first |

---

## Worktree Directory Selection

### Step 1: Check Existing Configuration

```bash
# Check for existing worktree directory
ls -la .worktrees/ 2>/dev/null || ls -la worktrees/ 2>/dev/null
```

### Step 2: Check Project Configuration

Look in:
- `CLAUDE.md` - May specify worktree location
- `.gitignore` - Should ignore worktree directory
- Project conventions

### Step 3: Choose Location

| Priority | Location | When to Use |
|----------|----------|-------------|
| 1 | `.worktrees/` | Default, hidden, project-local |
| 2 | `worktrees/` | Visible, project-local |
| 3 | `~/.worktrees/{project}/` | Global, outside repo |

**Safety Rule**: If using project-local directory, MUST verify it's gitignored.

---

## Creating a Worktree

### Pre-Flight Checks

```bash
# 1. Verify we're in a git repo
git rev-parse --git-dir

# 2. Check for existing worktrees
git worktree list

# 3. Verify worktree directory is gitignored (if project-local)
git check-ignore .worktrees/ || echo "WARNING: Not ignored"
```

### If Not Gitignored

```bash
# Add to .gitignore
echo ".worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: add worktrees directory to gitignore"
```

### Creation Command

```bash
# Create worktree with new branch
git worktree add .worktrees/{name} -b {branch-name}

# Or with existing branch
git worktree add .worktrees/{name} {existing-branch}
```

### Naming Convention

| Type | Branch Name | Worktree Dir |
|------|-------------|--------------|
| Feature | `feature/{name}` | `.worktrees/{name}` |
| Bugfix | `bugfix/{name}` | `.worktrees/fix-{name}` |
| Experiment | `experiment/{name}` | `.worktrees/exp-{name}` |
| Hotfix | `hotfix/{name}` | `.worktrees/hot-{name}` |

---

## Post-Creation Setup

### Auto-Detect and Run Setup

```bash
# Navigate to worktree
cd .worktrees/{name}

# Detect project type and run setup
if [ -f "package.json" ]; then
    # Node.js project
    if [ -f "pnpm-lock.yaml" ]; then
        pnpm install
    elif [ -f "yarn.lock" ]; then
        yarn install
    elif [ -f "bun.lockb" ]; then
        bun install
    else
        npm install
    fi
elif [ -f "Cargo.toml" ]; then
    cargo build
elif [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
elif [ -f "go.mod" ]; then
    go mod download
fi
```

### Verify Setup

```bash
# Run tests to establish baseline
npm test 2>/dev/null || \
pytest 2>/dev/null || \
cargo test 2>/dev/null || \
go test ./... 2>/dev/null
```

### Report Status

```markdown
## Worktree Created

**Location**: .worktrees/{name}
**Branch**: feature/{name}
**Base**: main
**Setup**: npm install (success)
**Tests**: 45 passing, 0 failing

Ready for development.
```

---

## Working in Worktrees

### Navigation

```bash
# List all worktrees
git worktree list

# Switch to worktree (just cd)
cd .worktrees/{name}

# Return to main
cd /path/to/main/repo
```

### Synchronizing with Main

```bash
# From worktree, get latest main
git fetch origin main
git rebase origin/main

# Or merge
git merge origin/main
```

### Committing

```bash
# Commits in worktree go to worktree's branch
git add .
git commit -m "feat: implement feature"

# Push worktree branch
git push -u origin feature/{name}
```

---

## Finishing Work

### When Feature is Complete

Four options available:

#### Option 1: Merge to Main Locally

```bash
# Return to main repo
cd /path/to/main/repo

# Merge feature branch
git checkout main
git merge feature/{name}

# Clean up worktree
git worktree remove .worktrees/{name}
git branch -d feature/{name}
```

#### Option 2: Create Pull Request

```bash
# Push branch from worktree
cd .worktrees/{name}
git push -u origin feature/{name}

# Create PR
gh pr create --title "Feature: {name}" --body "Description"

# Keep worktree until PR merged, then clean up
```

#### Option 3: Keep for Later

```bash
# Just leave it - worktree persists
# Can return anytime with: cd .worktrees/{name}
```

#### Option 4: Discard Work

```bash
# Force remove worktree and branch
git worktree remove --force .worktrees/{name}
git branch -D feature/{name}
```

**For discard**: Require explicit confirmation - type "discard" to proceed.

---

## Worktree Commands

```bash
# List all worktrees
git worktree list

# Add new worktree
git worktree add <path> <branch>

# Remove worktree
git worktree remove <path>

# Prune stale worktrees (after manual deletion)
git worktree prune

# Lock worktree (prevent removal)
git worktree lock <path>

# Unlock worktree
git worktree unlock <path>
```

---

## Multi-Agent Worktree Pattern

When multiple agents work in parallel:

### Setup Phase

```bash
# Agent 1: Create worktree for auth feature
git worktree add .worktrees/auth -b feature/auth

# Agent 2: Create worktree for dashboard feature
git worktree add .worktrees/dashboard -b feature/dashboard

# Agent 3: Create worktree for api feature
git worktree add .worktrees/api -b feature/api
```

### Work Phase

- Each agent works in its own worktree
- No file conflicts possible
- Each can commit independently

### Integration Phase

```bash
# All agents done - merge in order
git checkout main
git merge feature/auth
git merge feature/dashboard
git merge feature/api

# Resolve any conflicts in integration
# Clean up all worktrees
```

---

## Red Flags (STOP)

### Creation Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Creating worktree for quick fix | Overkill | Use main branch |
| Worktree directory not gitignored | May commit worktree | Add to .gitignore first |
| Many stale worktrees exist | Cleanup needed | Prune before creating more |

### Work Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Editing files in main while worktree exists for that feature | Confusion | Work in one place |
| Worktree far behind main | Merge conflicts likely | Rebase regularly |
| Forgetting which worktree you're in | Wrong commits | Check `git branch` frequently |

### Cleanup Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Deleting worktree directory manually | Leaves stale refs | Use `git worktree remove` |
| Removing worktree with uncommitted changes | Work lost | Commit or stash first |

---

## Integration with Other Skills

### With autonomous-loop

- Create worktree before starting loop
- All loop iterations work in isolated worktree
- Merge or discard when loop completes

### With two-stage-review

- Review happens on worktree branch
- Merge only after both stages pass

### With verification-gate

- Verify tests pass in worktree before merge
- Fresh test run in main after merge

---

## Commands

| Command | Description |
|---------|-------------|
| `/ws:worktree:create {name}` | Create new worktree for feature |
| `/ws:worktree:list` | List all worktrees |
| `/ws:worktree:finish` | Present finish options for current worktree |
| `/ws:worktree:cleanup` | Remove completed/stale worktrees |

---

## Output Format

### Creation Output

```json
{
  "skill": "git-worktree",
  "action": "create",
  "worktree": {
    "name": "auth-feature",
    "path": ".worktrees/auth-feature",
    "branch": "feature/auth",
    "base": "main"
  },
  "setup": {
    "command": "pnpm install",
    "status": "success"
  },
  "verification": {
    "tests": "45 passing, 0 failing"
  },
  "ready": true
}
```

### Finish Output

```json
{
  "skill": "git-worktree",
  "action": "finish",
  "worktree": ".worktrees/auth-feature",
  "branch": "feature/auth",
  "options": [
    "Merge to main locally",
    "Push and create PR",
    "Keep for later",
    "Discard work"
  ],
  "recommendation": "Push and create PR (code reviewed, tests passing)"
}
```

---

## Remember

**Worktrees provide isolation, not complexity.**

Use them when isolation helps (features, experiments, parallel work).
Skip them when isolation is overkill (quick fixes, small changes).

The goal is productivity, not process.
