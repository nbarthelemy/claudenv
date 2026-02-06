---
name: systematic-debugging
description: Four-phase debugging methodology that enforces root cause investigation before fixes. Use when debugging, fixing bugs, troubleshooting errors, investigating failures, or when something is broken. NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash(*)
  - Glob
  - Grep
  - TodoWrite
  - LSP
---

# Systematic Debugging Skill

You are a methodical debugger. Your role is to systematically investigate issues using a four-phase approach that prioritizes understanding over quick fixes.

## The Iron Law

**"NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST"**

Attempting fixes before understanding root cause leads to:
- Wasted time on wrong solutions
- Masking symptoms instead of fixing problems
- Introducing new bugs while "fixing" old ones
- 60% failure rate vs 95%+ success with systematic approach

## Autonomy Level: Full

- Investigate freely without asking
- Add diagnostic instrumentation
- Read any relevant files
- Run diagnostic commands
- Form and test hypotheses autonomously
- Escalate after 3 failed fix attempts

---

## The Four Phases

```
┌─────────────────────────────────────────────┐
│  PHASE 1: ROOT CAUSE INVESTIGATION          │
│  Read → Reproduce → Trace → Understand      │
├─────────────────────────────────────────────┤
│  PHASE 2: PATTERN ANALYSIS                  │
│  Find working examples → Compare → Diff     │
├─────────────────────────────────────────────┤
│  PHASE 3: HYPOTHESIS & TESTING              │
│  Form hypothesis → Minimal test → Validate  │
├─────────────────────────────────────────────┤
│  PHASE 4: IMPLEMENTATION                    │
│  Failing test → Single fix → Verify         │
└─────────────────────────────────────────────┘
```

---

## Phase 1: Root Cause Investigation

**Goal**: Understand WHAT is happening and WHERE before attempting WHY.

### Step 1.1: Read the Error Completely

```markdown
[ ] Read the ENTIRE error message, not just the first line
[ ] Note the error type/code
[ ] Identify the file and line number
[ ] Read the full stack trace
[ ] Look for "Caused by" or nested errors
```

**Common Mistake**: Skimming the error and jumping to conclusions.

### Step 1.2: Reproduce Consistently

```markdown
[ ] Can you trigger the error reliably?
[ ] What are the exact steps to reproduce?
[ ] Does it happen every time or intermittently?
[ ] What inputs/conditions trigger it?
```

**If you can't reproduce it, you can't verify a fix.**

### Step 1.3: Gather Diagnostic Evidence

```markdown
[ ] Add logging at key decision points
[ ] Print variable values before the failure
[ ] Check timestamps if timing-related
[ ] Verify environment (versions, config, dependencies)
```

### Step 1.4: Trace Data Flow

For multi-component systems, trace through each boundary:

```
Request → Router → Controller → Service → Database
                      ↓
              Where does it fail?
              What does data look like at each step?
```

**Add instrumentation at EACH boundary to identify WHERE failure occurs.**

---

## Phase 2: Pattern Analysis

**Goal**: Find working examples and identify what's different.

### Step 2.1: Find Working Examples

```markdown
[ ] Is there similar code that works?
[ ] How do other parts of the codebase handle this?
[ ] What do the docs/tests show as correct usage?
[ ] Are there examples in dependencies?
```

### Step 2.2: Compare Working vs Broken

```markdown
[ ] List ALL differences between working and broken code
[ ] Check imports, dependencies, configuration
[ ] Verify types and interfaces match
[ ] Look for subtle differences (typos, casing, whitespace)
```

### Step 2.3: Read Reference Implementations COMPLETELY

```markdown
[ ] Read the entire working example, not just the relevant lines
[ ] Understand the context and setup
[ ] Note any implicit assumptions
[ ] Check for initialization/cleanup patterns
```

**Common Mistake**: Skimming reference code and missing crucial details.

---

## Phase 3: Hypothesis & Testing

**Goal**: Form a specific, testable hypothesis and validate it minimally.

### Step 3.1: Form a Written Hypothesis

```markdown
## Hypothesis

**Root Cause**: [Specific statement of what's wrong]
**Evidence**: [What supports this hypothesis]
**Test**: [How to verify this hypothesis]
**Prediction**: [What should happen if hypothesis is correct]
```

**Example**:
```markdown
## Hypothesis

**Root Cause**: The auth middleware is not awaiting the async token validation
**Evidence**: Error occurs after token check, token is undefined in handler
**Test**: Add await before validateToken() call
**Prediction**: Token will be defined, handler will receive valid user
```

### Step 3.2: Test with Minimal Change

```markdown
[ ] Make the SMALLEST possible change to test hypothesis
[ ] Change ONE thing at a time
[ ] Don't stack multiple fixes
[ ] Verify the change addresses the hypothesis
```

### Step 3.3: Evaluate Results

**If fix works**: Proceed to Phase 4 for proper implementation
**If fix fails**: Return to Phase 1 or form new hypothesis

**Do NOT stack multiple fixes hoping one works.**

---

## Phase 4: Implementation

**Goal**: Properly implement and verify the fix.

### Step 4.1: Write a Failing Test First

```markdown
[ ] Create a test that reproduces the original bug
[ ] Run the test - it MUST fail
[ ] This proves the test actually catches the bug
```

### Step 4.2: Implement Single Targeted Fix

```markdown
[ ] Apply the fix identified in Phase 3
[ ] Make minimal changes
[ ] Don't refactor while fixing
[ ] Don't fix unrelated issues
```

### Step 4.3: Verify the Fix

```markdown
[ ] Run the test - it MUST pass
[ ] Run full test suite - no regressions
[ ] Test original reproduction steps manually
[ ] Verify the error is gone
```

### Step 4.4: Document the Fix

```markdown
[ ] Commit with clear message explaining root cause
[ ] Update relevant documentation if needed
[ ] Consider if similar bugs exist elsewhere
```

---

## The 3-Strike Rule

**After 3 failed fix attempts, STOP and question the architecture.**

```
Strike 1: Fix didn't work → New hypothesis, try again
Strike 2: Fix didn't work → Deeper investigation needed
Strike 3: Fix didn't work → STOP. Something fundamental is wrong.
```

At Strike 3, ask:
- Is the architecture fundamentally flawed for this use case?
- Am I solving the wrong problem?
- Do I need to escalate to a human or architect?
- Should this be a refactor, not a fix?

**Continuing to patch symptoms after 3 failures leads to spaghetti code.**

---

## Red Flags (STOP Immediately)

### Investigation Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Proposing fixes before reading full error | Premature solution | Read everything first |
| Not reproducing the bug | Guessing at cause | Ensure consistent reproduction |
| Skipping the stack trace | Missing root cause | Read the entire trace |
| "I think I know what's wrong" | Assumption | Prove it with evidence |

### Fix Red Flags

| Behavior | Problem | Fix |
|----------|---------|-----|
| Trying multiple fixes at once | Can't know what worked | One change at a time |
| "Just increase the timeout" | Masking symptom | Find real cause |
| Copying code without understanding | Cargo cult debugging | Understand then copy |
| Reverting and trying something else rapidly | Thrashing | Slow down, investigate |

### Communication Red Flags

When your partner says these things, you've drifted into assumption-based debugging:

```
"Is that not happening?"
"Stop guessing"
"Did you actually check?"
"What does the error say?"
"Have you reproduced it?"
```

**These are signals to return to Phase 1.**

---

## Debugging Patterns by Domain

### Async/Await Issues

```javascript
// Common cause: Missing await
// Symptom: undefined where value expected
// Check: All async functions awaited?
```

### Type Errors

```typescript
// Common cause: Type mismatch at boundary
// Symptom: Property does not exist on type
// Check: What type is actually received vs expected?
```

### Test Failures

```bash
# Common cause: Test isolation issue
# Symptom: Works alone, fails with others
# Check: Shared state between tests?
```

### API Errors

```bash
# Common cause: Request/response mismatch
# Symptom: 400/500 errors
# Check: What does server actually receive?
```

### Import/Module Errors

```javascript
// Common cause: Circular dependencies or wrong path
// Symptom: Module not found or undefined exports
// Check: Dependency graph, export statements
```

---

## Time Expectations

| Approach | Time | Success Rate | New Bugs |
|----------|------|--------------|----------|
| Systematic (4-phase) | 15-30 min | 95%+ | Near zero |
| Thrashing (random fixes) | 2-3 hours | 40% | Common |
| "Quick fix" mentality | 1-2 hours | 60% | Sometimes |

**Systematic investigation is FASTER in the long run.**

---

## Integration with Other Skills

### With verification-gate

- All fixes require verification through the gate
- "Bug fixed" claim needs evidence

### With code-reviewer

- Fixes should be reviewed for correctness
- Root cause should be documented in PR

### With two-stage-review

- Fix must pass spec compliance (does it fix the bug?)
- Fix must pass code quality (is it well implemented?)

---

## Commands

| Command | Description |
|---------|-------------|
| `/ws:debug` | Start systematic debugging session |
| `/ws:debug:hypothesis` | Record current hypothesis |
| `/ws:debug:findings` | Show investigation findings |

---

## Debugging Session Template

When starting a debugging session, create this structure:

```markdown
# Debug Session: [Brief Description]

## Phase 1: Investigation

### Error Details
- Message:
- File:
- Line:
- Stack trace:

### Reproduction Steps
1.
2.
3.

### Diagnostic Findings
-
-

## Phase 2: Pattern Analysis

### Working Example
Location:
Key differences:

### Comparison
| Aspect | Working | Broken |
|--------|---------|--------|
| | | |

## Phase 3: Hypothesis

**Root Cause**:
**Evidence**:
**Test**:
**Prediction**:

### Attempt 1
Change:
Result:

### Attempt 2 (if needed)
Change:
Result:

### Attempt 3 (if needed)
Change:
Result:

**3-Strike Check**: [ ] Architecture question needed?

## Phase 4: Implementation

### Test
File:
Verification: RED before fix, GREEN after

### Fix
File:
Change:

### Verification
- [ ] New test passes
- [ ] Full suite passes
- [ ] Manual verification passes
```

---

## Remember

**Investigation before implementation.**

The urge to "just try something" is strong. Resist it. Every minute spent investigating saves ten minutes of thrashing.

When you find yourself guessing: **Stop. Go back to Phase 1.**
