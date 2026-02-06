# Android Accessibility Rules

> WCAG 2.1 AA compliance and Android accessibility best practices.

## Mandatory Requirements

### 1. Content Descriptions for All Interactive Elements

```kotlin
// GOOD
IconButton(
    onClick = { },
    modifier = Modifier.semantics { 
        contentDescription = "Submit form"
    }
) {
    Icon(Icons.Default.Send, contentDescription = null)
}

// Or using Compose's built-in
Icon(
    Icons.Default.Send,
    contentDescription = "Send message"
)
```

### 2. Minimum Touch Target Size (48dp)

```kotlin
// GOOD
IconButton(
    onClick = { },
    modifier = Modifier.size(48.dp)
) {
    Icon(Icons.Default.Add, "Add item")
}

// Or use minimumInteractiveComponentSize
Modifier.minimumInteractiveComponentSize()
```

### 3. Color Contrast

- Text: minimum 4.5:1 ratio against background
- Large text (18sp+): minimum 3:1 ratio
- Use Material Theme colors which meet requirements

### 4. Don't Rely on Color Alone

```kotlin
// GOOD - uses icon + color
Row {
    Icon(Icons.Default.Error, "Error")
    Text("Something went wrong")
}

// BAD - color only
Text("Error", color = Color.Red)
```

### 5. Support Font Scaling

```kotlin
// GOOD - uses sp units (scales)
Text(
    text = "Hello",
    fontSize = 16.sp
)

// BAD - fixed size that won't scale
Text(
    text = "Hello",
    fontSize = 16.dp  // Never use dp for text
)
```

### 6. Group Related Content

```kotlin
Row(
    modifier = Modifier.semantics(mergeDescendants = true) { }
) {
    Text("John Doe")
    Text("Software Engineer")
}
```

### 7. Announce Dynamic Changes

```kotlin
Text(
    text = statusMessage,
    modifier = Modifier.semantics {
        liveRegion = LiveRegionMode.Polite
    }
)
```

### 8. Heading Structure

```kotlin
Text(
    text = "Settings",
    modifier = Modifier.semantics { heading() }
)
```

## Testing Checklist

1. Enable TalkBack and navigate entire app
2. Test with largest font size (Settings > Display > Font size)
3. Use Accessibility Scanner app
4. Test with Switch Access enabled
5. Verify touch targets are 48dp minimum
6. Test keyboard/D-pad navigation

## Common Issues

| Issue | Fix |
|-------|-----|
| Missing contentDescription | Add to `semantics { }` block |
| Touch target too small | Use `minimumInteractiveComponentSize()` |
| Poor contrast | Use Material Theme colors |
| Text not scaling | Use `sp` units, not `dp` |
| Focus order wrong | Use `focusOrder {}` |
