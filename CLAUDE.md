# Project Instructions

> **Note:** Full instructions are in `.claude/CLAUDE.md`
>
> This file is kept at the project root for compatibility with tools that expect CLAUDE.md here.

See [.claude/CLAUDE.md](.claude/CLAUDE.md) for:
- Autonomy & permissions configuration
- Skill and command documentation
- Infrastructure overview
- Workflow guidelines

## Quick Reference

### Key Commands

- `/claudenv` - Bootstrap infrastructure
- `/interview` - Project specification
- `/infrastructure:status` - System overview
- `/health:check` - Verify integrity
- `/learn:review` - Review suggestions

### Autonomy Level: High

Claude operates with full autonomy for:
- File operations
- Local git operations
- Dev dependency installation
- Skill/automation creation
- Error recovery (3 retries)

### Requires Approval

- Push to remote
- Deploy to any environment
- Secrets/credentials
- CI/CD changes
- Package publishing
