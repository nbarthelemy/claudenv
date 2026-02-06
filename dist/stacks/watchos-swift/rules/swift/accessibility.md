# watchOS Accessibility Rules

> WCAG 2.1 AA compliance and Apple accessibility best practices for watchOS.

## Mandatory Requirements

### 1. All Interactive Elements Need Labels

```swift
// GOOD
Button("Submit") { }
    .accessibilityLabel("Submit form")
    .accessibilityHint("Double tap to submit")

// BAD - icon-only button without label
Button { } label: {
    Image(systemName: "paperplane")
}
```

### 2. Complication Accessibility

```swift
// GOOD - complications must have descriptive labels
Text(entry.value)
    .accessibilityLabel("Current value: \(entry.value)")

// For gauges and progress
Gauge(value: progress, in: 0...100) {
    Text("Progress")
}
.accessibilityLabel("Progress: \(Int(progress)) percent")
```

### 3. Dynamic Type Support

```swift
// GOOD - respects user's text size preference
Text("Hello")
    .font(.body)  // System font scales automatically

// Use @ScaledMetric for custom values (smaller range on watch)
@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 20
```

### 4. Color Contrast (Higher Requirements)

- watchOS screens are smaller, need higher contrast
- Text: minimum 4.5:1 ratio against background
- Use semantic colors for automatic Dark/Light support
- Test on actual watch hardware (OLED displays)

### 5. Hide Decorative Elements

```swift
Image(systemName: "star.fill")
    .accessibilityHidden(true)  // Decorative only
```

### 6. Group Related Content

```swift
VStack {
    Text("Steps")
    Text("10,543")
}
.accessibilityElement(children: .combine)
.accessibilityLabel("Steps: 10,543")
```

### 7. Support Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
    // Keep animations short on watch
}
```

### 8. Haptic Feedback for Actions

```swift
// Provide haptic confirmation for important actions
Button("Confirm") {
    WKInterfaceDevice.current().play(.success)
    // Action
}
```

## watchOS-Specific Considerations

- **Small touch targets**: Minimum 44x44 points (Apple guideline)
- **Quick interactions**: Users glance briefly at watch
- **Clear focus states**: Essential for VoiceOver navigation
- **Digital Crown support**: `digitalCrownRotation` should be accessible

## Testing Checklist

1. Enable VoiceOver on paired iPhone, test on watch
2. Test with largest Dynamic Type size
3. Navigate all complications with VoiceOver
4. Test with Reduce Motion enabled
5. Verify haptic feedback is appropriate
6. Test Digital Crown interactions

## Common Issues

| Issue | Fix |
|-------|-----|
| Complication not readable | Add `.accessibilityLabel()` |
| Touch target too small | Increase tappable area |
| Animation too long | Respect Reduce Motion |
| Missing haptics | Add `WKInterfaceDevice.current().play()` |
