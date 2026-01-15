# Test-Driven Development

> TDD is enforced in this project. Write failing tests before implementation.

## The TDD Cycle

```
RED → GREEN → REFACTOR
 │      │         │
 │      │         └── Improve code quality (tests still pass)
 │      └── Write minimal code to make test pass
 └── Write a failing test first
```

## Mandatory Workflow

**Before writing ANY implementation code:**

1. **Write the test first** - Describe expected behavior in test form
2. **Run the test** - Verify it fails (red)
3. **Write minimal implementation** - Just enough to pass
4. **Run the test** - Verify it passes (green)
5. **Refactor** - Clean up while tests stay green

## File Mapping

| Implementation | Test File |
|----------------|-----------|
| `src/**/*.ts` | `src/**/*.test.ts` OR `tests/**/*.test.ts` |
| `src/**/*.tsx` | `src/**/*.test.tsx` OR `tests/**/*.test.tsx` |
| `app/**/*.ts` | `app/**/*.test.ts` OR `__tests__/**/*.test.ts` |
| `lib/**/*.ts` | `lib/**/*.test.ts` OR `tests/**/*.test.ts` |
| `*.py` | `test_*.py` OR `*_test.py` |
| `*.go` | `*_test.go` |

## Enforcement

A PreToolUse hook blocks writes to implementation files unless:
- A corresponding test file already exists, OR
- You are currently writing a test file

**To add new functionality:**
```
1. Create/edit test file first (e.g., user-service.test.ts)
2. Write failing test
3. Now you can edit implementation (e.g., user-service.ts)
```

## Bypass (Use Sparingly)

For non-testable files (configs, types, constants), the hook allows:
- `*.config.*`, `*.d.ts`, `types.ts`, `constants.ts`
- Files in: `config/`, `types/`, `public/`, `assets/`

## Benefits

- **Confidence**: Tests prove code works
- **Design**: Writing tests first improves API design
- **Documentation**: Tests document expected behavior
- **Refactoring**: Safe to change code with test coverage
