---
description: "Build and run iOS app on simulator"
allowed-tools:
  - Bash
  - mcp__xcodebuildmcp__*
---

# /ios:run - Build and Run iOS App

Build the app and launch it on a simulator.

## Usage

```bash
/ios:run                    # Run on default simulator (iPhone 16)
/ios:run "iPhone 15 Pro"    # Run on specific simulator
/ios:run --logs             # Run and capture logs
```

## With XcodeBuildMCP (Preferred)

```
# 1. List available simulators
mcp__xcodebuildmcp__list_simulators

# 2. Boot simulator if needed
mcp__xcodebuildmcp__boot_simulator

# 3. Build the app
mcp__xcodebuildmcp__build_sim_name_proj

# 4. Install the app
mcp__xcodebuildmcp__install_app

# 5. Launch the app
mcp__xcodebuildmcp__launch_app

# 6. Capture logs (optional)
mcp__xcodebuildmcp__capture_logs
```

## Without MCP (Fallback)

```bash
# Boot simulator
xcrun simctl boot "iPhone 16"

# Build and run
xcodebuild -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Install (find .app in DerivedData)
xcrun simctl install booted <path-to.app>

# Launch
xcrun simctl launch booted <bundle-identifier>

# Stream logs
xcrun simctl spawn booted log stream --predicate 'subsystem == "<bundle-id>"'
```

## On Launch Issues

1. Check if simulator is booted
2. Verify app bundle identifier
3. Check for runtime crashes in logs
4. Report any launch errors
