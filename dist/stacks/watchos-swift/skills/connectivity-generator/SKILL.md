---
name: connectivity-generator
description: Generate WatchConnectivity setup for iPhone pairing
allowed-tools:
  - Read
  - Write
  - Glob
---

# Connectivity Generator

Generate WatchConnectivity setup for iPhone-Watch communication.

## Triggers

- "setup watch connectivity"
- "add iphone sync"
- "create connectivity manager"

## Process

1. **Determine Sync Needs**
   - Application context (state sync)
   - User info (queued messages)
   - File transfer
   - Interactive messaging

2. **Generate Manager**
   - ConnectivityManager class
   - Session delegate implementation
   - Error handling

## Output

Creates:
- `ConnectivityManager.swift` - WCSession manager with delegate

## Capabilities

- Application context (immediate state)
- User info transfer (queued)
- File transfer (background)
- Real-time messaging (when reachable)
