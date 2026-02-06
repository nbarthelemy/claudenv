---
description: "Build iOS project for simulator or device"
allowed-tools:
  - Bash
  - mcp__xcodebuildmcp__*
---

# /ios:build - Build iOS Project

Build the iOS project using XcodeBuildMCP or xcodebuild.

## Usage

```bash
/ios:build              # Build for simulator (default)
/ios:build device       # Build for device
/ios:build clean        # Clean then build
```

## With XcodeBuildMCP (Preferred)

If XcodeBuildMCP is configured, use MCP tools:

```
mcp__xcodebuildmcp__build_sim_name_proj   # Simulator build
mcp__xcodebuildmcp__build_device_proj     # Device build
mcp__xcodebuildmcp__clean                 # Clean build products
```

## Without MCP (Fallback)

```bash
# Find scheme
xcodebuild -list

# Build for simulator
xcodebuild -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Build for device
xcodebuild -scheme <Scheme> \
  -destination 'generic/platform=iOS' \
  build

# Clean build
xcodebuild clean -scheme <Scheme>
```

## On Failure

1. Show build errors with file locations
2. Identify the root cause (missing import, type error, etc.)
3. Suggest specific fixes
4. Re-run build after fixes
