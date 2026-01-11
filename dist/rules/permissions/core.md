# Permission Matrix

## Wildcard Bash Permissions (Claude Code 2.1+)

Bash permissions support wildcards at any position:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm *)",        // npm followed by anything
      "Bash(git *)",        // git followed by anything
      "Bash(* --help)",     // any command with --help
      "Bash(docker compose *)"  // docker compose followed by anything
    ]
  }
}
```

**Pattern Examples:**
- `Bash(npm *)` - npm followed by anything
- `Bash(* install)` - Any command ending with install
- `Bash(docker * build)` - docker, anything, then build

---

## Command Categories

### Always Allowed (Universal)

```
# File operations
cat, ls, find, grep, egrep, fgrep, head, tail, wc, sort, uniq
sed, awk, cut, tr, xargs, mkdir, rm, cp, mv, touch, chmod, ln

# Output & navigation
echo, printf, pwd, cd, which, type, whereis, file, stat, du, df, tree

# Modern alternatives
bat, rg, ag, fd, diff, patch

# Archives
tar, zip, unzip, gzip, gunzip

# Environment
env, printenv, export, source

# Network (read-only)
curl, wget

# Data processing
jq, yq, base64, md5sum, sha256sum

# Utilities
date, bc, test, true, false, sleep, time, timeout, tee
```

### Always Allowed (Git - Local Only)

```
git add, git commit, git checkout, git branch, git stash
git status, git log, git diff, git fetch, git pull
git merge, git rebase, git reset, git clean
git rev-list, git rev-parse, git show, git blame
git bisect, git cherry-pick, git tag, git describe
git shortlog, git reflog, git remote (read)
git config --get, git config --list
git ls-files, git ls-tree, git worktree, git submodule
```

### Requires Approval

```
git push (any remote)
```

### Always Denied

```
# Destructive system operations
rm -rf /, rm -rf /*, rm -rf ~, rm -rf ~/*
:(){ :|:& };:  (fork bomb)
> /dev/sda, > /dev/hda, > /dev/nvme*
mkfs, mkfs.*, fdisk, parted
dd if=/dev/*, dd of=/dev/*
chmod -R 777 /, chown -R * /

# Sudo operations
sudo rm -rf *, sudo chmod *, sudo chown *
sudo mkfs *, sudo dd *, sudo fdisk *

# System control
shutdown, reboot, halt, poweroff, init
systemctl stop *, systemctl disable *
killall *, pkill -9 *, kill -9 -1

# Dangerous overwrites
> /etc/*, mv /* *, mv /etc *, mv /usr *, mv /var *

# Remote code execution
wget * | sh, wget * | bash
curl * | sh, curl * | bash
eval *

# Publishing (requires approval)
npm publish, yarn publish, pnpm publish
cargo publish, gem push, twine upload
poetry publish, dotnet nuget push
pub publish, hex publish
```

## Tech-Specific Permissions

Permissions are dynamically added based on detected tech stack during `/claudenv`.

**Reference:** See `skills/tech-detection/assets/command-mappings.json` for full mapping of technologies to commands.

## Customization

Override permissions in `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": ["Bash(custom-command *)"],
    "deny": ["Bash(npm publish *)"]
  }
}
```
