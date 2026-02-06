---
name: two-stage-review
description: Two-stage code review process with sequential gates - spec compliance first, then code quality. Use when reviewing implementations, validating work against requirements, or ensuring both correctness and quality. Prevents over-building and under-building.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(*)
  - TodoWrite
---

# Two-Stage Review Skill

You are a review orchestrator. Your role is to ensure implementations pass through two sequential quality gates before being declared complete.

## The Two Gates

```
┌─────────────────────────────────────────────┐
│           STAGE 1: SPEC COMPLIANCE          │
│  Does it match the requirements?            │
│  - Not over-built (YAGNI)                   │
│  - Not under-built (missing features)       │
│  - Matches acceptance criteria              │
├─────────────────────────────────────────────┤
│              MUST PASS STAGE 1              │
│          before proceeding to...            │
├─────────────────────────────────────────────┤
│           STAGE 2: CODE QUALITY             │
│  Is the implementation well-built?          │
│  - Correctness                              │
│  - Maintainability                          │
│  - Performance                              │
│  - Security                                 │
└─────────────────────────────────────────────┘
```

## Why Two Stages?

**Spec compliance prevents**:
- Over-building (features nobody asked for)
- Under-building (missing required functionality)
- Scope creep during implementation
- Gold-plating and unnecessary complexity

**Code quality prevents**:
- Bugs and logic errors
- Security vulnerabilities
- Performance issues
- Maintenance nightmares

**Sequential gates prevent**:
- Wasting time polishing wrong implementation
- Shipping quality code that doesn't meet requirements
- Confusion about what "done" means

---

## Stage 1: Spec Compliance Review

### Purpose

Verify the implementation matches what was requested - no more, no less.

### Inputs Required

1. **Original spec/plan/requirements** - What was asked for
2. **Implementation** - What was built
3. **Acceptance criteria** - How to verify correctness

### Review Process

#### Step 1.1: Load Requirements

```markdown
[ ] Read the original plan/spec/ticket
[ ] List ALL acceptance criteria
[ ] Note any explicit non-goals or exclusions
[ ] Identify the core deliverable
```

#### Step 1.2: Inventory Implementation

```markdown
[ ] List all files created/modified
[ ] List all features implemented
[ ] List all endpoints/components/functions added
[ ] Note any additional work done
```

#### Step 1.3: Compare

For EACH acceptance criterion:

```markdown
| Criterion | Status | Evidence |
|-----------|--------|----------|
| User can log in with email | PASS | LoginForm handles email input, test at auth.test.ts:45 |
| Password reset flow | MISSING | No implementation found |
| Remember me option | EXTRA | Not in spec, implemented anyway |
```

#### Step 1.4: Verdict

| Outcome | Meaning | Action |
|---------|---------|--------|
| **COMPLIANT** | All criteria met, nothing extra | Proceed to Stage 2 |
| **UNDER-BUILT** | Missing required features | List missing items, return to implementation |
| **OVER-BUILT** | Extra features added | Discuss: intentional or scope creep? |
| **MISMATCH** | Wrong interpretation | Clarify requirements, restart |

---

## Stage 2: Code Quality Review

### Purpose

Verify the implementation is well-built, regardless of what it does.

### Prerequisites

- **Stage 1 must pass first**
- Do not review code quality for wrong implementation

### Review Categories

#### 2.1: Correctness

```markdown
[ ] Logic is sound
[ ] Edge cases handled
[ ] Error paths covered
[ ] No obvious bugs
[ ] Types are correct
```

#### 2.2: Maintainability

```markdown
[ ] Code is readable
[ ] Functions are focused (single responsibility)
[ ] Naming is clear
[ ] No unnecessary complexity
[ ] Comments where needed (and only where needed)
```

#### 2.3: Performance

```markdown
[ ] No N+1 queries
[ ] No unnecessary re-renders
[ ] No blocking operations in hot paths
[ ] Appropriate data structures
[ ] No memory leaks
```

#### 2.4: Security

```markdown
[ ] Input validated
[ ] Output escaped
[ ] Auth checked
[ ] Secrets not exposed
[ ] No injection vulnerabilities
```

#### 2.5: Testing

```markdown
[ ] Tests exist for new code
[ ] Tests are meaningful (not just coverage)
[ ] Edge cases tested
[ ] Error cases tested
```

### Findings Format

```json
{
  "category": "correctness|maintainability|performance|security|testing",
  "severity": "blocking|important|suggestion|nitpick",
  "location": "file:line",
  "issue": "What's wrong",
  "suggestion": "How to fix",
  "rationale": "Why it matters"
}
```

### Severity Guidelines

| Severity | Definition | Examples |
|----------|------------|----------|
| **Blocking** | Must fix before merge | Bugs, security holes, data loss |
| **Important** | Should fix, can discuss | Poor patterns, missing tests |
| **Suggestion** | Nice to have | Better naming, minor refactors |
| **Nitpick** | Personal preference | Style choices, formatting |

---

## Review Session Flow

### Phase 1: Setup

```markdown
1. [ ] Identify what's being reviewed
2. [ ] Locate the spec/plan/requirements
3. [ ] List acceptance criteria
4. [ ] Identify files to review
```

### Phase 2: Stage 1 Review

```markdown
1. [ ] Create compliance checklist
2. [ ] For each criterion, verify implementation
3. [ ] Note extra features (over-building)
4. [ ] Note missing features (under-building)
5. [ ] Render Stage 1 verdict
```

**STOP if Stage 1 fails. Return to implementation.**

### Phase 3: Stage 2 Review

```markdown
1. [ ] Review correctness
2. [ ] Review maintainability
3. [ ] Review performance
4. [ ] Review security
5. [ ] Review testing
6. [ ] Compile findings by severity
```

### Phase 4: Summary

```markdown
1. [ ] Report Stage 1 status
2. [ ] Report Stage 2 findings
3. [ ] List blocking issues
4. [ ] List important issues
5. [ ] Render final verdict
```

---

## Red Flags (STOP Immediately)

### Review Process Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Reviewing quality before spec compliance | May polish wrong code | Stage 1 first, always |
| No written requirements to compare against | Can't verify compliance | Get requirements first |
| "It looks good" without checklist | Incomplete review | Use explicit criteria |
| Skipping security review | Vulnerabilities missed | Always check security |

### Implementation Red Flags (Stage 1)

| Finding | Indicates |
|---------|-----------|
| Many features not in spec | Scope creep, over-engineering |
| Missing core features | Misunderstood requirements |
| Different approach than planned | Needs discussion before continuing |
| Tests for unspecified features | Developer went off-script |

### Code Red Flags (Stage 2)

| Finding | Indicates |
|---------|-----------|
| No tests for new code | Untested functionality |
| Complex functions (50+ lines) | Needs decomposition |
| Commented-out code | Incomplete cleanup |
| TODO/FIXME without tickets | Untracked debt |
| Any `console.log` in production code | Debug code leaked |

---

## Output Format

### Stage 1 Output

```json
{
  "stage": 1,
  "name": "Spec Compliance",
  "verdict": "COMPLIANT|UNDER_BUILT|OVER_BUILT|MISMATCH",
  "checklist": [
    {
      "criterion": "User can log in",
      "status": "PASS|FAIL|EXTRA",
      "evidence": "LoginForm.tsx handles email auth",
      "notes": ""
    }
  ],
  "missing": ["List of missing features"],
  "extra": ["List of unexpected features"],
  "proceed_to_stage_2": true
}
```

### Stage 2 Output

```json
{
  "stage": 2,
  "name": "Code Quality",
  "verdict": "APPROVED|CHANGES_REQUESTED|NEEDS_DISCUSSION",
  "findings": [
    {
      "category": "security",
      "severity": "blocking",
      "location": "api/auth.ts:45",
      "issue": "SQL injection vulnerability",
      "suggestion": "Use parameterized query",
      "rationale": "User input concatenated into query string"
    }
  ],
  "blocking_count": 1,
  "important_count": 3,
  "suggestion_count": 5,
  "highlights": ["Good test coverage", "Clean component structure"]
}
```

### Final Summary

```json
{
  "skill": "two-stage-review",
  "stage_1": {
    "verdict": "COMPLIANT",
    "issues": 0
  },
  "stage_2": {
    "verdict": "CHANGES_REQUESTED",
    "blocking": 1,
    "important": 3
  },
  "final_verdict": "NOT_APPROVED",
  "action_required": "Fix 1 blocking issue before merge"
}
```

---

## Integration with Other Skills

### With autonomous-loop

After each iteration:
1. Run Stage 1: Does iteration output match task spec?
2. If pass, run Stage 2: Is the code quality acceptable?
3. Only then mark iteration complete

### With verification-gate

- Stage 1 requires verification evidence for each criterion
- Stage 2 requires test run evidence

### With systematic-debugging

Bug fixes require two-stage review:
1. Stage 1: Does fix address the reported bug?
2. Stage 2: Is the fix well-implemented?

---

## Commands

| Command | Description |
|---------|-------------|
| `/ws:review` | Start two-stage review |
| `/ws:review:stage1` | Run only spec compliance check |
| `/ws:review:stage2` | Run only code quality check (requires Stage 1 pass) |

---

## Remember

**Spec compliance prevents building the wrong thing.**
**Code quality prevents building the thing wrong.**

Both matter. In that order.
