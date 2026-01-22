# Learning System

Simple, human-in-the-loop learning for the claudenv framework.

## How It Works

1. **During sessions** - Claude notes useful patterns in `observations.md`
2. **At session end** - `/ce:reflect` consolidates observations into proposals
3. **Human review** - User reviews proposals and approves/rejects
4. **Implementation** - Approved proposals become skills, agents, or rules

## Structure

```
learning/
├── README.md           # This file (tracked)
├── implemented.md      # Log of implemented proposals (tracked)
└── working/            # Ephemeral files (gitignored)
    ├── observations.md
    ├── proposals.md
    ├── pending-skills.md
    ├── pending-agents.md
    ├── pending-commands.md
    ├── pending-hooks.md
    └── patterns.json
```

## Files

| File | Purpose |
|------|---------|
| `implemented.md` | Log of implemented proposals |
| `working/observations.md` | Raw observations from sessions |
| `working/proposals.md` | Consolidated proposals awaiting review |
| `working/pending-*.md` | Pending proposals by type |
| `working/patterns.json` | Pattern tracking data |

## Commands

- `/ce:reflect` - Review session, consolidate learnings
- `/ce:learn review` - Show pending proposals
- `/ce:learn approve <id>` - Approve a proposal for implementation

## What Gets Captured

- Repeated multi-step workflows (potential skills)
- Technology-specific patterns (potential agents)
- Error recovery patterns (potential rules)
- Useful commands/scripts (potential commands)

## Thresholds

Proposals are auto-generated when:
- Same pattern observed 3+ times across sessions
- User explicitly says "remember this" or "we should automate this"
