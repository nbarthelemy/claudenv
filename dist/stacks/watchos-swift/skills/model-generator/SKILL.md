---
name: model-generator
description: Generate data models with SwiftData support
allowed-tools:
  - Read
  - Write
  - Glob
---

# Model Generator

Generate data models with SwiftData and Codable support.

## Triggers

- "create model"
- "add data model"
- "generate entity"

## Process

1. **Gather Requirements**
   - Model name
   - Properties and types
   - Relationships
   - Persistence needs

2. **Generate Model**
   - SwiftData @Model for persistence
   - DTO struct for API responses
   - Codable conformance

## Output

Creates:
- `{Name}.swift` - Model with SwiftData support and DTO
