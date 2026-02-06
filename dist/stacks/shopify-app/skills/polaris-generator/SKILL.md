---
name: polaris-generator
description: Generate Shopify Polaris components following design system patterns
allowed-tools:
  - Read
  - Write
  - Glob
---

# Polaris Component Generator

Generate Shopify Polaris components following the design system.

## Triggers

- "create polaris component"
- "generate polaris"
- "add admin component"
- "new polaris page"

## Process

1. **Determine Component Type**
   - Page (full admin page)
   - Card component
   - Form component
   - Modal component
   - Resource list

2. **Check Polaris Patterns**
   - Read existing components
   - Match Polaris component usage
   - Follow naming conventions

3. **Generate Component**
   Use templates:
   - `templates/polaris-page.tsx.template` for pages
   - `templates/polaris-component.tsx.template` for components

## Output

Creates React component with:
- Polaris imports
- Proper TypeScript types
- App Bridge integration (if needed)
- Loading states
- Error handling

## Common Polaris Patterns

### Page with Resource List
```tsx
import { Page, Layout, Card, ResourceList } from '@shopify/polaris'

export default function ProductsPage() {
  return (
    <Page title="Products">
      <Layout>
        <Layout.Section>
          <Card>
            <ResourceList
              items={items}
              renderItem={(item) => <ResourceItem {...item} />}
            />
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  )
}
```

### Form with Validation
```tsx
import { Form, FormLayout, TextField, Button } from '@shopify/polaris'
import { useState, useCallback } from 'react'

export function SettingsForm() {
  const [value, setValue] = useState('')

  const handleSubmit = useCallback(() => {
    // submit logic
  }, [value])

  return (
    <Form onSubmit={handleSubmit}>
      <FormLayout>
        <TextField
          label="Setting"
          value={value}
          onChange={setValue}
          autoComplete="off"
        />
        <Button submit>Save</Button>
      </FormLayout>
    </Form>
  )
}
```

## Best Practices

- Use Polaris components exclusively in admin UI
- Follow App Design Guidelines
- Use App Bridge for navigation
- Implement loading and error states
- Keep forms accessible
