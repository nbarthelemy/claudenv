---
name: tdd
description: Test-Driven Development workflow guide. Enforces red-green-refactor cycle for reliable code.
triggers:
  - tdd
  - test driven
  - write tests first
  - red green refactor
tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash(npm test *, pnpm test *, yarn test *, pytest *, go test *, vitest *, jest *)
context: same
---

# TDD Skill

Guide test-driven development with strict red-green-refactor workflow.

## Activation

This skill activates when:
- User mentions "TDD", "test driven", "write tests first"
- User wants to add functionality with tests
- `/tdd` command is invoked

## Commands

| Command | Action |
|---------|--------|
| `/ce:tdd` | Show TDD status |
| `/ce:tdd disable` | Disable TDD enforcement for this project |
| `/ce:tdd enable` | Re-enable TDD enforcement |
| `/ce:tdd <feature>` | Start TDD workflow for a feature |

**Note:** TDD is enabled by default. Use `disable` only when necessary.

## Workflow

### Phase 1: RED (Write Failing Test)

1. **Understand the requirement** - What behavior are we testing?
2. **Create test file** - Name it `*.test.ts` or `*.spec.ts`
3. **Write the test**:
   ```typescript
   describe('UserService', () => {
     it('should create a user with valid email', async () => {
       const user = await userService.create({ email: 'test@example.com' });
       expect(user.id).toBeDefined();
       expect(user.email).toBe('test@example.com');
     });
   });
   ```
4. **Run the test** - Verify it FAILS (red)
5. **Confirm failure reason** - Should fail because code doesn't exist yet

### Phase 2: GREEN (Make Test Pass)

1. **Write minimal implementation** - Just enough to pass
2. **No premature optimization** - Simple, obvious code
3. **Run the test** - Verify it PASSES (green)
4. **Commit** - "feat: add user creation (TDD green)"

### Phase 3: REFACTOR (Improve Code)

1. **Look for improvements** - DRY, naming, structure
2. **Make small changes** - One refactor at a time
3. **Run tests after each change** - Must stay green
4. **Commit** - "refactor: extract validation logic"

## TDD Checklist

Before marking a feature complete:

- [ ] Test file exists and is comprehensive
- [ ] Tests cover happy path
- [ ] Tests cover edge cases
- [ ] Tests cover error conditions
- [ ] All tests pass
- [ ] No console.logs or debug code
- [ ] Code is refactored and clean

## TDD is Enabled by Default

The PreToolUse hook automatically enforces TDD in all claudenv projects.

## Disable TDD (Use Sparingly)

For projects where TDD doesn't apply:

```bash
touch .claude/tdd-disabled
```

Or in `.claude/settings.local.json`:

```json
{
  "tdd": {
    "enabled": false
  }
}
```

## Re-enable TDD

```bash
rm .claude/tdd-disabled
```

## Test File Patterns

| Implementation | Test Location |
|----------------|---------------|
| `src/services/user.ts` | `src/services/user.test.ts` |
| `src/services/user.ts` | `tests/services/user.test.ts` |
| `lib/utils.ts` | `lib/utils.test.ts` |
| `app/api/route.ts` | `app/api/route.test.ts` |

## Example Session

```
User: Add a function to validate email addresses

Claude: Starting TDD workflow for email validation.

## Phase 1: RED

Creating test file first...

[Creates src/utils/validate-email.test.ts]

```typescript
import { validateEmail } from './validate-email';

describe('validateEmail', () => {
  it('returns true for valid email', () => {
    expect(validateEmail('user@example.com')).toBe(true);
  });

  it('returns false for email without @', () => {
    expect(validateEmail('userexample.com')).toBe(false);
  });

  it('returns false for empty string', () => {
    expect(validateEmail('')).toBe(false);
  });
});
```

Running tests... ❌ FAILED (expected - module doesn't exist yet)

## Phase 2: GREEN

Now implementing the function...

[Creates src/utils/validate-email.ts]

```typescript
export function validateEmail(email: string): boolean {
  if (!email) return false;
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}
```

Running tests... ✅ PASSED

## Phase 3: REFACTOR

Code is simple enough, no refactoring needed.

✅ TDD cycle complete for validateEmail
```

## Integration with test-engineer Agent

For complex testing scenarios, delegate to test-engineer:

- Coverage analysis
- Test suite optimization
- Flaky test debugging
- E2E test setup

## Anti-Patterns

**Don't:**
- Write implementation first, tests after
- Write tests that test implementation details
- Skip the RED phase (test should fail first)
- Write tests that always pass
- Mock the system under test

**Do:**
- Test behavior, not implementation
- Keep tests independent
- Use descriptive test names
- Test edge cases and errors
- Run tests frequently
