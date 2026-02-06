---
name: server-action
description: Generate Next.js Server Actions with proper patterns
allowed-tools:
  - Read
  - Write
  - Glob
---

# Server Action Generator

Generate Next.js Server Actions with validation, error handling, and revalidation.

## Triggers

- "create server action"
- "generate action"
- "add form action"
- "new server function"

## Process

1. **Gather Requirements**
   - Action name and purpose
   - Input parameters
   - Validation rules
   - Revalidation needs (path or tag)

2. **Check Existing Patterns**
   - Read existing actions in `lib/actions/` or `app/*/actions.ts`
   - Match error handling patterns
   - Match validation patterns (zod, etc.)

3. **Generate Action**
   ```typescript
   'use server'

   import { revalidatePath } from 'next/cache'
   import { z } from 'zod'

   const schema = z.object({
     // validation schema
   })

   export async function actionName(formData: FormData) {
     const validated = schema.safeParse({
       // parse form data
     })

     if (!validated.success) {
       return { error: validated.error.flatten() }
     }

     // action logic

     revalidatePath('/path')
     return { success: true }
   }
   ```

## Output

Creates server action file with:
- 'use server' directive
- Zod validation
- Error handling
- Revalidation
