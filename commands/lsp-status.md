---
name: lsp:status
description: Show installed and available LSP servers
---

# LSP Status

Display the current status of LSP servers for this project.

## Check Configuration

Read `.claude/lsp-config.json` if it exists.

## Detect Current Languages

Scan project for file extensions and map to languages.

## Check Server Status

For each required server, check if installed:

```bash
# Example checks
which typescript-language-server && typescript-language-server --version
which pyright && pyright --version
which gopls && gopls version
which rust-analyzer && rust-analyzer --version
```

## Display Status

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 LSP STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Project Languages:
   TypeScript (423 files)
   Python (89 files)
   Go (34 files)
   Markdown (12 files)
   JSON (45 files)
   YAML (8 files)

🔧 LSP Servers:

Language        Server                      Status      Version
───────────────────────────────────────────────────────────────
TypeScript      typescript-language-server  ✅ Active    4.3.0
Python          pyright                     ✅ Active    1.1.350
Go              gopls                       ✅ Active    0.15.0
Markdown        marksman                    ❌ Missing   -
JSON            vscode-json-languageserver  ❌ Missing   -
YAML            yaml-language-server        ❌ Missing   -

📊 Summary:
   Active: 3
   Missing: 3
   Outdated: 0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 To install missing servers: /lsp
💡 To install specific server: /lsp install <server-name>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## LSP Operations Available

Also show available operations:

```
🔍 Available LSP Operations:

| Operation            | Description                           |
|----------------------|---------------------------------------|
| goToDefinition       | Jump to where symbol is defined       |
| findReferences       | Find all usages of a symbol           |
| hover                | Get docs and type info                |
| documentSymbol       | List all symbols in file              |
| workspaceSymbol      | Search symbols across workspace       |
| goToImplementation   | Find interface implementations        |
| prepareCallHierarchy | Get call hierarchy at position        |
| incomingCalls        | Find what calls this function         |
| outgoingCalls        | Find what this function calls         |

Usage: Use LSP tool with operation, file path, line, and character.
```

## Last Setup Info

```
⏱️ Last LSP setup: 2026-01-03 15:00:00 (2 hours ago)
📁 Config file: .claude/lsp-config.json
```
