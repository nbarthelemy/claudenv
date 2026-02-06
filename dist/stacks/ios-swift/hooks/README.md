# iOS Swift Hooks

Pre-configured hooks for iOS development quality enforcement.

## Available Hooks

### swiftlint-post-edit.sh

**Event:** PostToolUse
**Matcher:** `Write|Edit`

Runs SwiftLint on edited Swift files. Only triggers for files in iOS project directories:
- `App/`, `Features/`, `Core/`, `Sources/`
- `Models/`, `Views/`, `ViewModels/`, `Services/`

**Requirements:**
- SwiftLint installed (`brew install swiftlint`)
- `.swiftlint.yml` in project root

### swift-file-protection.sh

**Event:** PreToolUse
**Matcher:** `Write|Edit`

Blocks edits to sensitive iOS files:
- `Secrets.swift`, `APIKeys.swift`, `Credentials.swift`
- `GoogleService-Info.plist`, `Info.plist`
- `.xcconfig` files
- Lock files (`Podfile.lock`, `Package.resolved`)

## Installation

Add to `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/swiftlint-post-edit.sh"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/swift-file-protection.sh"
          }
        ]
      }
    ]
  }
}
```

## Customization

Edit the hook scripts to match your project structure:

1. **Directory patterns** in `swiftlint-post-edit.sh` - add/remove paths
2. **Protected files** in `swift-file-protection.sh` - add project-specific sensitive files

## Making Hooks Executable

```bash
chmod +x .claude/hooks/*.sh
```
