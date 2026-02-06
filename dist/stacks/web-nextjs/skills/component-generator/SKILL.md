---
name: component-generator
description: Generate React components with TypeScript, Tailwind, and proper patterns
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Component Generator

Generate React components following project conventions and best practices.

## Triggers

- "create component"
- "generate component"
- "new component"
- "add component"

## Documentation Access

**Research before implementing.** Consult:
- https://react.dev/reference/react - React 19 reference
- https://tailwindcss.com/docs - Tailwind CSS 3 docs

## Process

1. **Determine Component Type**
   - Server Component (default for data fetching)
   - Client Component (for interactivity)
   - Shared/UI Component (reusable)

2. **Check Existing Patterns**
   - Look for similar components in `components/`
   - Match naming and structure conventions

3. **Generate Component**
   - Create component file with proper typing
   - Add Tailwind styling
   - Include accessibility attributes

## Output

Creates:
- `components/{name}/{name}.tsx` - Component file
- `components/{name}/index.ts` - Export barrel (optional)

## Templates

### Server Component
```tsx
interface {Name}Props {
  title: string
  children?: React.ReactNode
}

export async function {Name}({ title, children }: {Name}Props) {
  const data = await fetchData()

  return (
    <section className="space-y-4">
      <h2 className="text-2xl font-bold">{title}</h2>
      {children}
    </section>
  )
}
```

### Client Component
```tsx
"use client"

import { useState } from "react"

interface {Name}Props {
  initialValue?: string
  onChange?: (value: string) => void
}

export function {Name}({ initialValue = "", onChange }: {Name}Props) {
  const [value, setValue] = useState(initialValue)

  const handleChange = (newValue: string) => {
    setValue(newValue)
    onChange?.(newValue)
  }

  return (
    <div className="relative">
      {/* Component content */}
    </div>
  )
}
```

## Best Practices

- Prefer Server Components unless interactivity needed
- Use TypeScript interfaces for props
- Include aria-labels for accessibility
- Compose smaller components
- Co-locate related files
