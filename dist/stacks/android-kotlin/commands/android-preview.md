---
description: Run Android app in emulator
allowed-tools:
  - Bash
---

# /android:preview - Android Emulator Preview

Build and run the app in the Android Emulator.

## Command

```bash
# Build and install
./gradlew installDebug

# Launch app
adb shell am start -n com.yourpackage/.MainActivity
```

## Notes

- Requires Android Emulator or connected device
- Use Android Studio for interactive Compose Previews
- Layout Inspector available for UI debugging
