# Documentation Rules

## Automatic Documentation Updates

When you modify code, you MUST update documentation in the same response. This is not optional.

### Inline Documentation

When editing functions, classes, or complex logic:
- Add/update docstrings explaining purpose and parameters
- Add inline comments for non-obvious logic
- Update existing comments if behavior changes

### File-Level Documentation

When adding or significantly changing a file:
- Ensure file has a header comment explaining its purpose
- Update any imports/exports documentation

### Project Documentation

When changes affect user-facing behavior:
- Update README.md if usage changes
- Update CLAUDE.md if conventions change
- Update command/skill .md files if their behavior changes

### Changelog

When shipping releases:
- Add changelog entry describing what changed
- Use clear, user-focused language

## Enforcement

This rule is AUTOMATIC. Do not ask permission to update docs. Do not skip doc updates to "save time." Every code change includes its documentation update in the same commit.

## What NOT to Document

- Obvious code (e.g., `i++` doesn't need `# increment i`)
- Temporary debug code
- Self-explanatory variable names
