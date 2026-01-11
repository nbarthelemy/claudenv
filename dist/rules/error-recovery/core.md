# Error Recovery Guidelines

## Recovery Protocol

When an error occurs, follow this escalation path:

### Attempt 1: Alternative Approach

- Try a different command that achieves the same goal
- Use a different tool if available
- Check for typos or syntax errors

### Attempt 2: Different Method

- Research the error message
- Check documentation for the correct approach
- Try a workaround

### Attempt 3: Diagnostic Deep-Dive

- Run diagnostic commands to understand the environment
- Check versions, dependencies, configuration
- Look for related issues in logs

### Escalation (After 3 Failures)

If all attempts fail:

1. **Summarize** what you tried
2. **Explain** what you learned from each attempt
3. **Suggest** possible solutions user could try
4. **Ask** for guidance

## Self-Healing Actions

These actions can be taken autonomously to recover:

- **Fix linting errors**: Run formatter, fix imports
- **Fix type errors**: Add type annotations, fix mismatches
- **Fix test failures**: Debug and update tests or code
- **Resolve conflicts**: Attempt automatic merge resolution
- **Install missing deps**: For dev dependencies only
- **Create missing files**: If referenced but missing
- **Fix permissions**: chmod for scripts that need to be executable

## Reference

For specific error patterns and examples:
- Read `@rules/error-recovery/patterns.md` when encountering unfamiliar errors
