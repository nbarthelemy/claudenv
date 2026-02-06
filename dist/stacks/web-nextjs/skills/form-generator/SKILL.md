---
name: form-generator
description: Generate forms with React Hook Form, Zod validation, and server actions
allowed-tools:
  - Read
  - Write
  - Glob
  - WebFetch
---

# Form Generator

Generate type-safe forms with validation and server action integration.

## Triggers

- "create form"
- "generate form"
- "add form"
- "input form"

## Documentation Access

**Research before implementing.** Consult:
- https://react-hook-form.com - React Hook Form docs
- https://zod.dev - Zod validation docs
- https://react.dev/reference/react/useActionState - Server action integration

## Process

1. **Define Form Schema**
   - Create Zod schema for validation
   - Infer TypeScript types

2. **Check Existing Patterns**
   - Look for form components in project
   - Match styling patterns

3. **Generate Form**
   - Create form component with RHF
   - Add server action for submission
   - Include error handling

## Output

Creates:
- `components/forms/{name}-form.tsx` - Form component
- `lib/schemas/{name}.ts` - Zod schema
- `lib/actions/{name}.ts` - Server action

## Templates

### Zod Schema
```typescript
// lib/schemas/contact.ts
import { z } from "zod"

export const contactSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters"),
  email: z.string().email("Invalid email address"),
  message: z.string().min(10, "Message must be at least 10 characters"),
})

export type ContactInput = z.infer<typeof contactSchema>
```

### Form Component
```tsx
"use client"

import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import { useActionState } from "react"
import { contactSchema, type ContactInput } from "@/lib/schemas/contact"
import { submitContact } from "@/lib/actions/contact"

export function ContactForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<ContactInput>({
    resolver: zodResolver(contactSchema),
  })

  const [state, formAction, isPending] = useActionState(submitContact, null)

  return (
    <form action={formAction} className="space-y-4">
      <div>
        <label htmlFor="name">Name</label>
        <input {...register("name")} id="name" />
        {errors.name && <p className="text-red-500">{errors.name.message}</p>}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input {...register("email")} id="email" type="email" />
        {errors.email && <p className="text-red-500">{errors.email.message}</p>}
      </div>

      <div>
        <label htmlFor="message">Message</label>
        <textarea {...register("message")} id="message" rows={4} />
        {errors.message && <p className="text-red-500">{errors.message.message}</p>}
      </div>

      <button type="submit" disabled={isPending}>
        {isPending ? "Sending..." : "Send Message"}
      </button>

      {state?.error && <p className="text-red-500">{state.error}</p>}
      {state?.success && <p className="text-green-500">Message sent!</p>}
    </form>
  )
}
```

### Server Action
```typescript
// lib/actions/contact.ts
"use server"

import { contactSchema } from "@/lib/schemas/contact"

export async function submitContact(prevState: any, formData: FormData) {
  const rawData = Object.fromEntries(formData)
  const parsed = contactSchema.safeParse(rawData)

  if (!parsed.success) {
    return { error: parsed.error.errors[0].message }
  }

  try {
    // Process form data
    await sendEmail(parsed.data)
    return { success: true }
  } catch (error) {
    return { error: "Failed to send message" }
  }
}
```

## Best Practices

- Define schemas in separate files for reuse
- Use server actions for form submission
- Show loading states during submission
- Display field-level and form-level errors
- Use proper HTML labels and accessibility
