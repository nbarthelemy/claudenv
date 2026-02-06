# Android Kotlin Hooks

Pre-configured hooks for Android development quality enforcement.

## Available Hooks

### ktlint-post-edit.sh

**Event:** PostToolUse
**Matcher:** `Write|Edit`

Runs ktlint on edited Kotlin files. Only triggers for files in Android project directories:
- `src/main/`, `src/debug/`, `src/release/`
- `ui/`, `viewmodel/`, `data/`, `domain/`, `di/`

**Requirements:**
- ktlint configured in Gradle (`./gradlew ktlintCheck`)
- Or ktlint CLI installed (`brew install ktlint`)

### kotlin-file-protection.sh

**Event:** PreToolUse
**Matcher:** `Write|Edit`

Blocks edits to sensitive Android files:
- `Secrets.kt`, `ApiKeys.kt`, `Credentials.kt`
- `google-services.json`, `local.properties`
- `keystore.properties`, `signing.properties`
- Keystore files (`.jks`, `.keystore`)
- `gradle.properties`, `gradle-wrapper.properties`

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
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/ktlint-post-edit.sh"
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
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/kotlin-file-protection.sh"
          }
        ]
      }
    ]
  }
}
```

## Customization

Edit the hook scripts to match your project structure:

1. **Directory patterns** in `ktlint-post-edit.sh` - add/remove paths
2. **Protected files** in `kotlin-file-protection.sh` - add project-specific sensitive files

## Making Hooks Executable

```bash
chmod +x .claude/hooks/*.sh
```

## Gradle ktlint Setup

If not already configured, add ktlint to your project:

```kotlin
// build.gradle.kts (project level)
plugins {
    id("org.jlleitschuh.gradle.ktlint") version "12.1.0" apply false
}

// build.gradle.kts (app level)
plugins {
    id("org.jlleitschuh.gradle.ktlint")
}

ktlint {
    android.set(true)
    ignoreFailures.set(false)
}
```
