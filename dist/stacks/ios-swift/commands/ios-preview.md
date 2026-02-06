---
description: Run iOS app in simulator
allowed-tools:
  - Bash
---

# /ios:preview - iOS Simulator Preview

Build and run the app in the iOS Simulator.

## Command

```bash
# Open Xcode project
open *.xcodeproj 2>/dev/null || open *.xcworkspace

# Or run from command line
xcodebuild -scheme YourScheme -destination 'platform=iOS Simulator,name=iPhone 16' run
```

## Notes

- Opens in Xcode by default for interactive development
- Use simulator for previewing UI changes
- Hot reload available with Xcode Previews
