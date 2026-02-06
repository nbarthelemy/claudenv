---
description: "Build and run Android app on emulator or device"
allowed-tools:
  - Bash
---

# /android:run - Build and Run Android App

Build the app and launch it on an emulator or connected device.

## Usage

```bash
/android:run                    # Run on default device
/android:run --device           # Run on connected device
/android:run --emulator         # Run on emulator
/android:run --logs             # Run and capture logcat
```

## Commands

```bash
# 1. List available devices
adb devices

# 2. List available emulators
emulator -list-avds

# 3. Start emulator (if needed)
emulator -avd <avd_name> &

# 4. Build and install
./gradlew installDebug

# 5. Launch app
adb shell am start -n <package>/<activity>

# 6. Stream logs (optional)
adb logcat *:E | grep <package>
```

## Finding Package and Activity

```bash
# From AndroidManifest.xml or build.gradle
# Package: com.example.myapp
# Activity: .MainActivity or .ui.MainActivity

adb shell am start -n com.example.myapp/.MainActivity
```

## On Launch Issues

1. Check if device/emulator is connected (`adb devices`)
2. Verify app is installed (`adb shell pm list packages | grep <package>`)
3. Check logcat for crashes
4. Report any launch errors
