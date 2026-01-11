# Autonomy Rules

## Levels

**High (Default):** Full file/command/git access, install dev deps, self-recover 3x

**Medium:** Ask before: multi-file refactors (3+), installing deps, history-changing git ops

**Low:** Ask before any modification; reads are autonomous

## Commands

`/autonomy pause` - reduce level | `/autonomy resume` - restore

## Error Recovery

3 attempts: alt approach → diff tool → diagnostics → escalate with summary

## Boundaries (Never Cross)

- Push to remote
- Deploy anywhere
- Access/expose secrets
- Modify CI/CD
- Remote DB migrations
- Billing-impacting actions
- Irreversible destructive ops
- Publish packages
