# iOS Accessibility Rules

> WCAG 2.1 AA compliance and Apple accessibility best practices.

## Mandatory Requirements

### 1. All Interactive Elements Need Labels

```swift
// GOOD
Button("Submit") { }
    .accessibilityLabel("Submit form")
    .accessibilityHint("Double tap to submit your information")

// BAD - icon-only button without label
Button { } label: {
    Image(systemName: "paperplane")
}
```

### 2. Dynamic Type Support

```swift
// GOOD - respects user's text size preference
Text("Hello")
    .font(.body)  // System font scales automatically

// Use @ScaledMetric for custom values
@ScaledMetric var iconSize: CGFloat = 24
```

### 3. Color Contrast

- Text: minimum 4.5:1 ratio against background
- Large text (18pt+): minimum 3:1 ratio
- Use `.foregroundStyle(.primary)` or `.secondary` for automatic contrast

### 4. Don't Rely on Color Alone

```swift
// GOOD - uses icon + color
HStack {
    Image(systemName: "exclamationmark.triangle")
    Text("Error")
}
.foregroundStyle(.red)

// BAD - color only
Text("Error")
    .foregroundStyle(.red)
```

### 5. Hide Decorative Elements

```swift
Image(systemName: "star.fill")
    .accessibilityHidden(true)  // Decorative only
```

### 6. Group Related Content

```swift
VStack {
    Text("John Doe")
    Text("Software Engineer")
}
.accessibilityElement(children: .combine)
```

### 7. Support Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .spring()) {
    // Animation
}
```

## Testing Checklist

1. Enable VoiceOver and navigate entire app
2. Test with largest Dynamic Type size
3. Use Accessibility Inspector in Xcode
4. Test with Reduce Motion enabled
5. Verify color contrast with Color Contrast Analyzer
6. Test with Switch Control

## Common Issues

| Issue | Fix |
|-------|-----|
| Missing labels on icons | Add `.accessibilityLabel()` |
| Text not scaling | Use system fonts or `@ScaledMetric` |
| Poor contrast | Use semantic colors |
| Focus order wrong | Use `.accessibilitySortPriority()` |
