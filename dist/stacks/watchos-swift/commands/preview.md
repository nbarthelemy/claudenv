---
description: Preview SwiftUI views in watchOS context
allowed-tools:
  - Bash
---

# /preview - SwiftUI Preview for watchOS

Launch SwiftUI previews in the watchOS context.

## Usage

Open Xcode and use the Canvas preview or:

```bash
# Open project in Xcode
xed .

# Or build and show previews
xcodebuild -scheme YourScheme -destination 'platform=watchOS Simulator,name=Apple Watch Series 9 (45mm)' build
```

## Preview Tips

1. Use `#Preview` macro for quick previews
2. Test multiple watch sizes (41mm, 45mm)
3. Preview complications in all families
4. Test with dark and light modes
5. Verify text readability at all sizes

## Complication Previews

```swift
#Preview("Circular", as: .accessoryCircular) {
    YourComplication()
} timeline: {
    YourEntry(value: "42")
}
```
